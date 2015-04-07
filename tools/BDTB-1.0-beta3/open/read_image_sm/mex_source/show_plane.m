function show_plane(img, DIMS, vplane, prescaled, fig)
% Displays images from img matrix img in cuts of orientation
% specified when img was created.  DIM is 3 vector with
% DIMS(1) = plane dimension, and 2, 3 are Down->Up, L->R dimensions
% Equivalently for ORIGIN, VOX, part of DIMS (= [DIM ORIGIN VOX])
% gives plane for voxel vplane (in appropriate dimension)
% prescaled is flag for whether img is already scaled to colormap
% if prescaled is 0, colormap is set, and plane scaled to img max
% fig is figure handle

if nargin < 3 
   error('Not enough arguments')
else if nargin < 4
      prescaled = 0;
   else if nargin < 5
         % Make new display window
         fig = figure('Name', 'Plane viewer');
      else
         figure(fig)
      end
   end
end

% Get data
plane = reshape(img(vplane, :), DIMS(2), DIMS(3));

% Axes and display
if ~prescaled
   clf
   colormap('bone');
   % Correct for unequal voxel size
   set(gcf,'Units','pixels')
   winsz = get(gcf,'Position');
   WIN = winsz(3:4);                    % Width, height in pixels
   i_dims = DIMS([3 2]) .* DIMS([9 8]);   % Dimensions of image in mm
   scfs = WIN * 0.85 ./ i_dims ;        % Pixels per mm for each dimension
   pixdims = round(min(scfs) * i_dims); % scale to most crunched dimension
   origins = (WIN - pixdims) / 2;       % Centre image
   axes( 'Units', 'pixels',...
      'position', [origins pixdims] );
   % Scale numbers to colormap
   mx = max(max(img));
   plane = (plane / mx) * size(colormap, 1);
end

% Display
image(plane);
axis xy;
xlabel 'Voxels'
ylabel 'Voxels'




