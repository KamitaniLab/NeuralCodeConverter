function res = resultsSummary(res)
%Finds freq_table and correct_per from results structs, and add them at the end of 'res'
%res = resultsSummary(res)
%
% Inputs:
%   res{}.preds            - predicted labels
%   res{}.labels           - correct labels
%
% Output:
%   res{:,end}.freq_table  - frequency table; [# nConds x # nConds] matrix 
%	res{:,end}.correct_per - total percent correct rate
%
% Created  By: Alex Harner (1),     alexh@atr.jp      06/10/26
% Modified By: Alex Harner (1),     alexh@atr.jp      06/10/30
% Modified By: Satoshi MURATA (1),  satoshi-m@atr.jp  08/10/03
% (1) ATR Intl. Computational Neuroscience Labs, Decoding Group


%% Check and get pars:
if exist('res','var')==0 || isempty(res),       error('Wrong vars');        end

[num_models, num_dataset] = size(res);
num_preds_data            = length(res{1}.preds);


%% Make res all:
preds  = zeros(num_dataset*num_preds_data,num_models);
labels = zeros(num_dataset*num_preds_data,1);

for itd=1:num_dataset
    labels((itd-1)*num_preds_data+1:itd*num_preds_data) = res{1,itd}.labels;
    
    for itm=1:num_models
        preds((itd-1)*num_preds_data+1:itd*num_preds_data,itm) = res{itm,itd}.preds;
    end
end



%% Calc summary
freq_table  = cell(num_models,1);
correct_per = cell(num_models,1);
for itm=1:num_models
    [freq_table{itm}, correct_per{itm}] = freqTableFromLabels(labels,preds(:,itm));
end


%% Add summary
res = [res cell(num_models,1)];
for itm=1:num_models
    model = res{itm,1}.model;
    
    res{itm,end} = struct('model',model,'preds',preds(:,itm),'labels',labels,...
                          'freq_table',freq_table{itm},'correct_per',correct_per{itm});
end
