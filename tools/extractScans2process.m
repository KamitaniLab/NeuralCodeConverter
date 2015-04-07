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
% to extract MRI scans to be processed
%
% Last modified by : Kentaro Yamada, HONDA R&D, on 2015/Mar/19th
%

function [dataLrn, dataTst] = extractScans2process(lrnIndexList, tstIndexList, input_lrn, output_lrn, input_tst, output_tst)

dataLrn.inputData = input_lrn.D.data(lrnIndexList, :);
dataLrn.outputData = output_lrn.D.data(lrnIndexList, :);
dataTst.inputData = input_tst.D.data(tstIndexList, :);
dataTst.outputData = output_tst.D.data(tstIndexList, :);

clear lrnIndexList tstIndexList