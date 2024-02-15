
***********************************************************
** This file cleans and merges NHATS data **
** for the Where Do People With Dementia Live Project **
** Last updated on 4/17/2023 by CS **
***********************************************************



loc filenames `""NHATS_Round_1_SP_File" "NHATS_Round_2_SP_File_v2" "NHATS_Round_3_SP_File" "NHATS_Round_4_SP_File" "NHATS_Round_5_SP_File_V2" "NHATS_Round_6_SP_File_V2" "NHATS_Round_7_SP_File" "NHATS_Round_8_SP_File" "NHATS_Round_9_SP_File" "NHATS_Round_10_SP_File" "NHATS_Round_11_SP_File""' 



* Loop over NHATS Round 1 to 11 *

forv i=1/11 {
	
    clear	
    capture log close
    set more off
    
	
	
**************************************
*** Section 1 Read in NHATS Data ***
**************************************
loc tt: word `i' of `filenames'
use "$data/`tt'.dta", clear
g round = `i'

* Rename variables 
rename(re`i'dcensdiv w`i'varunit w`i'anfinwgt0 w`i'varstrat r`i'd2intvrage)(redcensdiv wvarunit wanfinwgt0 wvarstrat age_cat)

if `i'<5 {
rename(r1dgender rl1dracehisp)(gender racehisp)
}

if `i'>=5 {
rename(r5dgender rl5dracehisp)(gender racehisp)
}



***************************************
*** Section 2 Sample Restrictions ***
***************************************
* Drop residential care FQ only and nursing home residents FQ only, deceased 
drop if !inlist(r`i'dresid,1,2,4)

* Drop SP aged between 65-69 as their percentages varied a lot
drop if age_cat==1

if `i'==2 {
*USE THIS LINE TO FIX A CODING ERROR IN ROUND 2 ONLY
replace cg`i'dwrdimmrc=-3 if cg`i'dwrdimmrc==10 & cg`i'dwrddlyrc==-3
}
	
	
	
**************************************************
*** Section 3 Generate Demogrpahic Variables ***
**************************************************
** Marital Status 
if `i'==1 {
	rename hh`i'martlstat hh`i'dmarstat
}
recode hh`i'dmarstat (1/2=1) (3/5=2) (6=3) (else=.), gen(marital_status)
 
** Race
recode racehisp (1=1) (2=2) (3=3) (4=4) (5/6=.)

** Living Arrangement
recode r`i'dresid (1=1) (2 4=2), gen(livarrgmt)

** Living Arrangement Detailed
g livarrgmt_detailed = .
    replace livarrgmt_detailed=1 if r`i'dresid==1 & hh`i'dlvngarrg==1              //Community + Alone
    replace livarrgmt_detailed=2 if r`i'dresid==1 & hh`i'dlvngarrg==2              //Community + With sp or partner only 	
    replace livarrgmt_detailed=3 if r`i'dresid==1 & hh`i'dlvngarrg==3              //Community + With sp or partner and with others
    replace livarrgmt_detailed=4 if r`i'dresid==1 & hh`i'dlvngarrg==4              //Community + With others only	
    replace livarrgmt_detailed=5 if r`i'dresid==2                                  //Residential care not nursing home 
    replace livarrgmt_detailed=6 if r`i'dresid==4                                  //Nursing Home

g livarrgmt_detailed2 = .
    replace livarrgmt_detailed2=1 if r`i'dresid==1 & hh`i'dlvngarrg==1              //Community + Alone
    replace livarrgmt_detailed2=2 if r`i'dresid==1 & inlist(hh`i'dlvngarrg,2,3,4)   //Community + With people		
    replace livarrgmt_detailed2=3 if r`i'dresid==2                                  //Residential care not nursing home 
    replace livarrgmt_detailed2=4 if r`i'dresid==4                                  //Nursing Home

	
