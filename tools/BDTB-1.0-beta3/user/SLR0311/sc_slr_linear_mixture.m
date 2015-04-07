% 2 class classfication by linear SLR
% feature extraction is possible ??? 
% 
% discriminant fucntion : linear function 
% training data : simulated data generated from Gaussian Mixtures 
% test data     : simulated data generated from Gaussian Mixtures 

clear

Ncomp = 2;

%% load data
load('work_shibata/IN/S0mmTT/Decoding/subnm1_train2.mat', 'x', 'label');
load('work_shibata/IN/S0mmTT/Decoding/odds_train2.mat', 'odds');
t_train = label;
x_train = x;
g_train = odds;

load('work_shibata/IN/S0mmTT/Decoding/subnm1_test2.mat', 'x', 'label');
load('work_shibata/IN/S0mmTT/Decoding/odds_test2.mat', 'odds');
t_test = label;
x_test = x;
g_test = odds;

% scaling and specified features only
scale = max(x_train(:));
x_train = x_train/scale; 
x_test = x_test/scale;

%% # of data
Ntrain = length(t_train);
Ntest = length(t_test);
Nparm = size(x,2) / Ncomp;

%% Explanatory matrix 
for m = 1 : Ncomp
    X_train{m} = [x_train(:,(m-1)*Nparm+1:m*Nparm) ones(Ntrain,1)];
    X_test{m} =  [x_test(:,(m-1)*Nparm+1:m*Nparm) ones(Ntest,1)];
end

%%
%% Learning
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[w_all_e, ix_eff_all, MS] = slr_learning_mixture(t_train, X_train, g_train,...
    @linfun_mixture, 'reweight', 'OFF');

%% Training Result
[Ncorrect_train, t_train_e, p_train] = slr_count_correct_mixture...
    (t_train, X_train, g_train, w_all_e);
fprintf('Answer correct in training : %f%% \n', Ncorrect_train/Ntrain*100);

%%
%% Test Data
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Test Result
[Ncorrect_test, t_test_e, p_test] = slr_count_correct_mixture...
    (t_test, X_test, g_test, w_all_e);
fprintf('Answer correct in test : %f%% \n', Ncorrect_test/Ntest*100);




