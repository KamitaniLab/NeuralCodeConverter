% Batch script for sparse prediction
clear all

% --- training method ID
method_id = 1;
%  Case: X is original input
%    Time embedding is done in the learning program
% 1: linear_sparse_space 
%    First choice for input dim < 1000 with embedding
% 2: linear_sparse_stepwise
%    First choice for input dim > 1000
% 3: linear_sparse_seq
%  Case: X is delay embedding input or input-output mapping
% 4: linear_map_sparse_cov_pinv

% --- Basic Learning Parameters
parm.Ntrain = 2000; % # of total training iteration
parm.Nskip  = 100;	% skip steps for display info

% --- Time delay embedding parameter
parm.Tau   = 1 ;   % Lag time steps
parm.Dtau  = 3 ;   % Number of embedding dimension
parm.Tpred = 0 ;   % Prediction time step : y(t+Tpred) = W * x(t)

% --- Normalization parameter
parm.data_norm  = 1;	% Normalize input and output

% File name of old training result for retraining 
old_file = [];

% File name for test data
datafile  = ['./test/test.mat'];
modelfile = ['./test/model'];
newdata   = 1; % = 1: make new data

% --- Make or Load training & test data
if newdata == 0 && exist(datafile,'file')
	load(datafile, ...
		'xdata','ydata','xtest','ytest')
else
	% Training & test data setting
	Tdata  = 1000 ; % # of training data
	Ttest  = 1000 ; % # of test data
	
	parm.Xdim = 200;   % Input dim
	parm.Meff = 30;    % Effective Input
	parm.Sdim = 10; % number of sinusoidal input
	parm.Tmin = 50; % minimum period
	parm.Tmax = 200;% maximum period
	parm.SY   = 0.3;% output moise variance

	parm.sy = parm.SY;
	[xdata,ydata,Wout,Weff,Wrdn,Win,Wirr] = ...
		make_train_data(parm, Tdata);
	
	parm.sy = 0.0;
	[xtest,ytest] = ...
		make_train_data(parm, Ttest, Wout,Wrdn,Win,Wirr);
	
	if ~isempty(datafile)
		save(datafile, ...
			'xdata','ydata','xtest','ytest','Wout','Weff','parm')
	end
end

% Normalize input data
[X,nparm] = normalize_data(xdata, parm.data_norm);
parm.xmean = nparm.xmean;
parm.xnorm = nparm.xnorm;

% Normalize output data
[Y,nparm] = normalize_data(ydata, parm.data_norm);
parm.ymean = nparm.xmean;
parm.ynorm = nparm.xnorm;

% Time alignment for prediction using embedding input
[tx,ty] = pred_time_index(X,parm);
X = X(:,tx,:);
Y = Y(:,ty,:);

% --- Initialization of Model Parameters
if ~isempty(old_file)
	% Start from old result
	load([old_file], 'Model')
else
	Model = [];
end

%profile_on = 1;
%profile_start(profile_on);

%
% --- Sparse estimation
%
switch	method_id
case	1
	% --- X is original input
	[Model, Info] = linear_sparse_space(X, Y, Model, parm);
case	2
	% --- X is original input
	[Model, Info] = linear_sparse_stepwise(X, Y, Model, parm);
case	3
	% --- X is original input
	[Model, Info] = linear_sparse_seq(X, Y, Model, parm);
case	4
	% --- Delay embedding is done before training
	Xd = delay_embed(X, parm.Tau, parm.Dtau);
	[Model, Info] = linear_map_sparse_cov(Xd, Y, Model, parm);
end

%
% --- Estimate prediction error for test data
%

% Time alignment for prediction using embedding input
[tx,ty] = pred_time_index(xtest,parm);
xtest = xtest(:,tx,:);
ytest = ytest(:,ty,:);

% Use normalization constant calculated by training data
xtest = normalize_data(xtest, parm.data_norm, parm);

% --- Prediction for test data
ypred = predict_output(xtest, Model, parm);
err   = sum((ytest(:)-ypred(:)).^2)/sum(ytest(:).^2)

if ~isempty(modelfile)
	fsave = [modelfile sprintf('_id%d.mat',method_id)];
	save(fsave, 'Model', 'Info', 'parm');
end

plot_predict

%profile_end(profile_on)
return
