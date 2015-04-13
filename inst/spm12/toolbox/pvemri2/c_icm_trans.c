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
% Please cite this paper if you use the code
% 
% The incremental kmeans algorithm used to initialize the method (if the segmented image is 
% not given) is described in
% J.V. Manjón,  J. Tohka , G. García-Martí, J. Carbonell-Caballero, 
% J.J. Lull, L. Martí-Bonmatí and M. Robles.
% Robust MRI Brain Tissue Parameter Estimation by Multistage Outlier Rejection. 
% Magnetic Resonance in Medicine, 59:866 - 873, 2008. 
% Please cite additionally this paper if you use the incremental k-means 
% 
% --------------------------------------------------------------
% Permission to use, copy, modify, and distribute this software 
% for any purpose and without fee is hereby
% granted, provided that the above copyright notice appear in all
% copies.  The author and Tampere University of Technology make no representations
% about the suitability of this software for any purpose.  It is
% provided "as is" without express or implied warranty.
% -------------------------------------------------------------

  % *******************************************
  % Iterative conditional modes based MRF
  % *******************************************

function seg = icm_trans(img,brain_mask,beta,voxel_size,class_means,class_vars)
*/
#define getIndex(x,y,z,dims) ((x) + (y)*(dims[0]) + (z)*(dims[0])*(dims[1])) 
#define INTERVALS 8 /* must be even number */
#define MAXITER 150
#define NO_BOOK_KEEPING 0


#ifndef M_PI
#define M_PI           3.14159265358979323846
#endif

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
const double inter[7][7] = {{2, -1, -1, -1,  1,  -1, -1}, 
		{-1,   2,  -1, -1,  1,    1,  -1},
		{-1, -1,   2,  -1, -1,  1,    1},
		{-1, -1, -1,   2,  -1, -1,  1},
		{1,    1,   -1, -1, 2,   -1, -1},
		{-1,  1,     1,  -1, -1,  2,  -1},
        	{-1, -1,   1,    1,  -1, -1,  2}
};

double d[27];
const char pve[3][2] = {{3,0},
                 	{0,1},
                        {1,2}
};
clock_t start, fin;
double dif1,dif2;
double *img;
mxArray *mx_log_likelihood, *mx_book_keep;
const int *dims;
int segdims[3];
int llhooddims[4];
double beta;
double *voxel_size;
double *class_means;
double *class_vars;
int ndim,numel,x,y,z,t,c,i,x1,y1,z1,i1;
int iteration_counter,changed;
char *book_keep, *seg, *brain_mask;
double *log_likelihood;
double w;
char maxlabel,curr_label;
double maxprob;
double prior,likelihood;
double mu1,mu2,var1,var2;
double tmpmu[INTERVALS + 1];
double tmpvar[INTERVALS + 1];
double tmpnc[INTERVALS + 1];
double negtwotmpvar[INTERVALS + 1];
double tmpnc_pure[3];
/* int debugi,debugs; */

start = clock();
img = mxGetPr(prhs[0]);
ndim = mxGetNumberOfDimensions(prhs[0]);
dims= mxGetDimensions(prhs[0]);
brain_mask = (char*)mxGetData(prhs[1]);
beta = (double)mxGetScalar(prhs[2]);
voxel_size = mxGetPr(prhs[3]);
class_means = mxGetPr(prhs[4]);
class_vars = mxGetPr(prhs[5]);

segdims[0] = dims[0] + 2;
segdims[1] = dims[1] + 2;
segdims[2] = dims[2] + 2;
plhs[0] = mxCreateNumericArray(ndim,segdims,mxINT8_CLASS, mxREAL);
seg = (char*)mxGetData(plhs[0]);
mx_book_keep = mxCreateNumericArray(ndim,dims,mxINT8_CLASS, mxREAL);
book_keep = (char*)mxGetData(mx_book_keep);
llhooddims[0] = dims[0];
llhooddims[1] = dims[1];
llhooddims[2] = dims[2];
llhooddims[3] = 6;
mx_log_likelihood = mxCreateNumericArray(4,llhooddims,mxDOUBLE_CLASS, mxREAL);
log_likelihood = mxGetPr(mx_log_likelihood);
numel = dims[0]*dims[1]*dims[2];

