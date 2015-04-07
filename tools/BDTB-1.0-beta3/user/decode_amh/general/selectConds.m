function [D, pars] = selectConds(D, pars)
%selectConds - selects data corresponding to labels that match 'conds'
%[D, pars] = selectConds(D, pars)
%
% Selects data and labels corresponding to labels that match conditions
% in array 'conds'; also returns indices of selection in 'pars.indCond'.
%
% Input:
%   D.data       - 2D matrix
%   D.labels     - 1D array of labels whose length matches the sample length of data
%   pars.conds   - 1D array of conditions to be selected from labels
% Optional:
%   pars.verbose - [1..3] = print detail level; 0 = no printing (default=0)
% Output:
%   D.data       - data corresponding to matched labels
%   D.labels     - condition labels matching 'conds'
%
% Original  By: Yukiyasu Kamitani (1),  kmtn@atr.jp       03/12/20
% Rewritten By: Alex Harner (1),        alexh@atr.jp      06/07/05
% Modified  By: Alex Harner (1),        alexh@atr.jp      06/10/23
% Modified  By: Satoshi MURATA (1),     satoshi-m@atr.jp  08/09/30
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
conds   = getFieldDef(pars,'conds',[]);
verbose = getFieldDef(pars,'verbose',0);

if isempty(conds),      return;     end


%% For UI:
if verbose
    fprintf(['\n' mfilename ' ------------------------------']);
    fprintf('\n conds: %s\n', num2str(conds));
end


%% Find indexes of labels matching conds:
conds      = unique(conds);
inds_match = find(ismember(D.labels,conds));


%% Select data and labels with indexes:
D.labels = D.labels(inds_match);
D.data   = D.data(inds_match,:);


%% For 'P'ars-struct
if exist('P','var')
    P.(mfilename) = pars;
end
