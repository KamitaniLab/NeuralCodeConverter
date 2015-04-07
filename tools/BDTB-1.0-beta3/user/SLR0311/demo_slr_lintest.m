% 2 class classfication by linear SLR
% feature extraction is possible ??? 
% 
% discriminant fucntion : linear function 
% training data : simulated data generated from Gaussian Mixtures 
% test data     : simulated data generated from Gaussian Mixtures 

clear
close all

fprintf('This is a demo how the sparse logistic regression model works...\n');
%----------------------------
% Generate Data
%----------------------------

D = 400;
Ntr = 200; 
Nte = 100;
% mean
mu1 = zeros(D,1);
mu2 = [1.5; 0; zeros(D-2,1)];
% covariance
S = diag(ones(D,1));
ro = 0.5;
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

%--------------------------------
% Learn Paramters
%--------------------------------
tic
fprintf('\nOLD version (ARD-Laplace)!!\n')
[ww_o, ix_eff_o, errTable_tr_o, errTable_te_o] = run_smlr_bi(xtr, ttr, xte, tte,...
    'wdisp_mode', 'off', 'nlearn', 300, 'mean_mode', 'none', 'scale_mode', 'none');
toc

tic
fprintf('\nFast version (ARD-Variational)!!\n')
[ww_f, ix_eff_f, errTable_tr_f, errTable_te_f] = run_smlr_bi_var(xtr, ttr, xte, tte,...
    'nlearn', 300, 'mean_mode', 'none', 'scale_mode', 'none');
toc

%--------------------------------
% Plot data (First 2 dimension)
%--------------------------------
figure,
subplot(2,1,1)
slr_view_data(tte, xte, [1 2], ww_o(:,1))
axis equal;
title('Old version');
subplot(2,1,2)
slr_view_data(tte, xte, [1 2], ww_f(:,1))
axis equal;
title('Fast version');


fprintf('Finish demo !\n');
