function path = fixMkDir(path_in)
%fixMkDir - fixes a dir path and makes it if it doesn't exist
%
% Input:
%   path_in  - any path directory (to a folder) (in Win or Unix)
% Output:
%   path     - path fixed for the current OS
%
% Calls:
%   fixDirname - fixes dirname with pathes
%
% Created  By: Alex Harner (1),     alexh@atr.jp      07/02/09
% Modified By: Alex Harner (1),     alexh@atr.jp      07/02/09
% Modified By: Satoshi MURATA (1),  satoshi-m@atr.jp  08/08/21
% (1) ATR Intl. Computational Neuroscience Labs, Decoding Group


%% Check and get pars:
if exist('path_in','var')==0 || isempty(path_in)
    path = [];
    return;
end


%% Fix dirname:
path = fixDirname(path_in);


%% Make directory
if exist(path,'dir')==0
	mkdir(path);
end
