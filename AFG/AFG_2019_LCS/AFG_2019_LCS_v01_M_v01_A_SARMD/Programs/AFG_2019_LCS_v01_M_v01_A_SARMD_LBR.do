/*------------------------------------------------------------------------------
					GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   AFG_2019_LCS_v01_M_v01_A_GMD_LBR.do	</_Program name_>
<_Application_>    STATA 16.0	<_Application_>
<_Author(s)_>      jogreen@worldbank.org	</_Author(s)_>
<_Date created_>   05-25-2020	</_Date created_>
<_Date modified>   08-08-2021	</_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        AFG	</_Country_>
<_Survey Title_>   LCS	</_Survey Title_>
<_Survey Year_>    2019	</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:	08-08-2021
File:	AFG_2019_LCS_v01_M_v01_A_GMD_LBR.do
- First version
</_Version Control_>
------------------------------------------------------------------------------*/

*<_Program setup_>
clear all
set more off

local code         "AFG"
local year         "2019"
local survey       "LCS"
local vm           "01"
local va           "01"
local type         "SARMD"
local yearfolder   "`code'_`year'_`survey'"
local harmfolder    "`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'"
local filename      "`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'_LBR"
*</_Program setup_>

* global path on Joe's computer
if ("`c(username)'"=="dekopon") {
	glo basepath "/Users/dekopon/Projects/WORLD BANK/SAR - GMD data harmonization/datalib/`code'/`yearfolder'"
	glo input "${basepath}/`yearfolder'_v`vm'_M"
	glo output "${basepath}/`yearfolder'_v`vm'_M_v`va'_A_SARGMD/Data/Harmonized"
	
	* load and merge relevant data
	cd "${input}/Data/Stata"
	* roster data
	use "roster_male.dta", clear
	* labour data
	merge 1:1 HH_ID Mem_ID using "labour_male", nogen assert(master match)
	* disability data
	merge 1:1 HH_ID Mem_ID using "disability", nogen assert(match)
	* household data
	merge m:1 HH_ID using "household_male", nogen assert(match)
	rename HH_ID hhid_orig
	destring hhid, g(HH_ID)	//note: need to fill in hhid if subsequent merged data contains umatched observations.
	* weight data
	merge m:1 HH_ID using "clusters", nogen assert(match) update replace
}
* global paths on WB computer
else {
	*<_Folder creation_>
	cap mkdir "${rootdatalib}\\`code'"
	cap mkdir "${rootdatalib}\\`code'\\`yearfolder'"
	cap mkdir "${rootdatalib}\\`code'\\`yearfolder'\\`harmfolder'"
	cap mkdir "${rootdatalib}\\`code'\\`yearfolder'\\`harmfolder'\Data"
	cap mkdir "${rootdatalib}\\`code'\\`yearfolder'\\`harmfolder'\Data\Harmonized"
	glo output "${rootdatalib}\\`code'\\`yearfolder'\\`harmfolder'\Data\Harmonized"
	*</_Folder creation_>
	
	*<_Datalibweb request_>
	tempfile individual_level_data
	local dlw "datalibweb, country(`code') year(`year') type(SARRAW) surveyid(`code'_`year'_`survey'_v`vm'_M)"
	qui `dlw' filename(temp_pov_2016_2019_consolidated.dta)
	keep if year==`year'
	drop year
	rename hhid HH_ID
	save `individual_level_data'	//NOTE: The poverty data is actually HH-level data, but will be merged into individual-level data in the next step.
	* roster data
	* NOTE: some individuals do not have poverty data. 
	qui `dlw' filename(labour_male.dta)
	merge m:1 HH_ID using `individual_level_data', nogen
	save `individual_level_data', replace
	* roster data
	qui `dlw' filename(roster_male.dta)
	merge 1:1 HH_ID Mem_ID using `individual_level_data', gen(m_pov_roster) 
	noi di "labour file has only individuals in the labor market, that why half observation are in labour file"
	save `individual_level_data', replace
	* disability data
	qui `dlw' filename(disability.dta)
	merge 1:1 HH_ID Mem_ID using `individual_level_data', nogen 
	save `individual_level_data', replace
	* household data
	qui `dlw' filename(household_male.dta)
	merge 1:m HH_ID using `individual_level_data', nogen 
	rename HH_ID hhid_orig
	destring hhid_orig, g(HH_ID)	//note: need to fill in hhid if subsequent merged data contains umatched observations.
	save `individual_level_data', replace
	* weight data
	qui `dlw' filename(clusters.dta)
	merge 1:m HH_ID using `individual_level_data', nogen
	*</_Datalibweb request_>
}

*<_countrycode_>
*<_countrycode_note_> country code *</_countrycode_note_>
*<_countrycode_note_> countrycode brought in from rawdata *</_countrycode_note_>
g countrycode = "`code'"
*</_countrycode_>

*<_year_>
*<_year_note_> Year *</_year_note_>
*<_year_note_> year brought in from rawdata *</_year_note_>
g year = `year'
*</_year_>

*<_hhid_>
*<_hhid_note_> Household identifier  *</_hhid_note_>
*<_hhid_note_> hhid brought in from rawdata *</_hhid_note_>
clonevar hhid = hhid_orig
*</_hhid_>

*<_pid_>
*<_pid_note_> Personal identifier  *</_pid_note_>
*<_pid_note_> pid brought in from rawdata *</_pid_note_>
clonevar pid = Mem_ID
*</_pid_>

*<_weight_>
*<_weight_note_> Household weight *</_weight_note_>
*<_weight_note_> weight brought in from rawdata *</_weight_note_>
clonevar weight = hh_weight
*</_weight_>

*<_weighttype_>
*<_weighttype_note_> Weight type (frequency, probability, analytical, importance) *</_weighttype_note_>
*<_weighttype_note_> weighttype brought in from rawdata *</_weighttype_note_>
g weighttype = "PW"
*</_weighttype_>

*<_age_>
*<_age_note_> Age of individual (continuous) *</_age_note_>
*<_age_note_> age brought in from rawdata *</_age_note_>
gen age = q202
*</_age_>

*<_minlaborage_>
*<_minlaborage_note_> Labor module application age *</_minlaborage_note_>
*<_minlaborage_note_> minlaborage brought in from rawdata *</_minlaborage_note_>
g minlaborage = 14
*</_minlaborage_>

*<_lstatus_>
*<_lstatus_note_> Labor status *</_lstatus_note_>
*<_lstatus_note_> lstatus brought in from rawdata *</_lstatus_note_>
g		lstatus = 1	if q304==1 | q305==1 | q306==1 | q307==1	 //2 Employed if working
replace	lstatus = 1 if q309==1	//2 Employed if they did any activity, even for 1 hour
replace	lstatus = 1 if q310==1	//2 Employed if temporarily absent
replace	lstatus = 1 if inlist(q314,6,7,9)	//2 Employed if an apprentice, in miliary service, or temporarily laid off
replace	lstatus = 3 if inlist(q314,1,2,3,5,11,13,14)	//3 Not in labor force if student, housekeeper, retired/too old, handicapped, did not want to work, family does not allow, other
recode	lstatus (.=2) if (q304==2 | q305==2 | q306==2 | q307==2) & (q312==1 | q313==1 | inlist(q314,4,8,10,12))
*2-Unemployed= (Did not did an activity last week) AND (seek job last four weeks OR if did not seek a job is not because they are out of the labor market)
recode lstatus (.=3) if  age>=minlaborage
*</_lstatus_>

*<_nlfreason_>
*<_nlfreason_note_> Reason not in the labor force *</_nlfreason_note_>
*<_nlfreason_note_> nlfreason brought in from rawdata *</_nlfreason_note_>
g		nlfreason = 1 if q314==1	//1= Student (a person currently studying.)
replace	nlfreason = 2 if q314==2	//2= Housewife (a person who takes care of the house, older people, or children)
replace nlfreason = 3 if q314==3	//3= Retired
replace nlfreason = 4 if q314==5	//4 = Disabled (a person who cannot work due to physical conditions)
recode nlfreason (.=5) if lstatus==3	//5 = Other (a person does not work for any other reason)
replace nlfreason = . if lstatus~=3
*</_nlfreason_>

*<_unempldur_l_>
*<_unempldur_l_note_> Unemployment duration (months) lower bracket *</_unempldur_l_note_>
*<_unempldur_l_note_> unempldur_l brought in from rawdata *</_unempldur_l_note_>
gen unempldur_l=.
note unempldur_l: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_unempldur_l_>

*<_unempldur_u_>
*<_unempldur_u_note_> Unemployment duration (months) upper bracket *</_unempldur_u_note_>
*<_unempldur_u_note_> unempldur_u brought in from rawdata *</_unempldur_u_note_>
gen unempldur_u=.
note unempldur_u: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_unempldur_u_>

*<_empstat_>
*<_empstat_note_> Employment status *</_empstat_note_>
*<_empstat_note_> empstat brought in from rawdata *</_empstat_note_>
recode q316 (1/3=1) (4=4) (5=3) (6=2) (*=.), g(empstat)
replace empstat = . if lstatus~=1
*</_empstat_>

*<_ocusec_>
*<_ocusec_note_> Sector of activity *</_ocusec_note_>
*<_ocusec_note_> ocusec brought in from rawdata *</_ocusec_note_>
recode q316 (1/2 4/6=2) (3=1) (*=.), g(ocusec)
replace ocusec = . if lstatus~=1
*</_ocusec_>

*<_industry_orig_>
*<_industry_orig_note_> original industry codes *</_industry_orig_note_>
*<_industry_orig_note_> industry_orig brought in from rawdata *</_industry_orig_note_>
clonevar industry_orig = q319
*</_industry_orig_>

*<_industrycat10_>
*<_industrycat10_note_> 1 digit industry classification *</_industrycat10_note_>
*<_industrycat10_note_> industrycat10 brought in from rawdata *</_industrycat10_note_>
gen industrycat10 = substr(q319,1,1)
destring industrycat10, replace
recode industrycat10 (0=10)
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
clonevar occup_orig = q320
*</_occup_orig_>

*<_occup_>
*<_occup_note_> 1 digit occupational classification *</_occup_note_>
*<_occup_note_> occup brought in from rawdata *</_occup_note_>
gen occup = substr(q320,1,1)
destring occup, replace
recode occup (0=10)
replace occup = . if lstatus~=1
*</_occup_>

*<_wage_nc_>
*<_wage_nc_note_> Last wage payment *</_wage_nc_note_>
*<_wage_nc_note_> wage_nc brought in from rawdata *</_wage_nc_note_>
gen wage_nc=.
note wage_nc: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_wage_nc_>

*<_unitwage_>
*<_unitwage_note_> Last wages time unit *</_unitwage_note_>
*<_unitwage_note_> unitwage brought in from rawdata *</_unitwage_note_>
gen unitwage=.
note unitwage: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_unitwage_>

*<_whours_>
*<_whours_note_> Hours of work in last week *</_whours_note_>
*<_whours_note_> whours brought in from rawdata *</_whours_note_>
gen whours= q317*q318
replace whours = . if lstatus~=1
*</_whours_>

*<_wmonths_>
*<_wmonths_note_> Months worked in the last 12 months *</_wmonths_note_>
*<_wmonths_note_> wmonths brought in from rawdata *</_wmonths_note_>
gen wmonths=.
note wmonths: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_wmonths_>

*<_wage_total_>
*<_wage_total_note_> Primary job total wage  *</_wage_total_note_>
*<_wage_total_note_> wage_total brought in from rawdata *</_wage_total_note_>
gen wage_total=.
note wage_total: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_wage_total_>

*<_contract_>
*<_contract_note_> Contract *</_contract_note_>
*<_contract_note_> contract brought in from rawdata *</_contract_note_>
gen contract=.
note contract: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_contract_>

*<_healthins_>
*<_healthins_note_> Health insurance *</_healthins_note_>
*<_healthins_note_> healthins brought in from rawdata *</_healthins_note_>
gen healthins=.
note healthins: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_healthins_>

*<_socialsec_>
*<_socialsec_note_> Social security *</_socialsec_note_>
*<_socialsec_note_> socialsec brought in from rawdata *</_socialsec_note_>
gen socialsec=.
note socialsec: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_socialsec_>

*<_union_>
*<_union_note_> Union membership *</_union_note_>
*<_union_note_> union brought in from rawdata *</_union_note_>
gen union=.
note union: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_union_>

*<_firmsize_l_>
*<_firmsize_l_note_> Firm size (lower bracket) *</_firmsize_l_note_>
*<_firmsize_l_note_> firmsize_l brought in from rawdata *</_firmsize_l_note_>
gen firmsize_l=.
note firmsize_l: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_firmsize_l_>

*<_firmsize_u_>
*<_firmsize_u_note_> Firm size (upper bracket) *</_firmsize_u_note_>
*<_firmsize_u_note_> firmsize_u brought in from rawdata *</_firmsize_u_note_>
gen firmsize_u=.
note firmsize_u: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_firmsize_u_>

*<_empstat_2_>
*<_empstat_2_note_> Employment status - second job *</_empstat_2_note_>
*<_empstat_2_note_> empstat_2 brought in from rawdata *</_empstat_2_note_>
recode q322b (1/3=1) (4=4) (5=3) (6=2) (*=.), g(empstat_2)
replace empstat_2 = . if lstatus~=1
*</_empstat_2_>

*<_ocusec_2_>
*<_ocusec_2_note_> Sector of activity for second job *</_ocusec_2_note_>
*<_ocusec_2_note_> ocusec_2 brought in from rawdata *</_ocusec_2_note_>
recode q322b (1/2 4/6=2) (3=1) (*=.), g(ocusec_2)
replace ocusec_2 = . if lstatus~=1
*</_ocusec_2_>

*<_industry_orig_2_>
*<_industry_orig_2_note_> original industry codes for second job *</_industry_orig_2_note_>
*<_industry_orig_2_note_> industry_orig_2 brought in from rawdata *</_industry_orig_2_note_>
clonevar industry_orig_2 = q322e
*</_industry_orig_2_>

*<_industrycat10_2_>
*<_industrycat10_2_note_> 1 digit industry classification for second job *</_industrycat10_2_note_>
*<_industrycat10_2_note_> industrycat10_2 brought in from rawdata *</_industrycat10_2_note_>
g industrycat10_2 = substr(q322e,1,1)
destring industrycat10_2, replace
recode industrycat10_2 (0=10)
replace industrycat10_2 = . if lstatus~=1
*</_industrycat10_2_>

*<_industrycat4_2_>
*<_industrycat4_2_note_> 1 digit industry classification (Broad Economic Activities) for second job *</_industrycat4_2_note_>
*<_industrycat4_2_note_> industrycat4_2 brought in from rawdata *</_industrycat4_2_note_>
recode industrycat10_2 (1=1) (2/5=2) (6/9=3) (10=4), g(industrycat4_2)
*</_industrycat4_2_>

*<_occup_orig_2_>
*<_occup_orig_2_note_> original occupation code for second job *</_occup_orig_2_note_>
*<_occup_orig_2_note_> occup_orig_2 brought in from rawdata *</_occup_orig_2_note_>
clonevar occup_orig_2 = q322f
*</_occup_orig_2_>

*<_occup_2_>
*<_occup_2_note_> 1 digit occupational classification for second job *</_occup_2_note_>
*<_occup_2_note_> occup_2 brought in from rawdata *</_occup_2_note_>
gen occup_2 = substr(q322f,1,1)
destring occup_2, replace
recode occup_2 (0=10)
replace occup_2 = . if lstatus~=1
*</_occup_2_>

*<_wage_nc_2_>
*<_wage_nc_2_note_> Last wage payment second job *</_wage_nc_2_note_>
*<_wage_nc_2_note_> wage_nc_2 brought in from rawdata *</_wage_nc_2_note_>
gen wage_nc_2=.
note wage_nc_2: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_wage_nc_2_>

*<_unitwage_2_>
*<_unitwage_2_note_> Last wages time unit second job *</_unitwage_2_note_>
*<_unitwage_2_note_> unitwage_2 brought in from rawdata *</_unitwage_2_note_>
gen unitwage_2=.
note unitwage_2: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_unitwage_2_>

*<_whours_2_>
*<_whours_2_note_> Hours of work in last week for the secondary job *</_whours_2_note_>
*<_whours_2_note_> whours_2 brought in from rawdata *</_whours_2_note_>
gen whours_2 = q322c*q322d
*</_whours_2_>

*<_wmonths_2_>
*<_wmonths_2_note_> Months worked in the last 12 months for the secondary job *</_wmonths_2_note_>
*<_wmonths_2_note_> wmonths_2 brought in from rawdata *</_wmonths_2_note_>
gen wmonths_2=.
note wmonths_2: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_wmonths_2_>

*<_wage_total_2_>
*<_wage_total_2_note_> Secondary job total wage  *</_wage_total_2_note_>
*<_wage_total_2_note_> wage_total_2 brought in from rawdata *</_wage_total_2_note_>
gen wage_total_2=.
note wage_total_2: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_wage_total_2_>

*<_firmsize_l_2_>
*<_firmsize_l_2_note_> Firm size (lower bracket) for the secondary job *</_firmsize_l_2_note_>
*<_firmsize_l_2_note_> firmsize_l_2 brought in from rawdata *</_firmsize_l_2_note_>
gen firmsize_l_2=.
note firmsize_l_2: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_firmsize_l_2_>

*<_firmsize_u_2_>
*<_firmsize_u_2_note_> Firm size (upper bracket) for the secondary job *</_firmsize_u_2_note_>
*<_firmsize_u_2_note_> firmsize_u_2 brought in from rawdata *</_firmsize_u_2_note_>
gen firmsize_u_2=.
note firmsize_u_2: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_firmsize_u_2_>

*<_t_hours_others_>
*<_t_hours_others_note_> Total hours of work in the last 12 months in other jobs excluding the primary and secondary ones *</_t_hours_others_note_>
*<_t_hours_others_note_> t_hours_others brought in from rawdata *</_t_hours_others_note_>
gen t_hours_others=.
note t_hours_others: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_t_hours_others_>

*<_t_wage_nc_others_>
*<_t_wage_nc_others_note_> Annualized wage in all jobs excluding the primary and secondary ones (excluding tips, bonuses, etc.). *</_t_wage_nc_others_note_>
*<_t_wage_nc_others_note_> t_wage_nc_others brought in from rawdata *</_t_wage_nc_others_note_>
gen t_wage_nc_others=.
note t_wage_nc_others: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_t_wage_nc_others_>

*<_t_wage_others_>
*<_t_wage_others_note_> Annualized wage (including tips, bonuses, etc.) in all other jobs excluding the primary and secondary ones. *</_t_wage_others_note_>
*<_t_wage_others_note_> t_wage_others brought in from rawdata *</_t_wage_others_note_>
gen t_wage_others=.
note t_wage_others: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_t_wage_others_>

*<_t_hours_total_>
*<_t_hours_total_note_> Annualized hours worked in all jobs (7-day ref period) *</_t_hours_total_note_>
*<_t_hours_total_note_> t_hours_total brought in from rawdata *</_t_hours_total_note_>
gen t_hours_total=.
note t_hours_total: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_t_hours_total_>

*<_t_wage_nc_total_>
*<_t_wage_nc_total_note_> Annualized wage in all jobs excl. bonuses, etc. (7-day ref period) *</_t_wage_nc_total_note_>
*<_t_wage_nc_total_note_> t_wage_nc_total brought in from rawdata *</_t_wage_nc_total_note_>
gen t_wage_nc_total=.
note t_wage_nc_total: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_t_wage_nc_total_>

*<_t_wage_nc_total_aux_>
g		t_wage_nc_total_day_labourer = q324 * q325 * q326
g		t_wage_nc_total_salaried = q330 * q331_1
g		t_wage_nc_total_self_employed = q333 * q334_2 * 5 * 4.3  if q334_1==1	//day
replace	t_wage_nc_total_self_employed = q333 * q334_2 * 4.3  if q334_1==2	//week
replace	t_wage_nc_total_self_employed = q333 * q334_2  if q334_1==3	//month
egen t_wage_nc_total_aux = rowtotal(t_wage_nc_total_day_labourer t_wage_nc_total_salaried t_wage_nc_total_self_employed), missing
*</_t_wage_nc_total_aux_>

*<_t_wage_total_>
*<_t_wage_total_note_> Annualized total wage for all jobs (7-day ref period) *</_t_wage_total_note_>
*<_t_wage_total_note_> t_wage_total brought in from rawdata *</_t_wage_total_note_>
gen t_wage_total=.
note t_wage_total: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_t_wage_total_>

*<_t_wage_total_aux_>
g		t_wage_total_day_labourer_part1 = q324 * q325 * q326
g		t_wage_total_day_labourer_part2 = q328
g		t_wage_total_salaried = q330 * q331_4
g		t_wage_total_self_employed = q333 * q334_2 * 5 * 4.3  if q334_1==1	//day
replace	t_wage_total_self_employed = q333 * q334_2 * 4.3  if q334_1==2	//week
replace	t_wage_total_self_employed = q333 * q334_2  if q334_1==3	//month
egen t_wage_total_aux = rowtotal(t_wage_total_day_labourer_part1 t_wage_total_day_labourer_part2 t_wage_total_salaried t_wage_total_self_employed), missing
*</_t_wage_total_aux_>

*<_minlaborage_year_>
*<_minlaborage_year_note_> Labor module application age (12-mon ref period) *</_minlaborage_year_note_>
*<_minlaborage_year_note_> minlaborage_year brought in from rawdata *</_minlaborage_year_note_>
gen minlaborage_year = 14
*</_minlaborage_year_>

*<_lstatus_year_>
*<_lstatus_year_note_> Labor status (12-mon ref period) *</_lstatus_year_note_>
*<_lstatus_year_note_> lstatus_year brought in from rawdata *</_lstatus_year_note_>
gen lstatus_year=.
note lstatus_year: Although q315 asks about labor status in the last 12 months, it is skipped for people employed in the last 7 days (see flow directions in 3.08 and 3.09), and doesn't allow us to categorize people into lstatus_year = 3 "not in 12 month labor force". We cannot create any of the *_year labor variables because they all require lstatus_year to exist.
*</_lstatus_year_>

*<_nlfreason_year_>
*<_nlfreason_year_note_> Reason not in the labor force (12-mon ref period) *</_nlfreason_year_note_>
*<_nlfreason_year_note_> nlfreason_year brought in from rawdata *</_nlfreason_year_note_>
gen nlfreason_year=.
note nlfreason_year: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_nlfreason_year_>

*<_unempldur_l_year_>
*<_unempldur_l_year_note_> Unemployment duration (months) lower bracket (12-mon ref period) *</_unempldur_l_year_note_>
*<_unempldur_l_year_note_> unempldur_l_year brought in from rawdata *</_unempldur_l_year_note_>
gen unempldur_l_year=.
note unempldur_l_year: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_unempldur_l_year_>

*<_unempldur_u_year_>
*<_unempldur_u_year_note_> Unemployment duration (months) upper bracket (12-mon ref period) *</_unempldur_u_year_note_>
*<_unempldur_u_year_note_> unempldur_u_year brought in from rawdata *</_unempldur_u_year_note_>
gen unempldur_u_year=.
note unempldur_u_year: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_unempldur_u_year_>

*<_empstat_year_>
*<_empstat_year_note_> Employment status, primary job (12-mon ref period) *</_empstat_year_note_>
*<_empstat_year_note_> empstat_year brought in from rawdata *</_empstat_year_note_>
gen empstat_year=.
note empstat_year: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_empstat_year_>

*<_ocusec_year_>
*<_ocusec_year_note_> Sector of activity, primary job (12-mon ref period) *</_ocusec_year_note_>
*<_ocusec_year_note_> ocusec_year brought in from rawdata *</_ocusec_year_note_>
gen ocusec_year=.
note ocusec_year: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_ocusec_year_>

*<_industry_orig_year_>
*<_industry_orig_year_note_> Original industry code, primary job (12-mon ref period) *</_industry_orig_year_note_>
*<_industry_orig_year_note_> industry_orig_year brought in from rawdata *</_industry_orig_year_note_>
gen industry_orig_year=.
note industry_orig_year: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_industry_orig_year_>

*<_industrycat10_year_>
*<_industrycat10_year_note_> 1 digit industry classification, primary job (12-mon ref period) *</_industrycat10_year_note_>
*<_industrycat10_year_note_> industrycat10_year brought in from rawdata *</_industrycat10_year_note_>
gen industrycat10_year=.
note industrycat10_year: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_industrycat10_year_>

*<_industrycat4_year_>
*<_industrycat4_year_note_> 4-category industry classification primary job (12-mon ref period) *</_industrycat4_year_note_>
*<_industrycat4_year_note_> industrycat4_year brought in from rawdata *</_industrycat4_year_note_>
gen industrycat4_year=.
note industrycat4_year: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_industrycat4_year_>

*<_occup_orig_year_>
*<_occup_orig_year_note_> Original occupational classification, primary job (12-mon ref period) *</_occup_orig_year_note_>
*<_occup_orig_year_note_> occup_orig_year brought in from rawdata *</_occup_orig_year_note_>
gen occup_orig_year=.
note occup_orig_year: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_occup_orig_year_>

*<_occup_year_>
*<_occup_year_note_> 1 digit occupational classification, primary job (12-mon ref period) *</_occup_year_note_>
*<_occup_year_note_> occup_year brought in from rawdata *</_occup_year_note_>
gen occup_year=.
note occup_year: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_occup_year_>

*<_wage_nc_year_>
*<_wage_nc_year_note_> Last wage payment, primary job, excl. bonuses, etc. (12-mon ref period) *</_wage_nc_year_note_>
*<_wage_nc_year_note_> wage_nc_year brought in from rawdata *</_wage_nc_year_note_>
gen wage_nc_year=.
note wage_nc_year: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_wage_nc_year_>

*<_unitwage_year_>
*<_unitwage_year_note_> Time unit of last wages payment, primary job (12-mon ref period) *</_unitwage_year_note_>
*<_unitwage_year_note_> unitwage_year brought in from rawdata *</_unitwage_year_note_>
gen unitwage_year=.
note unitwage_year: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_unitwage_year_>

*<_whours_year_>
*<_whours_year_note_> Hours of work in last week, primary job (12-mon ref period) *</_whours_year_note_>
*<_whours_year_note_> whours_year brought in from rawdata *</_whours_year_note_>
gen whours_year=.
note whours_year: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_whours_year_>

*<_wmonths_year_>
*<_wmonths_year_note_> Months worked in the last 12 months, primary job (12-mon ref period) *</_wmonths_year_note_>
*<_wmonths_year_note_> wmonths_year brought in from rawdata *</_wmonths_year_note_>
gen wmonths_year=.
note wmonths_year: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_wmonths_year_>

*<_wage_total_year_>
*<_wage_total_year_note_> Annualized total wage, primary job (12-mon ref period) *</_wage_total_year_note_>
*<_wage_total_year_note_> wage_total_year brought in from rawdata *</_wage_total_year_note_>
gen wage_total_year=.
note wage_total_year: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_wage_total_year_>

*<_contract_year_>
*<_contract_year_note_> Contract (12-mon ref period) *</_contract_year_note_>
*<_contract_year_note_> contract_year brought in from rawdata *</_contract_year_note_>
gen contract_year=.
note contract_year: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_contract_year_>

*<_healthins_year_>
*<_healthins_year_note_> Health insurance (12-mon ref period) *</_healthins_year_note_>
*<_healthins_year_note_> healthins_year brought in from rawdata *</_healthins_year_note_>
gen healthins_year=.
note healthins_year: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_healthins_year_>

*<_socialsec_year_>
*<_socialsec_year_note_> Social security (12-mon ref period) *</_socialsec_year_note_>
*<_socialsec_year_note_> socialsec_year brought in from rawdata *</_socialsec_year_note_>
gen socialsec_year=.
note socialsec_year: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_socialsec_year_>

*<_union_year_>
*<_union_year_note_> Union membership (12-mon ref period) *</_union_year_note_>
*<_union_year_note_> union_year brought in from rawdata *</_union_year_note_>
gen union_year=.
note union_year: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_union_year_>

*<_firmsize_l_year_>
*<_firmsize_l_year_note_> Firm size (lower bracket) (12-mon ref period) *</_firmsize_l_year_note_>
*<_firmsize_l_year_note_> firmsize_l_year brought in from rawdata *</_firmsize_l_year_note_>
gen firmsize_l_year=.
note firmsize_l_year: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_firmsize_l_year_>

*<_firmsize_u_year_>
*<_firmsize_u_year_note_> Firm size (upper bracket) (12-mon ref period) *</_firmsize_u_year_note_>
*<_firmsize_u_year_note_> firmsize_u_year brought in from rawdata *</_firmsize_u_year_note_>
gen firmsize_u_year=.
note firmsize_u_year: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_firmsize_u_year_>

*<_empstat_2_year_>
*<_empstat_2_year_note_> Employment status - second job (12-mon ref period) *</_empstat_2_year_note_>
*<_empstat_2_year_note_> empstat_2_year brought in from rawdata *</_empstat_2_year_note_>
gen empstat_2_year=.
note empstat_2_year: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_empstat_2_year_>

*<_ocusec_2_year_>
*<_ocusec_2_year_note_> Sector of activity for second job (12-mon ref period) *</_ocusec_2_year_note_>
*<_ocusec_2_year_note_> ocusec_2_year brought in from rawdata *</_ocusec_2_year_note_>
gen ocusec_2_year=.
note ocusec_2_year: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_ocusec_2_year_>

*<_industry_orig_2_year_>
*<_industry_orig_2_year_note_> original industry codes for second job (12-mon ref period) *</_industry_orig_2_year_note_>
*<_industry_orig_2_year_note_> industry_orig_2_year brought in from rawdata *</_industry_orig_2_year_note_>
gen industry_orig_2_year=.
note industry_orig_2_year: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_industry_orig_2_year_>

*<_industrycat10_2_year_>
*<_industrycat10_2_year_note_> 1 digit industry classification for second job (12-mon ref period) *</_industrycat10_2_year_note_>
*<_industrycat10_2_year_note_> industrycat10_2_year brought in from rawdata *</_industrycat10_2_year_note_>
gen industrycat10_2_year=.
note industrycat10_2_year: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_industrycat10_2_year_>

*<_industrycat4_2_year_>
*<_industrycat4_2_year_note_> 4-category industry classification, secondary job (12-mon ref period) *</_industrycat4_2_year_note_>
*<_industrycat4_2_year_note_> industrycat4_2_year brought in from rawdata *</_industrycat4_2_year_note_>
gen industrycat4_2_year=.
note industrycat4_2_year: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_industrycat4_2_year_>

*<_occup_orig_2_year_>
*<_occup_orig_2_year_note_> Original occupational classification, secondary job (12-mon ref period) *</_occup_orig_2_year_note_>
*<_occup_orig_2_year_note_> occup_orig_2_year brought in from rawdata *</_occup_orig_2_year_note_>
gen occup_orig_2_year=.
note occup_orig_2_year: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_occup_orig_2_year_>

*<_occup_2_year_>
*<_occup_2_year_note_> 1 digit occupational classification, secondary job (12-mon ref period) *</_occup_2_year_note_>
*<_occup_2_year_note_> occup_2_year brought in from rawdata *</_occup_2_year_note_>
gen occup_2_year=.
note occup_2_year: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_occup_2_year_>

*<_wage_nc_2_year_>
*<_wage_nc_2_year_note_> last wage payment, secondary job, excl. bonuses, etc. (12-mon ref period) *</_wage_nc_2_year_note_>
*<_wage_nc_2_year_note_> wage_nc_2_year brought in from rawdata *</_wage_nc_2_year_note_>
gen wage_nc_2_year=.
note wage_nc_2_year: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_wage_nc_2_year_>

*<_unitwage_2_year_>
*<_unitwage_2_year_note_> Time unit of last wages payment, secondary job (12-mon ref period) *</_unitwage_2_year_note_>
*<_unitwage_2_year_note_> unitwage_2_year brought in from rawdata *</_unitwage_2_year_note_>
gen unitwage_2_year=.
note unitwage_2_year: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_unitwage_2_year_>

*<_whours_2_year_>
*<_whours_2_year_note_> Hours of work in last week, secondary job (12-mon ref period) *</_whours_2_year_note_>
*<_whours_2_year_note_> whours_2_year brought in from rawdata *</_whours_2_year_note_>
gen whours_2_year=.
note whours_2_year: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_whours_2_year_>

*<_wmonths_2_year_>
*<_wmonths_2_year_note_> Months worked in the last 12 months, secondary job (12-mon ref period) *</_wmonths_2_year_note_>
*<_wmonths_2_year_note_> wmonths_2_year brought in from rawdata *</_wmonths_2_year_note_>
gen wmonths_2_year=.
note wmonths_2_year: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_wmonths_2_year_>

*<_wage_total_2_year_>
*<_wage_total_2_year_note_> Annualized total wage, secondary job (12-mon ref period) *</_wage_total_2_year_note_>
*<_wage_total_2_year_note_> wage_total_2_year brought in from rawdata *</_wage_total_2_year_note_>
gen wage_total_2_year=.
note wage_total_2_year: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_wage_total_2_year_>

*<_firmsize_l_2_year_>
*<_firmsize_l_2_year_note_> Firm size (lower bracket), secondary job (12-mon ref period) *</_firmsize_l_2_year_note_>
*<_firmsize_l_2_year_note_> firmsize_l_2_year brought in from rawdata *</_firmsize_l_2_year_note_>
gen firmsize_l_2_year=.
note firmsize_l_2_year: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_firmsize_l_2_year_>

*<_firmsize_u_2_year_>
*<_firmsize_u_2_year_note_> Firm size (lower bracket), secondary job (12-mon ref period) *</_firmsize_u_2_year_note_>
*<_firmsize_u_2_year_note_> firmsize_u_2_year brought in from rawdata *</_firmsize_u_2_year_note_>
gen firmsize_u_2_year=.
note firmsize_u_2_year: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_firmsize_u_2_year_>

*<_t_hours_others_year_>
*<_t_hours_others_year_note_> Annualized hours worked in all but primary and secondary jobs (12-mon ref period) *</_t_hours_others_year_note_>
*<_t_hours_others_year_note_> t_hours_others_year brought in from rawdata *</_t_hours_others_year_note_>
gen t_hours_others_year=.
note t_hours_others_year: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_t_hours_others_year_>

*<_t_wage_nc_others_year_>
*<_t_wage_nc_others_year_note_> Annualized wage in all but primary & secondary jobs excl. bonuses, etc. (12-mon ref period) *</_t_wage_nc_others_year_note_>
*<_t_wage_nc_others_year_note_> t_wage_nc_others_year brought in from rawdata *</_t_wage_nc_others_year_note_>
gen t_wage_nc_others_year=.
note t_wage_nc_others_year: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_t_wage_nc_others_year_>

*<_t_wage_others_year_>
*<_t_wage_others_year_note_> Annualized wage in all but primary and secondary jobs (12-mon ref period) *</_t_wage_others_year_note_>
*<_t_wage_others_year_note_> t_wage_others_year brought in from rawdata *</_t_wage_others_year_note_>
gen t_wage_others_year=.
note t_wage_others_year: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_t_wage_others_year_>

*<_t_hours_total_year_>
*<_t_hours_total_year_note_> Annualized hours worked in all jobs (12-mon ref period) *</_t_hours_total_year_note_>
*<_t_hours_total_year_note_> t_hours_total_year brought in from rawdata *</_t_hours_total_year_note_>
gen t_hours_total_year=.
note t_hours_total_year: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_t_hours_total_year_>

*<_t_wage_nc_total_year_>
*<_t_wage_nc_total_year_note_> Annualized wage in all jobs excl. bonuses, etc. (12-mon ref period) *</_t_wage_nc_total_year_note_>
*<_t_wage_nc_total_year_note_> t_wage_nc_total_year brought in from rawdata *</_t_wage_nc_total_year_note_>
gen t_wage_nc_total_year=.
note t_wage_nc_total_year: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_t_wage_nc_total_year_>

*<_t_wage_total_year_>
*<_t_wage_total_year_note_> Annualized total wage for all jobs (12-mon ref period) *</_t_wage_total_year_note_>
*<_t_wage_total_year_note_> t_wage_total_year brought in from rawdata *</_t_wage_total_year_note_>
gen t_wage_total_year=.
note t_wage_total_year: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_t_wage_total_year_>

*<_njobs_>
*<_njobs_note_> Total number of jobs *</_njobs_note_>
*<_njobs_note_> njobs brought in from rawdata *</_njobs_note_>
gen njobs=.
note njobs: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_njobs_>

*<_t_hours_annual_>
*<_t_hours_annual_note_> Total hours worked in all jobs in the previous 12 months *</_t_hours_annual_note_>
*<_t_hours_annual_note_> t_hours_annual brought in from rawdata *</_t_hours_annual_note_>
gen t_hours_annual=.
note t_hours_annual: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_t_hours_annual_>

*<_linc_nc_>
*<_linc_nc_note_> Total annual wage income in all jobs, excl. bonuses, etc. *</_linc_nc_note_>
*<_linc_nc_note_> linc_nc brought in from rawdata *</_linc_nc_note_>
gen linc_nc=.
note linc_nc: I cannot find questions in the questionnaire or variables in the data to create this indicator. According to the guidelines, this variable should include all jobs. But for people who have more than one salaried job, question 3.31 limits us to knowing only their main job's salary. I did create a linc_nc_aux version of this variable.
*</_linc_nc_>

*<_linc_nc_aux_>
g		linc_nc_day_labourer = q324 * q325 * q326
g		linc_nc_salaried = q330 * q331_1
g		linc_nc_self_employed = q333 * q334_2 * 5 * 4.3  if q334_1==1	//day
replace	linc_nc_self_employed = q333 * q334_2 * 4.3  if q334_1==2	//week
replace	linc_nc_self_employed = q333 * q334_2  if q334_1==3	//month
egen linc_nc_aux = rowtotal(linc_nc_day_labourer linc_nc_salaried linc_nc_self_employed), missing
*</_linc_nc_aux_>

*<_laborincome_>
*<_laborincome_note_> Total annual individual labor income in all jobs, incl. bonuses, etc. *</_laborincome_note_>
*<_laborincome_note_> laborincome brought in from rawdata *</_laborincome_note_>
gen laborincome=.
note laborincome: I cannot find questions in the questionnaire or variables in the data to create this indicator. According to the guidelines, this variable should include all jobs. But for people who have more than one salaried job, question 3.31 limits us to knowing only their main job's salary. I did create a laborincome_aux version of this variable.
*</_laborincome_>

*<_laborincome_aux_>
g		laborincome_day_labourer_part1 = q324 * q325 * q326
g		laborincome_day_labourer_part2 = q328
g		laborincome_salaried = q330 * q331_4
g		laborincome_self_employed = q333 * q334_2 * 5 * 4.3  if q334_1==1	//day
replace	laborincome_self_employed = q333 * q334_2 * 4.3  if q334_1==2	//week
replace	laborincome_self_employed = q333 * q334_2  if q334_1==3	//month
egen laborincome_aux = rowtotal(laborincome_day_labourer_part1 laborincome_day_labourer_part2 laborincome_salaried laborincome_self_employed), missing
*</_laborincome_aux_>

*<_Keep variables_>
keep countrycode year hhid pid weight weighttype age minlaborage lstatus nlfreason unempldur_l unempldur_u empstat ocusec industry_orig industrycat10 industrycat4 occup_orig occup wage_nc unitwage whours wmonths wage_total contract healthins socialsec union firmsize_l firmsize_u empstat_2 ocusec_2 industry_orig_2 industrycat10_2 industrycat4_2 occup_orig_2 occup_2 wage_nc_2 unitwage_2 whours_2 wmonths_2 wage_total_2 firmsize_l_2 firmsize_u_2 t_hours_others t_wage_nc_others t_wage_others t_hours_total t_wage_nc_total t_wage_total minlaborage_year lstatus_year nlfreason_year unempldur_l_year unempldur_u_year empstat_year ocusec_year industry_orig_year industrycat10_year industrycat4_year occup_orig_year occup_year wage_nc_year unitwage_year whours_year wmonths_year wage_total_year contract_year healthins_year socialsec_year union_year firmsize_l_year firmsize_u_year empstat_2_year ocusec_2_year industry_orig_2_year industrycat10_2_year industrycat4_2_year occup_orig_2_year occup_2_year wage_nc_2_year unitwage_2_year whours_2_year wmonths_2_year wage_total_2_year firmsize_l_2_year firmsize_u_2_year t_hours_others_year t_wage_nc_others_year t_wage_others_year t_hours_total_year t_wage_nc_total_year t_wage_total_year njobs t_hours_annual linc_nc laborincome *_aux t_wage_*
order countrycode year hhid pid weight weighttype
sort hhid pid 
*</_Keep variables_>

*<_Save data file_>
compress
if ("`c(username)'"=="dekopon") save "${output}/`filename'", replace
else save "${output}/`filename'.dta" , replace
*</_Save data file_>
