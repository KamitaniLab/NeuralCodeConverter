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
% this program is to achieve signal preprocess
%
% Last modified by : Kentaro Yamada, HONDA R&D, on 2015/Mar/19th
%

function [dataLrn, dataTst, stimulusLabelTst] = preprocess(paramWD, sourceSbj, targetSbj)

% to load datat
input_lrn = load(['./data/' sourceSbj '_randomImage.mat']);
output_lrn = load(['./data/' targetSbj '_randomImage.mat']);
input_tst = load(['./data/' sourceSbj '_figureImage.mat']);
output_tst = load(['./data/' targetSbj '_figureImage.mat']);

% to do outliear reduction
if paramWD.reduceOutliersSwith == 1
    input_lrn = load_afterReduceOutlierVoxInd(sourceSbj, input_lrn);
    output_lrn = load_afterReduceOutlierVoxInd(targetSbj, output_lrn);
    input_tst = load_afterReduceOutlierVoxInd(sourceSbj, input_tst);
    output_tst = load_afterReduceOutlierVoxInd(targetSbj, output_tst);
end

% to do detrend process
if paramWD.detrendSwith == 1
    [input_lrn.D] = detrend_amh(input_lrn.D);
    [output_lrn.D] = detrend_amh(output_lrn.D);
    [input_tst.D] = detrend_amh(input_tst.D);
    [output_tst.D] = detrend_amh(output_tst.D);
end

% to do high-pass filter process
if paramWD.highpassSwith == 1
    pars.linear_detrend = 0;
    [input_lrn.D] = highPassFilter(input_lrn.D, pars);
    [output_lrn.D] = highPassFilter(output_lrn.D, pars);
    [input_tst.D] = highPassFilter(input_tst.D, pars);
    [output_tst.D] = highPassFilter(output_tst.D, pars);
end

inLrnAllLabelList = input_lrn.D.labels;
outLrnAllLabelList = output_lrn.D.labels;
inTstAllLabelList = input_tst.D.labels;
outTstAllLabelList = output_tst.D.labels;

runNumLrn = size(input_lrn.D.inds_runs,2);
runNumTst = size(input_tst.D.inds_runs,2);

% to convert luminance data to signal change data for 'rest' type
runNumLrn = size(input_lrn.D.inds_runs,2);
[input_lrn] = luminace2signalchangeByRest(paramWD, input_lrn, runNumLrn);
[output_lrn] = luminace2signalchangeByRest(paramWD, output_lrn, runNumLrn);
runNumTst = size(input_tst.D.inds_runs,2);
[input_tst] = luminace2signalchangeByRest(paramWD, input_tst, runNumTst);
[output_tst] = luminace2signalchangeByRest(paramWD, output_tst, runNumTst);

% to shift data to consider hemodynamic response delay
[inLrnIndexList, inLrnLabelList, tmp, tmp] = hrDelayShift(paramWD, input_lrn, inLrnAllLabelList, runNumLrn, []);
[outLrnIndexList, outLrnLabelList, tmp, tmp] = hrDelayShift(paramWD, output_lrn, outLrnAllLabelList, runNumLrn, []);
input_tst.D.inds_runs = [1;size(inTstAllLabelList, 1)];
output_tst.D.inds_runs = [1;size(outTstAllLabelList, 1)];
[tmp, tmp, inTstIndexList, inTstLabelList] = hrDelayShift(paramWD, input_tst, inTstAllLabelList, 1, 1);
[tmp, tmp, outTstIndexList, outTstLabelList] = hrDelayShift(paramWD, output_tst, outTstAllLabelList, 1, 1);

% to extract MRI scans to be processed
[dataLrn, dataTst] = extractScans2process(inLrnIndexList, inTstIndexList, input_lrn, output_lrn, input_tst, output_tst);

% to centerize data for 'rest' PSC type only for cca
[dataLrn.inputData, dataTst.inputData, tmp] = ceterizeByEachRun(dataLrn.inputData, dataTst.inputData, runNumLrn);
[dataLrn.outputData, dataTst.outputData, biousOfCenterizeLrn] = ceterizeByEachRun(dataLrn.outputData, dataTst.outputData, runNumTst);

% do blockAverage
[dataLrn, dataTst, inLrnLabelList, outLrnLabelList, inTstLabelList, outTstLabelList] = blockAverage(dataLrn, dataTst, inLrnLabelList, outLrnLabelList, inTstLabelList,outTstLabelList);

stimulusLabelTst.input = inTstLabelList;
stimulusLabelTst.output = outTstLabelList;