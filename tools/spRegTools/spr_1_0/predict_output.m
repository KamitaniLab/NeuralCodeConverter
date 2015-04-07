function	[Y] = predict_output(X, Model, parm)
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

if ~exist('parm','var'), parm = []; end;

if ~isfield(parm,'Tau')
	tau = 1 ; 
	D   = 1 ; 
else
	tau = parm.Tau;
	D   = parm.Dtau;
end


[M, Tx, Ntrial] = size(X);
[N, MD] = size(Model.W );
T = Tx - (D-1)*tau;

if	isfield(Model,'ix_act')
	Flag = zeros(M*D,1);
	% active index for embeded space
	Flag(Model.ix_act) = 1;
	% extract active input dimension
	ix = find( sum(reshape(Flag,[M,D]),2) > 0);
	X  = X(ix,:,:);
	
	% adjust size of W
	W = zeros(N,M*D);
	W(:,Model.ix_act) = Model.W;
	W = reshape(W,[N,M,D]);
	W = W(:,ix,:);
	
	M = length(ix);
	W = reshape(W,[N,M*D]);
else
	W = Model.W;
end

% Embedding dimension
% D = size(W,2)/size(X,1)

Y = weight_out_delay_time(X, W, T, tau);

if isfield(parm,'ynorm') && ~isempty(parm.ynorm)
	Y = Y .* repmat(parm.ynorm, [1 T Ntrial]);
end

if isfield(parm,'ymean') && ~isempty(parm.ymean)
	Y = Y + repmat(parm.ymean, [1 T Ntrial]);
end
