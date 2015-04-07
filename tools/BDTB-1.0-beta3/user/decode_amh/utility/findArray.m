%findArray - search [n x 1] array from [n x m] matrix
%ind = findArray(array, matrix, num_inds, first)
%
% Input:
%   array    - target array
%   matrix   - group of array
% Optional:
%   num_inds - number of returned index
%              if absent, return all indexes
%   first    - from 'first' (1, default), or not (0)
% Output:
%   ind      - result index
%              if don't find, return empty matrix
%
% Example:
%   >> array  = [1 3 2]';
%   >> matrix = [1 1 1; 1 2 1; 1 3 2; 1 2 2; 3 2 2; 1 1 3; 1 3 2]';
%   >> ind = findArray(A, B)
%   ind = [3 7]
%   >> ind    = findArray(A, B, 1)
%   ind = 3
%   >> ind    = findArray(A, B, [], 0)
%   ind = [7 3]
% 
% Created By: Satoshi MURATA (1),  satoshi-m@atr.jp  08/09/19
% (1) ATR Intl. Computational Neuroscience Labs, Decoding Group


%-This is merely the help file for the compiled routine
error('findArraySub.c not compiled');
