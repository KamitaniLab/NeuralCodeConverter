function filenames = selectFile_gui(exts, title, start_path, multi)
%selectFile_gui - outputs dialog-box to select file with GUI
%filenames = selectFile_gui(exts, multi, start_path, title)
%
% Optional:
%   exts       - filter of extensions to select file
%                specified by '*.<extension>' format (see help of'uigetfile' for more detail)
%   multi      - 0: can select ONLY ONE file, or 1: can select multi files
%                (default: 0)
%   start_path - selected directory when dialog outputs
%   title      - title of dialog
% Output:
%   filenames  - selected filename
%                return '', if click 'cancel' on dialog
%                return cell, if multi-files are selected
%
% Created  By: Satoshi MURATA (1),  satoshi-m@atr.jp  08/10/01
% (1) ATR Intl. Computational Neuroscience Labs, Decoding Group


%% Check and get pars:
if exist('exts','var')==0 || isempty(exts)
    exts = '';
end

if exist('title','var')==0 || isempty(title)
    if multi,       title = 'Select files';
    else            title = 'Select a file';        end
end
if exist('start_path','var') && isempty(start_path)==0
    cur_path = pwd;
    cd(start_path);
end

if exist('multi','var')==0 || isempty(multi)
    multi = 0;
end


%% Select files:
if multi,       [filenames, dirname] = uigetfile(exts,title,'MultiSelect','on');
else            [filenames, dirname] = uigetfile(exts,title);                       end

if iscellstr(filenames)
    num_files = length(filenames);
    for itf=1:num_files
        filenames{itf} = fullfile(dirname,filenames{itf});
    end
elseif filenames==0
    filenames = '';
else
    filenames = fullfile(dirname,filenames);
end


%% Change directory (if need):
if exist('cur_path','var') && isempty(cur_path)==0
    cd(cur_path);
end
