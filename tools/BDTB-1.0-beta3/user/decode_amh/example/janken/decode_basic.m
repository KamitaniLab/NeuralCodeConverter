function [res, D, P] = decode_basic(data)
% Function for running 'decode' process
% Copy, modify, and run this function for your data files
%
% Input:
%   data - struct of 'D', or mat-filename written by 'make_fmri_mat'
% Output:
%   res.model       - names of used model
%   res.preds       - predicted labels
%   res.labels      - defined labels
%   res.dec_vals    - decision values
%   res.weights     - weights (and bias)
%   res.freq_table  - frequency table
%   res.correct_per - percent correct
%   D.sbj_id        - subject ID (2 initialis and date in YYMMDD format)
%   D.data          - 2D matrix of any data ([time(sample) x space(voxel/channel)] format)
%   D.tvals         - t-values of each voxel/channel ([1 x space] format)
%   D.xyz           - x,y,z-coordinate values of each voxel/channel ([3(x,y,z) x space] format)
%   D.labels        - condition labels of each sample ([time x 1] format)
%   D.labels_names  - names of each condition ({1 x condition} format)
%   D.inds_blocks   - begin/end indexes of samples for each block ([2(begin,end) x block] format)
%   D.inds_runs     - begin/end indexes of samples for each run ([2(begin,end) x run] format)
%   D.inds_conds    - indexes of samples for each condition ({condition x 1} format)
%   D.rois_inds     - indexes of samples within each ROI ({same size as 'P.rois.roi_files'} format)
%   D.rois_names    - names of each ROI ({same size as 'P.rois.roi_files'} format)
%   P.script_name   - name of performed script/function name (this file)
%   P.date_time     - date and time this function was performed
%   P.procs1        - name of pre-validation preprocessing functions
%   P.procs2        - name of within-validation preprocessing functions
%   P.models        - name of within-validation classification/regression models
%   P.plotRoi       - 1: plot ROIs and weights, 0: not plot
%   P.paths         - paths of data and library
%   P.<function>    - parameters for each function
%
% Calls:
%	load_paths      - loads paths (must be in same dir)
%   addpath_bdtb    - adds paths for BDTb, if needed
%   procSwitch      - runs pre-processings with parameters
%   crossValidate   - closs-validates by models with pre-processings and parameters
%   printResults    - prints out the results
%   fmri_plotVolRoi - plots ROIs
%
% Created  By: Alex Harner (1),     alexh@atr.jp      06/07/30
% Modified By: Alex Harner (1),     alexh@atr.jp      06/11/17
% Modified By: Satoshi MURATA (1),  satoshi-m@atr.jp  08/09/22
% (1) ATR Intl. Computational Neuroscience Labs, Decoding Group

% Modified By: Satoshi MURATA (1),  satoshi-m@atr.jp  08/09/22
% select mat-file by GUI, if 'data' is absent


%% Set parameters:
P.script_name = mfilename;
P.date_time   = datestr(now,'yyyy-mm-dd HH:MM:SS');


%% Set paths:
P.paths.to_lib = '';    % path to root of BDTB
P.paths.to_dat = '';    % path to root of DATA (maybe directory named 'sbj_id')
% if absent, select by GUI in the process


%% procs1 pars - pre-validation preprocessing:
P.procs1 = {'fmri_selectRoi'; 'selectChanByTvals'; 'reduceOutliers'; 'detrend_amh';
            %'highPassFilter';
            'shiftData'; 'averageBlocks'; 'normByBaseline'};
% Defines what will be done in for procs1
% Processings are sequentially run

% Parameters of procs1:
P.fmri_selectRoi.rois_use     = {1 1 1; 1 1 1};
P.selectChanByTvals.num_chans = 200;      % (<-nVoxels)
P.selectChanByTvals.tvals_min = 3.2;
P.reduceOutliers.std_thres    = 4;
P.reduceOutliers.num_its      = 2;
P.shiftData.shift             = -1;        % (<- -shiftTR)
P.normByBaseline.base_conds   = 1:4;


%% procs2 pars - within-validation preprocessing:
%P.procs2 = {'selectTopFvals'; 'zNorm_amh'; 'selectConds'};
P.procs2 = {'selectTopFvals'; 'zNorm_amh'; 'selectConds'};
% Defines what will be done in for procs2
% Processings are sequentially run

% Parameters of procs2:
P.selectTopFvals.num_comp = 130;
P.zNorm_amh.app_dim       = 2;     % along space
P.zNorm_amh.smode         = 1;
P.selectConds.conds       = 2:4;


%% Model pars - within-validation classification/regression parameters:
P.models = {'liblinear_sm'};
% Defines what modeling will be performed:
% Exps: libsvm_amh, svm11lin_amh(32bit only), svm_multi_amh, lda_amh, slr_sm

% Parameters of models:
%P.svm11lin_amh.num_boot = 100;
%P.slr_bi_amh.R          = 0;


% Parameters of 'corssValidate'
%P.crossValidate.res_train = 1;
P.crossValidate.num_fold = 12;




%% ----------------------------------------------------------------------------
%% Run functions (avoid changing):
% Load paths:
P.paths = set_paths;

% Check args:
if exist('data','var')==0 || isempty(data)
    data = selectFile_gui('*.mat','Select mat-file saved ''D''');
    if isempty(data),   error('''D''ata-struct or mat-filename saved ''D'' must be specified');     end
end

% Load data:
if ischar(data)
    data = load(data);
    data = data.D;
    D    = data;
else
    D    = data;
end

% Start writing log:
log_name = [P.paths.to_logs 'log_' P.script_name '_' P.date_time(1:10) '.txt'];
diary(log_name);
fprintf('\n============================================================');
fprintf('\nscript: %s \tdate: %s\n', P.script_name, P.date_time);

% Run procs1 - pre-validation preprocessing:
[D, P] = procSwitch(D,P,P.procs1);

% Validate - proc2 & model:
[res P] = crossValidate(D,P,P.procs2,P.models);

% Print results:
if isfield(res,'test'),     printResults(res.test(:,end));
else                        printResults(res(:,end));             end

% End log:
diary off;
