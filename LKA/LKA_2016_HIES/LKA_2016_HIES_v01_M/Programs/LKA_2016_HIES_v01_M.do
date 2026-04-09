/*------------------------------------------------------------------------------
					GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   `code'_`year'_`survey'_v01_M_v01_A_GMD_COR.do	</_Program name_>
<_Application_>    STATA 16.0	<_Application_>
<_Author(s)_>      Juan Segnana <jsegnana@worldbank.org>	</_Author(s)_>
<_Date created_>   05-25-2021	</_Date created_>
<_Date modified>   07-06 2023	by Adriana Castillo Castillo </_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        `code'	</_Country_>
<_Survey Title_>   `survey'	</_Survey Title_>
<_Survey Year_>    `year'	</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:	05-25-2020
File:	`code'_`year'_`survey'_v01_M_v01_A_`type'_COR.do
- First version
</_Version Control_>
------------------------------------------------------------------------------*/

*<_Program setup_>
clear all
set more off

glo   cpiver       "v09"
local code         "LKA"
local year         "2016"
local survey       "HIES"
local vm           "01"
local va           "04"
local type         "SARMD"
local yearfolder   "`code'_`year'_`survey'"
local input        "${rootdatalib}\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M\Data\Stata"
glo output         "${rootdatalib}\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M\Data\Stata"
*</_Program setup_>



