#include "math.h"

#include "mex.h"

#include <stdlib.h>

#include "matrix.h"



/*  function I = Info_Map_Gen(Ref,init,cc,vsx,vsy,vsz);
// Function to produce the information potential map for segmenting the left
// and right hemispheres of human brain in 3D MR images.

//-------------------------------------------------------------------------
// Usage
//-------------------------------------------------------------------------

// 1. Input: 

//    Ref: A labeled brain mask indicating each voxel is located at the
//         information source/termination, rest boundary or interior brain.
 
//    init: A brain mask where each voxel is given a initial information 
//          potential value for the simulated information transmission process.   

//    cc: A small constant as the criterion of convergence. The iterative
//        numerical implementation will stop when the converging progress 
//        is smaller than cc. Generally, 0.001 is recommended.
 
//    vsx: The voxel size of x direction.
 
//    vsx: The voxel size of y direction.
 
//    vsx: The voxel size of z direction.

// 2. Output:

//    IPM: The information potential map, presenting the steady state of the 
//         information transmission process from the left brain hemisphere 
//         to the right, for the input brain volume.

//-------------------------------------------------------------------------
// Copyright (C) 2010 Lu Zhao
// McConnell Brain Imaging Center,
// Montreal Neurological Institute,
// McGill University, Montreal, QC, Canada
// zhao<at>bic.mni.mcgill.ca
// ------------------------------------------------------------------------

// The method is described in
// L. Zhao, U. Ruotsalainen, J. Hirvonen, J. Hietala and J. Tohka.
// Automatic cerebral and cerebellar hemisphere segmentation in 3D MRI:
// adaptive disconnection algorithm. Medical Image Analysis, 14(3):360-372, 
// 2010.

// L. Zhao, J. Tohka, U. Ruotsalainen, 'Accurate 3D left-right brain 
// hemisphere segmentation in MR images based on shape bottlenecks and 
// partial volume estimation', Lecture Notes in Computer Science 4522, 
// pages 581 - 590, 2007.

// -------------------------------------------------------------------------
// Permission to use, copy, modify, and distribute this software
// for any purpose and without fee is hereby granted, provided that 
// the above copyright notice appear in all copies.  The author 
// makes no representations about the suitability of this software for 
// any purpose. It is provided "as is" without express or implied warranty.
// ------------------------------------------------------------------------



//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//-------------------------------------------------------------------------
// Find the boundary and interior region of the input brain volume, and 
// define the Information Source and Terminal on the boundary. 
//-------------------------------------------------------------------------

//--------------------------------------------------------------------------
// Numerical implementation
//--------------------------------------------------------------------------



*/



#define getIndex(x,y,z,dims) ((x) + (y)*(dims[0]) + (z)*(dims[0])*(dims[1]))

#define LEVELS 2



void constructPyramid(char *Ref_low, double *I_low, const char *Ref, 

	              const double *I, const int *dims, const int *dims_low_level,

	              int level)

