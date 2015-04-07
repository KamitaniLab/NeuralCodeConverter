function epi_files = fmri_makeFileList(P)
%fmri_makeFileList - makes EPI file list from P.prtcl, P.fMRI, and P.paths
%epi_files = fmri_makeFileLest(P)
%
% Input:
%   P.prtcl   - protocol of experiment
%               use 'labels_runs_blocks' and 'samples_per_block'
%   P.fMRI    - fMRI-specific parameters
%               use 'begin_vols', 'run_names', and 'base_file_name'
%   P.paths   - path of directory having EPI files
% Output:
%   epi_files - EPI file list
%
% Created By: Satoshi MURATA (1),  satoshi-m@atr.jp  08/09/17
% (1) ATR Intl. Computational Neuroscience Labs, Decoding Group

% Modified By: Satoshi MURATA (1),  satoshi-m@atr.jp  09/01/06
% compatible with samples_per_block --> [1 x block], [run x block]


%% Check and get pars:
if exist('P','var')==0 || isempty(P)
    error('''P''ars-struct must be specified');
end

prtcl = getFieldDef(P,'prtcl',[]);
fMRI  = getFieldDef(P,'fMRI', []);
paths = getFieldDef(P,'paths',[]);
if isempty(prtcl) || isempty(fMRI) || isempty(paths)
    error('''P''ars-struct is wrong');
end

labels_runs_blocks = getFieldDef(prtcl,'labels_runs_blocks',{});
samples_per_block  = getFieldDef(prtcl,'samples_per_block',1);
base_file_name     = getFieldDef(fMRI,'base_file_name','a');
run_names          = getFieldDef(fMRI,'run_names','a');
begin_vols         = getFieldDef(fMRI,'begin_vols',1);
dir_name           = fixDirname(getFieldDef(paths,'to_realigned','.'));
if ~iscell(samples_per_block)
    samples_per_block = {samples_per_block};
end


%% Calculate num of files in each run
num_runs   = length(labels_runs_blocks);
%num_blocks = length(labels_runs_blocks{1});

if length(samples_per_block)==1
    num_blocks = length(labels_runs_blocks{1});
    if length(samples_per_block{1})==1  % [1 x 1]
        num_files_run = num_blocks * samples_per_block{1};
    else                                % [1 x block]
        num_files_run = sum(samples_per_block{1});
    end
    num_files = num_runs * num_files_run;
else                                    % [run x block]
    num_files_run = zeros(1,num_runs);
    for itr=1:num_runs
        num_files_run(itr) = sum(samples_per_block{itr});
    end
    num_files = sum(num_files_run);
end


%% Make file list
fprintf('\nMaking EPI file list:\n');

dir_name  = repmat(dir_name,[num_files,1]);
base_name = repmat(base_file_name,[num_files,1]);
if length(samples_per_block)==1     % [1 x 1], [1 x block]
    run_name  = reshape(repmat(char(run_names{1:num_runs}),[1,num_files_run])',[],1);
    num_name  = repmat(num2str(((0:num_files_run-1)+begin_vols)','%04d'),[num_runs,1]);
else                                % [run x block]
    run_name = cell(1,num_runs);
    num_name = cell(1,num_runs);
    for itr=1:num_runs
        run_name{itr} = repmat(char(run_names{itr}),[1,num_files_run(itr)]);
        num_name{itr} = num2str(((0:num_files_run(itr)-1)+begin_vols),'%04d');
    end
    run_name = [run_name{:}]';
    num_name = reshape([num_name{:}]',4,[])';
end
ext_name  = repmat('.img',[num_files,1]);

epi_files = cellstr([dir_name base_name run_name num_name ext_name]);
