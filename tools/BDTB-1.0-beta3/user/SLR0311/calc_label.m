function [label_est, P] = calc_label(X, w);
%
%

Nclass = size(w,2);

if Nclass == 1,   % binary classification with parsimonious parametrization
    [label_est] = X * w > 0 ; 
    label_est = label_est + 1; % {0,1} -> {1,2} 
    P = 1 ./(1+exp(-X* w));
else
    [tmp, label_est] = max(X * w,[],2);
    eY = exp(X*w); % Nsamp*Nclass
    P = eY ./ repmat(sum(eY,2), [1, Nclass]); % Nsamp*Nclass
end