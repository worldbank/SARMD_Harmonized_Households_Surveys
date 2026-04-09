/*------------------------------------------------------------------------------
					GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   MDV_2016_HIES_v01_M_v01_A_GMD_GEO.do	</_Program name_>
<_Application_>    STATA 16.0	<_Application_>
<_Author(s)_>      Navishti Das and Javier Parada	</_Author(s)_>
<_Date created_>   03-03-2019	</_Date created_>
<_Date modified>    3 Mar 2020	</_Date modified_>
** MODIFIED         07/06/2023 by Adriana Castillo Castillo   
--------------------------------------------------------------------------------
<_Country_>        MDV	</_Country_>
<_Survey Title_>   HIES	</_Survey Title_>
<_Survey Year_>    2016	</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:	03-03-2019
File:	MDV_2016_HIES_v01_M_v01_A_GMD_GEO.do
- First version
</_Version Control_>
------------------------------------------------------------------------------*/

*<_Program setup_>

clear all
set more off

local code         "MDV"
local year         "2016"
local survey       "HIES"
local vm           "01"
local va           "01"
local type         "SARMD"
glo   module       "GEO"
local yearfolder   "`code'_`year'_`survey'"
local SARMDfolder  "`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD"
local filename     "`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD_${module}"
*</_Program setup_>

*<_Folder creation_>
*</_Folder creation_>

*datalibweb, country(`code') year(`year') type(`type') survey(`survey') vermast(`vm') veralt(`va') mod(IND) clear 
use "$rootdatalib\\`code'\\`yearfolder'\\`SARMDfolder'\Data\Harmonized\\`yearfolder'_v`vm'_M_v`va'_A_SARMD_IND.dta", clear
*</_Datalibweb request_>

*<_countrycode_>
*<_countrycode_note_> country code *</_countrycode_note_>
*<_countrycode_note_> countrycode brought in from SARMD *</_countrycode_note_>
*code
*</_countrycode_>

*<_year_>
*<_year_note_> Year *</_year_note_>
*<_year_note_> year brought in from SARMD *</_year_note_>
*year
*</_year_>

*<_hhid_>
*<_hhid_note_> Household identifier  *</_hhid_note_>
*<_hhid_note_> hhid brought in from SARMD *</_hhid_note_>
*clonevar hhid = idh
*</_hhid_>

*<_pid_>
*<_pid_note_> Personal identifier  *</_pid_note_>
*<_pid_note_> pid brought in from rawdata *</_pid_note_>
*clonevar pid  = idp
*</_pid_>

*<_weight_>
*<_weight_note_> Household weight *</_weight_note_>
*<_weight_note_> weight brought in from rawdata *</_weight_note_>
clonevar  weight = wgt
*</_weight_>

*<_weighttype_>
*<_weighttype_note_> Weight type (frequency, probability, analytical, importance) *</_weighttype_note_>
*<_weighttype_note_> weighttype brought in from rawdata *</_weighttype_note_>
*gen weighttype = "PW"
*</_weighttype_>

*<_subnatid1_>
*<_subnatid1_note_> Subnational ID - highest level *</_subnatid1_note_>
*<_subnatid1_note_> subnatid1 brought in from SARMD *</_subnatid1_note_>
*subnatid1
*</_subnatid1_>

*<_subnatid2_>
*<_subnatid2_note_> Subnational ID - second highest level *</_subnatid2_note_>
*<_subnatid2_note_> subnatid2 brought in from SARMD *</_subnatid2_note_>
*subnatid2
*</_subnatid2_>

*<_subnatid3_>
*<_subnatid3_note_> Subnational ID - third highest level *</_subnatid3_note_>
*<_subnatid3_note_> subnatid3 brought in from SARMD *</_subnatid3_note_>
*gen subnatid3=.
*</_subnatid3_>

*<_subnatid4_>
*<_subnatid4_note_> Subnational ID - lowest level *</_subnatid4_note_>
*<_subnatid4_note_> subnatid4 brought in from SARMD *</_subnatid4_note_>
*gen subnatid4 = ""
*</_subnatid4_>

*<_subnatidsurvey_>
*<_subnatidsurvey_note_> Survey representation of geographical units *</_subnatidsurvey_note_>
*<_subnatidsurvey_note_> subnatidsurvey brought in from SARMD *</_subnatidsurvey_note_>
gen subnatidsurvey=.
*</_subnatidsurvey_>

*<_strata_>
*<_strata_note_> Strata *</_strata_note_>
*<_strata_note_> strata brought in from SARMD *</_strata_note_>
*strata
*</_strata_>

*<_psu_>
*<_psu_note_> PSU *</_psu_note_>
*<_psu_note_> psu brought in from SARMD *</_psu_note_>
*psu
*</_psu_>

