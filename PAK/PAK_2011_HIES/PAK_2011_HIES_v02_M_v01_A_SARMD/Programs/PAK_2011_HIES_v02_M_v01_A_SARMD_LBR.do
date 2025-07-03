/*----------------------------------------------------------------------------------
  GMD Harmonization - Pakistan Social and Living Standards Measurement Survey (PSLM)
------------------------------------------------------------------------------------
<_Program name_>   	PAK_2011_HIES_v02_M_v01_A_SAMRD_LBR.do	       </_Program name_>
<_Application_>    	STATA 17.0									     <_Application_>
<_Author(s)_>      	Adriana Castillo Castillo           		      </_Author(s)_>
<_Modified_by_>     Leo Tornarolli <tornarolli@gmail.com>		    </_Modified_by_>
<_Date created_>   	12-2021								           </_Date created_>
<_Date modified>   	04-2025						                  </_Date modified_>
------------------------------------------------------------------------------------
<_Country_>        	PAK											        </_Country_>
<_Survey Title_>   	HIES								           </_Survey Title_>
<_Survey Year_>    	2011										    </_Survey Year_>
------------------------------------------------------------------------------------
<_Version Control_>
Date:				04-2025
File:				PAK_2011_HIES_v02_M_v01_A_SAMRD_LBR.do
First version
</_Version Control_>
----------------------------------------------------------------------------------*/

*<_Program setup_>
clear all
set more off

local code         		"PAK"
local cpiver       		"10"
local year         		"2011"
local survey       		"HIES"
local vm           		"02"
local va          		"01"
local type         		"SARMD"
global module       		"LBR"
local yearfolder    		"`code'_`year'_`survey'"
local SARMDfolder    		"`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'"
local filename      		"`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'_${module}"
global output       		"${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'\\Data\Harmonized" 
global shares    		"$rootdofiles\_aux\"
*</_Program setup_>

*<_Datalibweb request_>
use  "${rootdatalib}\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M\Data\Stata\\`yearfolder'_v`vm'_M.dta", clear
gen idh_org = hhcode
gen idp_org = idc
merge 1:1 idh_org idp_org using "${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'\Data\Harmonized\\`yearfolder'_v`vm'_M_v`va'_A_`type'_IND.dta"
*</_Datalibweb request_>

*<_countrycode_>
*<_countrycode_note_> country code *</_countrycode_note_>
*<_countrycode_note_> countrycode brought in from SARMD *</_countrycode_note_>
*replace code=countrycode
*</_countrycode_>

