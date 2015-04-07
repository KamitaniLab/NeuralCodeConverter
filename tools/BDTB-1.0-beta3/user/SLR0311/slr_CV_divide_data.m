function [t_train, x_train, t_test, x_test, ix_train, ix_test] = slr_CV_divide_data(t, x, r);
% Divide one data set to two data set, one is for training and the other 
% for testing.
% 
% t : Label
% x : Feature matrix
% r : Ratio of training data set to whole data  
%

[Nall] = length(t);

ix = randperm(Nall);    
ix_train = ix(1:floor(Nall*r));
ix_test = ix(floor(Nall*r)+1:end);
    
x_train = x(ix_train,:);
t_train = t(ix_train,:);
    
x_test = x(ix_test,:);
t_test = t(ix_test,:);