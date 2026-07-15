/*------------------------------------------------------------------------------
					GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   BGD_2016_HIES_v01_M_v01_A_GMD_LBR.do	</_Program name_>
<_Application_>    STATA 16.0	<_Application_>
<_Author(s)_>      Navishti Das and Javier Parada	</_Author(s)_>
<_Date created_>   03-03-2019	</_Date created_>
<_Date modified>   03-31-2020	</_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        BGD	</_Country_>
<_Survey Title_>   HIES	</_Survey Title_>
<_Survey Year_>    2016	</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:	03-31-2020
File:	BGD_2016_HIES_v01_M_v01_A_GMD_LBR.do
- First version
</_Version Control_>
------------------------------------------------------------------------------*/



*<_Raw data setup_>;
datalibweb, country(BGD) year(2016) type(SARRAW) surveyid(BGD_2016_HIES_v01_M) filename(HH_SEC_4.dta)

#delimit;
tempfile employmentdata;

drop if indid==.;
drop if indid==0;
drop if (s4aq02==. | s4aq02== 0) & (s4aq03==. | s4aq03== 0) & (s4aq04==. | s4aq04== 0); 

drop quarter hhwgt stratum stratum16 ruc urbrural division_code division_name zila_code zila_name s4aq05b s4aq05a;

gen hrspyr = int(s4aq04*s4aq03*s4aq02);

drop if hrspyr == .; 

gsort +psu +hhid +indid -hrspyr;
by psu hhid indid: gen activity_hr = _n;
*</_Raw data setup_>;

********************************************************************************
	* Variables to generate before discarding data for other activities
********************************************************************************
*<_njobs_>;
*<_njobs_note_> Total number of jobs *</_njobs_note_>;
*<_njobs_note_> njobs brought in from rawdata  *</_njobs_note_>;
gen one=1;	
bys psu hhid indid: egen njobs_year=total(one);
drop one;
*</_njobs_>;

*<_t_hours_others_year_>;
*<_t_hours_others_year_note_> Annualized hours worked in all but primary and secondary jobs (12-mon ref period) *</_t_hours_others_year_note_>;
*<_t_hours_others_year_note_> t_hours_others_year brought in from rawdata *</_t_hours_others_year_note_>;
bysort psu hhid indid: egen total_hours_other = total(hrspyr) if activity_hr > 2, missing;
bysort psu hhid indid: gen t_hours_others_year = total_hours_other[3];
drop total_hours_other;
*</_t_hours_others_year_>;

*<_t_wage_nc_others_year_>;
*<_t_wage_nc_others_year_note_> Annualized wage in all but primary & secondary jobs excl. bonuses, etc. (12-mon ref period) *</_t_wage_nc_others_year_note_>;
*<_t_wage_nc_others_year_note_> t_wage_nc_others_year brought in from rawdata  *</_t_wage_nc_others_year_note_>;
	*Cleaning;
replace s4bq07 = . if s4bq07 == 0 & s4bq08 == 0 & s4bq09 == 0;
replace s4bq08 = . if s4bq07 == 0 & s4bq08 == 0 & s4bq09 == 0;
replace s4bq09 = . if s4bq07 == 0 & s4bq08 == 0 & s4bq09 == 0;

replace s4bq02c = . if s4bq02c == 0 & s4bq02a == 0 & s4bq02b == 0;
replace s4bq02a = . if s4bq02c == 0 & s4bq02a == 0 & s4bq02b == 0;
replace s4bq02b = . if s4bq02c == 0 & s4bq02a == 0 & s4bq02b == 0;

recode s4bq07 (0 = .);
recode s4bq02c (0 = .);
	* for daily wage;
gen daily_others = int(s4bq02c*s4aq03*s4aq02) if activity_hr > 2;
	* for salary;
gen salary_others = int(s4bq07*s4aq02) if activity_hr > 2;
	* Sum of both for those who have both kinds of payment;
egen salarydaily_others = rowtotal(daily_others salary_others), missing;
	*Summing across all activities;
bysort psu hhid indid: egen t_wage_nc_others_year = total(salarydaily_others), missing;
*</_t_wage_nc_others_year_>;

*<_t_wage_others_year_>;
*<_t_wage_others_year_note_> Annualized wage in all but primary and secondary jobs (12-mon ref period) *</_t_wage_others_year_note_>;
*<_t_wage_others_year_note_> t_wage_others_year brought in from rawdata *</_t_wage_others_year_note_>;
	* bonus for daily wage;
gen bonus_daily_others = int(s4bq05b*s4aq03*s4aq02) if activity_hr > 2;
	* bonus for salary; 
gen bonus_salary_others = int(s4bq09) if activity_hr > 2;
	* daily bonus + salary bonus;
egen bonus_salarydaily_others = rowtotal(bonus_daily_others bonus_salary_others), missing;
	* salary + bonus for daily +salaried;
egen combined_others = rowtotal(bonus_salarydaily_others salarydaily_others), missing;
	* salary + bonus for daily +salaried across all other jobs;
bysort psu hhid indid: egen t_wage_others_year = total(combined_others), missing;

	*dropping excess vars;
drop daily_others salary_others salarydaily_others bonus_daily_others bonus_salary_others bonus_salarydaily_others combined_others;
*</_t_wage_others_year_>;


********************************************************************************
  * Reshaping data and keeping only 2 activities on which most time was spent
********************************************************************************
*<_Raw data transform_>;

drop activity;

keep if inlist(activity_hr,1,2);

ds psu hhid indid activity_hr, not;

foreach var in `r(varlist)' {;
ren `var' `var'_;
};

ds psu hhid indid activity_hr, not;

