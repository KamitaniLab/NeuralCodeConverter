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

function [dataLrn, dataTst] = highpassProcess(paramWD, dataLrn, dataTst, runNumLrn)

if paramWD.highpassSwith == 1
    
    % for Lrn
    numInRun = size(dataLrn.inputData,1)/runNumLrn;
    tmp.D.inds_runs = [];
    for tmpInd = 1:runNumLrn
        inds = [(tmpInd-1)*numInRun+1 ; tmpInd*numInRun];
        tmp.D.inds_runs = [tmp.D.inds_runs inds];
    end
    
    tmp.D.data = dataLrn.inputData;
    [tmp.D] = highPassFilter(tmp.D);
    dataLrn.inputData = tmp.D.data;
    
    tmp.D.data = dataLrn.outputData;
    [tmp.D] = highPassFilter(tmp.D);
    dataLrn.outputData = tmp.D.data;


    % for Tst
    numInRun = size(dataTst.inputData,1);
    tmp.D.inds_runs = [1 ; numInRun];
    
    tmp.D.data = dataTst.inputData;
    [tmp.D] = highPassFilter(tmp.D);
    dataTst.inputData = tmp.D.data;
    
    tmp.D.data = dataTst.outputData;
    [tmp.D] = highPassFilter(tmp.D);
    dataTst.outputData = tmp.D.data;
end
