/* arranged for Ver.7 by Satoshi MURATA */

#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <stdio.h>
#include <string.h>     /* sm */
#include "matrix.h"     /* sm */
#include "dbh.h"

#include "mex.h"

#define A_HEADER_SIZE	348

/* a few datatypes nicked from ANALYZE */
#define BINARY		1
#define UNSIGNED_CHAR	2
#define SIGNED_SHORT	4
#define SIGNED_INT	8
#define FLOAT	16
#define DOUBLE	64

/* bits per byte */
#define BYTEBITS	8

int get_datasize(type)
int type;
{
	if (type == BINARY) return(1);
	if (type == UNSIGNED_CHAR) return(8);
	if (type == SIGNED_SHORT) return(16);
	if (type == SIGNED_INT) return(32);
	if (type == FLOAT) return(32);
	if (type == DOUBLE) return(64);
	return(0);
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])      /* sm */
{
	struct dsr hdr;
	char *str, *extptr, errstr[2048];
	int i, k, matlen, stlen, datatype, datasize, offset;
	int xdim, ydim, zdim, len, addbits, dbits;
	FILE *fp;
	int bctr, pctr, planesize;
	double *ptr, *matbuf, *ddata, scale;
	unsigned char *imgbuf;
	unsigned char *cdata;
	short *sidata;
	int *idata;
	float *fdata;
	short int origin[5];

    int filesize;   /* sm */


	static struct stat stbuf;

	if (nrhs < 1 || nlhs < 1)
		mexErrMsgTxt("Inappropriate usage.");

	/* get filename */
/*	if (!mxIsString(prhs[0])) */
	if (!mxIsChar(prhs[0]))     /* sm */
		mexErrMsgTxt("filename should be a string");
	stlen = mxGetN(prhs[0]);
	str = (char *)mxCalloc(stlen+1, sizeof(char));
	mxGetString(prhs[0],str,stlen+1);

	/* delete white space */
	for(k=0; k<stlen; k++)
		if (str[k] == ' ')
		{
			str[k] = '\0';
			break;
		}

	/* check file extension */
	extptr = str + k -4;
	if (strcmp(extptr, ".img" )!= 0) {
		(void)sprintf(errstr,"Image file extension should be .img (%s).", str);
		mxFree(str);
		mexErrMsgTxt(errstr);
	}

	/* insert hdr extension */
	strcpy(extptr, ".hdr");

	/* read header info */
	if ((fp = fopen(str, "rb" )) == NULL) /* needs to be binary */
	{
		(void)sprintf(errstr,"Cannot open header file (%s).", str);
		mxFree(str);
		mexErrMsgTxt(errstr);
	}

	i = fread(&hdr, sizeof(char), A_HEADER_SIZE, fp);
	(void)fclose(fp);

	if (i != A_HEADER_SIZE)
	{
		(void)sprintf(errstr,"Cannot read all of header (%s).", str);
		mxFree(str);
		mexErrMsgTxt(errstr);
	}

	xdim = hdr.dime.dim[1];
	ydim = hdr.dime.dim[2];
	zdim = hdr.dime.dim[3];
	scale = hdr.dime.funused1;
	if (scale == 0)
		scale = 1;
	datatype = hdr.dime.datatype;
	offset = hdr.dime.vox_offset;

	if (xdim < 1 || ydim < 1 || zdim < 1)
		mexErrMsgTxt("Dimensions too small.");

	datasize = get_datasize(datatype);
	if (datasize == 0)
	{
		mxFree(str);
		mexErrMsgTxt("Unrecognised datatype.");
	}

	/* binary image packed to byte boundaries between planes */
	if (datatype == 1) { /* binary */
		addbits = (BYTEBITS - ((xdim * ydim) % BYTEBITS)) % BYTEBITS;
		len = (((xdim * ydim) + addbits) * zdim) / 8;
	} else
		len = ((int)(xdim*ydim*zdim)*datasize+7)/8;

	/* stat then read image */
	strcpy(extptr, ".img");

    /* sm */
    /* 'str()' cannot be used when this file is compiled by Lcc-win32 C 2.4.1
       (default compiler of mex). 
       So, 'fseek()' and 'ftell()', instead of 'str()', is used to get filesize
       of image file after the file has opened.                                 */
/*
    if (stat(str, &stbuf) == -1)
	{
		(void)sprintf(errstr,"Cannot stat image file (%s).", str);
		mxFree(str);
		mexErrMsgTxt(errstr);
	}
	if (stbuf.st_size < offset+len)
	{
		(void)sprintf(errstr,"Image file too small (%s).", str);
		mxFree(str);
		mexErrMsgTxt(errstr);
	}
*/

    if ((fp = fopen(str, "rb" )) == NULL) 
	{
		(void)sprintf(errstr,"Cannot open image file (%s).", str);
		mxFree(str);
		mexErrMsgTxt(errstr);
	}
    
    /* sm */
    fseek(fp, 0L, SEEK_END);
    filesize = ftell(fp);
    if (filesize < offset+len)
    {
		(void)sprintf(errstr,"Image file too small (%s).", str);
		mxFree(str);
		mexErrMsgTxt(errstr);
    }
    fseek(fp, 0L, SEEK_SET);
    /* sm */
	
	imgbuf = mxCalloc(offset + len, 1);
	i = fread(imgbuf, sizeof(char), len + offset, fp);
	(void)fclose(fp);
	
	if (i != len + offset)
	{
		(void)sprintf(errstr,"Cannot read all of image file (%s).", str);
		mxFree(str);
		mexErrMsgTxt(errstr);
	}
	mxFree(str);

	/* pointer to beginning of image */
	imgbuf = imgbuf + offset;

	/* now convert to doubles */
	matlen = xdim*ydim*zdim;
/*	plhs[0] = mxCreateFull(matlen,1,REAL); */
	plhs[0] = mxCreateDoubleMatrix(matlen,1,mxREAL);      /* sm */
	matbuf = mxGetPr(plhs[0]);

	switch (datatype) {
		case 1:
			/* Binary - don't read padding bits */
			cdata = (unsigned char *) imgbuf; /* char to avoid byte order probs */
			dbits = sizeof(char) * BYTEBITS;
			pctr = 0;	/* counter no of bits done in plane */
			bctr = 0;	/* ctr no bits used from byte */
			planesize = xdim * ydim;
			for (i = 0; i< matlen; i++) {
				if (pctr == planesize) {	/* past end of plane */
					pctr = 0;
					if (bctr) { /* now in padding bits */
						cdata ++ ;  /* new char */
						bctr = 0;
					}
				}
				matbuf[i] = ((*cdata & 128) > 0);
				pctr ++;
				bctr ++;
				if (bctr % dbits) 
					*cdata = *cdata << 1;
				else {	/* data boundary, refresh */
					cdata ++;
					bctr = 0;
				}
			}	
			break;
		case 2:
			cdata = (unsigned char *) imgbuf;
			for (i = 0; i< matlen; i++)
				matbuf[i] = cdata[i];	
			break;
		case 4:
			sidata = (short *) imgbuf;
			for (i = 0; i< matlen; i++)
				matbuf[i] = sidata[i];	
			break;
		case 8:
			idata = (int *) imgbuf;
			for (i = 0; i< matlen; i++)
				matbuf[i] = idata[i];	
			break;
		case 16:
			fdata = (float *) imgbuf;
			for (i = 0; i< matlen; i++)
				matbuf[i] = fdata[i];	
			break;
		case 32:
			ddata = (double *) imgbuf;
			for (i = 0; i< matlen; i++)
				matbuf[i] = ddata[i];
			break;
		default:
			mxFree(imgbuf);
			mxFree(matbuf);
			mexErrMsgTxt("Unrecognised datatype for conversion");

	}		
	mxFree(imgbuf);

	/* scale data unless second parameter is present and = 0 */
	k = 1;
	if (nrhs > 1)
		if (*(mxGetPr(prhs[1])) == 0)
			k = 0;
	if (k) 
		for (i = 0; i< matlen; i++)
			matbuf[i] = matbuf[i] * scale;

	/* return values for header info if required */
	if (nlhs > 1) {			/* dim */
/*		plhs[1] = mxCreateFull(1, 3 ,REAL); */
		plhs[1] = mxCreateDoubleMatrix(1, 3 ,mxREAL);     /* sm */
		ptr = mxGetPr(plhs[1]);
		ptr[0] = xdim;
		ptr[1] = ydim;
		ptr[2] = zdim;
	if (nlhs > 2) {			/* vox */
/*		plhs[2] = mxCreateFull(1, 3 ,REAL); */
		plhs[2] = mxCreateDoubleMatrix(1, 3 ,mxREAL);     /* sm */
		ptr = mxGetPr(plhs[2]);
		for (i=0; i<3; i++)
			ptr[i] = hdr.dime.pixdim[i+1];
	if (nlhs > 3) {		/* scale */
/*		plhs[3] = mxCreateFull(1, 1 ,REAL); */
		plhs[3] = mxCreateDoubleMatrix(1, 1 ,mxREAL);     /* sm */
		*mxGetPr(plhs[3]) = scale;
	if (nlhs > 4) {		/* type */
/*		plhs[4] = mxCreateFull(1, 1 ,REAL); */
		plhs[4] = mxCreateDoubleMatrix(1, 1 ,mxREAL);     /* sm */
		*mxGetPr(plhs[4]) = datatype;
	if (nlhs > 5) {		/* offset */
/*		plhs[5] = mxCreateFull(1, 1 ,REAL); */
		plhs[5] = mxCreateDoubleMatrix(1, 1 ,mxREAL);     /* sm */
		*mxGetPr(plhs[5]) = offset;
	if (nlhs > 6) {		/* origin */
/*		plhs[6] = mxCreateFull(1, 3 ,REAL); */
		plhs[6] = mxCreateDoubleMatrix(1, 3 ,mxREAL);     /* sm */
		ptr = mxGetPr(plhs[6]);
		memcpy(origin, &(hdr.hist.originator), 10);
		for (i=0; i<3; i++)
			ptr[i] = origin[i];
	if (nlhs > 7) {		/* description */
		plhs[7] = mxCreateString(hdr.hist.descrip);
	} } } } } } }
}



