/*----------------------------------------------------------------------------------
  SARMD Harmonization
------------------------------------------------------------------------------------
<_Program name_>   		IND_2022_HCES_v04_M_v01_SARMD_LBR.do	   	   </_Program name_>
<_Application_>    		STATA 17.0									 <_Application_>
<_Author(s)_>      		Leo Tornarolli <tornarolli@gmail.com>		  </_Author(s)_>
<_Date created_>   		02-2026									   </_Date created_>
<_Date modified>    	February 2026						 	  </_Date modified_>
------------------------------------------------------------------------------------
<_Country_>        		IND											    </_Country_>
<_Survey Title_>   		HCES									   </_Survey Title_>
<_Survey Year_>    		2022-2023									</_Survey Year_>
------------------------------------------------------------------------------------
<_Version Control_>
Date:					02-2026
File:					IND_2022_HCES_v04_M_v01_SARMD_LBR.do
First version
</_Version Control_>
----------------------------------------------------------------------------------*/

*<_Program setup_>
clear all
set more off

local code         		"IND"
local year         		"2022"
local survey       		"HCES"
local vm           		"04"
local va           		"01"
local type         		"SARMD"
global module       	"LBR"
local yearfolder    	"`code'_`year'_`survey'"
local SARMDfolder    	"`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'"
local filename      	"`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'_${module}"
cap mkdir				"${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'" 
cap mkdir				"${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'\\Data" 
cap mkdir				"${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'\\Data\Harmonized" 
global input      		"${rootdatalib}\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M\Data\Stata"
glo   output          	"${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'\\Data\Harmonized" 
*</_Program setup_>


*<_Datalibweb request_>
use "${input}\\`yearfolder'_v`vm'_M.dta", clear
*</_Datalibweb request_>


*<_countrycode_> 
*<_countrycode_note_> Country code according to ISO-3166 Alpha-3 *</_countrycode_note_>
gen countrycode = "`code'"
gen code = countrycode
*</_countrycode_>

*<_year_>
*<_year_note_> 4-digit year of survey based on IHSN standards *</_year_note_>
capture drop year 
gen year = 2022
*</_year_>

*<_hhid_>
*<_hhid_note_> Household identifier  *</_hhid_note_>
/*<_hhid_note_> . *</_hhid_note_>*/
*<_hhid_note_> hhid brought in from Master *</_hhid_note_>
*</_hhid_>

*<_pid_>
*<_pid_note_> Personal identifier  *</_pid_note_>
/*<_pid_note_> country specific *</_pid_note_>*/
*<_pid_note_> pid brought in from Master *</_pid_note_>
*</_pid_>

*<_weight_>
*<_weight_note_> Household weight  *</_weight_note_>
/*<_weight_note_> Survey specific information *</_weight_note_>*/
clonevar weight = hhwt
clonevar weight_p = weight
*</_weight_>

*<_weighttype_>
*<_weighttype_note_> Weight type (frequency, probability, analytical, importance) *</_weighttype_note_>
*<_weighttype_note_> weighttype brought in from rawdata *</_weighttype_note_>
gen weighttype = "PW"
*</_weighttype_>


*<_minlaborage_>
*<_minlaborage_note_> Labor module application age *</_minlaborage_note_>
/*<_minlaborage_note_>  *</_minlaborage_note_>*/
*<_minlaborage_note_> HCES does not include a module on labor *</_minlaborage_note_>
gen minlaborage = .
*</_minlaborage_>

*<_lstatus_>
*<_lstatus_note_> Labor status *</_lstatus_note_>
/*<_lstatus_note_> 1 "Employed" 2 "Unemployed" 3 "Not in labor force" *</_lstatus_note_>*/
*<_lstatus_note_> HCES does not include a module on labor *</_lstatus_note_>
gen lstatus = .
*</_lstatus_>

*<_nlfreason_>
*<_nlfreason_note_> Reason not in the labor force *</_nlfreason_note_>
/*<_nlfreason_note_>  1 "Student" 2 "Housewife" 3 "Retired" 4 "Disabled" 5"Others" *</_nlfreason_note_>*/
*<_nlfreason_note_> HCES does not include a module on labor *</_nlfreason_note_>
gen nlfreason = .
*</_nlfreason_>

*<_unempldur_l_>
*<_unempldur_l_note_> Unemployment duration (months) lower bracket *</_unempldur_l_note_>
/*<_unempldur_l_note_>  *</_unempldur_l_note_>*/
*<_unempldur_l_note_> HCES does not include a module on labor *</_unempldur_l_note_>
gen unempldur_l = .
*</_unempldur_l_>

*<_unempldur_u_>
*<_unempldur_u_note_> Unemployment duration (months) upper bracket *</_unempldur_u_note_>
/*<_unempldur_u_note_>  *</_unempldur_u_note_>*/
*<_unempldur_u_note_> HCES does not include a module on labor *</_unempldur_u_note_>
gen unempldur_u = .
*</_unempldur_u_>

*<_empstat_>
*<_empstat_note_> Employment status *</_empstat_note_>
/*<_empstat_note_> 1 "Paid Employee" 2 "Non-Paid Employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status" *</_empstat_note_>*/
*<_empstat_note_> HCES does not include a module on labor *</_empstat_note_>
gen empstat = .
*</_empstat_>

