function [D, pars] = shiftData(D, pars)
%shiftData - shifts data (relative to labels) by 'shift' (+ forward)
%[D, pars] = shiftData(D, pars)
%
% Shifting forward (shift>0) deletes the last 'shift' end sample and
% repeats the first 'shift' samples; shifting backwards (shift<0) deletes
% the first '-shift' samples andrepeats '-shift' end samples.
%
% Input:
%   D.data        - 2D matrix of any data ([time(sample) x space(voxel/channel)] format)
% Optional:
%   pars.shift    - number to shift data: + shifts forward, - backwards (normal)
%   		        (relative to labels)
%   pars.verbose  - [1..3] = print detail level; 0 = no printing (default=1)
% Output:
%   D.data        - shifted data
%   D.labels      - labels of shifted sample
%   D.inds_blocks - begin/end indexes of shifted samples for each block
%   D.inds_runs   - begin/end indexes of shifted samples for each run
%   D.inds_conds  - indexes of shifted samples for each cond
%
% Created  By: Alex Harner (1),     alexh@atr.jp      06/04/06
% Modified By: Alex Harner (1),     alexh@atr.jp      07/02/20
% Modified By: Satoshi MURATA (1),  satoshi-m@atr.jp  08/09/25
% (1) ATR Intl. Computational Neuroscience Labs, Decoding Group


%% Check and get pars:
if exist('D','var')==0 || isempty(D)
    error('''D''ata-struct must be specified');
end
if exist('pars','var')==0,      pars = [];      end

if isfield(pars,mfilename)      % unnest, if needed
    P    = pars;
    pars = P.(mfilename);
end
shift   = getFieldDef(pars,'shift',0);
verbose = getFieldDef(pars,'verbose',1);

if shift==0,    return;     end

num_runs    = size(D.inds_runs,2);


Nshift = abs(shift); %YF

%% For UI:
if verbose
    fprintf(['\n' mfilename ' ------------------------------']);
    fprintf('\n Shifting data forwards by %d samples (normal for fMRI data)\n', Nshift);
end


%% Shift data:
inds_del_data = zeros(num_runs*Nshift,1);
inds_del_labels = zeros(num_runs*Nshift,1);
if isfield(D,'inds_trial')
    D.inds_trial2 = [];
end
for itr=1:num_runs
    bi = D.inds_runs(1,itr);
    ei = D.inds_runs(2,itr);
    
    inds_del_data(Nshift*(itr-1)+1:Nshift*itr) = bi:bi+Nshift-1; %YF
    inds_del_labels(Nshift*(itr-1)+1:Nshift*itr) = ei-Nshift+1:ei; %YF
    
    ind_blocks_in                       = find(D.inds_blocks(1,:)>=bi & D.inds_blocks(1,:)<ei);
    D.inds_blocks(:,ind_blocks_in)      = D.inds_blocks(:,ind_blocks_in) - (itr-1)*Nshift;
    D.inds_blocks(2,ind_blocks_in(end)) = D.inds_blocks(2,ind_blocks_in(end)) - Nshift;


    if isfield(D,'inds_trial')
        D.inds_trial{itr} = D.inds_trial{itr} - (itr-1)*Nshift;
        D.inds_trial{itr}(2,end) = D.inds_trial{itr}(2,end) - Nshift;
        D.inds_trial2 = [D.inds_trial2 D.inds_trial{itr}];        
    end
    
    D.inds_runs(1,itr) = bi - (itr-1)*Nshift;
    D.inds_runs(2,itr) = ei - itr*Nshift;
end

D.data(inds_del_data,:) = []; %YF
D.labels(inds_del_labels,:) = []; %YF

uniq_conds = unique(D.labels);
for itc=1:length(uniq_conds)
    D.inds_conds{itc} = find(D.labels==uniq_conds(itc))';
end


%% For 'P'ars-struct
if exist('P','var')
    P.(mfilename) = pars;
end
