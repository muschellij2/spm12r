#include "math.h"
#include "mex.h"
#include <stdlib.h>
#include "matrix.h"
#include <stdio.h>
#include <time.h>

/* Partial volume estimation in brain MRI with TMCD method
% C routine for solving the MRF using ICM algorithm
% (C) 2010 Jussi Tohka 
% Department of Signal Processing,
% Tampere University of Technology, Finland
% jussi.tohka at tut.fi
% -------------------------------------------------------------
% The method is described in 
% J. Tohka, A. Zijdenbos, and A. Evans. 
% Fast and robust parameter estimation for statistical partial volume models in brain MRI. 
% NeuroImage, 23(1):84 - 97, 2004. 
% Please cite this paper if you use the code */

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	
const char pve[3][2] = {{0,3},
                 	{0,1},
                        {1,2}
};
int ndim,numel,indexmin,x,y,z,t,c,i;
double mu1,mu2,var1,var2;
double w,score,scoremin;
const int *dims;
int dims2[3];
double *class_means;
double *class_vars;
double tmpmu[101];
double tmpvar[101];
double regterm[101];
double tmponepervar[101];
double *tfe;
double *img;
char *cls;


img = mxGetPr(prhs[0]);
ndim = mxGetNumberOfDimensions(prhs[0]);
dims= mxGetDimensions(prhs[0]);	
cls = (char*)mxGetData(prhs[1]);
class_means = mxGetPr(prhs[2]);
class_vars = mxGetPr(prhs[3]);	
dims2[0] = dims[0];
dims2[1] = dims[1];
dims2[2] = dims[2];
dims2[3] = 3;
plhs[0] = mxCreateNumericArray(ndim + 1,dims2,mxDOUBLE_CLASS, mxREAL);
tfe = mxGetPr(plhs[0]);
numel = dims[0]*dims[1]*dims[2];
  i = 0; /* voxel counter */
  for(z = 0;z < dims[2];z++) {
    for(y = 0;y < dims[1];y++)  {
      for(x = 0;x < dims[0];x++)  {
      	if(cls[i] == 1) {
          tfe[i] = 1.0;
          tfe[i + numel] = 0.0;
          tfe[i + 2*numel] = 0.0;
        }
        if(cls[i] == 2) {
          tfe[i] = 0.0;
          tfe[i + numel] = 1.0;
          tfe[i + 2*numel] = 0.0;
        }
        if(cls[i] == 3) {
          tfe[i] = 0.0;
          tfe[i + numel] = 0.0;
          tfe[i + 2*numel] = 1.0;
        }
        i++;
      } 
    }
  }  
  
  for(c = 4;c < 7;c++) {
    mu1 = class_means[pve[c - 4][0]];
    mu2 = class_means[pve[c - 4][1]];
    var1 = class_vars[pve[c - 4][0]];
    var2 = class_vars[pve[c - 4][1]];	  
    for(t = 0;t < 101;t++) {
      w = ((double) t)/100;	    
      tmpmu[t] = w*mu1 + (1 - w)*mu2;
      tmpvar[t] = w*w*var1 + (1 - w*w)*var2;
      regterm[t] = log(tmpvar[t]);
      tmponepervar[t] = 1/(tmpvar[t]);
    }  
    i = 0; /* voxel counter */
    for(z = 0;z < dims[2];z++) {
      for(y = 0;y < dims[1];y++)  {
        for(x = 0;x < dims[0];x++)  {
      	  if(cls[i] == c) {
      	    scoremin = (img[i] - tmpmu[0])*(img[i] - tmpmu[0])*tmponepervar[0] + regterm[0];
      	    indexmin = 0;
      	    for(t = 1;t < 101;t++) {
              score = (img[i] - tmpmu[t])*(img[i] - tmpmu[t])*tmponepervar[t] + regterm[t];
              if(score < scoremin) {
              	 scoremin = score;
              	 indexmin = t;
              }
            }
            if(c == 4) {
             tfe[i] = ((double) indexmin)/100;
             tfe[i + numel] = 0.0;
             tfe[i + 2*numel] = 0.0;
            }
            if(c == 5) {
              tfe[i] = ((double) indexmin)/100;
              tfe[i + numel] = 1.0 - ((double) indexmin)/100;
              tfe[i + 2*numel] = 0.0;
            }
            if(c == 6) {
              tfe[i] = 0.0;
              tfe[i + numel] = ((double) indexmin)/100;
              tfe[i + 2*numel] = 1.0 - ((double) indexmin)/100;
            }
          }  
          i++;
        }
      }
    }
  } 
  return;
}
