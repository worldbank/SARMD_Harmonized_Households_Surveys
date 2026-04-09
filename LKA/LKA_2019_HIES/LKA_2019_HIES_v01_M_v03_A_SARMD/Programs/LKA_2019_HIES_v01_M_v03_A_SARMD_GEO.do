/*------------------------------------------------------------------------------
  GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   	LKA_2019_HIES_v01_M_v03_A_SARMD_GEO.do	   </_Program name_>
<_Application_>    	STATA 17.0									 <_Application_>
<_Author(s)_>       Joe Green 		<jogreen@worldbank.org>		  </_Author(s)_>
<_Date created_>    06-2022	                                   </_Date created_>
<_Author(s)_>      	Leo Tornarolli 	<tornarolli@gmail.com>		  </_Author(s)_>
<_Date modified_>   10-2024									  </_Date modified_>
<_Date modified>    October 2024							  </_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        	LKA											    </_Country_>
<_Survey Title_>   	HIES									   </_Survey Title_>
<_Survey Year_>    	2019										</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:				10-2024
File:				LKA_2019_HIES_v01_M_v03_A_SARMD_GEO.do
First version
</_Version Control_>
------------------------------------------------------------------------------*/

*<_Program setup_>
clear all
set more off

local code         		"LKA"
local year         		"2019"
local survey       		"HIES"
local vm           		"01"
local va           		"03"
local type         		"SARMD"
global module       	"GEO"
local yearfolder    	"`code'_`year'_`survey'"
local SARMDfolder    	"`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'"
local filename      	"`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'_${module}"
glo output          	"${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'\\Data\Harmonized" 
*</_Program setup_>


*<_Datalibweb request_>
use   "${rootdatalib}\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M\Data\Stata\\`yearfolder'_v`vm'_M.dta", clear
sort  hhid pid
merge 1:1 hhid pid using "${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'\Data\Harmonized\\`yearfolder'_v`vm'_M_v`va'_A_`type'_INC.dta" 
drop _merge
sort  hhid pid
rename industry industry_hies
merge 1:1 hhid pid using "${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'\Data\Harmonized\\`yearfolder'_v`vm'_M_v`va'_A_`type'_IND.dta" 
drop _merge
*</_Datalibweb request_>


*<_countrycode_>
*<_countrycode_note_> country code *</_countrycode_note_>
*<_countrycode_note_> countrycode brought in from rawdata *</_countrycode_note_>
*gen countrycode = code
* NOTE: this variable already exists in harmonized form
*</_countrycode_>

*<_year_>
*<_year_note_> Year *</_year_note_>
*<_year_note_> year brought in from rawdata *</_year_note_>
* NOTE: this variable already exists in harmonized form
*</_year_>

*<_hhid_>
*<_hhid_note_> Household identifier  *</_hhid_note_>
*<_hhid_note_> hhid brought in from rawdata *</_hhid_note_>
* NOTE: this variable already exists in harmonized form
*</_hhid_>

*<_weight_>
*<_weight_note_> Household weight *</_weight_note_>
*<_weight_note_> weight brought in from rawdata *</_weight_note_>
clonevar weight = finalweight
*</_weight_>

*<_weighttype_>
*<_weighttype_note_> Weight type (frequency, probability, analytical, importance) *</_weighttype_note_>
*<_weighttype_note_> weighttype brought in from rawdata *</_weighttype_note_>
*gen weighttype = "PW"
*</_weighttype_>

*<_subnatid1_>
*<_subnatid1_note_> Subnational ID - highest level *</_subnatid1_note_>
*<_subnatid1_note_> subnatid1 brought in from rawdata *</_subnatid1_note_>
*</_subnatid1_>

*<_subnatid2_>
*<_subnatid2_note_> Subnational ID - second highest level *</_subnatid2_note_>
*<_subnatid2_note_> subnatid2 brought in from rawdata *</_subnatid2_note_>
*</_subnatid2_>

*<_subnatid3_>
*<_subnatid3_note_> Subnational ID - third highest level *</_subnatid3_note_>
*<_subnatid3_note_> subnatid3 brought in from rawdata *</_subnatid3_note_>
*</_subnatid3_>

*<_subnatid4_>
*<_subnatid4_note_> Subnational ID - lowest level *</_subnatid4_note_>
*<_subnatid4_note_> subnatid4 brought in from rawdata *</_subnatid4_note_>
*</_subnatid4_>

*<_subnatidsurvey_>
*<_subnatidsurvey_note_> Survey representation of geographical units *</_subnatidsurvey_note_>
*<_subnatidsurvey_note_> subnatidsurvey brought in from rawdata *</_subnatidsurvey_note_>
gen subnatidsurvey=.
*</_subnatidsurvey_>

*<_strata_>
*<_strata_note_> Strata *</_strata_note_>
*<_strata_note_> strata brought in from rawdata *</_strata_note_>
*</_strata_>

*<_psu_>
*<_psu_note_> PSU *</_psu_note_>
*<_psu_note_> psu brought in from rawdata *</_psu_note_>
* NOTE: this variable already exists in harmonized form
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
gen      district1 = substr(string(district),1,1)
destring district1, replace
recode   district1 (1=2744) (2=2736) (3=2742) (4=2740) (5=2737) (6=2739) (7=2738) (8=2743) (9=2741) (*=.), g(gaul_adm1_code)
*</_gaul_adm1_code_>

*<_gaul_adm2_code_>
*<_gaul_adm2_code_note_> Gaul Code *</_gaul_adm2_code_note_>
*<_gaul_adm2_code_note_> gaul_adm2_code brought in from rawdata *</_gaul_adm2_code_note_>
recode district (11=25851) (12=25852) (13=25853) (21=41748) (22=25830) (23=41749) (31=25846) (32=25848) (33=25847) (41=25839) (42=25841) (43=25843) (44=25842) (45=25840) (51=25833) (52=25832) (53=25834) (61=25837) (62=25838) (71=25835) (72=25836) (81=25849) (82=25850) (91=25845) (92=25844) (*=.), g(gaul_adm2_code)
*</_gaul_adm2_code_>

*<_gaul_adm3_code_>
*<_gaul_adm3_code_note_> Gaul Code *</_gaul_adm3_code_note_>
*<_gaul_adm3_code_note_> gaul_adm3_code brought in from rawdata *</_gaul_adm3_code_note_>
gen gaul_adm3_code=.
*</_gaul_adm3_code_>

*<_urban_>
*<_urban_note_> Urban (1) or rural (0) *</_urban_note_>
*<_urban_note_> urban brought in from rawdata *</_urban_note_>
*</_urban_>


*<_Keep variables_>
order countrycode year hhid pid weight weighttype
sort  hhid pid
*</_Keep variables_>


*<_Save data file_>
quietly do 	"$rootdofiles\_aux\Labels_GMD2.0.do"
save 		"$output\\`filename'.dta", replace
*</_Save data file_>
