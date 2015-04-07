function [freq_table, correct_per] = freqTableFromLabels(labels, preds)
%freqTableFromLabels - creates a frequency table given correct ahd predicted labels
%[freq_table, correct_per] = freqTableFromLabels(labels, preds)
%
% Inputs:
%	labels      - correct labels array
%	preds       - prediction labels array
%
% Outputs:
%	freq_table  - frequency table; [# nConds x # nConds] matrix showing
%	              the number of a predicted condition (column) for a given test
%	              condition (row), in which values along the eye are numbers
%	              correct for each condition.
%	correct_per - total percent correct rate
%
% Original  By: Yukiyasu Kamitani (1), kmtn@atr.jp       04/04/14?
% Rewritten By: Alex Harner (1),       alexh@atr.jp      06/07/18
% Modified  By: Alex Harner (1),       alexh@atr.jp      07/02/21
% Modified  By: Satoshi MURATA (1),    satoshi-m@atr.jp  08/10/03
% (1) ATR Intl. Computational Neuroscience Labs, Decoding Group


%% Check and get pars:
if exist('labels','var')==0 || isempty(labels) || exist('preds','var')==0 || isempty(preds)...
        || length(labels)~=length(preds)
    error('Wrong args');
end

num_labels = length(labels);
conds      = unique(labels);
num_conds  = length(conds);


%% Make the table:
freq_table = zeros(num_conds);
if num_labels>num_conds*num_conds
    for itl=1:num_conds
        for itp=1:num_conds
            inds_match          = find(labels==conds(itl)&preds==conds(itp));
            freq_table(itl,itp) = freq_table(itl,itp) + length(inds_match);
        end
    end
else
    for itl=1:num_labels
        ind_l                   = find(conds==labels(itl));
        ind_p                   = find(conds==preds(itl));
        freq_table(ind_l,ind_p) = freq_table(ind_l,ind_p) + 1;
    end
end


%% Calc percent correct:
sum_ft = sum(freq_table(:));
if sum_ft>0,    correct_per = 100 * sum(diag(freq_table)) / sum_ft;
else            correct_per = 0;
end