i1 = 0;
for(z1 = -1;z1 < 2;z1++) {
  for(y1 = -1;y1 < 2;y1++)  {
    for(x1 = -1;x1 < 2;x1++)  {
      if((x1 == 0) && (y1 == 0) && (z1 == 0)) d[i1] = 0;
      else d[i1] = 1/(sqrt(pow(x1*voxel_size[0],2) + pow(y1*voxel_size[1],2) + pow(z1*voxel_size[2],2)));
      i1++;
    }
  }  
}


 for(c = 0;c < 3;c++) {
   tmpnc_pure[c] = log(1/(sqrt(2*M_PI*class_vars[c])));
 } 
  
  i = 0; /* voxel counter */
  for(z = 0;z < dims[2];z++) {
    for(y = 0;y < dims[1];y++)  {
      for(x = 0;x < dims[0];x++)  {
      	if(brain_mask[i] > 0) {
          for(c = 0;c < 3;c++) {  
           /* likelihood = (1/(sqrt(2*M_PI*class_vars[c])))*exp(-0.5*(img[i] - class_means[c])*(img[i] - class_means[c])/class_vars[c]);
            log_likelihood[i + c*numel] = log(likelihood); */
            log_likelihood[i + c*numel] = (-0.5*(img[i] - class_means[c])*(img[i] - class_means[c])/class_vars[c]) + tmpnc_pure[c];
          }
        }
        i++;
      }
    }
  }  

  for(c = 3;c < 6;c++) {  
    mu1 = class_means[pve[c - 3][0]];
    mu2 = class_means[pve[c - 3][1]];
    var1 = class_vars[pve[c - 3][0]];
    var2 = class_vars[pve[c - 3][1]];
    for(t = 0; t < (INTERVALS + 1);t++) {
      w = ((double) t)/INTERVALS;  
      tmpmu[t] = w*mu1 + (1 - w)*mu2;
      tmpvar[t] = w*w*var1 + (1 - w*w)*var2;
      tmpnc[t] = (1/sqrt(2*M_PI*tmpvar[t]))*(1/ ((double) INTERVALS)); 
      negtwotmpvar[t] = 1/((-2)*tmpvar[t]);
    }
    /* For trapezoid rule 
    tmpnc[0] = tmpnc[0]/2;
    tmpnc[INTERVALS] = tmpnc[INTERVALS]/2; */
    /* For Simpson's rule */
    tmpnc[0] = tmpnc[0]/3;
    tmpnc[INTERVALS] = tmpnc[INTERVALS]/3;  
    for(t = 1; t < (INTERVALS - 1);t = t + 2) {
      tmpnc[t] = 4*tmpnc[t]/3;
      tmpnc[t + 1] = 2*tmpnc[t + 1]/3;
    } 
    tmpnc[INTERVALS - 1] = 4*tmpnc[INTERVALS - 1]/3; 
    i = 0;
    for(z = 0;z < dims[2];z++) {
      for(y = 0;y < dims[1];y++)  {
      	for(x = 0;x < dims[0];x++) { 	
      	  if(brain_mask[i] > 0) {
      	    likelihood = 0.0;	  
      	   /*  This for (composite) trapezoid rule
      	      and the Simpon's rule */
      	    for(t = 0; t < (INTERVALS + 1);t++) {
      	      likelihood = likelihood + tmpnc[t]*exp(negtwotmpvar[t]*(img[i] - tmpmu[t])*(img[i] - tmpmu[t]));
      	    }
      	    log_likelihood[i + c*numel] = log(likelihood);	        	    
          }
          i++;
        }
      }  
    }        
  }  
  
  fin = clock();
  dif1 = (double)(fin - start)/CLOCKS_PER_SEC;
  start = clock();  
  i = 0;
  for(z = 0;z < dims[2];z++) {
    for(y = 0;y < dims[1];y++)  {
      for(x = 0;x < dims[0];x++)  {
      	if(brain_mask[i] > 0) {
          maxlabel = 1;
          maxprob = log_likelihood[i];
          book_keep[i] = 1;
          for(c = 1;c < 6;c++) {
            if(log_likelihood[i + c*numel] > maxprob) {
              maxlabel = c + 1;
              maxprob = log_likelihood[i + c*numel];
            }
          }
          seg[getIndex(x + 1,y + 1,z + 1,segdims)] = maxlabel;
        }
      i++;  
      }
    }  
  }
  
  iteration_counter = 0;
  changed = 1;
   while((changed > 0) && (iteration_counter < MAXITER)) {
     iteration_counter++; 	   
     changed = 0;
     i = 0;
     
     for(z = 0;z < dims[2];z++) {
       for(y = 0;y < dims[1];y++)  {
         for(x = 0;x < dims[0];x++)  {
           if(book_keep[i] > 0)  {
             curr_label = seg[getIndex(x + 1,y + 1,z + 1,segdims)];
             maxprob = -10000.0;
             maxlabel = 1;
             for(c = 0;c < 6;c++) {
               prior = 0.0;
               /* running the loops from 0 to 2 (rather than from - 1 to 1)
                  takes into account the extension of the seg matrix */
               i1 = 0;   
               for(z1 = 0;z1 < 3;z1++) {
                 for(y1 = 0;y1 < 3;y1++)  {
                   for(x1 = 0;x1 < 3;x1++)  {
                      	   
                     prior = prior + d[i1]*inter[c + 1][seg[getIndex(x + x1,y + y1,z + z1,segdims)]];
                     i1++;
                   }
                 }  
               }
               
               likelihood = log_likelihood[i + c*numel] + beta*prior;
               if(likelihood > maxprob) {
                 maxlabel = c + 1;
                 maxprob = likelihood;
               } 
             }
             if(maxlabel != curr_label)  {
               seg[getIndex(x + 1,y + 1,z + 1,segdims)] = maxlabel;
               changed++; 
               for(z1 = 0;z1 < 3;z1++) {
                 for(y1 = 0;y1 < 3;y1++)  {
                   for(x1 = 0;x1 < 3;x1++)  {     
                     if(seg[getIndex(x + x1,y + y1,z + z1,segdims)] != 0) {
             	       book_keep[getIndex(x + x1 - 1,y + y1 - 1,z + z1 - 1,dims)] = 1;
             	     }
             	   }  
                 }
               }
             }  
             else  {
               book_keep[i] = NO_BOOK_KEEPING;
             } 
           }
           i++;
         }
       }
     }
     
  }
  fin = clock();
  dif2 = ((double)(fin - start))/CLOCKS_PER_SEC;
  printf("ICM finished %d %4.2f %4.2f %4.2f \n ",iteration_counter,dif1,dif2,dif1 + dif2);
/*  printf("ICM finished after %d iterations \n ",iteration_counter);
  printf("Time consumed before ICM %.4lf s \n ",dif1);
  printf("Time consumed by ICM %.4lf  s \n ",dif2); */
  mxDestroyArray(mx_log_likelihood);
  mxDestroyArray(mx_book_keep);
  return;
}
  

 
 
  
