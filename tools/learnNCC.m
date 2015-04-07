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

function [wMat] = learnNCC(paramWD, matData)

inDataAll = matData.inputData;
outDataAll = matData.outputData;

% to check number of trials are same between input and output
assert(size(inDataAll,1) == size(outDataAll,1), '# of trial num is different between input and output')

outNodeNum = size(outDataAll,2);

wMat = [];

% to estimate weight vector to express output node
for i = 1:outNodeNum
    
    if mod(i, 100) == 0
        fprintf('%d/%d have been finished to create NCC\n', i, outNodeNum);
    end
    
    inData = inDataAll;
    outData = outDataAll(:,i);
    
    [weight] = spReg(outData', inData');
    wMat = [wMat weight];
end

clear inDataAll outDataAll trialNum inNodeNum outNodeNum  inData outData weight i;
