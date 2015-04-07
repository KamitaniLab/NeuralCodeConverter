function dirname = fixDirname(dirname_in, OS)
%fixDirname - fixes dirname with pathes for the appropriate OS, converting slashes (\/)
%dirname = fixDirname(dirname_in, OS)
%
% Input:
%   dirname_in - path to directory
% Optional:
%   OS         - target OS for returned 'path'
%                OS = 0(UNIX, Mac), 1(Windows), same the return-value of 'ispc'
% Output:
%   dirname    - dirname_in fixed for the current OS or given 'OS'
%
% Calls:
%   fixPath - fixes pathes
%
% Created  By: Satoshi MURATA (1),  satoshi-m@atr.jp  08/08/21
% (1) ATR Intl. Computational Neuroscience Labs, Decoding Group


%% Check and get pars:
if exist('dirname_in','var')==0 || isempty(dirname_in)
    dirname = [];
    return;
end

if exist('OS','var')==0 || isempty(OS)
    OS = ispc;
end


%% Add '\', if the end of 'dirname_in' isn't '\' or '/':
if strcmp(dirname_in(end),'\')==0 && strcmp(dirname_in(end),'/')==0
    dirname_in = [dirname_in '\'];
end


%% Fix dirname:
dirname = fixPath(dirname_in,OS);
