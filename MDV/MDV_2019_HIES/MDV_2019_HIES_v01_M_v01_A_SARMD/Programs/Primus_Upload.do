 /*------------------------------------------------------------------------------
					GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   .do	</_Program name_>
<_Application_>    STATA 16.0	<_Application_>
<_Author(s)_>      Adriana Castillo Castillo : acastillocastill@worldbank.org	</_Author(s)_>
<_Date created_>   12-09-2022	</_Date created_>
<_Date modified>   12-09-2022	</_Date modified_>
Modified by:       Adriana Castillo Castillo : acastillocastill@worldbank.org
-----------------------------------
<_Version Control_>
Date:	12-09-2022
File:	.do
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
log using "P:\SARMD\_script\2.primus_upload_do-file\PRIMUSuploadOutput\LKA_2019.log",  replace

glo   cpiver       "v08"
local code         "LKA"
local year         "2019"
local survey       "HIES"
local vm           "01"
local va           "01"
local type         "SARMD"
glo   module       "GMD"
local cpi_var      "cpi2017_`cpiver'"
local cpi_period   "`year'"
local ppp_var      "ppp_2017"

local yearfolder   "`code'_`year'_`survey'"
local gmdfolder    "`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD"
local filename     "`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD_${module}"
local filename_UTL "`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD_UTL"
local filename_DWL "`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD_DWL"
tempfile			individual_level_data
*</_Program setup_>

/*------------------------------------------------------------------------------*
/*------------------------------------------------------------------------------*
1. PRIMUS UPLOAD 
*------------------------------------------------------------------------------*/
*------------------------------------------------------------------------------*/
 use "$rootdatalib\\`code'\\`yearfolder'\\`gmdfolder'\\Data\Harmonized\\`filename'.dta", clear 
 
      foreach v of varlist welfare welfaredef welfarenom welfareother welfareothertype {
	     sum `v'
		 local `v'_mean = r(mean)
	     di ``v'_mean'
		 
		 if "`code'"=="LKA" {
			replace `v'=`v'*12 if ``v'_mean'<50000 
		 }
		 else {
		     di "Nothing to do"
		 }
	 }
 
 primus_upload  ,  ///
 countrycode("`code'")  year("`year'")  survey("`survey'") veralt(`va') vermast(`vm') welfare(welfare) welfaretype(EXP) ///
 welfshprosperity(welfshprosperity) weight(weight) welfshprtype(EXP) cpiperiod(cpiperiod) ///
 weighttype(PW) hsize(hsize) module(ALL) hhid(hhid) pid(pid) savepath(P:\SARMD\_script\2.primus_upload_do-file\PRIMUSuploadOutput) output("`filename'".xlsx)
 
 exit 
 
 primus_upload  ,  ///
 countrycode("`code'")  year("`year'")  survey("`survey'") veralt(`va') vermast(`vm') cpi(`cpi_var')  cpiperiod(`cpi_period') ppp(`ppp_var') welfare(welfare) welfaretype(EXP) ///
 welfshprosperity(welfshprosperity) weight(weight) welfshprtype(EXP) ///
 weighttype(PW) hsize(hsize) module(ALL) hhid(hhid) pid(pid) savepath(P:\SARMD\_script\2.primus_upload_do-file\PRIMUSuploadOutput) output("`filename'".xlsx)
 
 log close 
 exit 
 *<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>*