{

int low_index;

int x,y,z,i;

int leveltmp,levelplus,tr;



leveltmp = 2*level;

levelplus = level + 1;

tr = leveltmp*leveltmp*level;



i = 0;

for(z = 0;z < dims[2];z++) {

    for(y = 0;y < dims[1];y++)  {

      for(x = 0;x < dims[0];x++)  {   

      	if(Ref[i] > 0) { 

          low_index = getIndex(x/leveltmp,y/leveltmp,z/leveltmp,dims_low_level);

          Ref_low[low_index]++;

        }

        i++;

      }

    }

  }



i = 0;  

 for(z = 0;z < dims_low_level[2];z++) {

    for(y = 0;y < dims_low_level[1];y++)  {

      for(x = 0;x < dims_low_level[0];x++)  { 

        if(Ref_low[i] > tr) Ref_low[i] = 3;

        else Ref_low[i] = 0;

        i++;

      }  

    }

  }

  

  

i = 0;	

for(z = 0;z < dims[2];z++) {

  for(y = 0;y < dims[1];y++)  {

    for(x = 0;x < dims[0];x++)  {   

      if(Ref[i] > 0) {     

        low_index = getIndex(x/leveltmp,y/leveltmp,z/leveltmp,dims_low_level);  

      	if(Ref_low[low_index] > 0) {

      	  if(Ref[i] == 4) {

      	    Ref_low[low_index] = 4;

      	    I_low[low_index] = I[i];

      	  }

      	  else if((Ref[i] == 1) && (Ref_low[low_index] != 4)) {

      	    Ref_low[low_index] = 1;

      	    I_low[low_index] = I[i];

      	  }

      	  else if((Ref_low[low_index] != 4) && (Ref_low[low_index] != 1)) {

            I_low[low_index] = I[i];

          }

        }

      }  

      i++;         

    }

  } 

}

/* Finally inspect the borders */

i = 0;  

 for(z = 0;z < dims_low_level[2];z++) {

    for(y = 0;y < dims_low_level[1];y++)  {

      for(x = 0;x < dims_low_level[0];x++)  { 

      	if(Ref_low[i] == 3) {

      	  if( (Ref_low[getIndex(x -1,y,z,dims_low_level)] == 0) ||

      	       (Ref_low[getIndex(x +1,y,z,dims_low_level)] == 0) ||

              (Ref_low[getIndex(x,y - 1,z,dims_low_level)] == 0) ||

              (Ref_low[getIndex(x,y + 1,z,dims_low_level)] == 0) ||

              (Ref_low[getIndex(x,y,z - 1,dims_low_level)] == 0) ||

              (Ref_low[getIndex(x,y,z + 1,dims_low_level)] == 0)) {

            Ref_low[i] = 2;

            if( (Ref_low[getIndex(x -1,y,z,dims_low_level)] == 0) &&

      	       (Ref_low[getIndex(x +1,y,z,dims_low_level)] == 0) &&

              (Ref_low[getIndex(x,y - 1,z,dims_low_level)] == 0) &&

              (Ref_low[getIndex(x,y + 1,z,dims_low_level)] == 0) &&

              (Ref_low[getIndex(x,y,z - 1,dims_low_level)] == 0) &&

              (Ref_low[getIndex(x,y,z + 1,dims_low_level)] == 0))

            Ref_low[i] = 0; /* this to avoid isolated points */

            

          }

        }

      i++;  

      }  

    }

  }

  

return;

}	





void getUpperLevel(double *I_low, const char *Ref_low, 

	              double *I, const char *Ref, const int *dims_low_level, const int *dims_up_level)

{

int low_index;

int x,y,z,i;

int leveltmp;





leveltmp = 2;

i = 0;	

for(z = 0;z < dims_up_level[2];z++) {

  for(y = 0;y < dims_up_level[1];y++)  {

    for(x = 0;x < dims_up_level[0];x++)  {   

      if((Ref[i] > 0) && (Ref[i] != 1) && (Ref[i] != 4)) {     

	low_index = getIndex(x/leveltmp,y/leveltmp,z/leveltmp,dims_low_level);

	if(Ref_low[low_index] > 0)

	  I[i] = I_low[low_index];

      }

      i++;

    }

  }

}



return;

}

	

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])

