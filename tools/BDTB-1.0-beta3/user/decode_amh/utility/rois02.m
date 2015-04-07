fname = input('ROI name: ');

% ROI selection for SPM2
%
% 1) Display SPM results (glass brain and table) as usual
% 2) Select a cluster of interest by clicking its peak coordinate 
%    value (x,y,z {mm}) in the right column of the table 
%    -> the values will turn red, and a cursor on the glass brain (<)
%       will move to the peak of the cluster
% 3) Run this script in the window where you launched SPM 
%    Note: You need to attach single quotations 
%           to the ROI name (e.g., 'cerebellum').  
% 4) Coordinates and t-values of voxels in the cluster will 
%    be saved in the current directory (e.g., VOX_cerebellum.mat)
% 5) The cluster size and peak information in the saved data 
%     will be displayed so that you can check if the selection is correct.  
%
% 19 Apr, 2005  H.Imamizu

% find voxel IDs in the cluster of interest
[x,i] = spm_XYZreg('NearestXYZ',ans,xSPM.XYZmm) ;
A = spm_clusters(xSPM.XYZ) ;
C = find(A==A(i)) ;

% Make a matrix containing the voxel coordinates and T-values
eval(['VOX_' fname '= xSPM.XYZmm(:,C)']) ;
eval(['VOX_' fname '(4,:)= xSPM.Z(:,C)']) ;

% Check cluster size and peak
eval(['size(VOX_' fname ')' ]) 
eval(['max(VOX_' fname '(4,:))'])

% Save data
eval(['save VOX_' fname ' VOX_' fname])
















