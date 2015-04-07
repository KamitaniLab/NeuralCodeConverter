function [D, pars] = fmri_selectRoi(D, pars)
%fmri_selectRoi - selects roi sets specified by 'rois_use'
%[D, pars] = fmri_selectRoi(D, pars)
%
% Given an array of cells containing ROI indexes (rois_inds) and a same sized cell array
% with 0 or 1 for cell use (rois_use), this returns the data within the selected ROI.
%
% Input:
%   D.rois_inds      - indexes of samples within each ROI ({same size as 'P.rois.roi_files'} format)
%   pars.rois_use    - cell array specifying use ROI (1), or not (0)
% Optional:
%   pars.remove_dups - remove duplications? 0=no, 1=yes (default: 1)
%   pars.and_only    - and/intersection of rois_use? 0=intersection, 1=and (default: 1)
%   pars.verbose     - [1..3] print detail level 0=no printing (default: 1)
% Output:
%   D.data           - data within the selected ROI ([time(sample) x space(voxel/channel)] format)
%   D.xyz            - X,Y,Z-coordinate values within the selected ROI ([3(x,y,z) x space] format)
%   D.tvals          - t-values within the selected ROI ([1 x space] format)
%
% Created  By: Alex Harner (1),    alexh@atr.jp      06/04/18
% Modified By: Alex Harner (1),    alexh@atr.jp      06/09/12
% Modified By: Satoshi MURATA (1), satoshi-m@atr.jp  08/09/22
% (1) ATR Intl. Computational Neuroscience Labs, Decoding Group


%% Check and get pars:
if exist('D','var')==0 || isempty(D)
    error('''D''ata-struct must be specified');
end
if exist('pars','var')==0       pars = [];      end

rois_size   = size(D.rois_inds);
if isfield(pars,mfilename)      % unnest, if needed
    P    = pars;
    pars = P.(mfilename);
end
rois_use    = getFieldDef(pars,'rois_use',[]);
remove_dups = getFieldDef(pars,'remove_dups',1);
and_only    = getFieldDef(pars,'and_only',1);
verbose     = getFieldDef(pars,'verbose',1);

% If 'rois_use' is absent, use all rois:
if isempty(rois_use)
    rois_use    = cell(rois_size);
    rois_use{:} = 1;
end


%% For UI:
if verbose,     fprintf(['\n' mfilename ' ------------------------------']);     end


%% Select ROIs:
if and_only
    inds_use = [D.rois_inds{find([rois_use{:}])}];
else
    inds_use = [];
    for itr=1:prod(rois_size)
        if rois_use{itr}
            if isempty(inds_use)
                inds_use = D.rois_inds{itr};
            else
                temp_inds = ismember(inds_use, D.rois_inds{itr});
                if isempty(temp_inds)
                    inds_use = [];
                    break;
                else
                    inds_use = inds_use(temp_inds);
                end
            end
        end
    end
end
num_use = length(inds_use);

if remove_dups
    inds_use = unique(inds_use);
    num_uni  = length(inds_use);
end

num_all = length([D.rois_inds{:}]);


%% Select data within ROIs:
D.data  = D.data(:,inds_use);
D.xyz   = D.xyz(:,inds_use);
D.tvals = D.tvals(inds_use);

for itr=1:prod(rois_size)
    [tf, loc]               = ismember(D.rois_inds{itr},inds_use);
    D.rois_inds{itr}(tf)    = loc(tf);
    D.rois_inds{itr}(tf==0) = [];
end

%% User feedback:
if verbose
    fprintf('\n %d selected out of %d total voxels\n', num_use, num_all);
    if remove_dups,     fprintf(' Duplicates removed: %d\n', num_use-num_uni);      end
end


%% For 'P'ars-struct
if exist('P','var')
    P.(mfilename) = pars;
end
