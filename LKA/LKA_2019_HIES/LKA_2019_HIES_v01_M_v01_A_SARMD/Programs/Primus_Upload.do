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

glo   cpiver       "v08"
local code         "LKA"
local year         "2019"
local survey       "HIES"
local vm           "01"
local va           "01"
local type         "SARMD"
glo   module       "GMD"
glo rootdatalib   "P:\SARMD\SARDATABANK\SAR_DATABANK"
local yearfolder   "`code'_`year'_`survey'"
local gmdfolder    "`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD"
local filename     "`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD_${module}"
local filename_UTL "`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD_UTL"
local filename_DWL "`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD_DWL"
tempfile			individual_level_data
*</_Program setup_>

 use "$rootdatalib\\`code'\\`yearfolder'\\`gmdfolder'\\Data\Harmonized\\`filename'.dta", clear 
 
 primus_upload  ,  ///
 countrycode("`code'")  year("`year'")  survey("`survey'") veralt(`va') vermast(`vm') welfare(welfare) welfaretype(EXP) ///
 welfshprosperity(welfshprosperity) weight(weight) welfshprtype(EXP) ///
 weighttype(PW) hsize(hsize) module(ALL) hhid(hhid) pid(pid) savepath(P:\SARMD\_script\2.primus_upload_do-file\PRIMUSuploadOutput) output("`filename'".xlsx)

 
 
 