function [Dshuffle, Pcorrect, Pcorrect_shuf] = calc_Dshuffle(ttr,tte,xtr,xte,ix_shuf,Nshuf)
% Calculate Dshuffle.
% 
% Dshuffle is defined as difference of test percent correct between
% original data and shuffled data. Here logistic regression is used as a
% classifier.
%
% 2006/09/12 OY


% scale_mode = 'each';
% mean_mode = 'each';
% [xtr, scale, base] = normalize_feature(xtr, scale_mode, mean_mode);
% [xte] = normalize_feature(xte, scale_mode, mean_mode, scale, base);

%-------------------
% No Data Shuffle
%-------------------

% Logistic Regression
% Xtr = [xtr, ones(length(ttr),1)];
% [w_e, ix_eff, W, AX] = slr_learning(ttr, Xtr, @linfun,...
%     'reweight', 'OFF', 'nlearn', 1, 'ax0', zeros(size(Xtr,2),1), ...
%     'wmaxiter', 200, 'wdisplay', 'off');
% Xte = [xte ones(length(tte),1)];
% [Ncorrect] = slr_count_correct(tte, Xte, w_e);
% Pcorrect = Ncorrect/length(tte)*100;

    [c] = classify(xte, xtr, ttr);
    Pcorrect = sum(~xor(tte,c))/length(tte)*100;

fprintf('Test Correct (in extracted dimension) : %f ...\n', Pcorrect);

%------------------------------
% Data shuffled (Nshuf times)
% -----------------------------

for ii = 1 : Nshuf

    xtr_shuf = shuffle_data(ttr, xtr, ix_shuf);

%     % Logistic Regression
%     Xtr_shuf = [xtr_shuf, ones(length(ttr),1)];
%     [w_e, ix_eff, W, AX] = slr_learning(ttr, Xtr_shuf, @linfun,...
%         'reweight', 'OFF', 'nlearn', 1, 'ax0', zeros(size(Xtr_shuf,2),1), ...
%         'wmaxiter', 200, 'wdisplay', 'off');
% 
%     Xte = [xte ones(length(tte),1)];
%     [Ncorrect] = slr_count_correct(tte, Xte, w_e);
%     Pcorrect_shuf(ii) = Ncorrect/length(tte)*100;

        [c] = classify(xte, xtr_shuf, ttr);
        Pcorrect_shuf(ii) = sum(~xor(tte,c))/length(tte)*100;

    fprintf('Number of shuffle : %3d,  Test Correct (in extracted dimension) : %f ...\n', ii, Pcorrect_shuf(ii));
end

% shuff
Dshuffle = Pcorrect - mean(Pcorrect_shuf);
