function path = fixPath(path_in, OS, root)
%fixPath - fixes pathes for the appropriate OS, converting slashes (\/)
%path = fixPath(path_in, OS, root)
%
% Input:
%   path_in  - path of directory or file
% Optional:
%   OS       - target OS for returned 'path'
%              OS = 0(UNIX, Mac), 1(Windows), same the return-value of 'ispc'
%   root     - root to be prepended to path_in
% Output:
%   path     - [root path_in] fixed for the current OS or given 'OS'
%
% Calls:
%   fixDirname - fixes dirname with pathes (for 'root')
%
% Example: (in UNIX)
%   >> path_in = 'alexh-docs\code\';    % a Windows path
%   >> path    = fixPath(path_in,0);    % 0 for UNIX; 1 for Windows
%   path = 'alexh-docs/code/
%
% Created  By: Alex Harner (1),     alexh@atr.jp      06/03/27
% Modified By: Alex Harner (1),     alexh@atr.jp      07/02/20
% Modified By: Satoshi MURATA (1),  satoshi-m@atr.jp  08/08/21
% (1) ATR Intl. Computational Neuroscience Labs, Decoding Group


%% Check and get pars:
if exist('path_in','var')==0 || isempty(path_in)
    path = [];
    return
end

if exist('OS','var')==0 || isempty(OS)
    OS = ispc;
end


%% Fix path:
path = path_in;

% If root present, prepend root to path_in:
if exist('root','var')
    root = fixDirname(root);
	path = [root path];
end

% Switch \ /, depending on OS:
if OS   % To Windows
	dx = findstr(path,'/');
	path(dx) = '\';
	% Change: /neo -> \\neo
    if path(1)=='\' && path(2)~='\'
        path = ['\' path];
    end
else
	% To UNIX/Mac
	% Change: \\neo -> /neo
    if strcmp(path(1:2),'\\')
		path(1) = [];
    end
	dx = findstr(path,'\');
	path(dx) = '/';
end
