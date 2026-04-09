/*------------------------------------------------------------------------------
					GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   NPL_2010_LSS-III_v01_M_v01_A_GMD_LBR.do	</_Program name_>
<_Application_>    STATA 16.0	<_Application_>
<_Author(s)_>      Navishti Das and Javier Parada	</_Author(s)_>
<_Date created_>   03-03-2019	</_Date created_>
<_Date modified>    3 Mar 2020	</_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        NPL	</_Country_>
<_Survey Title_>   LSS-III	</_Survey Title_>
<_Survey Year_>    2010	</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:	03-03-2019
File:	NPL_2010_LSS-III_v01_M_v01_A_GMD_LBR.do
- First version
</_Version Control_>
------------------------------------------------------------------------------*/

*<_Preparing raw data_>;

tempfile wages
datalibweb, country(NPL) year(2010) type(SARRAW) surveyid(NPL_2010_LSS-III_v01_M) filename(S12.dta)
ren v12_01 id_person
ren v12_01_job id_job
save `wages'

tempfile raw
datalibweb, country(NPL) year(2010) type(SARRAW) surveyid(NPL_2010_LSS-III_v01_M) filename(S10B.dta)
ren v10_02 id_person
ren v10_02_job id_job

merge 1:1 xhpsu xhnum id_person id_job using `wages'
drop _merge 

egen months_worked = anycount(v10_04*), values(1)
replace months_worked = . if missing(v10_04a-v10_04l)

gen total_hours_worked = v10_05b*v10_05a*months_worked

gsort +xhpsu +xhnum +id_person -total_hours_worked

bysort xhpsu xhnum id_person: gen activity_hr = _n

*<_njobs_>;
*<_njobs_note_> Total number of jobs *</_njobs_note_>;
*<_njobs_note_> njobs brought in from  *</_njobs_note_>;
gen one=1
bys xhpsu xhnum id_person: egen njobs_year=total(one)
drop one
*</_njobs_>;

*<_t_hours_others_year_>;
*<_t_hours_others_year_note_> Annualized hours worked in all but primary and secondary jobs (12-mon ref period) *</_t_hours_others_year_note_>;
*<_t_hours_others_year_note_> t_hours_others_year brought in from  *</_t_hours_others_year_note_>;
bysort xhpsu xhnum id_person: egen total_hours_other = total(total_hours_worked) if activity_hr > 2, missing
bysort xhpsu xhnum id_person: gen t_hours_others_year = total_hours_other[3]
drop total_hours_other
*</_t_hours_others_year_>;

*<_t_wage_nc_others_year_>;
*<_t_wage_nc_others_year_note_> Annualized wage in all but primary & secondary jobs excl. bonuses, etc. (12-mon ref period) *</_t_wage_nc_others_year_note_>;
*<_t_wage_nc_others_year_note_> t_wage_nc_others_year brought in from  *</_t_wage_nc_others_year_note_>;

* Non agri long wages annualized
gen annual_basepay = v12_15a*months_worked
bysort xhpsu xhnum id_person: egen annual_longnonag_others = total(annual_basepay) if activity_hr > 2, missing

* Agri long wages
bysort xhpsu xhnum id_person: egen annual_longag_others = total(v12_08) if activity_hr > 2, missing

* Paid by day
gen annual_daily = v12_04*v10_05a*months_worked
bysort xhpsu xhnum id_person: egen annual_daily_others = total(annual_daily) if activity_hr > 2, missing

egen t_wage_nc_others_year= rowtotal(annual_longnonag_others annual_longag_others annual_daily_others), missing

bysort xhpsu xhnum id_person: replace t_wage_nc_others_year = t_wage_nc_others_year[3]

notes t_wage_nc_others_year: Wages for those with contract/piece-rate payments are not included as it is reported inclusive of in-kind(bonus) pay. Recorded in t_wage_others_year.
*</_t_wage_nc_others_year_>;

