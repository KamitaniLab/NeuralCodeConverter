function [results, pars] = libsvm_amh(D, pars)
%libsvm_amh - performs multi SVM using libsvm-mat, either train or test
%[results, pars] = libsvm_amh(D, pars)
%
% Inputs:
%	D.data    - 2D matrix of data
%	D.labels  - labels matching samples of 'data'; only [] for test mode
%
% Optional:
%	pars.model- SVM 'model', including weights; optional for training
%	pars.mode   - train=1 (make weights) or test=2 mode (use weights)
%	pars.verbose- [1..3] = print detail level; 0 = no printing (default=0)
%
%
%
%
% LibSVM pars fields:
%	.kernel - 0=linear, 1=poly, 2=rbf, 3=sigmoid; default=0
%	.cost   - C of C-SVC, epsilon-SVR, and nu-SVR; default=1
%	.gamma  - set gamma in kernel function; default 1/k
%	.coef   - set coef0 in kernel function; default=0
%	.degree - set degree in kernel function; default=3
%	.prob   - output probabilities as decVals? 0-no, 1-yes; default=1
%
% Outputs:
%	results - struct contain ANY result as a field, typically:
%       .mode   - name of this function
%       .pars   - parameters used (minus weights)
%		.decVals- decision values (raw classifier output)
%		.preds	- labels predicted by the models
%	pars    - modified pars, new weights will be added here
%
% Note: modelSwitch will make the remaining fields of results.
%
% Example:
%	>> % dataTrain, dataTest - [nSigs x nSamples]
%	>> pars.verbose = 0;	% to avoid printing (new)
%	>> % 1 - train mode:
%	>> [weights, results, pars] = libsvm_amh(dataTrain, pars, labelsTrain, 1);
%	>> % 2 - test  mode:
%	>> [weights, results, pars] = libsvm_amh(dataTest, pars, labelsTest, 2);
%
% Calls: svmtrain, svmpredict (help svmtrain for more info)
% Requires: libsvm-mat-2.82, (c) 2000-2005 Chih-Chung Chang & Chih-Jen Lin
% Info: http://www.csie.ntu.edu.tw/~cjlin/libsvm
% Status: basic testing
%
% Created  By: Alex Harner (1),     alexh@atr.jp      06/07/25
% Modified By: Alex Harner (1),     alexh@atr.jp      06/09/15
% Modified By: Satoshi MURATA (1),  satoshi-m@atr.jp  08/10/07
% (1) ATR Intl. Computational Neuroscience Labs, Decoding Group


%% Check and get pars:
if exist('D','var')==0    || isempty(D),        error('Wrong args');        end
if exist('pars','var')==0 || isempty(pars),     pars = [];                  end

pars    = getFieldDef(pars,mfilename,pars);    % unnest, if need
model   = getFieldDef(pars,'model',[]);
mode    = getFieldDef(pars,'mode',1);
verbose = getFieldDef(pars,'verbose',0);

if     mode==1 && isempty(D.labels),    error('must have ''labels'' for train');
elseif mode==2 && isempty(model),       error('must have ''model'' for test');      end


%% Add path of libsvm-mat (if needed):
str = which('svmpredict');
if isempty(str)
    dirname = selectDir_gui(pwd,'Select ''libsvm-mat'' directory');
    if isempty(dirname),    error('Can''t find ''libsvm-mat''');    end
    addpath(dirname);
end


%% SVM pars:
kernel = getFieldDef(pars,'kernel',0);      % linear
gamma  = getFieldDef(pars,'gamma',0);       % NOTE: gamma=0 defaults to 1/k
prob   = getFieldDef(pars,'prob',1);
cost   = getFieldDef(pars,'cost',1);
coef   = getFieldDef(pars,'coef',0);
degree = getFieldDef(pars,'degree',3);

ops1 = sprintf('-t %d -c %g -r %g -d %g', kernel, cost, coef, degree);
if prob,        ops1 = [ops1 ' -b 1'];   ops2 = '-b 1';     end
if gamma,       ops1 = [ops1 ' -g ' num2str(gamma)];        end
if verbose==0,  ops2 = [ops2 ' -o 0'];                      end     % amh hacked


%% For UI:
if verbose
    fprintf(['\n' mfilename ' ------------------------------']);
    fprintf('\n mode:  \t%d\n',mode);
    if verbose>=2
        kernel_str = {'0-linear','1-poly','2-rbf','3-sigmoid'};
        fprintf('\n kernel:\t%s',kernel_str{kernel+1});
        fprintf('\n cost:  \t%g',cost);
        fprintf('\n coef:  \t%g',coef);
        fprintf('\n degree:\t%g',degree);
        if prob,    fprintf('\n prob:  \t%d',prob);       end
        if gamma,   fprintf('\n gamma: \t%g',gamma);
        else        fprintf('\n gamma: \t1/k');          end
    end
end


%% Test mode:
if mode==2
    [preds, nouse, dec_vals] = svmpredict(D.labels,D.data,model,ops2);
    
    
%% Train mode:
else
    model                    = svmtrain(D.labels,D.data,ops1);
    [preds, nouse, dec_vals] = svmpredict(D.labels,D.data,model,ops2);
    
    pars.model = model;
end


%% Return results:
results.model    = mfilename;
results.preds    = preds;
results.labels   = D.labels;
results.dec_vals = dec_vals;

results.weights  = model.SVs' * model.sv_coef;