*<_year_>
*<_year_note_> Year *</_year_note_>
*<_year_note_> year brought in from SARMD *</_year_note_>
replace year = `year'
*</_year_>

*<_hhid_>
*<_hhid_note_> Household identifier  *</_hhid_note_>
*<_hhid_note_> hhid brought in from SARMD *</_hhid_note_>
*</_hhid_>

*<_pid_>
*<_pid_note_> Personal identifier  *</_pid_note_>
*<_pid_note_> pid brought in from rawdata *</_pid_note_>
*</_pid_>

*<_weight_>
*<_weight_note_> Household weight *</_weight_note_>
*<_weight_note_> weight brought in from rawdata *</_weight_note_>
*</_weight_>

*<_weighttype_>
*<_weighttype_note_> Weight type (frequency, probability, analytical, importance) *</_weighttype_note_>
*<_weighttype_note_> weighttype brought in from rawdata *</_weighttype_note_>
*</_weighttype_>

*<_age_>
*<_age_note_> Age of individual (continuous) *</_age_note_>
*<_age_note_> age brought in from SARMD *</_age_note_>
*	renam age age 
*</_age_>

*<_minlaborage_>
*<_minlaborage_note_> Labor module application age *</_minlaborage_note_>
*<_minlaborage_note_> minlaborage brought in from SARMD *</_minlaborage_note_>
gen minlaborage = lb_mod_age
*</_minlaborage_>

*<_lstatus_>
*<_lstatus_note_> Labor status *</_lstatus_note_>
*<_lstatus_note_> lstatus brought in from SARMD *</_lstatus_note_>
*gen lstatus=lstatus
*</_lstatus_>

*<_nlfreason_>
*<_nlfreason_note_> Reason not in the labor force *</_nlfreason_note_>
*<_nlfreason_note_> nlfreason brought in from SARMD *</_nlfreason_note_>
*</_nlfreason_>

*<_unempldur_l_>
*<_unempldur_l_note_> Unemployment duration (months) lower bracket *</_unempldur_l_note_>
*<_unempldur_l_note_> unempldur_l brought in from SARMD *</_unempldur_l_note_>
*</_unempldur_l_>

*<_unempldur_u_>
*<_unempldur_u_note_> Unemployment duration (months) upper bracket *</_unempldur_u_note_>
*<_unempldur_u_note_> unempldur_u brought in from SARMD *</_unempldur_u_note_>
*</_unempldur_u_>

*<_empstat_>
*<_empstat_note_> Employment status *</_empstat_note_>
*<_empstat_note_> empstat brought in from SARMD *</_empstat_note_>
*gen empstat=empstat
*</_empstat_>

*<_ocusec_>
*<_ocusec_note_> Sector of activity *</_ocusec_note_>
*<_ocusec_note_> ocusec brought in from SARMD *</_ocusec_note_>
*</_ocusec_>

*<_industry_orig_>
*<_industry_orig_note_> original industry codes *</_industry_orig_note_>
*<_industry_orig_note_> industry_orig brought in from SARMD *</_industry_orig_note_>
*gen industry_orig=industry_orig
*</_industry_orig_>

*<_industrycat10_>
*<_industrycat10_note_> 1 digit industry classification *</_industrycat10_note_>
*<_industrycat10_note_> industrycat10 brought in from SARMD *</_industrycat10_note_>
gen industrycat10 = industry
*</_industrycat10_>

*<_industrycat4_>
*<_industrycat4_note_> 1 digit industry classification (Broad Economic Activities) *</_industrycat4_note_>
*<_industrycat4_note_> industrycat4 brought in from SARMD *</_industrycat4_note_>
recode industrycat10 (1=1) (2/5=2) (6/9=3) (10=4), g(industrycat4)
*</_industrycat4_>

*<_occup_orig_>
gen occup_orig = s1bq04
labmask  occup_orig , val(s1bq04) lbl(lbloccup_orig) decode
replace occup_orig=. if lstatus!=1
la var occup_orig "Original occupation code"
*</_occup_orig_>

*<_occup_>
*<_occup_note_> 1 digit occupational classification *</_occup_note_>
*<_occup_note_> occup brought in from SARMD *</_occup_note_>
cap la de lbloccup 1 "Managers" 2 "Professionals" 3 "Technicians and associate professionals" 4 "Clerical support workers" 5 "Service and sales workers" 6 "Skilled agricultural, forestry and fishery workers" 7 "Craft and related trades workers" 8 "P"
*</_occup_>

*<_wage_nc_>
*<_wage_nc_note_> Last wage payment *</_wage_nc_note_>
*<_wage_nc_note_> wage_nc brought in from SARMD *</_wage_nc_note_>
gen wage_nc = .
*</_wage_nc_>

*<_unitwage_>
*<_unitwage_note_> Last wages time unit *</_unitwage_note_>
*<_unitwage_note_> unitwage brought in from SARMD *</_unitwage_note_>
*gen unitwage=unitwage
*</_unitwage_>

*<_whours_>
*<_whours_note_> Hours of work in last week *</_whours_note_>
*<_whours_note_> whours brought in from SARMD *</_whours_note_>
*</_whours_>

*<_wmonths_>
*<_wmonths_note_> Months worked in the last 12 months *</_wmonths_note_>
*<_wmonths_note_> wmonths brought in from SARMD *</_wmonths_note_>
gen wmonths = .
*</_wmonths_>

*<_wage_total_>
*<_wage_total_note_> Primary job total wage  *</_wage_total_note_>
*<_wage_total_note_> wage_total brought in from SARMD *</_wage_total_note_>
gen wage_total = .
*</_wage_total_>

*<_contract_>
*<_contract_note_> Contract *</_contract_note_>
*<_contract_note_> contract brought in from SARMD *</_contract_note_>
*</_contract_>

*<_healthins_>
*<_healthins_note_> Health insurance *</_healthins_note_>
*<_healthins_note_> healthins brought in from SARMD *</_healthins_note_>
*</_healthins_>

*<_socialsec_>
*<_socialsec_note_> Social security *</_socialsec_note_>
*<_socialsec_note_> socialsec brought in from SARMD *</_socialsec_note_>
*</_socialsec_>

*<_union_>
*<_union_note_> Union membership *</_union_note_>
*<_union_note_> union brought in from SARMD *</_union_note_>
*</_union_>

*<_firmsize_l_>
*<_firmsize_l_note_> Firm size (lower bracket) *</_firmsize_l_note_>
*<_firmsize_l_note_> firmsize_l brought in from SARMD *</_firmsize_l_note_>
*</_firmsize_l_>

*<_firmsize_u_>
*<_firmsize_u_note_> Firm size (upper bracket) *</_firmsize_u_note_>
*<_firmsize_u_note_> firmsize_u brought in from SARMD *</_firmsize_u_note_>
*</_firmsize_u_>

*<_empstat_2_>
*<_empstat_2_note_> Employment status - second job *</_empstat_2_note_>
*<_empstat_2_note_> empstat_2 brought in from SARMD *</_empstat_2_note_>
*</_empstat_2_>

*<_ocusec_2_>
*<_ocusec_2_note_> Sector of activity for second job *</_ocusec_2_note_>
*<_ocusec_2_note_> ocusec_2 brought in from SARMD *</_ocusec_2_note_>
gen ocusec_2 = .
*</_ocusec_2_>

*<_industry_orig_2_>
*<_industry_orig_2_note_> original industry codes for second job *</_industry_orig_2_note_>
*<_industry_orig_2_note_> industry_orig_2 brought in from SARMD *</_industry_orig_2_note_>
*gen industry_orig_2=industry_orig_2
*</_industry_orig_2_>

*<_industrycat10_2_>
*<_industrycat10_2_note_> 1 digit industry classification for second job *</_industrycat10_2_note_>
*<_industrycat10_2_note_> industrycat10_2 brought in from SARMD *</_industrycat10_2_note_>
gen industrycat10_2 = .
*</_industrycat10_2_>

*<_industrycat4_2_>
*<_industrycat4_2_note_> 1 digit industry classification (Broad Economic Activities) for second job *</_industrycat4_2_note_>
*<_industrycat4_2_note_> industrycat4_2 brought in from SARMD *</_industrycat4_2_note_>
gen industrycat4_2 = .
*</_industrycat4_2_>

*<_occup_orig_2_>
*<_occup_orig_2_note_> original occupation code for second job *</_occup_orig_2_note_>
*<_occup_orig_2_note_> occup_orig_2 brought in from SARMD *</_occup_orig_2_note_>
gen occup_orig_2 = .
*</_occup_orig_2_>

*<_occup_2_>
*<_occup_2_note_> 1 digit occupational classification for second job *</_occup_2_note_>
*<_occup_2_note_> occup_2 brought in from SARMD *</_occup_2_note_>
cap la de lbloccup_2 1 "Managers" 2 "Professionals" 3 "Technicians and associate professionals" 4 "Clerical support workers" 5 "Service and sales workers" 6 "Skilled agricultural, forestry and fishery workers" 7 "Craft and related trades workers" 8 ""
*</_occup_2_>

*<_wage_nc_2_>
*<_wage_nc_2_note_> Last wage payment second job *</_wage_nc_2_note_>
*<_wage_nc_2_note_> wage_nc_2 brought in from SARMD *</_wage_nc_2_note_>
gen wage_nc_2 = . 
*</_wage_nc_2_>

*<_unitwage_2_>
*<_unitwage_2_note_> Last wages time unit second job *</_unitwage_2_note_>
*<_unitwage_2_note_> unitwage_2 brought in from SARMD *</_unitwage_2_note_>
*gen unitwage_2=.
*</_unitwage_2_>

*<_whours_2_>
*<_whours_2_note_> Hours of work in last week for the secondary job *</_whours_2_note_>
*<_whours_2_note_> whours_2 brought in from SARMD *</_whours_2_note_>
gen whours_2 = .
*</_whours_2_>

*<_wmonths_2_>
*<_wmonths_2_note_> Months worked in the last 12 months for the secondary job *</_wmonths_2_note_>
*<_wmonths_2_note_> wmonths_2 brought in from SARMD *</_wmonths_2_note_>
gen wmonths_2 = .
*</_wmonths_2_>

*<_wage_total_2_>
*<_wage_total_2_note_> Secondary job total wage  *</_wage_total_2_note_>
*<_wage_total_2_note_> wage_total_2 brought in from SARMD *</_wage_total_2_note_>
gen wage_total_2 = .
*</_wage_total_2_>

*<_firmsize_l_2_>
*<_firmsize_l_2_note_> Firm size (lower bracket) for the secondary job *</_firmsize_l_2_note_>
*<_firmsize_l_2_note_> firmsize_l_2 brought in from SARMD *</_firmsize_l_2_note_>
gen firmsize_l_2 = .
*</_firmsize_l_2_>

*<_firmsize_u_2_>
*<_firmsize_u_2_note_> Firm size (upper bracket) for the secondary job *</_firmsize_u_2_note_>
*<_firmsize_u_2_note_> firmsize_u_2 brought in from SARMD *</_firmsize_u_2_note_>
gen firmsize_u_2 = .
*</_firmsize_u_2_>

*<_t_hours_others_>
*<_t_hours_others_note_> Total hours of work in the last 12 months in other jobs excluding the primary and secondary ones *</_t_hours_others_note_>
*<_t_hours_others_note_> t_hours_others brought in from SARMD *</_t_hours_others_note_>
gen t_hours_others = .
*</_t_hours_others_>

*<_t_wage_nc_others_>
*<_t_wage_nc_others_note_> Annualized wage in all jobs excluding the primary and secondary ones (excluding tips, bonuses, etc.). *</_t_wage_nc_others_note_>
*<_t_wage_nc_others_note_> t_wage_nc_others brought in from SARMD *</_t_wage_nc_others_note_>
gen t_wage_nc_others = .
*</_t_wage_nc_others_>

*<_t_wage_others_>
*<_t_wage_others_note_> Annualized wage (including tips, bonuses, etc.) in all other jobs excluding the primary and secondary ones. *</_t_wage_others_note_>
*<_t_wage_others_note_> t_wage_others brought in from SARMD *</_t_wage_others_note_>
gen t_wage_others = .
*</_t_wage_others_>

*<_t_hours_total_>
*<_t_hours_total_note_> Annualized hours worked in all jobs (7-day ref period) *</_t_hours_total_note_>
*<_t_hours_total_note_> t_hours_total brought in from SARMD *</_t_hours_total_note_>
gen t_hours_total = .
*</_t_hours_total_>

*<_t_wage_nc_total_>
*<_t_wage_nc_total_note_> Annualized wage in all jobs excl. bonuses, etc. (7-day ref period) *</_t_wage_nc_total_note_>
*<_t_wage_nc_total_note_> t_wage_nc_total brought in from SARMD *</_t_wage_nc_total_note_>
gen t_wage_nc_total = .
*</_t_wage_nc_total_>

*<_t_wage_total_>
*<_t_wage_total_note_> Annualized total wage for all jobs (7-day ref period) *</_t_wage_total_note_>
*<_t_wage_total_note_> t_wage_total brought in from SARMD *</_t_wage_total_note_>
gen t_wage_total = .
*</_t_wage_total_>

*<_minlaborage_year_>
*<_minlaborage_year_note_> Labor module application age (12-mon ref period) *</_minlaborage_year_note_>
*<_minlaborage_year_note_> minlaborage_year brought in from SARMD *</_minlaborage_year_note_>
gen minlaborage_year = lb_mod_age
*</_minlaborage_year_>

*<_lstatus_year_>
*<_lstatus_year_note_> Labor status (12-mon ref period) *</_lstatus_year_note_>
*<_lstatus_year_note_> lstatus_year brought in from SARMD *</_lstatus_year_note_>
gen lstatus_year = .
*</_lstatus_year_>

*<_nlfreason_year_>
*<_nlfreason_year_note_> Reason not in the labor force (12-mon ref period) *</_nlfreason_year_note_>
*<_nlfreason_year_note_> nlfreason_year brought in from SARMD *</_nlfreason_year_note_>
gen nlfreason_year = .
*</_nlfreason_year_>

*<_unempldur_l_year_>
*<_unempldur_l_year_note_> Unemployment duration (months) lower bracket (12-mon ref period) *</_unempldur_l_year_note_>
*<_unempldur_l_year_note_> unempldur_l_year brought in from SARMD *</_unempldur_l_year_note_>
gen unempldur_l_year = .
*</_unempldur_l_year_>

*<_unempldur_u_year_>
*<_unempldur_u_year_note_> Unemployment duration (months) upper bracket (12-mon ref period) *</_unempldur_u_year_note_>
*<_unempldur_u_year_note_> unempldur_u_year brought in from SARMD *</_unempldur_u_year_note_>
gen unempldur_u_year = .
*</_unempldur_u_year_>

*<_empstat_year_>
*<_empstat_year_note_> Employment status, primary job (12-mon ref period) *</_empstat_year_note_>
*<_empstat_year_note_> empstat_year brought in from SARMD *</_empstat_year_note_>
*</_empstat_year_>

*<_ocusec_year_>
*<_ocusec_year_note_> Sector of activity, primary job (12-mon ref period) *</_ocusec_year_note_>
*<_ocusec_year_note_> ocusec_year brought in from SARMD *</_ocusec_year_note_>
*</_ocusec_year_>

*<_industry_orig_year_>
*<_industry_orig_year_note_> Original industry code, primary job (12-mon ref period) *</_industry_orig_year_note_>
*<_industry_orig_year_note_> industry_orig_year brought in from SARMD *</_industry_orig_year_note_>
*</_industry_orig_year_>

*<_industrycat10_year_>
*<_industrycat10_year_note_> 1 digit industry classification, primary job (12-mon ref period) *</_industrycat10_year_note_>
*<_industrycat10_year_note_> industrycat10_year brought in from SARMD *</_industrycat10_year_note_>
gen industrycat10_year = .
*</_industrycat10_year_>

*<_industrycat4_year_>
*<_industrycat4_year_note_> 4-category industry classification primary job (12-mon ref period) *</_industrycat4_year_note_>
*<_industrycat4_year_note_> industrycat4_year brought in from SARMD *</_industrycat4_year_note_>
gen industrycat4_year = .
*</_industrycat4_year_>

*<_occup_orig_year_>
*<_occup_orig_year_note_> Original occupational classification, primary job (12-mon ref period) *</_occup_orig_year_note_>
*<_occup_orig_year_note_> occup_orig_year brought in from SARMD *</_occup_orig_year_note_>
gen occup_orig_year = .
*</_occup_orig_year_>

*<_occup_year_>
*<_occup_year_note_> 1 digit occupational classification, primary job (12-mon ref period) *</_occup_year_note_>
*<_occup_year_note_> occup_year brought in from SARMD *</_occup_year_note_>
*</_occup_year_>

*<_wage_nc_year_>
*<_wage_nc_year_note_> Last wage payment, primary job, excl. bonuses, etc. (12-mon ref period) *</_wage_nc_year_note_>
*<_wage_nc_year_note_> wage_nc_year brought in from SARMD *</_wage_nc_year_note_>
gen wage_nc_year = .
*</_wage_nc_year_>

*<_unitwage_year_>
*<_unitwage_year_note_> Time unit of last wages payment, primary job (12-mon ref period) *</_unitwage_year_note_>
*<_unitwage_year_note_> unitwage_year brought in from SARMD *</_unitwage_year_note_>
gen unitwage_year = .
*</_unitwage_year_>

*<_whours_year_>
*<_whours_year_note_> Hours of work in last week, primary job (12-mon ref period) *</_whours_year_note_>
*<_whours_year_note_> whours_year brought in from SARMD *</_whours_year_note_>
gen whours_year = .
*</_whours_year_>

*<_wmonths_year_>
*<_wmonths_year_note_> Months worked in the last 12 months, primary job (12-mon ref period) *</_wmonths_year_note_>
*<_wmonths_year_note_> wmonths_year brought in from SARMD *</_wmonths_year_note_>
gen wmonths_year = .
*</_wmonths_year_>

*<_wage_total_year_>
*<_wage_total_year_note_> Annualized total wage, primary job (12-mon ref period) *</_wage_total_year_note_>
*<_wage_total_year_note_> wage_total_year brought in from SARMD *</_wage_total_year_note_>
gen wage_total_year = .
*</_wage_total_year_>

*<_contract_year_>
*<_contract_year_note_> Contract (12-mon ref period) *</_contract_year_note_>
*<_contract_year_note_> contract_year brought in from SARMD *</_contract_year_note_>
gen contract_year = .
*</_contract_year_>

*<_healthins_year_>
*<_healthins_year_note_> Health insurance (12-mon ref period) *</_healthins_year_note_>
*<_healthins_year_note_> healthins_year brought in from SARMD *</_healthins_year_note_>
gen healthins_year = .
*</_healthins_year_>

*<_socialsec_year_>
*<_socialsec_year_note_> Social security (12-mon ref period) *</_socialsec_year_note_>
*<_socialsec_year_note_> socialsec_year brought in from SARMD *</_socialsec_year_note_>
gen socialsec_year = .
*</_socialsec_year_>

*<_union_year_>
*<_union_year_note_> Union membership (12-mon ref period) *</_union_year_note_>
*<_union_year_note_> union_year brought in from SARMD *</_union_year_note_>
gen union_year = .
*</_union_year_>

*<_firmsize_l_year_>
*<_firmsize_l_year_note_> Firm size (lower bracket) (12-mon ref period) *</_firmsize_l_year_note_>
*<_firmsize_l_year_note_> firmsize_l_year brought in from SARMD *</_firmsize_l_year_note_>
gen firmsize_l_year = .
*</_firmsize_l_year_>

*<_firmsize_u_year_>
*<_firmsize_u_year_note_> Firm size (upper bracket) (12-mon ref period) *</_firmsize_u_year_note_>
*<_firmsize_u_year_note_> firmsize_u_year brought in from SARMD *</_firmsize_u_year_note_>
gen firmsize_u_year = .
*</_firmsize_u_year_>

*<_empstat_2_year_>
*<_empstat_2_year_note_> Employment status - second job (12-mon ref period) *</_empstat_2_year_note_>
*<_empstat_2_year_note_> empstat_2_year brought in from SARMD *</_empstat_2_year_note_>
cap gen empstat_2_year = .
*</_empstat_2_year_>

*<_ocusec_2_year_>
*<_ocusec_2_year_note_> Sector of activity for second job (12-mon ref period) *</_ocusec_2_year_note_>
*<_ocusec_2_year_note_> ocusec_2_year brought in from SARMD *</_ocusec_2_year_note_>
gen ocusec_2_year = .
*</_ocusec_2_year_>

*<_industry_orig_2_year_>
*<_industry_orig_2_year_note_> original industry codes for second job (12-mon ref period) *</_industry_orig_2_year_note_>
*<_industry_orig_2_year_note_> industry_orig_2_year brought in from SARMD *</_industry_orig_2_year_note_>
*</_industry_orig_2_year_>

*<_industrycat10_2_year_>
*<_industrycat10_2_year_note_> 1 digit industry classification for second job (12-mon ref period) *</_industrycat10_2_year_note_>
*<_industrycat10_2_year_note_> industrycat10_2_year brought in from SARMD *</_industrycat10_2_year_note_>
gen industrycat10_2_year = .
*</_industrycat10_2_year_>

*<_industrycat4_2_year_>
*<_industrycat4_2_year_note_> 4-category industry classification, secondary job (12-mon ref period) *</_industrycat4_2_year_note_>
*<_industrycat4_2_year_note_> industrycat4_2_year brought in from SARMD *</_industrycat4_2_year_note_>
gen industrycat4_2_year = .
*</_industrycat4_2_year_>

*<_occup_orig_2_year_>
*<_occup_orig_2_year_note_> Original occupational classification, secondary job (12-mon ref period) *</_occup_orig_2_year_note_>
*<_occup_orig_2_year_note_> occup_orig_2_year brought in from SARMD *</_occup_orig_2_year_note_>
gen occup_orig_2_year = .
*</_occup_orig_2_year_>

*<_occup_2_year_>
*<_occup_2_year_note_> 1 digit occupational classification, secondary job (12-mon ref period) *</_occup_2_year_note_>
*<_occup_2_year_note_> occup_2_year brought in from SARMD *</_occup_2_year_note_>
gen occup_2_year = .
*</_occup_2_year_>

*<_wage_nc_2_year_>
*<_wage_nc_2_year_note_> last wage payment, secondary job, excl. bonuses, etc. (12-mon ref period) *</_wage_nc_2_year_note_>
*<_wage_nc_2_year_note_> wage_nc_2_year brought in from SARMD *</_wage_nc_2_year_note_>
gen wage_nc_2_year = .
*</_wage_nc_2_year_>

*<_unitwage_2_year_>
*<_unitwage_2_year_note_> Time unit of last wages payment, secondary job (12-mon ref period) *</_unitwage_2_year_note_>
*<_unitwage_2_year_note_> unitwage_2_year brought in from SARMD *</_unitwage_2_year_note_>
gen unitwage_2_year = .
*</_unitwage_2_year_>

*<_whours_2_year_>
*<_whours_2_year_note_> Hours of work in last week, secondary job (12-mon ref period) *</_whours_2_year_note_>
*<_whours_2_year_note_> whours_2_year brought in from SARMD *</_whours_2_year_note_>
gen whours_2_year = .
*</_whours_2_year_>

*<_wmonths_2_year_>
*<_wmonths_2_year_note_> Months worked in the last 12 months, secondary job (12-mon ref period) *</_wmonths_2_year_note_>
*<_wmonths_2_year_note_> wmonths_2_year brought in from SARMD *</_wmonths_2_year_note_>
gen wmonths_2_year = .
*</_wmonths_2_year_>

*<_wage_total_2_year_>
*<_wage_total_2_year_note_> Annualized total wage, secondary job (12-mon ref period) *</_wage_total_2_year_note_>
*<_wage_total_2_year_note_> wage_total_2_year brought in from SARMD *</_wage_total_2_year_note_>
gen wage_total_2_year = .
*</_wage_total_2_year_>

*<_firmsize_l_2_year_>
*<_firmsize_l_2_year_note_> Firm size (lower bracket), secondary job (12-mon ref period) *</_firmsize_l_2_year_note_>
*<_firmsize_l_2_year_note_> firmsize_l_2_year brought in from SARMD *</_firmsize_l_2_year_note_>
gen firmsize_l_2_year = .
*</_firmsize_l_2_year_>

*<_firmsize_u_2_year_>
*<_firmsize_u_2_year_note_> Firm size (lower bracket), secondary job (12-mon ref period) *</_firmsize_u_2_year_note_>
*<_firmsize_u_2_year_note_> firmsize_u_2_year brought in from SARMD *</_firmsize_u_2_year_note_>
gen firmsize_u_2_year = .
*</_firmsize_u_2_year_>

*<_t_hours_others_year_>
*<_t_hours_others_year_note_> Annualized hours worked in all but primary and secondary jobs (12-mon ref period) *</_t_hours_others_year_note_>
*<_t_hours_others_year_note_> t_hours_others_year brought in from SARMD *</_t_hours_others_year_note_>
gen t_hours_others_year = .
*</_t_hours_others_year_>

*<_t_wage_nc_others_year_>
*<_t_wage_nc_others_year_note_> Annualized wage in all but primary & secondary jobs excl. bonuses, etc. (12-mon ref period) *</_t_wage_nc_others_year_note_>
*<_t_wage_nc_others_year_note_> t_wage_nc_others_year brought in from SARMD *</_t_wage_nc_others_year_note_>
gen t_wage_nc_others_year = .
*</_t_wage_nc_others_year_>

*<_t_wage_others_year_>
*<_t_wage_others_year_note_> Annualized wage in all but primary and secondary jobs (12-mon ref period) *</_t_wage_others_year_note_>
*<_t_wage_others_year_note_> t_wage_others_year brought in from SARMD *</_t_wage_others_year_note_>
gen t_wage_others_year = .
*</_t_wage_others_year_>

*<_t_hours_total_year_>
*<_t_hours_total_year_note_> Annualized hours worked in all jobs (12-mon ref period) *</_t_hours_total_year_note_>
*<_t_hours_total_year_note_> t_hours_total_year brought in from SARMD *</_t_hours_total_year_note_>
gen t_hours_total_year = .
*</_t_hours_total_year_>

*<_t_wage_nc_total_year_>
*<_t_wage_nc_total_year_note_> Annualized wage in all jobs excl. bonuses, etc. (12-mon ref period) *</_t_wage_nc_total_year_note_>
*<_t_wage_nc_total_year_note_> t_wage_nc_total_year brought in from SARMD *</_t_wage_nc_total_year_note_>
gen t_wage_nc_total_year = .
*</_t_wage_nc_total_year_>

*<_t_wage_total_year_>
*<_t_wage_total_year_note_> Annualized total wage for all jobs (12-mon ref period) *</_t_wage_total_year_note_>
*<_t_wage_total_year_note_> t_wage_total_year brought in from SARMD *</_t_wage_total_year_note_>
gen t_wage_total_year = t_wage_total
*</_t_wage_total_year_>

*<_njobs_>
*<_njobs_note_> Total number of jobs *</_njobs_note_>
*<_njobs_note_> njobs brought in from SARMD *</_njobs_note_>
*</_njobs_>

*<_t_hours_annual_>
*<_t_hours_annual_note_> Total hours worked in all jobs in the previous 12 months *</_t_hours_annual_note_>
*<_t_hours_annual_note_> t_hours_annual brought in from SARMD *</_t_hours_annual_note_>
gen t_hours_annual = .
*</_t_hours_annual_>

*<_linc_nc_>
*<_linc_nc_note_> Total annual wage income in all jobs, excl. bonuses, etc. *</_linc_nc_note_>
*<_linc_nc_note_> linc_nc brought in from SARMD *</_linc_nc_note_>
gen linc_nc = .
*</_linc_nc_>

*<_laborincome_>
*<_laborincome_note_> Total annual individual labor income in all jobs, incl. bonuses, etc. *</_laborincome_note_>
*<_laborincome_note_> laborincome brought in from SARMD *</_laborincome_note_>
gen laborincome = .
*</_laborincome_>


clonevar hhid_orig = idh_org
clonevar pid_orig = idp_org


*<_Save data file_>
quietly do 	"$rootdofiles\_aux\Labels_GMD2.0.do"
save "$output\\`filename'.dta", replace
*</_Save data file_>
