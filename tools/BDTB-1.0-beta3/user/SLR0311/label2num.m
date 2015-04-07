function [label_num, label_names, Nclass] = label2num(label);
% Create label vector consisting of the number from labels.
%  
% Note that elements of output labels starts from 1. 
%
% -- Usage
% [label_num, label_names, Nclass] = label2num(label)
%
% -- Example 
% > label = {'red', 'green', 'green', 'red'}
% > label_num = label2num(label)
% > [1; 2; 2; 1];
%
% -- Input
% label : label vector 
% 


if (ischar(label))
   label = cellstr(label);
end
if (size(label, 1) == 1)
   label = label';
end

%% 
label_names = unique(label);
Nclass = length(label_names);
Nsamp = length(label);

label_num = NaN * ones(Nsamp,1);

for ii = 1 : Nclass
    if iscell(label_names)
        ix = find(label == label_names{ii});
    else
        ix = find(label == label_names(ii));
    end
    
    label_num(ix) = ii;
    
end
    

