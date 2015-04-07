function D = fmri_readEpisWithinRois(D, file_list)
%fmri_readEpisWithinRois - reads EPI files, and returns data within ROIs
%data = fmri_readEpisWithinRois(D, file_list)
%
% Input:
%   D.xyz     - X,Y,Z-coordinate value of voxels within ROIs ([3(x,y,z) x space] format)
%               if empty, use all voxels (whole brain)
%   file_list - EPI file list
% Output:
%   D.data    - read data of voxels within ROIs ([time(sample) x space(voxel/channel)] format)
%   D.xyz     - X,Y,Z-coordinate value of voxels ([3(x,y,z) x space] format)
%
% Calls:
%   selectDir_gui     - outputs dialog-box to select directory with GUI
%   ismemberMatrix    - checks that arrays in source is also contained in target
%   SPM, (c) >>>
%       spm_defaults  - sets the defaults which are used by SPM
%       spm_vol       - get header information etc for images
%       spm_read_vols - read in entire image volumes
%   read_image, (c) >>>
%       read_image_sm - reads image
%
% Created  By: Satoshi MURATA (1),  satoshi-m@atr.jp  08/09/18
% Modified By: Satoshi MURATA (1),  satoshi-m@atr.jp  08/12/26
%   compatible with 'whole brain'
% Modified by: Yoichi Miyawaki (1),  yoichi_m@atr.jp   09/03/09
% (1) ATR Intl. Computational Neuroscience Labs, Decoding Group


%% Check and get pars:
if exist('D','var')==0 || isempty(D)
    error('''D''ata-struct must be specified');
end
if exist('file_list','var')==0 || isempty(file_list)
    error('''file_list'' must be specified');
end

rois_xyz = getFieldDef(D,'xyz',[]);


%% Add path of SPM (if needed):
str = which('spm_vol');
if isempty(str)
    dirname = selectDir_gui(pwd,'Select SPM directory');
    if isempty(dirname),   error('Can''t find SPM');   end
    addpath(dirname);
end

global defaults
if isempty(defaults),   spm_defaults;   end


%% Add path of 'read_image_sm' (if needed):
str = which('read_image_sm');
if isempty(str)
    dir_name = selectDir_gui(pwd,'Select ''read_image_sm'' directory');
    if isempty(dir_name),   error('Can''t find ''read_image_sm''');  end
    addpath(dir_name);
end


%% Make index of voxels within ROIs:
fprintf('\nMaking index of voxels:\n');

inf          = spm_vol(file_list{1});
[nouse, xyz] = spm_read_vols(inf);

if isempty(rois_xyz)     % whole brain
    ind          = 1:size(xyz,2);
    D.xyz        = xyz;
    D.tvals      = NaN(1,size(xyz,2));
    D.rois_inds  = {ind};
    D.rois_names = {'WHOLE_BRAIN'};
else                % use ROI

    [nouse, ind] = ismember(rois_xyz',xyz','rows');
%   [nouse, ind] = ismemberMatrix(rois_xyz,xyz);
end


%% Read EPI files:
fprintf('\nReading EPI files:\n');

data = zeros(length(file_list),length(ind));
for itf=1:length(file_list)
    V = read_image_sm(file_list{itf});
    data(itf,:) = V(ind);
    
    fprintf('.');
    if mod(itf,60)==0
        fprintf('\n');
    end
end
D.data = data;

fprintf('\n');
