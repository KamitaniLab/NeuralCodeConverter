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

function [paramWD] = paramSet

% to specify percent signal change type
paramWD.baselineVols = [1:10]+2;

% to define switch of detrend
paramWD.reduceOutliersSwith = 1; % 0 or 1

% to define switch of detrend
paramWD.detrendSwith = 1; % 0 or 1

% to define switch of highpass filtering
paramWD.highpassSwith = 1; % 0 or 1

% to set hemodynamic response delay
paramWD.hrDelayLrn = 2; % scans
paramWD.hrDelayTst = 2; % scans

% to specify labels for learning
paramWD.lrnLabels = [1001 : 1440]; % for random images

% to specify labels for test
paramWD.tstLabels = [2001 : 2005]; % for figure images

