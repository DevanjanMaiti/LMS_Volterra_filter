/*
 * Volterra adaptive filter using LMS
 * This is the main file
 *
 *
 * By
 * Pranav S Koundinya
 * Devanjan Maiti
 * Sreekar V
 * Nikhil Ravishankar
 *
 */
 
 #include "voltera.h"
 #include "types.h"

 #define MAXVECTORSIZE 1000

 FILE *fin, *fout;

 void rt_OneStep(void);

 int main (int argc, const char *argv[])
 {
	int i, size;
	DW DW_l;
	real32_T inp[MAXVECTORSIZE], desired[MAXVECTORSIZE], err[MAXVECTORSIZE];
	xt_iss_client_command("profile", "disable"); // Disable profiling, in case it has not been done when xt-run (ISS) has been called
	xt_iss_switch_mode(XT_ISS_FUNCTIONAL); // Start off in turbo mode for argument processing and reading the input files.

	if (argc != 3)
	{
		fprintf(stderr,"ERROR - There must be 2 user arguments: the first being the input file and the second being the output file.\n"
		" You have %d user arguments. Quitting.\n", (argc-1));
		return 1;
	}
	if ((fin = fopen(argv[1], "r")) == NULL)
	{
		fprintf(stderr,"ERROR - Cannot open input file %s. Quitting.\n", argv[1]);
		return 1;
	}
	if ((fout = fopen(argv[2], "w")) == NULL)
	{
		fprintf(stderr,"ERROR - Cannot open output file %s. Quitting.\n", argv[2]);
		return 1;
	}

	// Read the input files and fill the arrays
	fscanf(fin,"%d",&size);
	if (size <= 0)
	{
		fprintf(stderr,"ERROR - Input array size of %d is too small. Quitting.\n", size);
		return 1;
	}
	else if (size > MAXVECTORSIZE)
	{
		fprintf(stderr,"ERROR - Input array size of %d is too large. Maximum size is %d. Quitting.\n", size, MAXVECTORSIZE);
		return 1;
	}
	for (i = 0; i < size; i++)
	{
		if (feof(fin))
		{
			fprintf(stderr,"ERROR - Not enough input values. Number read is %d. Expecting %d. Quitting.\n", i, size);
			return 1;
		}
		else fscanf(fin,"%f %f",&inp[i], &desired[i]);
		// fprintf(stdout,"just read inputs %d %d for index %d\n",inp1[i], inp2[i], i);
	}
	fclose(fin);

	// Now switch to cycle accurate mode and turn on profiling.
	xt_iss_switch_mode(XT_ISS_CYCLE_ACCURATE);
	xt_iss_profile_enable;



	for (i = 0; i < size; i++)
		err[i] = DW_l.Volterra_Mtap_step(inp[i], desired[i]);

	// Now disable profiling
	xt_iss_profile_disable;
	// Now switch back to turbo mode for output file generation
	xt_iss_switch_mode(XT_ISS_FUNCTIONAL);
	// Generate the output file

	for (i = 0; i < size; i++)
	{
		fprintf(fout,"%f\n",err[i]);
	}
	fclose(fout);
	return 0;
 }