** Code for each ADL activity; 

	** Able to walk at least 3 blocks
	recode pc`i'walk3blks (1=1) (2=0) (else=.), gen(walk3blocks)
    replace walk3blocks =1 if pc`i'walk6blks==1 

	** Able to walk up 10 stairs
	recode pc`i'up10stair (1=1) (2=0) (else=.), gen(walk10stairs)
    replace walk10stairs =1 if pc`i'up20stair==1 		
		
	* MO: get around outside
	g needhelp_out=.
		** If MO6 = 1 (anyone ever helped you go outside)
		replace needhelp_out=1 if mo`i'outhlp==1
	    ** If MO8: how much diff do you have = some/a lot 
	    replace needhelp_out=1 if inlist(mo`i'outdif,3,4) & needhelp_out==.	
		** If MO10: ever have to stay in home because no one was there to help
	    replace needhelp_out=1 if mo`i'outwout==1 & needhelp_out==.
		** If MO6 = 2 (no help to go outside) and MO8 = 1/2 (no/little difficulty going outside by self)
		replace needhelp_out=0 if mo`i'outhlp==2 & inlist(mo`i'outdif,1,2) & needhelp_out==.	
			
	* MO: get around inside
	g needhelp_ins=. 
		** If MO18 = 1 (anyone ever helped you get around inside)
		replace needhelp_ins=1 if mo`i'insdhlp==1
	    ** If MO21: how much diff do you have = some/a lot 
	    replace needhelp_ins=1 if inlist(mo`i'insddif,3,4) & needhelp_ins==.
		** If MO23: there were any places in home that did not go because no one was there to help
	    replace needhelp_ins=1 if mo`i'insdwout==1 & needhelp_ins==.
		** If MO18 = 2 (did not get help getting around inside) and MO21= 1 (no difficulty getting around inside)
		replace needhelp_ins=0 if mo`i'insdhlp==2 & inlist(mo`i'insddif,1,2) & needhelp_ins==.
		
	* MO: get out of bed
	g needhelp_bed=.
		** If MO25 = 1 (anyone ever helped you get out of bed)
		replace needhelp_bed=1 if mo`i'bedhlp==1
	    ** If MO27: how much diff did you have getting out of bed = some/a lot 
	    replace needhelp_bed=1 if inlist(mo`i'beddif,3,4) & needhelp_bed==.	
		** If MO28: ever have to stay in bed because no one was there to help
	    replace needhelp_bed=1 if mo`i'bedwout==1 & needhelp_bed==.
		** If MO25 = 2 (no help getting out of bed) and MO27 = 1/2 (no/little difficulty getting out of bed)
		replace needhelp_bed=0 if mo`i'bedhlp==2 & inlist(mo`i'beddif,1,2) & needhelp_bed==.			
		
	* SC: eating 
	g needhelp_eat=.
	    ** If SC3 = 1 (someone helped me eat in the last month)
	    replace needhelp_eat=1 if sc`i'eathlp==1
		** If SC5: how much diff did you have eating by yourself and without help = some/a lot 
	    replace needhelp_eat=1 if inlist(sc`i'eatslfdif,3,4) & needhelp_eat==.	
		** If SC6: ever go without eating because no one was there to help
	    replace needhelp_eat=1 if sc`i'eatwout==1 & needhelp_eat==.		
	    ** If SC3 = 2 (no help with eating) and SC5 = 1 or 2 (no/little difficulty eating)
	    replace needhelp_eat=0 if sc`i'eathlp==2 & inlist(sc`i'eatslfdif,1,2) & needhelp_eat==.	
		
	* SC: bathing 
	g needhelp_bath=.
	    ** If SC11 = 1 (someone helped me take a bath)
	    replace needhelp_bath=1 if sc`i'bathhlp==1
		** If SC13: how much diff did you have taking a bath and without help = some/a lot 
	    replace needhelp_bath=1 if inlist(sc`i'bathdif,3,4) & needhelp_bath==.	
		** If SC15: ever go without taking a bath because no one was there to help
	    replace needhelp_bath=1 if sc`i'bathwout==1 & needhelp_bath==.		
	    ** If SC11 = 2 (no help cleaning up) and SC13 = 1/2 (no/little difficulty cleaning up)
	    replace needhelp_bath=0 if sc`i'bathhlp==2 & inlist(sc`i'bathdif,1,2) & needhelp_bath==.		
		
	* SC: toileting 
	g needhelp_toilet=.
	    ** If SC17 = 1 (someone helped me use the toilet)
	    replace needhelp_toilet=1 if sc`i'toilhlp==1
		** If SC19: how much diff did you have using the toilet and without help = some/a lot 
	    replace needhelp_toilet=1 if inlist(sc`i'toildif,3,4) & needhelp_toilet==.		
		** If SC20: ever accidentally wet or soil clothes because no one was there to help
	    replace needhelp_toilet=1 if sc`i'toilwout==1 & needhelp_toilet==.		
	    ** If SC17 = 2 (no help) and SC19 = 1/2 (no/little difficulty)
	    replace needhelp_toilet=0 if sc`i'toilhlp==2 & inlist(sc`i'toildif,1,2) & needhelp_toilet==.	
	
	* SC: dressing 
	g needhelp_dress=.
	    ** If SC23 = 1 (someone helped me get dressed)
	    replace needhelp_dress=1 if sc`i'dreshlp==1
		** If SC25: how much diff did you have e getting dressed and without help = some/a lot 
	    replace needhelp_dress=1 if inlist(sc`i'dresdif,3,4) & needhelp_dress==.		
		** If SC27: ever accidentally wet or soil clothes because no one was there to help
	    replace needhelp_dress=1 if sc`i'dreswout==1 & needhelp_dress==.		
	    ** If SC23 = 2 (did not get help) and SC25 = 1/2 (no/little difficulty)
	    replace needhelp_dress=0 if sc`i'dreshlp==2 & inlist(sc`i'dresdif,1,2) & needhelp_dress==.	
	
		