*<_t_wage_others_year_>;
*<_t_wage_others_year_note_> Annualized wage in all but primary and secondary jobs (12-mon ref period) *</_t_wage_others_year_note_>;
*<_t_wage_others_year_note_> t_wage_others_year brought in from  *</_t_wage_others_year_note_>;

* Non agri long bonus
gen transport_annual = v12_15b*months_worked
egen nonaglong_bonus = rowtotal(transport_annual v12_15c v12_15d v12_15e), missing
egen nonaglong_bonuswages = rowtotal(nonaglong_bonus annual_longnonag_others), missing
bysort xhpsu xhnum id_person: egen t_nonaglong_others = total(nonaglong_bonuswages) if activity_hr > 2, missing 

* Agri long bonus
egen aglong_bonuswages= rowtotal(v12_10b annual_longag_others), missing
bysort xhpsu xhnum id_person: egen t_aglong_others = total(aglong_bonuswages) if activity_hr > 2, missing 

* Paid by day
egen daily_bonuswages= rowtotal(v12_06b annual_daily_others), missing
bysort xhpsu xhnum id_person: egen t_daily_others = total(daily_bonuswages) if activity_hr > 2, missing 

* Contract/piece rate
bysort xhpsu xhnum id_person: egen t_piecerate_others = total(v12_21) if activity_hr > 2, missing 


egen t_wage_others_year = rowtotal(t_nonaglong_others t_aglong_others t_daily_others t_piecerate_others), missing

bysort xhpsu xhnum id_person: replace t_wage_others_year = t_wage_others_year[3]
*</_t_wage_others_year_>;

*<_t_hours_total_year_>;
*<_t_hours_total_year_note_> Annualized hours worked in all jobs (12-mon ref period) *</_t_hours_total_year_note_>;
*<_t_hours_total_year_note_> t_hours_total_year brought in from  *</_t_hours_total_year_note_>;
bysort xhpsu xhnum id_person: egen t_hours_total_year= total(total_hours_worked), missing
*</_t_hours_total_year_>;

* reshaping
keep if inlist(activity_hr,1,2)

ds xhpsu xhnum id_person activity_hr njobs t_hours_others_year t_wage_nc_others_year t_wage_others_year t_hours_total_year , not

reshape wide `r(varlist)', i(xhpsu xhnum id_person) j(activity_hr)

egen str idh= concat(xhpsu xhnum), punct(-)
egen str idp= concat(idh id_person), punct(-)

save `raw'
*</_Preparing raw data_>;


*<_Program setup_>;
#delimit ;
clear all;
set more off;

local code         "NPL";
local year         "2010";
local survey       "LSS-III";
local vm           "01";
local va           "04";
local type         "SARMD";
local yearfolder   "NPL_2010_LSS-III";
local gmdfolder    "NPL_2010_LSS-III_v01_M_v01_A_GMD";
local filename     "NPL_2010_LSS-III_v01_M_v01_A_GMD_LBR";
*</_Program setup_>;

*<_Folder creation_>;
cap mkdir "$rootdatalib\GMD";
cap mkdir "$rootdatalib\GMD\\`code'";
cap mkdir "$rootdatalib\GMD\\`code'\\`yearfolder'";
cap mkdir "$rootdatalib\GMD\\`code'\\`yearfolder'\\`gmdfolder'";
cap mkdir "$rootdatalib\GMD\\`code'\\`yearfolder'\\`gmdfolder'\Data";
cap mkdir "$rootdatalib\GMD\\`code'\\`yearfolder'\\`gmdfolder'\Data\Harmonized";
*</_Folder creation_>;

*<_Datalibweb request_>;
#delimit cr
datalibweb, country(`code') year(`year') type(`type') survey(`survey') vermast(`vm') veralt(`va') mod(IND) clear 
#delimit ;
*</_Datalibweb request_>;

