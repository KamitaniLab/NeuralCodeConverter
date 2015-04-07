function preds = predsFromDecVals(dec_vals, conds)
%predsFromDecVals - maps decision values to prediction labels
%preds = predsFromDecVals(dec_vals, conds)
%
% Inputs:
%	dec_vals - decision values
%
% Optional:
%	conds   - list of conditions corresponding to decVals; if absent,
%   		  it will use [1 2 ...] as conditions
%
% Created  By: Alex Harner (1),     alexh@atr.jp      06/07/27
% Modified By: Alex Harner (1),     alexh@atr.jp      06/07/27
% Modified By: Satoshi MURATA (1),  satoshi-m@atr.jp  08/10/09
% (1) ATR Intl. Computational Neuroscience Labs, Decoding Group


%% Check and get pars:
if exist('dec_vals','var')==0 || isempty(dec_vals),     error('Wrong args');    end

if exist('conds','var')==0 || isempty(conds)
    num_conds = size(dec_vals,2);
    conds     = 1:num_conds;
end


%% Find max decision value:
[nouse, inds] = max(dec_vals,[],2);


%% Map max to condition:
preds = conds(inds);
