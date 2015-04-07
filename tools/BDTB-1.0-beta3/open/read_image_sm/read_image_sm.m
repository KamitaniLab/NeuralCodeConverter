% FORMAT [img DIM VOX SCALE TYPE OFFSET ORIGIN] = read_image( fname )
%
%S read_image version midified to run on MATLAB 7.
%S Some abolished functions in this were replaced to the usable functions.
%S
%S Modified By: Satoshi MURATA (1),  satoshi-m@atr.jp  07/06/20
%S (1) ATR Intl. Computational Neuroscience Labs, Decoding Group
%
%
% Reads image fname and header for fname, returning image as matrix
% img, mutliplied by SCALE, as well as header info
%
% Returns only as many output arguments as passed, e.g
% [img DIM VOX] = read_image( 'test.img' ) will behave as expected
%
% Compiled MEX file
%
% Matthew Brett 11/97
