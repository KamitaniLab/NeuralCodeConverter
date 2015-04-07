function view_img
% Selects then views an image using view_planes.m

P = spm_get(1, 'img', 'Select an image to view');
if ~isempty(P)
   view_planes(P)
end