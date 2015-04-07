function [out_matrix, ind_in, ind_out] = uniqueMatrix(in_matrix)
%uniqueMatrix - extended 'unique' to matrix
%[out_matrix, ind_in, ind_out] = uniqueMatrix(in_matrix)
%
% Input:
%   in_matrix  - input matrix
%                if coordinate, [2 x num_pixel] / [3 x num_voxel]
% Output:
%   out_matrix - output matrix
%   ind_in     - indexes for in_matrix
%   ind_out    - indexed for out_matrix
%
% Calls:
%   findArray - search array from marix
%
% Example:
%   >> in_matrix = [1 1 1; 1 2 1; 1 3 2; 1 2 2; 1 3 2; 1 2 1; 1 1 3; 1 3 2]'
%     1   1   1   1   1   1   1   1
%     1   2   3   2   3   2   1   3
%     1   1   2   2   2   1   3   2
%   >> [out_matrix, ind_in, ind_out] = uniqueMatrix(in_matrix);
%   out_matrix = 
%     1   1   1   1   1
%     1   2   3   2   1
%     1   1   2   2   3
%   ind_in  = [1 2 3 4 7]
%   ind_out = [1 2 3 4 3 2 5 3]
%
% Created  By: Satoshi MURATA (1),  satoshi-m@atr.jp  08/09/17
% (1) ATR Intl. Computational Neuroscience Labs, Decoding Group


%% Check and get pars:
if exist('in_matrix','var')==0 || isempty(in_matrix)
    out_matrix = [];
    ind_in     = [];
    ind_out    = [];
    return;
end

dim = size(in_matrix);
if length(dim)~=2,      error('Dimension of ''in_matrix'' must be 2');    end


%% Initialize vars:
ind_out    = zeros(1,dim(2));

out_matrix = zeros(dim);
ind_in     = zeros(1,dim(2));


%% Apply 'unique':
num_unique = 1;
for its=1:dim(2)
    if ind_out(its)==0      % not duplicate
        out_matrix(:,num_unique) = in_matrix(:,its);
        ind_out(its)             = num_unique;
        ind_in(num_unique)       = its;
        
        if its<dim(2)
            temp_ind = findArray(in_matrix(:,its),in_matrix(:,its+1:end));
            if isempty(temp_ind)~=1
                ind_out(temp_ind+its) = num_unique;
            end
        end

        num_unique = num_unique+1;
    end
end

out_matrix(:,num_unique:end) = [];
ind_in(num_unique:end)       = [];
