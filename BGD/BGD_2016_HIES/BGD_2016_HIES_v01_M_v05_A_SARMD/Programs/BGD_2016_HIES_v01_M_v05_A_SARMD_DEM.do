/*------------------------------------------------------------------------------
					GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   BGD_2016_HIES_v01_M_v01_A_GMD_DEM.do	</_Program name_>
<_Application_>    STATA 16.0	<_Application_>
<_Author(s)_>      Navishti Das and Javier Parada	</_Author(s)_>
<_Date created_>   03-03-2019	</_Date created_>
<_Date modified>    3 Mar 2020	</_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        BGD	</_Country_>
<_Survey Title_>   HIES	</_Survey Title_>
<_Survey Year_>    2016	</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:	03-03-2019
File:	BGD_2016_HIES_v01_M_v01_A_GMD_DEM.do
- First version
</_Version Control_>
------------------------------------------------------------------------------*/

*<_Program setup_>
 
clear all
set more off

local code         "BGD"
local year         "2016"
local survey       "HIES"
local vm           "01"
local va           "05"
local type         "SARMD"
local yearfolder   "`code'_`year'_`survey'"
local SARMDfolder  "`yearfolder'_v`vm'_M_v`va'_A_SARMD"
local filename     "`yearfolder'_v`vm'_M_v`va'_A_SARMD_DEM"
*</_Program setup_>

*<_Folder creation_>
*</_Folder creation_>

*<_Datalibweb request_>
use "${rootdatalib}\\`code'\\`code'_`year'_`survey'\\`code'_`year'_`survey'_v`vm'_M\Data\Stata\\`code'_`year'_`survey'_M.dta", clear 
egen idh=concat(psu hhid), punct(-)
cap clonevar hhid=idh
egen idp=concat(idh idp1), punct(-)
cap clonevar pid=idp 
keep *id id* s1aq*
	
merge 1:1 idh idp using "$rootdatalib\\`code'\\`yearfolder'\\`SARMDfolder'\Data\Harmonized\\`yearfolder'_v`vm'_M_v`va'_A_SARMD_IND.dta"
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

*<_language_>
*<_language_note_> Language *</_language_note_>
*<_language_note_> language brought in from SARMD *</_language_note_>
gen language=.
*</_language_>

*<_age_>
*<_age_note_> Age of individual (continuous) *</_age_note_>
*<_age_note_> age brought in from SARMD *</_age_note_>
*age 
*</_age_>

*<_male_>
*<_male_note_> Sex of household member (male=1) *</_male_note_>
*<_male_note_> male brought in from SARMD *</_male_note_>
*male 
*</_male_>

*<_relationharm_>
*<_relationharm_note_> Relationship to head of household harmonized across all regions *</_relationharm_note_>
*<_relationharm_note_> relationharm brought in from SARMD *</_relationharm_note_>
*relationharm
*</_relationharm_>

*<_relationcs_>
*<_relationcs_note_> Relationship to head of household harmonized across all regions *</_relationcs_note_>
*<_relationcs_note_> relationcs brought in from SARMD *</_relationcs_note_>
*relationcs
*</_relationcs_>

*<_marital_>
*<_marital_note_> Marital status *</_marital_note_>
*<_marital_note_> marital brought in from SARMD *</_marital_note_>
*marital
*</_marital_>

label define eye_disability_label 1 "No – no difficulty"  2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all"
label define hear_disability_label 1 "No – no difficulty"  2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all"
label define walk_disability_label 1 "No – no difficulty"  2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all"
label define conc_disability_label 1 "No – no difficulty"  2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all"
label define slfcre_disability_label 1 "No – no difficulty"  2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all"
label define comm_disability_label 1 "No – no difficulty"  2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all"

** 1. Do you have difficulty seeing, even if wearing glasses?	
	gen eye_dsablty = s1aq12
	label values eye_dsablty eye_disability_label
	label var eye_dsablty "eye_dsablty is a numerical variable that indicates whether an individual has any difficulty in seeing, even when wearing glasses."

