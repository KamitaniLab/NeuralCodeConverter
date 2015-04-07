% --------------------------------------------------------
% Copyright (c) 2015 ATR Department of Neuroinformatics
%                    and Honda R&D Co.,Ltd
%                    Part of NeuralCodeConverter project
% 
% This work has been published in NeuroImage,
% http://www.journals.elsevier.com/neuroimage/
% 
% Released under the MIT license
% http://opensource.org/licenses/mit-license.php
% --------------------------------------------------------
% 
% this program is to evaluate NCC performance
%
% Last modified by : Kentaro Yamada, HONDA R&D, on 2015/Mar/19th
%

function evaluateNCC(rslt)

uniqueLabel = unique(rslt.label);
labelTypeNum = length(uniqueLabel);
crrAccum = [];
for i = 1:labelTypeNum
    index4thisLabel = find(rslt.label == uniqueLabel(i));
    for j = 1:length(index4thisLabel)
        index4ans = index4thisLabel(j);
        for k = 1:length(index4thisLabel)
            index4prd = index4thisLabel(k);
            crrTmp = corrcoef(rslt.answer(:,index4ans), rslt.predicted(:,index4prd));
            crrAccum = [crrAccum crrTmp(1,2)];
        end
    end
end
% fisher's zscore transform of voxel-wise correlation
zTranformedCrr = log((1+crrAccum)./(1-crrAccum))/2;
fprintf('Average voxel-wise correlation (converted into Fisher zscore) is %.3f\n\n', mean(zTranformedCrr));