*<_Merge_>;
merge 1:1 idp using `raw';
drop _merge;
*</_Merge_>;

*<_countrycode_>;
*<_countrycode_note_> country code *</_countrycode_note_>;
*<_countrycode_note_> countrycode brought in from SARMD *</_countrycode_note_>;
*countrycode;
*</_countrycode_>;

*<_year_>;
*<_year_note_> Year *</_year_note_>;
*<_year_note_> year brought in from SARMD *</_year_note_>;
*year;
*</_year_>;

*<_hhid_>;
*<_hhid_note_> Household identifier  *</_hhid_note_>;
*<_hhid_note_> hhid brought in from SARMD *</_hhid_note_>;
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
*<_minlaborage_note_> minlaborage brought in from *</_minlaborage_note_>;
gen minlaborage = .;
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
*<_empstat_note_> empstat brought in from *</_empstat_note_>;
replace empstat = .;
*</_empstat_>;

*<_ocusec_>;
*<_ocusec_note_> Sector of activity *</_ocusec_note_>;
*<_ocusec_note_> ocusec brought in from  *</_ocusec_note_>;
gen ocusec = .;
*</_ocusec_>;

*<_industry_orig_>;
*<_industry_orig_note_> original industry codes *</_industry_orig_note_>;
*<_industry_orig_note_> industry_orig brought in from  *</_industry_orig_note_>;
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
replace occup_orig = .;
*</_occup_orig_>;

*<_occup_>;
*<_occup_note_> 1 digit occupational classification *</_occup_note_>;
*<_occup_note_> occup brought in from  *</_occup_note_>;
replace occup = .;
*</_occup_>;

*<_wage_nc_>;
*<_wage_nc_note_> Last wage payment *</_wage_nc_note_>;
*<_wage_nc_note_> wage_nc brought in from  *</_wage_nc_note_>;
gen wage_nc=.;
*</_wage_nc_>;

*<_unitwage_>;
*<_unitwage_note_> Last wages time unit *</_unitwage_note_>;
*<_unitwage_note_> unitwage brought in from  *</_unitwage_note_>;
replace unitwage = . ;
*</_unitwage_>;

*<_whours_>;
*<_whours_note_> Hours of work in last week *</_whours_note_>;
*<_whours_note_> whours brought in from *</_whours_note_>;
replace whours = .;
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
replace firmsize_l = .;
*</_firmsize_l_>;

*<_firmsize_u_>;
*<_firmsize_u_note_> Firm size (upper bracket) *</_firmsize_u_note_>;
*<_firmsize_u_note_> firmsize_u brought in from  *</_firmsize_u_note_>;
replace firmsize_u = .;
*</_firmsize_u_>;

*<_empstat_2_>;
*<_empstat_2_note_> Employment status - second job *</_empstat_2_note_>;
*<_empstat_2_note_> empstat_2 brought in from  *</_empstat_2_note_>;
replace empstat_2 = .;
*</_empstat_2_>;

*<_ocusec_2_>;
*<_ocusec_2_note_> Sector of activity for second job *</_ocusec_2_note_>;
*<_ocusec_2_note_> ocusec_2 brought in from  *</_ocusec_2_note_>;
gen ocusec_2=.;
*</_ocusec_2_>;

*<_industry_orig_2_>;
*<_industry_orig_2_note_> original industry codes for second job *</_industry_orig_2_note_>;
*<_industry_orig_2_note_> industry_orig_2 brought in from  *</_industry_orig_2_note_>;
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
replace occup_2 = .;
*</_occup_2_>;

*<_wage_nc_2_>;
*<_wage_nc_2_note_> Last wage payment second job *</_wage_nc_2_note_>;
*<_wage_nc_2_note_> wage_nc_2 brought in from  *</_wage_nc_2_note_>;
gen wage_nc_2=.;
*</_wage_nc_2_>;

*<_unitwage_2_>;
*<_unitwage_2_note_> Last wages time unit second job *</_unitwage_2_note_>;
*<_unitwage_2_note_> unitwage_2 brought in from  *</_unitwage_2_note_>;
replace unitwage_2=.;
*</_unitwage_2_>;

*<_whours_2_>;
*<_whours_2_note_> Hours of work in last week for the secondary job *</_whours_2_note_>;
*<_whours_2_note_> whours_2 brought in from rawdata *</_whours_2_note_>;
gen whours_2= .;
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
*<_minlaborage_year_note_> minlaborage_year brought in from SARMD *</_minlaborage_year_note_>;
clonevar minlaborage_year= lb_mod_age;
*</_minlaborage_year_>;

*<_lstatus_year_>;
*<_lstatus_year_note_> Labor status (12-mon ref period) *</_lstatus_year_note_>;
*<_lstatus_year_note_> lstatus_year brought in from SARMD *</_lstatus_year_note_>;
ren lstatus_year lstatus_year_sarmd;
clonevar lstatus_year = lstatus;
*</_lstatus_year_>;

*<_nlfreason_year_>;
*<_nlfreason_year_note_> Reason not in the labor force (12-mon ref period) *</_nlfreason_year_note_>;
*<_nlfreason_year_note_> nlfreason_year brought in from  *</_nlfreason_year_note_>;
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
*<_empstat_year_note_> empstat_year brought in from rawdata *</_empstat_year_note_>;
drop empstat_year;
gen empstat_year = .;
replace empstat_year=1 if v10_071==1 | v10_071==2;
replace empstat_year=4 if v10_071==3 | v10_071==4;
replace empstat=. if lstatus_year!=1;
*</_empstat_year_>;

*<_ocusec_year_>;
*<_ocusec_year_note_> Sector of activity, primary job (12-mon ref period) *</_ocusec_year_note_>;
*<_ocusec_year_note_> ocusec_year brought in from  *</_ocusec_year_note_>;
gen ocusec_year=.;
*</_ocusec_year_>;

*<_industry_orig_year_>;
*<_industry_orig_year_note_> Original industry code, primary job (12-mon ref period) *</_industry_orig_year_note_>;
*<_industry_orig_year_note_> industry_orig_year brought in from rawdata *</_industry_orig_year_note_>;
gen industry_orig_year= v12_021;
*</_industry_orig_year_>;

*<_industrycat10_year_>;
*<_industrycat10_year_note_> 1 digit industry classification, primary job (12-mon ref period) *</_industrycat10_year_note_>;
*<_industrycat10_year_note_> industrycat10_year brought in from rawdata *</_industrycat10_year_note_>;
gen industrycat10_year= industry_orig_year;
	recode industrycat10_year(1 2 5 =1) (10 11 12 13 14=2);
	forval i= 15/37 {;
	recode industrycat10_year (`i'=3);
	};
	recode industrycat10_year (40 41 90 =4)(45=5)(50 51 52 55 =6);
	recode industrycat10_year (60 61 62 63 64 =7);
	recode industrycat10_year (65 66 67 70 71 72 73 74=8) (75 =9);
	recode industrycat10_year ( 80 85 90 91 92 93 95 99=10);
