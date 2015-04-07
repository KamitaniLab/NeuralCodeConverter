function [D, pars] = zNorm_amh(D, pars)
%zNorm_amh - normalizes data by z=(data-mean)/std along pars.app_dim
%[D, pars] = zNorm_amh(D, pars)
%
% Input:
%   D.data        - 2D matrix of any data ([time(sample) x space(voxel/channel)] format)
% Optional:
%   pars.mode     - 1: train (make .mu, .sd), or 2: test (use .mu, .sd)
%   pars.smode    - over-riding static mode (smode=1 always calcs mu, sd)
%   pars.app_dim  - dim to normalize along (1=time, 2=space, default=2)
%   pars.sub_mean - subtract mean? (1=yes, 2=no, default=1)
%   pars.verbose  - [1..3] = print detail level; 0 = no printing (default=0)
%   pars.mu       - mean
%   pars.sd       - standard deviation
% Output:
%   D.data        - normalized data
%   pars          - modified pars, including adding .mu .sd if training mode
%
% Notes:
% 	Subtracting by mean is optional.
% 	If data is a vector, it will set app_dim to the non-singular dim
% 	(normalizing along the vector)
%
% Created  By: Alex Harner (1),     alexh@atr.jp      06/04/07
% Modified By: Alex Harner (1),     alexh@atr.jp      06/10/16
% Modified By: Satoshi MURATA (1),  satoshi-m@atr.jp  08/09/30
% (1) ATR Intl. Computational Neuroscience Labs, Decoding Group


%% Check and get pars:
if exist('D','var')==0 || isempty(D)
    error('''D''ata-struct must be specified');
end
if exist('pars','var')==0,      pars = [];      end

if isfield(pars,mfilename)      % unnest, if needed
    P    = pars;
    pars = P.(mfilename);
end
mode     = getFieldDef(pars,'mode',1);
smode    = getFieldDef(pars,'smode',0);
app_dim  = getFieldDef(pars,'app_dim',2);
sub_mean = getFieldDef(pars,'sub_mean',1);
verbose  = getFieldDef(pars,'verbose',0);

if smode,       mode = 1;       end


%% For UI:
if verbose
    fprintf(['\n' mfilename ' ------------------------------']);
    if verbose>=2
        fprintf('\n mode:    \t%d',mode);
        fprintf('\n app_dim: \t%d',app_dim);
        fprintf('\n sub_mean:\t%d\n',sub_mean);
    end
end


%% If data is a vector, set app_dim to the non-singular dim
data_size = size(D.data);
if data_size(1)==1,         app_dim = 2;
elseif data_size(2)==1,     app_dim = 1;        end

pars.app_dim = app_dim;


%% Set mean and standard deviation:
if mode==1 || isfield(pars,'mean')==0
    mu        = mean(D.data,app_dim);
    pars.mean = mu;
else
    mu = pars.mean;
end

if mode==1 || isfield(pars,'std')==0
    sd       = std(D.data,0,app_dim);
    pars.std = sd;
else
    sd = pars.std;
end


%% Can't have sd==0:
if isempty(find(sd==0,1))==0
    fprintf('\n Warning: sd==0; will set it to 0.01!\n');
    sd(sd==0) = 0.01;
end


%% Normalize data:
if app_dim==1
    mu = repmat(mu,data_size(1),1);
    sd = repmat(sd,data_size(1),1);
else
    mu = repmat(mu,1,data_size(2));
    sd = repmat(sd,1,data_size(2));
end

if sub_mean     % optionally, subtract mean
    D.data = (D.data-mu) ./ sd;
else            % only / by standard deviation
    D.data = D.data ./ sd;
end


%% For 'P'ars-struct
if exist('P','var')
    P.(mfilename) = pars;
end
