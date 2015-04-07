function	[weight] = ky_predict_output(inputDimSize, Model, parm)
% Prediction from input data
% Time delay embedding for X is done in this function
%  Y = predict_output(X, Model)
%    = Model.W * X
%  Y = predict_output(X, Model, parm)
%    = (Model.W * X) * (parm.ynorm) + (parm.ymean)
% --- Input
%  X  : Input data  ( M x T x Ntrial)
%  M  =  # of input (original input space dimension)
%  T  =  # of time sample
% parm.Tau       = Lag time
% parm.Dtau      = Number of embedding dimension
% parm.ymean
% parm.ynorm
%
%
% --- Output
%  Y  : Output data ( N x (T- (D-1)*tau) x Ntrial )
%  N  =  # of output
%
% 2006/1/27 M. Sato
% 2008-5-8 Modified by M. Sato
% modified by Kentaro Yamada, Honda R&D

if ~exist('parm','var'), parm = []; end;

if ~isfield(parm,'Tau')
    tau = 1 ;
    D   = 1 ;
else
    tau = parm.Tau;
    D   = parm.Dtau;
end

[N, MD] = size(Model.W );

if	isfield(Model,'ix_act')
    Flag = zeros(inputDimSize*D,1);
    % active index for embeded space
    Flag(Model.ix_act) = 1;
    % extract active input dimension
    ix = find( sum(reshape(Flag,[inputDimSize,D]),2) > 0);

    % adjust size of W
    W = zeros(N,inputDimSize*D);
    W(:,Model.ix_act) = Model.W;
    W = reshape(W,[N,inputDimSize,D]);
    W = W(:,ix,:);

    M = length(ix);
    W = reshape(W,[N,M*D]);
else
    W = Model.W;
end

weight.W = W;
weight.ix = ix;
weight.tau = tau;
weight.D = D;
weight.parm = parm;