*<_ocusec_>
*<_ocusec_note_> Sector of activity *</_ocusec_note_>
/*<_ocusec_note_> 1 "Public sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish" *</_ocusec_note_>*/
*<_ocusec_note_> HCES does not include a module on labor *</_ocusec_note_>
gen ocusec = .
*</_ocusec_>

*<_industry_orig_>
*<_industry_orig_note_> original industry codes *</_industry_orig_note_>
/*<_industry_orig_note_>  *</_industry_orig_note_>*/
*<_industry_orig_note_> HCES does not include a module on labor *</_industry_orig_note_>
gen industry_orig = "."
*</_industry_orig_>

*<_industrycat10_>
*<_industrycat10_note_> 1 digit industry classification *</_industrycat10_note_>
/*<_industrycat10_note_> 1 "Agriculture, Hunting, Fishing, etc." 2 "Mining" 3 "Manufacturing" 4 "Public Utility Services" 5 "Construction" 6 "Commerce" 7 "Transport and Communications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Others *</_industrycat10_note_>*/
*<_industrycat10_note_> HCES does not include a module on labor *</_industrycat10_note_>
gen industrycat10 = .
*</_industrycat10_>

*<_industrycat4_>
*<_industrycat4_note_> 1 digit industry classification (Broad Economic Activities) *</_industrycat4_note_>
/*<_industrycat4_note_> 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other" *</_industrycat4_note_>*/
*<_industrycat4_note_> HCES does not include a module on labor *</_industrycat4_note_>
gen industrycat4 = .
*</_industrycat4_>

*<_occup_orig_>
*<_occup_orig_note_> original occupation code *</_occup_orig_note_>
/*<_occup_orig_note_>  *</_occup_orig_note_>*/
*<_occup_orig_note_> HCES does not include a module on labor *</_occup_orig_note_>
gen occup_orig = "."
*</_occup_orig_>

*<_occup_>
*<_occup_note_> 1 digit occupational classification *</_occup_note_>
/*<_occup_note_> 1 "Managers" 2 "Professionals" 3 "Technicians and associate professionals" 4 "Clerical support workers" 5 "Service and sales workers" 6 "Skilled agricultural, forestry and fishery workers" 7 "Craft and related trades workers" 8 "Plant and machine operators, and assemblers" 9 "Elementary occupations" 10 "Armed forces occupations" 99 "Other/unspecified"  *</_occup_note_>*/
*<_occup_note_> HCES does not include a module on labor *</_occup_note_>
gen occup = .
*</_occup_>

*<_wage_nc_>
*<_wage_nc_note_> Last wage payment *</_wage_nc_note_>
/*<_wage_nc_note_>  *</_wage_nc_note_>*/
*<_wage_nc_note_> HCES does not include a module on labor *</_wage_nc_note_>
gen wage_nc = .
*</_wage_nc_>

*<_unitwage_>
*<_unitwage_note_> Last wages time unit *</_unitwage_note_>
/*<_unitwage_note_> 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Every two months" 5 "Monthly" 6 "Quarterly" 7 "Every six months" 8 "Annually" 9 "Hourly" 10 "Other" *</_unitwage_note_>*/
*<_unitwage_note_> HCES does not include a module on labor *</_unitwage_note_>
gen unitwage = .
*</_unitwage_>

*<_whours_>
*<_whours_note_> Hours of work in last week *</_whours_note_>
/*<_whours_note_>  *</_whours_note_>*/
*<_whours_note_> HCES does not include a module on labor *</_whours_note_>
gen whours = .
*</_whours_>

*<_wmonths_>
*<_wmonths_note_> Months worked in the last 12 months *</_wmonths_note_>
/*<_wmonths_note_>  *</_wmonths_note_>*/
*<_wmonths_note_> HCES does not include a module on labor *</_wmonths_note_>
gen wmonths = .
*</_wmonths_>

*<_wage_total_>
*<_wage_total_note_> Primary job total wage  *</_wage_total_note_>
/*<_wage_total_note_>  *</_wage_total_note_>*/
*<_wage_total_note_> HCES does not include a module on labor *</_wage_total_note_>
gen wage_total = .
*</_wage_total_>

*<_contract_>
*<_contract_note_> Contract *</_contract_note_>
/*<_contract_note_> 1 "Yes" 0 "No" *</_contract_note_>*/
*<_contract_note_> HCES does not include a module on labor *</_contract_note_>
gen contract = .
*</_contract_>

*<_healthins_>
*<_healthins_note_> Health insurance *</_healthins_note_>
/*<_healthins_note_> 1 "Yes" 0 "No" *</_healthins_note_>*/
*<_healthins_note_> HCES does not include a module on labor *</_healthins_note_>
gen healthins = .
*</_healthins_>

*<_socialsec_>
*<_socialsec_note_> Social security *</_socialsec_note_>
/*<_socialsec_note_> 1 "Yes" 0 "No" *</_socialsec_note_>*/
*<_socialsec_note_> HCES does not include a module on labor *</_socialsec_note_>
gen socialsec = .
*</_socialsec_>

