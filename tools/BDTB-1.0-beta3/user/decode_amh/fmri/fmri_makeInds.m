function [inds_blocks, inds_runs, inds_conds] = fmri_makeInds(prtcl, labels)
%fmri_makeInds - make indexes for each block, run, and condition
%[inds_blocks, inds_runs, inds_conds] = fmri_makeInds(prtcl)
%
% Input:
%   prtcl.labels_runs_blocks - labels of each run ([run x block] format)
%   prtcl.samples_per_block  - number of samples per block ([1 x 1] or [1 x block] format)
%   labels                   - condition labels of each sample ([time x 1] format)
%                              if absent, call 'fmri_makeLabels'
% Output:
%   inds_blocks              - begin/end indexes of samples for each block ([2(begin,end) x block] format)
%   inds_runs                - begin/end indexes of samples for each run ([2(begin,end) x run] format)
%   inds_conds               - indexes of samples for each condition ({condition x 1} format)
%
% Calls:
%    fmri_makeLabels - makes labels for each sample from 'prtcl'
%
% Created  By: Satoshi MURATA (1),  satoshi-m@atr.jp  08/09/17
% (1) ATR Intl. Computational Neuroscience Labs, Decoding Group

% Modified By: Satoshi MURATA (1),  satoshi-m@atr.jp  09/01/06
% compatible with samples_per_block --> [1 x block], [run x block]


%% Check and get pars:
if exist('prtcl','var')==0  || isempty('prtcl')
    error('''prtcl'' must be specified');
end
prtcl = getFieldDef(prtcl,'prtcl',prtcl);   % unnest, if needed

if exist('labels','var')==0 || isempty('labels')
    labels = fmri_makeLabels(prtcl);
end
labels = getFieldDef(labels,'labels',labels);   % unnest, if needed

labels_runs_blocks = getFieldDef(prtcl,'labels_runs_blocks',{});
samples_per_block  = getFieldDef(prtcl,'samples_per_block',1);
if ~iscell(samples_per_block)
    samples_per_block = {samples_per_block};
end

num_runs    = length(labels_runs_blocks);
%num_blocks  = length(labels_runs_blocks{1});
num_samples = length(labels);
uniq_conds  = unique([labels_runs_blocks{:}]);
num_conds   = length(uniq_conds);


%% Make indexes:
fprintf('\nMaking indexes:\n');

% inds_blocks:
if length(samples_per_block)==1
    num_blocks  = length(labels_runs_blocks{1});
    if length(samples_per_block{1})==1  % [1 x 1]
        inds_blocks = [1:samples_per_block{1}:num_samples; samples_per_block{1}:samples_per_block{1}:num_samples];
    else                                % [1 x block]
        inds_blocks = zeros(2,num_runs*num_blocks);
        end_ind     = cumsum(samples_per_block{1});
        start_ind   = [1 end_ind(1:end-1)+1];
        for itr=1:num_runs
            inds_blocks(:,1+num_blocks*(itr-1):num_blocks*itr) = [start_ind+end_ind(end)*(itr-1); end_ind+end_ind(end)*(itr-1)];
        end
    end
else                                    % [run x block]
    inds_blocks = zeros(2,length([labels_runs_blocks{:}]));
    num_blocks  = zeros(1,num_runs+1);
    for itr=1:num_runs
        num_blocks(itr+1) = num_blocks(itr) + length(labels_runs_blocks{itr});
        end_ind           = cumsum(samples_per_block{itr});
        start_ind         = [1 end_ind(1:end-1)+1];
        if itr==1
            inds_blocks(1,num_blocks(itr)+1:num_blocks(itr+1)) = start_ind;
            inds_blocks(2,num_blocks(itr)+1:num_blocks(itr+1)) = end_ind;
        else
            inds_blocks(1,num_blocks(itr)+1:num_blocks(itr+1)) = start_ind + inds_blocks(2,num_blocks(itr));
            inds_blocks(2,num_blocks(itr)+1:num_blocks(itr+1)) = end_ind + inds_blocks(2,num_blocks(itr));
        end
    end
end

% inds_runs:
if length(samples_per_block)==1
    if length(samples_per_block{1})==1  % [1 x 1]
        num_samples_runs = num_blocks * samples_per_block{1};
    else                                % [1 x block]
        num_samples_runs = sum(samples_per_block{1});
    end
    inds_runs = [1:num_samples_runs:num_samples; num_samples_runs:num_samples_runs:num_samples];
else                                    % [run x block]
    inds_runs = zeros(2,num_runs);
    num_samples_runs  = zeros(1,num_runs+1);
    for itr=1:num_runs
        num_samples_runs(itr+1)  = num_samples_runs(itr) + sum(samples_per_block{itr});
        inds_runs(1,itr)         = num_samples_runs(itr) + 1;
        inds_runs(2,itr)         = num_samples_runs(itr+1);
    end
end

% inds_conds:
inds_conds = cell(num_conds,1);
for itc=1:num_conds
    inds_conds{itc} = find(labels==uniq_conds(itc))';
end
