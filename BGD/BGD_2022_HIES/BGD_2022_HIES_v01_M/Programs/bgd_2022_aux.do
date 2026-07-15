/*------------------------------------------------------------------------------
					SAMRD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   BGD_2022_aux.do	</_Program name_>
<_Application_>    STATA 16.0	<_Application_>
<_Author(s)_>      Adriana Castillo Castillo 	</_Author(s)_>
<_Date created_>   04-2023	</_Date created_>
<_Date modified>    4 Apr 2023	</_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        BGD	</_Country_>
<_Survey Title_>   HIES	</_Survey Title_>
<_Survey Year_>    2022	</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:	04-2023
File:	BGD_2022_aux.do
- First version
</_Version Control_>
------------------------------------------------------------------------------*/


*<_Program setup_>
clear all
set more off

local code         "BGD"
local year         "2022"
local survey       "HIES"
local vm           "01"
local va           "01"
local type         "SARMD"
local yearfolder   "BGD_2022_HIES"
local SAMRDfolder  "BGD_2022_HIES_v01_M_v01_A_SAMRD"
*local filename     "BGD_2022_HIES_v01_M_v01_A_SAMRD_IND"
*</_Program setup_>

** DIRECTORY
	global input "${rootdatalib}\\`code'\\`code'_`year'_`survey'\\`code'_`year'_`survey'_v`vm'_M"
	global output "${rootdatalib}\\`code'\\`code'_`year'_`survey'\\`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD"
	
   
** MONTH OF INTERVIEW - Database 
	use "${input}\Data\Stata\HH_SEC_9A1_hies2022_qty_gm_new.dta", clear 
    rename *, lower
	keep term psu hhid s9a1q06 s9a1q07 item day 
	gen hhold=psu*1000+hhid 
	rename hhid hhid_orig
	rename s9a1q06 month 
	rename s9a1q07 year 
	egen mode_month=mode(month), by(psu term hhold)
	bys  psu term hhold: gen id=_n
	sort psu term hhold item year month day id
	replace mode_month=month if id==1 & mode_month==.
	gen  mode_year = year if mode_month==month
	egen mode_year_max=max(mode_year),by(psu term hhold)
	order psu term hhold item year month day mode_*
	keep psu term hh* mode_*
	rename mode_year_max year
	rename mode_month month
	drop mode_year
    duplicates drop psu term month year hhold, force
	drop if month==.
	
	
** CPI from IMF 
	preserve 
    import excel "${input}\Data\Stata\IMF_BGD_CPI_Indexes_And_Weights.xlsx", sheet("datalibweb") firstrow clear
	keep code year month monthly_cpi yearly_cpi
	keep if year>=2021 & year<=2022
	tempfile CPI_dlw_2022
	save `CPI_dlw_2022'
	restore 
    merge m:1 month year using  `CPI_dlw_2022', nogen keep(match)
	rename (code year month) (countrycode year_survey month_survey)
	tempfile CPI_BGD_2022
	save `CPI_BGD_2022'
   
   
** WELFARE
    *use "${input}\Data\Stata\longhh_hies2022.dta", clear 
	use "${input}\Data\Stata\longhh_hies2022_excl_new_items.dta", clear 
	rename *, lower
	keep psu hhold p_cons2 
	rename p_cons2 welfarenom 
	merge 1:1 psu hhold using `CPI_BGD_2022', nogen keep(match)
	gen welfare=welfarenom*yearly_cpi/monthly_cpi
	tempfile CPI_BGD_2022
	save `CPI_BGD_2022'
	
   
** CPI from datalibweb 
   datalibweb, country(Support) year(2005) type(GMDRAW) surveyid(Support_2005_CPI_v06_M) filename(Final_CPI_PPP_to_be_used.dta) 
   keep if code=="BGD"
   keep code icp2017
   rename code countrycode
   duplicates drop countrycode, force
   merge 1:m countrycode using `CPI_BGD_2022', nogen
   tempfile CPI_BGD_2022
   save `CPI_BGD_2022'

	
   use "$rootdatalib\\`code'\\`yearfolder'\\`SAMRDfolder'\Data\Harmonized\\BGD_2022_HIES_v01_M_v01_A_SAMRD_IND.dta", clear 
   merge m:1 countrycode psu hhold using `CPI_BGD_2022' , nogen keep(match)
   drop if welfare==.
   
   gen cpi2017=yearly_cpi/161.226455688476563
   
   /*
   gen welfare_new=(12/365)*welfare/cpi2017/icp2017
   
   apoverty welfare_new [aw=weight], line(2.15) gen(dep_poor215)
   apoverty welfare_new [aw=weight], line(3.65) gen(dep_poor365)
   apoverty welfare_new [aw=weight], line(6.85) gen(dep_poor685)	
  */ 
   save "$rootdatalib\\`code'\\`yearfolder'\\`SAMRDfolder'\Data\Harmonized\\BGD_2022_HIES_v01_M_v01_A_SAMRD_IND_aux.dta", replace 
   
   
   

   