*<_union_>
*<_union_note_> Union membership *</_union_note_>
/*<_union_note_> 1 "Yes" 0 "No" *</_union_note_>*/
*<_union_note_> HCES does not include a module on labor *</_union_note_>
gen union = .
*</_union_>

*<_firmsize_l_>
*<_firmsize_l_note_> Firm size (lower bracket) *</_firmsize_l_note_>
/*<_firmsize_l_note_>  *</_firmsize_l_note_>*/
*<_firmsize_l_note_> HCES does not include a module on labor *</_firmsize_l_note_>
gen firmsize_l = .
*</_firmsize_l_>

*<_firmsize_u_>
*<_firmsize_u_note_> Firm size (upper bracket) *</_firmsize_u_note_>
/*<_firmsize_u_note_>  *</_firmsize_u_note_>*/
*<_firmsize_u_note_> HCES does not include a module on labor *</_firmsize_u_note_>
gen firmsize_u = .
*</_firmsize_u_>

*<_empstat_2_>
*<_empstat_2_note_> Employment status - second job - last 7 days *</_empstat_2_note_>
/*<_empstat_2_note_> 1 "Paid Employee" 2 "Non-Paid Employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status" *</_empstat_2_note_>*/
*<_empstat_2_note_> HCES does not include a module on labor *</_empstat_2_note_>
gen empstat_2 = .
*</_empstat_2_>

*<_ocusec_2_>
*<_ocusec_2_note_> Sector of activity for second job *</_ocusec_2_note_>
/*<_ocusec_2_note_> 1 "Public sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish" *</_ocusec_2_note_>*/
*<_ocusec_2_note_> HCES does not include a module on labor *</_ocusec_2_note_>
gen ocusec_2 = .
*</_ocusec_2_>

*<_industry_orig_2_>
*<_industry_orig_2_note_> original industry codes for second job *</_industry_orig_2_note_>
/*<_industry_orig_2_note_>  *</_industry_orig_2_note_>*/
*<_industry_orig_2_note_> HCES does not include a module on labor *</_industry_orig_2_note_>
gen industry_orig_2 = "."
*</_industry_orig_2_>

*<_industrycat10_2_>
*<_industrycat10_2_note_> 1 digit industry classification for second job *</_industrycat10_2_note_>
/*<_industrycat10_2_note_> 1 "Agriculture, Hunting, Fishing, etc." 2 "Mining" 3 "Manufacturing" 4 "Public Utility Services" 5 "Construction" 6 "Commerce" 7 "Transport and Communications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Others *</_industrycat10_2_note_>*/
*<_industrycat10_2_note_> HCES does not include a module on labor *</_industrycat10_2_note_>
gen industrycat10_2 = .
*</_industrycat10_2_>

*<_industrycat4_2_>
*<_industrycat4_2_note_> 1 digit industry classification (Broad Economic Activities) for second job *</_industrycat4_2_note_>
/*<_industrycat4_2_note_> 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other" *</_industrycat4_2_note_>*/
*<_industrycat4_2_note_> HCES does not include a module on labor *</_industrycat4_2_note_>
gen industrycat4_2 = .
*</_industrycat4_2_>

*<_occup_orig_2_>
*<_occup_orig_2_note_> original occupation code for second job *</_occup_orig_2_note_>
/*<_occup_orig_2_note_>  *</_occup_orig_2_note_>*/
*<_occup_orig_2_note_> HCES does not include a module on labor *</_occup_orig_2_note_>
gen occup_orig_2 = "."
*</_occup_orig_2_>

*<_occup_2_>
*<_occup_2_note_> 1 digit occupational classification for second job *</_occup_2_note_>
/*<_occup_2_note_> 1 "Managers" 2 "Professionals" 3 "Technicians and associate professionals" 4 "Clerical support workers" 5 "Service and sales workers" 6 "Skilled agricultural, forestry and fishery workers" 7 "Craft and related trades workers" 8 "Plant and machine operators, and assemblers" 9 "Elementary occupations" 10 "Armed forces occupations" 99 "Other/unspecified"  *</_occup_2_note_>*/
*<_occup_2_note_> HCES does not include a module on labor *</_occup_2_note_>
gen occup_2 = .
*</_occup_2_>

*<_wage_nc_2_>
*<_wage_nc_2_note_> Last wage payment second job *</_wage_nc_2_note_>
/*<_wage_nc_2_note_>  *</_wage_nc_2_note_>*/
*<_wage_nc_2_note_> HCES does not include a module on labor *</_wage_nc_2_note_>
gen wage_nc_2 = .
*</_wage_nc_2_>

*<_unitwage_2_>
*<_unitwage_2_note_> Last wages time unit second job *</_unitwage_2_note_>
/*<_unitwage_2_note_> 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Every two months" 5 "Monthly" 6 "Quarterly" 7 "Every six months" 8 "Annually" 9 "Hourly" 10 "Other" *</_unitwage_2_note_>*/
*<_unitwage_2_note_> HCES does not include a module on labor *</_unitwage_2_note_>
gen unitwage_2 = .
*</_unitwage_2_>

