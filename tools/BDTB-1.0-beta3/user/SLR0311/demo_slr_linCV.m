% 2 class classfication by RVM
% feature extraction is possible ??? 
% Cross Validation is used for feature selection
%
% discriminant fucntion : linear function 
% training data : simulated data from Gaussian mixture distribution
% test data     : simulated data from Gaussian mixture distribution

clear
close all

%
fprintf('\nThis is a demo how sparse logistic regression can be used to select meaningful features by cross validation...\n');

%----------- Parameters to be modified
Ncv = 50;     % # of cross validation
Rtrain = 0.8;  % Ratio of training data set 

%----------------------------
% Generate Data
%----------------------------

D = 300;
Ntr = 200; 
Nte = 100;
% mean
mu1 = zeros(D,1);
mu2 = [1.5; 0; zeros(D-2,1)];
% covariance
S = diag(ones(D,1));
ro = 0.8;
S(1,2) = ro;
S(2,1) = ro;


[ttr, xtr, tte, xte, g] = gen_simudata([mu1 mu2], S, Ntr, Nte);
              
fprintf('\nThe data is generated from 2 Gaussian Mixture model of which centers (mean) are different.\n'); 
fprintf('Input feature dimension is %d. \n',D);
fprintf('But only the first dimension has difference in mean value between two classes,\n'); 
fprintf('and the other dimension has same mean value.\n');
fprintf('Therefore only the first dimension is detected as a meaningful feature,\n') 
fprintf('if you select features by feature-wise t-value ranking method.\n');
fprintf('However due to the correlataion between the second dimension and the first dimension,\n')
fprintf('inclusion of the second dimension makes classfication more accurate.\n');

%--------------------------------
% Plot data (First 2 dimension)
%--------------------------------
slr_view_data(ttr, xtr);
axis equal;
title('Training Data')

fprintf('\nPress any key to proceed \n');
pause

%----------------------------
% Cross Validation
%----------------------------
x = xtr;
t = ttr;

for nn = 1 : Ncv
    
    fprintf('\n\n Cross Validation Trial : %3d \n', nn)
    
    [ix_train, ix_test] = separate_train_test(t, Rtrain);
            
    x_train = x(ix_train,:);
    t_train = t(ix_train);
    x_test = x(ix_test,:);
    t_test = t(ix_test);
    
    fprintf('Fast version (ARD-Variational)!!\n')
    [ww, ix_eff, errTable_tr, errTable_te, g] = run_smlr_bi_var(x_train, t_train, x_test, t_test,...
        'nlearn', 1000, 'nstep', 1000, 'mean_mode', 'each', 'scale_mode', 'each', 'amax', 1e8);

    
    CVRes(nn).ix_eff_all = ix_eff;
    CVRes(nn).errTable_te = errTable_te;
    CVRes(nn).errTable_tr = errTable_tr;
    CVRes(nn).g           = g;
        
    IX_SAMP_TEST(nn,:)  = ix_test;
    
end

% N-value 
N = calc_Nval(CVRes, {'blue'});
figure,
bar(N);
ylabel('N-value');
xlabel('Feature Number');



