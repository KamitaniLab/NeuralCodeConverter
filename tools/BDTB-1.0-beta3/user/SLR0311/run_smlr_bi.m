function [ww, ix_eff_all, errTable_tr, errTable_te, parm, AXall,Ptr,Pte] =...
    run_smlr_bi(x_train, t_train, x_test, t_test, varargin)
% Run sparse multinomial logistic regression using combinations of binary
% classifier
% 
% -- Usage
% [ww, ix_eff_all, errTable_tr, errTable_te, parm, AXall, Ptr, Pte] =
% run_smlr_bi(x_train, t_train, x_test, t_test, varargin)
%
% --- Input
% x_train :   [Nsamp_tr , Nfeat] 
% t_train :   [Nsamp_tr , 1]
% x_test  :   [Nsamp_te , Nfeat]
% t_test  :   [Nsamp_te , Nfeat]
%
% --- Optional Input
% parm = finputcheck(varargin, ...
%     {'scale_mode', 'string', {'all','each','none'}, 'all';...
%      'mean_mode',  'string', {'all','each','none'}, 'all';...
%      'ax0',        'real',     [],  [];...
%      'nlearn',     'integer',  [1 inf],  1000;...
%      'nstep',      'integer',  [1 inf],  100;...
%      'amax',       'real',     [0 inf],  1e8;...
%      'wmaxiter',   'integer',  [1 inf],  50;...
%      'wdisp_mode', 'string',   {'iter', 'off', 'final', 'notify'}, 'iter';...
%      'usebias',    'boolean',  []     , 1;...
%      'norm_sep'  , 'boolean',  []     , 0;... 
%      %'isplot'    , 'boolean' , []     , 0;...
%      'reduceparm', 'boolean',  []     , 0;...
%      'nprobe',     'integer',  [0 inf], 0;...
%      'displaytext',   'boolean',  []     , 1;... 
%      });
%
% --- Output
% ww          :   Estimated weight parameters. [Nfeat, Nclass]
% ix_eff_all  :   Index of features survived. cell array of {Nclass}
% errTable_tr :   Counting table of each label estimated. [Nclass, Nclass]
% errTbale_te :   Counting table of each label estimated. [Nclass, Nclass]
% parm        :   Parmaters used in this routine. [struct]
% AXall       :   History of hyperparameters updating. [Nfeat*Nclass Nlearn]
% Ptr         :   Probaility of observing every label in training data. [Nsamp_tr Nclass]
%                 This value is used to put a label on each sample.
% Pte         :   Probaility of observing every label in training data. [Nsamp_te Nclass]
%                 This value is used to put a label on each sample.
%
% 2006/10/23 OY
% * 'Nclass' is removed from inputs.
% 2006/09/11 OY
% * Add probe vectors 
% 2006/09/07 OY 
% * Output format is modified
% 2006/05/26 OY
% 2006/05/15 OY

if nargin < 4
    help run_smlr_bi;
    return
end

% char label -> number 
[t_train, label_names, Nclass] = label2num(t_train);
[t_test] = label2num(t_test);

[Nsamp_tr, Nfeat] = size(x_train);
Nsamp_te = size(x_test,1);

%% input check for optional parameter.
parm = finputcheck(varargin, ...
    {'scale_mode', 'string', {'all','each','none'}, 'all';...
     'mean_mode',  'string', {'all','each','none'}, 'all';...
     'ax0',        'real',     [],  [];...
     'nlearn',     'integer',  [1 inf],  1000;...
     'nstep',      'integer',  [1 inf],  100;...
     'amax',       'real',     [0 inf],  1e8;...
     'wmaxiter',   'integer',  [1 inf],  50;...
     'wdisp_mode', 'string',   {'iter', 'off', 'final', 'notify'}, 'iter';...
     'usebias',    'boolean',  []     , 1;...
     'norm_sep'  , 'boolean',  []     , 0;... 
     %'isplot'    , 'boolean' , []     , 0;...
     'reduceparm', 'boolean',  []     , 0;...
     'nprobe',     'integer',  [0 inf], 0;...
     'displaytext',   'boolean',  []     , 1;... 
     });
 
 if ~isstruct(parm)
   error(parm);
