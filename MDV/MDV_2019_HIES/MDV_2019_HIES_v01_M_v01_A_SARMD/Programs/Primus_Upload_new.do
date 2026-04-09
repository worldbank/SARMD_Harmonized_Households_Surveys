 /*------------------------------------------------------------------------------
					GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   BTN_2022_HIES_v01_M_v01_A_SARMD_SARMD.do	</_Program name_>
<_Application_>    STATA 16.0	<_Application_>
<_Author(s)_>      Adriana Castillo Castillo : acastillocastill@worldbank.org	</_Author(s)_>
<_Date created_>   12-09-2022	</_Date created_>
<_Date modified>   12-09-2022	</_Date modified_>
Modified by:       Adriana Castillo Castillo : acastillocastill@worldbank.org
--------------------------------------------------------------------------------
<_Country_>        BTN	</_Country_>
<_Survey Title_>   HIES	</_Survey Title_>
<_Survey Year_>    2022	</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:	12-09-2022
File:	BTN_2022_HIES_v01_M_v01_A_SARMD_IND.do
- First version
</_Version Control_>
------------------------------------------------------------------------------*/

/*------------------------------------------------------------------------------*
/*------------------------------------------------------------------------------*
0. SET UP 
*------------------------------------------------------------------------------*/
*------------------------------------------------------------------------------*/
*<_Program setup_>
clear all
set more off
*set trace on 

glo rootdatalib    "P:\SARMD\SARDATABANK\SAR_DATABANK"

cap log close 

glo   cpiver       "v08"
local code         "LKA"
local year         "2012"
local survey       "HIES"
local vm_input     "01"
local va_input     "05"
local type         "SARMD"
glo   module       "GMD"
local cpi_var      "cpi2017_`cpiver'"
local cpi_period   "`year'"
local ppp_var      "ppp_2017"
local weighttype   "PW"
local welfaretype  "CONS"

datalibweb, country(LKA) year(2012) type(GMD) mod(GPWG) nocpi
return list 
local vm_output    "01"
local va_output    "05" 

local yearfolder   "`code'_`year'_`survey'"
local gmdfolder    "`code'_`year'_`survey'_v`vm_input'_M_v`va_input'_A_SARMD"
local filename     "`code'_`year'_`survey'_v`vm_input'_M_v`va_input'_A_SARMD_${module}"
local filename_ALL "`code'_`year'_`survey'_v`vm_input'_M_v`va_input'_A_SARMD_ALL"
local filename_UTL "`code'_`year'_`survey'_v`vm_input'_M_v`va_input'_A_SARMD_UTL"
local filename_DWL "`code'_`year'_`survey'_v`vm_input'_M_v`va_input'_A_SARMD_DWL"

log using "P:\SARMD\_script\2.primus_upload_do-file\PRIMUSuploadOutput\\`code'_`year'.log",  replace
tempfile			individual_level_data
*</_Program setup_>

datalibweb, country(LKA) year(2012) type(GMD) mod(GPWG) nocpi
 sum welfare  weight 
 *rename welfareothertype welfareothertype_gmd //LKA 2016
 rename subnatid subnatid_gmd
 rename subnatid2 subnatid2_gmd
 rename subnatid3 subnatid3_gmd
 rename male male_gmd
 rename urban urban_gmd
 rename code code_gmd
 *rename countryname countryname_gmd
 
 preserve 
 use "$rootdatalib\\`code'\\`yearfolder'\\`gmdfolder'\\Data\Harmonized\\`filename_ALL'.dta", clear 
 rename idh hhid 
 rename idp pid 
 drop subnatid* male urban   
 tempfile new_version
 save `new_version'
 restore 
 merge 1:1 hhid pid using `new_version', update  
 
 *merge 1:1 hhid pid using "$rootdatalib\\`code'\\`yearfolder'\\`gmdfolder'\\Data\Harmonized\\`filename_ALL'.dta", update  
*drop if _merge==2
*drop welfareothertype //LKA 2016
*rename welfareothertype_gmd welfareothertype  //LKA 2016

rename  subnatid2_gmd subnatid2
rename  subnatid3_gmd subnatid3
  rename  subnatid_gmd subnatid
 rename  male_gmd male
 rename   urban_gmd urban
 rename  code_gmd code
 *rename  countryname_gmd countryname
	
sum welfare  weight 
 
  
 
 primus_upload  ,  ///
 countrycode("`code'")  year("`year'")  survey("`survey'") veralt(`va_output') vermast(`vm_output')  welfare(welfare) welfaretype(`welfaretype') ///
 welfshprosperity(welfshprosperity) weight(weight) welfshprtype(EXP) cpiperiod(cpiperiod) ///
 weighttype(`weighttype') hsize(hsize) module(ALL) hhid(hhid) pid(pid) nopovcal savepath(P:\SARMD\_script\2.primus_upload_do-file\PRIMUSuploadOutput) output("`filename'".xlsx) overwrite  
 log close 
 exit 
 *cpi(`cpi_var')  ppp(`ppp_var') //variable ppp already defined
 
 
 
 /*
	  *cap rename ppp* icp* 
	  cap rename wgt weight
	  cap rename weight_h weight
	  
      foreach v of varlist welfare welfaredef welfarenom welfareother welfareothertype {
	     sum `v'
		 local `v'_mean = r(mean)
	     di ``v'_mean'
		 
		 if "`code'"=="LKA" | "`code'"=="MDV" {
			replace `v'=`v'*12 if ``v'_mean'<50000 
		 }
		 else {
		     di "Nothing to do"
		 }
	 }
 */
 
 
 primus_upload  ,  ///
 countrycode("`code'")  year("`year'")  survey("`survey'") veralt(`va') vermast(`vm') cpi(`cpi_var')  cpiperiod(`cpi_period') ppp(`ppp_var') welfare(welfare) welfaretype(EXP) ///
 welfshprosperity(welfshprosperity) weight(weight) welfshprtype(EXP) ///
 weighttype(PW) hsize(hsize) module(ALL) hhid(hhid) pid(pid) savepath(P:\SARMD\_script\2.primus_upload_do-file\PRIMUSuploadOutput) output("`filename'".xlsx)
 

 exit 
 *<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>*