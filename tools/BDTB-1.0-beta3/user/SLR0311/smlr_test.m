function [label_est_te, Pte, errTable_te, parm] = smlr_test(ww, x_test, t_test, Nclass, parm)
% Predict using sparse multinomial logistic regression.
% 
% -- Usage
% [label_est_te, Pte, errTable_te, parm] =...
%     smlr_test(ww, x_test, t_test, Nclass, parm)
%
% --- Input
% ww      :   [Nfeat, Nclass]
% x_test  :   [Nsamp_te , Nfeat]
% t_test  :   [Nsamp_te , Nfeat]
% Nclass  :   [scalar]
% parm    :   struct of parameter in learning
%
% --- Optional Input (in parm)
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
%      'separate_normalize', 'boolean',  []           ,  0;... 
%     })
%
% --- Output
% label_est_te :
% Pte          :  [nSamp x nClass]
% errTbale_te  :   [Nclass, Nclass]
% parm         :   parmaters used in this routine [struct]
%
% 2008/10/10 SM
%  * Modified for MATLAB warning
% 2006/12/26 HU
%  * Separate learning and testing.
% 2006/09/06 OY  
%  * Output format modified (error table as output)
%  * Comment modified
% 2006/08/02 OY
% 2006/05/26 OY

if nargin < 5
    help smlr_test;
    return
end

[Nsamp_te, Nfeat] = size(x_test);

%
usebias  = parm.usebias;
norm_sep = parm.norm_sep;

% added by uchi
scale = parm.scale;
base  = parm.base;

% add a regressor for bias 
if usebias == 1
    Nfeat = Nfeat+1;
end
Nparm = Nclass*Nfeat;

% keep constant parameters
parm.nclass   = Nclass;
parm.nparm    = Nparm;
parm.nsamp_te = Nsamp_te;
parm.nfeat    = Nfeat;

% normalize (sacling and baseline addjustment)
if norm_sep == 0
%    [x_test, scale, base] = normalize_feature(x_test, parm.scale_mode, parm.mean_mode, scale, base);
    x_test = normalize_feature(x_test, parm.scale_mode, parm.mean_mode, scale, base);
else
    [x_test, scaleTe, baseTe] = normalize_feature(x_test, parm.scale_mode, parm.mean_mode);
    % added by uchi
    parm.scaleTe = scaleTe;
    parm.baseTe  = baseTe;
end

% add a regressor for bias term
if usebias
    Xte = [x_test, ones(Nsamp_te,1)];
else
    Xte = x_test;
end

%-----------------------
% Test
%----------------------
[tmp, label_est_te] = max(Xte*ww,[],2);
%if ~strcmp(t_test,'') & length(t_test) > 0
if ~isempty(t_test)
  Ncorrect_te=length(find(label_est_te == t_test))/(Nsamp_te)*100;
  fprintf(' Test Answer Correct  : %f \n', Ncorrect_te);
  errTable_te = slr_error_table(t_test, label_est_te);
else
  errTable_te = [];
end
eYte = exp(Xte*ww); % Nsamp*Nclass
Pte = eYte ./ repmat(sum(eYte,2), [1, Nclass]); % Nsamp*Nclass


