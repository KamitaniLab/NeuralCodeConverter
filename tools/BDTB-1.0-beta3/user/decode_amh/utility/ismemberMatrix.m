%ismemberMatrix - checks that arrays in source is also contained in target
%[tf, inds] = ismemberMatrix(source, target)
%
% Input:
%   source - group of array, [m x n] matrix
%   target - group of array, [m x t] matrix
% Output:
%   tf     - return 1: contained, or 0: not contained
%            [1 x n] array
%   inds   - return index, if contained
%            [1 x n] array
%
% Example:
%   >> source     = [1 1 1; 1 1 2; 1 2 3; 1 3 2]';
%   >> target     = [1 1 1; 1 2 1; 1 3 2; 1 3 3; 1 1 1; 1 2 3; 2 3 1]';
%   >> [tf, inds] = ismemberMatrix(source, target)
%   tf   = [1   0   1   1]
%   inds = [1   0   6   3]
%
% Created  By: Satoshi MURATA (1),  satoshi-m@atr.jp  08/09/19
% (1) ATR Intl. Computational Neuroscience Labs, Decoding Group


%-This is merely the help file for the compiled routine
error('findArraySub.c not compiled');
