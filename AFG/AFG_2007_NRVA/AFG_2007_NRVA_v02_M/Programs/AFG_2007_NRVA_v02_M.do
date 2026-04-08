/*------------------------------------------------------------------------------
					GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   `code'_`year'_`survey'_v01_M_v01_A_GMD_COR.do	</_Program name_>
<_Application_>    STATA 16.0	<_Application_>
<_Author(s)_>      acastillocastill@worldbank.org	</_Author(s)_>
<_Date created_>   05-25-2021	</_Date created_>
<_Date modified>   09-08 2021	</_Date modified_>
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

local code         "AFG"
local year         "2007"
local survey       "NRVA"
local vm           "02"
local va           "06"
local type         "SARMD"
local yearfolder   "`code'_`year'_`survey'"
local input        "$rootdatalib\\`code'\\`code'_`year'_`survey'\\`code'_`year'_`survey'_v`vm'_M"
glo output         "${rootdatalib}\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M\Data\Stata"
*</_Program setup_>

	
*<_Datalibweb request_>
		* PREPARE DATASETS
	global data  = "`input'\Data\Stata"  

	tempfile Area_Name_modified
	use "$data\Area_Name.dta", clear 
	sort cid 
	save `Area_Name_modified', replace 

	tempfile S1_modified
	use "$data\S1.dta", clear 
	sort hhid hhmemid 
	save `S1_modified', replace 

	tempfile S6_modified
	use "$data\S6.dta", clear 
	sort hhid hhmemid 
	save `S6_modified', replace 

	tempfile S7_modified
	use "$data\S7.dta", clear 
	sort hhid hhmemid 
	save `S7_modified', replace 

	tempfile S8_modified
	use "$data\S8.dta", clear 
	sort hhid 
	save `S8_modified', replace 

	tempfile S9A_modified
	use "$data\S9A.dta", clear 
	sort hhid hhmemid 
	save `S9A_modified', replace 

	tempfile S9B_modified
	use "$data\S9B.dta", clear 
	sort hhid hhmemid 
	save `S9B_modified', replace 

	tempfile S20B_modified
	use "$data\S20B.dta", clear 
	sort hhid hhmemid 
	save `S20B_modified', replace 

	tempfile CM4_modified
	use "$data\CM4.dta", clear 
	sort cid 
	save `CM4_modified.dta', replace 

	tempfile S2A_modified
	use "$data\S2A.dta", clear 
	sort hhid 
	save `S2A_modified', replace 

	tempfile S3_modified
	use "$data\S3.dta", clear 
	sort hhid 
	save `S3_modified', replace 

	tempfile S2B_modified
	use "$data\S2B.dta", clear 
	sort hhid 
	save `S2B_modified', replace 

	tempfile poverty_modified
	use "$data\poverty2007.dta", clear 
	sort hhid 
	ren hhsize hhsize_nat
	save `poverty_modified', replace 
	
	
	tempfile S3_modified
	use "$data\S3.dta", clear
	sort hhid
	save `S3_modified', replace
	
	
	tempfile S_M_modified
	use "$data\S_M.dta", clear
	sort hhid
	save `S_M_modified', replace

	loc a "A C"
	foreach p of local a{
	tempfile S5`p'_modified
	use "$data\S5`p'.dta", clear 
	sort hhid
	save `S5`p'_modified', replace
	}
	
	/*
	tempfile pov_cons_modified
	use "$data\pov_cons.dta", clear 
	sort hhid 
	save `pov_cons_modified', replace 
	*/

	* COMBINE DATASETS

	use `S1_modified', clear 

	sort cid 
	merge cid using `Area_Name_modified'
	tab _merge 
	drop if _merge == 2 
	drop _merge 

	order cid provincec provincen districtc hhid hhmemid districtn villagec villagen subnahia Block_No qrt urk kuchic ///
	 urbrur targetm clustern Province_Name_Dari District_Name_Dari Village_Name_Dari pcenter nohhs ProvDari area_weight 

	foreach x in S6_modified S7_modified S9A_modified S9B_modified{
	sort hhid hhmemid
	merge 1:1 hhid hhmemid using ``x''
	tab _merge
	drop if _merge==2
	drop _merge	
	}

	foreach x in S8_modified S2A_modified  S3_modified S2B_modified poverty_modified  S5A_modified S5C_modified S_M_modified{
	sort hhid hhmemid
	merge m:1 hhid using ``x''
	tab _merge
	drop if _merge==2
	drop _merge	
	}

	sort cid 
	merge cid using `CM4_modified'
	tab _merge 
	drop if _merge == 2 
	drop _merge 
	sort hhid hhmemid
	
	cap drop *poor poor poor fline nfline pline  pexnom_* pexadj_* quinpce 
	cap drop hsize
	preserve 
	use "`input'\Data\Stata\consolidated_HHlevel.dta" , clear 
	keep if year==`year'
	drop year Province_Code Province_Name hh_weight ind_weight urru urruku regstrat region quarter2 quarter_aligned provincec districtc mint
	destring hhid, replace 
	tempfile consolidated_HHlevel
	save `consolidated_HHlevel'
	restore 
	merge m:1 hhid using `consolidated_HHlevel'

*</_Datalibweb request_>
	

*<_Save data file_>
compress
if ("`c(username)'"=="dekopon") save "${output}/`yearfolder'_M.dta", replace
else save "${output}/`yearfolder'_M.dta" , replace
*</_Save data file_>
