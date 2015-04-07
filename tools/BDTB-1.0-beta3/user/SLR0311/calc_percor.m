function [Pcorrect] = calc_percor(errTable);

Nsamp = sum(errTable(:));
Ncor  = sum(diag(errTable));

Pcorrect = Ncor/Nsamp * 100;  % percent 