** Code for unmet needs
recode sc`i'eatwout  (1=1)(2=0)(else=.), gen(unmetneeds_eat)
    replace unmetneeds_eat=0 if sc`i'eathlp==2 & inlist(sc`i'eatslfdif,1,2) & unmetneeds_eat==.
	
recode sc`i'bathwout (1=1)(2=0)(else=.), gen(unmetneeds_bath)
    replace unmetneeds_bath=0 if sc`i'bathhlp==2 & inlist(sc`i'bathdif,1,2) & unmetneeds_bath==.
	
recode sc`i'toilwout (1=1)(2=0)(else=.), gen(unmetneeds_toilet)
    replace unmetneeds_toilet=0 if sc`i'toilhlp==2 & inlist(sc`i'toildif,1,2) & unmetneeds_toilet==.
	
recode sc`i'dreswout (1=1)(2=0)(else=.), gen(unmetneeds_dress)
    replace unmetneeds_dress=0 if sc`i'dreshlp==2 & inlist(sc`i'dresdif,1,2) & unmetneeds_dress==.
	
recode mo`i'bedwout  (1=1)(2=0)(else=.), gen(unmetneeds_bed)
    replace unmetneeds_bed=0 if mo`i'bedhlp==2 & inlist(mo`i'beddif,1,2) & unmetneeds_bed==.

recode mo`i'outwout  (1=1)(2=0)(else=.), gen(unmetneeds_out)
recode mo`i'insdwout (1=1)(2=0)(else=.), gen(unmetneeds_ins)

* Count ADL needs
egen ADL_tot = rowtotal(needhelp_bed needhelp_eat needhelp_bath needhelp_toilet needhelp_dress), missing

* Count unmet ADL needs
egen unmet_ADL_tot = rowtotal(unmetneeds_bed unmetneeds_eat unmetneeds_bath unmetneeds_toilet unmetneeds_dress), missing



***************************************
** Section 4 Keep Needed Variables **
***************************************
if `i'>8 {
rename r`i'dmetnonmet rdmetnonmet	
keep spid round redcensdiv wvarunit wanfinwgt0 wvarstrat gender racehisp age_cat ///
marital_status livarrgmt livarrgmt_detailed livarrgmt_detailed2 walk3blocks ///
walk10stairs needhelp* ADL_tot rdmetnonmet unmetneeds* unmet_ADL_tot 
}
else {
keep spid round redcensdiv wvarunit wanfinwgt0 wvarstrat gender racehisp age_cat ///
marital_status livarrgmt livarrgmt_detailed livarrgmt_detailed2 walk3blocks ///
walk10stairs needhelp* ADL_tot unmetneeds* unmet_ADL_tot 
}

sa "$createddata/NHATS_Round`i'.dta", replace
	
}	



*******************************************************
** Section 5 Merge Metro/Non-Metro Residence Data **
*******************************************************
forv i=1/8 {
use	"$data/NHATS_Round_`i'_MetNonMet.dta", clear
rename r`i'dmetnonmet rdmetnonmet
keep spid rdmetnonmet
merge 1:1 spid using "$createddata/NHATS_Round`i'.dta", keep (matched) nogen
sa "$createddata/NHATS_Round`i'.dta", replace
}



