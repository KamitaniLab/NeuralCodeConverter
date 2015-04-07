function [D, pars] = reduceOutliers(D, pars)
%reduceOutliers - reduces outlier values of data along app_dim
%[D, pars] = reduceOutliers(D, pars)
%
% Input:
%   D.data         - 2D matrix of any data ([time(sample) x space(voxel/channel)] format)
%
% Optional:
%   D.inds_runs    - [2 x N] matrix of start/end points for each run
%   pars.app_dim   - dimension along which reduction will be applied (std, mean)
%                    1: across time (default), 2: across space(channels)
%   pars.remove    - 1: remove instead of clip outliers, 0: clip
%   pars.method    - 1: max std deviation ONLY, 2: constant min_val, max_val ONLY, 3: BOTH (default)
%   pars.std_thres - number times std for threshold cut off and clip (default: 3)
%   pars.num_its   - number of iteration (default: 10)
%   pars.max_val   - absolute max value, used with method >=2
%   pars.min_val   - absolute min value, used with method >=2
%	pars.breaks    - [2 x N] matrix of break points for piecewise outlier reduction;
%	                 rows: 1-begin points, 2-end points; may contain just begin or end;
%   pars.break_run - use 'inds_runs' as 'breaks' (1, default), or not (0)
%   pars.verbose   - [1..3] print detail level 0=no printing (default: 1)
%
% Output:
%   D.data         - data reduced ourlier value
%   D.xyz          - X,Y,Z-coordinate values within the selected channel
%   D.tvals        - t-values within the selected channel
%   D.rois_inds    - indexes for each ROI
%
% Original  By: Yukiyasu Kamitani (1),  kmtn@atr.jp       03/12/13?
% Rewritten By: Alex Harner (1),        alexh@atr.jp      06/06/27
% Modified  By: Alex Harner (1),        alexh@atr.jp      06/10/17
% Modified  By: Satoshi MURATA (1),     satoshi-m@atr.jp  08/09/24
% (1) ATR Intl. Computational Neuroscience Labs, Decoding Group


%% Check and get pars:
if exist('D','var')==0 || isempty(D),   error('Wrong args');    end
if exist('pars','var')==0,              pars = [];              end

pars      = getFieldDef(pars,mfilename,pars);
app_dim   = getFieldDef(pars,'app_dim',1);
std_thres = getFieldDef(pars,'std_thres',3);
num_its   = getFieldDef(pars,'num_its',10);
max_val   = getFieldDef(pars,'max_val',inf);
min_val   = getFieldDef(pars,'min_val',-inf);
breaks    = getFieldDef(pars,'breaks',[]);
break_run = getFieldDef(pars,'break_run',1);
verbose   = getFieldDef(pars,'varbose',1);

if min_val>-inf || max_val<inf
    method = getFieldDef(pars,'method',3);
else
    method = getFieldDef(pars,'method',1);
end

if method>=2
    remove = getFieldDef(pars,'remove',1);
else
    remove = getFieldDef(pars,'remove',0);
end

if isempty(breaks)
    if break_run,   breaks = D.inds_runs;
    else            breaks = [1;size(D.data,1)];    end
end
num_breaks = size(breaks,2);


%% For UI:
if verbose
    fprintf(['\n' mfilename ' ------------------------------']);
    if verbose>=2
        fprintf('\n # breaks:\t%d',num_breaks);
        fprintf('\n method:\t%d',method);
        fprintf('\n remove:\t%d',remove);
        fprintf('\n std_thres:\t%d',std_thres);
        fprintf('\n num_its:\t%d',num_its);
        if method>=2
            fprintf('\n max_val:\t%g',max_val);
            fprintf('\n min_val:\t%g',min_val);
        end
        fprintf('\n app_dim:\t%d', app_dim);
    end
end


%% Main loop:
ind_all = sparse(size(D.data,1),size(D.data,2));     % keep num of outliers

