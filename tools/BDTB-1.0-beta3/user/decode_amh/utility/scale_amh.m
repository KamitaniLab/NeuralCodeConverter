function B = scale_amh(A, bottom, top, dim)
%scale_amh - scales values of A between bottom and top, along dim
%B = scale_amh(A, bottom, top, dim)
%
% Scales min and max values of A between 'bottom' and 'top'.
% If dim=0 (default), scales all elements (via vectorization);
% if dim=n, scale along dim n.
%
% Input:
%   A      - matrix of any format, any dimension
% Optional:
%   bottom - min val of B (default: 0)
%   top    - max val of B (default: 1)
%   dim    - dimension of scaling (default: 0 - vectorize elements)
% Output:
%   B      - values of A scaled between bottom and top (or [0 1])
%
% Example:
%	>> A = [1 3 0 4; 5 6 10 8];
%	>> B = scale_amh(A, 0, 1)
%	B = 0.1  0.3    0  0.4
%	    0.5  0.6  1.0  0.8
%
% Created  By: Alex Harner (1),     alexh@atr.jp      06/04/14
% Modified By: Alex Harner (1),     alexh@atr.jp      06/11/17
% Modified By: Satoshi MURATA (1),  satoshi-m@atr.jp  08/10/17
% (1) ATR Intl. Computational Neuroscience Labs, Decoding Group


%% Check and get pars:
if exist('A','var')==0 || isempty(A)
    B = [];
    return;
end

if exist('bottom','var')==0 || isempty(bottom),     bottom = 0;     end
if exist('top','var')==0    || isempty(top),        top    = 1;     end
if exist('dim','var')==0    || isempty(dim),        dim    = 0;     end

% if bottom > top, swap them:
if bottom>top
    tmp    = bottom;
    bottom = top;
    top    = tmp;
end

% if dim > ndims(A), return A:
if dim>ndims(A)
    B = A;
    return;
end


%% Scale:
B = A;

if dim==0
    % scale all elements:
    B = B -  min(B(:));
    B = B ./ max(B(:));
    B = (top-bottom) .* B + bottom;
else
    % scale along dim:
    sz    = size(B);
    min_B = min(B,[],dim);
    sz_m  = size(min_B);
    if length(sz)~=length(sz_m)
        sz_m(end+1:length(sz)) = 1;
    end
    min_B = repmat(min_B,sz./sz_m);
    B     = B - min_B;
    max_B = repmat(max(B,[],dim),sz./sz_m);
    B     = B ./ max_B;
    B     = (top-bottom) .* B + bottom;
end
