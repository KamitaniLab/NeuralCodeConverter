function [img, DIMS] = get_o_img(Fname, orient)
% Returns image named by 'Fname' in specified orientation,
% 'orient', where orient = 1 = x axis = sagittal, 
% orient = 2 = y axis = coronal, and 3 = z axis = axial.
% Returns whole image in 'img' matrix, with specified axis as
% rows, and plane data in columns, one plane for each row.
% DIMS returned are [DIM ORIGIN VOX] from header, each arranged 
% with plane dimension first, then down->up, then L->R dimensions

[img DIM VOX SCALE TYPE OFFSET ORIGIN] = read_image(Fname);

% Reshape according to orientation
if orient == 1   % x axis, sagittal
   img = reshape(img, DIM(1), prod(DIM(2:3)));
   dord = [1 2 3];
   transf = 1;
else
   if orient == 2
      img = reshape(img, DIM(1), prod(DIM(2:3)));
      img = reshape(img', DIM(2), prod(DIM([1 3])));
      dord = [2 3 1];
      transf = 0;
   else
      if orient ==3
         img = reshape(img, prod(DIM(1:2)), DIM(3))';
         dord = [3 1 2];
         transf = 1;
      else
         error('Orientation must be 1 - 3');
      end
   end
end

%Flip, if required
if transf
   DIMt = DIM(dord);
   for i = 1:DIMt(1)
      img(i, :) = reshape(reshape(img(i, :), DIMt(2), DIMt(3))', ...
         1, prod(DIMt(2:3)));
   end
   dord = dord([1 3 2]);
end

% Set new dimensions
DIMS = [DIM(dord) ORIGIN(dord) VOX(dord)];