*</_industrycat10_year_>;

*<_industrycat4_year_>;
*<_industrycat4_year_note_> 4-category industry classification primary job (12-mon ref period) *</_industrycat4_year_note_>;
*<_industrycat4_year_note_> industrycat4_year brought in from  *</_industrycat4_year_note_>;
gen industrycat4_year= industrycat10_year;
	recode industrycat4_year (2/5=2) (6/9=3) (10=4);
*</_industrycat4_year_>;

*<_occup_orig_year_>;
*<_occup_orig_year_note_> Original occupational classification, primary job (12-mon ref period) *</_occup_orig_year_note_>;
*<_occup_orig_year_note_> occup_orig_year brought in from rawdata *</_occup_orig_year_note_>;
gen occup_orig_year= v10_031;
*</_occup_orig_year_>;

*<_occup_year_>;
*<_occup_year_note_> 1 digit occupational classification, primary job (12-mon ref period) *</_occup_year_note_>;
*<_occup_year_note_> occup_year brought in from rawdata *</_occup_year_note_>;
gen occup_year=.;
	replace occup_year=1 if v10_031>=111 & v10_031<=131;
	replace occup_year=2 if v10_031>=211 & v10_031<=246;
	replace occup_year=3 if v10_031>=311 & v10_031<=348;
	replace occup_year=4 if v10_031>=411 & v10_031<=422;
	replace occup_year=5 if v10_031>=511 & v10_031<=523;
	replace occup_year=6 if v10_031>=611 & v10_031<=621;
	replace occup_year=7 if v10_031>=711 & v10_031<=744;
	replace occup_year=8 if v10_031>=811 & v10_031<=833;
	replace occup_year=9 if v10_031>=911 & v10_031<=933;
	replace occup_year=10 if v10_031==11;
	replace occup_year=99 if v10_031==999;
	replace occup_year=. if lstatus!=1;