*<_whours_2_>
*<_whours_2_note_> Hours of work in last week for the secondary job *</_whours_2_note_>
/*<_whours_2_note_>  *</_whours_2_note_>*/
*<_whours_2_note_> HCES does not include a module on labor *</_whours_2_note_>
gen whours_2 = .
*</_whours_2_>

*<_wmonths_2_>
*<_wmonths_2_note_> Months worked in the last 12 months for the secondary job *</_wmonths_2_note_>
/*<_wmonths_2_note_>  *</_wmonths_2_note_>*/
*<_wmonths_2_note_> HCES does not include a module on labor *</_wmonths_2_note_>
gen wmonths_2 = .
*</_wmonths_2_>

*<_wage_total_2_>
*<_wage_total_2_note_> Secondary job total wage  *</_wage_total_2_note_>
/*<_wage_total_2_note_>  *</_wage_total_2_note_>*/
*<_wage_total_2_note_> HCES does not include a module on labor *</_wage_total_2_note_>
gen wage_total_2 = .
*</_wage_total_2_>

*<_firmsize_l_2_>
*<_firmsize_l_2_note_> Firm size (lower bracket) for the secondary job *</_firmsize_l_2_note_>
/*<_firmsize_l_2_note_>  *</_firmsize_l_2_note_>*/
*<_firmsize_l_2_note_> HCES does not include a module on labor *</_firmsize_l_2_note_>
gen firmsize_l_2 = .
*</_firmsize_l_2_>

*<_firmsize_u_2_>
*<_firmsize_u_2_note_> Firm size (upper bracket) for the secondary job *</_firmsize_u_2_note_>
/*<_firmsize_u_2_note_>  *</_firmsize_u_2_note_>*/
*<_firmsize_u_2_note_> HCES does not include a module on labor *</_firmsize_u_2_note_>
gen firmsize_u_2 = .
*</_firmsize_u_2_>

*<_t_hours_others_>
*<_t_hours_others_note_> Total hours of work in the last 12 months in other jobs excluding the primary and secondary ones *</_t_hours_others_note_>
/*<_t_hours_others_note_>  *</_t_hours_others_note_>*/
*<_t_hours_others_note_> HCES does not include a module on labor *</_t_hours_others_note_>
gen t_hours_others = .
*</_t_hours_others_>

*<_t_wage_nc_others_>
*<_t_wage_nc_others_note_> Annualized wage in all jobs excluding the primary and secondary ones (excluding tips, bonuses, etc.). *</_t_wage_nc_others_note_>
/*<_t_wage_nc_others_note_>  *</_t_wage_nc_others_note_>*/
*<_t_wage_nc_others_note_> HCES does not include a module on labor *</_t_wage_nc_others_note_>
gen t_wage_nc_others = .
*</_t_wage_nc_others_>

*<_t_wage_others_>
*<_t_wage_others_note_> Annualized wage (including tips, bonuses, etc.) in all other jobs excluding the primary and secondary ones. *</_t_wage_others_note_>
/*<_t_wage_others_note_>  *</_t_wage_others_note_>*/
*<_t_wage_others_note_> HCES does not include a module on labor *</_t_wage_others_note_>
gen t_wage_others = .
*</_t_wage_others_>

*<_t_hours_total_>
*<_t_hours_total_note_> Annualized hours worked in all jobs (7-day ref period) *</_t_hours_total_note_>
/*<_t_hours_total_note_>  *</_t_hours_total_note_>*/
*<_t_hours_total_note_> HCES does not include a module on labor *</_t_hours_total_note_>
gen t_hours_total = .
*</_t_hours_total_>

*<_t_wage_nc_total_>
*<_t_wage_nc_total_note_> Annualized wage in all jobs excl. bonuses, etc. (7-day ref period) *</_t_wage_nc_total_note_>
/*<_t_wage_nc_total_note_>  *</_t_wage_nc_total_note_>*/
*<_t_wage_nc_total_note_> HCES does not include a module on labor *</_t_wage_nc_total_note_>
gen t_wage_nc_total = .
*</_t_wage_nc_total_>

*<_t_wage_total_>
*<_t_wage_total_note_> Annualized total wage for all jobs (7-day ref period) *</_t_wage_total_note_>
/*<_t_wage_total_note_>  *</_t_wage_total_note_>*/
*<_t_wage_total_note_> HCES does not include a module on labor *</_t_wage_total_note_>
gen t_wage_total = .
*</_t_wage_total_>

*<_minlaborage_year_>
*<_minlaborage_year_note_> Labor module application age (12-mon ref period) *</_minlaborage_year_note_>
/*<_minlaborage_year_note_>  *</_minlaborage_year_note_>*/
*<_minlaborage_year_note_> HCES does not include a module on labor *</_minlaborage_year_note_>
gen minlaborage_year = .
*</_minlaborage_year_>

*<_lstatus_year_>
*<_lstatus_year_note_> Labor status (12-mon ref period) *</_lstatus_year_note_>
/*<_lstatus_year_note_> 1 "Employed" 2 "Unemployed" 3 "Not in labor force" *</_lstatus_year_note_>*/
*<_lstatus_year_note_> HCES does not include a module on labor *</_lstatus_year_note_>
gen lstatus_year = .
*</_lstatus_year_>

