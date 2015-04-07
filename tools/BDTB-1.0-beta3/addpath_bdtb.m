function addpath_bdtb
%addpath_bdtb - addpath all directories under 'BDTb' root-directory
%
% Created By: Satoshi MURATA (1),  satoshi-m@atr.jp  08/10/16
% (1) ATR Intl. Computational Neuroscience Labs, Decoding Group


str = fileparts(which(mfilename));
addpath(genpath(str));
