/*------------------------------------------------------------------------------
					GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   MDV_2019_HIES_v01_M_v02_A_GMD_LBR.do	</_Program name_>
<_Application_>    STATA 16.0	<_Application_>
<_Author(s)_>      Sizhen Fang <sfang2@worldbank.org>	</_Author(s)_>
<_Date created_>   06-26-2023	</_Date created_>
<_Date modified>    26 June 2023	</_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        MDV	</_Country_>
<_Survey Title_>   HIES	</_Survey Title_>
<_Survey Year_>    2019	</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:	06-26-2023
File:	MDV_2019_HIES_v01_M_v02_A_GMD_LBR.do
- First version
</_Version Control_>
------------------------------------------------------------------------------*/

*<_Program setup_>;
#delimit ;
clear all;
set more off;

local code         "MDV";
local year         "2019";
local survey       "HIES";
local vm           "01";
local va           "02";
local type         "SARMD";
local yearfolder   "`code'_`year'_`survey'";
local gmdfolder    "`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'";
local filename     "`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'_LBR";
*</_Program setup_>;

*<_Folder creation_>;
cap mkdir "$rootdatalib";
cap mkdir "$rootdatalib\\`code'";
cap mkdir "$rootdatalib\\`code'\\`yearfolder'";
cap mkdir "$rootdatalib\\`code'\\`yearfolder'\\`gmdfolder'";
cap mkdir "$rootdatalib\\`code'\\`yearfolder'\\`gmdfolder'\Data";
cap mkdir "$rootdatalib\\`code'\\`yearfolder'\\`gmdfolder'\Data\Harmonized";
*</_Folder creation_>;