{

	



char *Ref;

double *Q,*I;

double *I_low1,*I_low2,*I_low;

char *Ref_low1,*Ref_low2,*Ref_low;

double w,vsx,vsy,vsz,vx,vy,vz,vi1,vi2,improvement,perc_impr,cc,improvement_max;



int x,y,z,iteration_time,ndim,numel,i,j,level;

double d,T,N;

const int  *dims;

mxArray *mx_I_low1, *mx_Ref_low1,*mx_I_low2, *mx_Ref_low2;

int dims_low[LEVELS + 1][3];





Ref = (char*)mxGetData(prhs[0]);

ndim = mxGetNumberOfDimensions(prhs[0]);

dims= mxGetDimensions(prhs[0]);

vsx = (double)mxGetScalar(prhs[3]);

vsy = (double)mxGetScalar(prhs[4]);

vsz = (double)mxGetScalar(prhs[5]);



cc = (double)mxGetScalar(prhs[2]); 

I = mxGetPr(prhs[1]);

plhs[0] = mxCreateNumericArray(ndim,dims,mxDOUBLE_CLASS, mxREAL);

Q = mxGetPr(plhs[0]);



w = 1.5;



vx = 1/(vsx*vsx);

vy = 1/(vsy*vsy);

vz = 1/(vsz*vsz);

vi1= 1-w;

vi2 = w*(1/(2*(vx+vy+vz)));



iteration_time = 0;

perc_impr = 1;  

numel = dims[0]*dims[1]*dims[2];





for(j = 0;j < 3;j++) {

  dims_low[0][j] = dims[j];

}

for(i = 0;i < LEVELS;i++) {

  for(j = 0;j < 3;j++) {	

    dims_low[i+ 1][j] = dims_low[i][j]/2 + 1;

  }  

}





/* perform 1 iteration at full level to find out the termination threshold */

for(i = 0;i < numel;i++) 

  {

    Q[i] = I[i];

  } 



 improvement = 0.0;

  i = 0; /* voxel counter */

  for(z = 0;z < dims[2];z++) {

    for(y = 0;y < dims[1];y++)  {

      for(x = 0;x < dims[0];x++)  {

       	if(Ref[i] == 3) { /* For interior region, the usual consistent second order discrete Laplace equation is used */

       	  I[i] = vi1*I[i] + vi2*(vx*(I[getIndex(x + 1,y,z,dims)] +I[getIndex(x - 1,y,z,dims)])

                               + vy*(I[getIndex(x,y + 1,z,dims)]+I[getIndex(x,y - 1,z,dims)])

                               + vz*(I[getIndex(x,y,z + 1,dims)]+I[getIndex(x,y,z - 1,dims)]));

          if(I[i] > Q[i]) {

            improvement = improvement + I[i] - Q[i];

          }

          else {

            improvement = improvement + Q[i] - I[i];

          } 

          Q[i] = I[i];

        }                        

        else if(Ref[i] == 2) { /* For the rest of the boundary, the Neumann boundary condition is used */

          d = 0.0; 

          T = 0.0; 

          N = 0.0; 

          if( (Ref[getIndex(x + 1,y,z,dims)] != 0) || (Ref[getIndex(x - 1,y,z,dims)] != 0)) {

            d = d + vx;

            if( (Ref[getIndex(x + 1,y,z,dims)] != 0) && (Ref[getIndex(x - 1,y,z,dims)] != 0)) {

              T = T + vx*(I[getIndex(x + 1,y,z,dims)] + I[getIndex(x - 1,y,z,dims)]);

             

            }

            else {

              N = N + vx*(I[getIndex(x + 1,y,z,dims)] + I[getIndex(x - 1,y,z,dims)]);

              

            }

          }

        

          if( (Ref[getIndex(x,y + 1,z,dims)] != 0) || (Ref[getIndex(x,y - 1,z,dims)] != 0)) {

            d = d + vy;

            if( (Ref[getIndex(x,y + 1,z,dims)] != 0) && (Ref[getIndex(x,y - 1,z,dims)] != 0)) {

              T = T + vy*(I[getIndex(x,y + 1,z,dims)] + I[getIndex(x,y - 1,z,dims)]);

            }

            else {

              N = N + vy*(I[getIndex(x,y + 1,z,dims)] + I[getIndex(x,y - 1,z,dims)]);                        

            }

          }         

          if( (Ref[getIndex(x,y,z + 1,dims)] != 0) || (Ref[getIndex(x,y,z - 1,dims)] != 0)) {

            d = d + vz;

            if( (Ref[getIndex(x,y,z + 1,dims)] != 0) && (Ref[getIndex(x,y,z - 1,dims)] != 0)) {

              T = T + vz*(I[getIndex(x,y,z + 1,dims)] + I[getIndex(x,y,z - 1,dims)]);

            }

            else {

              N = N + vz*(I[getIndex(x,y,z + 1,dims)] + I[getIndex(x,y,z - 1,dims)]);                        

            }

          }

   

          I[i] = vi1*I[i] + w*((1/d)*N + (1/(2*d))*T);

         if(I[i] > Q[i]) {

           improvement = improvement + I[i] - Q[i];

         }

         else {

           improvement = improvement + Q[i] - I[i];

         }    

         Q[i] = I[i]; 

        }

        i++;

      }

    }

  }  

  improvement_max = improvement;

  /* Generate lower level pyramids */

  /* mx_I_low1 */

  

  mx_I_low1 = mxCreateNumericArray(ndim,dims_low[1],mxDOUBLE_CLASS, mxREAL);

  I_low1 = mxGetPr(mx_I_low1);

  mx_Ref_low1 =  mxCreateNumericArray(ndim,dims_low[1],mxINT8_CLASS, mxREAL);

  Ref_low1 = (char*)mxGetData(mx_Ref_low1);

  mx_I_low2 = mxCreateNumericArray(ndim,dims_low[2],mxDOUBLE_CLASS, mxREAL);

  I_low2 = mxGetPr(mx_I_low2);

  mx_Ref_low2  =  mxCreateNumericArray(ndim,dims_low[2],mxINT8_CLASS, mxREAL);

  Ref_low2 = (char*)mxGetData(mx_Ref_low2);



  constructPyramid(Ref_low1,I_low1,Ref,I,dims,dims_low[1],1);

  constructPyramid(Ref_low2,I_low2,Ref,I,dims,dims_low[2],2);  

 

  /* Run lower level pyramids */

  level = 2;  

  I_low = I_low2;

  Ref_low = Ref_low2;

  

for(iteration_time = 0;iteration_time < 200;iteration_time++) {

  i = 0; /* voxel counter */

  for(z = 0;z < dims_low[level][2];z++) {

     for(y = 0;y < dims_low[level][1];y++)  {

       for(x = 0;x < dims_low[level][0];x++)  {

       	if(Ref_low[i] == 3) { /* For interior region, the usual consistent second order discrete Laplace equation is used */

       	  I_low[i] = vi1*I_low[i] + vi2*(vx*(I_low[getIndex(x + 1,y,z,dims_low[level])] +I_low[getIndex(x - 1,y,z,dims_low[level])])

                               + vy*(I_low[getIndex(x,y + 1,z,dims_low[level])]+I_low[getIndex(x,y - 1,z,dims_low[level])])

                               + vz*(I_low[getIndex(x,y,z + 1,dims_low[level])]+I_low[getIndex(x,y,z - 1,dims_low[level])]));

          

        }                        

        else if(Ref_low[i] == 2) { /* For the rest of the boundary, the Neumann boundary condition is used */

          d = 0.0; 

          T = 0.0; 

          N = 0.0; 

          if( (Ref_low[getIndex(x + 1,y,z,dims_low[level])] != 0) || (Ref_low[getIndex(x - 1,y,z,dims_low[level])] != 0)) {

            d = d + vx;

            if( (Ref_low[getIndex(x + 1,y,z,dims_low[level])] != 0) && (Ref_low[getIndex(x - 1,y,z,dims_low[level])] != 0)) {

              T = T + vx*(I_low[getIndex(x + 1,y,z,dims_low[level])] + I_low[getIndex(x - 1,y,z,dims_low[level])]);

             

            }

            else {

              N = N + vx*(I_low[getIndex(x + 1,y,z,dims_low[level])] + I_low[getIndex(x - 1,y,z,dims_low[level])]);

              

            }

          }

        

          if( (Ref_low[getIndex(x,y + 1,z,dims_low[level])] != 0) || (Ref_low[getIndex(x,y - 1,z,dims_low[level])] != 0)) {

            d = d + vy;

            if( (Ref_low[getIndex(x,y + 1,z,dims_low[level])] != 0) && (Ref_low[getIndex(x,y - 1,z,dims_low[level])] != 0)) {

              T = T + vy*(I_low[getIndex(x,y + 1,z,dims_low[level])] + I_low[getIndex(x,y - 1,z,dims_low[level])]);

            }

            else {

              N = N + vy*(I_low[getIndex(x,y + 1,z,dims_low[level])] + I_low[getIndex(x,y - 1,z,dims_low[level])]);                        

            }

          }         

          if( (Ref_low[getIndex(x,y,z + 1,dims_low[level])] != 0) || (Ref_low[getIndex(x,y,z - 1,dims_low[level])] != 0)) {

            d = d + vz;

            if( (Ref_low[getIndex(x,y,z + 1,dims_low[level])] != 0) && (Ref_low[getIndex(x,y,z - 1,dims_low[level])] != 0)) {

              T = T + vz*(I_low[getIndex(x,y,z + 1,dims_low[level])] + I_low[getIndex(x,y,z - 1,dims_low[level])]);

            }

            else {

              N = N + vz*(I_low[getIndex(x,y,z + 1,dims_low[level])] + I_low[getIndex(x,y,z - 1,dims_low[level])]);                        

            }

          }

   

          I_low[i] = vi1*I_low[i] + w*((1/d)*N + (1/(2*d))*T);

        

        }

        i++;	  

      }

    }

  }

}



getUpperLevel(I_low, Ref_low,I_low1,Ref_low1,dims_low[2],dims_low[1]); 



level = 1;  

I_low = I_low1;

Ref_low = Ref_low1;

  

for(iteration_time = 0;iteration_time < 500;iteration_time++) {

  i = 0; /* voxel counter */

    for(z = 0;z < dims_low[level][2];z++) {

     for(y = 0;y < dims_low[level][1];y++)  {

       for(x = 0;x < dims_low[level][0];x++)  {

       	if(Ref_low[i] == 3) { /* For interior region, the usual consistent second order discrete Laplace equation is used */

       	  I_low[i] = vi1*I_low[i] + vi2*(vx*(I_low[getIndex(x + 1,y,z,dims_low[level])] +I_low[getIndex(x - 1,y,z,dims_low[level])])

                               + vy*(I_low[getIndex(x,y + 1,z,dims_low[level])]+I_low[getIndex(x,y - 1,z,dims_low[level])])

                               + vz*(I_low[getIndex(x,y,z + 1,dims_low[level])]+I_low[getIndex(x,y,z - 1,dims_low[level])]));

          

        }                        

        else if(Ref_low[i] == 2) { /* For the rest of the boundary, the Neumann boundary condition is used */

          d = 0.0; 

          T = 0.0; 

          N = 0.0; 

          if( (Ref_low[getIndex(x + 1,y,z,dims_low[level])] != 0) || (Ref_low[getIndex(x - 1,y,z,dims_low[level])] != 0)) {

            d = d + vx;

            if( (Ref_low[getIndex(x + 1,y,z,dims_low[level])] != 0) && (Ref_low[getIndex(x - 1,y,z,dims_low[level])] != 0)) {

              T = T + vx*(I_low[getIndex(x + 1,y,z,dims_low[level])] + I_low[getIndex(x - 1,y,z,dims_low[level])]);

             

            }

            else {

              N = N + vx*(I_low[getIndex(x + 1,y,z,dims_low[level])] + I_low[getIndex(x - 1,y,z,dims_low[level])]);

              

            }

          }

        

          if( (Ref_low[getIndex(x,y + 1,z,dims_low[level])] != 0) || (Ref_low[getIndex(x,y - 1,z,dims_low[level])] != 0)) {

            d = d + vy;

            if( (Ref_low[getIndex(x,y + 1,z,dims_low[level])] != 0) && (Ref_low[getIndex(x,y - 1,z,dims_low[level])] != 0)) {

              T = T + vy*(I_low[getIndex(x,y + 1,z,dims_low[level])] + I_low[getIndex(x,y - 1,z,dims_low[level])]);

            }

            else {

              N = N + vy*(I_low[getIndex(x,y + 1,z,dims_low[level])] + I_low[getIndex(x,y - 1,z,dims_low[level])]);                        

            }

          }         

          if( (Ref_low[getIndex(x,y,z + 1,dims_low[level])] != 0) || (Ref_low[getIndex(x,y,z - 1,dims_low[level])] != 0)) {

            d = d + vz;

            if( (Ref_low[getIndex(x,y,z + 1,dims_low[level])] != 0) && (Ref_low[getIndex(x,y,z - 1,dims_low[level])] != 0)) {

              T = T + vz*(I_low[getIndex(x,y,z + 1,dims_low[level])] + I_low[getIndex(x,y,z - 1,dims_low[level])]);

            }

            else {

              N = N + vz*(I_low[getIndex(x,y,z + 1,dims_low[level])] + I_low[getIndex(x,y,z - 1,dims_low[level])]);                        

            }

          }

   

          I_low[i] = vi1*I_low[i] + w*((1/d)*N + (1/(2*d))*T);

        

        }

        i++;	  

      }

    }

  }    

  }

  getUpperLevel(I_low, Ref_low,I,Ref,dims_low[1],dims_low[0]);

 

 /* mxDestroyArray(mx_I_low1);

  mxDestroyArray(mx_Ref_low1);

  mxDestroyArray(mx_I_low2);

  mxDestroyArray(mx_Ref_low2); */

  

  for(i = 0;i < numel;i++) 

  {

    Q[i] = I[i];

  } 

 

  iteration_time = 0;

  while(perc_impr > cc)  { 

  improvement = 0.0;

  i = 0; /* voxel counter */

  for(z = 0;z < dims[2];z++) {

    for(y = 0;y < dims[1];y++)  {

      for(x = 0;x < dims[0];x++)  {

       	if(Ref[i] == 3) { /* For interior region, the usual consistent second order discrete Laplace equation is used */

       	  I[i] = vi1*I[i] + vi2*(vx*(I[getIndex(x + 1,y,z,dims)] +I[getIndex(x - 1,y,z,dims)])

                               + vy*(I[getIndex(x,y + 1,z,dims)]+I[getIndex(x,y - 1,z,dims)])

                               + vz*(I[getIndex(x,y,z + 1,dims)]+I[getIndex(x,y,z - 1,dims)]));

          if(I[i] > Q[i]) {

            improvement = improvement + I[i] - Q[i];

          }

          else {

            improvement = improvement + Q[i] - I[i];

          } 

          Q[i] = I[i];

        }                        

        else if(Ref[i] == 2) { /* For the rest of the boundary, the Neumann boundary condition is used */

          d = 0.0; 

          T = 0.0; 

          N = 0.0; 

          if( (Ref[getIndex(x + 1,y,z,dims)] != 0) || (Ref[getIndex(x - 1,y,z,dims)] != 0)) {

            d = d + vx;

            if( (Ref[getIndex(x + 1,y,z,dims)] != 0) && (Ref[getIndex(x - 1,y,z,dims)] != 0)) {

              T = T + vx*(I[getIndex(x + 1,y,z,dims)] + I[getIndex(x - 1,y,z,dims)]);

             

            }

            else {

              N = N + vx*(I[getIndex(x + 1,y,z,dims)] + I[getIndex(x - 1,y,z,dims)]);

              

            }

          }

        

          if( (Ref[getIndex(x,y + 1,z,dims)] != 0) || (Ref[getIndex(x,y - 1,z,dims)] != 0)) {

            d = d + vy;

            if( (Ref[getIndex(x,y + 1,z,dims)] != 0) && (Ref[getIndex(x,y - 1,z,dims)] != 0)) {

              T = T + vy*(I[getIndex(x,y + 1,z,dims)] + I[getIndex(x,y - 1,z,dims)]);

            }

            else {

              N = N + vy*(I[getIndex(x,y + 1,z,dims)] + I[getIndex(x,y - 1,z,dims)]);                        

            }

          }         

          if( (Ref[getIndex(x,y,z + 1,dims)] != 0) || (Ref[getIndex(x,y,z - 1,dims)] != 0)) {

            d = d + vz;

            if( (Ref[getIndex(x,y,z + 1,dims)] != 0) && (Ref[getIndex(x,y,z - 1,dims)] != 0)) {

              T = T + vz*(I[getIndex(x,y,z + 1,dims)] + I[getIndex(x,y,z - 1,dims)]);

            }

            else {

              N = N + vz*(I[getIndex(x,y,z + 1,dims)] + I[getIndex(x,y,z - 1,dims)]);                        

            }

          }

   

          I[i] = vi1*I[i] + w*((1/d)*N + (1/(2*d))*T);

         if(I[i] > Q[i]) {

           improvement = improvement + I[i] - Q[i];

         }

         else {

           improvement = improvement + Q[i] - I[i];

         }    

         Q[i] = I[i]; 

        }

        i++;

      }

    }

  }

  iteration_time = iteration_time + 1; 

  perc_impr = improvement/improvement_max;

  

  

}





return;

  }