*<_nlfreason_year_>
*<_nlfreason_year_note_> Reason not in the labor force (12-mon ref period) *</_nlfreason_year_note_>
/*<_nlfreason_year_note_>  1 "Student" 2 "Housewife" 3 "Retired" 4 "Disabled" 5"Others" *</_nlfreason_year_note_>*/
*<_nlfreason_year_note_> HCES does not include a module on labor *</_nlfreason_year_note_>
gen nlfreason_year = .
*</_nlfreason_year_>

*<_unempldur_l_year_>
*<_unempldur_l_year_note_> Unemployment duration (months) lower bracket (12-mon ref period) *</_unempldur_l_year_note_>
/*<_unempldur_l_year_note_>  *</_unempldur_l_year_note_>*/
*<_unempldur_l_year_note_> HCES does not include a module on labor *</_unempldur_l_year_note_>
gen unempldur_l_year = .
*</_unempldur_l_year_>

*<_unempldur_u_year_>
*<_unempldur_u_year_note_> Unemployment duration (months) upper bracket (12-mon ref period) *</_unempldur_u_year_note_>
/*<_unempldur_u_year_note_>  *</_unempldur_u_year_note_>*/
*<_unempldur_u_year_note_> HCES does not include a module on labor *</_unempldur_u_year_note_>
gen unempldur_u_year = .
*</_unempldur_u_year_>

*<_empstat_year_>
*<_empstat_year_note_> Employment status, primary job (12-mon ref period) *</_empstat_year_note_>
/*<_empstat_year_note_> 1 "Paid Employee" 2 "Non-Paid Employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status" *</_empstat_year_note_>*/
*<_empstat_year_note_> HCES does not include a module on labor *</_empstat_year_note_>
gen empstat_year = .
*</_empstat_year_>

*<_ocusec_year_>
*<_ocusec_year_note_> Sector of activity, primary job (12-mon ref period) *</_ocusec_year_note_>
/*<_ocusec_year_note_> 1 "Public sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish" *</_ocusec_year_note_>*/
*<_ocusec_year_note_> HCES does not include a module on labor *</_ocusec_year_note_>
gen ocusec_year = .
*</_ocusec_year_>

*<_industry_orig_year_>
*<_industry_orig_year_note_> Original industry code, primary job (12-mon ref period) *</_industry_orig_year_note_>
/*<_industry_orig_year_note_>  *</_industry_orig_year_note_>*/
*<_industry_orig_year_note_> HCES does not include a module on labor *</_industry_orig_year_note_>
gen industry_orig_year = "."
*</_industry_orig_year_>

*<_industrycat10_year_>
*<_industrycat10_year_note_> 1 digit industry classification, primary job (12-mon ref period) *</_industrycat10_year_note_>
/*<_industrycat10_year_note_> 1 "Agriculture, Hunting, Fishing, etc." 2 "Mining" 3 "Manufacturing" 4 "Public Utility Services" 5 "Construction" 6 "Commerce" 7 "Transport and Communications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Others *</_industrycat10_year_note_>*/
*<_industrycat10_year_note_> HCES does not include a module on labor *</_industrycat10_year_note_>
gen industrycat10_year = .
*</_industrycat10_year_>

*<_industrycat4_year_>
*<_industrycat4_year_note_> 4-category industry classification primary job (12-mon ref period) *</_industrycat4_year_note_>
/*<_industrycat4_year_note_> 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other" *</_industrycat4_year_note_>*/
*<_industrycat4_year_note_> HCES does not include a module on labor *</_industrycat4_year_note_>
gen industrycat4_year = .
*</_industrycat4_year_>

*<_occup_orig_year_>
*<_occup_orig_year_note_> Original occupational classification, primary job (12-mon ref period) *</_occup_orig_year_note_>
/*<_occup_orig_year_note_>  *</_occup_orig_year_note_>*/
*<_occup_orig_year_note_> HCES does not include a module on labor *</_occup_orig_year_note_>
gen occup_orig_year = "."					
*</_occup_orig_year_>

*<_occup_year_>
*<_occup_year_note_> 1 digit occupational classification, primary job (12-mon ref period) *</_occup_year_note_>
/*<_occup_year_note_> 1 "Managers" 2 "Professionals" 3 "Technicians and associate professionals" 4 "Clerical support workers" 5 "Service and sales workers" 6 "Skilled agricultural, forestry and fishery workers" 7 "Craft and related trades workers" 8 "Plant and machine operators, and assemblers" 9 "Elementary occupations" 10 "Armed forces occupations" 99 "Other/unspecified"  *</_occup_year_note_>*/
*<_occup_year_note_> HCES does not include a module on labor *</_occup_year_note_>
gen occup_year = .
*</_occup_year_>

*<_wage_nc_year_>
*<_wage_nc_year_note_> Last wage payment, primary job, excl. bonuses, etc. (12-mon ref period) *</_wage_nc_year_note_>
/*<_wage_nc_year_note_>  *</_wage_nc_year_note_>*/
*<_wage_nc_year_note_> HCES does not include a module on labor *</_wage_nc_year_note_>
gen wage_nc_year = .
*</_wage_nc_year_>

