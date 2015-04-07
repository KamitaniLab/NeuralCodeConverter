function [nx, scale, base] = normalize_feature(x, scale_mode, mean_mode, scale, base)
% NORMALIZE FEATURE VECTORS BEFORE CLASSIFICATION.
% First mean adjustment, then scaling. 
% 
% -- Usage
% [nx, scale, base] = normalize_feature(x, scale_mode, mean_mode)
% [nx, scale, base] = normalize_feature(x, scale_mode, mean_mode,
% scale, base)
%
% -- Input
% x : input features ( trial * feature )
% scale_mode : {all', 'each', 'none', .. }
% mean_mode : {all', 'each', 'none', .. }
% (scale, base) : optional
%
% 2006/01/31 Okito Yamashita



%% mean adjustment
switch mean_mode     
    case 'all',
        if nargin < 5
        base = mean(x(:));
        end
        nx = x - base;
        fprintf(' Mean adjustment by all features mean !')
    case 'each',
        if nargin < 5
        base =  mean(x,1);  % adjust baseline
        end
        nx = x - repmat(base, [size(x,1),1]);
        fprintf(' Mean adjustment by each feature mean!')
    otherwise,
        if nargin < 5
        base = 0;
        end
        nx = x;
   %     fprintf(' No mean adjustment !');
end

%% scale adjustment
switch scale_mode     
    case 'all',
        if nargin < 4
        scale = max(abs(nx(:))); 
        end
        nx = nx / scale ;
        fprintf(' Scaling by all features scale !\n')
    case 'each',
        if nargin < 4
        scale = max(abs(nx),[],1); 
        end
        nx = nx ./repmat(scale, [size(nx,1),1]) ;
        fprintf(' Scaling by each featue scale !\n')
    otherwise,
        if nargin < 4
        scale = 1;
        end
        nx = nx;
    %    fprintf(' No scaling !\n');
end

