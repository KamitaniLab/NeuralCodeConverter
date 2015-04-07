function [D, pars] = selectTopFvals(D, pars)
%selectTopFvals - selects top N channels/samples of data based on its anova F-vals
%[D, pars] = selectTopFvals(D, pars)
%
% Input:
%   D.data          - 2D matrix of any data ([time(sample) x space(voxel/channel)] format)
%   D.labels        - condition labels of each sample ([time x 1] format)
% Optional:
%   pars.inds_fvals - indices of data ordered F-vals; optional for training
%   pars.fvals      - F-vals matching inds_fvals (descending) (result of training)
%   pars.mode       - 1: train (make Finds), or 2: test (use inds_fvals)
%   pars.app_dim    - application (component) dimension (default=2:channel)
%   pars.num_comp   - number of F-vals to select or percent; may be a percent
%                     default: all components
%   pars.fvals_min  - min value of F-vals range to use
%   pars.fvals_max  - max value of F-vals range to use
%   pars.verbose    - [1..3] = print detail level; 0 = no printing (default=0)
% Output:
%   D.data          - data with top N channels remaining, ordered by decreasing F-val
%   pars            - modified pars, including adding .inds_fvals if training mode
%
% Calls: anovaFvals
%
% Created  By: Alex Harner (1),     alexh@atr.jp      06/09/11
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
inds_fvals = getFieldDef(pars,'inds_fvals',[]);
mode       = getFieldDef(pars,'mode',1);
app_dim    = getFieldDef(pars,'app_dim',2);
verbose    = getFieldDef(pars,'verbose',0);
num_comp   = getFieldDef(pars,'num_comp',size(D.data,app_dim));
fvals_min  = getFieldDef(pars,'fvals_min',-inf);
fvals_max  = getFieldDef(pars,'fvals_max',inf);

if num_comp<1,      num_comp = round(num_comp*size(D.data,app_dim));        end
pars.num_comp = num_comp;

if app_dim==1,      D.data = D.data';       end


%% For UI:
if verbose
    fprintf(['\n' mfilename ' ------------------------------']);
    if verbose>=2
        fprintf('\n mode     :\t%d',mode);
        if mode==1
            fprintf('\n app_dim:  \t%d',app_dim);
            fprintf('\n num_comp: \t%d',num_comp);
            if fvals_min>-inf,      fprintf('\n fvals_min:\t%g',fvals_min);     end
            if fvals_max<inf,       fprintf('\n fvals_max:\t%g',fvals_max);     end
        end
    end
end


%% Test mode:
if mode==2
    D.data = D.data(:,inds_fvals);


%% Train mode:
else
    % Calc anova F-vals:
    fvals = anovaFvals(D.data, D.labels);
    
    % Select top N within range
    [fvals, inds_fvals] = sort(fvals,'descend');
    inds_use            = find(fvals>=fvals_min & fvals<=fvals_max);
    inds_fvals          = inds_fvals(inds_use);
    num_comp            = min(num_comp,length(inds_fvals));
    inds_fvals          = inds_fvals(1:num_comp);
    D.data              = D.data(:,inds_fvals);
    
    % Return pars:
    pars.fvals      = fvals(inds_use(1:num_comp));
    pars.inds_fvals = inds_fvals;
    pars.num_comp   = num_comp;
end


%% Fix dims:
if app_dim==1,      D.data = D.data';       end


%% User feedback:
if verbose
    if app_dim==2
        fprintf('\n Selected %d channels based on F-vals',length(inds_fvals));
    else
        fprintf('\n Selected %d samples based on F-vals',length(inds_fvals));
    end
    fprintf('\n between %g and %g\n',min(pars.fvals),max(pars.fvals));
end


%% For 'P'ars-struct
if exist('P','var')
    P.(mfilename) = pars;
end
