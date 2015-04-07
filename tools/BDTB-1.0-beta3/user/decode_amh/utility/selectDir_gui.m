function dirname = selectDir_gui(start_path, title)
%selectDir_gui - outputs dialog-box to select directory with GUI
%dirname = selectDir_gui(start_path, title)
%
% Optional:
%   start_path - selected directory when dialog outputs
%   title      - title of dialog
% Output:
%   dirname    - selected directory
%                return '', if click 'cancel' on dialog
%
% Created  By: Satoshi MURATA (1),  satoshi-m@atr.jp  08/09/18
% (1) ATR Intl. Computational Neuroscience Labs, Decoding Group


%% Check and get pars:
if exist('start_path','var')==0 || isempty(start_path)
    start_path = pwd;
end

if exist('title','var')==0 || isempty(title)
    title = 'Select a directory';
end


%% Select a directory:
dirname = uigetdir(start_path, title);

if dirname==0   % click 'cancel'
    dirname = '';
else
    dirname = fixDirname(dirname);
end
