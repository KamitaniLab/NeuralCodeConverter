function [f,g,H] = linfun_mixture(w, t, ax, X, z)
% [f,g,H] = linfun_mixture(w, t, ax, X, z)
% 
% For learning one mixture components 
% apply weight z 
% 
%

y = X * w;
p = 1 ./(1+exp(-y));

s = 1-t;
q = 1-p;

ix = find(p > eps & q > eps);

%%%% Value
%f = t(ix)'*log(p(ix)) + s(ix)'*log(q(ix)) - 1/2 * w'*A*w;
f = ((z(ix).*t(ix))'*log(p(ix)) + (z(ix).*s(ix))'*log(q(ix))) - 1/2 * sum(ax.* w.^2);
f = -f;  

%%%% Gradient
if nargout > 1
    gc = z.*(t-p);
    g = -X'*gc + ax .* w;
end

%%%% Hessian
if nargout > 2
   b = z.*p.*(1-p);
%    B = diag(b);
%    H = Phi'*B*Phi+A;
   Nparm = length(ax);
   H = X'* (b(:, ones(1,Nparm)).*X) + spdiags(ax, 0, Nparm, Nparm);

end

% %%----------- old version
% 
% y = X * w;
% p = 1 ./(1+exp(-y));
% A = diag(ax);
% 
% s = 1-t;
% q = 1-p;
% 
% ix = find(p > eps & q > eps);
% 
% %%%% Value
% f = t(ix)'*log(p(ix)) + s(ix)'*log(q(ix)) - 1/2 * w'*A*w;
% f = -f;  
% 
% %%%% Gradient
% if nargout > 1
% %     gc = t-p;
% %     g= -A*w;
% %     for i = 1 : length(gc)
% %         g = g+gc(i)*Phi(i,:)';
% %     end
%     
%     gc = (t-p)';
%     tmp = X' .* gc(ones(1,size(X,2)),:); 
%     g = sum(tmp,2) - A*w;
%     g = -g;
% end
% 
% %%%% Hessian
% if nargout > 2
%    b = p.*(1-p);
% %    B = diag(b);
% %    H = Phi'*B*Phi+A;
%    H = X'* (b(:, ones(1,size(X,2))).*X) + A;
%      
% end
