function [N, NCORRECT_TE] = calc_Nval(CVRes, COND)
% Calculate N-value from result of cross validation.
%
% -- Syntax
% [N, Ncorrect] = calc_Nval(CVRes)
% [N, NCORRECT_TE] = calc_Nval(CVRes, COND)
%
% -- Input
% CVRes : Cross Validation Result structure
% .ix_eff_all  :
% .g           :
% .Ncorrect_te :
%      or
% .errTable_te :  
% Cond         : cell array of strings, this is just for diplaying purpose
%
% -- Ouput
% N : N-value
% NCORRECT_TE : percent correct in test (prediction performance)
%
% 2006/09/12 OY support new output format
% 2006/09/01 OY


Ncv = length(CVRes);
Nclass = 1;
Nvox = CVRes(1).g.nfeat-1;  % number of voxels

count = zeros(Nclass, Nvox);
NCORRECT_TE = zeros(Ncv,1);

if nargin < 2
  for ii = 1 : Nclass
      COND{ii} = '';
  end
end

for ii = 1 :  Ncv
    Res = CVRes(ii);
    if isfield(Res, 'Ncorrect_te'),
        Pcorrect_te = Res.Ncorrect_te/100;
    elseif isfield(Res, 'errTable_te')
        Pcorrect_te = sum(diag(Res.errTable_te))/sum(Res.errTable_te(:));
    else
        Pcorrect_te = sum(diag(Res.errTbale_te))/sum(Res.errTbale_te(:));
    end
        
    for cc = 1 : Nclass
        if ~isempty(COND{cc})
        fprintf('%s          : ', COND{cc});fprintf('%d ', Res.ix_eff_all{cc});
        fprintf('\n');
        end
        
        incr = zeros(1,Nvox);
        incr(:, Res.ix_eff_all{cc}) = Pcorrect_te;            
        count(cc,:) = count(cc,:) + incr;
    end
    
    NCORRECT_TE(ii) = Pcorrect_te*100;
end
N = count;
