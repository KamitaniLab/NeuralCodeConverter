function [D, pars] = averageBlocks(D, pars)
%averageBlocks - averages data in each block for each channel (voxel)
%[D, pars] = averageBlocks(D, pars)
%
% Input:
%	D.data         - 2D matrix of any data ([time(sample) x space(voxel/channel)] format)
%	D.inds_blocks  - begin/end indexes of samples for each block ([2(begin,end) x block] format)
% Optional:
%	pars.begin_off - number of samples to remove from the beginning of each block
%	pars.end_off   - number of samples to remove from the end of each block
%	pars.verbose   - [1..3] = print detail level; 0 = no printing (default=1)
% Output:
%	D.data         - block averaged data
%   D.labels       - labels for each averaged data
%   D.inds_runs    - begin/end indexes of averaged samples for each run
%   D.inds_conds   - indexes of averaged samples for each condition
%
% Key:
%	nChans = # Channels, signals; voxels for fMRI; sensors for EEG; ~ space, patterns
%	nSamps = # Samples; nTRs, nVols, nTrials for fMRI (not MEG); ~ time
%
% Created  By: Alex Harner (1),     alexh@atr.jp      06/03/22
% Modified By: Alex Harner (1),     alexh@atr.jp      06/07/31
% Modified By: Satoshi MURATA (1),  satoshi-m@atr.jp  08/09/25
% Modified By: Satoshi MURATA (1),  satoshi-m@atr.jp  09/01/21
% (1) ATR Intl. Computational Neuroscience Labs, Decoding Group


%% Check and get pars:
if exist('D','var')==0 || isempty(D)
    error('''D''ata-struct must be specified');
end
if exist('pars','var')==0,      pars = [];              end

if isfield(pars,mfilename)      % unnest, if needed
    P    = pars;
    pars = P.(mfilename);
end
begin_off = getFieldDef(pars,'begin_off',0);
end_off   = getFieldDef(pars,'end_off',0);
verbose   = getFieldDef(pars,'verbose',1);

num_blocks = size(D.inds_blocks,2);
num_chans  = size(D.data,2);


%% For UI:
if verbose
    fprintf(['\n' mfilename ' ------------------------------']);
    if verbose>=2
        fprintf('\n # blocks: \t%d',num_blocks);
        fprintf('\n begin_off:\t%d',begin_off);
        fprintf('\n end_off:  \t%d',end_off);
    end
    fprintf('\n');
end


%% Calculate average:
data_temp = zeros(num_blocks,num_chans);
for itb=1:num_blocks
    bi = D.inds_blocks(1,itb) + begin_off;
    ei = D.inds_blocks(2,itb) - end_off;
    
    if bi>ei
        if ismember(D.inds_blocks(2,itb),D.inds_runs(2,:))
            % last block of each run, this error may be caused by 'shiftData'
            fprintf('\nWarning: End-point of block averaging is smaller than begin-point\n Use only begin-point\n');
            ei = bi;
        else
            error('begin/end_off is too many to keep samples of block averaging');
        end
    end
    
    data_temp(itb,:) = mean(D.data(bi:ei,:),1);
end
D.data = data_temp;


%% Make labels:
D.labels = D.labels(D.inds_blocks(1,:));


%% Make indexes:
[nouse, ind]     = ismember(D.inds_runs(1,:),D.inds_blocks(1,:));
D.inds_runs(1,:) = ind;
D.inds_runs(2,:) = [ind(2:end)-1 size(D.inds_blocks,2)];

uniq_conds = unique(D.labels);
for itc=1:length(uniq_conds)
    D.inds_conds{itc} = find(D.labels==uniq_conds(itc))';
end

D.inds_blocks(1,:) = 1:size(D.inds_blocks,2);
D.inds_blocks(2,:) = D.inds_blocks(1,:);


%% For 'P'ars-struct
if exist('P','var')
    P.(mfilename) = pars;
end
