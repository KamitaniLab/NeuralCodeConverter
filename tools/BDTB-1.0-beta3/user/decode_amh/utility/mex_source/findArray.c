/**********************************************************************************
*
* ind = findArray(array, matrix, num_inds, first)
*
*  Notice:
*    This file should be compiled with "findArrayFromMatrix.c"
*
* Created By: Satoshi MURATA (1),  satoshi-m@atr.jp  08/09/19
* (1) ATR Intl. Computational Neuroscience Labs, Decoding Group
*
**********************************************************************************/

#include "mex.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    double  *array, *matrix, *d_num_inds, *d_first;
    int     *inds, *temp_inds;
    int     num_size, num_size_m, num_samples, i_num_inds, i_first, num_found;
    int     iinds;
    
    /* Check and get args */
    if(nrhs<2||nrhs>4)      mexErrMsgTxt("Input should be Two, Three, or Four args.");
    if(nlhs>1)              mexErrMsgTxt("Output should be equal or less than One arg.");
    
    array       = mxGetPr(prhs[0]);
    matrix      = mxGetPr(prhs[1]);
    
    num_size    = mxGetM(prhs[0]);
    num_size_m  = mxGetM(prhs[1]);
    num_samples = mxGetN(prhs[1]);
    
    if(num_size!=num_size_m)    mexErrMsgTxt("Col-size of array and matrix should be same.");
    
    if(nrhs<3||mxIsEmpty(prhs[2])) {
        i_num_inds = num_samples;
    }
    else {
        d_num_inds = mxGetPr(prhs[2]);
        i_num_inds = (int)(*d_num_inds);
    }
    
    if(nrhs<4||mxIsEmpty(prhs[3])) {
        i_first = 1;
    }
    else {
        d_first = mxGetPr(prhs[3]);
        i_first = (int)(*d_first);
    }
    
    
    /* Initialize var of found indexes */
    temp_inds = mxCalloc(i_num_inds, sizeof(int));
    if(temp_inds==NULL){
        mexErrMsgTxt("Cannot get enough memory space");
    }
    
    
    /* Find "array" */
    findArrayFromMatrix(array, matrix, num_size, num_samples, i_num_inds, i_first, &num_found, temp_inds);
    
    
    /* Initialize output args */
    plhs[0] = mxCreateNumericMatrix(1, num_found, mxINT32_CLASS, mxREAL);
    inds    = (int *)mxGetData(plhs[0]);
    
    
    /* Arrange output args */
    for(iinds=0; iinds<num_found; iinds++) {
        inds[iinds] = temp_inds[iinds];
    }
    
    
    /* Finalize */
    mxFree(temp_inds);
}