*</_occup_year_>;

*<_wage_nc_year_>;
*<_wage_nc_year_note_> Last wage payment, primary job, excl. bonuses, etc. (12-mon ref period) *</_wage_nc_year_note_>;
*<_wage_nc_year_note_> wage_nc_year brought in from rawdata *</_wage_nc_year_note_>;
gen wage_nc_year=.;
	replace wage_nc_year= v12_15a1 if v12_15a1!=.;
	replace wage_nc_year=v12_081 if v12_081!=.;
	replace wage_nc_year=v12_041 if  v12_041!=.;
	replace wage_nc_year=0 if empstat_year==2;
	replace wage_nc_year=. if lstatus_year!=1;
notes wage_nc_year: Wages for those with contract/piece-rate payments are not included as it is reported inclusive of in-kind(bonus) pay. Recorded in wage_total_year.
*</_wage_nc_year_>;

*<_unitwage_year_>;
*<_unitwage_year_note_> Time unit of last wages payment, primary job (12-mon ref period) *</_unitwage_year_note_>;
*<_unitwage_year_note_> unitwage_year brought in from rawdata *</_unitwage_year_note_>;
gen unitwage_year=.;
	replace unitwage_year=1 if v12_041!=.;
	replace unitwage_year=5 if v12_15a1!=.;
	replace unitwage_year=8 if v12_081!=.;
	replace unitwage_year=8 if v12_211!=.;
	replace unitwage_year=. if lstatus!=1;
*</_unitwage_year_>;

*<_whours_year_>;
*<_whours_year_note_> Hours of work in last week, primary job (12-mon ref period) *</_whours_year_note_>;
*<_whours_year_note_> whours_year brought in from rawdata *</_whours_year_note_>;
gen whours_year= v10_06h1;
*</_whours_year_>;

*<_wmonths_year_>;
*<_wmonths_year_note_> Months worked in the last 12 months, primary job (12-mon ref period) *</_wmonths_year_note_>;
*<_wmonths_year_note_> wmonths_year brought in from rawdata *</_wmonths_year_note_>;
egen wmonths_year = anycount(v10_04*1),values(1);
replace wmonths_year = . if missing(v10_04a1-v10_04l1);
*</_wmonths_year_>;

*<_wage_total_year_>;
*<_wage_total_year_note_> Annualized total wage, primary job (12-mon ref period) *</_wage_total_year_note_>;
*<_wage_total_year_note_> wage_total_year brought in from  *</_wage_total_year_note_>;
gen wage_total_year=.;
gen annualized_dailywage = v12_041*v10_05a1*wmonths_year;
egen annual_totaldaily = rowtotal(annualized_dailywage v12_06b1), missing;
replace wage_total_year = annual_totaldaily if v12_031 == 1;

egen annualized_agrilong = rowtotal(v12_081 v12_10b1), missing;
replace wage_total_year = annualized_agrilong if v12_031 == 2 & v12_071 == 1;

egen monthly_longnonagri = rowtotal(v12_15a1 v12_15b1), missing;
gen annual_longnonagri = monthly_longnonagri*wmonths_year if !missing(monthly_longnonagri, wmonths_year);
egen annual_totallongnonagri = rowtotal(annual_longnonagri v12_15c1 v12_15d1 v12_15e1), missing;
replace wage_total_year = annual_totallongnonagri if v12_031 == 2 & v12_071 == 2;

