/*------------------------------------------------------------------------------
					GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   LKA_2019_HIES_v01_M_v01_A_SARMD_LBR.do	</_Program name_>
<_Application_>    STATA 16.0	<_Application_>
<_Author(s)_>      jogreen@worldbank.org	</_Author(s)_>
<_Date created_>   06-26-2022	</_Date created_>
<_Date modified>   26 May 2022	</_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        LKA	</_Country_>
<_Survey Title_>   HIES	</_Survey Title_>
<_Survey Year_>    2019	</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:	06-26-2022
File:	LKA_2019_HIES_v01_M_v01_A_SARMD_LBR.do
- First version
</_Version Control_>
------------------------------------------------------------------------------*/

*<_Program setup_>
clear all
set more off

local code         "LKA"
local year         "2019"
local survey       "HIES"
local vm           "01"
local va           "01"
local type         "SARMD"
glo   module       "LBR"
local yearfolder   "`code'_`year'_`survey'"
local gmdfolder    "`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD"
local filename     "`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD_${module}"
tempfile			individual_level_data
*</_Program setup_>

* global path on Joe's computer
if ("`c(username)'"=="sunquat") {
	glo basepath "/Users/`c(username)'/Projects/WORLD BANK/SAR - GMD data harmonization/datalib/`code'/`yearfolder'"
	glo input "${basepath}/`yearfolder'_v`vm'_M"
	glo output "${basepath}/`yearfolder'_v`vm'_M_v`va'_A_SARGMD/Data/Harmonized"
	
	* load and merge relevant data
	cd "${input}/Data/Stata"
	* weight data
	use "weight_2019", clear
	* roster data
	merge 1:m psu using "LKA_2019_HIES_v01_M", nogen assert(match)
	save `individual_level_data'
	* Section 5.1 - Income from paid employments during last 4 weeks / last calendar month
	use "SEC_5_1_EMP_INCOME", clear
		* reshape to wide format: 1 observation per person
		reshape wide wages_salaries allowences bonus, i(hhid pid) j(pri_sec)
		* identify observations in this section
		g section5_1 = 1
	merge 1:1 hhid pid using `individual_level_data', nogen assert(using match)
	save `individual_level_data', replace
	* Section 5.2 - Income from agricultural activities - (Paddy, Other seasonal crops)
	use "SEC_5_2_AGRI_INCOME", clear
		* rename variables to easily identify them later
		rename s52_col_* s52_col_*_
		* reshape to wide format: 1 observation per person
		reshape wide s52_col_5_-s52_col_13_, i(hhid pid) j(s52_col_4)
		* identify observations in this section
		g section5_2 = 1
	merge 1:1 hhid pid using `individual_level_data', nogen assert(using match)
	save `individual_level_data', replace
	* Section 5.3 - Income from other agricultural activities (Non seasonal crops/ Livestock)
	use "SEC_5_3_OTHER_AGRI_INCOME", clear
	* rename variables to easily identify them later
		rename *_5_3 *_5_3_
		rename fertilizes fertilizes_
		* reshape to wide format: 1 observation per person
		reshape wide acres_5_3_-fertilizes_, i(hhid pid) j(seasonal_crop)
		* identify observations in this section
		g section5_3 = 1
	merge 1:1 hhid pid using `individual_level_data', nogen assert(using match)
	save `individual_level_data', replace
	* Section 5.4 - Income Form Non - Agricultural activities (Income from industry, construction, trade and services)
	use "SEC_5_4_NON_AGRI_INCOME", clear
	* rename variables to easily identify them later
		rename *_5_4 *_5_4_
		rename subsidies subsidies_
		* reshape to wide format: 1 observation per person
		reshape wide output_5_4-subsidies_, i(hhid pid) j(non_agri)
		* identify observations in this section
		g section5_4 = 1
	merge 1:1 hhid pid using `individual_level_data', nogen assert(using match)
}
* global paths on WB computer
else {
	*<_Folder creation_>
	cap mkdir "${rootdatalib}"
	cap mkdir "${rootdatalib}\\`code'"
	cap mkdir "${rootdatalib}\\`code'\\`yearfolder'"
	cap mkdir "${rootdatalib}\\`code'\\`yearfolder'\\`gmdfolder'"
	cap mkdir "${rootdatalib}\\`code'\\`yearfolder'\\`gmdfolder'\Data"
	cap mkdir "${rootdatalib}\\`code'\\`yearfolder'\\`gmdfolder'\Data\Harmonized"
	*</_Folder creation_>
	
	*<_Datalibweb request_>
	* load and merge relevant data
	* weight data
	datalibweb, country(`code') year(`year') type(SARRAW) filename(weight_2019.dta)
	save `individual_level_data'
	* durable goods data
	datalibweb, country(`code') year(`year') type(SARRAW) filename(LKA_2019_HIES_v01_M.dta)
	merge m:1 psu using `individual_level_data', nogen assert(match)
	save `individual_level_data', replace
	* Section 5.1 - Income from paid employments during last 4 weeks / last calendar month
	datalibweb, country(`code') year(`year') type(SARRAW) filename(SEC_5_1_EMP_INCOME.dta)
		* reshape to wide format: 1 observation per person
		reshape wide wages_salaries allowences bonus, i(hhid pid) j(pri_sec)
		* identify observations in this section
		g section5_1 = 1
	merge 1:1 hhid pid using `individual_level_data', nogen assert(using match)
	save `individual_level_data', replace
	* Section 5.2 - Income from agricultural activities - (Paddy, Other seasonal crops)
	datalibweb, country(`code') year(`year') type(SARRAW) filename(SEC_5_2_AGRI_INCOME.dta)
		* rename variables to easily identify them later
		rename s52_col_* s52_col_*_
		* reshape to wide format: 1 observation per person
		reshape wide s52_col_5_-s52_col_13_, i(hhid pid) j(s52_col_4)
		* identify observations in this section
		g section5_2 = 1
	merge 1:1 hhid pid using `individual_level_data', nogen assert(using match)
	save `individual_level_data', replace
	* Section 5.3 - Income from other agricultural activities (Non seasonal crops/ Livestock)
	datalibweb, country(`code') year(`year') type(SARRAW) filename(SEC_5_3_OTHER_AGRI_INCOME.dta)
	* rename variables to easily identify them later
		rename *_5_3 *_5_3_
		rename fertilizes fertilizes_
		* reshape to wide format: 1 observation per person
		reshape wide acres_5_3_-fertilizes_, i(hhid pid) j(seasonal_crop)
		* identify observations in this section
		g section5_3 = 1
	merge 1:1 hhid pid using `individual_level_data', nogen assert(using match)
	save `individual_level_data', replace
	* Section 5.4 - Income Form Non - Agricultural activities (Income from industry, construction, trade and services)
	datalibweb, country(`code') year(`year') type(SARRAW) filename(SEC_5_4_NON_AGRI_INCOME.dta)
	* rename variables to easily identify them later
		rename *_5_4 *_5_4_
		rename subsidies subsidies_
		* reshape to wide format: 1 observation per person
		reshape wide output_5_4-subsidies_, i(hhid pid) j(non_agri)
		* identify observations in this section
		g section5_4 = 1
	merge 1:1 hhid pid using `individual_level_data', nogen assert(using match)
	*</_Datalibweb request_>
}

*<_countrycode_>
*<_countrycode_note_> country code *</_countrycode_note_>
*<_countrycode_note_> countrycode brought in from rawdata *</_countrycode_note_>
gen countrycode=code
*</_countrycode_>

*<_year_>
*<_year_note_> Year *</_year_note_>
*<_year_note_> year brought in from rawdata *</_year_note_>
* NOTE: this variable already exists in harmonized form.
*</_year_>

*<_hhid_>
*<_hhid_note_> Household identifier  *</_hhid_note_>
*<_hhid_note_> hhid brought in from rawdata *</_hhid_note_>
* NOTE: this variable already exists in harmonized form.
*</_hhid_>

*<_pid_>
*<_pid_note_> Personal identifier  *</_pid_note_>
*<_pid_note_> pid brought in from rawdata *</_pid_note_>
* NOTE: this variable already exists in harmonized form.
*</_pid_>

*<_weight_>
*<_weight_note_> Household weight *</_weight_note_>
*<_weight_note_> weight brought in from rawdata *</_weight_note_>
clonevar weight = finalweight
*</_weight_>

*<_weighttype_>
*<_weighttype_note_> Weight type (frequency, probability, analytical, importance) *</_weighttype_note_>
*<_weighttype_note_> weighttype brought in from rawdata *</_weighttype_note_>
g weighttype = "PW"
*</_weighttype_>

*<_age_>
*<_age_note_> Age of individual (continuous) *</_age_note_>
*<_age_note_> age brought in from rawdata *</_age_note_>
* NOTE: this variable already exists in harmonized form.
*</_age_>

*<_minlaborage_>
*<_minlaborage_note_> Labor module application age *</_minlaborage_note_>
*<_minlaborage_note_> minlaborage brought in from rawdata *</_minlaborage_note_>
g minlaborage = 15
*</_minlaborage_>

*<_lstatus_>
*<_lstatus_note_> Labor status *</_lstatus_note_>
*<_lstatus_note_> lstatus brought in from rawdata *</_lstatus_note_>
g		lstatus = 1 if inlist(main_activity,1,2)
recode	lstatus (.=2) if main_activity==3
recode	lstatus (.=3) if inrange(main_activity,4,99)
replace lstatus = . if age<15
*</_lstatus_>

*<_nlfreason_>
*<_nlfreason_note_> Reason not in the labor force *</_nlfreason_note_>
*<_nlfreason_note_> nlfreason brought in from rawdata *</_nlfreason_note_>
recode main_activity (4/6=3) (7=2) (8=1) (9=4) (99=5) (*=.) if lstatus==3, g(nlfreason)
*</_nlfreason_>

*<_unempldur_l_>
*<_unempldur_l_note_> Unemployment duration (months) lower bracket *</_unempldur_l_note_>
*<_unempldur_l_note_> unempldur_l brought in from rawdata *</_unempldur_l_note_>
gen unempldur_l=.
*</_unempldur_l_>

*<_unempldur_u_>
*<_unempldur_u_note_> Unemployment duration (months) upper bracket *</_unempldur_u_note_>
*<_unempldur_u_note_> unempldur_u brought in from rawdata *</_unempldur_u_note_>
gen unempldur_u=.
*</_unempldur_u_>

*<_empstat_>
*<_empstat_note_> Employment status *</_empstat_note_>
*<_empstat_note_> empstat brought in from rawdata *</_empstat_note_>
recode employment_status (1/3=1) (4=3) (5=4) (6=5) (*=.) if lstatus==1, g(empstat)
*</_empstat_>

*<_ocusec_>
*<_ocusec_note_> Sector of activity *</_ocusec_note_>
*<_ocusec_note_> ocusec brought in from rawdata *</_ocusec_note_>
recode employment_status (1=1) (2=3) (3/6=2) (*=.) if lstatus==1, g(ocusec)
*</_ocusec_>

*<_industry_orig_>
*<_industry_orig_note_> original industry codes *</_industry_orig_note_>
*<_industry_orig_note_> industry_orig brought in from rawdata *</_industry_orig_note_>
g industry_orig = industry if lstatus==1
*</_industry_orig_>

*<_industrycat10_>
*<_industrycat10_note_> 1 digit industry classification *</_industrycat10_note_>
*<_industrycat10_note_> industrycat10 brought in from rawdata *</_industrycat10_note_>
/*
tostring industry, g(industry_str)
replace industry_str = "0" + industry_str if length(industry_str)==4
gen industrycat10 = substr(industry_str,1,1)
destring industrycat10, replace
replace industrycat10 = . if lstatus~=1
*/
gen ind=int(industry/1000)
drop industry
recode ind (1/3 = 1) (5/9 = 2) (10/33 = 3) (35/39 = 4) (41/43 = 5) ///
(45/47 = 6) (49/63 = 7) (64/82 = 8) (84 = 9) (85/99 = 10), gen(industry)
gen industrycat10= industry
replace industrycat10 = . if lstatus~=1
*</_industrycat10_>

*<_industrycat4_>
*<_industrycat4_note_> 1 digit industry classification (Broad Economic Activities) *</_industrycat4_note_>
*<_industrycat4_note_> industrycat4 brought in from rawdata *</_industrycat4_note_>
recode industrycat10 (1=1) (2/5=2) (6/9=3) (10=4), g(industrycat4)
*</_industrycat4_>

*<_occup_orig_>
*<_occup_orig_note_> original occupation code *</_occup_orig_note_>
*<_occup_orig_note_> occup_orig brought in from rawdata *</_occup_orig_note_>
g occup_orig = main_occupation
*</_occup_orig_>

*<_occup_>
*<_occup_note_> 1 digit occupational classification *</_occup_note_>
*<_occup_note_> occup brought in from rawdata *</_occup_note_>
tostring main_occupation, g(main_occupation_str)
replace main_occupation_str = "0" + main_occupation_str if length(main_occupation_str)==3
g occup = substr(main_occupation_str,1,1) if lstatus==1
destring occup, replace
*</_occup_>

*<_wage_nc_>
*<_wage_nc_note_> Last wage payment *</_wage_nc_note_>
*<_wage_nc_note_> wage_nc brought in from rawdata *</_wage_nc_note_>
gen wage_nc = .
*</_wage_nc_>

*<_unitwage_>
*<_unitwage_note_> Last wages time unit *</_unitwage_note_>
*<_unitwage_note_> unitwage brought in from rawdata *</_unitwage_note_>
gen unitwage=.
*</_unitwage_>

*<_whours_>
*<_whours_note_> Hours of work in last week *</_whours_note_>
*<_whours_note_> whours brought in from rawdata *</_whours_note_>
gen whours=.
*</_whours_>

*<_wmonths_>
*<_wmonths_note_> Months worked in the last 12 months *</_wmonths_note_>
*<_wmonths_note_> wmonths brought in from rawdata *</_wmonths_note_>
gen wmonths=.
*</_wmonths_>

*<_wage_total_>
*<_wage_total_note_> Primary job total wage  *</_wage_total_note_>
*<_wage_total_note_> wage_total brought in from rawdata *</_wage_total_note_>
gen wage_total=.
*</_wage_total_>

*<_contract_>
*<_contract_note_> Contract *</_contract_note_>
*<_contract_note_> contract brought in from rawdata *</_contract_note_>
gen contract=.
*</_contract_>

*<_healthins_>
*<_healthins_note_> Health insurance *</_healthins_note_>
*<_healthins_note_> healthins brought in from rawdata *</_healthins_note_>
gen healthins=.
*</_healthins_>

*<_socialsec_>
*<_socialsec_note_> Social security *</_socialsec_note_>
*<_socialsec_note_> socialsec brought in from rawdata *</_socialsec_note_>
gen socialsec=.
*</_socialsec_>

*<_union_>
*<_union_note_> Union membership *</_union_note_>
*<_union_note_> union brought in from rawdata *</_union_note_>
gen union=.
*</_union_>

*<_firmsize_l_>
*<_firmsize_l_note_> Firm size (lower bracket) *</_firmsize_l_note_>
*<_firmsize_l_note_> firmsize_l brought in from rawdata *</_firmsize_l_note_>
gen firmsize_l=.
*</_firmsize_l_>

*<_firmsize_u_>
*<_firmsize_u_note_> Firm size (upper bracket) *</_firmsize_u_note_>
*<_firmsize_u_note_> firmsize_u brought in from rawdata *</_firmsize_u_note_>
gen firmsize_u=.
*</_firmsize_u_>

*<_empstat_2_>
*<_empstat_2_note_> Employment status - second job *</_empstat_2_note_>
*<_empstat_2_note_> empstat_2 brought in from rawdata *</_empstat_2_note_>
gen empstat_2=.
*</_empstat_2_>

*<_ocusec_2_>
*<_ocusec_2_note_> Sector of activity for second job *</_ocusec_2_note_>
*<_ocusec_2_note_> ocusec_2 brought in from rawdata *</_ocusec_2_note_>
gen ocusec_2=.
*</_ocusec_2_>

*<_industry_orig_2_>
*<_industry_orig_2_note_> original industry codes for second job *</_industry_orig_2_note_>
*<_industry_orig_2_note_> industry_orig_2 brought in from rawdata *</_industry_orig_2_note_>
gen industry_orig_2=.
*</_industry_orig_2_>

*<_industrycat10_2_>
*<_industrycat10_2_note_> 1 digit industry classification for second job *</_industrycat10_2_note_>
*<_industrycat10_2_note_> industrycat10_2 brought in from rawdata *</_industrycat10_2_note_>
gen industrycat10_2=.
*</_industrycat10_2_>

*<_industrycat4_2_>
*<_industrycat4_2_note_> 1 digit industry classification (Broad Economic Activities) for second job *</_industrycat4_2_note_>
*<_industrycat4_2_note_> industrycat4_2 brought in from rawdata *</_industrycat4_2_note_>
gen industrycat4_2=.
*</_industrycat4_2_>

*<_occup_orig_2_>
*<_occup_orig_2_note_> original occupation code for second job *</_occup_orig_2_note_>
*<_occup_orig_2_note_> occup_orig_2 brought in from rawdata *</_occup_orig_2_note_>
gen occup_orig_2=.
*</_occup_orig_2_>

*<_occup_2_>
*<_occup_2_note_> 1 digit occupational classification for second job *</_occup_2_note_>
*<_occup_2_note_> occup_2 brought in from rawdata *</_occup_2_note_>
gen occup_2=.
*</_occup_2_>

*<_wage_nc_2_>
*<_wage_nc_2_note_> Last wage payment second job *</_wage_nc_2_note_>
*<_wage_nc_2_note_> wage_nc_2 brought in from rawdata *</_wage_nc_2_note_>
gen wage_nc_2=.
*</_wage_nc_2_>

*<_unitwage_2_>
*<_unitwage_2_note_> Last wages time unit second job *</_unitwage_2_note_>
*<_unitwage_2_note_> unitwage_2 brought in from rawdata *</_unitwage_2_note_>
gen unitwage_2=.
*</_unitwage_2_>

*<_whours_2_>
*<_whours_2_note_> Hours of work in last week for the secondary job *</_whours_2_note_>
*<_whours_2_note_> whours_2 brought in from rawdata *</_whours_2_note_>
gen whours_2=.
*</_whours_2_>

*<_wmonths_2_>
*<_wmonths_2_note_> Months worked in the last 12 months for the secondary job *</_wmonths_2_note_>
*<_wmonths_2_note_> wmonths_2 brought in from rawdata *</_wmonths_2_note_>
gen wmonths_2=.
*</_wmonths_2_>

*<_wage_total_2_>
*<_wage_total_2_note_> Secondary job total wage  *</_wage_total_2_note_>
*<_wage_total_2_note_> wage_total_2 brought in from rawdata *</_wage_total_2_note_>
gen wage_total_2=.
*</_wage_total_2_>

*<_firmsize_l_2_>
*<_firmsize_l_2_note_> Firm size (lower bracket) for the secondary job *</_firmsize_l_2_note_>
*<_firmsize_l_2_note_> firmsize_l_2 brought in from rawdata *</_firmsize_l_2_note_>
gen firmsize_l_2=.
*</_firmsize_l_2_>

*<_firmsize_u_2_>
*<_firmsize_u_2_note_> Firm size (upper bracket) for the secondary job *</_firmsize_u_2_note_>
*<_firmsize_u_2_note_> firmsize_u_2 brought in from rawdata *</_firmsize_u_2_note_>
gen firmsize_u_2=.
*</_firmsize_u_2_>

*<_t_hours_others_>
*<_t_hours_others_note_> Total hours of work in the last 12 months in other jobs excluding the primary and secondary ones *</_t_hours_others_note_>
*<_t_hours_others_note_> t_hours_others brought in from rawdata *</_t_hours_others_note_>
gen t_hours_others=.
*</_t_hours_others_>

*<_t_wage_nc_others_>
*<_t_wage_nc_others_note_> Annualized wage in all jobs excluding the primary and secondary ones (excluding tips, bonuses, etc.). *</_t_wage_nc_others_note_>
*<_t_wage_nc_others_note_> t_wage_nc_others brought in from rawdata *</_t_wage_nc_others_note_>
gen t_wage_nc_others=.
*</_t_wage_nc_others_>

*<_t_wage_others_>
*<_t_wage_others_note_> Annualized wage (including tips, bonuses, etc.) in all other jobs excluding the primary and secondary ones. *</_t_wage_others_note_>
*<_t_wage_others_note_> t_wage_others brought in from rawdata *</_t_wage_others_note_>
gen t_wage_others=.
*</_t_wage_others_>

*<_t_hours_total_>
*<_t_hours_total_note_> Annualized hours worked in all jobs (7-day ref period) *</_t_hours_total_note_>
*<_t_hours_total_note_> t_hours_total brought in from rawdata *</_t_hours_total_note_>
gen t_hours_total=.
*</_t_hours_total_>

*<_t_wage_nc_total_>
*<_t_wage_nc_total_note_> Annualized wage in all jobs excl. bonuses, etc. (7-day ref period) *</_t_wage_nc_total_note_>
*<_t_wage_nc_total_note_> t_wage_nc_total brought in from rawdata *</_t_wage_nc_total_note_>
* annualize 5.1 income
g s51q4j1_year = wages_salaries1 * 52.17857/4
g s51q4j2_year = wages_salaries2 * 52.17857/4
* Note: 5.2 income is already annualized
* annualize 5.3 income
forval activity = 1/16 {
	g s53q8a`activity'_year = output_5_3_`activity' * 12
}
g s53q8a99 = output_5_3_99 * 12
* annualize 5.4 income
foreach activity in 1 2 3 4 5 6 9 {
	g s54q5a`activity'_year = output_5_4_`activity' * 12
}
egen t_wage_nc_total = rowtotal(s51q4j?_year s52_col_81_? s53q8a*_year s54q5a?_year), missing
note t_wage_nc_total: LKA_2019_HIES uses multiple reference periods to create this indicator.
*</_t_wage_nc_total_>

*<_t_wage_total_>
*<_t_wage_total_note_> Annualized total wage for all jobs (7-day ref period) *</_t_wage_total_note_>
*<_t_wage_total_note_> t_wage_total brought in from rawdata *</_t_wage_total_note_>
* annualize 5.1 Tips, Commissions, Overtime pay etc.
g s51q5j1_year = allowences1 * 52.17857/4
g s51q5j2_year = allowences2 * 52.17857/4
egen t_wage_total = rowtotal(s51q4j?_year s51q5j?_year bonus? s52_col_81_? s53q8a*_year s54q5a?_year), missing
note t_wage_total: LKA_2019_HIES uses multiple reference periods to create this indicator.
*</_t_wage_total_>

*<_minlaborage_year_>
*<_minlaborage_year_note_> Labor module application age (12-mon ref period) *</_minlaborage_year_note_>
*<_minlaborage_year_note_> minlaborage_year brought in from rawdata *</_minlaborage_year_note_>
g minlaborage_year = 15
*</_minlaborage_year_>

*<_lstatus_year_>
*<_lstatus_year_note_> Labor status (12-mon ref period) *</_lstatus_year_note_>
*<_lstatus_year_note_> lstatus_year brought in from rawdata *</_lstatus_year_note_>
gen lstatus_year=.
*</_lstatus_year_>

*<_nlfreason_year_>
*<_nlfreason_year_note_> Reason not in the labor force (12-mon ref period) *</_nlfreason_year_note_>
*<_nlfreason_year_note_> nlfreason_year brought in from rawdata *</_nlfreason_year_note_>
gen nlfreason_year=.
*</_nlfreason_year_>

*<_unempldur_l_year_>
*<_unempldur_l_year_note_> Unemployment duration (months) lower bracket (12-mon ref period) *</_unempldur_l_year_note_>
*<_unempldur_l_year_note_> unempldur_l_year brought in from rawdata *</_unempldur_l_year_note_>
gen unempldur_l_year=.
*</_unempldur_l_year_>

*<_unempldur_u_year_>
*<_unempldur_u_year_note_> Unemployment duration (months) upper bracket (12-mon ref period) *</_unempldur_u_year_note_>
*<_unempldur_u_year_note_> unempldur_u_year brought in from rawdata *</_unempldur_u_year_note_>
gen unempldur_u_year=.
*</_unempldur_u_year_>

*<_empstat_year_>
*<_empstat_year_note_> Employment status, primary job (12-mon ref period) *</_empstat_year_note_>
*<_empstat_year_note_> empstat_year brought in from rawdata *</_empstat_year_note_>
gen empstat_year=.
*</_empstat_year_>

*<_ocusec_year_>
*<_ocusec_year_note_> Sector of activity, primary job (12-mon ref period) *</_ocusec_year_note_>
*<_ocusec_year_note_> ocusec_year brought in from rawdata *</_ocusec_year_note_>
gen ocusec_year=.
*</_ocusec_year_>

*<_industry_orig_year_>
*<_industry_orig_year_note_> Original industry code, primary job (12-mon ref period) *</_industry_orig_year_note_>
*<_industry_orig_year_note_> industry_orig_year brought in from rawdata *</_industry_orig_year_note_>
gen industry_orig_year=.
*</_industry_orig_year_>

*<_industrycat10_year_>
*<_industrycat10_year_note_> 1 digit industry classification, primary job (12-mon ref period) *</_industrycat10_year_note_>
*<_industrycat10_year_note_> industrycat10_year brought in from rawdata *</_industrycat10_year_note_>
gen industrycat10_year=.
*</_industrycat10_year_>

*<_industrycat4_year_>
*<_industrycat4_year_note_> 4-category industry classification primary job (12-mon ref period) *</_industrycat4_year_note_>
*<_industrycat4_year_note_> industrycat4_year brought in from rawdata *</_industrycat4_year_note_>
gen industrycat4_year=.
*</_industrycat4_year_>

*<_occup_orig_year_>
*<_occup_orig_year_note_> Original occupational classification, primary job (12-mon ref period) *</_occup_orig_year_note_>
*<_occup_orig_year_note_> occup_orig_year brought in from rawdata *</_occup_orig_year_note_>
gen occup_orig_year=.
*</_occup_orig_year_>

*<_occup_year_>
*<_occup_year_note_> 1 digit occupational classification, primary job (12-mon ref period) *</_occup_year_note_>
*<_occup_year_note_> occup_year brought in from rawdata *</_occup_year_note_>
gen occup_year=.
*</_occup_year_>

*<_wage_nc_year_>
*<_wage_nc_year_note_> Last wage payment, primary job, excl. bonuses, etc. (12-mon ref period) *</_wage_nc_year_note_>
*<_wage_nc_year_note_> wage_nc_year brought in from rawdata *</_wage_nc_year_note_>
gen wage_nc_year=.
*</_wage_nc_year_>

*<_unitwage_year_>
*<_unitwage_year_note_> Time unit of last wages payment, primary job (12-mon ref period) *</_unitwage_year_note_>
*<_unitwage_year_note_> unitwage_year brought in from rawdata *</_unitwage_year_note_>
gen unitwage_year=.
*</_unitwage_year_>

*<_whours_year_>
*<_whours_year_note_> Hours of work in last week, primary job (12-mon ref period) *</_whours_year_note_>
*<_whours_year_note_> whours_year brought in from rawdata *</_whours_year_note_>
gen whours_year=.
*</_whours_year_>

*<_wmonths_year_>
*<_wmonths_year_note_> Months worked in the last 12 months, primary job (12-mon ref period) *</_wmonths_year_note_>
*<_wmonths_year_note_> wmonths_year brought in from rawdata *</_wmonths_year_note_>
gen wmonths_year=.
*</_wmonths_year_>

*<_wage_total_year_>
*<_wage_total_year_note_> Annualized total wage, primary job (12-mon ref period) *</_wage_total_year_note_>
*<_wage_total_year_note_> wage_total_year brought in from rawdata *</_wage_total_year_note_>
gen wage_total_year=.
*</_wage_total_year_>

*<_contract_year_>
*<_contract_year_note_> Contract (12-mon ref period) *</_contract_year_note_>
*<_contract_year_note_> contract_year brought in from rawdata *</_contract_year_note_>
gen contract_year=.
*</_contract_year_>

*<_healthins_year_>
*<_healthins_year_note_> Health insurance (12-mon ref period) *</_healthins_year_note_>
*<_healthins_year_note_> healthins_year brought in from rawdata *</_healthins_year_note_>
gen healthins_year=.
*</_healthins_year_>

*<_socialsec_year_>
*<_socialsec_year_note_> Social security (12-mon ref period) *</_socialsec_year_note_>
*<_socialsec_year_note_> socialsec_year brought in from rawdata *</_socialsec_year_note_>
gen socialsec_year=.
*</_socialsec_year_>

*<_union_year_>
*<_union_year_note_> Union membership (12-mon ref period) *</_union_year_note_>
*<_union_year_note_> union_year brought in from rawdata *</_union_year_note_>
gen union_year=.
*</_union_year_>

*<_firmsize_l_year_>
*<_firmsize_l_year_note_> Firm size (lower bracket) (12-mon ref period) *</_firmsize_l_year_note_>
*<_firmsize_l_year_note_> firmsize_l_year brought in from rawdata *</_firmsize_l_year_note_>
gen firmsize_l_year=.
*</_firmsize_l_year_>

*<_firmsize_u_year_>
*<_firmsize_u_year_note_> Firm size (upper bracket) (12-mon ref period) *</_firmsize_u_year_note_>
*<_firmsize_u_year_note_> firmsize_u_year brought in from rawdata *</_firmsize_u_year_note_>
gen firmsize_u_year=.
*</_firmsize_u_year_>

*<_empstat_2_year_>
*<_empstat_2_year_note_> Employment status - second job (12-mon ref period) *</_empstat_2_year_note_>
*<_empstat_2_year_note_> empstat_2_year brought in from rawdata *</_empstat_2_year_note_>
gen empstat_2_year=.
*</_empstat_2_year_>

*<_ocusec_2_year_>
*<_ocusec_2_year_note_> Sector of activity for second job (12-mon ref period) *</_ocusec_2_year_note_>
*<_ocusec_2_year_note_> ocusec_2_year brought in from rawdata *</_ocusec_2_year_note_>
gen ocusec_2_year=.
*</_ocusec_2_year_>

*<_industry_orig_2_year_>
*<_industry_orig_2_year_note_> original industry codes for second job (12-mon ref period) *</_industry_orig_2_year_note_>
*<_industry_orig_2_year_note_> industry_orig_2_year brought in from rawdata *</_industry_orig_2_year_note_>
gen industry_orig_2_year=.
*</_industry_orig_2_year_>

*<_industrycat10_2_year_>
*<_industrycat10_2_year_note_> 1 digit industry classification for second job (12-mon ref period) *</_industrycat10_2_year_note_>
*<_industrycat10_2_year_note_> industrycat10_2_year brought in from rawdata *</_industrycat10_2_year_note_>
gen industrycat10_2_year=.
*</_industrycat10_2_year_>

*<_industrycat4_2_year_>
*<_industrycat4_2_year_note_> 4-category industry classification, secondary job (12-mon ref period) *</_industrycat4_2_year_note_>
*<_industrycat4_2_year_note_> industrycat4_2_year brought in from rawdata *</_industrycat4_2_year_note_>
gen industrycat4_2_year=.
*</_industrycat4_2_year_>

*<_occup_orig_2_year_>
*<_occup_orig_2_year_note_> Original occupational classification, secondary job (12-mon ref period) *</_occup_orig_2_year_note_>
*<_occup_orig_2_year_note_> occup_orig_2_year brought in from rawdata *</_occup_orig_2_year_note_>
gen occup_orig_2_year=.
*</_occup_orig_2_year_>

*<_occup_2_year_>
*<_occup_2_year_note_> 1 digit occupational classification, secondary job (12-mon ref period) *</_occup_2_year_note_>
*<_occup_2_year_note_> occup_2_year brought in from rawdata *</_occup_2_year_note_>
gen occup_2_year=.
*</_occup_2_year_>

*<_wage_nc_2_year_>
*<_wage_nc_2_year_note_> last wage payment, secondary job, excl. bonuses, etc. (12-mon ref period) *</_wage_nc_2_year_note_>
*<_wage_nc_2_year_note_> wage_nc_2_year brought in from rawdata *</_wage_nc_2_year_note_>
gen wage_nc_2_year=.
*</_wage_nc_2_year_>

*<_unitwage_2_year_>
*<_unitwage_2_year_note_> Time unit of last wages payment, secondary job (12-mon ref period) *</_unitwage_2_year_note_>
*<_unitwage_2_year_note_> unitwage_2_year brought in from rawdata *</_unitwage_2_year_note_>
gen unitwage_2_year=.
*</_unitwage_2_year_>

*<_whours_2_year_>
*<_whours_2_year_note_> Hours of work in last week, secondary job (12-mon ref period) *</_whours_2_year_note_>
*<_whours_2_year_note_> whours_2_year brought in from rawdata *</_whours_2_year_note_>
gen whours_2_year=.
*</_whours_2_year_>

*<_wmonths_2_year_>
*<_wmonths_2_year_note_> Months worked in the last 12 months, secondary job (12-mon ref period) *</_wmonths_2_year_note_>
*<_wmonths_2_year_note_> wmonths_2_year brought in from rawdata *</_wmonths_2_year_note_>
gen wmonths_2_year=.
*</_wmonths_2_year_>

*<_wage_total_2_year_>
*<_wage_total_2_year_note_> Annualized total wage, secondary job (12-mon ref period) *</_wage_total_2_year_note_>
*<_wage_total_2_year_note_> wage_total_2_year brought in from rawdata *</_wage_total_2_year_note_>
gen wage_total_2_year=.
*</_wage_total_2_year_>

*<_firmsize_l_2_year_>
*<_firmsize_l_2_year_note_> Firm size (lower bracket), secondary job (12-mon ref period) *</_firmsize_l_2_year_note_>
*<_firmsize_l_2_year_note_> firmsize_l_2_year brought in from rawdata *</_firmsize_l_2_year_note_>
gen firmsize_l_2_year=.
*</_firmsize_l_2_year_>

*<_firmsize_u_2_year_>
*<_firmsize_u_2_year_note_> Firm size (lower bracket), secondary job (12-mon ref period) *</_firmsize_u_2_year_note_>
*<_firmsize_u_2_year_note_> firmsize_u_2_year brought in from rawdata *</_firmsize_u_2_year_note_>
gen firmsize_u_2_year=.
*</_firmsize_u_2_year_>

*<_t_hours_others_year_>
*<_t_hours_others_year_note_> Annualized hours worked in all but primary and secondary jobs (12-mon ref period) *</_t_hours_others_year_note_>
*<_t_hours_others_year_note_> t_hours_others_year brought in from rawdata *</_t_hours_others_year_note_>
gen t_hours_others_year=.
*</_t_hours_others_year_>

*<_t_wage_nc_others_year_>
*<_t_wage_nc_others_year_note_> Annualized wage in all but primary & secondary jobs excl. bonuses, etc. (12-mon ref period) *</_t_wage_nc_others_year_note_>
*<_t_wage_nc_others_year_note_> t_wage_nc_others_year brought in from rawdata *</_t_wage_nc_others_year_note_>
gen t_wage_nc_others_year=.
*</_t_wage_nc_others_year_>

*<_t_wage_others_year_>
*<_t_wage_others_year_note_> Annualized wage in all but primary and secondary jobs (12-mon ref period) *</_t_wage_others_year_note_>
*<_t_wage_others_year_note_> t_wage_others_year brought in from rawdata *</_t_wage_others_year_note_>
gen t_wage_others_year=.
*</_t_wage_others_year_>

*<_t_hours_total_year_>
*<_t_hours_total_year_note_> Annualized hours worked in all jobs (12-mon ref period) *</_t_hours_total_year_note_>
*<_t_hours_total_year_note_> t_hours_total_year brought in from rawdata *</_t_hours_total_year_note_>
gen t_hours_total_year=.
*</_t_hours_total_year_>

*<_t_wage_nc_total_year_>
*<_t_wage_nc_total_year_note_> Annualized wage in all jobs excl. bonuses, etc. (12-mon ref period) *</_t_wage_nc_total_year_note_>
*<_t_wage_nc_total_year_note_> t_wage_nc_total_year brought in from rawdata *</_t_wage_nc_total_year_note_>
gen t_wage_nc_total_year=.
*</_t_wage_nc_total_year_>

*<_t_wage_total_year_>
*<_t_wage_total_year_note_> Annualized total wage for all jobs (12-mon ref period) *</_t_wage_total_year_note_>
*<_t_wage_total_year_note_> t_wage_total_year brought in from rawdata *</_t_wage_total_year_note_>
gen t_wage_total_year=.
*</_t_wage_total_year_>

*<_njobs_>
*<_njobs_note_> Total number of jobs *</_njobs_note_>
*<_njobs_note_> njobs brought in from rawdata *</_njobs_note_>
gen njobs=.
*</_njobs_>

*<_t_hours_annual_>
*<_t_hours_annual_note_> Total hours worked in all jobs in the previous 12 months *</_t_hours_annual_note_>
*<_t_hours_annual_note_> t_hours_annual brought in from rawdata *</_t_hours_annual_note_>
gen t_hours_annual=.
*</_t_hours_annual_>

*<_linc_nc_>
*<_linc_nc_note_> Total annual wage income in all jobs, excl. bonuses, etc. *</_linc_nc_note_>
*<_linc_nc_note_> linc_nc brought in from rawdata *</_linc_nc_note_>
egen linc_nc = rowtotal(s51q4j?_year s52_col_81_? s53q8a*_year s54q5a?_year), missing
note linc_nc: LKA_2019_HIES uses multiple reference periods to create this indicator.
*</_linc_nc_>

*<_laborincome_>
*<_laborincome_note_> Total annual individual labor income in all jobs, incl. bonuses, etc. *</_laborincome_note_>
*<_laborincome_note_> laborincome brought in from rawdata *</_laborincome_note_>
egen laborincome = rowtotal(s51q4j?_year s51q5j?_year bonus? s52_col_81_? s53q8a*_year s54q5a?_year), missing
note laborincome: LKA_2019_HIES uses multiple reference periods to create this indicator.
*</_laborincome_>

*<_Keep variables_>
*keep countrycode year hhid pid weight weighttype age minlaborage lstatus nlfreason unempldur_l unempldur_u empstat ocusec industry_orig industrycat10 industrycat4 occup_orig occup wage_nc unitwage whours wmonths wage_total contract healthins socialsec union firmsize_l firmsize_u empstat_2 ocusec_2 industry_orig_2 industrycat10_2 industrycat4_2 occup_orig_2 occup_2 wage_nc_2 unitwage_2 whours_2 wmonths_2 wage_total_2 firmsize_l_2 firmsize_u_2 t_hours_others t_wage_nc_others t_wage_others t_hours_total t_wage_nc_total t_wage_total minlaborage_year lstatus_year nlfreason_year unempldur_l_year unempldur_u_year empstat_year ocusec_year industry_orig_year industrycat10_year industrycat4_year occup_orig_year occup_year wage_nc_year unitwage_year whours_year wmonths_year wage_total_year contract_year healthins_year socialsec_year union_year firmsize_l_year firmsize_u_year empstat_2_year ocusec_2_year industry_orig_2_year industrycat10_2_year industrycat4_2_year occup_orig_2_year occup_2_year wage_nc_2_year unitwage_2_year whours_2_year wmonths_2_year wage_total_2_year firmsize_l_2_year firmsize_u_2_year t_hours_others_year t_wage_nc_others_year t_wage_others_year t_hours_total_year t_wage_nc_total_year t_wage_total_year njobs t_hours_annual linc_nc laborincome
order countrycode year hhid pid weight weighttype
sort hhid pid 
*</_Keep variables_>

*<_Save data file_>
do "${rootdatalib}/`code'/`yearfolder'/`yearfolder'_v`vm'_M_v`va'_A_SARMD/Programs/Labels_GMD2.0.do"
compress
if ("`c(username)'"=="sunquat") save "${output}/`filename'", replace
else save "$rootdatalib\\`code'\\`yearfolder'\\`gmdfolder'\Data\Harmonized\\`filename'.dta" , replace
*</_Save data file_>
