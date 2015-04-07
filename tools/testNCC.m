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
% this program is to test NCC
%
% Last modified by : Kentaro Yamada, HONDA R&D, on 2015/Mar/19th
%

function rslt = testNCC(dataTst, stimulusLabelTst, wMat)

% to do process on each sample (voxel)
testTrialNum = size(stimulusLabelTst.output, 1);

% to initialize matrix
rslt.answer = [];
rslt.predicted = [];
rslt.label = [];

for i = 1:testTrialNum
    
    predictedData = [];
    % to make models for each patch
    dataTstSingleSampleInputData = dataTst.inputData(i,:);
    answerData = dataTst.outputData(i,:);
    
    % to calculate the different subject brain data by using the weight vector 'wMat'
    predictedData = makePrediction(dataTstSingleSampleInputData, wMat);
    
    rslt.predicted = [rslt.predicted predictedData'];
    rslt.answer = [rslt.answer answerData'];
    rslt.label = [rslt.label stimulusLabelTst.input(i)];
    
end