reshape wide `r(varlist)', i(psu hhid indid) j(activity_hr);

drop njobs_year_2 t_hours_others_year_2 t_wage_nc_others_year_2 t_wage_others_year_2;
rename njobs_year_1               njobs_year ;     
rename t_hours_others_year_1     t_hours_others_year ;  
rename t_wage_nc_others_year_1   t_wage_nc_others_year ;  
rename t_wage_others_year_1      t_wage_others_year ;
*rename (njobs_year_1 t_hours_others_year_1 t_wage_nc_others_year_1 t_wage_others_year_1) (njobs_year t_hours_others_year t_wage_nc_others_year t_wage_others_year); 

egen idp = concat(psu hhid indid), punct(-);
egen idh = concat(psu hhid), punct(-);

save `employmentdata', replace;
*</_Raw data transform_>;

********************************************************************************

*<_Program setup_>;
#delimit 
clear all;
set more off;

local code         "BGD";
local year         "2016";
local survey       "HIES";
local vm           "01";
local va           "04";
local type         "SARMD";
local yearfolder   "`code'_`year'_`survey'";
local gmdfolder    "`yearfolder'_v`vm'_M_v`va'_A_SARMD";
local filename     "`gmdfolder'_LBR";
*</_Program setup_>;

*<_Folder creation_>;
*;
*</_Folder creation_>;

*<_Datalibweb request_>;
#delimit cr
*datalibweb, country(`code') year(`year') type(`type') survey(`survey') vermast(`vm') veralt(`va') mod(IND) clear 
use "$rootdatalib\\`code'\\`yearfolder'\\`gmdfolder'\Data\Harmonized\\`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD_IND.dta", clear
#delimit ;
*</_Datalibweb request_>;

*<_Merge_>;
ren njobs_year njobs_year_sarmd; 