*<_unitwage_year_>
*<_unitwage_year_note_> Time unit of last wages payment, primary job (12-mon ref period) *</_unitwage_year_note_>
/*<_unitwage_year_note_> 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Every two months" 5 "Monthly" 6 "Quarterly" 7 "Every six months" 8 "Annually" 9 "Hourly" 10 "Other" *</_unitwage_year_note_>*/
*<_unitwage_year_note_> HCES does not include a module on labor *</_unitwage_year_note_>
gen unitwage_year = .
*</_unitwage_year_>

*<_whours_year_>
*<_whours_year_note_> Hours of work in last week, primary job (12-mon ref period) *</_whours_year_note_>
/*<_whours_year_note_>  *</_whours_year_note_>*/
*<_whours_year_note_> HCES does not include a module on labor *</_whours_year_note_>
gen whours_year = .
*</_whours_year_>

*<_wmonths_year_>
*<_wmonths_year_note_> Months worked in the last 12 months, primary job (12-mon ref period) *</_wmonths_year_note_>
/*<_wmonths_year_note_>  *</_wmonths_year_note_>*/
*<_wmonths_year_note_> HCES does not include a module on labor *</_wmonths_year_note_>
gen wmonths_year = .
*</_wmonths_year_>

*<_wage_total_year_>
*<_wage_total_year_note_> Annualized total wage, primary job (12-mon ref period) *</_wage_total_year_note_>
/*<_wage_total_year_note_>  *</_wage_total_year_note_>*/
*<_wage_total_year_note_> HCES does not include a module on labor *</_wage_total_year_note_>
gen wage_total_year = .
*</_wage_total_year_>

*<_contract_year_>
*<_contract_year_note_> Contract (12-mon ref period) *</_contract_year_note_>
/*<_contract_year_note_> 1 "Yes" 0 "No" *</_contract_year_note_>*/
*<_contract_year_note_> HCES does not include a module on labor *</_contract_year_note_>
gen contract_year = .
*</_contract_year_>

*<_healthins_year_>
*<_healthins_year_note_> Health insurance (12-mon ref period) *</_healthins_year_note_>
/*<_healthins_year_note_> 1 "Yes" 0 "No" *</_healthins_year_note_>*/
*<_healthins_year_note_> HCES does not include a module on labor *</_healthins_year_note_>
gen healthins_year = .
*</_healthins_year_>

*<_socialsec_year_>
*<_socialsec_year_note_> Social security (12-mon ref period) *</_socialsec_year_note_>
/*<_socialsec_year_note_> 1 "Yes" 0 "No" *</_socialsec_year_note_>*/
*<_socialsec_year_note_> HCES does not include a module on labor *</_socialsec_year_note_>
gen socialsec_year = .
*</_socialsec_year_>

*<_union_year_>
*<_union_year_note_> Union membership (12-mon ref period) *</_union_year_note_>
/*<_union_year_note_> 1 "Yes" 0 "No" *</_union_year_note_>*/
*<_union_year_note_> HCES does not include a module on labor *</_union_year_note_>
gen union_year = .
*</_union_year_>

*<_firmsize_l_year_>
*<_firmsize_l_year_note_> Firm size (lower bracket) (12-mon ref period) *</_firmsize_l_year_note_>
/*<_firmsize_l_year_note_>  *</_firmsize_l_year_note_>*/
*<_firmsize_l_year_note_> HCES does not include a module on labor *</_firmsize_l_year_note_>
gen firmsize_l_year = .
*</_firmsize_l_year_>

*<_firmsize_u_year_>
*<_firmsize_u_year_note_> Firm size (upper bracket) (12-mon ref period) *</_firmsize_u_year_note_>
/*<_firmsize_u_year_note_>  *</_firmsize_u_year_note_>*/
*<_firmsize_u_year_note_> HCES does not include a module on labor *</_firmsize_u_year_note_>
gen firmsize_u_year = .
*</_firmsize_u_year_>

*<_empstat_2_year_>
*<_empstat_2_year_note_> Employment status - second job (12-mon ref period) *</_empstat_2_year_note_>
/*<_empstat_2_year_note_> 1 "Paid Employee" 2 "Non-Paid Employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status" *</_empstat_2_year_note_>*/
*<_empstat_2_year_note_> HCES does not include a module on labor *</_empstat_2_year_note_>
gen empstat_2_year = .
*</_empstat_2_year_>

*<_ocusec_2_year_>
*<_ocusec_2_year_note_> Sector of activity for second job (12-mon ref period) *</_ocusec_2_year_note_>
/*<_ocusec_2_year_note_> 1 "Public sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish" *</_ocusec_2_year_note_>*/
*<_ocusec_2_year_note_> HCES does not include a module on labor *</_ocusec_2_year_note_>
gen ocusec_2_year = .
*</_ocusec_2_year_>

*<_industry_orig_2_year_>
*<_industry_orig_2_year_note_> original industry codes for second job (12-mon ref period) *</_industry_orig_2_year_note_>
/*<_industry_orig_2_year_note_>  *</_industry_orig_2_year_note_>*/
*<_industry_orig_2_year_note_> HCES does not include a module on labor *</_industry_orig_2_year_note_>
gen industry_orig_2_year = "."
*</_industry_orig_2_year_>

