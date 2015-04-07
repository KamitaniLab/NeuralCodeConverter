function [D, pars] = normByBaseline(D, pars)
%normByBaseline - normalizes data by its baseline (within each break)
%[D, pars] = normByBaseline(D, pars)
%
% Normalizes each channel (voxel) of data by subtracting and dividing the average
% of each channel's baseline (within each break), as defined by baseConds.
%
% Inputs:
%   D.data          - 2D matrix data of any type (fMRI,MEG,...)
%
% Optional:
%   D.inds_runs     - begin/end indexes for each run
%   D.inds_conds    - indexes for each condition
%   pars.base_conds - array of baseline condition numbers (default = [1])
%   pars.zero_thres - threshold below which the baseline chan is considered zero,
%                     in which case, chan is set to zero
%	pars.breaks     - [2 x N] matrix of break points for piecewise normalization;
%	                  rows: 1-begin points, 2-end points; may contain just begin or end;
%   pars.break_run  - use 'inds_runs' as 'breaks' (1, default), or not (0)
%   pars.verbose   - [1..3] print detail level 0=no printing (default: 1)
%
% Ouput:
%   D.data          - normlized data, same dims
%
% Original  By: Yukiyasu Kamitani (1),  kmtn@atr.jp       04/01/29?
% Rewritten By: Alex Harner (1),        alexh@atr.jp      06/07/03
% Modified  By: Alex Harner (1),        alexh@atr.jp      07/02/20
% Modified  By: Satoshi MURATA (1),     satoshi-m@atr.jp  08/09/25
% (1) ATR Intl. Computational Neuroscience Labs, Decoding Group


%% Check and get pars:
if exist('D','var')==0 || isempty(D),   error('Wrong args');    end
if exist('pars','var')==0,              pars = [];              end

pars       = getFieldDef(pars,mfilename,pars);     % unnest, if need
base_conds = getFieldDef(pars,'base_conds',1);
zero_thres = getFieldDef(pars,'zero_thres',1);
breaks     = getFieldDef(pars,'breaks',[]);
break_run  = getFieldDef(pars,'break_run',1);
verbose    = getFieldDef(pars,'verbose',1);

if isempty(breaks)
    if break_run,   breaks = D.inds_runs;
    else            breaks = [1;size(D.data,1)];    end
end
num_breaks = size(breaks,2);


%% For UI:
if verbose,     fprintf(['\n' mfilename ' ------------------------------']);     end


%% Main loop:
for itb=1:num_breaks
    bi = breaks(1,itb);
    ei = breaks(2,itb);
    
    % Pull section (run) out:
    data_temp = D.data(bi:ei,:);
    
    % Find indexes of base condition:
    ind_use  = ismember(bi:ei,[D.inds_conds{base_conds}]);
    
    % Calc baseline:
    baseline = mean(data_temp(ind_use,:),1);
    
    % Find baseline indexes ~= 0 (to avoid dividing by them):
    zero_ind  = find(abs(baseline) <= zero_thres);
    num_zeros = numel(zero_ind);
    if num_zeros>1      % If there are some zero values in the baseline
        fprintf('\n Warning: %d baselines indexes near zero (abs<%g)!',num_zeros,zero_thres);
        baseline(zero_ind) = zero_thres;    % set them to zero_thres to avoid dividing by them
    end
    
    % Normalize by baseline:
    baseline_mat = repmat(baseline,size(data_temp,1),1);
    data_temp    = 100 * (data_temp - baseline_mat) ./ baseline_mat;
    
    % Set zero_ind data to zero:
    if num_zeros>1,      data_temp(zero_ind) = 0;     end
    
    % Put normalized section (run) back:
    D.data(bi:ei,:) = data_temp;
end


%% User feedback:
fprintf('\n');
