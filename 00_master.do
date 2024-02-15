

********************************************************************************
		*	      WHERE DO PWD LIVE MASTER DO FILE	        *
********************************************************************************

/*
GENERAL NOTES:
- This is the master do-file for the Where do pwd live project.
- This do-file defines folder and data globals and allows users to choose which sections and tables to run.
- Adjust the folder and state_data globals 
*/

********************************************************************************
	
	clear  
	clear matrix
	clear mata
	capture log close
	set more off
	set maxvar 20000
	set scheme s1color
	cap ssc install estout

		
********************************************************************************
	*	PART 1:  PREPARING GLOBALS & DEFINE PREAMBLE	  *
********************************************************************************


* FOLDER AND DATA GLOBALS

if 1 {

*select path
gl csun  1
gl nbcoe 0

	if $csun {
	gl folder 					"C:\Users\chuxuan\Desktop\Projects\Coe_Project\project_inprogress\WhereDoPWDLive"  
	}

	if $nbcoe {
	gl folder					""                                                   /* Enter location of main folder */
	}

}


* FOLDER GLOBALS

		gl do			   			"$folder\do"
		gl output		  			"$folder\output"
		gl log			  		 	"$folder\log"
		gl data			   			"$folder\data"
		gl createddata			   	"$folder\createddata"
		


* CHOOSE SECTIONS TO RUN
	
	loc cleanandmerge				1	
	loc summarystats                1


********************************************************************************
*				PART 2:  RUN DO-FILES			*
********************************************************************************

* PART 0: CREATE DATASET	

	if `cleanandmerge' {
	    do "$do/01_hrsfam1618.do"
		do "$do/01_cleanandmerge.do"
	}

* PART 1: RUN ANALYSIS	

	if `summarystats' {
		do "$do/02_summarystats.do"
	}

	