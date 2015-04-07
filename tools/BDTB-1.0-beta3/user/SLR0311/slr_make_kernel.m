function [X] = slr_make_kernel(x, R, xcenter)
% Make explanatory matrix consisting of Gaussian kernel
% 
% function [X] = slr_make_kernel(x, r, xcenter)
%
% x : data      (N*D)
% R : width of Gaussian kernel
% xcenter  : center of kernel (Nref*D)
%
% 2005-12-04 Okito Yamashita

if nargin < 3
    xcenter = x;
end

N = size(x,1);
D = size(x,2);
Ncenter = size(xcenter,1);
K = zeros(N, Ncenter);

for i = 1 : Ncenter
    xref = xcenter(i,:);
    d = x - repmat(xref,[N,1]);
    dd = sum(d.^2,2);
    K(:,i) = dd'/D;  % normalization 
end

X = exp(-R*K);  %Gaussian kernel


%     [ K(x(1), xc(1)), K(x(1), xc(2)), ... K(x(1), xc(Nref)) ]
%     [ K(x(2), xc(1)), K(x(2), xc(2)), ... K(x(2), xc(Nref)) ]
% K = [                        :                              ]
%     [                        :                              ]
%     [ K(x(N), xc(1)), K(x(N), xc(2)), ... K(x(N), xc(Nref)) ]