replace wage_total_year = v12_211 if v12_031 == 3;

drop annualized_dailywage annual_totaldaily annualized_agrilong monthly_longnonagri annual_longnonagri annual_totallongnonagri;
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
*<_empstat_2_year_note_> empstat_2_year brought in from  *</_empstat_2_year_note_>;
*empstat_2_year;
*</_empstat_2_year_>;

*<_ocusec_2_year_>;
*<_ocusec_2_year_note_> Sector of activity for second job (12-mon ref period) *</_ocusec_2_year_note_>;
*<_ocusec_2_year_note_> ocusec_2_year brought in from  *</_ocusec_2_year_note_>;
gen ocusec_2_year=.;
*</_ocusec_2_year_>;

*<_industry_orig_2_year_>;
*<_industry_orig_2_year_note_> original industry codes for second job (12-mon ref period) *</_industry_orig_2_year_note_>;
*<_industry_orig_2_year_note_> industry_orig_2_year brought in from  *</_industry_orig_2_year_note_>;
gen industry_orig_2_year= v12_022;
*</_industry_orig_2_year_>;

*<_industrycat10_2_year_>;
*<_industrycat10_2_year_note_> 1 digit industry classification for second job (12-mon ref period) *</_industrycat10_2_year_note_>;
*<_industrycat10_2_year_note_> industrycat10_2_year brought in from  *</_industrycat10_2_year_note_>;
gen industrycat10_2_year= industry_orig_2_year;
	recode industrycat10_2_year(1 2 5 =1) (10 11 12 13 14=2);
	forval i= 15/37 {;
	recode industrycat10_2_year (`i'=3);
	};
	recode industrycat10_2_year (40 41 90 =4)(45=5)(50 51 52 55 =6);
	recode industrycat10_2_year (60 61 62 63 64 =7);
	recode industrycat10_2_year (65 66 67 70 71 72 73 74=8) (75 =9);
	recode industrycat10_2_year ( 80 85 90 91 92 93 95 99=10);
*</_industrycat10_2_year_>;

*<_industrycat4_2_year_>;
*<_industrycat4_2_year_note_> 4-category industry classification, secondary job (12-mon ref period) *</_industrycat4_2_year_note_>;
*<_industrycat4_2_year_note_> industrycat4_2_year brought in from  *</_industrycat4_2_year_note_>;
gen industrycat4_2_year= industrycat10_2_year;
	recode industrycat4_2_year (2/5=2) (6/9=3) (10=4);
*</_industrycat4_2_year_>;

*<_occup_orig_2_year_>;
*<_occup_orig_2_year_note_> Original occupational classification, secondary job (12-mon ref period) *</_occup_orig_2_year_note_>;
*<_occup_orig_2_year_note_> occup_orig_2_year brought in from  *</_occup_orig_2_year_note_>;
gen occup_orig_2_year= v10_032;
*</_occup_orig_2_year_>;

*<_occup_2_year_>;
*<_occup_2_year_note_> 1 digit occupational classification, secondary job (12-mon ref period) *</_occup_2_year_note_>;
*<_occup_2_year_note_> occup_2_year brought in from  *</_occup_2_year_note_>;
gen occup_2_year=.;
	replace occup_2_year=1 if v10_032>=111 & v10_032<=131;
	replace occup_2_year=2 if v10_032>=211 & v10_032<=246;
	replace occup_2_year=3 if v10_032>=311 & v10_032<=348;
	replace occup_2_year=4 if v10_032>=411 & v10_032<=422;
	replace occup_2_year=5 if v10_032>=511 & v10_032<=523;
	replace occup_2_year=6 if v10_032>=611 & v10_032<=621;
	replace occup_2_year=7 if v10_032>=711 & v10_032<=744;
	replace occup_2_year=8 if v10_032>=811 & v10_032<=833;
	replace occup_2_year=9 if v10_032>=911 & v10_032<=933;
	replace occup_2_year=10 if v10_032==11;
	replace occup_2_year=99 if v10_032==999;
	replace occup_2_year=. if lstatus_year!=1;
*</_occup_2_year_>;

*<_wage_nc_2_year_>;
*<_wage_nc_2_year_note_> last wage payment, secondary job, excl. bonuses, etc. (12-mon ref period) *</_wage_nc_2_year_note_>;
*<_wage_nc_2_year_note_> wage_nc_2_year brought in from  *</_wage_nc_2_year_note_>;
gen wage_nc_2_year=.;
	replace wage_nc_2_year= v12_15a2 if v12_15a2!=.;
	replace wage_nc_2_year=v12_082 if v12_082!=.;
	replace wage_nc_2_year=v12_042 if  v12_042!=.;
	replace wage_nc_2_year=0 if empstat_2_year==2;
	replace wage_nc_2_year=. if lstatus_year!=1;
notes wage_nc_2_year: Wages for those with contract/piece-rate payments are not included as it is reported inclusive of in-kind(bonus) pay. Recorded in wage_total_2_year.
*</_wage_nc_2_year_>;

*<_unitwage_2_year_>;
*<_unitwage_2_year_note_> Time unit of last wages payment, secondary job (12-mon ref period) *</_unitwage_2_year_note_>;
*<_unitwage_2_year_note_> unitwage_2_year brought in from  *</_unitwage_2_year_note_>;
gen unitwage_2_year=.;
	replace unitwage_2_year=1 if v12_042!=.;
	replace unitwage_2_year=5 if v12_15a2!=.;
	replace unitwage_2_year=8 if v12_082!=.;
	replace unitwage_2_year=8 if v12_212!=.;
	replace unitwage_2_year=. if lstatus!=1;
*</_unitwage_2_year_>;

*<_whours_2_year_>;
*<_whours_2_year_note_> Hours of work in last week, secondary job (12-mon ref period) *</_whours_2_year_note_>;
*<_whours_2_year_note_> whours_2_year brought in from  *</_whours_2_year_note_>;
gen whours_2_year= v10_06h2;
*</_whours_2_year_>;

*<_wmonths_2_year_>;
*<_wmonths_2_year_note_> Months worked in the last 12 months, secondary job (12-mon ref period) *</_wmonths_2_year_note_>;
*<_wmonths_2_year_note_> wmonths_2_year brought in from  *</_wmonths_2_year_note_>;
egen wmonths_2_year = anycount(v10_04*2),values(1);
replace wmonths_2_year = . if missing(v10_04a2-v10_04l2);
*</_wmonths_2_year_>;

*<_wage_total_2_year_>;
*<_wage_total_2_year_note_> Annualized total wage, secondary job (12-mon ref period) *</_wage_total_2_year_note_>;
*<_wage_total_2_year_note_> wage_total_2_year brought in from  *</_wage_total_2_year_note_>;
gen wage_total_2_year=.;
gen annualized_dailywage = v12_042*v10_05a2*wmonths_2_year;
egen annual_totaldaily = rowtotal(annualized_dailywage v12_06b2), missing;
replace wage_total_2_year = annual_totaldaily if v12_032 == 1;

egen annualized_agrilong = rowtotal(v12_082 v12_10b2), missing;
replace wage_total_2_year = annualized_agrilong if v12_032 == 2 & v12_072 == 1;

egen monthly_longnonagri = rowtotal(v12_15a2 v12_15b2), missing;
gen annual_longnonagri = monthly_longnonagri*wmonths_2_year if !missing(monthly_longnonagri, wmonths_2_year);
egen annual_totallongnonagri = rowtotal(annual_longnonagri v12_15c2 v12_15d2 v12_15e2), missing;
replace wage_total_2_year = annual_totallongnonagri if v12_032 == 2 & v12_072 == 2;

replace wage_total_2_year = v12_212 if v12_032 == 3;

drop annualized_dailywage annual_totaldaily annualized_agrilong monthly_longnonagri annual_longnonagri annual_totallongnonagri;
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

*<_t_wage_nc_total_year_>;
*<_t_wage_nc_total_year_note_> Annualized wage in all jobs excl. bonuses, etc. (12-mon ref period) *</_t_wage_nc_total_year_note_>;
*<_t_wage_nc_total_year_note_> t_wage_nc_total_year brought in from  *</_t_wage_nc_total_year_note_>;
egen t_wage_nc_total_year= rowtotal (wage_nc_year wage_nc_2_year t_wage_nc_others_year), missing;
*</_t_wage_nc_total_year_>;

*<_t_wage_total_year_>;
*<_t_wage_total_year_note_> Annualized total wage for all jobs (12-mon ref period) *</_t_wage_total_year_note_>;
*<_t_wage_total_year_note_> t_wage_total_year brought in from  *</_t_wage_total_year_note_>;
egen t_wage_total_year= rowtotal (wage_total_year wage_total_2_year t_wage_others_year), missing;
*</_t_wage_total_year_>;

*<_t_hours_annual_>;
*<_t_hours_annual_note_> Total hours worked in all jobs in the previous 12 months *</_t_hours_annual_note_>;
*<_t_hours_annual_note_> t_hours_annual brought in from  *</_t_hours_annual_note_>;
gen t_hours_annual= t_hours_total_year;
*</_t_hours_annual_>;

*<_linc_nc_>;
*<_linc_nc_note_> Total annual wage income in all jobs, excl. bonuses, etc. *</_linc_nc_note_>;
*<_linc_nc_note_> linc_nc brought in from  *</_linc_nc_note_>;
gen linc_nc= t_wage_nc_total_year;
*</_linc_nc_>;

*<_laborincome_>;
*<_laborincome_note_> Total annual individual labor income in all jobs, incl. bonuses, etc. *</_laborincome_note_>;
*<_laborincome_note_> laborincome brought in from  *</_laborincome_note_>;
gen laborincome= t_wage_total_year;
*</_laborincome_>;

*<_Keep variables_>;
keep countrycode year hhid pid weight weighttype age minlaborage lstatus nlfreason unempldur_l unempldur_u empstat ocusec industry_orig industrycat10 industrycat4 occup_orig occup wage_nc unitwage whours wmonths wage_total contract healthins socialsec union firmsize_l firmsize_u empstat_2 ocusec_2 industry_orig_2 industrycat10_2 industrycat4_2 occup_orig_2 occup_2 wage_nc_2 unitwage_2 whours_2 wmonths_2 wage_total_2 firmsize_l_2 firmsize_u_2 t_hours_others t_wage_nc_others t_wage_others t_hours_total t_wage_nc_total t_wage_total minlaborage_year lstatus_year nlfreason_year unempldur_l_year unempldur_u_year empstat_year ocusec_year industry_orig_year industrycat10_year industrycat4_year occup_orig_year occup_year wage_nc_year unitwage_year whours_year wmonths_year wage_total_year contract_year healthins_year socialsec_year union_year firmsize_l_year firmsize_u_year empstat_2_year ocusec_2_year industry_orig_2_year industrycat10_2_year industrycat4_2_year occup_orig_2_year occup_2_year wage_nc_2_year unitwage_2_year whours_2_year wmonths_2_year wage_total_2_year firmsize_l_2_year firmsize_u_2_year t_hours_others_year t_wage_nc_others_year t_wage_others_year t_hours_total_year t_wage_nc_total_year t_wage_total_year njobs t_hours_annual linc_nc laborincome;
order countrycode year hhid pid weight weighttype;
sort hhid pid ;
*</_Keep variables_>;

*<_Save data file_>;
save "$rootdatalib\GMD\\`code'\\`yearfolder'\\`gmdfolder'\Data\Harmonized\\`filename'.dta" , replace;
*</_Save data file_>;
