function [results, pars] = svm_multi_amh(D, pars)
%svm_multi_amh - performs multi SVM using multiclassSVM, either train or test
%[results, pars] = svmMulti_amh(D, pars)
%
% Input:
%   D.data    - 2D matrix of any data ([time(sample) x space(voxel/channel)] format)
%   D.labels  - condition labels of each sample ([time x 1] format)
%               use [1,2,...,class_num] is recommended
% Optional:
%   pars.model- SVM 'model', including weights; optional for training
%   pars.mode   - train=1 (make weights) or test=2 mode (use weights)
%   pars.verbose- [1..3] = print detail level; 0 = no printing (default=0)
% For SVM (svm_multi_*) options ('ops') see:
%	http://www.cs.cornell.edu/People/tj/svm%5Flight/svm_struct.html
% Output:
%   results - struct contain ANY result as a field, typically:
%       .model    - name of this function
%       .preds    - predicted labels
%       .labels   - defined labels
%       .weights  - weights and bias
%   pars    - modified pars, new weights will be added here
%
% Calls:
%   selectDir_gui          - outputs dialog-box to select directory with GUI
%   multiclassSVM, (c) >>>
%       svm_multi_classify - classifying data by learned parameters
%       svm_multi_learn    - learning parameters of multiclassSVM
%
% Created  By: Alex Harner (1),     alexh@atr.jp      06/07/30
% Modified By: Alex Harner (1),     alexh@atr.jp      06/09/08
% Modified By: Satoshi MURATA (1),  satoshi-m@atr.jp  08/10/02
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
model   = getFieldDef(pars,'model',[]);
mode    = getFieldDef(pars,'mode',1);
verbose = getFieldDef(pars,'verbose',0);
ops     = getFieldDef(pars,'ops',[]);

if     mode==1 && isempty(D.labels),    error('must have ''labels'' for train');
elseif mode==2 && isempty(model),       error('must have ''model'' for test');      end

if max(D.labels)~=length(unique(D.labels)) || isempty(find(D.labels==0,1))==0
    fprintf('\nWarning: unrecommended format of ''labels''');
    fprintf('\n rename ''labels'' in ''svm_multi''\n');
    
    [D.labels, labels_new, labels_old] = reIndex(D.labels);
end

%% Add path of MultiClassSVM (if needed):
str = which('svm_multi_learn');
if isempty(str)
    dirname = selectDir_gui(pwd,'Select ''multiclassSVM'' directory');
    if isempty(dirname),    error('Can''t find ''multiclassSVM''');     end
    addpath(dirname);
end


%% For UI:
if verbose
    fprintf(['\n' mfilename ' ------------------------------']);
    fprintf('\n mode:\t%d\n',mode);
end


%% SVM pars:
if verbose,     ops = [ops ' -v 2 -y 1'];
else            ops = [ops ' -v 0'];           end


%% Test mode:
if mode==2
    preds = svm_multi_classify(model,D.data,D.labels,ops);
    
    
%% Train mode:
else
    model = svm_multi_learn(D.data,D.labels,ops);               % train
    preds = svm_multi_classify(model,D.data,D.labels,ops);      % test
    
    pars.model = model;
end


%% Calc weights:
weights = sum(model.supvec .* repmat(model.supvec_label,1,size(model.supvec,2)));
weights = reshape(weights,model.num_features,model.num_classes);
weights = [weights; repmat(model.threshold,1,size(weights,2))];


%% Retrun results:
if exist('labels_old','var') && isempty(labels_old)==0
    D.labels = reIndex(D.labels,labels_old,labels_new);
    preds    = reIndex(preds,labels_old,labels_new);
end

results.model   = mfilename;
results.preds   = preds;
results.labels  = D.labels;
results.weights = weights;


%% For 'P'ars-struct
if exist('P','var')
    P.(mfilename) = pars;
end
