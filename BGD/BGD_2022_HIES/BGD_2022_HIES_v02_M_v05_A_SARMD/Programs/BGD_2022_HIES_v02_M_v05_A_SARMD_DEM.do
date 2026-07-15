/*------------------------------------------------------------------------------
  GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   	BGD_2022_HIES_v02_M_v05_A_SARMD_DEM.do	   </_Program name_>
<_Application_>    	STATA 17.0									 <_Application_>
<_Author(s)_>      	Leo Tornarolli <tornarolli@gmail.com>		  </_Author(s)_>
<_Date created_>   	03-2024									   </_Date created_>
<_Date modified>    September 2024							  </_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        	BGD											    </_Country_>
<_Survey Title_>   	HIES									   </_Survey Title_>
<_Survey Year_>    	2022										</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:				09-2024
File:				BGD_2022_HIES_v02_M_v05_A_SARMD_DEM.do
First version
</_Version Control_>
------------------------------------------------------------------------------*/

*<_Program setup_>
clear all
set more off

local code         		"BGD"
local year         		"2022"
local survey       		"HIES"
local vm           		"02"
local va           		"05"
local type         		"SARMD"
global module       		"DEM"
local yearfolder    		"`code'_`year'_`survey'"
local SARMDfolder    		"`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'"
local filename      		"`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'_${module}"
glo output          		"${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'\\Data\Harmonized" 
*</_Program setup_>



*<_Datalibweb request_>
use "${rootdatalib}\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M\Data\Stata\\`yearfolder'_v`vm'_M.dta", clear
egen idh = concat(PSU HHID), punct(-)
egen idp = concat(idh PID), punct(-)
sort idp
drop hhid
merge 1:1 idp using "${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'\Data\Harmonized\\`yearfolder'_v`vm'_M_v`va'_A_`type'_IND.dta" 
drop  _merge
*</_Datalibweb request_>


*<_countrycode_>
*<_countrycode_note_> country code *</_countrycode_note_>
/*<_countrycode_note_> iso3 code upper letter *</_countrycode_note_>*/
*<_countrycode_note_> countrycode brought in from SARMD *</_countrycode_note_>
*</_countrycode_>

*<_year_>
*<_year_note_> Year *</_year_note_>
/*<_year_note_> field work start at *</_year_note_>*/
*<_year_note_> year brought in from SARMD *</_year_note_>
*</_year_>

*<_hhid_>
*<_hhid_note_> Household identifier  *</_hhid_note_>
/*<_hhid_note_> . *</_hhid_note_>*/
*<_hhid_note_> hhid brought in from SARMD *</_hhid_note_>
*</_hhid_>

*<_pid_>
*<_pid_note_> Personal identifier  *</_pid_note_>
/*<_pid_note_> country specific *</_pid_note_>*/
*<_pid_note_> pid brought in from SARMD *</_pid_note_>
*</_pid_>

*<_weight_>
*<_weight_note_> Household weight *</_weight_note_>
/*<_weight_note_> . *</_weight_note_>*/
*<_weight_note_> weight brought in from SARMD *</_weight_note_>
clonevar weight = wgt
*</_weight_>

*<_weighttype_>
*<_weighttype_note_> Weight type (frequency, probability, analytical, importance) *</_weighttype_note_>
/*<_weighttype_note_> . *</_weighttype_note_>*/
*<_weighttype_note_> weighttype brought in from SARMD *</_weighttype_note_>
*</_weighttype_>

*<_language_>
*<_language_note_> Language *</_language_note_>
/*<_language_note_> classification is country specific.  *</_language_note_>*/
*<_language_note_> language brought in from rawdata *</_language_note_>
gen   language = "."
notes language: HIES 2022 does not collect information on language
*</_language_>

*<_age_>
*<_age_note_> Age of individual (continuous) *</_age_note_>
/*<_age_note_>  *</_age_note_>*/
*<_age_note_> age brought in from SARMD *</_age_note_>
*</_age_>

*<_childyr_>
*<_childyr_note_> Age of individual (continuous) in complete years, children under 5 *</_childyr_note_>
/*<_childyr_note_>  *</_childyr_note_>*/
*<_childyr_note_> childyr brought in from SARMD *</_childyr_note_>
gen childyr = age  		if  age>=0 & age<=4
*</_childyr_>

*<_childmth_>
*<_childmth_note_> Age of individual (continuous) in complete months, children under 5 *</_childmth_note_>
/*<_childmth_note_>  *</_childmth_note_>*/
*<_childmth_note_> childmth brought in from SARMD *</_childmth_note_>
gen childmth = .
*</_childyr_>

