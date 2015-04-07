function [D, P] = make_fmri_mat
% Function for making <sbj_id>_fmri_<roi_set>_<save_ver> format data
% Copy, modify, and run this function for your data files
%
% Output:
%   D.sbj_id       - subject ID (2 initialis and date in YYMMDD format)
%   D.data         - 2D matrix of any data ([time(sample) x space(voxel/channel)] format)
%   D.tvals        - t-values of each voxel/channel ([1 x space] format)
%   D.xyz          - x,y,z-coordinate values of each voxel/channel ([3(x,y,z) x space] format)
%   D.labels       - condition labels of each sample ([time x 1] format)
%   D.labels_names - names of each condition ({1 x condition} format)
%   D.inds_blocks  - begin/end indexes of samples for each block ([2(begin,end) x block] format)
%   D.inds_runs    - begin/end indexes of samples for each run ([2(begin,end) x run] format)
%   D.inds_conds   - indexes of samples for each condition ({condition x 1} format)
%   D.rois_inds    - indexes of samples within each ROI ({same size as 'P.rois.roi_files'} format)
%   D.rois_names   - names of each ROI ({same size as 'P.rois.roi_files'} format)
%   P.script_name  - name of performed script/function name (this file)
%   P.date_time    - date and time this function was performed
%   P.sbj_id       - subject ID (2 initialis and date in YYMMDD format)
%   P.fMRI         - parameters for fMRI
%   P.prtcl        - parameters for protocol of experiment
%   P.rois         - parameters for ROI files
%   P.output       - parameters for file output
%   P.paths        - paths of data and library
%
% Calls:
%	load_paths              - loads paths (must be in same dir)
%   addpath_bdtb            - adds paths for BDTb, if needed
%	fmri_makeLabels         - makes D.labels (labels for each sample) 
%	fmri_makeInds           - makes D.inds_* (indexes for each block, run, and condition)
%   fmri_readRois           - reads ROI files
%   fmri_makeFileList       - makes epi_files to read
%	fmri_readEpisWithinRois - reads data from epi_files within ROIs
%   fmri_saveMat            - saves 'D'ata and 'P'arameters
%
% Created  By: Alex Harner (1),     alexh@atr.jp      06/06/27
% Modified By: Alex Harner (1),     alexh@atr.jp      06/11/17
% Modified By: Satoshi MURATA (1),  satoshi-m@atr.jp  08/09/16
% Modified By: Satoshi MURATA (1),  satoshi-m@atr.jp  08/12/26
% (1) ATR Intl. Computational Neuroscience Labs, Decoding Group


%% Set parameters:
P.script_name = mfilename;
P.date_time   = datestr(now,'yyyy-mm-dd HH:MM:SS');

% Current Subject ID (2 initials and date in YYMMDD format):
P.sbj_id = 'HU060614';


%% Set paths:
P.paths.to_lib = '';    % path to root of BDTB
P.paths.to_dat = '';    % path to root of DATA (maybe directory named 'sbj_id')
% if absent, select by GUI in the process


%% fMRI-specific:
% TR = secs per sample (1 sample = 1 TR = 1 volume for fMRI):
P.fMRI.TR = 5;

% 1st vol of each run:
P.fMRI.begin_vols = 3;
% If same each run, may be [1x1]; which is converted below;
% if different each run, list them as an array [4 3 3 ...].

% Maps task run numbers 1,2,... to file run letters:
P.fMRI.run_names = ...
		{'a','b','c','d','e','f','g','h','i','j','k','l'};
% Run:	  1   2   3   4   5   6   7   8   9  10
% If (functional data) run 1 = c, then remove: 'a','b'.

% Base file names to read:
P.fMRI.base_file_name = ['r' P.sbj_id];


%% Protocol of experiment:
% Condition labels for each run:
P.prtcl.labels_runs_blocks = {...   % [runs x blocksPerRun]
	[ 1  3  2  4  2  4  3  1 ];...	% run 1
	[ 1  3  4  2  2  3  4  1 ];...	% run 2
	[ 1  2  3  4  2  4  3  1 ];...	% ...
	[ 1  4  2  3  2  3  4  1 ];...
	[ 1  3  4  2  2  3  4  1 ];...
	[ 1  4  3  2  4  2  3  1 ];...
	[ 1  4  2  3  2  4  3  1 ];...
	[ 1  3  4  2  3  2  4  1 ];...
	[ 1  3  2  4  2  4  3  1 ];...
	[ 1  2  3  4  3  4  2  1 ]};
% A cell array with 1 cell for each run that contains
% a [1 x nBlock] matrix of labels for each block

% Names of condition labels
P.prtcl.labels_names  = {'rest', 'gu', 'choki', 'pa'}; 
% Condition labels:        1      2       3       4
% Cell array containing string names of labels,
% were each label number maps to a column name:

% Number of samples per block:
P.prtcl.samples_per_block = {4};
% If constant, may be size [1x1] (as above);
% if it varies per block/run, then it should match labels_runs_blocks in size.
% [1 x blocksPerRun] or [runs x blocksPerRun]


%% ROI info:
% SPM version used for making ROI:
P.rois.spm_ver = 5;
% Select from 99, 2, 5

% Directory of ROI index & stat files:
P.rois.roi_set = 'roi';
P.rois.roi_dir = 'roi/';    % use [P.paths.to_dat P.rois.roi_dir];

% ROI names (and file name ends):
P.rois.roi_files = {
   'M1_RHand','SMA_RHand','CB_RHand'; ...
   'M1_LHand','SMA_LHand','CB_LHand'; ...
};
% filename (without 'VOX_' and '.mat'), or empty if use all voxel (whole brain)


%% Output:
% Print details level for operations:
P.output.verbose = 0;

% Compatible format with MATLAB ver:
P.output.save_ver = 7;
% Select 6(-v6), 7(-v7), 7.3(-v7.3)

% File name:
P.output.file_name = [P.sbj_id '_fmri_' P.rois.roi_set '_v' num2str(P.output.save_ver) '.mat'];
% default: <sbj_id>_fmri_<roi_set>_<save_ver>





%% ----------------------------------------------------------------------------
%% Run functions (avoid changing):
% Set paths:
P.paths = set_paths(P.paths);

% Add paths (if needed):
str = which('addpath_bdtb');
if isempty(str),    addpath(P.paths.to_lib);    end
str = which('fmri_makeLabels');
if isempty(str),    addpath_bdtb;               end

% Make struct 'D'ata (empty):
D = struct;

% Start writing log:
log_name = [P.paths.to_logs 'log_' P.script_name '_' P.date_time(1:10) '.txt'];
diary(log_name);
fprintf('\n============================================================');
fprintf('\nscript: %s \tdate: %s\n', P.script_name, P.date_time);

% Copy Subject ID:
D.sbj_id = P.sbj_id;

% Make labels for each sample:
D.labels       = fmri_makeLabels(P.prtcl);
D.labels_names = P.prtcl.labels_names;

% Make indexes for each block, run, and condtion
[D.inds_blocks, D.inds_runs, D.inds_conds] = fmri_makeInds(P.prtcl,D.labels);

% Read ROI files:
[D.xyz, D.tvals, D.rois_inds, D.rois_names] = fmri_readRois(P);

% Read EPI files within ROI:
epi_files = fmri_makeFileList(P);
D         = fmri_readEpisWithinRois(D,epi_files);

% Save mat file:
fmri_saveMat(D,P);

% End log:
diary off;
