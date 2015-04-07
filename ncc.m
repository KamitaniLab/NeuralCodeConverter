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
% This program is to achieve Ågneural code conversion.Åh
% It converts one subjectÅfs brain activity pattern into anotherÅfs representing the same content.
%
% Last modified by : Kentaro Yamada, HONDA R&D, on 2015/Mar/19th
%

function ncc

% to add path for sparse regression
addpath(genpath('./tools'));

% to set parameter for brain prediction
[param] = paramSet;
   
sourceSbj = 'S2';
targetSbj = 'S1';
fprintf('Neural Code Conversion from %s to %s is achieved\n', sourceSbj, targetSbj)


%% preprocessing
[dataLrn, dataTst, stimulusLabelTst] = preprocess(param, sourceSbj, targetSbj);


%% lerning Neural Code Converter
wMat = learnNCC(param, dataLrn);


%% testing Neural Code Converter
rslt = testNCC(dataTst, stimulusLabelTst, wMat);


%% evaluation part
evaluateNCC(rslt)

clear all