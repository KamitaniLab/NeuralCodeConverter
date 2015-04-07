function [results, pars] = lda_amh(D, pars)
%lda_amh - performs linear discriminant analysis (LDA), either train or test
%[results, pars] = lda_amh(D, pars)
%
% Inputs:
%	D.data    - D or 2D matrix of data of either format
%	D.labels  - labels matching samples of 'data'; only [] for test mode
%
% Optional:
%	pars.weights- weights for test mode; optional for training
%	pars.mode   - train=1 (make weights) or test=2 mode (use weights)
%	pars.verbose- [1..3] = print detail level; 0 = no printing (default=0)
%
% Outputs:
%	results - struct contain ANY result as a field, typically:
%       .mode   - name of this function
%       .pars   - parameters used (minus weights)
%		.decVals- decision values (raw classifier output)
%		.preds	- labels predicted by the models
%	pars    - modified pars, new weights will be added here
%
% Created  By: Alex Harner (1),     alexh@atr.jp      06/07/12
% Modified By: Alex Harner (1),     alexh@atr.jp      06/09/08
% Modified By: Satoshi MURATA (1),  satoshi-m@atr.jp  08/10/09
% (1) ATR Intl. Computational Neuroscience Labs, Decoding Group


%% Check and get pars:
if exist('D','var')==0    || isempty(D),        error('Wrong args');        end
if exist('pars','var')==0 || isempty(pars),     pars = [];                  end

pars    = getFieldDef(pars,mfilename,pars);    % unnest, if need
weights = getFieldDef(pars,'weights',[]);
mode    = getFieldDef(pars,'mode',1);
verbose = getFieldDef(pars,'verbose',0);

if     mode==1 && isempty(D.labels),    error('must have ''labels'' for train');
elseif mode==2 && isempty(weights),     error('must have ''weights'' for test');    end


%% For UI:
if verbose
    fprintf(['\n' mfilename ' ------------------------------']);
    fprintf('\n mode:\t%d\n',mode);
end


%% Test mode:
if mode==2
    dec_vals = D.data * weights(1:end-1,:);
    preds    = predsFromDecVals(dec_vals,unique(D.labels));


%% Train mode:
else
    [preds, weights] = classify_yk(D.data,D.data,D.labels);
    dec_vals         = D.data * weights(1:end-1,:);
    
    pars.weights = weights;
end


%% Return results:
results.model    = mfilename;
results.dec_vals = dec_vals;
results.weights  = weights;
results.labels   = D.labels;
results.preds    = preds;
