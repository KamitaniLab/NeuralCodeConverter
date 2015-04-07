/**********************************************************************************
*
* [tf, inds] = ismemberMatrix(source, target)
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
    double  *source, *target, *source_sub;
    int     *tf, *inds;
    int     num_size, num_size_t, num_source, num_target, num_found, temp_ind;
    int     isource, isize;
    
    
    /* Check and get args */
    if(nrhs!=2)     mexErrMsgTxt("Input should be Two args.");
    if(nlhs>2)      mexErrMsgTxt("Output should be equal or less than Two arg.");
    
    source     = mxGetPr(prhs[0]);
    target     = mxGetPr(prhs[1]);
    
    num_size   = mxGetM(prhs[0]);
    num_source = mxGetN(prhs[0]);
    num_size_t = mxGetM(prhs[1]);
    num_target = mxGetN(prhs[1]);

    if(num_size!=num_size_t)    mexErrMsgTxt("Col-size of source and target should be same.");
    
    source_sub = mxCalloc(num_size, sizeof(double));
    
    
    /* Initialize output args */
    plhs[0]    = mxCreateNumericMatrix(1, num_source, mxINT32_CLASS, mxREAL);
    tf         = (int *)mxGetData(plhs[0]);
    plhs[1]    = mxCreateNumericMatrix(1, num_source, mxINT32_CLASS, mxREAL);
    inds       = (int *)mxGetData(plhs[1]);
    
    
    /* Check "ismember" */
    for(isource=0; isource<num_source; isource++) {
        for(isize=0; isize<num_size; isize++) {
            source_sub[isize] = source[isize+isource*num_size];
        }
        findArrayFromMatrix(source_sub, target, num_size, num_target, 1, 1, &num_found, &temp_ind);
        
        if(num_found) {
            tf[isource]   = 1;
            inds[isource] = temp_ind;
        }
    }
    
    
    /* Finalize */
    mxFree(source_sub);
}
