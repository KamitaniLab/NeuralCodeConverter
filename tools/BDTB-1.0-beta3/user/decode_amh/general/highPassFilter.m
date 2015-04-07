function [D, pars] = highPassFilter(D, pars)
%highPassFilter - apply high-pass filter
%[D, pars] = highPassFilter(D, pars)
%
% Apply high-pass filter to data along dimension 'appDim'
%
% Input:
%	D.data              - 2D matrix of any format (double)
%
% Optional:
%   pars.dt             - sampling interval (default = 2 s)
%	pars.cutoff         - cut-off frequency in second (default = 128 s)
%	                      or list of cut-off frequency (e.g, [128 128 128 ...])
%	pars.app_dim        - dimension along which this process will be applied
%                         1: across time (default), 2: across space(channels)
%	pars.linear_detrend - perform 'detrend' before high-pass filtering
%                         1: do it (default), 0: skip
%	pars.breaks         - [2 x N] matrix of break points for piecewise filtering;
%	                      rows: 1-begin points, 2-end points; may contain just begin or end;
%   pars.break_run      - use 'inds_runs' as 'breaks' (1, defaults), or not (0)
%	pars.verbose        - [1..3] = print detail level; 0 = no printing (default=1)
%
% Output:
%	D.data              - high-pass filtered data in same format
%
% Status: tested preliminary
%
% Created  By: Yoichi Miyawaki (1),  yoichi_m@atr.jp   08/06/25
% Modified By: Satoshi MURATA (1),   satoshi-m@atr.jp  08/10/07
% (1) ATR Intl. Computational Neuroscience Labs, Decoding Group


%% Check and get pars:
if exist('D','var')==0 || isempty(D),   error('Wrong args');    end
if exist('pars','var')==0,              pars = [];              end

pars           = getFieldDef(pars,mfilename,pars);
dt             = getFieldDef(pars,'dt',2);
cutoff         = getFieldDef(pars,'cutoff',128);
app_dim        = getFieldDef(pars,'app_dim',1);
linear_detrend = getFieldDef(pars,'linear_detrend',1);
breaks         = getFieldDef(pars,'breaks',[]);
break_run      = getFieldDef(pars,'break_run',1);
verbose        = getFieldDef(pars,'verbose',1);

if isempty(breaks)
    if break_run,   breaks = D.inds_runs;
    else            breaks = [1;size(D.data,app_dim)];      end
end
num_breaks = size(breaks,2);

if size(cutoff,1)~=1,   error('''cutoff'' should be a single scalar or a 1xN vector');  end

if     size(cutoff,2)==1,           cutoff = repmat(cutoff,1,num_breaks);
elseif size(cutoff,2)~=num_breaks,  cutoff = [cutoff,repmat(128,1,num_breaks-size(cutoff,2))];  end     % padded by default value


%% Add path of SPM (if needed):
str = which('spm_filter');
if isempty(str)
    dirname = selectDir_gui(pwd,'Select ''SPM'' directory');
    if isempty(dirname),    error('Can''t find ''SPM''');       end
    addpath(dirname);
end

% load default:
spm_defaults;


%% Fix dims for detrend and high-pass:
if app_dim==2,      D.data = D.data';       end


%% For UI:
if verbose
    % fprintf(['\n' mfilename ' ------------------------------']);
    if verbose>=2
        fprintf('\n # breaks:      \t%d',num_breaks);
        fprintf('\n sampling intv: \t%g',dt);
        fprintf('\n cutoff:        \t%g',cutoff);
        fprintf('\n app_dim:       \t%d',app_dim);
        fprintf('\n linear detrend:\t%d',linear_detrend);
    end
    % fprintf('\n');
end


%% Detrend:
if linear_detrend
    for itb=1:num_breaks
        bi = breaks(1,itb);
        ei = breaks(2,itb);
        
        D.data(bi:ei,:) = detrend(D.data(bi:ei,:));
    end
end


%% High-path:
% Set filter kernel information -- depend on SPM lib
Kc = cell(1,num_breaks);
for itb=1:num_breaks
    Kc{itb}.row    = breaks(1,itb):breaks(2,itb);   % voluem index
    Kc{itb}.HParam = cutoff(itb);
    Kc{itb}.RT     = dt;
    
    k          = length(Kc{itb}.row);
    n          = fix(2*(k*Kc{itb}.RT)/Kc{itb}.HParam + 1);
    X0         = spm_dctmtx(k,n);
    Kc{itb}.X0 = X0(:,2:end);
end

K = cell2mat(Kc);
Y = D.data;

K = spm_filter(K);
Y = spm_filter(K,Y);

D.data = Y;

% for debug -- check power spectrum density
if 0
    Fs = 1/2;
    h = spectrum.welch; 
    
    for rt = 1:20,
        idx = breaks(1,rt):breaks(2,rt);    % volume index
        for i=1:10
            hpf = psd(h,Y(idx,i),'Fs',Fs);
            dbpsd.hpf(:,i) = log10(hpf.Data./trapz(hpf.Frequencies,hpf.Data));
            hpf = psd(h,D.data(idx,i),'Fs',Fs);
            dbpsd.org(:,i) = log10(hpf.Data./trapz(hpf.Frequencies,hpf.Data));
        end
    end
end


if app_dim==2,  D.data = D.data';       end;
