function [class, weights] = classify_yk(sample, training, group, type, prior)
%CLASSIFY Discriminant analysis.
%   CLASS = CLASSIFY(SAMPLE,TRAINING,GROUP) classifies each row of the data in
%   SAMPLE into one of the groups in TRAINING.  SAMPLE and TRAINING must be
%   matrices with the same number of columns.  GROUP is a grouping variable for
%   TRAINING.  Its unique values define groups, and each element defines which
%   group the corresponding row of TRAINING belongs to.  GROUP can be a numeric
%   vector, a string array, or a cell array of strings.  TRAINING and GROUP must
%   have the same number of rows.  CLASSIFY treats NaNs or empty strings in
%   GROUP as missing values, and ignores the corresponding rows of TRAINING.
%   CLASS indicates which group each row of SAMPLE has been assigned to, and is
%   of the same type as GROUP.
%
% for more information, see help of 'classify'
%
% Rewritten By: Yukiyasu Kamitani (1),  kmtn@atr.jp
% Modified  By: Satoshi MURATA (1),     satoshi-m@atr.jp  08/10/09
% (1) ATR Intl. Computational Neuroscience Labs, Decoding Group


if nargin < 3
    error('Requires at least three arguments.');
end

% grp2idx sorts a numeric grouping var ascending, and a string grouping
% var by order of first occurrence
[gindex,groups] = grp2idx_yk(group);
nans            = find(isnan(gindex));
if isempty(nans)==0
    training(nans,:) = [];
    gindex(nans)     = [];
end
ngroups = length(groups);
gsize   = hist(gindex,1:ngroups);

[n,d] = size(training);
if size(gindex,1) ~= n
    error('The length of GROUP must equal the number of rows in TRAINING.');
elseif size(sample,2) ~= d
    error('SAMPLE and TRAINING must have the same number of columns.');
end
m = size(sample,1);

if nargin < 4 || isempty(type)
    type = 1; % 'linear'
elseif ischar(type)
    i = strmatch(lower(type), {'linear','quadratic','mahalanobis'});
    if length(i) > 1
        error('Ambiguous value for TYPE:  %s.', type);
    elseif isempty(i)
        error('Unknown value for TYPE:  %s.', type);
    end
    type = i;
else
    error('TYPE must be a string.');
end

% Default to a uniform prior
if nargin < 5 || isempty(prior)
    prior = ones(1, ngroups) / ngroups;
% Estimate prior from relative group sizes
elseif ischar(prior) && ~isempty(strmatch(lower(prior), 'empirical'))
    prior = gsize(:)' / sum(gsize);
% Explicit prior
elseif isnumeric(prior)
    if min(size(prior)) ~= 1 || max(size(prior)) ~= ngroups
        error('PRIOR must be a vector one element for each group.');
    elseif any(prior < 0)
        error('PRIOR cannot contain negative values.');
    end
    prior = prior(:)' / sum(prior); % force a normalized row vector
elseif isstruct(prior)
    [pgindex,pgroups] = grp2idx_yk(prior.group);
    ord               = repmat(NaN,1,ngroups);
    for i = 1:ngroups
        j = strmatch(groups(i), pgroups(pgindex), 'exact');
        if ~isempty(j)
            ord(i) = j;
        end
    end
    if any(isnan(ord))
        error('PRIOR.group must contain all of the unique values in GROUP.');
    end
    prior = prior.prob(ord);
    if any(prior < 0)
        error('PRIOR.prob cannot contain negative values.');
    end
    prior = prior(:)' / sum(prior); % force a normalized row vector
else
    error('PRIOR must be a a vector, a structure, or the string ''empirical''.');
end

% Add training data to sample for error rate estimation
if nargout > 1
    sample = [sample; training];
    mm     = m+n;
else
    mm = m;
end

gmeans = repmat(NaN, ngroups, d);
for k = 1:ngroups   
    gmeans(k,:) = mean(training((gindex == k),:),1);
end

D       = repmat(NaN, mm, ngroups);
decVals = repmat(NaN, mm, ngroups);  %%% yk

switch type
case 1 % 'linear'
    if n <= ngroups
        error('TRAINING must have more observations than the number of groups.');
    end
    % Pooled estimate of covariance
    [Q,R] = qr(training - gmeans(gindex,:), 0);
    R     = R / sqrt(n - ngroups); % SigmaHat = R'*R
    s     = svd(R);
%    if any(s <= eps^(3/4)*max(s))
    if any(s <= max(n,d) * eps(max(s)))
		error('The pooled covariance matrix of TRAINING must be positive definite.');
    end

    % MVN relative log posterior density, by group, for each sample
    weights = zeros(d+1,ngroups);
    for k = 1:ngroups
        A = (sample - repmat(gmeans(k,:), mm, 1)) / R;
        % D(:,k) =  - sum(A .* A, 2);
        D(:,k) = log(prior(k)) - .5*sum(A .* A, 2);

        %%% compute weights %%%%%%
        gmean_R      = gmeans(k,:)/R;
        w            = 2*(inv(R)*gmean_R');
        b            = - gmean_R*gmean_R'; 
        w_b          = [w; b];
        decVals(:,k) = sample*w + b;       
        
        weights(:,k) = w_b;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end

end

% find nearest group to each observation in sample data
%  [tmp class] = max(D, [], 2);
  [tmp class] = max(decVals, [], 2);   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% yk

% Compute apparent error rate: percentage of training data that
% are misclassified.
if nargout > 1
    class   = class(1:m);
end

% Convert back to original grouping variable
if isnumeric(group)
    groups = str2num(char(groups));
    class  = groups(class);
elseif ischar(group)
    groups = char(groups);
    class  = groups(class,:);
else %if iscellstr(group)
    class = groups(class);
end
