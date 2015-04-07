% 2 class classfication by SLR
% nonlinear discriminant function in low dimension extracted by 
% feature selection. Optimization of Gaussian kernel width.
% 
% discriminant fucntion : kernel function 
% training data : simulated data generated from Gaussian Mixtures 
% test data     : simulated data generated from Gaussian Mixtures

clear
close all

fprintf('This is a demo how kernel classifier works using simulated data...\n\n');

%-----------------------
% Generate data
%-----------------------
mu = [-0.8 0.8; 0 0];
S  = [9 0; 0 1];
[tt, xx] = gen_sin_data(300,mu,S);
ttrain = tt(1:200);
xtrain = xx(1:200,:);
ttest  = tt(201:300);
xtest  = xx(201:300,:);

%------------------------
% Plot simulated data
%------------------------
slr_view_data(ttrain, xtrain);
xlabel('Feature 1');
ylabel('Feature 2');
title('Simulated Training Data');

fprintf('Press any key to proceed\n');
pause

%-------------------------
% Optimize Kernel Width
%-------------------------
fprintf('Kernel classifier with radial basis Function is used...\n'); 
fprintf('Now optimizing kernel width ...\n'); 

t = ttrain;
x = xtrain;
Nall = length(t);

RR = 2.^[1:15] * 1e-4; 
Ncv = 10;

for r = 1 : length(RR)
    R = RR(r);
    for nn = 1 : Ncv
        fprintf('Gaussian Width : %1.5f, Trial : %2.0d, ', R, nn);
        
        [t_train_CV, x_train_CV, t_test_CV, x_test_CV, ix_train_CV] = ...
            slr_CV_divide_data(t, x, 0.8);

        [ww, ix_eff_all, errTable_tr, errTable_te, parm]...
            = run_rvm(x_train_CV, t_train_CV, x_test_CV, t_test_CV, R, ...
            'nlearn', 100, 'nstep', 150, 'scale_mode', 'none', 'mean_mode', 'none');

        COR_TEST(nn) = calc_percor(errTable_te);
        
          
        
    end  %% CV loop end

    COR_TEST_R(r,:) =  COR_TEST;
end

[tmp, rmax] = max(mean(COR_TEST_R, 2));

fprintf('Optimization finished ...\n'); 
fprintf('Optimum Kernel Width = %1.5f ...\n\n', RR(rmax)); 

%--------------------------
% Plot Optimization Result
%--------------------------

figure,
semilogx(RR, mean(COR_TEST_R, 2), 'bo-');
xyrefline(RR(rmax));   
xlabel('Kernel Width');
ylabel('Validation Result (%)');

fprintf('Press any key to proceed... \n');
pause

%-------------------------------
% Try Test Data 
%-------------------------------
fprintf('Now try test data ... \n');

Ropt = RR(rmax);

[ww, ix_eff_all, errTable_tr, errTable_te, parm]...
            = run_rvm(xtrain, ttrain, xtest, ttest, Ropt, ...
            'nlearn', 1000, 'nstep', 200, 'scale_mode', 'none', 'mean_mode', 'none');

            
fprintf('\nDemo Finished ...\n');
  
%---------------------------------
% Plot Boundary (need to modify)
%---------------------------------
    
minx1 = min(xtrain(:,1))*1.0;
maxx1 = max(xtrain(:,1))*1.0;
minx2 = min(xtrain(:,2))*1.0;
maxx2 = max(xtrain(:,2))*1.0;
    
[X1, X2] = meshgrid([minx1:(maxx1-minx1)/50:maxx1],[minx2:(maxx2-minx2)/50:maxx2]); 
Phi = slr_make_kernel([X1(:),X2(:)], Ropt, xcenter);
if isbias 
    Phi = [Phi ones(size(Phi,1),1)];
end
Z = Phi * w_e(ix_eff);
        
%% 
ttest = label2num(ttest);
ix1 = find(ttest == 1);
ix2 = find(ttest == 2);

figure,
plot(xtest(ix1,1),xtest(ix1,2), 'b*');
hold on;
plot(xtest(ix2,1),xtest(ix2,2), 'r.');
hold on
contour(X1, X2, reshape(Z, [51,51]),[0,0]);
xlabel('Feature 1');
ylabel('Feature 2');
title('Test Data')
axis equal;


        
