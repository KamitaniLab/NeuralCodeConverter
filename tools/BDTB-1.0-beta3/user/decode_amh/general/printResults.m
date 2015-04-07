function printResults(res)
%printResults - prints results with freq_table and correct_per
%printResults(res)
%
% Input:
%	res        - some result containing 'freq_table' and 'correct_per'
%
% Original  By: Yukiyasu Kamitani (1), kmtn@atr.jp       ?
% Rewritten By: Alex Harner (1),       alexh@atr.jp      06/08/02
% Modified  By: Alex Harner (1),       alexh@atr.jp      06/08/31
% Modified  By: Satoshi MURATA (1),    satoshi-m@atr.jp  08/10/06
% (1) ATR Intl. Computational Neuroscience Labs, Decoding Group


%% Check and get pars:
if exist('res','var')==0 || isempty(res),       error('Wrong args');        end
if size(res,2)~=1,                              res = res(:,end);           end

num_model   = size(res,1);
freq_table  = cell(num_model,1);
correct_per = cell(num_model,1);
for itm=1:num_model
    freq_table{itm,1}  = getFieldDef(res{itm,1},'freq_table',[]);
    correct_per{itm,1} = getFieldDef(res{itm,1},'correct_per',[]);
    
    if isempty(freq_table{itm,1}) || isempty(correct_per{itm,1}),   error('Wrong args');    end
end


%% Print results:
for itm=1:num_model
    fprintf('\nResults *************************');
    if num_model>1,     fprintf('\n Model: %s',res{itm,1}.model);   end
    fprintf('\n Percent Correct: %6.2f',correct_per{itm,1});
    fprintf('\n Frequency Table:\n');
    fprintf(['  ' repmat('%4d ', 1, size(freq_table{itm,1},2)) '\n'], freq_table{itm,1}');
end
