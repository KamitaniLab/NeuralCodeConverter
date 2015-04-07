function [results, pars] = slr_sm(D, pars)
%slr_sm - performs multinomial SLR using SLR0.311, either train or test
%[results, pars] = slr_sm(D, pars)
%
% Input:
%   D,data        - 2D matrix of any data ([time(sample) x space(voxel/channel)] format)
%   D.labels      - condition labels of each sample ([time x 1] format); only [] for test mode
% Optional:
%   pars.conds    - conditions to be tested (should be 2 for binomial)
%   pars.mode     - train=1 (make weights) or test=2 mode (use weights)
%   pars.verbose  - [1..3] = print detail level; 0 = no printing (default=0)
% SLR pars:
%   .R            - SLR Gaussian kernel width; 0 = linear version (default)
% SLR pars for test:
%   .weights      - SLR weights; for linear, length of chans (mostly zeros)
%   .ix_eff       - index of non-zero weights; for linear, chans used	
%   .xcenter      - center of kernels (in original space?)
%   .parm         - struct of parameter in learning
% SLR pars for train:
%   .nlearn       - # of learning
%   .ax0          - Initial value of relevance parameter ax
%   .amax         - Truncation criteria. Parameters whose relevance parameter is larger 
%                   than this value are eliminated from further iterations
% Output:
%   results - struct contain ANY result as a field, typically:
%       .model    - name of this function
%       .preds    - predicted labels
%       .labels   - defined labels
%       .dec_vals - decision values
%       .weights  - weights and bias
%	pars          - modified pars, new weights will be added here
%
% Calls:
%   selectDir_gui         - outputs dialog-box to select directory with GUI
%   SLR0.311, (c) >>>
%       slr_make_kernel   - make explanatory matrix consisting of Gaussian kernel
%       slr_learning      - learning parameters of ARD-sparse logistic regression model
%       slr_count_correct - count the number of correct label
%       smlr_test         - predict using sparse multinomial logistic regression
%       smlr_learn        - run sparse multinomial logistic regression
%
% Created   By: Alex Harner (1),	  alexh@atr.jp      06/10/23
% Modified  By: Alex Harner (1),	  alexh@atr.jp      06/10/30
% With help of: Okito Yamashita (1),  oyamashi@atr.jp
% Modified  By: Hajime Uchida (1),    hajime-u@atr.jp   06/11/20
% Modified  By: Hajime Uchida (1),    hajime-u@atr.jp   06/12/26
% Modified  By: Satoshi MURATA (1),   satoshi-m@atr.jp  08/10/10
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
%%%%%%%%%%% modified by KY %%%%%%%%%%%%%
if pars.mode == 2
    conds   = pars.conds_ky;
else
    conds   = getFieldDef(pars,'conds',unique(D.labels));
    pars.conds_ky = conds;
end
%%%%%%%%%%% modified by KY %%%%%%%%%%%%%
mode    = getFieldDef(pars,'mode',1);
verbose = getFieldDef(pars,'verbose',0);

num_class = length(conds);

% SLR pars:
% binomial only
if num_class==2
    R       = getFieldDef(pars,'R',0);      % Gaussian width parameter
    xcenter = getFieldDef(pars,'xcenter',[]);
% multinomial only
else
    parm    = getFieldDef(pars,'parm',[]);
    nlearn  = getFieldDef(pars,'nlearn',150);
    ax0     = getFieldDef(pars,'ax0',[]);
    amax    = getFieldDef(pars,'amax',1e8);
end
weights = getFieldDef(pars,'weights',[]);
ix_eff  = getFieldDef(pars,'ix_eff',[]);

if     mode==1 && isempty(D.labels),    error('must have ''labels'' for train');
elseif mode==2 && isempty(weights),     error('must have ''weights'' for test');      end


%% Add path of SLR (if needed):
str = which('slr_learning');
if isempty(str)
    dirname = selectDir_gui(pwd,'Select ''SLR'' directory');
    if isempty(dirname),    error('Can''t find ''SLR''');     end
    addpath(dirname);
end


%% For UI:
if verbose
    fprintf(['\n' mfilename ' ------------------------------']);
    fprintf('\n mode:    \t%-4d',mode);
    if verbose>=2
        fprintf('\n conds:   \t[%s]',conds);
        fprintf('\n # ix_eff:\t%-4d',length(ix_eff));
        if num_class==2
            fprintf('\n R    :   \t%-4d',R);
        end
    end
    fprintf('\n');
end


%% Fix data input for SLR:
[labels, conds2] = reIndex(D.labels,[],conds);
if num_class==2     % binomial
    labels = labels - 1;    % re-indexes to 0,1,...
    conds2 = [0 1];
end
inds        = ismember(labels,conds2);
labels2     = labels(inds);
data2       = D.data(inds,:);
num_samples = length(labels2);


%% Test mode:
if mode==2
    % binomial
    if num_class==2
        if R>0,     Phi = slr_make_kernel(data2,R,xcenter);
        else        Phi = data2;                                end
        Phi = [Phi ones(num_samples,1)];
    
        if isempty(ix_eff)
            szl         = size(labels2);
            num_correct = 0;
            preds       = zeros(szl);
            dec_vals    = zeros(szl);
        else
            if size(weights,1)>size(Phi,2),     weights = weights(ix_eff);      end
            [num_correct, preds, dec_vals] = slr_count_correct(labels2,Phi,weights);
        end
    
    % multinomial
    else
        [preds, dec_vals] = smlr_test(weights,data2,labels2,num_class,parm);
        num_correct       = sum(preds==labels2);
    end

    accur = num_correct / num_samples * 100;
    if verbose,     fprintf(' Answer correct in test: %g%%\n',accur);       end


%% Train mode:
else
    % binomial
    if num_class==2
        if R>0,     Phi = slr_make_kernel(data2,R);
        else        Phi = data2;                        end
        Phi = [Phi ones(num_samples,1)];
        
        [weights, ix_eff] = slr_learning(labels2,Phi,@linfun,'reweight','OFF','wdisplay','off');
        
        if isempty(ix_eff)
            szl         = size(labels2);
            num_correct = 0;
            preds       = zeros(szl);
            dec_vals    = zeros(szl);
        else
            [num_correct, preds, dec_vals] = slr_count_correct(labels2,Phi,weights);
        end
        
        pars.weights = weights;
        pars.ix_eff  = ix_eff;
        if R>0,     pars.xcenter = data2(ix_eff(1:end-1),:);    end
    
    % multinomial
    else
        if verbose,     verbose_str = 'on';
        else            verbose_str = 'off';        end
        
        [weights, ix_eff, nouse, parm, nouse, preds, dec_vals] = ...
                smlr_learn(data2,labels2,num_class,'nlearn',nlearn,'ax0',ax0,'amax',amax,'wdisp_mode','off','verbose',verbose_str);
        
        num_correct = sum(preds==labels2);
        
        pars.parm    = parm;
        pars.weights = weights;
        pars.ix_eff  = ix_eff;
    end

    accur = num_correct / num_samples * 100;
    if verbose,     fprintf(' Answer correct in train: %g%%\n',accur);      end
end


%% Return results:
results.model    = mfilename;
results.labels   = D.labels;
results.weights  = weights;
results.dec_vals = dec_vals;

if num_class==2,    results.preds = conds(preds+1);
else                results.preds = conds(preds);       end


%% For 'P'ars-struct
if exist('P','var')
    P.(mfilename) = pars;
end
