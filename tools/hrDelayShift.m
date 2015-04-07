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

function [lrnIndexList, lrnLabelList, tstIndexList, tstLabelList] = hrDelayShift(paramWD, input, allLabelList, numOfRun, runIndex)

numOfTrialInRun = size(allLabelList,1)/numOfRun;
assert(mod(numOfTrialInRun, 1) == 0, 'numOfTrials are differnt run by run!!\n');

testedIndex = [input.D.inds_runs(1,runIndex) : input.D.inds_runs(2,runIndex)];
lrnedIndex = intersect(setxor([1:size(allLabelList,1)], testedIndex), [1:size(allLabelList,1)]);

% lrn
lrnIndexList = [];
lrnLabelList = [];
loopMax = size(lrnedIndex,2)/numOfTrialInRun;
assert(mod(loopMax, 1) == 0, 'something wrong in hrDelayShift function!\n');
for i = 1:loopMax

    runBeginIndex = lrnedIndex((i-1)*numOfTrialInRun+1);
    runEndIndex = lrnedIndex(i*numOfTrialInRun);

    pseudoLabel = zeros(paramWD.hrDelayLrn, 1);
    shiftedLabel = allLabelList(runBeginIndex:runEndIndex-paramWD.hrDelayLrn, :);
    shiftedLabel = [pseudoLabel ; shiftedLabel];

    label2lrn = allLabelList(runBeginIndex : runEndIndex - paramWD.hrDelayLrn);
    label2getRidOf = setdiff(label2lrn, paramWD.lrnLabels);
    index2getRidOfLabel = find(ismember(label2lrn, label2getRidOf));
    index2lrnLabel = setdiff([1:size(label2lrn,1)], index2getRidOfLabel);
    tmpLrnLable = label2lrn(index2lrnLabel);
    lrnLabelList = [lrnLabelList ; tmpLrnLable];

    index2getRidOfShiftedLabel = find(ismember(shiftedLabel,setdiff(shiftedLabel, paramWD.lrnLabels)) == 1);
    tmpLrnIndex = setdiff([1:numOfTrialInRun], index2getRidOfShiftedLabel) + runBeginIndex -1;
    lrnIndexList = [lrnIndexList ; tmpLrnIndex'];
end

assert(size(lrnLabelList, 1) == size(lrnIndexList, 1), 'something wrong in hrDelayShift function!!\n');

% tst
tstIndexList = [];
tstLabelList = [];
loopMax = size(testedIndex,2)/numOfTrialInRun;
assert(mod(loopMax, 1) == 0, 'something wrong in hrDelayShift function!\n');
for i = 1:loopMax

    runBeginIndex = testedIndex((i-1)*numOfTrialInRun+1);
    runEndIndex = testedIndex(i*numOfTrialInRun);

    pseudoLabel = zeros(paramWD.hrDelayTst, 1);
    shiftedLabel = allLabelList(runBeginIndex:runEndIndex-paramWD.hrDelayTst, :);
    shiftedLabel = [pseudoLabel ; shiftedLabel];

    label2tst = allLabelList(runBeginIndex : runEndIndex - paramWD.hrDelayTst);
    label2getRidOf = setdiff(label2tst, paramWD.tstLabels);
    index2getRidOfLabel = find(ismember(label2tst, label2getRidOf));
    index2tstLabel = setdiff([1:size(label2tst,1)], index2getRidOfLabel);
    tmpTstLable = label2tst(index2tstLabel);
    tstLabelList = [tstLabelList ; tmpTstLable];

    index2getRidOfShiftedLabel = find(ismember(shiftedLabel,setdiff(shiftedLabel, paramWD.tstLabels)) == 1);
    tmpTstIndex = setdiff([1:numOfTrialInRun], index2getRidOfShiftedLabel) + runBeginIndex -1;
    tstIndexList = [tstIndexList ; tmpTstIndex'];
end

assert(size(tstLabelList, 1) == size(tstIndexList, 1), 'something wrong in hrDelayShift function!!\n');

clear runBeginIndex runEndIndex pseudoLabel shiftedLabel label2lrn label2getRidOf index2getRidOfLabel
clear index2lrnLabel tmpLrnLable index2getRidOfShiftedLabel tmpLrnIndex label2tst index2tstLabel tmpTstLable tmpTstIndex