function [results, P] = modelSwitch(D, P, models)
%modelSwitch - performs a list of models (classifcation/regression) on data
%[results, P] =  modelSwitch(D, P, models)
%
% Performs classifcation or regression listed in 'models' (in order) on
% 'data' with all parameters in 'P' (including weights) using 'labels'
% (if available); P.mode switches between train and test modes.
%
% Input:
%	D.data   - any data accepted by 'models' (below)
%	D.labels - labels matching samples of 'data'; don't use for test mode
%	P        - structure containing all parameters of 'models' as fields;
%              should be nested as P.<models> (e.g. P.ica_amh)
%	models   - array of strings of the modeling functions to be called;
%	           this may be any function listed below or any function
%	           in the user's path that conforms with this format:
%              [results, pars] = myClassifier(D, pars);
%
% Optional:
%   P.modelSwitch.mode
%            - 1: train, or 2: test; if specified, pass to all 'models'
%
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
% Created  By: Alex Harner (1),     alexh@atr.jp      06/07/05
% Modified By: Alex Harner (1),     alexh@atr.jp      06/11/17
% Modified By: Satoshi MURATA (1),  satoshi-m@atr.jp  08/10/01
% (1) ATR Intl. Computational Neuroscience Labs, Decoding Group


%% Check and get pars:
if exist('D','var')==0      || isempty(D),          return;     end
if exist('models','var')==0 || isempty(models),     return;     end
if exist('P','var')==0      || isempty(P),          P = [];     end

pars = getFieldDef(P,mfilename,[]);
mode = getFieldDef(pars,'mode',[]);

% Put strings in cell array of strings
if ischar(models)
    models = cellstr(models);
end


%% Loop through processing steps in models cell array:
results = cell(length(models),1);
for itm=1:length(models)
    model = models{itm};
    
    if exist(model,'file')==2
        pars                 = getFieldDef(P,model,[]);
        if isempty(mode)==0,    pars.mode = mode;       end
        [results{itm}, pars] = feval(model,D,pars);
        P.(model)            = pars;
    else
        fprintf('\n modelSwitch ERROR: did not find ''%s'', skipped!\n',model);
    end
end