** DIRECTORY;
*<_Datalibweb request income_>;
foreach act of numlist 1 2 { ;
	#delimit cr
	datalibweb, country(`code') year(`year') type(SARRAW) surveyid(MDV_2019_HIES_v01_M) filename(occupation.dta)
	#delimit ;
	* keep only primary occupation; 
	keep if occupation__id==`act';
	rename primaryIncomeAndProfitInBusiness ProfitInBusiness; ///name is too long;
	keep uqhh__id UsualMembers__id incmvr__1 ProfitInBusiness emp_income primaryMonthsWorked primaryDaysWorked;
	rename (*) (*`act');
	rename uqhh__id`act' uqhhid; 
	rename UsualMembers__id`act' person_no;
	tempfile income`act' ;
	save `income`act'', replace ;
};
*</_Datalibweb request income_>;

*<_Datalibweb request_>;
#delimit cr
datalibweb, country(`code') year(`year') type(SARRAW) surveyid(`code'_`year'_`survey'_v`vm'_M) filename(`code'_`year'_`survey'_v`vm'_M.dta) clear 
#delimit ;
drop year hhid pid;
merge 1:1  uqhhid person_no using `income1', gen(inc1_m);
drop if inc1_m==2;
merge 1:1  uqhhid person_no using `income2', gen(inc2_m);
drop if inc2_m==2; drop inc?_m;

*</_Datalibweb request_>;

*<_countrycode_>;
*<_countrycode_note_> country code *</_countrycode_note_>;
*<_countrycode_note_> countrycode brought in from rawdata *</_countrycode_note_>;
gen countrycode="MDV";
note countrycode: countrycode=MDV;
*</_countrycode_>;

*<_year_>;
*<_year_note_> Year *</_year_note_>;
*<_year_note_> year brought in from rawdata *</_year_note_>;
gen year=2019;
note year: year=2019;
*</_year_>;

*<_hhid_>;
*<_hhid_note_> Household identifier  *</_hhid_note_>;
*<_hhid_note_> hhid brought in from rawdata *</_hhid_note_>;
gen hhid=uqhhid;
tostring hhid, replace;
label var hhid "Household id";
note hhid: hhid=uqhhid  4,721 values;
*</_hhid_>;

*<_pid_>;
*<_pid_note_> Personal identifier  *</_pid_note_>;
*<_pid_note_> pid brought in from rawdata *</_pid_note_>;
egen pid=concat (uqhhid person_no), punct(-);
note pid: pid=uqhhid - person_no  24,845 values;
*</_pid_>;

*<_weight_>;
*<_weight_note_> Household weight *</_weight_note_>;
*<_weight_note_> weight brought in from rawdata *</_weight_note_>;
gen weight=wgt;
note weight: weight=wgt;
*</_weight_>;

*<_weighttype_>;
*<_weighttype_note_> Weight type (frequency, probability, analytical, importance) *</_weighttype_note_>;
*<_weighttype_note_> weighttype brought in from rawdata *</_weighttype_note_>;
gen weighttype="PW";
note weighttype: "Probability weight"
*</_weighttype_>;

*<_age_>;
*<_age_note_> Age of individual (continuous) *</_age_note_>;
*<_age_note_> age brought in from rawdata *</_age_note_>;
gen age=Age;
note age: age=Age;
*</_age_>;

*<_minlaborage_>;
*<_minlaborage_note_> Labor module application age *</_minlaborage_note_>;
*<_minlaborage_note_> minlaborage brought in from rawdata *</_minlaborage_note_>;
gen minlaborage=15;
note minlaborage: minlaborage=15;
*</_minlaborage_>;

*<_lstatus_>;
*<_lstatus_note_> Labor status *</_lstatus_note_>;
*<_lstatus_note_> lstatus brought in from rawdata *</_lstatus_note_>;
gen lstatus=ilo_lfs;
note lstatus: LAbor status in last 7 days;
*</_lstatus_>;

*<_nlfreason_>;
*<_nlfreason_note_> Reason not in the labor force *</_nlfreason_note_>;
*<_nlfreason_note_> nlfreason brought in from rawdata *</_nlfreason_note_>;
gen nlfreason=.;
note nlfreason: N/A;
*</_nlfreason_>;

*<_unempldur_l_>;
*<_unempldur_l_note_> Unemployment duration (months) lower bracket *</_unempldur_l_note_>;
*<_unempldur_l_note_> unempldur_l brought in from rawdata *</_unempldur_l_note_>;
gen unempldur_l=(actvly_lookng_dur==1);
note unempldur_l: Unemployment duration (months) lower bracket;
*</_unempldur_l_>;

*<_unempldur_u_>;
*<_unempldur_u_note_> Unemployment duration (months) upper bracket *</_unempldur_u_note_>;
*<_unempldur_u_note_> unempldur_u brought in from rawdata *</_unempldur_u_note_>;
gen unempldur_u=(actvly_lookng_dur==5);
note unempldur_u: Unemployment duration (months) upper bracket;
*</_unempldur_u_>;

*<_empstat_>;
*<_empstat_note_> Employment status *</_empstat_note_>;
*<_empstat_note_> empstat brought in from rawdata *</_empstat_note_>;
recode  primaryStatusEmp (1=1) (2=3) (3 4 5 6 =4) , gen(empstat);
note empstat: Status in primary employment in last 7 days;
*</_empstat_>;

*<_ocusec_>;
*<_ocusec_note_> Sector of activity *</_ocusec_note_>;
*<_ocusec_note_> ocusec brought in from rawdata *</_ocusec_note_>;
gen ocusec=.;
replace ocusec=1 if inlist(PrimaryEstabType, 1, 2, 4, 5);
replace ocusec=2 if inlist(PrimaryEstabType, 3, 6, 7, 9, 10);
replace ocusec=3 if PrimaryEstabType==8;
note ocusec: Sector of primary activity in last 7 days;
*</_ocusec_>;

*<_industry_orig_>;
*<_industry_orig_note_> original industry codes *</_industry_orig_note_>;
*<_industry_orig_note_> industry_orig brought in from rawdata *</_industry_orig_note_>;
gen industry_orig=isic_section;
note industry_orig: industry_orig=isic_section in primary occupation;
*</_industry_orig_>;

*<_industrycat10_>;
*<_industrycat10_note_> 1 digit industry classification *</_industrycat10_note_>;
*<_industrycat10_note_> industrycat10 brought in from rawdata *</_industrycat10_note_>;
gen industrycat10=.;
replace industrycat10=1  if isic_section==1;
replace industrycat10=2  if isic_section==2;
replace industrycat10=3  if isic_section==3;
replace industrycat10=4  if isic_section==5;
replace industrycat10=5  if isic_section==6;
replace industrycat10=6  if isic_section==7;
replace industrycat10=7  if [isic_section==8 | isic_section==10];
replace industrycat10=8  if [isic_section==11 | isic_section==12];
replace industrycat10=9  if isic_section==15 & occupation__id==1;
replace industrycat10=10 if [isic_section==14 | isic_section==19];
note industrycat10: industrycat10=4 includes "Water supply, sewerage, waste management and remediation activities" - industrycat10=7 includes "Transportation and storage + Information and communication" - industrycat10=8 includes "Financial and insurance activities + Real estate activities" - industrycat10=10 includes "Administrative and support services + Other service activities";
note industrycat10: 1 digit industry classification in primary employment;
*</_industrycat10_>;

*<_industrycat4_>;
*<_industrycat4_note_> 1 digit industry classification (Broad Economic Activities) *</_industrycat4_note_>;
*<_industrycat4_note_> industrycat4 brought in from rawdata *</_industrycat4_note_>;
gen industrycat4=.;
replace industrycat4=1 if inlist(industrycat10, 1); 
replace industrycat4=2 if inlist(industrycat10, 2, 3, 5);
replace industrycat4=3 if inlist(industrycat10, 4, 6, 8, 9);
replace industrycat4=4 if inlist(industrycat10, 10);
note industrycat4: 1 digit industry classification (Broad Economic Activities) in primary occupation;
*</_industrycat4_>;

*<_occup_orig_>;
*<_occup_orig_note_> original occupation code *</_occup_orig_note_>;
*<_occup_orig_note_> occup_orig brought in from rawdata *</_occup_orig_note_>;
gen occup_orig=isco08_unit;
note occup_orig: original occupation code in primary occupation;
*</_occup_orig_>;

*<_occup_>;
*<_occup_note_> 1 digit occupational classification *</_occup_note_>;
*<_occup_note_> occup brought in from rawdata *</_occup_note_>;
gen occup=isco08_major;
note occup: 1 digit occupational classification in primary occupation;
*</_occup_>;

*<_wage_nc_>;
*<_wage_nc_note_> Last wage payment *</_wage_nc_note_>;
*<_wage_nc_note_> wage_nc brought in from rawdata *</_wage_nc_note_>;
replace incmvr__11=.u if incmvr__11==-99;
gen wage_nc = incmvr__11 if primaryStatusEmp == 1;
replace wage_nc = ProfitInBusiness1 if inlist(primaryStatusEmp, 2, 3, 4, 5, 6);
note wage_nc: Last wage payment in primary occupation;

*</_wage_nc_>;

*<_unitwage_>;
*<_unitwage_note_> Last wages time unit *</_unitwage_note_>;
*<_unitwage_note_> unitwage brought in from rawdata *</_unitwage_note_>;
gen unitwage=.;
replace unitwage=5;
note unitwage: Monthly;
*</_unitwage_>;

*<_whours_>;
*<_whours_note_> Hours of work in last week *</_whours_note_>;
*<_whours_note_> whours brought in from rawdata *</_whours_note_>;
gen whours=(primaryHrsPerDay*primaryDaysWorked);
note whours: Hours of work in last week i primary occupation;
*</_whours_>;

*<_wmonths_>;
*<_wmonths_note_> Months worked in the last 12 months *</_wmonths_note_>;
*<_wmonths_note_> wmonths brought in from rawdata *</_wmonths_note_>;
gen wmonths=primaryMonthsWorked;
note wmonths: Months worked in the last 12 months in primary occupation;
*</_wmonths_>;

*<_wage_total_>;
*<_wage_total_note_> Primary job total wage  *</_wage_total_note_>;
*<_wage_total_note_> wage_total brought in from rawdata *</_wage_total_note_>;
gen wage_total=( emp_income1*primaryMonthsWorked) if primaryMonthsWorked > 0;
replace wage_total=. if ProfitInBusiness1==. & incmvr__11==.;
replace wage_total = emp_income1 if primaryMonthsWorked == 0;
note wage_total: Total wage in primary occupation;
*</_wage_total_>;

*<_contract_>;
*<_contract_note_> Contract *</_contract_note_>;
*<_contract_note_> contract brought in from rawdata *</_contract_note_>;
gen contract=.;
replace contract=0 if primaryWrittenOrOralContract==3;
replace contract=1 if [primaryWrittenOrOralContract==1 | primaryWrittenOrOralContract==2];
note contract: Written or oral contract in primary occupation;
*</_contract_>;

*<_healthins_>;
*<_healthins_note_> Health insurance *</_healthins_note_>;
*<_healthins_note_> healthins brought in from rawdata *</_healthins_note_>;
gen healthins=.;
replace healthins=0 if primary_health_insurance==2;
replace healthins=1 if primary_health_insurance==1;
note healthins: Worker with health insurance;
*</_healthins_>;

*<_socialsec_>;
*<_socialsec_note_> Social security *</_socialsec_note_>;
*<_socialsec_note_> socialsec brought in from rawdata *</_socialsec_note_>;
gen socialsec=.;
replace socialsec=1 if primaryPension==1;
replace socialsec=0 if primaryPension==2;
note socialsec: Social security status of worker;
*</_socialsec_>;

*<_union_>;
*<_union_note_> Union membership *</_union_note_>;
*<_union_note_> union brought in from rawdata *</_union_note_>;
gen union=.;
note union: N/A;
*</_union_>;

*<_firmsize_l_>;
*<_firmsize_l_note_> Firm size (lower bracket) *</_firmsize_l_note_>;
*<_firmsize_l_note_> firmsize_l brought in from rawdata *</_firmsize_l_note_>;
gen firmsize_l=.;
note firmsize_l: N/A;
*</_firmsize_l_>;

*<_firmsize_u_>;
*<_firmsize_u_note_> Firm size (upper bracket) *</_firmsize_u_note_>;
*<_firmsize_u_note_> firmsize_u brought in from rawdata *</_firmsize_u_note_>;
gen firmsize_u=.;
note firmsize_u: N/A;
*</_firmsize_u_>;

*<_empstat_2_>;
*<_empstat_2_note_> Employment status - second job *</_empstat_2_note_>;
*<_empstat_2_note_> empstat_2 brought in from rawdata *</_empstat_2_note_>;
recode  primaryStatusEmp2 (1=1) (2=3) (3 4 5 6 =4) , gen(empstat_2);
note empstat_2: Status in secondary employment in last 7 days;
*</_empstat_2_>;

*<_ocusec_2_>;
*<_ocusec_2_note_> Sector of activity for second job *</_ocusec_2_note_>;
*<_ocusec_2_note_> ocusec_2 brought in from rawdata *</_ocusec_2_note_>;
gen ocusec_2=.;
replace ocusec_2=1 if inlist(PrimaryEstabType2, 1, 2, 4, 5);
replace ocusec_2=2 if inlist(PrimaryEstabType2, 3, 6, 7, 9, 10);
replace ocusec_2=3 if PrimaryEstabType2==8;
note ocusec_2: Sector of secondary activity in last 7 days;
*</_ocusec_2_>;

*<_industry_orig_2_>;
*<_industry_orig_2_note_> original industry codes for second job *</_industry_orig_2_note_>;
*<_industry_orig_2_note_> industry_orig_2 brought in from rawdata *</_industry_orig_2_note_>;
gen industry_orig_2=isic_section2;
note industry_orig_2: industry_orig=isic_section in secondary occupation;
*</_industry_orig_2_>;

*<_industrycat10_2_>;
*<_industrycat10_2_note_> 1 digit industry classification for second job *</_industrycat10_2_note_>;
*<_industrycat10_2_note_> industrycat10_2 brought in from rawdata *</_industrycat10_2_note_>;
gen industrycat10_2=.;
replace industrycat10_2=1  if isic_section2==1;
replace industrycat10_2=2  if isic_section2==2;
replace industrycat10_2=3  if isic_section2==3;
replace industrycat10_2=4  if isic_section2==5;
replace industrycat10_2=5  if isic_section2==6;
replace industrycat10_2=6  if isic_section2==7;
replace industrycat10_2=7  if [isic_section2==8 | isic_section2==10];
replace industrycat10_2=8  if [isic_section2==11 | isic_section2==12];
replace industrycat10_2=9  if isic_section2==15;
replace industrycat10_2=10 if [isic_section2==14 | isic_section2==19];
note industrycat10: industrycat10_2=4 includes "Water supply, sewerage, waste management and remediation activities" - industrycat10_2=7 includes "Transportation and storage + Information and communication" - industrycat10_2=8 includes "Financial and insurance activities + Real estate activities" - industrycat10_2=10 includes "Administrative and support services + Other service activities";
note industrycat10: 1 digit industry classification in secondary occupation;
*</_industrycat10_2_>;

*<_industrycat4_2_>;
*<_industrycat4_2_note_> 1 digit industry classification (Broad Economic Activities) for second job *</_industrycat4_2_note_>;
*<_industrycat4_2_note_> industrycat4_2 brought in from rawdata *</_industrycat4_2_note_>;
gen industrycat4_2=.;
replace industrycat4_2=1 if inlist(industrycat10_2, 1); 
replace industrycat4_2=2 if inlist(industrycat10_2, 2, 3, 5);
replace industrycat4_2=3 if inlist(industrycat10_2, 4, 6, 8, 9);
replace industrycat4_2=4 if inlist(industrycat10_2, 10);
note industrycat4_2: 1 digit industry classification (Broad Economic Activities) in secondary occupation;
*</_industrycat4_2_>;

*<_occup_orig_2_>;
*<_occup_orig_2_note_> original occupation code for second job *</_occup_orig_2_note_>;
*<_occup_orig_2_note_> occup_orig_2 brought in from rawdata *</_occup_orig_2_note_>;
gen occup_orig_2=isco08_unit2;
note occup_orig_2: occup_orig_2=isco08_unit in secondary occupation;
*</_occup_orig_2_>;

*<_occup_2_>;
*<_occup_2_note_> 1 digit occupational classification for second job *</_occup_2_note_>;
*<_occup_2_note_> occup_2 brought in from rawdata *</_occup_2_note_>;
gen occup_2=isco08_major2;
note occup_2: occup_2=isco08_major in secondary occupation;
*</_occup_2_>;

*<_wage_nc_2_>;
*<_wage_nc_2_note_> Last wage payment second job *</_wage_nc_2_note_>;
*<_wage_nc_2_note_> wage_nc_2 brought in from rawdata *</_wage_nc_2_note_>;
replace incmvr__12=.u if incmvr__12==-99;
gen wage_nc_2 = incmvr__12 if primaryStatusEmp22 == 1;
replace wage_nc = ProfitInBusiness1 if inlist(primaryStatusEmp22, 2, 3, 4, 5, 6);
note wage_nc_2: Last wage payment second job;
*</_wage_nc_2_>;

*<_unitwage_2_>;
*<_unitwage_2_note_> Last wages time unit second job *</_unitwage_2_note_>;
*<_unitwage_2_note_> unitwage_2 brought in from rawdata *</_unitwage_2_note_>;
gen unitwage_2=.;
replace unitwage_2=5;
note unitwage_2: Monthly;
*</_unitwage_2_>;

*<_whours_2_>;
*<_whours_2_note_> Hours of work in last week for the secondary job *</_whours_2_note_>;
*<_whours_2_note_> whours_2 brought in from rawdata *</_whours_2_note_>;
gen whours_2=(primaryHrsPerDay22*primaryDaysWorked22);
note whours_2: Hours of work in last week for the secondary job ;
*</_whours_2_>;

*<_wmonths_2_>;
*<_wmonths_2_note_> Months worked in the last 12 months for the secondary job *</_wmonths_2_note_>;
*<_wmonths_2_note_> wmonths_2 brought in from rawdata *</_wmonths_2_note_>;
gen wmonths_2=primaryMonthsWorked22;
note wmonths_2: Months worked in the last 12 months for the secondary job;
*</_wmonths_2_>;

*<_wage_total_2_>;
*<_wage_total_2_note_> Secondary job total wage  *</_wage_total_2_note_>;
*<_wage_total_2_note_> wage_total_2 brought in from rawdata *</_wage_total_2_note_>;
gen wage_total_2=( emp_income2*primaryMonthsWorked22) if primaryMonthsWorked22 > 0;
replace wage_total_2=. if ProfitInBusiness2==. & incmvr__12==.;
replace wage_total_2 = emp_income2 if primaryMonthsWorked22 == 0;
note wage_total_2: Secondary job total monthly wage;
*</_wage_total_2_>;

*<_firmsize_l_2_>;
*<_firmsize_l_2_note_> Firm size (lower bracket) for the secondary job *</_firmsize_l_2_note_>;
*<_firmsize_l_2_note_> firmsize_l_2 brought in from rawdata *</_firmsize_l_2_note_>;
gen firmsize_l_2=.;
note firmsize_l_2: N/A;
*</_firmsize_l_2_>;

*<_firmsize_u_2_>;
*<_firmsize_u_2_note_> Firm size (upper bracket) for the secondary job *</_firmsize_u_2_note_>;
*<_firmsize_u_2_note_> firmsize_u_2 brought in from rawdata *</_firmsize_u_2_note_>;
gen firmsize_u_2=.;
note firmsize_u_2: N/A;
*</_firmsize_u_2_>;

*<_t_hours_others_>;
*<_t_hours_others_note_> Total hours of work in the last 12 months in other jobs excluding the primary and secondary ones *</_t_hours_others_note_>;
*<_t_hours_others_note_> t_hours_others brought in from rawdata *</_t_hours_others_note_>;
gen t_hours_others=.;
note t_hours_others: N/A
*</_t_hours_others_>;

*<_t_wage_nc_others_>;
*<_t_wage_nc_others_note_> Annualized wage in all jobs excluding the primary and secondary ones (excluding tips, bonuses, etc.). *</_t_wage_nc_others_note_>;
*<_t_wage_nc_others_note_> t_wage_nc_others brought in from rawdata *</_t_wage_nc_others_note_>;
gen t_wage_nc_others=.;
note t_wage_nc_others:N/A;
*</_t_wage_nc_others_>;

*<_t_wage_others_>;
*<_t_wage_others_note_> Annualized wage (including tips, bonuses, etc.) in all other jobs excluding the primary and secondary ones. *</_t_wage_others_note_>;
*<_t_wage_others_note_> t_wage_others brought in from rawdata *</_t_wage_others_note_>;
gen t_wage_others=.;
note t_wage_others: N/A;
*</_t_wage_others_>;

*<_t_hours_total_>;
*<_t_hours_total_note_> Annualized hours worked in all jobs (7-day ref period) *</_t_hours_total_note_>;
*<_t_hours_total_note_> t_hours_total brought in from rawdata *</_t_hours_total_note_>;
gen t_hours_total=.;
replace t_hours_total=(othr_income_specify+whours + whours_2);
replace t_hours_total=t_hours_total*4.3*12;
note t_hours_total: Annualized hours worked in all jobs (7-day ref period);
*</_t_hours_total_>;

*<_t_wage_nc_total_>;
*<_t_wage_nc_total_note_> Annualized wage in all jobs excl. bonuses, etc. (7-day ref period) *</_t_wage_nc_total_note_>;
*<_t_wage_nc_total_note_> t_wage_nc_total brought in from rawdata *</_t_wage_nc_total_note_>;
egen t_wage_nc_total=rowtotal(wage_nc wage_nc_2 t_wage_nc_others);
note t_wage_nc_total: Annualized wage in all jobs excl. bonuses, etc. (7-day ref period);
*</_t_wage_nc_total_>;

*<_t_wage_total_>;
*<_t_wage_total_note_> Annualized total wage for all jobs (7-day ref period) *</_t_wage_total_note_>;
*<_t_wage_total_note_> t_wage_total brought in from rawdata *</_t_wage_total_note_>;
egen t_wage_total=rowtotal(wage_total wage_total_2 t_wage_others);
note t_wage_total: Annualized total wage for all jobs (7-day ref period);
*</_t_wage_total_>;

*<_minlaborage_year_>;
*<_minlaborage_year_note_> Labor module application age (12-mon ref period) *</_minlaborage_year_note_>;
*<_minlaborage_year_note_> minlaborage_year brought in from rawdata *</_minlaborage_year_note_>;
gen minlaborage_year=.;
note minlaborage_year: N/A;
*</_minlaborage_year_>;

*<_lstatus_year_>;
*<_lstatus_year_note_> Labor status (12-mon ref period) *</_lstatus_year_note_>;
*<_lstatus_year_note_> lstatus_year brought in from rawdata *</_lstatus_year_note_>;
gen lstatus_year=.;
note lstatus_year: N/A;
*</_lstatus_year_>;

*<_nlfreason_year_>;
*<_nlfreason_year_note_> Reason not in the labor force (12-mon ref period) *</_nlfreason_year_note_>;
*<_nlfreason_year_note_> nlfreason_year brought in from rawdata *</_nlfreason_year_note_>;
gen nlfreason_year=.;
note nlfreason_year: N/A;
*</_nlfreason_year_>;

*<_unempldur_l_year_>;
*<_unempldur_l_year_note_> Unemployment duration (months) lower bracket (12-mon ref period) *</_unempldur_l_year_note_>;
*<_unempldur_l_year_note_> unempldur_l_year brought in from rawdata *</_unempldur_l_year_note_>;
gen unempldur_l_year=.;
note unempldur_l_year: N/A;
*</_unempldur_l_year_>;

*<_unempldur_u_year_>;
*<_unempldur_u_year_note_> Unemployment duration (months) upper bracket (12-mon ref period) *</_unempldur_u_year_note_>;
*<_unempldur_u_year_note_> unempldur_u_year brought in from rawdata *</_unempldur_u_year_note_>;
gen unempldur_u_year=.;
note unempldur_u_year: N/A;
*</_unempldur_u_year_>;

*<_empstat_year_>;
*<_empstat_year_note_> Employment status, primary job (12-mon ref period) *</_empstat_year_note_>;
*<_empstat_year_note_> empstat_year brought in from rawdata *</_empstat_year_note_>;
gen empstat_year=.;
note empstat_year:N/A;
*</_empstat_year_>;

*<_ocusec_year_>;
*<_ocusec_year_note_> Sector of activity, primary job (12-mon ref period) *</_ocusec_year_note_>;
*<_ocusec_year_note_> ocusec_year brought in from rawdata *</_ocusec_year_note_>;
gen ocusec_year=.;
note ocusec_year: N/A;
*</_ocusec_year_>;

*<_industry_orig_year_>;
*<_industry_orig_year_note_> Original industry code, primary job (12-mon ref period) *</_industry_orig_year_note_>;
*<_industry_orig_year_note_> industry_orig_year brought in from rawdata *</_industry_orig_year_note_>;
gen industry_orig_year=.;
note industry_orig_year: N/A;
*</_industry_orig_year_>;

*<_industrycat10_year_>;
*<_industrycat10_year_note_> 1 digit industry classification, primary job (12-mon ref period) *</_industrycat10_year_note_>;
*<_industrycat10_year_note_> industrycat10_year brought in from rawdata *</_industrycat10_year_note_>;
gen industrycat10_year=.;
note industrycat10_year: N/A;
*</_industrycat10_year_>;

*<_industrycat4_year_>;
*<_industrycat4_year_note_> 4-category industry classification primary job (12-mon ref period) *</_industrycat4_year_note_>;
*<_industrycat4_year_note_> industrycat4_year brought in from rawdata *</_industrycat4_year_note_>;
gen industrycat4_year=.;
note industrycat4_year: N/A;
*</_industrycat4_year_>;

*<_occup_orig_year_>;
*<_occup_orig_year_note_> Original occupational classification, primary job (12-mon ref period) *</_occup_orig_year_note_>;
*<_occup_orig_year_note_> occup_orig_year brought in from rawdata *</_occup_orig_year_note_>;
gen occup_orig_year=.;
note occup_orig_year: N/A;
*</_occup_orig_year_>;

*<_occup_year_>;
*<_occup_year_note_> 1 digit occupational classification, primary job (12-mon ref period) *</_occup_year_note_>;
*<_occup_year_note_> occup_year brought in from rawdata *</_occup_year_note_>;
gen occup_year=.;
note occup_year: N/A;
*</_occup_year_>;

*<_wage_nc_year_>;
*<_wage_nc_year_note_> Last wage payment, primary job, excl. bonuses, etc. (12-mon ref period) *</_wage_nc_year_note_>;
*<_wage_nc_year_note_> wage_nc_year brought in from rawdata *</_wage_nc_year_note_>;
gen wage_nc_year=.;
note wage_nc_year: N/A;
*</_wage_nc_year_>;

*<_unitwage_year_>;
*<_unitwage_year_note_> Time unit of last wages payment, primary job (12-mon ref period) *</_unitwage_year_note_>;
*<_unitwage_year_note_> unitwage_year brought in from rawdata *</_unitwage_year_note_>;
gen unitwage_year=.;
note unitwage_year: N/A;
*</_unitwage_year_>;

*<_whours_year_>;
*<_whours_year_note_> Hours of work in last week, primary job (12-mon ref period) *</_whours_year_note_>;
*<_whours_year_note_> whours_year brought in from rawdata *</_whours_year_note_>;
gen whours_year=.;
note whours_year: N/A;
*</_whours_year_>;

*<_wmonths_year_>;
*<_wmonths_year_note_> Months worked in the last 12 months, primary job (12-mon ref period) *</_wmonths_year_note_>;
*<_wmonths_year_note_> wmonths_year brought in from rawdata *</_wmonths_year_note_>;
gen wmonths_year=.;
note wmonths_year: N/A;
*</_wmonths_year_>;

*<_wage_total_year_>;
*<_wage_total_year_note_> Annualized total wage, primary job (12-mon ref period) *</_wage_total_year_note_>;
*<_wage_total_year_note_> wage_total_year brought in from rawdata *</_wage_total_year_note_>;
gen wage_total_year=.;
note wage_total_year: N/A;
*</_wage_total_year_>;

*<_contract_year_>;
*<_contract_year_note_> Contract (12-mon ref period) *</_contract_year_note_>;
*<_contract_year_note_> contract_year brought in from rawdata *</_contract_year_note_>;
gen contract_year=.;
note contract_year: N/A;
*</_contract_year_>;

*<_healthins_year_>;
*<_healthins_year_note_> Health insurance (12-mon ref period) *</_healthins_year_note_>;
*<_healthins_year_note_> healthins_year brought in from rawdata *</_healthins_year_note_>;
gen healthins_year=.;
note healthins_year: N/A;
*</_healthins_year_>;

*<_socialsec_year_>;
*<_socialsec_year_note_> Social security (12-mon ref period) *</_socialsec_year_note_>;
*<_socialsec_year_note_> socialsec_year brought in from rawdata *</_socialsec_year_note_>;
gen socialsec_year=.;
note socialsec_year: N/A;
*</_socialsec_year_>;

*<_union_year_>;
*<_union_year_note_> Union membership (12-mon ref period) *</_union_year_note_>;
*<_union_year_note_> union_year brought in from rawdata *</_union_year_note_>;
gen union_year=.;
note union_year: N/A;
*</_union_year_>;

*<_firmsize_l_year_>;
*<_firmsize_l_year_note_> Firm size (lower bracket) (12-mon ref period) *</_firmsize_l_year_note_>;
*<_firmsize_l_year_note_> firmsize_l_year brought in from rawdata *</_firmsize_l_year_note_>;
gen firmsize_l_year=.;
note firmsize_l_year: N/A;
*</_firmsize_l_year_>;

*<_firmsize_u_year_>;
*<_firmsize_u_year_note_> Firm size (upper bracket) (12-mon ref period) *</_firmsize_u_year_note_>;
*<_firmsize_u_year_note_> firmsize_u_year brought in from rawdata *</_firmsize_u_year_note_>;
gen firmsize_u_year=.;
note firmsize_u_year: N/A;
*</_firmsize_u_year_>;

*<_empstat_2_year_>;
*<_empstat_2_year_note_> Employment status - second job (12-mon ref period) *</_empstat_2_year_note_>;
*<_empstat_2_year_note_> empstat_2_year brought in from rawdata *</_empstat_2_year_note_>;
gen empstat_2_year=.;
note empstat_2_year: N/A;
*</_empstat_2_year_>;

*<_ocusec_2_year_>;
*<_ocusec_2_year_note_> Sector of activity for second job (12-mon ref period) *</_ocusec_2_year_note_>;
*<_ocusec_2_year_note_> ocusec_2_year brought in from rawdata *</_ocusec_2_year_note_>;
gen ocusec_2_year=.;
note ocusec_2_year: N/A;
*</_ocusec_2_year_>;

*<_industry_orig_2_year_>;
*<_industry_orig_2_year_note_> original industry codes for second job (12-mon ref period) *</_industry_orig_2_year_note_>;
*<_industry_orig_2_year_note_> industry_orig_2_year brought in from rawdata *</_industry_orig_2_year_note_>;
gen industry_orig_2_year=.;
note industry_orig_2_year: N/A;
*</_industry_orig_2_year_>;

*<_industrycat10_2_year_>;
*<_industrycat10_2_year_note_> 1 digit industry classification for second job (12-mon ref period) *</_industrycat10_2_year_note_>;
*<_industrycat10_2_year_note_> industrycat10_2_year brought in from rawdata *</_industrycat10_2_year_note_>;
gen industrycat10_2_year=.;
note industrycat10_2_year: N/A;
*</_industrycat10_2_year_>;

*<_industrycat4_2_year_>;
*<_industrycat4_2_year_note_> 4-category industry classification, secondary job (12-mon ref period) *</_industrycat4_2_year_note_>;
*<_industrycat4_2_year_note_> industrycat4_2_year brought in from rawdata *</_industrycat4_2_year_note_>;
gen industrycat4_2_year=.;
note industrycat4_2_year: N/A;
*</_industrycat4_2_year_>;

*<_occup_orig_2_year_>;
*<_occup_orig_2_year_note_> Original occupational classification, secondary job (12-mon ref period) *</_occup_orig_2_year_note_>;
*<_occup_orig_2_year_note_> occup_orig_2_year brought in from rawdata *</_occup_orig_2_year_note_>;
gen occup_orig_2_year=.;
note occup_orig_2_year: N/A;
*</_occup_orig_2_year_>;

*<_occup_2_year_>;
*<_occup_2_year_note_> 1 digit occupational classification, secondary job (12-mon ref period) *</_occup_2_year_note_>;
*<_occup_2_year_note_> occup_2_year brought in from rawdata *</_occup_2_year_note_>;
gen occup_2_year=.;
note occup_2_year: N/A;
*</_occup_2_year_>;

*<_wage_nc_2_year_>;
*<_wage_nc_2_year_note_> last wage payment, secondary job, excl. bonuses, etc. (12-mon ref period) *</_wage_nc_2_year_note_>;
*<_wage_nc_2_year_note_> wage_nc_2_year brought in from rawdata *</_wage_nc_2_year_note_>;
gen wage_nc_2_year=.;
note wage_nc_2_year: N/A;
*</_wage_nc_2_year_>;

*<_unitwage_2_year_>;
*<_unitwage_2_year_note_> Time unit of last wages payment, secondary job (12-mon ref period) *</_unitwage_2_year_note_>;
*<_unitwage_2_year_note_> unitwage_2_year brought in from rawdata *</_unitwage_2_year_note_>;
gen unitwage_2_year=.;
note unitwage_2_year: N/A;
*</_unitwage_2_year_>;

*<_whours_2_year_>;
*<_whours_2_year_note_> Hours of work in last week, secondary job (12-mon ref period) *</_whours_2_year_note_>;
*<_whours_2_year_note_> whours_2_year brought in from rawdata *</_whours_2_year_note_>;
gen whours_2_year=.;
note whours_2_year: N/A;
*</_whours_2_year_>;

*<_wmonths_2_year_>;
*<_wmonths_2_year_note_> Months worked in the last 12 months, secondary job (12-mon ref period) *</_wmonths_2_year_note_>;
*<_wmonths_2_year_note_> wmonths_2_year brought in from rawdata *</_wmonths_2_year_note_>;
gen wmonths_2_year=.;
note wmonths_2_year: N/A;
*</_wmonths_2_year_>;

*<_wage_total_2_year_>;
*<_wage_total_2_year_note_> Annualized total wage, secondary job (12-mon ref period) *</_wage_total_2_year_note_>;
*<_wage_total_2_year_note_> wage_total_2_year brought in from rawdata *</_wage_total_2_year_note_>;
gen wage_total_2_year=.;
note wage_total_2_year: N/A;
*</_wage_total_2_year_>;

*<_firmsize_l_2_year_>;
*<_firmsize_l_2_year_note_> Firm size (lower bracket), secondary job (12-mon ref period) *</_firmsize_l_2_year_note_>;
*<_firmsize_l_2_year_note_> firmsize_l_2_year brought in from rawdata *</_firmsize_l_2_year_note_>;
gen firmsize_l_2_year=.;
note firmsize_l_2_year: N/A;
*</_firmsize_l_2_year_>;

*<_firmsize_u_2_year_>;
*<_firmsize_u_2_year_note_> Firm size (lower bracket), secondary job (12-mon ref period) *</_firmsize_u_2_year_note_>;
*<_firmsize_u_2_year_note_> firmsize_u_2_year brought in from rawdata *</_firmsize_u_2_year_note_>;
gen firmsize_u_2_year=.;
note firmsize_u_2_year: N/A;
*</_firmsize_u_2_year_>;

*<_t_hours_others_year_>;
*<_t_hours_others_year_note_> Annualized hours worked in all but primary and secondary jobs (12-mon ref period) *</_t_hours_others_year_note_>;
*<_t_hours_others_year_note_> t_hours_others_year brought in from rawdata *</_t_hours_others_year_note_>;
gen t_hours_others_year=.;
note t_hours_others_year: N/A;
*</_t_hours_others_year_>;

*<_t_wage_nc_others_year_>;
*<_t_wage_nc_others_year_note_> Annualized wage in all but primary & secondary jobs excl. bonuses, etc. (12-mon ref period) *</_t_wage_nc_others_year_note_>;
*<_t_wage_nc_others_year_note_> t_wage_nc_others_year brought in from rawdata *</_t_wage_nc_others_year_note_>;
gen t_wage_nc_others_year=.;
note t_wage_nc_others_year: N/A;
*</_t_wage_nc_others_year_>;

*<_t_wage_others_year_>;
*<_t_wage_others_year_note_> Annualized wage in all but primary and secondary jobs (12-mon ref period) *</_t_wage_others_year_note_>;
*<_t_wage_others_year_note_> t_wage_others_year brought in from rawdata *</_t_wage_others_year_note_>;
gen t_wage_others_year=.;
note t_wage_others_year: N/A;
*</_t_wage_others_year_>;

*<_t_hours_total_year_>;
*<_t_hours_total_year_note_> Annualized hours worked in all jobs (12-mon ref period) *</_t_hours_total_year_note_>;
*<_t_hours_total_year_note_> t_hours_total_year brought in from rawdata *</_t_hours_total_year_note_>;
gen t_hours_total_year=.;
note t_hours_total_year: N/A;
*</_t_hours_total_year_>;

*<_t_wage_nc_total_year_>;
*<_t_wage_nc_total_year_note_> Annualized wage in all jobs excl. bonuses, etc. (12-mon ref period) *</_t_wage_nc_total_year_note_>;
*<_t_wage_nc_total_year_note_> t_wage_nc_total_year brought in from rawdata *</_t_wage_nc_total_year_note_>;
gen t_wage_nc_total_year=.;
note t_wage_nc_total_year: N/A;
*</_t_wage_nc_total_year_>;

*<_t_wage_total_year_>;
*<_t_wage_total_year_note_> Annualized total wage for all jobs (12-mon ref period) *</_t_wage_total_year_note_>;
*<_t_wage_total_year_note_> t_wage_total_year brought in from rawdata *</_t_wage_total_year_note_>;
gen t_wage_total_year=.;
note t_wage_total_year: N/A;
*</_t_wage_total_year_>;

*<_njobs_>;
*<_njobs_note_> Total number of jobs *</_njobs_note_>;
*<_njobs_note_> njobs brought in from rawdata *</_njobs_note_>;
gen njobs=0; replace njobs=1 if work_for_income==1; replace njobs=2 if carried_secondary==1;
note njobs: Total number of jobs;
*</_njobs_>;

*<_t_hours_annual_>;
*<_t_hours_annual_note_> Total hours worked in all jobs in the previous 12 months *</_t_hours_annual_note_>;
*<_t_hours_annual_note_> t_hours_annual brought in from rawdata *</_t_hours_annual_note_>;
gen t_hours_annual=(othr_income_specify + primaryHrsPerDay*5 + primaryHrsPerDay2*5);
replace t_hours_annual=t_hours_annual*4.3*12;
note t_hours_annual: Total hours worked in all jobs in the previous 12 months;
*</_t_hours_annual_>;

*<_linc_nc_>;
*<_linc_nc_note_> Total annual wage income in all jobs, excl. bonuses, etc. *</_linc_nc_note_>;
*<_linc_nc_note_> linc_nc brought in from rawdata *</_linc_nc_note_>;
egen linc_nc=rowtotal(t_wage_nc_total t_wage_nc_total_year);
note linc_nc: Total annual wage income in all jobs, excl. bonuses, etc.;
*</_linc_nc_>;

*<_laborincome_>;
*<_laborincome_note_> Total annual individual labor income in all jobs, incl. bonuses, etc. *</_laborincome_note_>;
*<_laborincome_note_> laborincome brought in from rawdata *</_laborincome_note_>;
egen laborincome=rowtotal(t_wage_total t_wage_total_year);
note laborincome: Total annual individual labor income in all jobs, incl. bonuses, etc.;
*</_laborincome_>;

*<_Keep variables_>;
keep countrycode year hhid pid weight weighttype age minlaborage lstatus nlfreason unempldur_l unempldur_u empstat ocusec industry_orig industrycat10 industrycat4 occup_orig occup wage_nc unitwage whours wmonths wage_total contract healthins socialsec union firmsize_l firmsize_u empstat_2 ocusec_2 industry_orig_2 industrycat10_2 industrycat4_2 occup_orig_2 occup_2 wage_nc_2 unitwage_2 whours_2 wmonths_2 wage_total_2 firmsize_l_2 firmsize_u_2 t_hours_others t_wage_nc_others t_wage_others t_hours_total t_wage_nc_total t_wage_total minlaborage_year lstatus_year nlfreason_year unempldur_l_year unempldur_u_year empstat_year ocusec_year industry_orig_year industrycat10_year industrycat4_year occup_orig_year occup_year wage_nc_year unitwage_year whours_year wmonths_year wage_total_year contract_year healthins_year socialsec_year union_year firmsize_l_year firmsize_u_year empstat_2_year ocusec_2_year industry_orig_2_year industrycat10_2_year industrycat4_2_year occup_orig_2_year occup_2_year wage_nc_2_year unitwage_2_year whours_2_year wmonths_2_year wage_total_2_year firmsize_l_2_year firmsize_u_2_year t_hours_others_year t_wage_nc_others_year t_wage_others_year t_hours_total_year t_wage_nc_total_year t_wage_total_year njobs t_hours_annual linc_nc laborincome;
order countrycode year hhid pid weight weighttype;
sort hhid pid ;
*</_Keep variables_>;

*<_Save data file_>;
glo module="LBR";
include "${rootdatalib}\_aux\GMD2.0labels.do";
save "$rootdatalib\\`code'\\`yearfolder'\\`gmdfolder'\Data\Harmonized\\`filename'.dta" , replace;
*</_Save data file_>;
