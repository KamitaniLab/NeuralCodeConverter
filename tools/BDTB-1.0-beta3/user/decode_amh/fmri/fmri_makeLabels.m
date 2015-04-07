function labels = fmri_makeLabels(prtcl)
%fmri_makeLabels - makes labels for each sample from 'prtcl'
%labels = fmri_makeLabels(prtcl)
%
% Input:
%   prtcl.labels_runs_blocks - labels of each run ([run x block] format)
%   prtcl.samples_per_block  - number of samples per block ([1 x 1], [1 x block] or [run x block] format)
% Output:
%   labels                   - condition labels of each sample ([time x 1] format)
%
% Calls:
%   fmri_makeLabelsSub - make labels from 'samples_per_block' with [1 x block] format
%
% Created  By: Satoshi MURATA (1),  satoshi-m@atr.jp  08/09/17
% (1) ATR Intl. Computational Neuroscience Labs, Decoding Group

% Modified By: Yoichi Miyawaki (1),  yoichi_m@atr.jp  08/12/24
% compatible with samples_per_block --> [run x block]
% Modified By: Satoshi MURATA (1),  satoshi-m@atr.jp  09/01/06
% compatible with samples_per_block --> [1 x block]


%% Check and get pars:
if exist('prtcl','var')==0 || isempty(prtcl)
    error('''prtcl'' must be specified');
end

prtcl = getFieldDef(prtcl,'prtcl',prtcl);   % unnest, if need

labels_runs_blocks = getFieldDef(prtcl,'labels_runs_blocks',{});
samples_per_block  = getFieldDef(prtcl,'samples_per_block',1);
if ~iscell(samples_per_block)
    samples_per_block = {samples_per_block};
end


%% Make labels:
fprintf('\nMaking labels:\n');

if length(samples_per_block)==1
    if length(samples_per_block{1})==1  % [1 x 1]
        labels = reshape(repmat([labels_runs_blocks{:}],[samples_per_block{1},1]),1,[])';
    else                                % [1 x block]
        if length(samples_per_block{1})~=length(labels_runs_blocks{1})
            error('''labels_runs_blocks'' and ''samples_per_block'' don''t have the same block num');
        end
        num_samples = length(labels_runs_blocks) * sum(samples_per_block{1});
        labels      = fmri_makeLabelsSub(cell2mat(labels_runs_blocks),samples_per_block{1},num_samples);
    end
else                                    % [run x block]
    num_run = length(samples_per_block);
    if num_run~=1 && length(labels_runs_blocks)~=num_run
        error('''labels_runs_blocks'' and ''samples_per_bock'' don''t have the same run num');
    end
    labels = cell(num_run,1);
    for itr=1:num_run
        if length(labels_runs_blocks{itr})~=length(samples_per_block{itr})
            error('''labels_runs_blocks'' and ''samples_per_block'' don''t have the same block num');
        end
        num_samples = sum(samples_per_block{itr});
        labels{itr} = fmri_makeLabelsSub(labels_runs_blocks{itr},samples_per_block{itr},num_samples);
    end
    labels = [labels{:}];
end
