function [xyz, tvals, rois_inds, rois_names] = fmri_readRois(P)
%fmri_readRois - reads ROI files specified by P.rois
%[xyz, rois_names, rois_tvals] = fmri_readRois(P)
%
% Input:
%   P.rois.spm_ver   - SPM ver used for making ROI (default: 5)
%   P.rois.roi_dir   - directory of ROI
%   P.rois.roi_files - ROI names (and file name ends)
%                      if empty, use all voxels (whole brain)
%   P.paths.to_dat   - directory of data
% Output:
%   xyz              - X,Y,Z-coordinate value of voxels within ROI ([3(x,y,z) x space] format)
%   tvals            - t-value of voxels within ROI ([1 x space] format)
%   rois_inds        - indexes of each ROI for xyz and t-value ({same size as 'P.rois.roi_files'} format)
%   rois_names       - file names of ROI files ({same size as 'P.rois.roi_files'} format)
%
% Key:
%   xyz_each_file   = xyz(:,rois_inds{i});
%   tvals_each_file = tvals(rois_inds{i});
%
% Created  By: Satoshi MURATA (1),   satoshi-m@atr.jp  08/09/18
% Modified By: Satoshi MURATA (1),   satoshi-m@atr.jp  08/12/26
% Modified by: Yoichi Miyawaki (1),  yoichi_m@atr.jp   09/03/09
% (1) ATR Intl. Computational Neuroscience Labs, Decoding Group


%% Check and get pars:
if exist('P','var')==0 || isempty(P)
    error('''P''ars-struct must be specified');
end

paths = getFieldDef(P,'paths',[]);
if isempty(paths)
    error('''P''ars-struct is wrong');
end

rois  = getFieldDef(P,'rois',[]);
spm_ver   = getFieldDef(rois,'spm_ver',5);
roi_dir   = getFieldDef(rois,'roi_dir','.');
roi_files = getFieldDef(rois,'roi_files',{});
dir_name  = getFieldDef(paths,'to_dat','.');
if isempty(roi_files)
    fprintf('\nUse all voxels (whole brain):\n');
    xyz        = [];
    tvals      = [];
    rois_inds  = {};
    rois_names = {};
    return;
end

rois_names = roi_files;


%% Read ROI files:
xyz_files   = cell(size(rois_names));
tvals_files = cell(size(rois_names));

for itr=1:numel(roi_files)
    roi_file                = roi_files{itr};
    [nouse, file_name, ext] = fileparts(roi_file);
    if strcmp(ext,'.mat')~=1
        roi_file = [file_name '.mat'];
    end
    file_name = fullfile(dir_name,roi_dir,roi_file);
    if exist(file_name,'file')==0
 %       file_name = fullfile(dir_name,roi_dir,['VOX_' roi_file]);
        if exist(file_name,'file')==0,      error('Can''t find file: %s', file_name);   end
    end

    fprintf('\nReading ROI file:\n %s\n', file_name);
    
    roi        = load(file_name);
    field_name = fieldnames(roi);
    field_name = field_name{1};
    roi        = roi.(field_name);
    
    xyz_files{itr}   = roi(1:3,:);
    tvals_files{itr} = roi(4,:);
    
    if spm_ver==99
        xyz_files{itr}(1,:) = -xyz_files{itr}(1,:);
    end
    
    fprintf(' %d voxels found\n', size(roi,2));
end


%% Make indexes:
fprintf('\nMaking ROI indexes:\n');

num_voxels = zeros(size(xyz_files));
for itr=1:numel(xyz_files)
    num_voxels(itr) = size(xyz_files{itr},2);
end

xyz_all   = [xyz_files{:}];
tvals_all = [tvals_files{:}];
rois_inds = cell(size(xyz_files));

% [xyz, ind_in, ind_out] = uniqueMatrix(xyz_all(1:3,:));

[xyz, ind_in, ind_out] = unique(xyz_all(1:3,:)','rows');
xyz     = xyz';
ind_in  = ind_in';
ind_out = ind_out';

tvals = tvals_all(ind_in);

ind_head = 1;
for itr=1:numel(rois_inds)
    rois_inds{itr} = ind_out(ind_head:ind_head+num_voxels(itr)-1);
    ind_head       = ind_head + num_voxels(itr);
end