*******************************************************
** Section 6 Merge Dementia Classification Data **
*******************************************************
forv i=1/11 {
use	"$createddata/NHATS_Round_`i'_dementia`i'.dta", clear
merge 1:1 spid using "$createddata/NHATS_Round`i'.dta", keep (matched) nogen
sa "$createddata/NHATS_Round`i'.dta", replace
}



*******************************************************
** Section 7 Combine all Data and Label Variables**
******************************************************
use "$createddata/NHATS_Round1.dta"
forv i=2/11 {
append using "$createddata/NHATS_Round`i'.dta"
}

** Label variables 
order spid round demclas wanfinwgt0 wvarstrat wvarunit 
foreach var of varlist gender-unmetneeds_ins {	
	replace `var'=99 if mi(`var')
}

replace demclas=99 if demclas==-9

lab define glabel 			1 "Male" 2 "Female" 
lab values gender 	        glabel
lab define mlabel 			1 "Married/Partnered" 2 "Separated/Divorced/Widowed" 3 "Never Married" 99 "Missing"
lab values marital_status 	mlabel
lab define rlabel 			1 "White, non-hispanic" 2 "Black, non-hispanic" 3 "Other" 4 "Hispanic" 99 "Missing"
lab values racehisp 	    rlabel
lab define aglabel 			2 "70 to 74" 3 "75 to 79" 4 "80 to 84" 5 "85 to 89" 6 "90+" 99 "Missing"
lab values age_cat 	        aglabel
lab define slabel 			1 "New England Div" 2 "Middle Atlantic Div" 3 "East North Central Div" 4 "West North Central Div" 5 "South Atlantic Div" 6 "East South Central Div" 7 "West South Central Div" 8 "Mountain Div" 9 "Pacific Div" 99 "Missing"
lab values redcensdiv 	    slabel
lab define livlabel 		1 "Community" 2 "ResidentialCare or NursingHome" 99 "Missing"
lab values livarrgmt 	    livlabel
lab define livdlabel 		1 "Comm-Alone" 2 "Comm-With sp/partner only" 3 "Comm-With sp and others" 4 "Comm-With others only" 5 "Residential Care" 6 "Nursing Home" 99 "Missing"
lab values livarrgmt_detailed 	livdlabel
lab define livdtlabel 		1 "Comm-Alone" 2 "Comm-With people" 3 "Residential Care" 4 "Nursing Home" 99 "Missing"
lab values livarrgmt_detailed2 	livdtlabel


lab var gender                 "Gender"
lab var racehisp               "Race"
lab var age_cat                "Age"
lab var marital_status         "Marital Status"  
lab var redcensdiv             "Census Division"
lab var rdmetnonmet            "Metro/Non-Metro Residence"
lab var livarrgmt              "Living arrangements"
lab var livarrgmt_detailed     "Living arrangements (detailed)"
lab var livarrgmt_detailed2    "Living arrangements (detailed2)"

lab var walk3blocks            "Walking 3/6 blocks"
lab var walk10stairs           "Walking up 10/20 stairs"
lab var needhelp_eat           "Eating"
lab var needhelp_bath          "Bathing"
lab var needhelp_toilet        "Toileting"
lab var needhelp_dress         "Dressing"   
lab var needhelp_out           "Getting around outside"
lab var needhelp_ins           "Getting around inside"
lab var needhelp_bed           "Getting out of bed"

lab var unmetneeds_eat         "Unmet Needs: Eating"
lab var unmetneeds_bath        "Unmet Needs: Bathing"
lab var unmetneeds_toilet      "Unmet Needs: Toileting"
lab var unmetneeds_dress       "Unmet Needs: Dressing"
lab var unmetneeds_bed         "Unmet Needs: Getting out of bed" 
lab var unmetneeds_out         "Unmet Needs: Getting around outside"
lab var unmetneeds_ins         "Unmet Needs: Getting around inside"
lab var ADL_tot                "Total # of ADL"
lab var unmet_ADL_tot          "Total # of Unmet ADL"

sa "$createddata/NHATS_Round1to11.dta", replace