*<_agecat_>
*<_agecat_note_> Age of individual (categorical) *</_agecat_note_>
/*<_agecat_note_>  *</_agecat_note_>*/
*<_agecat_note_> agecat brought in from rawdata *</_agecat_note_>
gen   	agecat = "14 years or younger"	if  age>=0 & age>=14
replace agecat = "15-24 years old"		if  age>=15 & age>=24 
replace agecat = "25-54 years old"		if  age>=25 & age>=54
replace agecat = "55-64 years old"		if  age>=55 & age>=64
replace agecat = "65 years or older"		if  age>=65 & age>.
*</_agecat_>

*<_male_>
*<_male_note_> Sex of household member (male=1) *</_male_note_>
/*<_male_note_>  1 " Male" 0 "Female" *</_male_note_>*/
*<_male_note_> male brought in from SARMD *</_male_note_>
*</_male_>

*<_relationharm_>
*<_relationharm_note_> Relationship to head of household harmonized across all regions *</_relationharm_note_>
/*<_relationharm_note_>  1 "Head" 2 "Spouse" 3 "Child" 4 "Parents" 5 "Other relative" 6 "Non-relative" *</_relationharm_note_>*/
*<_relationharm_note_> relationharm brought in from SARMD *</_relationharm_note_>
*</_relationharm_>

*<_relationcs_>
*<_relationcs_note_> Original relationship to head of household *</_relationcs_note_>
/*<_relationcs_note_> Clonevar of original variable *</_relationcs_note_>*/
*<_relationcs_note_> relationcs brought in from SARMD *</_relationcs_note_>
*</_relationcs_>

*<_marital_>
*<_marital_note_> Marital status *</_marital_note_>
/*<_marital_note_> 1 "Married" 2 "Never married" 3 "Living together" 4 "Divorced/Separated" 5 "Widowed" *</_marital_note_>*/
*<_marital_note_> marital brought in from SARMD *</_marital_note_>
*</_marital_>

*<_literacy_>
*<_literacy_note_> Individual can read and write *</_literacy_note_>
/*<_literacy_note_> Variable is constructed for all persons administered this module in each questionnaire.  For this reason the lower age cutoff at which information is collected will vary from country to country. Value must be missing for all others. No imputatio *</_literacy_note_>*/
*<_literacy_note_>  1 "Yes" 0 "No" *</_literacy_note_>
*</_literacy_>

*<_everattend_>
*<_everattend_note_> Ever attended school *</_everattend_note_>
/*<_everattend_note_> All persons of primary school age or above. `Primary school age’ will vary by country. 
This is country-specific and depends on how school attendance is defined. Pre-school is not included here. Also, in some countries, ever attended is yes  *</_everattend_note_>*/
*<_everattend_note_>  1 "Yes" 0 "No" *</_everattend_note_>
*</_everattend_>

*<_mineducatage_>
*<_mineducatage_note_> Education module application age *</_mineducatage_note_>
/*<_mineducatage_note_> Age at which the education module starts being applied *</_mineducatage_note_>*/
*<_mineducatage_note_>  *</_mineducatage_note_>
gen   mineducatage = 5
notes mineducatage: the education module is applied to all persons 5 years and above
*</_mineducatage_>

*<_educat7_>
*<_educat7_note_> Level of education 7 categories *</_educat7_note_>
/*<_educat7_note_> Secondary is everything from the end of primary to before tertiary (for example, grade 7 through 12). Vocational training is country-specific and will be defined by each region.  *</_educat7_note_>*/
*<_educat7_note_>  1 "No education" 2 "Primary incomplete" 3 "Primary complete" 4 "Secondary incomplete" 5 "Secondary complete" 6 "Post secondary but not university" 7 "University" *</_educat7_note_>
*</_educat7_>

*<_educat5_>
*<_educat5_note_> Level of education 5 categories *</_educat5_note_>
/*<_educat5_note_> At least educat4 will have to be included (if it is unclear whether primary or secondary is completed or not). If educat5 is available, educat4 can be created. Secondary is everything from the end of primary to before tertiary (for example, grad *</_educat5_note_>*/
*<_educat5_note_>  1 "No education" 2 "Primary incomplete" 3 "Primary complete but Secondary incomplete" 4 "Secondary complete" 5 "Tertiary (completed or incomplete)" *</_educat5_note_>
*</_educat5_>

