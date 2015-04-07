function [N, bin] = slr_hist_feature(IX_EFF, Nfeature) 
%
% Nfeature : # of features in estimation
%

ix_eff = []
for i = 1 : length(IX_EFF)
    ix_eff = [ix_eff; IX_EFF{i}];
end

[N, bin] = hist(ix_eff, Nfeature);
hist(ix_eff, Nfeature);
