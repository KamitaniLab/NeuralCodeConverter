/**********************************************************************************
*
* findArrayFromMatrix(array, matrix, num_size, num_samples, num_find, first, num_found, inds)
*
*  Input:
*    array       - target array
*    matrix      - group of array
*    num_size    - size of array (ex. "2" for pixel, "3" for voxel)
*    num_samples - sample-num of matrix
*    num_find    - num of wanted indexes
*    first       - from "first" (1), or not (0)
*    num_found   - var for num of found indexes
*    inds        - var for found indexes
*
*  Notice:
*    This function used in "ismemberMatrixSub" and "findArraySub"
*
* Created By: Satoshi MURATA (1),  satoshi-m@atr.jp  08/09/19
* (1) ATR Intl. Computational Neuroscience Labs, Decoding Group
*
**********************************************************************************/

void findArrayFromMatrix(const double   *array,
                         const double   *matrix,
                         const int      num_size,
                         const int      num_samples,
                         const int      num_find,
                         const int      first,
                         int            *num_found,
                         int            *inds)
{
    int isize, isamples, num_find_inds, num_found_inds, num_match, *temp_inds;
    
    
    /* Num of indexes to find */
    if(first) {
        num_find_inds = num_find;
    }
    else {
        num_find_inds = num_samples;
        temp_inds     = (int *)calloc(num_find_inds, sizeof(int));
    }
    
    
    /* Search array */
    num_found_inds = 0;
    for(isamples=0; isamples<num_samples; isamples++) {
        num_match = 0;
        for(isize=0; isize<num_size; isize++) {
            if(array[isize]==matrix[isize+isamples*num_size]) {
                num_match++;
            }
            else {
                break;
            }
        }
        if(num_match==num_size) {
            if(first)   inds[num_found_inds]      = isamples+1;
            else        temp_inds[num_found_inds] = isamples+1;
            num_found_inds++;
        }
        if(num_found_inds>=num_find_inds) {
            break;
        }
    }
    
    
    /* Arrange output args */
    if(first) {
        *num_found = num_found_inds;
    }
    else {
        for(isamples=0; isamples<num_find; isamples++) {
            if(num_found_inds-isamples>=0) {
                inds[isamples] = temp_inds[num_found_inds-isamples-1];
            }
            else {
                break;
            }
        }
        *num_found = (num_find<num_found_inds) ? num_find : num_found_inds;
        free(temp_inds);
    }
}