*<_industrycat10_2_year_>
*<_industrycat10_2_year_note_> 1 digit industry classification for second job (12-mon ref period) *</_industrycat10_2_year_note_>
/*<_industrycat10_2_year_note_> 1 "Agriculture, Hunting, Fishing, etc." 2 "Mining" 3 "Manufacturing" 4 "Public Utility Services" 5 "Construction" 6 "Commerce" 7 "Transport and Communications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Others *</_industrycat10_2_year_note_>*/
*<_industrycat10_2_year_note_> HCES does not include a module on labor *</_industrycat10_2_year_note_>
gen industrycat10_2_year = .
*</_industrycat10_2_year_>

*<_industrycat4_2_year_>
*<_industrycat4_2_year_note_> 4-category industry classification, secondary job (12-mon ref period) *</_industrycat4_2_year_note_>
/*<_industrycat4_2_year_note_> 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other" *</_industrycat4_2_year_note_>*/
*<_industrycat4_2_year_note_> HCES does not include a module on labor *</_industrycat4_2_year_note_>
gen industrycat4_2_year = .
*</_industrycat4_2_year_>

*<_occup_orig_2_year_>
*<_occup_orig_2_year_note_> Original occupational classification, secondary job (12-mon ref period) *</_occup_orig_2_year_note_>
/*<_occup_orig_2_year_note_>  *</_occup_orig_2_year_note_>*/
*<_occup_orig_2_year_note_> HCES does not include a module on labor *</_occup_orig_2_year_note_>
gen occup_orig_2_year = "."							
*</_occup_orig_2_year_>

*<_occup_2_year_>
*<_occup_2_year_note_> 1 digit occupational classification, secondary job (12-mon ref period) *</_occup_2_year_note_>
/*<_occup_2_year_note_> 1 "Managers" 2 "Professionals" 3 "Technicians and associate professionals" 4 "Clerical support workers" 5 "Service and sales workers" 6 "Skilled agricultural, forestry and fishery workers" 7 "Craft and related trades workers" 8 "Plant and machine operators, and assemblers" 9 "Elementary occupations" 10 "Armed forces occupations" 99 "Other/unspecified"  *</_occup_2_year_note_>*/
*<_occup_2_year_note_> HCES does not include a module on labor *</_occup_2_year_note_>
gen occup_2_year = .
*</_occup_2_year_>

*<_wage_nc_2_year_>
*<_wage_nc_2_year_note_> last wage payment, secondary job, excl. bonuses, etc. (12-mon ref period) *</_wage_nc_2_year_note_>
/*<_wage_nc_2_year_note_>  *</_wage_nc_2_year_note_>*/
*<_wage_nc_2_year_note_> HCES does not include a module on labor *</_wage_nc_2_year_note_>
gen wage_nc_2_year = .
*</_wage_nc_2_year_>

*<_unitwage_2_year_>
*<_unitwage_2_year_note_> Time unit of last wages payment, secondary job (12-mon ref period) *</_unitwage_2_year_note_>
/*<_unitwage_2_year_note_> 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Every two months" 5 "Monthly" 6 "Quarterly" 7 "Every six months" 8 "Annually" 9 "Hourly" 10 "Other" *</_unitwage_2_year_note_>*/
*<_unitwage_2_year_note_> HCES does not include a module on labor *</_unitwage_2_year_note_>
gen unitwage_2_year = .
*</_unitwage_2_year_>

*<_whours_2_year_>
*<_whours_2_year_note_> Hours of work in last week, secondary job (12-mon ref period) *</_whours_2_year_note_>
/*<_whours_2_year_note_>  *</_whours_2_year_note_>*/
*<_whours_2_year_note_> HCES does not include a module on labor *</_whours_2_year_note_>
gen whours_2_year = .
*</_whours_2_year_>

*<_wmonths_2_year_>
*<_wmonths_2_year_note_> Months worked in the last 12 months, secondary job (12-mon ref period) *</_wmonths_2_year_note_>
/*<_wmonths_2_year_note_>  *</_wmonths_2_year_note_>*/
*<_wmonths_2_year_note_> HCES does not include a module on labor *</_wmonths_2_year_note_>
gen wmonths_2_year = .
*</_wmonths_2_year_>

*<_wage_total_2_year_>
*<_wage_total_2_year_note_> Annualized total wage, secondary job (12-mon ref period) *</_wage_total_2_year_note_>
/*<_wage_total_2_year_note_>  *</_wage_total_2_year_note_>*/
*<_wage_total_2_year_note_> HCES does not include a module on labor *</_wage_total_2_year_note_>
gen wage_total_2_year = .
*</_wage_total_2_year_>

*<_firmsize_l_2_year_>
*<_firmsize_l_2_year_note_> Firm size (lower bracket), secondary job (12-mon ref period) *</_firmsize_l_2_year_note_>
/*<_firmsize_l_2_year_note_>  *</_firmsize_l_2_year_note_>*/
*<_firmsize_l_2_year_note_> HCES does not include a module on labor *</_firmsize_l_2_year_note_>
gen firmsize_l_2_year = .
*</_firmsize_l_2_year_>

