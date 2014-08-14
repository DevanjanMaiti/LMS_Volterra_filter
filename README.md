LMS_Volterra_filter
===================

This project contains the source code for the LMS implementation of a 3rd order, 5 tap Volterra Model filter.


--------------------------------------------------------------------------------------------------------------------------
      FILE NAME                           DESCRIPTION
--------------------------------------------------------------------------------------------------------------------------  

	1. execute.m                 Contains code to compile using system commands
	2. exporttwovectors.m 	     Exports data into a txt file	
	3. types.h 		     Contains additional types and typcasting			 
	4. voltera.h 		     Header file to suport the main file contains the volterra model and LMS algorithm 
	5. Volterra_LMS.m            The main Matlab code to run. Also has a Matlab simulation of the filter
	6. xt_main.c		     Main C code
	
--------------------------------------------------------------------------------------------------------------------------

The MATLAB code execute.m runs the MATLAB code to perform the filter simulation and also calls the ISS code to do the same, simultaneously. The graphical results that are obtained contain outputs for both the MATLAB as well as the ISS simulation.
