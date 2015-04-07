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

function [data] = luminace2signalchangeByRest(paramWD, data, numOfRun)

numOfTrialInRun = size(data.D.data,1)/numOfRun;
assert(mod(numOfTrialInRun, 1) == 0, 'numOfTrials are differnt run by run!!\n');

for i = 1:numOfRun

    runBeginIndex = (i-1)*numOfTrialInRun+1;
    runEndIndex = i*numOfTrialInRun;
    
    baselineVols = paramWD.baselineVols + (runBeginIndex - 1);
    
    dataBaseline = data.D.data(baselineVols,:);

    dataBaseline = repmat(mean(dataBaseline,1), numOfTrialInRun, 1);
    data.D.data([runBeginIndex : runEndIndex], :) = (data.D.data([runBeginIndex : runEndIndex], :) - dataBaseline) ./ dataBaseline;
end

% if strcmp(paramWD.expType,'randomCenter4') || strcmp(paramWD.expType,'figure') ||...
%    strcmp(paramWD.expType,'neuroSmall') || strcmp(paramWD.expType,'figure1by1')
%     if paramWD.dcSignalAddFlag == 0 
%         data = data * 100;
%     end
% end


clear i baselineVols dataBaseline
