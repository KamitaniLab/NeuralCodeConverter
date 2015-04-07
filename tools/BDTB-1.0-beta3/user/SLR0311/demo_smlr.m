% Demo of three class classification
%
%

clear 
close all

fprintf('This is demo of how sparse MULTINOMIAL regression work ...\n');
fprintf('3 classes and 100 samples are used \n');

%-----------------
% data generation
%-----------------

mu = [-5 0 ; 0 0 ; 5 0 ;];
sig = [1; 1; 1;];
N = 100; % sample per class
Nclass = length(sig); 
Nfeat = size(mu,2)+1;
mark = {'ro', 'b+', 'g.'};

X = [];
label = [];
for c = 1 : Nclass
    x = randmn(mu(c,:)', sig(c)*Nfeat, N)';
    X = [X; x];
    label = [label; c*ones(N,1)];
end

slr_view_data_multi(label, X)
title('Synthesized data');
axis equal

fprintf('Press any key to proceed\n');
pause;



%--------------------- 
% MLE
%---------------------
X = [X ones(N*Nclass,1)];
AMAX = 1e6;

Nparm = Nclass*Nfeat;
w = zeros(Nparm,1);
ax = ones(Nparm,1);
ix_eff = [1:Nparm]';


for n = 1 : 100
    ax_eff = ax(ix_eff);
    w0_eff = w(ix_eff);
    X_eff = X;


    [ixf, ixc] = ind2sub([Nfeat, Nclass], ix_eff);

    %%% W-step

    option = optimset('Gradobj','on','Hessian','off', 'Display', 'iter');
    [w_eff,f,eflag,output,g,H]=fminunc(@linfunmlr, w0_eff, option,...
        label, ax_eff, X_eff, ix_eff, ixf, ixc, Nclass);

    iax_eff = 1./ax_eff;
    dS_eff = inv(H); % #parm*1
    %% A-step
    ax_eff = (1-ax_eff.* diag(dS_eff))./(w_eff.^2);

    %% Prune ineffective parameters
    w = zeros(Nparm,1);
    w(ix_eff) = w_eff;
    ax(ix_eff) = ax_eff;
    ix_eff = find(ax < AMAX);

    %semilogy(ax+1);
    %pause(0.5)

end

ww = reshape(w, [Nfeat, Nclass]);
[tmp, label_est] = max(X*ww,[],2);
length(find(label_est == label))/(N*Nclass)*100

figure,
slr_view_data_multi(label, X, [1 2], ww);
