function make(func_name)
%make - executes 'mex' command to make 'func_name'
%make(func_name)
%
% Input:
%   func_name - function name wanted to make 
%               if absent, make all functions
% 
% Created By: Satoshi MURATA (1),  satoshi-m@atr.jp  08/09/19
% (1) ATR Intl. Computational Neuroscience Labs, Decoding Group


%% Check and get args:
if exist('func_name','var')==0 || isempty(func_name)
    func_name = 'all';
end


%% Execute 'mex' command:
switch func_name
    case 'all'
        make('findArray');
        make('ismemberMatrix');
        
    case 'findArray'
        mex -c findArrayFromMatrix.c
        if ispc,    mex findArray.c findArrayFromMatrix.obj;
        else        mex findArray.c findArrayFromMatrix.o;      end
        
    case 'ismemberMatrix'
        mex -c findArrayFromMatrix.c
        if ispc,    mex ismemberMatrix.c findArrayFromMatrix.obj;
        else        mex ismemberMatrix.c findArrayFromMatrix.o;     end
        
    case 'clean'
        if ispc,    delete *.obj;
        else        delete *.o;     end
end
