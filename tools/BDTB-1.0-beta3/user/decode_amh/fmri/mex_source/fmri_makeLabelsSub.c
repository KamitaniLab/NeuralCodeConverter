/**********************************************************************************
***
***   labels = fmri_makeLabelsSub(labels_runs_blocks, samples_per_block, num_samples)
***
***                                        2008/09/17  Satoshi MURATA
***
**********************************************************************************/

#include "mex.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    double  *labels_runs_blocks, *samples_per_block, *num_samples, *labels;
    int     num_runs, num_blocks, i, j, k;
    
    /* Check args */
    if(nrhs!=3)    mexErrMsgTxt("Input should be Three args.");
    if(nlhs>1)     mexErrMsgTxt("Output should be equal or less than One arg.");
    
    /* Get values of labels_runs_blocks, samples_per_block, and num_samples */
    labels_runs_blocks = mxGetPr(prhs[0]);
    samples_per_block  = mxGetPr(prhs[1]);
    num_samples        = mxGetPr(prhs[2]);
    
    /* Get values of num_runs and num_blocks */
    num_runs   = mxGetM(prhs[0]);
    num_blocks = mxGetN(prhs[0]);
    
    /* Initialize of output */
    plhs[0] = mxCreateNumericMatrix(1,*num_samples,mxDOUBLE_CLASS,mxREAL);
    labels  = mxGetPr(plhs[0]);
    
    /* Make labels */
    for(i=0; i<num_runs; i++)
    {
        for(j=0; j<num_blocks; j++)
        {
            for(k=0; k<samples_per_block[j]; k++)
            {
                *labels++ = labels_runs_blocks[j*num_runs+i];
            }
        }
    }
}