/** DATABASE ASSEMBLENT */
	/*------------------------------------------------------------------------------*
/*------------------------------------------------------------------------------*
1. INPUT DATA 
*------------------------------------------------------------------------------*/
*------------------------------------------------------------------------------*/

	*--------------------------------------------------------------------------*
	* CPI and PPP
	*--------------------------------------------------------------------------*
	datalibweb, country(Support) year(2005) type(GMDRAW) surveyid(Support_2005_CPI_${cpiver}_M) filename(Final_CPI_PPP_to_be_used.dta)
	keep if code=="`code'" & year==2016
	keep code year cpi2011 icp2011 cpi2017 icp2017 comparability
		rename icp2011 ppp_2011
		rename icp2017 ppp_2017
		gen cpiperiod=. 
	tempfile cpidata
	save `cpidata', replace

	*--------------------------------------------------------------------------*
	* Demographic Characteristics for every HH member
	*--------------------------------------------------------------------------*
	datalibweb, country(`code') year(`year') type(SARRAW) surveyid(`code'_`year'_`survey'_v01_M) filename(sec_1_demographic_information.dta) // 88,281 obs
	
	tostring district sector month psu snumber hhno, replace
	gen zero="0"
	egen temp_month= concat(zero month)
	replace month= substr(temp_month,-2,.)
	egen temp_psu= concat(zero zero psu)
	replace psu= substr(temp_psu,-3,.)
	egen temp_snumber= concat(zero snumber)
	replace snumber= substr(temp_snumber,-2,.)
	drop temp* zero
	egen hhid=concat(district sector month psu snumber hhno)
	capture gen person_serial_no=0
	drop district
	qui sort hhid person_serial_no
	di as error "Demographic Characteristics for every HH member"
	tempfile individual
	save `individual'

	*--------------------------------------------------------------------------*
	* School education for people between (5-20 yrs old)
	*--------------------------------------------------------------------------*
	datalibweb, country(`code') year(`year') type(SARRAW) surveyid(`code'_`year'_`survey'_v01_M) filename(sec_2_school_education.dta) // 21,081 obs 

	tostring district sector month psu snumber hhno, replace
	gen zero="0"
	egen temp_month= concat(zero month)
	replace month= substr(temp_month,-2,.)
	egen temp_psu= concat(zero zero psu)
	replace psu= substr(temp_psu,-3,.)
	egen temp_snumber= concat(zero snumber)
	replace snumber= substr(temp_snumber,-2,.)
	drop temp* zero
	egen hhid=concat(district sector month psu snumber hhno)
	**** Rename serial number from database
	ren r2_person_serial person_serial_no // For Education dataset
	drop district
	qui sort hhid person_serial_no
	di as error "School education for people between (5-20 yrs old)"
	merge 1:1 psu hhid person_serial_no using `individual', nogen
	tempfile individual
	save `individual'

	*--------------------------------------------------------------------------*
	* Health for every HH member
	*--------------------------------------------------------------------------*
	datalibweb, country(`code') year(`year') type(SARRAW) surveyid(`code'_`year'_`survey'_v01_M) filename(sec_3a_health.dta) // 82,961 obs 
	tostring district sector month psu snumber hhno, replace

	gen zero="0"
	egen temp_month= concat(zero month)
	replace month= substr(temp_month,-2,.)
	egen temp_psu= concat(zero zero psu)
	replace psu= substr(temp_psu,-3,.)
	egen temp_snumber= concat(zero snumber)
	replace snumber= substr(temp_snumber,-2,.)
	drop temp* zero
	
	egen hhid=concat(district sector month psu snumber hhno)
	
	**** Rename serial number from database
	ren s3a_2_person_sno person_serial_no // For Health dataset
	
	drop district

	qui sort hhid person_serial_no

	di as error "Health for every HH member"

	merge 1:1 psu hhid person_serial_no using `individual', nogen

	tempfile individual
	save `individual'

	*--------------------------------------------------------------------------*
	* Income from paid employements
	*--------------------------------------------------------------------------*
	datalibweb, country(`code') year(`year') type(SARRAW) surveyid(`code'_`year'_`survey'_v01_M) filename(sec_5_1_emp_income.dta) // 19,242 obs
	tostring district sector month psu snumber hhno, replace

	gen zero="0"
	egen temp_month= concat(zero month)
	replace month= substr(temp_month,-2,.)
	egen temp_psu= concat(zero zero psu)
	replace psu= substr(temp_psu,-3,.)
	egen temp_snumber= concat(zero snumber)
	replace snumber= substr(temp_snumber,-2,.)
	drop temp* zero

	egen hhid=concat(district sector month psu snumber hhno)

	**** Rename serial number from database
	ren serial_no_sec_1 person_serial_no // For Employment income

	drop district

	drop if pri_sec==. & wages_salaries==. & allowences==. & bonus==.  // Erase people without information in this section
	bys hhid person_serial_no: egen n=max(pri_sec) if pri_sec!=. // Check the number of jobs by HH member
	gen njobs=1 if n>1 & n!=.
	drop n
	reshape wide wages_salaries allowences bonus, i(hhid person_serial_no) j(pri_sec)

	qui sort hhid person_serial_no

	di as error "Income from paid employements"

	merge 1:1 psu hhid person_serial_no using `individual', nogen

	tempfile individual
	save `individual'

	*--------------------------------------------------------------------------*
	* Income from cash receipt during last 12 months
	*--------------------------------------------------------------------------*
	datalibweb, country(`code') year(`year') type(SARRAW) surveyid(`code'_`year'_`survey'_v01_M) filename(sec_5_5_1_other_income.dta) // 14,958 obs 
	tostring district sector month psu snumber hhno, replace

	gen zero="0"
	egen temp_month= concat(zero month)
	replace month= substr(temp_month,-2,.)
	egen temp_psu= concat(zero zero psu)
	replace psu= substr(temp_psu,-3,.)
	egen temp_snumber= concat(zero snumber)
	replace snumber= substr(temp_snumber,-2,.)
	drop temp* zero

	egen hhid=concat(district sector month psu snumber hhno)

	**** Rename serial number from database
	ren serial_5_5_1 person_serial_no // For Other income source

	drop district

	duplicates tag hhid, gen(TAG)
	drop if TAG!=0 & samurdhi==200
	drop TAG

	qui sort hhid person_serial_no
	
	di as error "Income from cash receipt during last 12 months"

	merge 1:1 psu hhid person_serial_no using `individual', nogen

	tempfile individual
	save `individual'

	*--------------------------------------------------------------------------*
	* Children death by HH
	*--------------------------------------------------------------------------*
	datalibweb, country(`code') year(`year') type(SARRAW) surveyid(`code'_`year'_`survey'_v01_M) filename(sec_3_b_is_child_death.dta) // 21,756 obs
	tostring district sector month psu snumber hhno, replace

	gen zero="0"
	egen temp_month= concat(zero month)
	replace month= substr(temp_month,-2,.)
	egen temp_psu= concat(zero zero psu)
	replace psu= substr(temp_psu,-3,.)
	egen temp_snumber= concat(zero snumber)
	replace snumber= substr(temp_snumber,-2,.)
	drop temp* zero

	egen hhid=concat(district sector month psu snumber hhno)

	capture gen person_serial_no=0
	drop district

	qui sort hhid 
	qui drop person_serial_no

	di as error "Children death by HH"

	tempfile household
	save `household'

	*--------------------------------------------------------------------------*
	* Person worked as employee during last 4 weeks
	*--------------------------------------------------------------------------*
	datalibweb, country(`code') year(`year') type(SARRAW) surveyid(`code'_`year'_`survey'_v01_M) filename(sec_5_1_is_emp_income.dta) // 21,756 obs
	tostring district sector month psu snumber hhno, replace

	gen zero="0"
	egen temp_month= concat(zero month)
	replace month= substr(temp_month,-2,.)
	egen temp_psu= concat(zero zero psu)
	replace psu= substr(temp_psu,-3,.)
	egen temp_snumber= concat(zero snumber)
	replace snumber= substr(temp_snumber,-2,.)
	drop temp* zero

	egen hhid=concat(district sector month psu snumber hhno)

	capture gen person_serial_no=0
	drop district

	qui sort hhid 
	qui drop person_serial_no

	di as error "Person worked as employee during last 4 weeks"

	merge 1:1 psu hhid using `household', nogen

	tempfile household
	save `household'

	*--------------------------------------------------------------------------*
	* Person received cash during last 12 months
	*--------------------------------------------------------------------------*
	datalibweb, country(`code') year(`year') type(SARRAW) surveyid(`code'_`year'_`survey'_v01_M) filename(sec_5_5_1_is_other_income.dta) // 21,756 obs
	tostring district sector month psu snumber hhno, replace

	gen zero="0"
	egen temp_month= concat(zero month)
	replace month= substr(temp_month,-2,.)
	egen temp_psu= concat(zero zero psu)
	replace psu= substr(temp_psu,-3,.)
	egen temp_snumber= concat(zero snumber)
	replace snumber= substr(temp_snumber,-2,.)
	drop temp* zero

	egen hhid=concat(district sector month psu snumber hhno)

	capture gen person_serial_no=0
	drop district

	qui sort hhid 
	qui drop person_serial_no

	di as error "Person received cash during last 12 months"

	merge 1:1 psu hhid using `household', nogen

	tempfile household
	save `household'
	
	*--------------------------------------------------------------------------*
	* Durable goods for HH
	*--------------------------------------------------------------------------*
	datalibweb, country(`code') year(`year') type(SARRAW) surveyid(`code'_`year'_`survey'_v01_M) filename(sec_6a_durable_goods.dta) // 21,756 obs
	tostring district sector month psu snumber hhno, replace

	gen zero="0"
	egen temp_month= concat(zero month)
	replace month= substr(temp_month,-2,.)
	egen temp_psu= concat(zero zero psu)
	replace psu= substr(temp_psu,-3,.)
	egen temp_snumber= concat(zero snumber)
	replace snumber= substr(temp_snumber,-2,.)
	drop temp* zero

	egen hhid=concat(district sector month psu snumber hhno)

	capture gen person_serial_no=0
	drop district

	qui sort hhid 
	qui drop person_serial_no

	di as error "Durable goods for HH"

	merge 1:1 psu hhid  using `household', nogen

	tempfile household
	save `household'

	*--------------------------------------------------------------------------*
	* Access to primary facilities for HH 
	*--------------------------------------------------------------------------*
	datalibweb, country(`code') year(`year') type(SARRAW) surveyid(`code'_`year'_`survey'_v01_M) filename(sec_7_basic_facilities.dta) // 21,756 obs
	tostring district sector month psu snumber hhno, replace

	gen zero="0"
	egen temp_month= concat(zero month)
	replace month= substr(temp_month,-2,.)
	egen temp_psu= concat(zero zero psu)
	replace psu= substr(temp_psu,-3,.)
	egen temp_snumber= concat(zero snumber)
	replace snumber= substr(temp_snumber,-2,.)
	drop temp* zero

	egen hhid=concat(district sector month psu snumber hhno)

	capture gen person_serial_no=0
	drop district

	qui sort hhid 
	qui drop person_serial_no

	di as error "Access to primary facilities for HH "

	merge 1:1 psu hhid  using `household', nogen

	tempfile household
	save `household'
	
	*--------------------------------------------------------------------------*
	* Housing Information
	*--------------------------------------------------------------------------*
	datalibweb, country(`code') year(`year') type(SARRAW) surveyid(`code'_`year'_`survey'_v01_M) filename(sec_8_housing.dta) // 21,756 obs
	tostring district sector month psu snumber hhno, replace

	gen zero="0"
	egen temp_month= concat(zero month)
	replace month= substr(temp_month,-2,.)
	egen temp_psu= concat(zero zero psu)
	replace psu= substr(temp_psu,-3,.)
	egen temp_snumber= concat(zero snumber)
	replace snumber= substr(temp_snumber,-2,.)
	drop temp* zero

	egen hhid=concat(district sector month psu snumber hhno)

	capture gen person_serial_no=0
	drop district

	qui sort hhid 
	qui drop person_serial_no

	di as error "Housing Information"

	merge 1:1 psu hhid  using `household', nogen

	tempfile household
	save `household'

	*--------------------------------------------------------------------------*
	* Weigths
	*--------------------------------------------------------------------------*
	datalibweb, country(`code') year(`year') type(SARRAW) surveyid(`code'_`year'_`survey'_v01_M) filename(wfile2016.dta) // 21,756 obs
	tostring district psu, replace
	drop sector month

	gen zero="0"
	egen temp_psu= concat(zero zero psu)
	replace psu= substr(temp_psu,-3,.)
	drop temp* zero

	gen code="LKA"
	gen year=2016

	*--------------------------------------------------------------------------*
	* Final database 
	*--------------------------------------------------------------------------*
	**** Clean unwanted observations
	**** Households not available in the Consumption File
	merge 1:1 psu hhid using `household', nogen
	merge 1:m psu hhid using `individual', nogen keep(match)
	merge m:1 code year using `cpidata', nogen

	**** Individuals who are not living in the house (code higher than 40 are people that don't live in the HH)
	drop if person_serial_no>=40
	*drop if age==. // Don't drop to keep consistency with LKA2016_v03

 

*<_Save data file_>
compress
if ("`c(username)'"=="dekopon") save "${output}/`yearfolder'_M.dta", replace
else save "${output}/`yearfolder'_M.dta" , replace
*</_Save data file_>
