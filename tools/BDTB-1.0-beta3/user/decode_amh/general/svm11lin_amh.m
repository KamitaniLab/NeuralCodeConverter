function [results, pars] = svm11lin_amh(D, pars)
%svm11lin_amh - SVM one-against-one, linear combination, either train or test
%[results, pars] = svm11lin_amh(D, pars)
%
% Input:
%   D.data        - 2D matrix of any data ([time(sample) x space(voxel/channel)] format)
%   D.labels      - condition labels of each sample ([time x 1] format)
% Optional:
%   pars.weights  - weights for test mode; optional for training
%   pars.mode     - train=1 (make weights) or test=2 mode (use weights)
%   pars.num_boot - number of bootstrap samples
%                   0: no botstrapping, <0: use '-num_boot*length(labels)'
%   pars.verbose  - [1..3] = print detail level; 0 = no printing (default=0)
% Output:
%   results       - struct contain ANY result as a field, typically:
%       .model    - name of this function
%       .preds    - predicted labels
%       .labels   - defined labels
%       .dec_vals - decision values
%       .weights  - weights and bias
%   pars          - modified pars, new weights will be added here
%
% Calls:
%   selectDir_gui - outputs dialog-box to select directory with GUI
%   svm11linTrain - calculates weights by 'OSU SVM'
%
% Created  By: Alex Harner (1),     alexh@atr.jp      06/07/21
% Modified By: Alex Harner (1),     alexh@atr.jp      06/09/08
% Modified By: Satoshi MURATA (1),  satoshi-m@atr.jp  08/10/01
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
weights  = getFieldDef(pars,'weights',[]);
mode     = getFieldDef(pars,'mode',1);
num_boot = getFieldDef(pars,'num_boot',0);
verbose  = getFieldDef(pars,'verbose',0);

if     mode==1 && isempty(D.labels),    error('must have ''labels'' for train');
elseif mode==2 && isempty(weights),     error('must have ''weights'' for test');         end


%% Add path of OSU SVM (if needed):
str = which('PolySVC');
if isempty(str)
    dirname = selectDir_gui(pwd,'Select OSU SVM directory');
    if isempty(dirname),    error('Can''t find OSU SVM');   end
    addpath(dirname);
end


%% For UI:
if verbose
    fprintf(['\n' mfilename ' ------------------------------']);
    fprintf('\n mode    :\t%d\n',mode);
    if num_boot~=0,     fprintf(' num_boot:\t%d\n',num_boot);       end
end


%% Test mode:
if mode==2
    dec_vals = D.data * weights(1:end-1,:);


%% Train mode (normal):
elseif num_boot==0
    weights  = svm11linTrain(D.data,D.labels);
    dec_vals = D.data * weights(1:end-1,:);
    
    pars.weights = weights;


%% Train mode (Bootstrapping):
else
    if num_boot<0,      num_boot_samps = -num_boot*length(D.labels);
    else                num_boot_samps = num_boot;                          end
    
    boot_weights = bootstrp(num_boot_samps,'svm11linTrain',D.data,D.labels);
    weights      = reshape(mean(boot_weights(1:num_boot_samps,:),1),[],length(unique(D.labels)));
    dec_vals     = D.data * weights(1:end-1,:);
    
    pars.weights = weights;
end


%% Return results:
results.model    = mfilename;
results.dec_vals = dec_vals;
results.weights  = weights;
results.labels   = D.labels;
results.preds    = predsFromDecVals(dec_vals,unique(D.labels));


%% For 'P'ars-struct
if exist('P','var')
    P.(mfilename) = pars;
end
