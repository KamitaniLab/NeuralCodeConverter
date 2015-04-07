mex -O -c -largeArrayDims svm.cpp
mex -O -c -largeArrayDims svm_model_matlab.c
if ispc
	mex -O -largeArrayDims svmtrain.c svm.obj svm_model_matlab.obj
	mex -O -largeArrayDims svmpredict.c svm.obj svm_model_matlab.obj
else
	mex -O -largeArrayDims svmtrain.c svm.o svm_model_matlab.o
	mex -O -largeArrayDims svmpredict.c svm.o svm_model_matlab.o
	mex -O -largeArrayDims read_sparse.c
end
mex -O -largeArrayDims read_sparse.c


if 0
mex -O -c svm.cpp
mex -O -c svm_model_matlab.c
mex -O svmtrain.c svm.obj svm_model_matlab.obj
mex -O svmpredict.c svm.obj svm_model_matlab.obj
mex -O read_sparse.c
end