for itb=1:num_breaks
    bi = breaks(1,itb);
    ei = breaks(2,itb);
    
    data_temp = D.data(bi:ei,:);
    data_size = size(data_temp);
    ind_m1    = zeros(data_size);   % indexes of outliers found in method1 (max std deviation)
    ind_m2    = zeros(data_size);   % indexes of outliers found in method2 (constant min_val, max_val)
    
    if method==1 || method==3
        for its=1:num_its       % do num_its iterations
            mu = mean(data_temp,app_dim);       % mean
            sd = std(data_temp,0,app_dim);      % standard deviation
            if exist('sdo','var') && isempty(sdo-sd<0.01*sd==false)
                break;
            end

            sdo = sd;
            % Find and clip values OVER threshold:
            if app_dim==1,      thres_mat = repmat(mu+sd*std_thres,data_size(1),1);     % make threshold matrix
            else                thres_mat = repmat(mu+sd*std_thres,1,data_size(2));     end
            ind_out            = data_temp>thres_mat;       % find values over thres_mat
            data_temp(ind_out) = thres_mat(ind_out);        % set those to thres_mat
            ind_m1(ind_out)    = ind_m1(ind_out)+1;
            % Find and clip values UNDER threshold:
            if app_dim==1,      thres_mat = repmat(mu-sd*std_thres,data_size(1),1);     % make threshold matrix
            else                thres_mat = repmat(mu-sd*std_thres,1,data_size(2));     end
            ind_out            = data_temp<thres_mat;       % find values under thres_mat
            data_temp(ind_out) = thres_mat(ind_out);        % set those to thres_mat
            ind_m1(ind_out)    = ind_m1(ind_out)+1;
        end
        if verbose && num_breaks>1
            num_out = length(find(ind_m1));
            fprintf('\n Segment %2d std dev outliers:   \t%d\t(%.2f %%)',itb,num_out,100*num_out/numel(data_temp));
        end
    end
    
    if method>=2
        if max_val<inf
            % Over max_val:
            ind_out            = data_temp>max_val;
            data_temp(ind_out) = max_val;
            ind_m2(ind_out)    = ind_m2(ind_out)+1;
        end
        if min_val>-inf
            % Below min_val:
            ind_out            = data_temp<min_val;
            data_temp(ind_out) = min_val;
            ind_m2(ind_out)    = ind_m2(ind_out)+1;
        end
        if verbose && num_breaks>1
            num_out = length(find(ind_m2));
            fprintf('\n Segment %2d min-max outliers:   \t%d\t(%.2f %%)',itb,num_out,100*num_out/numel(data_temp));
        end
    end
    
    D.data(bi:ei,:)  = data_temp;
    ind_all(bi:ei,:) = sparse(ind_m1+ind_m2);
end


%% User feedback:
if remove
    ind_remove_chans           = find(sum(ind_all,1));
    ind_use_chans              = setdiff(1:length(D.tvals),ind_remove_chans);
    num_remove                 = length(ind_remove_chans);
    D.data(:,ind_remove_chans) = [];
    D.xyz(:,ind_remove_chans)  = [];
    D.tvals(ind_remove_chans)  = [];
    for itr=1:numel(D.rois_inds)
        [tf, loc]               = ismember(D.rois_inds{itr},ind_use_chans);
        D.rois_inds{itr}(tf)    = loc(tf);
        D.rois_inds{itr}(tf==0) = [];
    end
    fprintf('\n Total outliers channels removed:\t%d\t(%.3f %%)',num_remove,100*num_remove/size(ind_all,2));
    if 100*num_remove/size(ind_all,2)>10
        fprintf('\n WARNING: High percentage (>10%%) of outliers removed!');
    end
else
    num_out = length(find(ind_all));
    num_elm = numel(ind_all);
    fprintf('\n Total outlier elements reduced: \t%d\t(%.3f %%)',num_out,100*num_out/num_elm);
    if 100*num_out/num_elm>0.01
        fprintf('\n WARNING: High percentage (>0.01%%) of outliers reduced!');
        fprintf('\n          Check data for spikes');
    end
end
fprintf('\n');