*<_subnatid1_prev_>
*<_subnatid1_prev_note_> Subnatid *</_subnatid1_prev_note_>
*<_subnatid1_prev_note_> subnatid1_prev brought in from SARMD *</_subnatid1_prev_note_>
gen subnatid1_prev=""
*</_subnatid1_prev_>

*<_subnatid2_prev_>
*<_subnatid2_prev_note_> Subnatid *</_subnatid2_prev_note_>
*<_subnatid2_prev_note_> subnatid2_prev brought in from SARMD *</_subnatid2_prev_note_>
gen subnatid2_prev=""
*</_subnatid2_prev_>

*<_subnatid3_prev_>
*<_subnatid3_prev_note_> Subnatid *</_subnatid3_prev_note_>
*<_subnatid3_prev_note_> subnatid3_prev brought in from SARMD *</_subnatid3_prev_note_>
gen subnatid3_prev=""
*</_subnatid3_prev_>

*<_subnatid4_prev_>
*<_subnatid4_prev_note_> Subnatid *</_subnatid4_prev_note_>
*<_subnatid4_prev_note_> subnatid4_prev brought in from SARMD *</_subnatid4_prev_note_>
gen subnatid4_prev=""
*</_subnatid4_prev_>

*<_gaul_adm1_code_>
	gen gaul_adm1_code=.
	label var gaul_adm1_code "GAUL code for admin1 level"
	replace gaul_adm1_code=1990 if subnatid1=="1 - Alif Alif"
	replace gaul_adm1_code=1991 if subnatid1=="2 - Alif Dhaal"
	replace gaul_adm1_code=1992 if subnatid1=="3 - Baa"
	replace gaul_adm1_code=1993 if subnatid1=="4 - Dhaalu"
	replace gaul_adm1_code=1994 if subnatid1=="5 - Faafu"
	replace gaul_adm1_code=1995 if subnatid1=="6 - Gaafu Alif"
	replace gaul_adm1_code=1996 if subnatid1=="7 - Gaafu Dhaalu"
	replace gaul_adm1_code=. if subnatid1=="8 - Gnaviyani"
	replace gaul_adm1_code=1997 if subnatid1=="9 - Haa Alif"
	replace gaul_adm1_code=1998 if subnatid1=="10 - Haa Dhaalu"
	replace gaul_adm1_code=1999 if subnatid1=="11 - Kaafu"
	replace gaul_adm1_code=2000 if subnatid1=="12 - Laamu"
	replace gaul_adm1_code=2001 if subnatid1=="13 - Lhaviyani"
	replace gaul_adm1_code=2002 if subnatid1=="14 - Malé"
	replace gaul_adm1_code=2003 if subnatid1=="15 - Meemu"
	replace gaul_adm1_code=2004 if subnatid1=="16 - Noonu"
	replace gaul_adm1_code=2005 if subnatid1=="17 - Raa"
	replace gaul_adm1_code=2006 if subnatid1=="18 - Seenu/Addu"
	replace gaul_adm1_code=2007 if subnatid1=="19 - Shaviyani"
	replace gaul_adm1_code=2008 if subnatid1=="20 - Thaa"
	replace gaul_adm1_code=2009 if subnatid1=="21 - Vaavu"
*<_gaul_adm1_code_>


*<_gaul_adm2_code_>
*<_gaul_adm2_code_note_> Gaul Code *</_gaul_adm2_code_note_>
*<_gaul_adm2_code_note_> gaul_adm2_code brought in from SARMD *</_gaul_adm2_code_note_>
gen gaul_adm2_code=.
*</_gaul_adm2_code_>

*<_gaul_adm3_code_>
*<_gaul_adm3_code_note_> Gaul Code *</_gaul_adm3_code_note_>
*<_gaul_adm3_code_note_> gaul_adm3_code brought in from SARMD *</_gaul_adm3_code_note_>
gen gaul_adm3_code=.
*</_gaul_adm3_code_>

*<_urban_>
*<_urban_note_> Urban (1) or rural (0) *</_urban_note_>
*<_urban_note_> urban brought in from SARMD *</_urban_note_>
*urban
*</_urban_>

*<_Keep variables_>
*keep countrycode year hhid pid weight weighttype subnatid1 subnatid2 subnatid3 subnatid4 subnatidsurvey strata psu subnatid1_prev subnatid2_prev subnatid3_prev subnatid4_prev gaul_adm1_code gaul_adm2_code gaul_adm3_code urban
order countrycode year hhid pid weight weighttype
sort hhid pid 
*</_Keep variables_>

*<_Save data file_>
do   "P:\SARMD\SARDATABANK\SARMDdofiles\_aux\Labels_GMD2.0.do"
save "${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'\Data\Harmonized\\`filename'.dta" , replace
*</_Save data file_>