end
     
% reduce class for economical parametrization
if Nclass == 2
   parm.reduceparm = 1;
end
  
AMAX   = parm.amax;
ax0    = parm.ax0;
Nlearn = parm.nlearn;
Nstep  = parm.nstep;
wdisp_mode = parm.wdisp_mode;
wmaxiter = parm.wmaxiter;
usebias  = parm.usebias;
norm_sep = parm.norm_sep;
Nprobe   = parm.nprobe;
reduceparm = parm.reduceparm;
displaytext= parm.displaytext;

% add bias
if usebias == 1
    Nfeat = Nfeat+1;
end
% # of features
Nfeat = Nfeat + Nprobe;
% # of parameters
if reduceparm
    Nparm = (Nclass-1)*Nfeat;
else
    Nparm = Nclass*Nfeat;
end
% 
if isempty(ax0)
    ax0 = ones(Nparm,1);
    parm.ax0 = ax0;
end

parm.nclass = Nclass;
parm.nparm = Nparm;
parm.nsamp_tr = Nsamp_tr;
parm.nsamp_te = Nsamp_te;
parm.nfeat    = Nfeat;
parm.nprobe   = Nprobe;

% normalize (sacling and baseline addjustment)
if norm_sep == 0
    [x_train, scale, base] = normalize_feature(x_train, parm.scale_mode, parm.mean_mode);
    [x_test, scale, base] = normalize_feature(x_test, parm.scale_mode, parm.mean_mode, scale, base);
else
    [x_train, scale, base] = normalize_feature(x_train, parm.scale_mode, parm.mean_mode);
    [x_test, scale, base] = normalize_feature(x_test, parm.scale_mode, parm.mean_mode);
end

% add a regressor for bias term
if usebias
    Xtr = [x_train, ones(Nsamp_tr,1)];
    Xte = [x_test, ones(Nsamp_te,1)];
else
    Xtr = [x_train];
    Xte = [x_test];
end

% add probe vectors
if Nprobe > 0
    Xtr = [Xtr randn(Nsamp_tr, Nprobe)];
    Xte = [Xte randn(Nsamp_te, Nprobe)];
end

%---------------------
% 1 vs all other 
%---------------------
AXtmp = [];
for c = 1 : Nclass

    if displaytext,fprintf('\n Learning parameters for class %d .... \n', c); end

    if c == Nclass & reduceparm
        if displaytext, fprintf(' All parameters fixed to zeros...\n'); end
        ww(:,c) = zeros(Nfeat,1);
        ix_eff_all{c} = '';
    else

        label = zeros(Nsamp_tr, 1);
        ix = find(t_train == c);
        label(ix) = 1;   % 1 for class c, 0 otherwise

        [w_e, ix_eff, W, AX] = slr_learning(label, Xtr, @linfun,...
            'reweight', 'OFF', 'nlearn', Nlearn, 'nstep', Nstep, 'wdisplay', wdisp_mode, 'amax', AMAX);

        ix_eff_all{c} = ix_eff;
        ww(:, c) = w_e;

        
        AXtmp = [AXtmp;AX];
    end
end
AXall = [ax0, AXtmp];

%-----------------------
% Training Correct
%-----------------------
[t_train_est, Ptr] = calc_label(Xtr, ww);

%-----------------------
% Test
%----------------------
[t_test_est, Pte] = calc_label(Xte, ww);

% remove baseline parameters from effective index
for c = 1 : Nclass
    ix_tmp = ix_eff_all{c};
    if isempty(ix_tmp)
        ix_eff_all{c} = [];
    elseif ix_tmp(end) == Nfeat,       % last index == index of baseline
        ix_tmp2 = ix_tmp(1:end-1); % remove last index
        ix_eff_all{c} = ix_tmp2;
    end
end

errTable_tr = slr_error_table(t_train, t_train_est);
errTable_te = slr_error_table(t_test, t_test_est);

Pcorrect_tr = calc_percor(errTable_tr);
Pcorrect_te = calc_percor(errTable_te);

if displaytext,
fprintf(' Training Correct : %2.2f %%,  Test Correct : %2.2f %%\n', Pcorrect_tr, Pcorrect_te);
end