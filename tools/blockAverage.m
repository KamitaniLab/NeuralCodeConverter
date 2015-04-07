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

function [dataLrn, dataTst, inLrnLabelList, outLrnLabelList, inTstLabelList,outTstLabelList] = blockAverage(dataLrn, dataTst, inLrnLabelList, outLrnLabelList, inTstLabelList,outTstLabelList)

% process for lrn
blockAverageBeginInd = find(inLrnLabelList - [0 ;inLrnLabelList(1:end-1)] ~= 0);
blockAverageEndInd = find(inLrnLabelList - [inLrnLabelList(2:end) ; 0] ~= 0);
gap = min(blockAverageEndInd - blockAverageBeginInd);
blockAverageBeginInd = [blockAverageBeginInd(1):gap+1:size(inLrnLabelList,1)]';
blockAverageEndInd = blockAverageBeginInd + gap;
tmpBlockNum = size(blockAverageBeginInd,1);
accumLabelIn = [];
accumDataIn = [];
accumLabelOut = [];
accumDataOut = [];
for tmpInd = 1:tmpBlockNum
    % for input
    tmpLabel = mean(inLrnLabelList(blockAverageBeginInd(tmpInd):blockAverageEndInd(tmpInd)),1);
    assert(mod(tmpLabel,1) == 0, 'something wrong in averaging');
    accumLabelIn = [accumLabelIn ; tmpLabel];
    tmpData = mean(dataLrn.inputData(blockAverageBeginInd(tmpInd):blockAverageEndInd(tmpInd),:),1);
    accumDataIn = [accumDataIn ; tmpData];
    % for output
    tmpLabel = mean(outLrnLabelList(blockAverageBeginInd(tmpInd):blockAverageEndInd(tmpInd)),1);
    assert(mod(tmpLabel,1) == 0, 'something wrong in averaging');
    accumLabelOut = [accumLabelOut ; tmpLabel];
    tmpData = mean(dataLrn.outputData(blockAverageBeginInd(tmpInd):blockAverageEndInd(tmpInd),:),1);
    accumDataOut = [accumDataOut ; tmpData];
end
inLrnLabelList = accumLabelIn;
dataLrn.inputData = accumDataIn;
outLrnLabelList = accumLabelOut;
dataLrn.outputData = accumDataOut;

% process for tst
blockAverageBeginInd = find(inTstLabelList - [0 ;inTstLabelList(1:end-1)] ~= 0);
blockAverageEndInd = find(inTstLabelList - [inTstLabelList(2:end) ; 0] ~= 0);
gap = min(blockAverageEndInd - blockAverageBeginInd);
blockAverageBeginInd = [blockAverageBeginInd(1):gap+1:size(inTstLabelList,1)]';
blockAverageEndInd = blockAverageBeginInd + gap;
tmpBlockNum = size(blockAverageBeginInd,1);
accumLabelIn = [];
accumDataIn = [];
accumLabelOut = [];
accumDataOut = [];
for tmpInd = 1:tmpBlockNum
    % for input
    tmpLabel = mean(inTstLabelList(blockAverageBeginInd(tmpInd):blockAverageEndInd(tmpInd)),1);
    assert(mod(tmpLabel,1) == 0, 'something wrong in averaging');
    accumLabelIn = [accumLabelIn ; tmpLabel];
    tmpData = mean(dataTst.inputData(blockAverageBeginInd(tmpInd):blockAverageEndInd(tmpInd),:),1);
    accumDataIn = [accumDataIn ; tmpData];
    % for output
    tmpLabel = mean(outTstLabelList(blockAverageBeginInd(tmpInd):blockAverageEndInd(tmpInd)),1);
    assert(mod(tmpLabel,1) == 0, 'something wrong in averaging');
    accumLabelOut = [accumLabelOut ; tmpLabel];
    tmpData = mean(dataTst.outputData(blockAverageBeginInd(tmpInd):blockAverageEndInd(tmpInd),:),1);
    accumDataOut = [accumDataOut ; tmpData];
end
inTstLabelList = accumLabelIn;
dataTst.inputData = accumDataIn;
outTstLabelList = accumLabelOut;
dataTst.outputData = accumDataOut;
