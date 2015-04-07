function w_b = svmSinglePairWeights(data, labels) 
%svmSinglePairWeights - calculates weights and bias
%
% Input:
%   data   - 2D matrix of any data ([time(sample) x space(voxel/channel)] format)
%   labels - condition labels of each sample ([time x 1] format)
%             must be '1' and '-1'
% Output:
%   w_b    - weights and bias
%
% Calls:
%   OSU SVM, (c) >>>
%       PolySVC - Construct a non-linear SVM classifier with a polynomial kernel
%                 from the training Samples and Labels
%
% Original  By: Yukiyasu Kamitani (1),  kmtn@atr.jp
% Modified  By: Satoshi MURATA (1),     satoshi-m@atr.jp  08/10/02
% (1) ATR Intl. Computational Neuroscience Labs, Decoding Group


%% Check pars:
if exist('data','var')==0 || isempty(data) || exist('labels','var')==0 || isempty(labels)
    error('''data'' and ''labels'' must be specified');
end


%% Calc weights and bias:
% SVM train:
[AlphaY, SVs, Bias, Parameters, nSV, nLabel] = PolySVC(data',labels',1);

% Compute weights:
w = SVs * AlphaY';

w_b = nLabel(1) * [w; -Bias];

% w's norm=1
if norm(w)==0,      w_b(1:end-1) = zeros(size(w));
else                w_b          = w_b / norm(w);       end
