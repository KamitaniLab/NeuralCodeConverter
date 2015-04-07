function [w_all, ix_eff_all, MS, opt] = slr_learning_mixture2(label, X, g, hfun, varargin)
% Learning mixture sparse logistic regression model
%
% [w_all, ix_eff_all, MS, opt] = slr_learning_mixture2(label, X, g,
% hfun, varargin)
% 
% -- Input
% label : teacher label vector consisting of {0,1}  [N*1]
% X{m}  : explanatory matrix belonging to component m   [N*#feature]
% g(:,m): ratio of mixture [N*1]
% hfun  : function handle
%
% -- Field of Optional Input
% w0    : initial value of parameter w 
% ax0   : initial value of parameter variance ax
% nlearn : # of learning 
% amax   : truncation criteria. parameters whose ax is larger than this value 
%          are eliminated from the further estimation.
% wmaxiter : # of learning in W-step
% wdisplay : 
% reweight :
%
% -- Output
% w      : estimated parameters
% ix_eff : index of the effective feature
% W      : history of parameter learning
% AX     : history of hyper parameter learning
%
% 2005-12-04 by Okito Yamashita 
% 2006-02-07 by Okito Yamashita
% 2006/06/27 by O.Y.  
% In case X{1} and X{2} have different size are supported!! 
%


%% Error check
if nargin < 4
    help slr_learning_mixture
end

%% # of parameters
Ncomp  = length(X);

for m = 1 : Ncomp
    Nparm(m)  = size(X{m}, 2); 
end

%% input check for optional parameter.
opt = finputcheck(varargin, ...
    {%'ax0',    'real',  [],   ones(Nparm(1), Ncomp);...
     %'w0',     'real',  [],   zeros(Nparm(1), Ncomp);...
     'nlearn', 'integer', [1 inf], 150;...
     'amax',   'real', [0 inf], 1e8;...
     'wmaxiter', 'integer', [1 inf], 50;...
     'wdisplay', 'string', {'iter', 'off', 'final', 'notify'}, 'final';...
     'reweight', 'string', {'ON', 'OFF'}, 'OFF'});
  
if ~isstruct(opt)
   error(opt);
end
     
% if size(opt.ax0,1) ~= Nparm | size(opt.w0,1) ~= Nparm
%     error('The size of ax0 or w0 is incorrect !!');
% end

%--- Initialization
Nlearn = opt.nlearn;
AMAX   = opt.amax;
ReWeight = opt.reweight;
WMaxIter = opt.wmaxiter;
WDisplay = opt.wdisplay;

for m = 1 : Ncomp, 
    ix_eff_all{m} = [1:Nparm(m)]'; 
    opt.w0{m} =  zeros(Nparm(m),1);  % Default
    opt.ax0{m} = ones(Nparm(m),1); % Default
end

ax_all = opt.ax0;   
w_all  = opt.w0; 
g_all = g;


for nlearn = 1 : Nlearn
   %--- Posterior probability of hidden variable
   for  m = 1 : Ncomp
       y = X{m}*w_all{m}(:);
       p = 1 ./(1+exp(-y)) ; % #data
       z_all(:,m) = g_all(:,m).*(p.*label +(1-p).* (1-label));    
   end   
   z_all = z_all ./ repmat(sum(z_all,2), [1, Ncomp]);
   
   for m = 1 : Ncomp
       if mod(nlearn,100) == 0
       display(['iter : ' num2str(nlearn), '  component :' num2str(m)]);
       end
       %--- Effective parameters 
       ix_eff = ix_eff_all{m};      % Nparm_eff 
       X_eff  = X{m}(:, ix_eff);    % Nsamp*Nparm_eff
       w0_eff = w_all{m}(ix_eff);   % Nparm_eff
       ax_eff = ax_all{m}(ix_eff);  % Nparm_eff
       z = z_all(:,m);              % Nsamp*Ncomp

       %--- W-step 
       option = optimset('Gradobj','on','Hessian','on',...
           'MaxIter', WMaxIter, 'Display', WDisplay);
        
       [w_eff,f,eflag,output,g,H]=fminunc(@linfun_mixture, w0_eff, option,...
       label, ax_eff, X_eff, z);
              
        y = X_eff*w_eff;
        p = 1 ./(1+exp(-y)) ; % #data
        b = z.*p.*(1-p);      % #data
   
        B = diag(b);       
        A_eff = diag(ax_eff);

        %S_eff = inv(H);
        S_eff = inv(X_eff'*B*X_eff+A_eff);
   
        %if strcmp(ReWeight, 'ON') 
        %   w_eff = S_eff*X_eff'*B* y;
        %end

        %--- A-step
        ax_eff = (1-ax_eff.*diag(S_eff))./(w_eff.^2);
        %ax_eff = 1./(w_eff.^2 + diag(S_eff));
        
        %--- Prune ineffective parameters
        w = zeros(Nparm(m),1);
        ax = ones(Nparm(m),1) * AMAX;
        w(ix_eff)  = w_eff;
        ax(ix_eff) = ax_eff;
        
        ix_eff = find(ax < AMAX);  
        
        w_all{m}(:)   = w;
        ax_all{m}(:)  = ax;
        ix_eff_all{m} = ix_eff;
      
        semilogy(ax);
        axis([-inf inf 0 1e10])
        pause(0.05)
   end

end

MS = make_struct(X, ix_eff_all, ax_all, w_all, g_all, z_all, 2);

function MS = make_struct(XX, II, AA, WW, GG, ZZ, Ncomponent);
for m = 1 : Ncomponent
    MS(m).X = XX{m};
    MS(m).ix_eff = II{m};
    MS(m).ax     = AA(:,m);   
    MS(m).w      = WW(:,m);   
    MS(m).g      = GG(:,m);     % prior mixture ratio
    MS(m).z      = ZZ(:,m);     % posterior mixture ratio
end








