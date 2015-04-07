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
% Last modified by : Kentaro Yamada, HONDA R&D, on 2015/Mar/19th
%

function [lrnData, tstData, biousData] = ceterizeByEachRun(lrnData, tstData, numOfRun)

numOfTrialInRun = size(lrnData,1)/numOfRun;
assert(mod(numOfTrialInRun, 1) == 0, 'numOfTrials are differnt run by run!!\n');

biousData = [];

for i = 1:numOfRun

    runBeginIndex = (i-1)*numOfTrialInRun+1;
    runEndIndex = i*numOfTrialInRun;
    lrnDataDataPartial = lrnData(runBeginIndex:runEndIndex, :);

    lrnDataMeanData = mean(lrnDataDataPartial,1);
    lrnDataDataPartial = lrnDataDataPartial - repmat(lrnDataMeanData, size(lrnDataDataPartial, 1), 1);

    lrnData(runBeginIndex:runEndIndex, :) = lrnDataDataPartial;

    biousData = [biousData ; lrnDataMeanData(1,:)];
end
biousData= mean(biousData, 1);

tstData = tstData - repmat(biousData, size(tstData, 1), 1);

clear runBeginIndex runEndIndex lrnDataDataPartial tstDataDataPartial lrnDataMeanData tstDataMeanData