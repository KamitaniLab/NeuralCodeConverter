function [results, P] = crossValidate_run(D, P, procs, models)
% crossValidate_run - performs leave-'one_run'-out cross-validations tests of 'models'
% results = crossValidate_run(D, P, procs, models)
%
% Input:
%   D.data       - 2D matrix of any data ([time(sample) x space(voxel/channel)] format)
%   D.labels     - condition labels of each sample ([time x 1] format)
%   procs        - array of strings of the processing functions to be called;
%                  this may be any function that conforms with this format:
%                  [D, pars] = myFunc(D, pars);
%   models       - array of strings of the models functions to be called;
%                  this may be any function that conforms with this format:
%                  [results, pars] = myFunc(D, pars);
% Optional:
%   P.<function> - parameters of 'procs' and 'models'
%   P.corssValidate.res_train
%                - return training results also? 0-no, 1-yes, default=0
%   P.crossValidate_run.verbose
%                - [1..3] = print detail level; 0 = no printing (default=1)
% Output:
%	results      - cell array of 'results' structs returned by models, with fields:
%       .model       - names of used model
%       .preds       - predicted labels
%       .labels      - defined labels
%       .dec_vals    - decision values
%       .weights     - weights (and bias)
%       .freq_table  - frequency table
%       .correct_per - percent correct
%  P.<function>  - modified parameters of 'procs' and 'models'
%
% Calls:
%   procSwitch     - performs a list of processing
%   modelSwitch    - performs a list of models
%   resultsSummary - calculates fummary of results
%
% Created  By: Alex Harner (1),     alexh@atr.jp      06/07/04
% Modified By: Alex Harner (1),     alexh@atr.jp      06/10/17
% Modified By: Satoshi MURATA (1),  satoshi-m@atr.jp  09/04/17
% (1) ATR Intl. Computational Neuroscience Labs, Decoding Group


%% Check and get pars:
if exist('D','var')==0      || isempty(D),          return;         end
if exist('procs','var')==0  || isempty(procs),      procs = [];     end
if exist('models','var')==0 || isempty(models),     return;         end
if exist('P','var')==0      || isempty(P),          P = [];         end

pars        = getFieldDef(P,mfilename,[]);
res_train   = getFieldDef(pars,'res_train',0);
verbose     = getFieldDef(pars,'verbose',1);

num_run  = size(D.inds_runs,2);
inds_all = D.inds_runs(1):D.inds_runs(end);

% Put strings in cell array of strings
if ischar(procs)
    temp  = procs;
    procs = cell(size(temp,1),1);
    for itp=1:size(temp,1)
        procs{itp,1} = temp(1,:);
    end
end
if ischar(models)
    temp   = models;
    models = cell(size(temp,1),1);
    for itm=1:size(temp,1)
        models{itm,1} = temp(1,:);
    end
end


%% For UI:
if verbose
    fprintf(['\n' mfilename ' ------------------------------']);
    fprintf('\n %d fold cross validation',num_run);
    if isempty(procs)==0
        fprintf('\n processing:');
        for itp=1:length(procs)
            fprintf('\t%s',procs{itp});
        end
    end
    fprintf('\n models    :');
    for itm=1:length(models)
        fprintf('\t%s',models{itm});
    end
end


%% Main validation loop:
fprintf('\n run       :');
res_cells_te = cell(length(models),num_run);
res_cells_tr = cell(length(models),num_run);
for itd=1:num_run
    fprintf(' %d', itd);
    
    % Get training and test indexes:
    inds_te = D.inds_runs(1,itd):D.inds_runs(2,itd);
    inds_tr = setdiff(inds_all,inds_te);
    
    % Get training data and labels:
    D_tr.data   = D.data(inds_tr,:);
    D_tr.labels = D.labels(inds_tr);
    
    % Preprocessing for training data:
    P.procSwitch.mode = 1;
    [D_tr, P]         = procSwitch(D_tr,P,procs);
    
    % Training:
    P.modelSwitch.mode = 1;
    [res_tr, P]        = modelSwitch(D_tr,P,models);
    
    % Get test data and labels:
    D_te.data   = D.data(inds_te,:);
    D_te.labels = D.labels(inds_te);
    
    % Preprocessing for test data:
    P.procSwitch.mode = 2;
    [D_te, P]         = procSwitch(D_te,P,procs);
    
    %Test:
    P.modelSwitch.mode = 2;
    [res_te, P]        = modelSwitch(D_te,P,models);
    
    res_cells_tr(:,itd) = res_tr;
    res_cells_te(:,itd) = res_te;
end

fprintf('\n');


%% Results summary:
res_cells_te = resultsSummary(res_cells_te);


%% Return results:
if res_train
    results.train = res_cells_tr;
    results.test  = res_cells_te;
else
    results = res_cells_te;
end
