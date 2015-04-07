function [Ncorrect, label_est, prob ,y] = slr_count_correct_mixture2(label, X, g_all, w_all)
% Count the number of correct label 
%
% function [Ncorrect, label_est, prob ,y] = slr_count_correct_mixture(label, X,
% g_all, w_all)
%

for m = 1 : length(X)
    y = X{m}*w_all{m}(:);
    p = 1 ./(1+exp(-y)) ; % #data

    p_all(:,m) = p;    
end

prob = sum(p_all.*g_all,2);
label_est = prob > 0.5;

% ~xor  0 0 -> 1, 
%       0 1 -> 0
%       1 0 -> 0 
%       1 1 -> 1

[v] = ~xor(label, label_est);
Ncorrect = sum(v);



