/*------------------------------------------------------------------------------
					GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   BTN_2022_BLSS_v01_M_v01_A_SARMD_GEO.do	</_Program name_>
<_Application_>    STATA 16.0	<_Application_>
<_Author(s)_>      jogreen@worldbank.org	</_Author(s)_>
<_Date created_>   11-28-2022	</_Date created_>
<_Date modified>   11-28-2022	</_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        BTN	</_Country_>
<_Survey Title_>   BLSS	</_Survey Title_>
<_Survey Year_>    2022	</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:	11-28-2022
File:	BTN_2022_BLSS_v01_M_v01_A_SARMD_GEO.do
- First version
</_Version Control_>
------------------------------------------------------------------------------*/

*<_Program setup_>
clear all
set more off

local code         "BTN"
local year         "2022"
local survey       "BLSS"
local vm           "01"
local va           "02"
local type         "SARMD"
global module      "GEO"
local yearfolder    "`code'_`year'_`survey'"
local SARMDfolder    "`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'"
local filename      "`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'_${module}"
glo output          "${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'\\Data\Harmonized" 
*</_Program setup_>

	* weights
	datalibweb, country(`code') year(`year') type(SARRAW) filename(weights) local localpath(${rootdatalib})
	tempfile weight
	save `weight'
	
	* merge in main data
	datalibweb, country(`code') year(`year') type(SARRAW) filename(`yearfolder'_v`vm'_M.dta) local localpath(${rootdatalib})

	* The weights variable in the BTN_2022_BLSS_v01_M file is the old weights variable, so remove it.
	drop weight weights
	merge m:1 interview__id using `weight', nogen assert(match)
	tempfile base 
	save `base'
	
	use "${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'\Data\Harmonized\\`yearfolder'_v`vm'_M_v`va'_A_`type'_IND.dta" 
	merge 1:1 hhid pid using `base', nogen

*<_countrycode_>
*<_countrycode_note_> country code *</_countrycode_note_>
*<_countrycode_note_> countrycode brought in from rawdata *</_countrycode_note_>
cap gen countrycode="`code'"
*</_countrycode_>

*<_year_>
*<_year_note_> Year *</_year_note_>
*<_year_note_> year brought in from rawdata *</_year_note_>
confirm var  year
*</_year_>

*<_hhid_>
*<_hhid_note_> Household identifier  *</_hhid_note_>
*<_hhid_note_> hhid brought in from rawdata *</_hhid_note_>
confirm var  hhid
*</_hhid_>

*<_weight_>
*<_weight_note_> Household weight *</_weight_note_>
*<_weight_note_> weight brought in from rawdata *</_weight_note_>
clonevar weight = weights
*</_weight_>

*<_weighttype_>
*<_weighttype_note_> Weight type (frequency, probability, analytical, importance) *</_weighttype_note_>
*<_weighttype_note_> weighttype brought in from rawdata *</_weighttype_note_>
confirm var weighttype
*</_weighttype_>

*<_subnatid1_>
*<_subnatid1_note_> Subnational ID - highest level *</_subnatid1_note_>
*<_subnatid1_note_> subnatid1 brought in from rawdata *</_subnatid1_note_>
label define dcode 1 "21 - Bumthang" 2 "11 - Chukha" 3 "44 - Dagana" 4 "16 - Gasa" 5 "12 - Ha" 6 "31 - Lhuntshi" 7 "32 - Mongar" 8 "13 - Paro" 9 "35 - Pemagatshel" 10 "15 - Punakha" 11 "36 - Samdrup Jongkhar" 12 "41 - Samtse" 13 "42 - Sarpang" 14 "14 - Thimphu" 15 "33 - Trashigang" 16 "34 - Tashi Yangtse" 17 "22 - Trongsa" 18 "43 - Tsirang" 19 "17 - Wangdi Phodrang" 20 "23 - Zhemgang", replace
*decode dcode, g(subnatid1)
*</_subnatid1_>

*<_subnatid2_>
*<_subnatid2_note_> Subnational ID - second highest level *</_subnatid2_note_>
*<_subnatid2_note_> subnatid2 brought in from rawdata *</_subnatid2_note_>
cap gen subnatid2=""
*</_subnatid2_>

*<_subnatid3_>
*<_subnatid3_note_> Subnational ID - third highest level *</_subnatid3_note_>
*<_subnatid3_note_> subnatid3 brought in from rawdata *</_subnatid3_note_>
cap gen subnatid3=""
*</_subnatid3_>

*<_subnatid4_>
*<_subnatid4_note_> Subnational ID - lowest level *</_subnatid4_note_>
*<_subnatid4_note_> subnatid4 brought in from rawdata *</_subnatid4_note_>
*gen subnatid4=""
*</_subnatid4_>

*<_subnatidsurvey_>
*<_subnatidsurvey_note_> Survey representation of geographical units *</_subnatidsurvey_note_>
*<_subnatidsurvey_note_> subnatidsurvey brought in from rawdata *</_subnatidsurvey_note_>
gen subnatidsurvey=.
*</_subnatidsurvey_>

*<_strata_>
*<_strata_note_> Strata *</_strata_note_>
*<_strata_note_> strata brought in from rawdata *</_strata_note_>
cap g strata = stratum44
*</_strata_>

*<_psu_>
*<_psu_note_> PSU *</_psu_note_>
*<_psu_note_> psu brought in from rawdata *</_psu_note_>
confirm var psu
*</_psu_>

*<_subnatid1_prev_>
*<_subnatid1_prev_note_> Subnatid *</_subnatid1_prev_note_>
*<_subnatid1_prev_note_> subnatid1_prev brought in from rawdata *</_subnatid1_prev_note_>
gen subnatid1_prev=.
*</_subnatid1_prev_>

*<_subnatid2_prev_>
*<_subnatid2_prev_note_> Subnatid *</_subnatid2_prev_note_>
*<_subnatid2_prev_note_> subnatid2_prev brought in from rawdata *</_subnatid2_prev_note_>
gen subnatid2_prev=.
*</_subnatid2_prev_>

*<_subnatid3_prev_>
*<_subnatid3_prev_note_> Subnatid *</_subnatid3_prev_note_>
*<_subnatid3_prev_note_> subnatid3_prev brought in from rawdata *</_subnatid3_prev_note_>
gen subnatid3_prev=.
*</_subnatid3_prev_>

*<_subnatid4_prev_>
*<_subnatid4_prev_note_> Subnatid *</_subnatid4_prev_note_>
*<_subnatid4_prev_note_> subnatid4_prev brought in from rawdata *</_subnatid4_prev_note_>
gen subnatid4_prev=.
*</_subnatid4_prev_>

*<_gaul_adm1_code_>
*<_gaul_adm1_code_note_> Gaul Code *</_gaul_adm1_code_note_>
*<_gaul_adm1_code_note_> gaul_adm1_code brought in from rawdata *</_gaul_adm1_code_note_>
recode dcode (1=2105) (2=2106) (3=2107) (4=2108) (5=2109) (6=2110) (7=2111) (8=2112) (9=2113) (10=2114) (11=2115) (12=2116) (13=2117) (14=2118) (15=2119) (16=2120) (17=2121) (18=2122) (19=2123) (20=2124) (*=.), g(gaul_adm1_code)
*</_gaul_adm1_code_>

*<_gaul_adm2_code_>
*<_gaul_adm2_code_note_> Gaul Code *</_gaul_adm2_code_note_>
*<_gaul_adm2_code_note_> gaul_adm2_code brought in from rawdata *</_gaul_adm2_code_note_>
gen gaul_adm2_code=.
*</_gaul_adm2_code_>

*<_gaul_adm3_code_>
*<_gaul_adm3_code_note_> Gaul Code *</_gaul_adm3_code_note_>
*<_gaul_adm3_code_note_> gaul_adm3_code brought in from rawdata *</_gaul_adm3_code_note_>
gen gaul_adm3_code=.
*</_gaul_adm3_code_>

*<_urban_>
*<_urban_note_> Urban (1) or rural (0) *</_urban_note_>
*<_urban_note_> urban brought in from rawdata *</_urban_note_>
*gen urban = (area==1)
*</_urban_>

*<_Keep variables_>
collapse (firstnm) weight weighttype subnatid1 subnatid2 subnatid3 subnatid4 subnatidsurvey strata psu subnatid1_prev subnatid2_prev subnatid3_prev subnatid4_prev gaul_adm1_code gaul_adm2_code gaul_adm3_code urban, by(countrycode year hhid)
order countrycode year hhid weight weighttype
sort hhid 
isid hhid
gen relationharm=1
gen pid="01"
*</_Keep variables_>

*<_Save data file_>
quietly do 	"$rootdofiles\_aux\Labels_GMD2.0.do"
save "$output\\`filename'.dta", replace
*</_Save data file_>
