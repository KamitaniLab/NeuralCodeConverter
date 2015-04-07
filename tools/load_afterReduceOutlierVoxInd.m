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

function brainData = load_afterReduceOutlierVoxInd(sbjID, brainData)

fileName = ['./data/' sbjID '_outlierVoxInd.mat'];

load(fileName);

brainData.D.data = brainData.D.data(:,afterOutlierVoxInd);
brainData.D.xyz = brainData.D.xyz(:,afterOutlierVoxInd);
brainData.D.tvals = brainData.D.tvals(:,afterOutlierVoxInd);
