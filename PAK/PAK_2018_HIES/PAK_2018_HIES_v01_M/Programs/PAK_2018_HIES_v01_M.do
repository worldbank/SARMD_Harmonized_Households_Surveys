/*====================================================================
project:       Labor Survey Nepal
Author:        WB473845 
Dependencies:  SAR Stats Team-World Bank
----------------------------------------------------------------------
Creation Date:    29 Apr 2020 - 11:08:15
Modification Date:   
Do-file version:    01
References:          
Output:             dta
====================================================================*/
*------------------------------
*        0: Program set up
*------------------------------
*<_Program setup_>
clear all
set more off

local code         "PAK"
local year         "2018"
local survey       "HIES"
local vm           "01"
local type         "SARMD"
local yearfolder   "`code'_`year'_`survey'"
glo output         "${rootdatalib}\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M\Data\Stata"
*</_Program setup_>


	
glo input			 "${rootdatalib}/`code'/`yearfolder'/`yearfolder'_v`vm'_M"
*glo pricedata       "${sarmd}/CPI/cpi_ppp_sarmd_weighted.dta"
global shares        "P:/SARMD/SARDATABANK/APPS/DATA CHECK/Food and non-food shares/PAK"
	
*<_Folder creation_>
cap mkdir "${output}"
*</_Folder creation_>

	

** DATABASE ASSEMBLENT
* Household Roster
use "${input}/Data/Stata/plist.dta", clear

* Employment
merge 1:1 hhcode idc using "${input}/Data/Stata/sec_1b (2).dta", nogen assert (master match)

* Education
merge 1:1 hhcode idc using "${input}/Data/Stata/sec_2ab.dta", nogen assert(master match)

* Detail on the family (housing info)
merge m:1 hhcode using "${input}/Data/Stata/sec_5a.dta", nogen assert(match)

* Interview information
merge m:1 hhcode using "${input}/Data/Stata/sec_00.dta", nogen keep(master match)	//note: 867 obs deleted

* HH Expenditures
merge m:1 hhcode using "${input}/Data/Stata/CA_1819_sharing_v2.dta", nogen assert(match)

tempfile individual_level_data
save `individual_level_data'

/*
* Durable and non-durable goods 
use "${input}/Data/Stata/sec_6a.dta", clear
format %20.0f hhcode
keep hhcode itc v1
decode itc, gen (itc1)
gen itc11=itc
tostring itc11, replace 
gen var_="_"
egen itc2=concat( itc11 var_ itc1 )
replace itc2=strtoname(itc2)
replace itc2=substr(itc2, 1,20)
keep hhcode itc2 v1
ren v1 numdur
reshape wide numdur, i( hhcode ) j( itc2 ) string
des
merge 1:m hhcode using `individual_level_data', nogen assert(match)


* Add livestock assets
	use "${input}/Data/Stata/sec_10b.dta", clear
	duplicates tag hhcode codes, gen(TAG)
	drop if TAG==1 & s10c1==.
	drop TAG
	keep s10c1 codes hhcode
	decode codes, gen(itc)
	egen itc2=concat( itc codes )
	replace itc2=strtoname(itc2)
	replace itc2=substr(itc2, 1,20)
	keep hhcode s10c1 itc2
	ren s10c1 numlivestock
	reshape wide numlivestock, i( hhcode ) j( itc2 ) string
	tempfile agri
	save `agri'
	save "${output}/agri.dta", replace
*/	
	
**Add landholding information
	use "${input}/Data/Stata/sec_9a.dta", clear
	format %20.0f hhcode
	keep hhcode code s9aq01
	decode code, gen (code1)
	tostring code, g(code11) 
	gen var_="_"
	egen code2=concat( code11 var_ code1 )
	replace code2=strtoname(code2)
	replace code2=substr(code2, 1,20)
	keep hhcode code2 s9aq01
	reshape wide s9aq01, i( hhcode ) j( code2 ) string
	merge 1:m hhcode using `individual_level_data', nogen assert(match)
	

**Add deflactor information	
	merge m:1 psu using "${input}/Data/Stata/psu_paasche_2018_pdef1.dta", nogen assert(match)
	

**Add corrected welfare information	
	rename nomexpend nomexpend_old 
	
	gen double idp_= hhcode*100+idc
	gen idp=string(idp_,"%16.0g")
	label var idp "Individual id"
	drop idp_
	
	gen double idh_=hhcode
	gen idh=string(idh_,"%16.0g")
	label var idh "Household id"
	drop idh_
	
	merge 1:1 psu idh idp using "${input}/Data/Stata/welfarenom_v01M_new.dta", nogen assert(match)
	notes: This database has information of the old welfare for Pakistan 2018, before the changes of adjustments in spatial prices were applied. Therefore, this sarmd version 02 will use this information. 
	drop idh idp 
	*countrycode year survey wgt pop_wgt
	
* section 7a
	save `individual_level_data', replace
	use "${input}/Data/Stata/sec_7a", clear
	keep if inlist(code,701,702,704,706,714,711,710,727,728,730,732)
	drop c01 c03
	keep hhcode psu code c02
	decode code, gen (itc1)
	gen itc11=code
	tostring itc11, replace 
	gen var_="_"
	egen itc2=concat( itc11 var_ itc1 )
	replace itc2=strtoname(itc2)
	replace itc2=substr(itc2, 1,20)
	keep hhcode psu itc2 c02
	reshape wide c02, i( hhcode ) j( itc2 ) string
	merge 1:m hhcode using `individual_level_data', nogen assert(using match)


*<_Save data file_>
compress
save "${output}/`yearfolder'_M.dta" , replace
*</_Save data file_>

exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
