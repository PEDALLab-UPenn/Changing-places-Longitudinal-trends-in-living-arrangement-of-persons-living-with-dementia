

********************************************************************************
** This file generates figures for Where Do People With Dementia Live **
** Last updated on 06/09/2023 by CS **
********************************************************************************


******************
*** Figure 1 ***
******************
* Loop over round 5 to round 11 *
forv i=5/11 {

capture log close
set more off	
clear all 

use "$createddata/NHATS_Round1to11.dta", clear
keep if round==`i'

    ** Set svyset
    svyset wvarunit [pweight=wanfinwgt0], strata(wvarstrat) 
	
    ** Distribution of livarrgmt_detailed2
	    svy, subpop(if demclas==1): proportion livarrgmt_detailed2
		matrix C=e(b)
		matselrc C B , r(1) c(1,2,3,4)
		mat colnames B= Comm_alone Comm_wppl Resfac NursingHome
		matrix A = B'
		
        ** Get original row names of matrix (and row count)
        local rownames : rowfullnames A
        local c : word count `rownames'
        ** Get original column names of matrix and substitute out _cons
        local names : colfullnames A
        local newnames : subinstr local names "_cons" "cons", word
        ** Rename columns of matrix
        matrix colnames A = `newnames'
        ** Convert to dataset
        clear
        svmat double A, name(col)
        ** Add matrix row names to dataset
        gen rownames = ""
        forv u = 1/`c' {
            replace rownames = "`:word `u' of `rownames''" in `u'
        }
        ** Add round to dataset
        gen round = `i'
        ** Check
        order rownames
        list, sep(0)
		
        tempfile temp`i'
        sa `temp`i''
        clear
					
}

	use `temp5'
		forval j = 6/11 {
		append using `temp`j''
		}		
    sa "$output/figure_all.dta", replace
    clear
	
	
* Generate Figure 1 *
use "$output/figure_all.dta", clear
rename y1 proportion 

g condition=.
    replace condition=1 if strpos(rownames,"Comm_alone")
	replace condition=2 if strpos(rownames,"Comm_wppl")
	replace condition=3 if strpos(rownames,"NursingHome")
	replace condition=4 if strpos(rownames,"Resfac")

g year=.
    replace year=2015 if round==5
	replace year=2016 if round==6
	replace year=2017 if round==7
	replace year=2018 if round==8
	replace year=2019 if round==9
	replace year=2020 if round==10
	replace year=2021 if round==11

twoway connected proportion year if condition==1, lwidth(0.5) msymbol(diamond) msize(small) || connected proportion year if condition==2, lwidth(0.5) msymbol(circle) msize(small) || connected proportion year if condition==3, lwidth(0.5) msymbol(triangle) msize(small) || connected proportion year if condition==4, lwidth(0.5) msymbol(square) msize(small) ///
xline(2019, lwidth(0.4) lpattern(dash) lcolor(black)) ///
text(0.25 2020 "Community Alone", size(medium) color(forest_green)) text(0.63 2016 "Community with People", size(medium) color(dkorange)) ///
text(0.05 2016 "Nursing Home", size(medium) color(navy)) text(0.22 2017 "Other Residential Care Setting", size(medium) color(maroon)) ///
title("", size(large) color(black) margin(medium)) ///
ytitle("Weighted Proportion", size(large) margin(medium)) ///
xtitle("Year", size(large) margin(medium)) ///
ylabel(0(0.1)1, labsize(medium)) xlabel(2015/2021, labsize(medium)) legend(off) ///
graphregion(color(white) margin(l+1 r+5)) ///
ysize(5) xsize(10)  sort

graph export "$output\Figure 1.tif", width(1800) replace



******************
*** Figure 2 ***
******************

** ADL Count **

forv i=5/11 {

capture log close
set more off	
clear all 

use "$createddata/NHATS_Round1to11.dta", clear
keep if round==`i'

    ** Set svyset
    svyset wvarunit [pweight=wanfinwgt0], strata(wvarstrat) 
	
    ** Distribution of livarrgmt_detailed2 of ADL variables
	    svy, subpop(if demclas==1): mean ADL_tot, over(livarrgmt_detailed2)
		matrix C=e(b)
		matselrc C B , r(1) c(1,2,3,4)
		mat colnames B= Comm_alone Comm_wppl Resfac NursingHome
		matrix A = B'
		
        ** Get original row names of matrix (and row count)
        local rownames : rowfullnames A
        local c : word count `rownames'
        ** Get original column names of matrix and substitute out _cons
        local names : colfullnames A
        local newnames : subinstr local names "_cons" "cons", word
        ** Rename columns of matrix
        matrix colnames A = `newnames'
        ** Convert to dataset
        clear
        svmat double A, name(col)
        ** Add matrix row names to dataset
        gen rownames = ""
        forv u = 1/`c' {
            replace rownames = "`:word `u' of `rownames''" in `u'
        }
        ** Add round to dataset
        gen round = `i'
        ** Check
        order rownames
        list, sep(0)
		
        tempfile temp`i'
        sa `temp`i''
        clear
					
}

	use `temp5'
		forval j = 6/11 {
		append using `temp`j''
		}	
		
    sa "$output/figure_adl_mean.dta", replace
    clear


	
** Unmet Need Count **

forv i=5/11 {

capture log close
set more off	
clear all 

use "$createddata/NHATS_Round1to11.dta", clear
keep if round==`i'

    ** Set svyset
    svyset wvarunit [pweight=wanfinwgt0], strata(wvarstrat) 
	
    ** Distribution of livarrgmt_detailed2 of ADL variables
	    svy, subpop(if demclas==1 & ADL_tot>0 & ADL_tot<.): mean unmet_ADL_tot, over(livarrgmt_detailed2)
		matrix C=e(b)
		matselrc C B , r(1) c(1,2,3,4)
		mat colnames B= Comm_alone Comm_wppl Resfac NursingHome
		matrix A = B'
		
        ** Get original row names of matrix (and row count)
        local rownames : rowfullnames A
        local c : word count `rownames'
        ** Get original column names of matrix and substitute out _cons
        local names : colfullnames A
        local newnames : subinstr local names "_cons" "cons", word
        ** Rename columns of matrix
        matrix colnames A = `newnames'
        ** Convert to dataset
        clear
        svmat double A, name(col)
        ** Add matrix row names to dataset
        gen rownames = ""
        forv u = 1/`c' {
            replace rownames = "`:word `u' of `rownames''" in `u'
        }
        ** Add round to dataset
        gen round = `i'
        ** Check
        order rownames
        list, sep(0)
		
        tempfile temp`i'
        sa `temp`i''
        clear
					
}

	use `temp5'
		forval j = 6/11 {
		append using `temp`j''
		}	
		
    sa "$output/figure_unmetadl_mean.dta", replace
    clear
	
	
* Generate Figure 2 - ADL Count & Unmet Need Count
use "$output/figure_adl_mean.dta", clear
rename y1 proportion 
g condition=.
    replace condition=1 if strpos(rownames,"Comm_alone")
	replace condition=2 if strpos(rownames,"Comm_wppl")
	replace condition=3 if strpos(rownames,"NursingHome")
	replace condition=4 if strpos(rownames,"Resfac")

g year=.
    replace year=2015 if round==5
	replace year=2016 if round==6
	replace year=2017 if round==7
	replace year=2018 if round==8
	replace year=2019 if round==9
	replace year=2020 if round==10
	replace year=2021 if round==11

twoway connected proportion year if condition==1, lwidth(0.5) msymbol(diamond) msize(small) || connected proportion year if condition==2, lwidth(0.5) msymbol(circle) msize(small) || connected proportion year if condition==3, lwidth(0.5) msymbol(triangle) msize(small) || connected proportion year if condition==4, lwidth(0.5) msymbol(square) msize(small) ///
xline(2019, lwidth(0.4) lpattern(dash) lcolor(black)) ///
text(0.8 2016.5 "Community Alone", size(medium) color(forest_green)) text(1.8 2016.5 "Community with People", size(medium) color(dkorange)) text(4.2 2016.5 "Nursing Home", size(medium) color(navy)) text(2.8 2016.5 "Other Residential Care Setting", size(medium) color(maroon)) legend(off) ///
title("Panel A: Number of Self-Care Difficulties", size(large) color(black) margin(medium)) ///
ytitle("", size(small) margin(large)) xtitle("", size(small)) ///
ylabel(0(1)5, labsize(medium)) xlabel(2015/2021, labsize(medium)) ///
graphregion(color(white)) sort name(adl)

use "$output/figure_unmetadl_mean.dta", clear
rename y1 proportion 
g condition=.
    replace condition=1 if strpos(rownames,"Comm_alone")
	replace condition=2 if strpos(rownames,"Comm_wppl")
	replace condition=3 if strpos(rownames,"NursingHome")
	replace condition=4 if strpos(rownames,"Resfac")

g year=.
    replace year=2015 if round==5
	replace year=2016 if round==6
	replace year=2017 if round==7
	replace year=2018 if round==8
	replace year=2019 if round==9
	replace year=2020 if round==10
	replace year=2021 if round==11

twoway connected proportion year if condition==1, lwidth(0.5) msymbol(diamond) msize(small) || connected proportion year if condition==2, lwidth(0.5) msymbol(circle) msize(small) || connected proportion year if condition==3, lwidth(0.5) msymbol(triangle) msize(small) || connected proportion year if condition==4, lwidth(0.5) msymbol(square) msize(small) ///
xline(2019, lwidth(0.4) lpattern(dash) lcolor(black)) ///
text(1.2 2020 "Community Alone", size(medium) color(forest_green)) text(0.1 2020 "Community with People", size(medium) color(dkorange)) text(1.2 2016.5 "Nursing Home", size(medium) color(navy)) text(0.1 2017 "Other Residential Care Setting", size(medium) color(maroon)) legend(off) ///
title("Panel B: Number of Unmet Needs", size(large) color(black) margin(medium)) ///
ytitle("", size(small) margin(large)) xtitle("", size(small)) ///
ylabel(0(1)5, labsize(medium)) xlabel(2015/2021, labsize(medium)) ///
graphregion(color(white)) sort name(unmet)

graph combine adl unmet, title("",size(large)) l1title("Weighted Mean",size(large) margin(vsmall)) b1title("Year",size(large) margin(vsmall))  ysize(5) xsize(13) 

graph export "$output\Figure 2.tif", width(1800) replace