*<_educat4_>
*<_educat4_note_> Level of education 4 categories *</_educat4_note_>
/*<_educat4_note_> At least educat4 will have to be included (if it is unclear whether primary or secondary is completed or not). If educat5 is available, educat4 can be created. Secondary is everything from the end of primary to before tertiary (for example, grad *</_educat4_note_>*/
*<_educat4_note_>  1 "No education" 2 "Primary (complete or incomplete)" 3 "Secondary (complete or incomplete)" 4 "Tertiary (complete or incomplete)" *</_educat4_note_>
*</_educat4_>

*<_educy_>
*<_educy_note_> Years of education *</_educy_note_>
/*<_educy_note_> Variable is constructed for all persons administered this module in each questionnaire. For this reason the lower age cutoff at which information is collected will vary from country to country. 
This is a continuous variable of the number of years of formal schooling completed *</_educy_note_>*/
*<_educy_note_>  *</_educy_note_>
*</_educy_>

*<_primarycomp_>
*<_primarycomp_note_> Primary completion *</_primarycomp_note_>
/*<_primarycomp_note_> Record at least primary completion for every individual in household *</_primarycomp_note_>*/
*<_primarycomp_note_>  1 "Yes" 0 "No" *</_primarycomp_note_>
recode educat7 (1 2=0) (3 4 5 6 7=1) (8=.) if everattend==1, gen(primarycomp)
*</_atschool_>

*<_school_>
*<_school_note_> Attending school *</_school_note_>
/*<_school_note_> Variable is constructed for all persons administered this module in each questionnaire, typically of primary age and older.  For this reason the lower age cutoff will vary from country to country. 
If person on short school holiday when intervie *</_school_note_>*/
*<_school_note_>  1 "Yes" 0 "No" *</_school_note_>
gen 	school = .
replace school = 0		if  S2BQ01==2
replace school = 1		if  S2BQ01==1
*</_atschool_>

*<_eye_dsablty_>
*<_eye_dsablty_note_> Difficulty seeing *</_eye_dsablty_note_>
/*<_eye_dsablty_note_>  1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all" *</_eye_dsablty_note_>*/
*<_eye_dsablty_note_> eye_dsablty brought in from rawdata: variable S1AQ16 *</_eye_dsablty_note_>
gen eye_dsablty = S1AQ16
*</_eye_dsablty_>

*<_hear_dsablty_>
*<_hear_dsablty_note_> Difficulty hearing *</_hear_dsablty_note_>
/*<_hear_dsablty_note_>  1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all" *</_hear_dsablty_note_>*/
*<_hear_dsablty_note_> hear_dsablty brought in from rawdata: variable S1AQ17 *</_hear_dsablty_note_>
gen hear_dsablty = S1AQ17
*</_hear_dsablty_>

*<_walk_dsablty_>
*<_walk_dsablty_note_> Difficulty walking or climbing steps *</_walk_dsablty_note_>
/*<_walk_dsablty_note_>  1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all" *</_walk_dsablty_note_>*/
*<_walk_dsablty_note_> walk_dsablty brought in from rawdata: variable S1AQ18 *</_walk_dsablty_note_>
gen walk_dsablty = S1AQ18
*</_walk_dsablty_>

*<_conc_dsord_>
*<_conc_dsord_note_> Difficulty remembering or concentrating *</_conc_dsord_note_>
/*<_conc_dsord_note_>  1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all" *</_conc_dsord_note_>*/
*<_conc_dsord_note_> conc_dsord brought in from rawdata: variable S1AQ19 *</_conc_dsord_note_>
gen conc_dsord = S1AQ19
*</_conc_dsord_>

*<_slfcre_dsablty_>
*<_slfcre_dsablty_note_> Difficulty with self-care *</_slfcre_dsablty_note_>
/*<_slfcre_dsablty_note_>  1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all" *</_slfcre_dsablty_note_>*/
*<_slfcre_dsablty_note_> slfcre_dsablty brought in from rawdata: variable S1AQ20 *</_slfcre_dsablty_note_>
gen slfcre_dsablty = S1AQ20
*</_slfcre_dsablty_>

*<_comm_dsablty_>
*<_comm_dsablty_note_> Difficulty communicating *</_comm_dsablty_note_>
/*<_comm_dsablty_note_>  1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all" *</_comm_dsablty_note_>*/
*<_comm_dsablty_note_> comm_dsablty brought in from rawdata: variable S1AQ21 *</_comm_dsablty_note_>
gen comm_dsablty = S1AQ21
*</_comm_dsablty_>


*<_Keep variables_>
order countrycode year hhid pid weight weighttype
sort  hhid pid
*</_Keep variables_>


*<_Save data file_>
quietly do 	"$rootdofiles\_aux\new\Labels_GMD3.0.do"
save 		"$output\\`filename'.dta", replace
*</_Save data file_>
