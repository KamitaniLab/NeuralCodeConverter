% --------------------------------------------------------
% Copyright (c) 2015 ATR Department of Neuroinformatics
%                    and Honda R&D Co.,Ltd
%                    Part of NeuralCodeConverter project
% 
% This work has been published in NeuroImage,
% http://www.journals.elsevier.com/neuroimage/
% 
% Released under the MIT license
% http://opensource.org/licenses/mit-license.php
% --------------------------------------------------------
%
% Last modified by : Kentaro Yamada, HONDA R&D, on 2015/Mar/19th
%

function [weight] = spReg(ydata, xdata)

% --- training method ID
method_id = 2;
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
parm.Ntrain = 500; % # of total training iteration
parm.Npre_train = 50; % # of precise training which takes time
parm.Nskip  = 100;	% skip steps for display info

% --- Time delay embedding parameter
parm.Tau   = 1 ;   % Lag time steps
parm.Dtau  = 1 ;   % Number of embedding dimension
%parm.Dtau  = 3 ;   % Number of embedding dimension
parm.Tpred = 0 ;   % Prediction time step : y(t+Tpred) = W * x(t)

% --- Normalization parameter
parm.data_norm  = 1;	% Normalize input and output

% File name of old training result for retraining 
old_file = [];

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

% --- Prediction for test data
inputDimSize = size(X,1);
weight = ky_predict_output(inputDimSize, Model, parm);
