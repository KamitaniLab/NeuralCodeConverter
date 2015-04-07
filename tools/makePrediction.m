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

function [predictedData] = makePrediction(testInputData, wMat)

predictedData = [];
outNodeNum = size(wMat,2);
for nodeInd = 1:outNodeNum
    testInputDataTmp = testInputData';
    % Time alignment for prediction using embedding input
    [tx,ty] = pred_time_index(testInputDataTmp, wMat(1,nodeInd).parm);
    testInputDataTmp = testInputDataTmp(:,tx,:);
    % Use normalization constant calculated by training data
    testInputDataTmp = normalize_data(testInputDataTmp, wMat(1,nodeInd).parm.data_norm, wMat(1,nodeInd).parm);
    [M, Tx, Ntrial] = size(testInputDataTmp);
    T = Tx - (wMat(1,nodeInd).D-1)*wMat(1,nodeInd).tau;
    testInputDataTmp  = testInputDataTmp(wMat(1, nodeInd).ix,:,:);
    predictedOneNode = weight_out_delay_time(testInputDataTmp, wMat(1, nodeInd).W, T, wMat(1, nodeInd).tau);
    if isfield(wMat(1, nodeInd).parm,'ynorm') && ~isempty(wMat(1, nodeInd).parm.ynorm)
        predictedOneNode = predictedOneNode .* repmat(wMat(1, nodeInd).parm.ynorm, [1 T Ntrial]);
    end
    if isfield(wMat(1, nodeInd).parm,'ymean') && ~isempty(wMat(1, nodeInd).parm.ymean)
        predictedOneNode = predictedOneNode + repmat(wMat(1, nodeInd).parm.ymean, [1 T Ntrial]);
    end
    predictedData = [predictedData predictedOneNode];
end