merge 1:1 psu idh idp using `employmentdata';

drop if _merge == 2;
drop _merge;
*</_Merge_>;

*<_countrycode_>;
*<_countrycode_note_> country code *</_countrycode_note_>;
*<_countrycode_note_> countrycode brought in from SARMD *</_countrycode_note_>;
*clonevar countrycode = code;
*</_countrycode_>;

*<_year_>;
*<_year_note_> Year *</_year_note_>;
*<_year_note_> year brought in from SARMD *</_year_note_>;
*year;
*</_year_>;

*<_hhid_>;
*<_hhid_note_> Household identifier  *</_hhid_note_>;
*<_hhid_note_> hhid brought in from SARMD *</_hhid_note_>;
drop hhid;
clonevar hhid = idh;
*</_hhid_>;

*<_pid_>;
*<_pid_note_> Personal identifier  *</_pid_note_>;
*<_pid_note_> pid brought in from SARMD *</_pid_note_>;
clonevar pid  = idp;
*</_pid_>;

*<_weight_>;
*<_weight_note_> Household weight *</_weight_note_>;
*<_weight_note_> weight brought in from SARMD *</_weight_note_>;
clonevar  weight = wgt;
*</_weight_>;

*<_weighttype_>;
*<_weighttype_note_> Weight type (frequency, probability, analytical, importance) *</_weighttype_note_>;
*<_weighttype_note_> weighttype brought in from SARMD *</_weighttype_note_>;
gen weighttype = "PW";
*</_weighttype_>;

*<_age_>;
*<_age_note_> Age of individual (continuous) *</_age_note_>;
*<_age_note_> age brought in from SARMD *</_age_note_>;
*age ;
*</_age_>;

*<_minlaborage_>;
*<_minlaborage_note_> Labor module application age *</_minlaborage_note_>;
*<_minlaborage_note_> minlaborage brought in from SARMD *</_minlaborage_note_>;
clonevar minlaborage = lb_mod_age;
*</_minlaborage_>;

*<_lstatus_>;
*<_lstatus_note_> Labor status *</_lstatus_note_>;
*<_lstatus_note_> lstatus brought in from SARMD *</_lstatus_note_>;
*lstatus;
*</_lstatus_>;

*<_nlfreason_>;
*<_nlfreason_note_> Reason not in the labor force *</_nlfreason_note_>;
*<_nlfreason_note_> nlfreason brought in from SARMD *</_nlfreason_note_>;
*nlfreason;
*</_nlfreason_>;

*<_unempldur_l_>;
*<_unempldur_l_note_> Unemployment duration (months) lower bracket *</_unempldur_l_note_>;
*<_unempldur_l_note_> unempldur_l brought in from  *</_unempldur_l_note_>;
gen unempldur_l=.;
*</_unempldur_l_>;

*<_unempldur_u_>;
*<_unempldur_u_note_> Unemployment duration (months) upper bracket *</_unempldur_u_note_>;
*<_unempldur_u_note_> unempldur_u brought in from  *</_unempldur_u_note_>;
gen unempldur_u=.;
*</_unempldur_u_>;

*<_empstat_>;
*<_empstat_note_> Employment status *</_empstat_note_>;
*<_empstat_note_> empstat brought in from*</_empstat_note_>;
ren empstat empstat_sarmd;
gen empstat = .;
*</_empstat_>;

*<_ocusec_>;
*<_ocusec_note_> Sector of activity *</_ocusec_note_>;
*<_ocusec_note_> ocusec brought in from  *</_ocusec_note_>;
ren ocusec ocusec_sarmd;
gen ocusec = .;
*</_ocusec_>;

*<_industry_orig_>;
*<_industry_orig_note_> original industry codes *</_industry_orig_note_>;
*<_industry_orig_note_> industry_orig brought in from  *</_industry_orig_note_>;
ren industry_orig industry_orig_sarmd; 
gen industry_orig = .;
*</_industry_orig_>;

*<_industrycat10_>;
*<_industrycat10_note_> 1 digit industry classification *</_industrycat10_note_>;
*<_industrycat10_note_> industrycat10 brought in from  *</_industrycat10_note_>;
gen industrycat10=.;
*</_industrycat10_>;

*<_industrycat4_>;
*<_industrycat4_note_> 1 digit industry classification (Broad Economic Activities) *</_industrycat4_note_>;
*<_industrycat4_note_> industrycat4 brought in from  *</_industrycat4_note_>;
gen industrycat4=.;
*</_industrycat4_>;

*<_occup_orig_>;
*<_occup_orig_note_> original occupation code *</_occup_orig_note_>;
*<_occup_orig_note_> occup_orig brought in from  *</_occup_orig_note_>;
ren occup_orig occup_orig_sarmd ;
gen occup_orig=.;
*</_occup_orig_>;

*<_occup_>;
*<_occup_note_> 1 digit occupational classification *</_occup_note_>;
*<_occup_note_> occup brought in from *</_occup_note_>;
ren occup occup_sarmd;
gen occup=.;
*</_occup_>;

*<_wage_nc_>;
*<_wage_nc_note_> Last wage payment *</_wage_nc_note_>;
*<_wage_nc_note_> wage_nc brought in from  *</_wage_nc_note_>;
gen wage_nc=.;
*</_wage_nc_>;

*<_unitwage_>;
*<_unitwage_note_> Last wages time unit *</_unitwage_note_>;
*<_unitwage_note_> unitwage brought in from  *</_unitwage_note_>;
ren unitwage unitwage_sarmd;
gen unitwage=.;
*</_unitwage_>;

*<_whours_>;
*<_whours_note_> Hours of work in last week *</_whours_note_>;
*<_whours_note_> whours brought in from  *</_whours_note_>;
ren whours whours_sarmd;
gen whours=.;
*</_whours_>;

*<_wmonths_>;
*<_wmonths_note_> Months worked in the last 12 months *</_wmonths_note_>;
*<_wmonths_note_> wmonths brought in from  *</_wmonths_note_>;
gen wmonths=.;
*</_wmonths_>;

*<_wage_total_>;
*<_wage_total_note_> Primary job total wage  *</_wage_total_note_>;
*<_wage_total_note_> wage_total brought in from  *</_wage_total_note_>;
gen wage_total=.;
*</_wage_total_>;

*<_contract_>;
*<_contract_note_> Contract *</_contract_note_>;
*<_contract_note_> contract brought in from  *</_contract_note_>;
gen contract=.;
*</_contract_>;

*<_healthins_>;
*<_healthins_note_> Health insurance *</_healthins_note_>;
*<_healthins_note_> healthins brought in from  *</_healthins_note_>;
gen healthins=.;
*</_healthins_>;

*<_socialsec_>;
*<_socialsec_note_> Social security *</_socialsec_note_>;
*<_socialsec_note_> socialsec brought in from  *</_socialsec_note_>;
gen socialsec=.;
*</_socialsec_>;

*<_union_>;
*<_union_note_> Union membership *</_union_note_>;
*<_union_note_> union brought in from  *</_union_note_>;
gen union=.;
*</_union_>;

*<_firmsize_l_>;
*<_firmsize_l_note_> Firm size (lower bracket) *</_firmsize_l_note_>;
*<_firmsize_l_note_> firmsize_l brought in from  *</_firmsize_l_note_>;
gen firmsize_l=.;
*</_firmsize_l_>;

*<_firmsize_u_>;
*<_firmsize_u_note_> Firm size (upper bracket) *</_firmsize_u_note_>;
*<_firmsize_u_note_> firmsize_u brought in from  *</_firmsize_u_note_>;
gen firmsize_u=.;
*</_firmsize_u_>;

*<_empstat_2_>;
*<_empstat_2_note_> Employment status - second job *</_empstat_2_note_>;
*<_empstat_2_note_> empstat_2 brought in from  *</_empstat_2_note_>;
ren empstat_2 empstat_2_sarmd;
gen empstat_2=.;
*</_empstat_2_>;

*<_ocusec_2_>;
*<_ocusec_2_note_> Sector of activity for second job *</_ocusec_2_note_>;
*<_ocusec_2_note_> ocusec_2 brought in from  *</_ocusec_2_note_>;
gen ocusec_2=.;
*</_ocusec_2_>;

*<_industry_orig_2_>;
*<_industry_orig_2_note_> original industry codes for second job *</_industry_orig_2_note_>;
*<_industry_orig_2_note_> industry_orig_2 brought in from  *</_industry_orig_2_note_>;
ren industry_orig_2 industry_orig_2_sarmd;
gen industry_orig_2=.;
*</_industry_orig_2_>;

*<_industrycat10_2_>;
*<_industrycat10_2_note_> 1 digit industry classification for second job *</_industrycat10_2_note_>;
*<_industrycat10_2_note_> industrycat10_2 brought in from  *</_industrycat10_2_note_>;
gen industrycat10_2=.;
*</_industrycat10_2_>;

*<_industrycat4_2_>;
*<_industrycat4_2_note_> 1 digit industry classification (Broad Economic Activities) for second job *</_industrycat4_2_note_>;
*<_industrycat4_2_note_> industrycat4_2 brought in from  *</_industrycat4_2_note_>;
gen industrycat4_2=.;
*</_industrycat4_2_>;

*<_occup_orig_2_>;
*<_occup_orig_2_note_> original occupation code for second job *</_occup_orig_2_note_>;
*<_occup_orig_2_note_> occup_orig_2 brought in from  *</_occup_orig_2_note_>;
gen occup_orig_2=.;
*</_occup_orig_2_>;

*<_occup_2_>;
*<_occup_2_note_> 1 digit occupational classification for second job *</_occup_2_note_>;
*<_occup_2_note_> occup_2 brought in from  *</_occup_2_note_>;
ren occup_2 occup_2_sarmd;
gen occup_2=.;
*</_occup_2_>;

*<_wage_nc_2_>;
*<_wage_nc_2_note_> Last wage payment second job *</_wage_nc_2_note_>;
*<_wage_nc_2_note_> wage_nc_2 brought in from  *</_wage_nc_2_note_>;
gen wage_nc_2=.;
*</_wage_nc_2_>;

*<_unitwage_2_>;
*<_unitwage_2_note_> Last wages time unit second job *</_unitwage_2_note_>;
*<_unitwage_2_note_> unitwage_2 brought in from  *</_unitwage_2_note_>;
ren unitwage_2 unitwage_2_sarmd;
gen unitwage_2=.;
*</_unitwage_2_>;

*<_whours_2_>;
*<_whours_2_note_> Hours of work in last week for the secondary job *</_whours_2_note_>;
*<_whours_2_note_> whours_2 brought in from  *</_whours_2_note_>;
gen whours_2=.;
*</_whours_2_>;

*<_wmonths_2_>;
*<_wmonths_2_note_> Months worked in the last 12 months for the secondary job *</_wmonths_2_note_>;
*<_wmonths_2_note_> wmonths_2 brought in from  *</_wmonths_2_note_>;
gen wmonths_2=.;
*</_wmonths_2_>;

*<_wage_total_2_>;
*<_wage_total_2_note_> Secondary job total wage  *</_wage_total_2_note_>;
*<_wage_total_2_note_> wage_total_2 brought in from  *</_wage_total_2_note_>;
gen wage_total_2=.;
*</_wage_total_2_>;

*<_firmsize_l_2_>;
*<_firmsize_l_2_note_> Firm size (lower bracket) for the secondary job *</_firmsize_l_2_note_>;
*<_firmsize_l_2_note_> firmsize_l_2 brought in from  *</_firmsize_l_2_note_>;
gen firmsize_l_2=.;
*</_firmsize_l_2_>;

*<_firmsize_u_2_>;
*<_firmsize_u_2_note_> Firm size (upper bracket) for the secondary job *</_firmsize_u_2_note_>;
*<_firmsize_u_2_note_> firmsize_u_2 brought in from  *</_firmsize_u_2_note_>;
gen firmsize_u_2=.;
*</_firmsize_u_2_>;

*<_t_hours_others_>;
*<_t_hours_others_note_> Total hours of work in the last 12 months in other jobs excluding the primary and secondary ones *</_t_hours_others_note_>;
*<_t_hours_others_note_> t_hours_others brought in from  *</_t_hours_others_note_>;
gen t_hours_others=.;
*</_t_hours_others_>;

*<_t_wage_nc_others_>;
*<_t_wage_nc_others_note_> Annualized wage in all jobs excluding the primary and secondary ones (excluding tips, bonuses, etc.). *</_t_wage_nc_others_note_>;
*<_t_wage_nc_others_note_> t_wage_nc_others brought in from  *</_t_wage_nc_others_note_>;
gen t_wage_nc_others=.;
*</_t_wage_nc_others_>;

*<_t_wage_others_>;
*<_t_wage_others_note_> Annualized wage (including tips, bonuses, etc.) in all other jobs excluding the primary and secondary ones. *</_t_wage_others_note_>;
*<_t_wage_others_note_> t_wage_others brought in from  *</_t_wage_others_note_>;
gen t_wage_others=.;
*</_t_wage_others_>;

*<_t_hours_total_>;
*<_t_hours_total_note_> Annualized hours worked in all jobs (7-day ref period) *</_t_hours_total_note_>;
*<_t_hours_total_note_> t_hours_total brought in from  *</_t_hours_total_note_>;
gen t_hours_total=.;
*</_t_hours_total_>;

*<_t_wage_nc_total_>;
*<_t_wage_nc_total_note_> Annualized wage in all jobs excl. bonuses, etc. (7-day ref period) *</_t_wage_nc_total_note_>;
*<_t_wage_nc_total_note_> t_wage_nc_total brought in from  *</_t_wage_nc_total_note_>;
gen t_wage_nc_total=.;
*</_t_wage_nc_total_>;

*<_t_wage_total_>;
*<_t_wage_total_note_> Annualized total wage for all jobs (7-day ref period) *</_t_wage_total_note_>;
*<_t_wage_total_note_> t_wage_total brought in from  *</_t_wage_total_note_>;
gen t_wage_total=.;
*</_t_wage_total_>;

*<_minlaborage_year_>;
*<_minlaborage_year_note_> Labor module application age (12-mon ref period) *</_minlaborage_year_note_>;
*<_minlaborage_year_note_> minlaborage_year brought in from  *</_minlaborage_year_note_>;
clonevar minlaborage_year=lb_mod_age;
*</_minlaborage_year_>;

*<_lstatus_year_>;
*<_lstatus_year_note_> Labor status (12-mon ref period) *</_lstatus_year_note_>;
*<_lstatus_year_note_> lstatus_year brought in from SARMD *</_lstatus_year_note_>;
ren lstatus_year lstatus_year_sarmd; 
clonevar lstatus_year = lstatus_year_sarmd;
recode lstatus_year (0 = .);
*</_lstatus_year_>;

*<_nlfreason_year_>;
*<_nlfreason_year_note_> Reason not in the labor force (12-mon ref period) *</_nlfreason_year_note_>;
*<_nlfreason_year_note_> nlfreason_year brought in from *</_nlfreason_year_note_>;
gen nlfreason_year=.;
*</_nlfreason_year_>;

*<_unempldur_l_year_>;
*<_unempldur_l_year_note_> Unemployment duration (months) lower bracket (12-mon ref period) *</_unempldur_l_year_note_>;
*<_unempldur_l_year_note_> unempldur_l_year brought in from  *</_unempldur_l_year_note_>;
gen unempldur_l_year=.;
*</_unempldur_l_year_>;

*<_unempldur_u_year_>;
*<_unempldur_u_year_note_> Unemployment duration (months) upper bracket (12-mon ref period) *</_unempldur_u_year_note_>;
*<_unempldur_u_year_note_> unempldur_u_year brought in from  *</_unempldur_u_year_note_>;
gen unempldur_u_year=.;
*</_unempldur_u_year_>;

*<_empstat_year_>;
*<_empstat_year_note_> Employment status, primary job (12-mon ref period) *</_empstat_year_note_>;
*<_empstat_year_note_> empstat_year brought in from SARMD *</_empstat_year_note_>;
*empstat_year;
*</_empstat_year_>;

*<_ocusec_year_>;
*<_ocusec_year_note_> Sector of activity, primary job (12-mon ref period) *</_ocusec_year_note_>;
*<_ocusec_year_note_> ocusec_year brought in from rawdata *</_ocusec_year_note_>;
gen ocusec_year=.;
replace ocusec_year= 1 if (s4bq06_1==1 | s4bq06_1==2 | s4bq06_1==4 | s4bq06_1==6);
replace ocusec_year= 2 if (s4bq06_1==3 | s4bq06_1==5 | s4bq06_1==8 | s4bq06_1==7);
*</_ocusec_year_>;

*<_industry_orig_year_>;
*<_industry_orig_year_note_> Original industry code, primary job (12-mon ref period) *</_industry_orig_year_note_>;
*<_industry_orig_year_note_> industry_orig_year brought in from rawdata *</_industry_orig_year_note_>;
gen industry_orig_year= s4aq01c_1;
destring industry_orig_year, replace;
replace industry_orig_year=. if lstatus_year!=1;
la val industry_orig_year lblindustry_orig;

recode industry_orig_year (0 3 4 6 7 8 9 12 13 39 42 43 44 46 47 49 53 54 56 57 58 59 76 77 78 79 82 83 84 85 86 87 91 94 96=.); //Incorrect codes are send to missing
*</_industry_orig_year_>;

*<_industrycat10_year_>;
*<_industrycat10_year_note_> 1 digit industry classification, primary job (12-mon ref period) *</_industrycat10_year_note_>;
*<_industrycat10_year_note_> industrycat10_year brought in from rawdata *</_industrycat10_year_note_>;
gen industrycat10_year=industry_orig_year;
recode industrycat10_year (0=.) (1/5=1) (10/14=2) (15/39=3) (40/43=4) (45/49=5) (50/59=6) (60/64=7) (65/74=8) (75=9) (76/99=10) (nonmis=.);
replace industrycat10_year=. if lstatus_year==2| lstatus_year==3;
replace industrycat10_year=. if lstatus_year!=1;
*</_industrycat10_year_>;

*<_industrycat4_year_>;
*<_industrycat4_year_note_> 4-category industry classification primary job (12-mon ref period) *</_industrycat4_year_note_>;
*<_industrycat4_year_note_> industrycat4_year brought in from rawdata *</_industrycat4_year_note_>;
gen industrycat4_year = industrycat10_year;
recode industrycat4_year (1 = 1) (2/5 = 2) (6/9 = 3) (10 = 4);
*</_industrycat4_year_>;

*<_occup_orig_year_>;
*<_occup_orig_year_note_> Original occupational classification, primary job (12-mon ref period) *</_occup_orig_year_note_>;
*<_occup_orig_year_note_> occup_orig_year brought in from rawdata *</_occup_orig_year_note_>;
gen occup_orig_year=s4aq01b_1;
replace occup_orig_year=. if lstatus_year!=1;
la val occup_orig_year lbloccup_orig;
recode occup_orig_year (11 22 25 26 41 46 47 48 57 62 65 67 69 93 96 99 0=.); // Incorrect codes are send to missing
*</_occup_orig_year_>;

*<_occup_year_>;
*<_occup_year_note_> 1 digit occupational classification, primary job (12-mon ref period) *</_occup_year_note_>;
*<_occup_year_note_> occup_year brought in from rawdata *</_occup_year_note_>;
recode s4aq01b_1 (1 = 3) (2 = 2) (3 = 3) (4 = 2) (5 = 3) (6 = 2) (40 = 1) (8 = 2) (9 = 2) (10 = 2) (12 = 2) (13 = 2) (14 = 3) (15 = 2) (16 = 2) (17 = 2) (18 = 2) (19 = 2) (20 = 1) (21 = 1) (30 = 1) (31 = 4) (32 = 4) (33 = 4) (34 = 8) (35 = 8) (50 = 1) (7 = 2) (42 = 3) (39 = 4) (43 = 3) (44 = 3) (86 = 3) (37 = 4) (38 = 4) (36 = 5) (45 = 5) (51 = 5) (52 = 5) (53 = 5) (54 = 5) (49 = 5) (70 = 6) (58 = 5) (59 = 5) (60 = 6) (61 = 6) (63 = 6) (64 = 6) (71 = 7) (72 = 7) (75 = 7) (74 = 8) (76 = 7) (77 = 7) (78 = 7) (79 = 7) (80 = 7) (81 = 7) (82 = 7) (83 = 7) (84 = 7) (85 = 7) (87 = 7) (88 = 7) (89 = 7) (92 = 7) (90 = 8) (91 = 8) (55 = 9) (56 = 9) (11 22 25 26 41 46 47 48 57 62 65 67 69 93 96 99 0 68 73 = .) (nonmis = .), gen(occup_year);

replace occup_year=. if lstatus_year!=1;
la val occup_year lbloccup;
*</_occup_year_>;

*<_wage_nc_year_>;
*<_wage_nc_year_note_> Last wage payment, primary job, excl. bonuses, etc. (12-mon ref period) *</_wage_nc_year_note_>;
*<_wage_nc_year_note_> wage_nc_year brought in from rawdata *</_wage_nc_year_note_>;
gen wage_nc_year = .;
replace wage_nc_year = s4bq02c_1 if s4bq01_1 == 1 & s4bq07_1 == .;
replace wage_nc_year = s4bq07_1 if s4bq01_1 == 2;
replace wage_nc_year = (s4bq02c_1*s4aq03_1)+ s4bq07_1 if s4bq07_1 != . & s4bq02c_1 != .;
*</_wage_nc_year_>;

*<_unitwage_year_>;
*<_unitwage_year_note_> Time unit of last wages payment, primary job (12-mon ref period) *</_unitwage_year_note_>;
*<_unitwage_year_note_> unitwage_year brought in from rawdata *</_unitwage_year_note_>;
gen unitwage_year= .;
replace unitwage_year = 1 if s4bq01_1 == 1 & s4bq07_1 == .;
replace unitwage_year = 5 if s4bq01_1 == 2 & s4bq07_1 != .;
replace unitwage_year = 5 if s4bq07_1 != . & s4bq02c_1 != .;
*</_unitwage_year_>;

*<_whours_year_>;
*<_whours_year_note_> Hours of work in last week, primary job (12-mon ref period) *</_whours_year_note_>;
*<_whours_year_note_> whours_year brought in from rawdata *</_whours_year_note_>;
gen whours_year = s4aq04_1*5 if !missing(s4aq04_1);
*</_whours_year_>;

*<_wmonths_year_>;
*<_wmonths_year_note_> Months worked in the last 12 months, primary job (12-mon ref period) *</_wmonths_year_note_>;
*<_wmonths_year_note_> wmonths_year brought in from rawdata *</_wmonths_year_note_>;
gen wmonths_year= s4aq02_1;
*</_wmonths_year_>;

*<_wage_total_year_>;
*<_wage_total_year_note_> Annualized total wage, primary job (12-mon ref period) *</_wage_total_year_note_>;
*<_wage_total_year_note_> wage_total_year brought in from rawdata *</_wage_total_year_note_>;
gen bonus_daily1 = int(s4bq05b_1*s4aq03_1*s4aq02_1); 
egen bonus_salarydaily1 = rowtotal(bonus_daily1 s4bq09_1), missing;

gen annual_daily1 = int(s4bq02c_1*s4aq03_1*s4aq02_1);
gen annual_salary1 = int(s4bq07_1*wmonths_year);
egen annual_salarydaily1 = rowtotal(annual_daily1 annual_salary1), missing;
egen wage_total_year = rowtotal(bonus_salarydaily1 annual_salarydaily1), missing;

drop bonus_daily1 bonus_salarydaily1 annual_daily1 annual_salary1;
*</_wage_total_year_>;

*<_contract_year_>;
*<_contract_year_note_> Contract (12-mon ref period) *</_contract_year_note_>;
*<_contract_year_note_> contract_year brought in from  *</_contract_year_note_>;
gen contract_year=.;
*</_contract_year_>;

*<_healthins_year_>;
*<_healthins_year_note_> Health insurance (12-mon ref period) *</_healthins_year_note_>;
*<_healthins_year_note_> healthins_year brought in from  *</_healthins_year_note_>;
gen healthins_year=.;
*</_healthins_year_>;

*<_socialsec_year_>;
*<_socialsec_year_note_> Social security (12-mon ref period) *</_socialsec_year_note_>;
*<_socialsec_year_note_> socialsec_year brought in from  *</_socialsec_year_note_>;
gen socialsec_year=.;
*</_socialsec_year_>;

*<_union_year_>;
*<_union_year_note_> Union membership (12-mon ref period) *</_union_year_note_>;
*<_union_year_note_> union_year brought in from  *</_union_year_note_>;
gen union_year=.;
*</_union_year_>;

*<_firmsize_l_year_>;
*<_firmsize_l_year_note_> Firm size (lower bracket) (12-mon ref period) *</_firmsize_l_year_note_>;
*<_firmsize_l_year_note_> firmsize_l_year brought in from  *</_firmsize_l_year_note_>;
gen firmsize_l_year=.;
*</_firmsize_l_year_>;

*<_firmsize_u_year_>;
*<_firmsize_u_year_note_> Firm size (upper bracket) (12-mon ref period) *</_firmsize_u_year_note_>;
*<_firmsize_u_year_note_> firmsize_u_year brought in from  *</_firmsize_u_year_note_>;
gen firmsize_u_year=.;
*</_firmsize_u_year_>;

*<_empstat_2_year_>;
*<_empstat_2_year_note_> Employment status - second job (12-mon ref period) *</_empstat_2_year_note_>;
*<_empstat_2_year_note_> empstat_2_year brought in from rawdata*</_empstat_2_year_note_>;
ren empstat_2_year empstat_2_year_sarmd;
gen empstat_2_year=.;
replace empstat_2_year = 1 if (s4aq07_2==1 | s4aq08_2==1 | s4aq07_2==4 | s4aq08_2==4);
replace empstat_2_year = 3 if (s4aq07_2==3 | s4aq08_2==3);
replace empstat_2_year = 4 if (s4aq07_2==2 | s4aq08_2==2);
replace empstat=. if lstatus_year!=1;
*</_empstat_2_year_>;

*<_ocusec_2_year_>;
*<_ocusec_2_year_note_> Sector of activity for second job (12-mon ref period) *</_ocusec_2_year_note_>;
*<_ocusec_2_year_note_> ocusec_2_year brought in from rawdata*</_ocusec_2_year_note_>;
gen ocusec_2_year=.;
replace ocusec_2_year= 1 if (s4bq06_2==1 | s4bq06_2==2 | s4bq06_2==4 | s4bq06_2==6);
replace ocusec_2_year= 2 if (s4bq06_2==3 | s4bq06_2==5 | s4bq06_2==8 | s4bq06_2==7);
*</_ocusec_2_year_>;

*<_industry_orig_2_year_>;
*<_industry_orig_2_year_note_> original industry codes for second job (12-mon ref period) *</_industry_orig_2_year_note_>;
*<_industry_orig_2_year_note_> industry_orig_2_year brought in from rawdata *</_industry_orig_2_year_note_>;
gen industry_orig_2_year= s4aq01c_2;
destring industry_orig_2_year, replace;
replace industry_orig_2_year=. if lstatus_year!=1;
la val industry_orig_2_year lblindustry_orig;
recode industry_orig_2_year (0 3 4 6 7 8 9 12 13 39 42 43 44 46 47 49 53 54 56 57 58 59 76 77 78 79 82 83 84 85 86 87 91 94 96=.); //Incorrect codes are send to missing;
*</_industry_orig_2_year_>;

*<_industrycat10_2_year_>;
*<_industrycat10_2_year_note_> 1 digit industry classification for second job (12-mon ref period) *</_industrycat10_2_year_note_>;
*<_industrycat10_2_year_note_> industrycat10_2_year brought in from rawdata *</_industrycat10_2_year_note_>;
gen industrycat10_2_year= industry_orig_2_year;
recode industrycat10_2_year (0=.) (1/5=1) (10/14=2) (15/39=3) (40/43=4) (45/49=5) (50/59=6) (60/64=7) (65/74=8) (75=9) (76/99=10) (nonmis=.);
replace industrycat10_2_year=. if lstatus_year==2| lstatus_year==3;
replace industrycat10_2_year=. if lstatus_year!=1;
*</_industrycat10_2_year_>;

*<_industrycat4_2_year_>;
*<_industrycat4_2_year_note_> 4-category industry classification, secondary job (12-mon ref period) *</_industrycat4_2_year_note_>;
*<_industrycat4_2_year_note_> industrycat4_2_year brought in from rawwdata *</_industrycat4_2_year_note_>;
gen industrycat4_2_year= industrycat10_2_year;
recode industrycat4_2_year (1 = 1) (2/5 = 2) (6/9 = 3) (10 = 4);
*</_industrycat4_2_year_>;

*<_occup_orig_2_year_>;
*<_occup_orig_2_year_note_> Original occupational classification, secondary job (12-mon ref period) *</_occup_orig_2_year_note_>;
*<_occup_orig_2_year_note_> occup_orig_2_year brought in from rawdata *</_occup_orig_2_year_note_>;
gen occup_orig_2_year= s4aq01b_2;
replace occup_orig_2_year=. if lstatus_year!=1;
la val occup_orig_2_year lbloccup_orig;
recode occup_orig_2_year (11 22 25 26 41 46 47 48 57 62 65 67 69 93 96 99 0=.); 
*</_occup_orig_2_year_>;

*<_occup_2_year_>;
*<_occup_2_year_note_> 1 digit occupational classification, secondary job (12-mon ref period) *</_occup_2_year_note_>;
*<_occup_2_year_note_> occup_2_year brought in from rawdata *</_occup_2_year_note_>;
recode s4aq01b_2 (1 = 3) (2 = 2) (3 = 3) (4 = 2) (5 = 3) (6 = 2) (40 = 1) (8 = 2) (9 = 2) (10 = 2) (12 = 2) (13 = 2) (14 = 3) (15 = 2) (16 = 2) (17 = 2) (18 = 2) (19 = 2) (20 = 1) (21 = 1) (30 = 1) (31 = 4) (32 = 4) (33 = 4) (34 = 8) (35 = 8) (50 = 1) (7 = 2) (42 = 3) (39 = 4) (43 = 3) (44 = 3) (86 = 3) (37 = 4) (38 = 4) (36 = 5) (45 = 5) (51 = 5) (52 = 5) (53 = 5) (54 = 5) (49 = 5) (70 = 6) (58 = 5) (59 = 5) (60 = 6) (61 = 6) (63 = 6) (64 = 6) (71 = 7) (72 = 7) (75 = 7) (74 = 8) (76 = 7) (77 = 7) (78 = 7) (79 = 7) (80 = 7) (81 = 7) (82 = 7) (83 = 7) (84 = 7) (85 = 7) (87 = 7) (88 = 7) (89 = 7) (92 = 7) (90 = 8) (91 = 8) (55 = 9) (56 = 9) (11 22 25 26 41 46 47 48 57 62 65 67 69 93 96 99 0 68 73 = .) (nonmis = .), gen(occup_2_year);

replace occup_2_year=. if lstatus_year!=1;
la val occup_2_year lbloccup;
*</_occup_2_year_>;

*<_wage_nc_2_year_>;
*<_wage_nc_2_year_note_> last wage payment, secondary job, excl. bonuses, etc. (12-mon ref period) *</_wage_nc_2_year_note_>;
*<_wage_nc_2_year_note_> wage_nc_2_year brought in from rawdata *</_wage_nc_2_year_note_>;
gen wage_nc_2_year=.;
replace wage_nc_2_year = s4bq02c_2 if s4bq01_2 == 1 & s4bq07_2 == .;
replace wage_nc_2_year = s4bq07_2 if s4bq01_2 == 2;
replace wage_nc_2_year = (s4bq02c_2*s4aq03_2)+ s4bq07_2 if s4bq07_2 != . & s4bq02c_2 != .;
*</_wage_nc_2_year_>;

*<_unitwage_2_year_>;
*<_unitwage_2_year_note_> Time unit of last wages payment, secondary job (12-mon ref period) *</_unitwage_2_year_note_>;
*<_unitwage_2_year_note_> unitwage_2_year brought in from rawdata *</_unitwage_2_year_note_>;
gen unitwage_2_year=.;
replace unitwage_2_year = 1 if s4bq01_2 == 1 & s4bq07_2 == .;
replace unitwage_2_year = 5 if s4bq01_2 == 2 & s4bq07_2 != .;
replace unitwage_2_year = 5 if s4bq07_2 != . & s4bq02c_2 != .;
*</_unitwage_2_year_>;

*<_whours_2_year_>;
*<_whours_2_year_note_> Hours of work in last week, secondary job (12-mon ref period) *</_whours_2_year_note_>;
*<_whours_2_year_note_> whours_2_year brought in from rawdata *</_whours_2_year_note_>;
gen whours_2_year= s4aq04_2*5 if !missing(s4aq04_2);
*</_whours_2_year_>;

*<_wmonths_2_year_>;
*<_wmonths_2_year_note_> Months worked in the last 12 months, secondary job (12-mon ref period) *</_wmonths_2_year_note_>;
*<_wmonths_2_year_note_> wmonths_2_year brought in from rawdata  *</_wmonths_2_year_note_>;
gen wmonths_2_year= s4aq02_2;
*</_wmonths_2_year_>;

*<_wage_total_2_year_>;
*<_wage_total_2_year_note_> Annualized total wage, secondary job (12-mon ref period) *</_wage_total_2_year_note_>;
*<_wage_total_2_year_note_> wage_total_2_year brought in from rawdata *</_wage_total_2_year_note_>;
gen bonus_daily2 = int(s4bq05b_2*s4aq03_2*s4aq02_2); 
egen bonus_salarydaily2 = rowtotal(bonus_daily2 s4bq09_2), missing;

gen annual_daily2 = int(s4bq02c_2*s4aq03_2*s4aq02_2);
gen annual_salary2 = int(s4bq07_2*wmonths_2_year);
egen annual_salarydaily2 = rowtotal(annual_daily2 annual_salary2), missing;
egen wage_total_2_year = rowtotal(bonus_salarydaily2 annual_salarydaily2), missing;

drop bonus_daily2 bonus_salarydaily2 annual_daily2 annual_salary2;
*</_wage_total_2_year_>;

*<_firmsize_l_2_year_>;
*<_firmsize_l_2_year_note_> Firm size (lower bracket), secondary job (12-mon ref period) *</_firmsize_l_2_year_note_>;
*<_firmsize_l_2_year_note_> firmsize_l_2_year brought in from  *</_firmsize_l_2_year_note_>;
gen firmsize_l_2_year=.;
*</_firmsize_l_2_year_>;

*<_firmsize_u_2_year_>;
*<_firmsize_u_2_year_note_> Firm size (lower bracket), secondary job (12-mon ref period) *</_firmsize_u_2_year_note_>;
*<_firmsize_u_2_year_note_> firmsize_u_2_year brought in from  *</_firmsize_u_2_year_note_>;
gen firmsize_u_2_year=.;
*</_firmsize_u_2_year_>;

*<_t_hours_total_year_>;
*<_t_hours_total_year_note_> Annualized hours worked in all jobs (12-mon ref period) *</_t_hours_total_year_note_>;
*<_t_hours_total_year_note_> t_hours_total_year brought in from  *</_t_hours_total_year_note_>;
egen t_hours_total_year= rowtotal(t_hours_others_year hrspyr_1 hrspyr_2), missing;
*</_t_hours_total_year_>;

*<_t_wage_nc_total_year_>;
*<_t_wage_nc_total_year_note_> Annualized wage in all jobs excl. bonuses, etc. (12-mon ref period) *</_t_wage_nc_total_year_note_>;
*<_t_wage_nc_total_year_note_> t_wage_nc_total_year brought in from rawdata *</_t_wage_nc_total_year_note_>;
egen t_wage_nc_total_year=rowtotal(t_wage_nc_others_year annual_salarydaily1 annual_salarydaily2), missing;
drop annual_salarydaily1 annual_salarydaily2;
*</_t_wage_nc_total_year_>;

*<_t_wage_total_year_>;
*<_t_wage_total_year_note_> Annualized total wage for all jobs (12-mon ref period) *</_t_wage_total_year_note_>;
*<_t_wage_total_year_note_> t_wage_total_year brought in from rawdata *</_t_wage_total_year_note_>;
egen t_wage_total_year = rowtotal(t_wage_others_year wage_total_2_year wage_total_year), missing;
*</_t_wage_total_year_>;

*<_t_hours_annual_>;
*<_t_hours_annual_note_> Total hours worked in all jobs in the previous 12 months *</_t_hours_annual_note_>;
*<_t_hours_annual_note_> t_hours_annual brought in from *</_t_hours_annual_note_>;
clonevar t_hours_annual = t_hours_total_year;
*</_t_hours_annual_>;

*<_linc_nc_>;
*<_linc_nc_note_> Total annual wage income in all jobs, excl. bonuses, etc. *</_linc_nc_note_>;
*<_linc_nc_note_> linc_nc brought in from  *</_linc_nc_note_>;
clonevar linc_nc = t_wage_nc_total_year;
*</_linc_nc_>;

*<_laborincome_>;
*<_laborincome_note_> Total annual individual labor income in all jobs, incl. bonuses, etc. *</_laborincome_note_>;
*<_laborincome_note_> laborincome brought in from  *</_laborincome_note_>;
clonevar laborincome = t_wage_total_year;
*</_laborincome_>;

*<_Keep variables_>;
keep countrycode year hhid pid weight weighttype age minlaborage lstatus nlfreason unempldur_l unempldur_u empstat ocusec industry_orig industrycat10 industrycat4 occup_orig occup wage_nc unitwage whours wmonths wage_total contract healthins socialsec union firmsize_l firmsize_u empstat_2 ocusec_2 industry_orig_2 industrycat10_2 industrycat4_2 occup_orig_2 occup_2 wage_nc_2 unitwage_2 whours_2 wmonths_2 wage_total_2 firmsize_l_2 firmsize_u_2 t_hours_others t_wage_nc_others t_wage_others t_hours_total t_wage_nc_total t_wage_total minlaborage_year lstatus_year nlfreason_year unempldur_l_year unempldur_u_year empstat_year ocusec_year industry_orig_year industrycat10_year industrycat4_year occup_orig_year occup_year wage_nc_year unitwage_year whours_year wmonths_year wage_total_year contract_year healthins_year socialsec_year union_year firmsize_l_year firmsize_u_year empstat_2_year ocusec_2_year industry_orig_2_year industrycat10_2_year industrycat4_2_year occup_orig_2_year occup_2_year wage_nc_2_year unitwage_2_year whours_2_year wmonths_2_year wage_total_2_year firmsize_l_2_year firmsize_u_2_year t_hours_others_year t_wage_nc_others_year t_wage_others_year t_hours_total_year t_wage_nc_total_year t_wage_total_year njobs t_hours_annual linc_nc laborincome;
order countrycode year hhid pid weight weighttype;
sort hhid pid ;
*</_Keep variables_>;

*<_Save data file_>;
save "$rootdatalib\\`code'\\`yearfolder'\\`gmdfolder'\Data\Harmonized\\`filename'.dta" , replace;
*</_Save data file_>;

exit;
