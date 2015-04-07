function fvals = anovaFvals(data, labels)
%anovaFvals - returns F-vals for an n-way anova for each column of data
%Fvals = anovaFvals(data, labels)
%
% Input:
%	data   - [num_samples x num_channels] float data
%	labels - [num_samples x 1] labels
% Output:
%	fvals  - a [1 x num_channels] vector of F-values
%
% Note:
%	Originally 'kmr_anovaVoxel'; it was rewritten from scratch to speed
%	it up ~88x for data with M>300 channels by doing them all at once.
%	This is also much faster than looping through 'anovan'.
%
% Original  By: Masahiro Kimura (1),  kmr@atr.jp        05/10/21?
% Rewritten By: Alex Harner (1),      alexh@atr.jp      06/09/11
% Modified  By: Alex Harner (1),      alexh@atr.jp      06/10/10
% Modified  By: Satoshi MURATA (1),   satoshi-m@atr.jp  08/09/30
% (1) ATR Intl. Computational Neuroscience Labs, Decoding Group


%% Chack and get pars:
if exist('data','var')==0   || isempty(data) || exist('labels','var')==0 || isempty(labels)
    fvals = [];
    return;
end

if size(data,1)~=size(labels,1)
    error('column-num of ''data'' and ''labels'' must be same');
end


%% Group info:
grps     = unique(labels);
num_grps = length(grps);
if num_grps<2
    fprintf('\n anovaFvals error: must have >1 groups!');
    return
end

inds_grps = cell(1,num_grps);
for itg=1:num_grps
    inds_grps{itg} = find(ismember(labels,grps(itg)));
end


%% Main:
data_avg  = mean(data,1);
num_chans = size(data,2);
fvals     = zeros(1,num_chans);
MSa       = zeros(1,num_chans);     % for Mean Square factor A
MSe       = zeros(1,num_chans);     % for Mean Square Error

for itg=1:num_grps
    data_grp    = data(inds_grps{itg},:);
    num_grp_elm = length(inds_grps{itg});
    
    MSa = MSa + num_grp_elm .* (mean(data_grp,1)-data_avg) .^ 2;
    MSe = MSe + (num_grp_elm-1) .* var(data_grp,0,1);
end

MSa = MSa ./ (num_grps-1);
MSe = MSe ./ (size(data,1)-num_grps);

inds_use        = MSe~=0;
fvals(inds_use) = MSa(inds_use) ./ MSe(inds_use);
