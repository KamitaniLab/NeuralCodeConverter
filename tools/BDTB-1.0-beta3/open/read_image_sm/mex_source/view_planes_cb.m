function view_planes_cb( param, options )
% Function services callback routines from view_planes
%
% Note that these routines take the lazy way out, and
% reload the image from disk if the orientation is changed.
% Could be done better, but it would be a bit of a bore

if nargin < 1 
   error('Need at least 1 parameter')
else
   if nargin < 2
      options = 0;
   end
end

% General stuff
ctls = get(gcf, 'UserData');

if strcmp(param, 'LoadData')
% Loads image in specified orientation  
   
[vp_img, vp_DIMS] = get_o_img(...
   get(ctls(1), 'UserData'),...
   get(ctls(5), 'Value'));

% Scale to colormap
mx = max(max(vp_img));
vp_img = (vp_img / mx) * size(...
   get(get(ctls(7), 'UserData'), 'colormap'), 1);

% Make sure origin is sensible
if vp_DIMS(4) < 1 | vp_DIMS(4) > vp_DIMS(1)
   def = round(vp_DIMS(1) / 2);
else
   def = vp_DIMS(4);
end

set(ctls(4), 'Max', vp_DIMS(1), 'Value', def)
v = version;
if v(1) == '5'
   set(ctls(4),	'SliderStep', [1/vp_DIMS(1) 10/vp_DIMS(1)]);
end
set(ctls(2), 'UserData', vp_img);
set(ctls(6), 'UserData', vp_DIMS);

view_planes_cb('SetPlane');
view_planes_cb('ShowPlane', 0);

else if strcmp(param, 'CheckPlane')
% Check if sensible value from text box, and set slider
plane = round(str2num(get(ctls(6), 'String')));
DIM = get(ctls(6), 'UserData');
% ?Sensible value
if plane > DIM(1)
   plane = DIM(1);
   set(ctls(6), 'String', num2str(plane));
else
   if plane < 1
      plane = 1;
      set(ctls(6), 'String', num2str(plane));
   end
end
% set slider value
set(ctls(4), 'Value', str2num(get(ctls(6), 'String')));

else if strcmp(param, 'SetPlane')
% set plane edit box value
set(ctls(6), 'String', num2str(round(get(ctls(4), 'Value'))));

else if strcmp(param, 'ShowPlane')
% Show plane in figure   
show_plane(...
   get(ctls(2), 'UserData'), ...
   get(ctls(6), 'UserData'), ...
   round(str2num(get(ctls(6), 'String'))), ...
   options,...
   get(ctls(7), 'Userdata')...
   );

else if strcmp(param, 'Quit')
% Close both figure windows      
f = gcf;
figure(get(ctls(7), 'UserData'));
close;
close(f);

else
   error(['Unexpected parameter ' param])
end
end
end
end
end
