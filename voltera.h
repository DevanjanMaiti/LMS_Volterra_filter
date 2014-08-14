/*
 * Voltera adaptive filter using LMS
 * This file has the required functions used by the main file
 *
 *
 * By
 * Pranav S Koundinya
 * Devanjan Maiti
 * Sreekar V
 * Nikhil Ravishankar
 *
 */
 #ifndef VOLTERRA_H
 #define VOLTERRA_H
 #ifndef VOLTERRA_COMMON_INCLUDES
 #define VOLTERRA_COMMON_INCLUDES
 #include <math.h>
 #include <stdio.h>

 #include "types.h"
 #include "xtensa/sim.h"
 #endif

 #define M 5	//filter memory
 #define VECTOR_LEN 55	//input vector length

  class DW {
  real32_T wts[VECTOR_LEN];              /* 'wts' */
  real32_T wts_Delay_IC_BUFF[VECTOR_LEN];/* 'wts_Delay' */

  real32_T x;                            /* 'x' */
  real32_T xn1;                          /* 'x(n-1)' */
  real32_T xn2;                          /* 'x(n-2)' */
  real32_T xn3;                          /* 'x(n-3)' */
  real32_T xn1_IC_BUFF;                  /* 'x(n-1)' */
  real32_T xn2_IC_BUFF;                  /* 'x(n-2)' */
  real32_T xn3_IC_BUFF;                  /* 'x(n-3)' */
  real32_T xn4_IC_BUFF;                  /* 'x(n-4)' */

  real32_T stepsize_Value[VECTOR_LEN];

  public:

  DW(void)
     {
    	int32_T i;

    	for(i = 0; i < VECTOR_LEN; i++)
    	{
    		wts[i] = 0;
    		wts_Delay_IC_BUFF[i] = 0;
    		if(i < M)
    			stepsize_Value[i] = 0.02;
    		else if (i < (M*(M+1)/2))
    			stepsize_Value[i] = 0.0008;
    		else
    			stepsize_Value[i] = 0.0003;
    	}

    	x = 0;
    	xn1 = 0;
    	xn2 = 0;
    	xn3 = 0;

    	xn1_IC_BUFF = 0;
    	xn2_IC_BUFF = 0;
    	xn3_IC_BUFF = 0;
    	xn4_IC_BUFF = 0;
     }


   real32_T Volterra_Mtap_step(const real32_T next_ip, const real32_T speaker_ip)
   {
  	int32_T k,i,j,l;
  	real32_T ux[VECTOR_LEN];
  	real32_T yError;
  	real32_T mul[VECTOR_LEN];

  	x = next_ip;

  	/* Voltera Model */
  	ux[0] = x;
  	xn1 = xn1_IC_BUFF;
  	ux[1] = xn1;
  	xn2 = xn2_IC_BUFF;
  	ux[2] = xn2;
  	xn3 = xn3_IC_BUFF;
  	ux[3] = xn3;
  	ux[4] = xn4_IC_BUFF;
  	j = 5;
  	for(k = 0; k < 5; k++)
  		for(i = k; i < 5; i++)
  			ux[j++] = ux[k] * ux[i];

  	for(l = 0; l < 5; l++)
  		for(k = l; k < 5; k++)
  			for(i = k; i < 5; i++)
  				ux[j++] = ux[l] * ux[k] * ux[i];

  	/* Update the delays on input */
  	xn1_IC_BUFF = x;
  	xn2_IC_BUFF = xn1;
  	xn3_IC_BUFF = xn2;
  	xn4_IC_BUFF = xn3;

  	/* End of Voltera Model */

  	/* Convolve and find error */
  	for (i = 0; i < VECTOR_LEN; i++)
  	{
  		wts[i] = wts_Delay_IC_BUFF[i];
          mul[i] = ux[i] * wts[i];
  	}

      yError = mul[0];
  	for (i = 0; i < VECTOR_LEN-1; i++)
  		yError += mul[i + 1];

  	yError = (speaker_ip) - yError;
  	/* End of Convolve and find error */



  	/* LMS */
  	for (i = 0; i < VECTOR_LEN-1; i++)
  	{
  		wts[i] += yError * stepsize_Value[i] * ux[i];
  		wts_Delay_IC_BUFF[i] = wts[i];
  	}
  	/* End of LMS */
  	return yError;
   }

 };

 /* Data required for code */

 extern  DW DW_l;

 #endif
