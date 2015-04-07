function [ww, ix_eff_all, errTable_tr, errTable_te, parm, AXall, Ptr, Pte] =...
    run_smlr(x_train, t_train, x_test, t_test, varargin)
% Run sparse multinomial logistic regression.
% 
% Normalization, parameter estimation, and performance evaluation are executed.
%
% -- Usage
% [ww, ix_eff_all, errTable_Tr, errTable_te, parm, AXall, Ptr, Pte] =...
%   run_smlr(x_train, t_train, x_test, t_test,  varargin)
%
% --- Input
% x_train :   [Nsamp_tr , Nfeat] 
% t_train :   [Nsamp_tr , 1]
% x_test  :   [Nsamp_te , Nfeat]
% t_test  :   [Nsamp_te , Nfeat]
%
% --- Optional Input
% parm = finputcheck(varargin, ...
%     {'scale_mode', 'string'  , {'all','each','none'}, 'all';...
%      'mean_mode' , 'string'  , {'all','each','none'}, 'all';...
%      'ax0'       , 'real'    , []                   ,  [];...
%      'nlearn'    , 'integer' , [1 inf]              ,  1000;...
%      'nstep'     , 'integer' , [1 inf]              ,  100;...
%      'amax'      , 'real'    , [0 inf]              ,  1e8;...
%      'wmaxiter'  , 'integer' , [1 inf]              ,  50;...
%      'wdisp_mode', 'string'  , {'iter', 'off', 'final', 'notify'}, 'iter';...
%      'isplot'    , 'boolean' , []                   ,  0;...
%      'usebias'   , 'boolean' , []                   ,  1;...
%      'norm_sep'  , 'boolean' , []                   ,  0;... 
%      'nprobe',     'integer' , [0 inf]              ,  0;...
%      'displaytext','boolean' ,  []                  ,  1;...
%     });
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
% 2006/09/12 OY
%  * A field "nprobe" is introduced.
% 2006/09/06 OY  
%  * Output format modified (error table as output)
%  * Comment modified
% 2006/08/02 OY
% 2006/05/26 OY

if nargin < 4
    help run_smlr;
    return
end

% char label -> number 
[t_train, label_names, Nclass] = label2num(t_train);
[t_test] = label2num(t_test);

[Nsamp_tr, Nfeat] = size(x_train);
Nsamp_te = size(x_test,1);

%% input check for optional parameter.
parm = finputcheck(varargin, ...
    {'scale_mode', 'string'  , {'all','each','none'}, 'all';...
     'mean_mode' , 'string'  , {'all','each','none'}, 'all';...
     'ax0'       , 'real'    , []                   ,  [];...
     'nlearn'    , 'integer' , [1 inf]              ,  1000;...
     'nstep'     , 'integer' , [1 inf]              ,  100;...
     'amax'      , 'real'    , [0 inf]              ,  1e8;...
     'wmaxiter'  , 'integer' , [1 inf]              ,  50;...
     'wdisp_mode', 'string'  , {'iter', 'off', 'final', 'notify'}, 'iter';...
     'isplot'    , 'boolean' , []                   ,  0;...
     'usebias'   , 'boolean' , []                   ,  1;...
     'norm_sep'  , 'boolean' , []                   ,  0;... 
     'nprobe',     'integer' , [0 inf]              ,  0;...
     'displaytext','boolean' ,  []                  ,  1;...
    });

if ~isstruct(parm)
   error(parm);
end

AMAX = parm.amax;
ax0 = parm.ax0; 
Nlearn = parm.nlearn;
Nstep = parm.nstep;
wdisp_mode = parm.wdisp_mode;
wmaxiter = parm.wmaxiter;
isplot   = parm.isplot;  
usebias  = parm.usebias;
norm_sep = parm.norm_sep;
Nprobe   = parm.nprobe;
displaytext   = parm.displaytext;

% add a regressor for bias 
if usebias == 1
    Nfeat = Nfeat+1;
end
Nfeat = Nfeat + Nprobe;
Nparm = Nclass*Nfeat;

% set ax0 
if isempty(ax0),
    ax0 = ones(Nparm,1);
end
parm.ax0 = ax0;

% keep constant parameters
parm.nclass = Nclass;
parm.nparm = Nparm;
parm.nsamp_tr = Nsamp_tr;
parm.nsamp_te = Nsamp_te;
parm.nfeat    = Nfeat

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
% VB
%---------------------
w = zeros(Nparm,1);
ax = ax0;
ix_eff = [1:Nparm]';
AXall = ax0;

for n = 1 : Nlearn
    
    ax_eff = ax(ix_eff);
    w0_eff = w(ix_eff);

    [ixf, ixc] = ind2sub([Nfeat, Nclass], ix_eff);

    %%% W-step

    option = optimset('Gradobj','on','Hessian','on', 'Display', wdisp_mode);
    [w_eff,f,eflag,output,grad,H]=fminunc(@linfunmlr, w0_eff, option,...
        t_train, ax_eff, Xtr, ix_eff, ixf, ixc, Nclass);

    iax_eff = 1./ax_eff;
    dS_eff = inv(H); % #parm*1
    %% A-step
    ax_eff = (1-ax_eff.* diag(dS_eff))./(w_eff.^2);

    %% Prune ineffective parameters
    w = zeros(Nparm,1);
    w(ix_eff) = w_eff;
    ax(ix_eff) = ax_eff;
    ix_eff = find(ax < AMAX);
    
    if mod(n, Nstep) == 0
        fprintf('Iterations : %d, Feature Remained: %d \n', n, length(ix_eff));
        AXall(:,n/Nstep) = ax;
        if isplot   % plot hyperparameters updating
            semilogy(ax+1);
            hold on
            semilogy(AMAX*ones(Nparm,1), 'r:', 'linewidth', 5)
            hold off
            title(['Iteration ', num2str(n), '  Feature ', num2str(length(ix_eff))]);
            pause(0.1);
        end
    end
end

%-----------------------
% Count correct
%-----------------------
ww = reshape(w, [Nfeat, Nclass]);
[tmp, t_train_est] = max(Xtr*ww,[],2);

eYtr = exp(Xtr*ww); % Nsamp_tr*Nclass
Ptr = eYtr ./ repmat(sum(eYtr,2), [1, Nclass]); % Nsamp_tr*Nclass

%-----------------------
% Test
%----------------------
[tmp, t_test_est] = max(Xte*ww,[],2);

eYte = exp(Xte*ww); % Nsamp_te*Nclass
Pte = eYte ./ repmat(sum(eYte,2), [1, Nclass]); % Nsamp_te*Nclass

[ixf, ixc] = ind2sub([Nfeat, Nclass], ix_eff);
for c = 1 : Nclass
    tmp = find(ixc == c);   % restricted to class c
    ixf_tmp = ixf(tmp);      % feature indices of class c
    if isempty(ixf_tmp)
        ix_eff_all{c} = [];
    elseif ixf_tmp(end) == Nfeat,         % last index == index of baseline
        ixf_tmp2 = ixf_tmp(1:end-1);  % remove last index
        ix_eff_all{c} = ixf_tmp2;
        else
        ix_eff_all{c} = ixf_tmp;
    end
end

errTable_tr = slr_error_table(t_train, t_train_est);
errTable_te = slr_error_table(t_test, t_test_est);

Pcorrect_tr = calc_percor(errTable_tr);
Pcorrect_te = calc_percor(errTable_te);

if displaytext,
fprintf(' Training Correct : %2.2f %%,  Test Correct : %2.2f %%\n', Pcorrect_tr, Pcorrect_te);
end
