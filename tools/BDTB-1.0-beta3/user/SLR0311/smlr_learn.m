function [ww, ix_eff_all, errTable_tr, parm, AXall, label_est_tr, Ptr] =...
    smlr_learn(x_train, t_train, Nclass, varargin)
% Run sparse multinomial logistic regression.
% 
% Noramlization, parameter estimation, and performance evaluation are executed.
%
% -- Usage
% [ww, ix_eff_all, errTable_Tr, errTable_te, parm, AXall] =...
%   run_smlr(x_train, t_train, Nclass, varargin)
%
% --- Input
% x_train :   [Nsamp , Nfeat] 
% t_train :   [Nsamp , 1]
% Nclass  :   [scalar]
%
% --- Optional Input
%     {'scale_mode', 'string'  , {'all','each','none'}, 'all';...
%      'mean_mode' , 'string'  , {'all','each','none'}, 'all';...
%      'ax0'       , 'real'    , []                   ,  ones(Nparm,1);...
%      'nlearn'    , 'integer' , [1 inf]              ,  1000;...
%      'nstep'     , 'integer' , [1 inf]              ,  100;...
%      'amax'      , 'real'    , [0 inf]              ,  1e8;...
%      'wmaxiter'  , 'integer' , [1 inf]              ,  50;...
%      'wdisp_mode', 'string'  , {'iter', 'off', 'final', 'notify'}, 'iter';...
%      'isplot'    , 'boolean' , []                   ,  0;...
%      'usebias'   , 'boolean' , []                   ,  1;...
%      'separate_normalize'    , 'boolean',  []       ,  0;... 
%      'verbose'   , 'string'  , {'on','off'}         , 'on';...
%     })
%
% --- Output
% ww          :   [Nfeat, Nclass]
% ix_eff_all  :   cell array of {Nclass}
% errTable_tr :   [Nclass, Nclass]
% parm        :   parmaters used in this routine [struct]
% AXall       :   history of hyperparameters updating [Nfeat*Nclass Nlearn]
%
%
% 2008/10/10 SM
%  * Modified for MATLAB warning
% 2007/06/18 HU
%  * Fix error when no-feature remained.
% 2006/12/26 HU
%  * Separate learning and testing.
% 2006/09/06 OY  
%  * Output format modified (error table as output)
%  * Comment modified
% 2006/08/02 OY
% 2006/05/26 OY

if nargin < 3
    help run_smlr;
    return
end

[Nsamp, Nfeat] = size(x_train);


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
     'verbose'   , 'string'  , {'on','off'}         , 'on';...
    });

AMAX       = parm.amax;
ax0        = parm.ax0; 
Nlearn     = parm.nlearn;
Nstep      = parm.nstep;
wdisp_mode = parm.wdisp_mode;
%wmaxiter   = parm.wmaxiter;
isplot     = parm.isplot;  
usebias    = parm.usebias;
norm_sep   = parm.norm_sep;
verbose    = parm.verbose;

% add a regressor for bias 
if usebias == 1
    Nfeat = Nfeat+1;
end
Nparm = Nclass*Nfeat;

% set ax0 
if isempty(ax0),
    ax0 = ones(Nparm,1);
end
parm.ax0 = ax0;

% keep constant parameters
parm.nclass   = Nclass;
parm.nparm    = Nparm;
parm.nsamp_tr = Nsamp;
parm.nfeat    = Nfeat;


% normalize (sacling and baseline addjustment)
if norm_sep == 0
    [x_train, scale, base] = normalize_feature(x_train, parm.scale_mode, parm.mean_mode);
else
    [x_train, scale, base] = normalize_feature(x_train, parm.scale_mode, parm.mean_mode);
end


% save normalize parameters. added by uchi
parm.scale = scale;
parm.base  = base;

% add a regressor for bias term
if usebias
    Xtr = [x_train, ones(Nsamp,1)];
else
    Xtr = x_train;
end

%---------------------
% VB
%---------------------
w      = zeros(Nparm,1);
ax     = ax0;
ix_eff = (1:Nparm)';
AXall  = ax0;

for n = 1 : Nlearn
    
    ax_eff = ax(ix_eff);
    w0_eff = w(ix_eff);

    [ixf, ixc] = ind2sub([Nfeat, Nclass], ix_eff);

    %%% W-step

    option = optimset('Gradobj','on','Hessian','on', 'Display', wdisp_mode);
    [w_eff,f,eflag,output,grad,H]=fminunc(@linfunmlr, w0_eff, option,...
        t_train, ax_eff, Xtr, ix_eff, ixf, ixc, Nclass);

    %% iax_eff = 1./ax_eff;  %% commentoutted by uchi
    dS_eff = inv(H); % #parm*1
    %% A-step
    ax_eff = (1-ax_eff.* diag(dS_eff))./(w_eff.^2);

    %% Prune ineffective parameters
    w          = zeros(Nparm,1);
    w(ix_eff)  = w_eff;
    ax(ix_eff) = ax_eff;
    ix_eff     = find(ax < AMAX);

    if isempty(ix_eff)
        display('Caution: No feature is survived !!');
        break;  
    end

    
    if mod(n, Nstep) == 0
        if strcmp(verbose,'on')
          fprintf('Iterations : %d, Feature Remained: %d \n', n, length(ix_eff));
        end
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
% set ix_eff_all
%-----------------------
[ixf, ixc] = ind2sub([Nfeat, Nclass], ix_eff);
ix_eff_all = cell(1,Nclass);
for c = 1 : Nclass
    tmp     = ixc==c;       % restricted to class c
    ixf_tmp = ixf(tmp);     % feature indices of class c
    if isempty(ixf_tmp)
        ix_eff_all{c} = [];
    elseif ixf_tmp(end) == Nfeat            % last index == index of baseline
        ixf_tmp2      = ixf_tmp(1:end-1);   % remove last index
        ix_eff_all{c} = ixf_tmp2;
        else
        ix_eff_all{c} = ixf_tmp;
    end
end


%-----------------------
% Count correct
%-----------------------
ww = reshape(w, [Nfeat, Nclass]);
[tmp, label_est_tr] = max(Xtr*ww,[],2);
Ncorrect_tr=length(find(label_est_tr == t_train))/(Nsamp)*100;
if strcmp(verbose,'on')
  fprintf(' Training Answer Correct  : %f \n', Ncorrect_tr);
end

eYtr = exp(Xtr*ww); % Nsamp*Nclass
Ptr  = eYtr ./ repmat(sum(eYtr,2), [1, Nclass]); % Nsamp*Nclass

errTable_tr = slr_error_table(t_train, label_est_tr);