** 2. Do you have difficulty hearing, even if using a hearing aid?	
	gen hear_dsablty = s1aq13
	label values hear_dsablty hear_disability_label
	label var hear_dsablty "hear_dsablty is a numerical variable that indicates whether an individual has any difficulty in hearing even when using a hearing aid."

** 3. Do you have difficulty walking or climbing steps?	
	gen walk_dsablty = s1aq14
	label values walk_dsablty walk_disability_label
	label var walk_dsablty "walk_dsablty is a numerical variable that indicates whether an individual has any difficulty in walking or climbing steps."

** 4. Do you have difficulty remembering or concentrating?	
	gen conc_dsord = s1aq15
	label values conc_dsord conc_disability_label
	label var conc_dsord "conc_dsord is a numerical variable that indicates whether an individual has any difficulty concentrating or remembering."

** 5. Do you have difficulty (with self-care such as) washing all over or dressing?	
	gen slfcre_dsablty = s1aq16 
	label values slfcre_dsablty slfcre_disability_label
	label var slfcre_dsablty "slfcre_dsablty is a numerical variable that indicates whether an individual has any difficulty with self-care such as washing all over or dressing."

** 6. Using your usual (customary) language, do you have difficulty communicating, for example understanding or being understood?
	gen comm_dsablty = s1aq17
	label values comm_dsablty comm_disability_label
	label var comm_dsablty "comm_dsablty is a numerical variable that indicates whether an individual has any difficulty communicating or understanding usual (customary) language."

replace eye_dsablty=. if eye_dsablty != 1 & eye_dsablty != 2 & eye_dsablty != 3 & eye_dsablty != 4
replace hear_dsablty=. if hear_dsablty != 1 & hear_dsablty != 2 & hear_dsablty != 3 & hear_dsablty != 4
replace walk_dsablty=. if walk_dsablty != 1 & walk_dsablty != 2 & walk_dsablty != 3 & walk_dsablty != 4
replace conc_dsord=. if conc_dsord != 1 & conc_dsord != 2 & conc_dsord != 3 & conc_dsord != 4
replace slfcre_dsablty=. if slfcre_dsablty != 1 & slfcre_dsablty != 2 & slfcre_dsablty != 3 & slfcre_dsablty != 4
replace comm_dsablty=. if comm_dsablty != 1 & comm_dsablty != 2 & comm_dsablty != 3 & comm_dsablty != 4
	
	
 gen agecat=""
 replace agecat="15 years or younger" if age<=15
 replace agecat="15-24 years old" if (age>15 & age<=24)
 replace agecat="25-54 years old" if (age>24 & age<=54)
 replace agecat="55-64 years old" if (age>54 & age<=64)
 replace agecat="65 years or older" if age>64

*<_Keep variables_>
*keep countrycode year hhid pid weight weighttype language age agecat male relationharm relationcs marital eye_dsablty hear_dsablty walk_dsablty conc_dsord slfcre_dsablty comm_dsablty
order countrycode year hhid pid weight weighttype
sort hhid pid 
*</_Keep variables_>

cap drop subnatid1_prev
cap tostring subnatid1_prev, replace 
cap gen subnatid1_prev=""
replace subnatid1_prev="10 - Barisal"    if subnatid1=="10 - Barisal"
replace subnatid1_prev="20 - Chittagong" if subnatid1=="20 - Chittagong"
replace subnatid1_prev="30 - Dhaka"      if subnatid1=="30 - Dhaka"
replace subnatid1_prev="40 - Khulna"     if subnatid1=="40 - Khulna" | subnatid1 =="45 - Mymensingh"
replace subnatid1_prev="50 - Rajshahi"   if subnatid1=="50 - Rajshahi"
replace subnatid1_prev="55 - Rangpur"    if subnatid1=="55 - Rangpur"
replace subnatid1_prev="60 - Sylhet"     if subnatid1=="60 - Sylhet"


*<_Save data file_>
do   "P:\SARMD\SARDATABANK\SARMDdofiles\_aux\Labels_GMD2.0.do"
save "${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'\Data\Harmonized\\`filename'.dta" , replace
*</_Save data file_>
