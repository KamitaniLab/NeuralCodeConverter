function [D, P] = procSwitch(D, P, procs)
%procSwitch - performs processing steps listed in 'procs' on 'D'ata.
%[D, P] =  procSwitch(D, P, procs)
%
% Performs (pre-)processing steps listed in string array 'procs' (in order)
% on 'D'ata with 'P'arameters;
%
% Inputs:
%	D     - structure of 'D'ata
%	P     - structure containing all parameters of 'procs' as fields;
%           should be nested as P.<proc> (e.g. P.ica_amh).
%	procs - array of strings of the processing functions to be called;
%	        this may be any function in the user's path that conforms with:
%	          [D, P] = myProc(D, P);
%
% Optional:
%   P.procSwitch.mode
%         - 1: train, or 2: test; if specified, pass to all 'procs'
%           (use for proprocs in 'crossValidate')
%
% Outputs:
%   D     - modified D
%	P     - modified P, including adding weights for training mode
%
% Created  By: Alex Harner (1),     alexh@atr.jp      06/07/04
% Modified By: Alex Harner (1),     alexh@atr.jp      06/11/17
% Modified By: Satoshi MURATA (1),  satoshi-m@atr.jp  08/08/28
% (1) ATR Intl. Computational Neuroscience Labs, Decoding Group


%% Check and get pars:
if exist('D','var')==0     || isempty(D),       return;     end
if exist('procs','var')==0 || isempty(procs),   return;     end
if exist('P','var')==0     || isempty(P),       P = [];     end

pars = getFieldDef(P,mfilename,[]);
mode = getFieldDef(pars,'mode',[]);

% Put strings in cell array of strings
if ischar(procs)
    procs = cellstr(procs);
end


%% Loop through processing steps in procs cell array:
for itp=1:length(procs)
    proc = procs{itp};
    
    if exist(proc,'file')==2
        pars      = getFieldDef(P,proc,[]);
        if isempty(mode)==0,    pars.mode = mode;       end
        [D, pars] = feval(proc,D,pars);
        P.(proc)  = pars;
    else
        fprintf('\n procSwitch ERROR: did not find ''%s'', skipped!\n', proc);
    end
end
