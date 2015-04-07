function file_path = fmri_saveMat(D, P)
%fmri_saveMat - saves 'D'ata and 'P'ars into [P.paths.to_mat P.output.file_name]
%file_path = fmri_saveMat(D, P)
%
% Input:
%   D                  - struct of 'D'ata
%   P                  - struct of 'P'arameters
%   P.paths.to_mat     - directory saved file
%   P.output.file_name - saved file name
%   P.output.save_ver  - option of 'save' command
% Output:
%   file_path          - path of saved file
%
% Created  By: Satoshi MURATA (1),  satoshi-m@atr.jp  08/09/18
% (1) ATR Intl. Computational Neuroscience Labs, Decoding Group


%% Check and get pars:
if exist('D','var')==0 || isempty(D)
    error('''D''ata-struct must be specified');
end
if exist('P','var')==0 || isempty(P)
    error('''P''ars-struct must be specified');
end

paths  = getFieldDef(P,'paths',[]);
output = getFieldDef(P,'output',[]);
if isempty(paths) || isempty(output)
    error('''P''ars -struct is wrong');
end

dir_name  = getFieldDef(paths,'to_mat','.');
file_name = getFieldDef(output,'file_name','matfile');
save_ver  = getFieldDef(output,'save_ver',7);

file_path = fullfile(dir_name, file_name);


%% Save:
fprintf('\nSaving:\n %s\n', file_path);

cmd = ['save ' file_path ' D P'];

switch save_ver
    case 6
        cmd = [cmd ' -v6'];
    case 7
        cmd = [cmd ' -v7'];
    case 7.3
        cmd = [cmd ' -v7.3'];
end

eval(cmd);
