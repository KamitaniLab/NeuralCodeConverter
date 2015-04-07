function weights = svm11linTrain(data, labels)
%svm11linTrain - calculates weights and bias
%
% Input:
%   data    - 2D matrix of any data ([time(sample) x space(voxel/channel)] format)
%   labels  - condition labels of each sample ([time x 1] format)
% Output:
%   weights - weights and bias
%
% Calls:
%   svmSinglePairWeights - calculates weights and bias for all pair by 'OSU SVM'
%
% Original  By: Yukiyasu Kamitani (1),  kmtn@atr.jp
% Modified  By: Satoshi MURATA (1),     satoshi-m@atr.jp  08/10/02
% (1) ATR Intl. Computational Neuroscience Labs, Decoding Group


%% Check pars:
if exist('data','var')==0 || isempty(data) || exist('labels','var')==0 || isempty(labels)
    error('''data'' and ''labels'' must be specified');
end


%% Calc weights:
used_conds = unique(labels);
weights    = zeros(size(data,2)+1,length(used_conds));

for itt=1:length(used_conds)        % target class
    target_class = used_conds(itt);
    
    weights_class = zeros(size(data,2)+1,length(used_conds));
    for itc=1:length(used_conds)    % compared class
        if itt~=itc
            compare_class = used_conds(itc);
            
            D    = struct('data',data,'labels',labels);
            pars = struct('conds',[target_class compare_class],'verbose',0);
            D    = selectConds(D,pars);
            
            labels_temp                          = D.labels;
            D.labels(labels_temp==target_class)  = 1;
            D.labels(labels_temp==compare_class) = -1;  % must be '-1'
            weights_bias                         = svmSinglePairWeights(D.data,D.labels);
            weights_class(:,itc)                 = weights_bias;
        end
    end
    
    weights_class(:,itt) = [];
    weights(:,itt)       = mean(weights_class,2);
end
