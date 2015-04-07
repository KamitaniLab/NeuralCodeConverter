function slr_view_data_multi(t, x, dim, w)
% View the distribution of data in feature space with projection of two
% dimensional plane specified by 'dim'. 
% 
%  -- Example
% > slr_view_data(t, x)
% View features value of first two dimension of "x".
% > slr_view_data(t, x, dim)
% View features value of two dimension of "x" projected onto the dimension
% specified 'dim'.
% > slr_view_data(t, x, dim, w)
% % View features value of two dimension of "x" projected onto the
% dimension specified 'dim' and the boundary specified by "w". 
%
% 2006/09/20 OY

if nargin < 3
    dim1 = 1;
    dim2 = 2;
else
    dim1 = dim(1);
    dim2 = dim(2);
end
    
[t, tmp, Nclass] = label2num(t);
markers = {'b*', 'r.', 'go', 'md'}; 
if Nclass > 4
    error('This program only supports data of less than four classes !!');
end

for ii = 1 : Nclass
    ix{ii} = find(t == ii);
    hold on;
    plot(x(ix{ii},dim1),x(ix{ii},dim2), markers{ii});
end

if nargin == 4
    
    minx1 = min(x(:,dim1))*1.0;
    maxx1 = max(x(:,dim1))*1.0;
    minx2 = min(x(:,dim2))*1.0;
    maxx2 = max(x(:,dim2))*1.0;
    
    [X1, X2] = meshgrid([minx1:(maxx1-minx1)/20:maxx1],[minx2:(maxx2-minx2)/20:maxx2]);
    
    for ii = 1 : Nclass
    w1 = w(dim1,ii);
    w2 = w(dim2,ii);
    c = w(end,ii);
    Z(:,ii) = w1.*X1(:)+w2.*X2(:)+c;
    %hold on;
    %surf(X1, X2, reshape(Z(:,ii), [21,21]));
    end
    
    ZZ = max(Z, [], 2);
    
    hold on;
    surfc(X1, X2, reshape(ZZ, [21,21]));
    xlabel('Feature 1');
    ylabel('Feature 2');
    
end