*<_firmsize_u_2_year_>
*<_firmsize_u_2_year_note_> Firm size (lower bracket), secondary job (12-mon ref period) *</_firmsize_u_2_year_note_>
/*<_firmsize_u_2_year_note_>  *</_firmsize_u_2_year_note_>*/
*<_firmsize_u_2_year_note_> HCES does not include a module on labor *</_firmsize_u_2_year_note_>
gen firmsize_u_2_year = .
*</_firmsize_u_2_year_>

*<_t_hours_others_year_>
*<_t_hours_others_year_note_> Annualized hours worked in all but primary and secondary jobs (12-mon ref period) *</_t_hours_others_year_note_>
/*<_t_hours_others_year_note_>  *</_t_hours_others_year_note_>*/
*<_t_hours_others_year_note_> HCES does not include a module on labor *</_t_hours_others_year_note_>
gen t_hours_others_year = .
*</_t_hours_others_year_>

*<_t_wage_nc_others_year_>
*<_t_wage_nc_others_year_note_> Annualized wage in all but primary & secondary jobs excl. bonuses, etc. (12-mon ref period) *</_t_wage_nc_others_year_note_>
/*<_t_wage_nc_others_year_note_>  *</_t_wage_nc_others_year_note_>*/
*<_t_wage_nc_others_year_note_> HCES does not include a module on labor *</_t_wage_nc_others_year_note_>
gen t_wage_nc_others_year = .
*</_t_wage_nc_others_year_>

*<_t_wage_others_year_>
*<_t_wage_others_year_note_> Annualized wage in all but primary and secondary jobs (12-mon ref period) *</_t_wage_others_year_note_>
/*<_t_wage_others_year_note_>  *</_t_wage_others_year_note_>*/
*<_t_wage_others_year_note_> HCES does not include a module on labor *</_t_wage_others_year_note_>
gen t_wage_others_year = .
*</_t_wage_others_year_>

*<_t_hours_total_year_>
*<_t_hours_total_year_note_> Annualized hours worked in all jobs (12-mon ref period) *</_t_hours_total_year_note_>
/*<_t_hours_total_year_note_>  *</_t_hours_total_year_note_>*/
*<_t_hours_total_year_note_> HCES does not include a module on labor *</_t_hours_total_year_note_>
gen t_hours_total_year = .
*</_t_hours_total_year_>

*<_t_wage_nc_total_year_>
*<_t_wage_nc_total_year_note_> Annualized wage in all jobs excl. bonuses, etc. (12-mon ref period) *</_t_wage_nc_total_year_note_>
/*<_t_wage_nc_total_year_note_>  *</_t_wage_nc_total_year_note_>*/
*<_t_wage_nc_total_year_note_> HCES does not include a module on labor *</_t_wage_nc_total_year_note_>
gen t_wage_nc_total_year = .
*</_t_wage_nc_total_year_>

*<_t_wage_total_year_>
*<_t_wage_total_year_note_> Annualized total wage for all jobs (12-mon ref period) *</_t_wage_total_year_note_>
/*<_t_wage_total_year_note_>  *</_t_wage_total_year_note_>*/
*<_t_wage_total_year_note_> HCES does not include a module on labor *</_t_wage_total_year_note_>
gen t_wage_total_year = .
*</_t_wage_total_year_>

*<_njobs_>
*<_njobs_note_> Total number of jobs *</_njobs_note_>
/*<_njobs_note_>  *</_njobs_note_>*/
*<_njobs_note_> HCES does not include a module on labor *</_njobs_note_>
gen njobs = .
*</_njobs_>

*<_t_hours_annual_>
*<_t_hours_annual_note_> Total hours worked in all jobs in the previous 12 months *</_t_hours_annual_note_>
/*<_t_hours_annual_note_>  *</_t_hours_annual_note_>*/
*<_t_hours_annual_note_> HCES does not include a module on labor *</_t_hours_annual_note_>
gen t_hours_annual = .
*</_t_hours_annual_>

*<_linc_nc_>
*<_linc_nc_note_> Total annual wage income in all jobs, excl. bonuses, etc. *</_linc_nc_note_>
/*<_linc_nc_note_>  *</_linc_nc_note_>*/
*<_linc_nc_note_> HCES does not include a module on labor *</_linc_nc_note_>
gen linc_nc = .
*</_linc_nc_>

*<_laborincome_>
*<_laborincome_note_> Total annual individual labor income in all jobs, incl. bonuses, etc. *</_laborincome_note_>
/*<_laborincome_note_>  *</_laborincome_note_>*/
*<_laborincome_note_> HCES does not include a module on labor *</_laborincome_note_>
gen laborincome = .
*</_laborincome_>

*<_Keep variables_>
order countrycode year hhid pid weight weighttype
sort  hhid pid
*</_Keep variables_>


*<_Save data file_>
compress
quietly do 	"$rootdofiles\_aux\Labels_GMD3.0.do"
save "$output\\`filename'.dta", replace
*<_Save data file_>

	