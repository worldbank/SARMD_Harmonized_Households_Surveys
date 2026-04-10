***********************************************************************
*	IND_2011_EUS
*	SAR Labor Harmonization
*	Oct 2024
*	Sizhen Fang, sfang2@worldbank.com
***********************************************************************
clear
set more off
local countrycode	"IND"
local year			"2011"
local survey		"EUS"
local va			"01"
local vm			"01"
local type			"SARLAB"
local surveyfolder	"`countrycode'_`year'_`survey'"
local masternm	 	"`surveyfolder'_v`vm'_M"
local filename 		"`surveyfolder'_v`vm'_M_v`va'_A_`type'"" 

* global path on SF's computer
if ("`c(username)'"=="wb611670") {
* define folder paths
	glo rootdatalib "C:\Users\wb611670\WBG\Laura Liliana Moreno Herrera - 09.SARLAB\WORKINGDATA"
	glo rootlabels "C:\Users\wb611670\WBG\Laura Liliana Moreno Herrera - 09.SARLAB\_aux"
}
* global paths on WB computer
// else {
// 	* NOTE: TODO: You (WB staff) will need to define the location of the datalibweb folder path here.
// 	* load data and merge
// 	tempfile hhvisit1
// 	datalibweb, country(`countrycode') year(`year') survey(`survey') type(SARRAW) filename(hhvisit1_2021-	22.dta) localpath(${rootdatalib}) local
// 	save `hhvisit1', replace
// 	* start with individual data
// 	datalibweb, country(`countrycode') year(`year') survey(`survey') type(SARRAW) filename(personvisit1_2021-22.dta) localpath(${rootdatalib}) local
// 	drop district stratum substratum subsample _merge
// 	* merge in HH data
//  	merge m:1 hhid using `hhvisit1', nogen assert(match)
//
// }

glo surveydata		"${rootdatalib}/`countrycode'/`surveyfolder'/`surveyfolder'_v`vm'_M/Data/Stata"
glo output			"${rootdatalib}/`countrycode'/`surveyfolder'/`surveyfolder'_v`vm'_M_v`va'_A_`type'/Data/Harmonized"
cap mkdir "${rootdatalib}/`countrycode'/`surveyfolder'"
cap mkdir "${rootdatalib}/`countrycode'/`surveyfolder'/`surveyfolder'_v`vm'_M_v`va'_A_`type'"
cap mkdir "${rootdatalib}/`countrycode'/`surveyfolder'/`surveyfolder'_v`vm'_M_v`va'_A_`type'/Data"
cap mkdir "${rootdatalib}/`countrycode'/`surveyfolder'/`surveyfolder'_v`vm'_M_v`va'_A_`type'/Data/Harmonized"
cap mkdir "${rootdatalib}/`countrycode'/`surveyfolder'/`surveyfolder'_v`vm'_M_v`va'_A_`type'/Program"

* SF
if ("`c(username)'"=="wb611670") {
	* load data and merge
	* start with individual data
	use "${surveydata}/IND_EUS_2011.dta", clear
}

* countrycode = country code
g countrycode = "`countrycode'"

* year = Year
g year = `year'

* int_year = interview year
g		int_year = 2011 if inlist(Sub_Round,"1","2")
replace	int_year = 2012 if inlist(Sub_Round,"3","4")

* int_month = interview month
gen  int_month = substr(Date_of_Survey, -4, 2)
destring int_month, replace

* hhid = Household identifier
egen str9 hhid = concat(FSU_Serial_No Hamlet_Group_Sub_Block_No Second_Stage_Stratum_No Sample_Hhld_No)

* pid = Personal identifier
egen  str11 pid = concat(hhid Person_Serial_No)

* confirm unique identifiers: hhid + pid
isid hhid pid

* weight = Household weight
gen weight = Multiplier_comb

* relationharm = Relationship to head of household harmonized across all regions
destring(Relation_to_Head), gen(relationharm)
recode relationharm (3 5 = 3) (7=4) (4 6 8 = 5) (9=7) (0=.)

* relationcs = Original relationship to head of household
gen relationcs = Relation_to_Head

* household member. All excluding household workers
gen hhmember=(relationharm!=7)

* hsize = Household size, not including household workers
bys hhid: egen hsize=total(hhmember)

* strata = Strata
g strata = Stratum

* psu = PSU
g psu = FSU_Serial_No

* spdef = Spatial deflator (if one is used)
g spdef = .

* subnatid1 = Subnational ID - highest level
destring State, gen(subnatid1)

* subnatid2 = Subnational ID - second highest level
egen subnatid2 = concat(State District), punct(-)

* subnatid3 = Subnational ID - third highest level
g subnatid3 = ""

* urban = Urban (1) or rural (0)
destring Sector, gen(urban)
recode urban (1 = 0) (2 = 1)

* language = Language
g language = ""

* age = Age of individual (continuous)
g age = Age

* male = Sex of household member (male=1)
destring Sex, gen(male)
recode male (2 = 0)

* marital = Marital status
destring Marital_Status, gen(marital)
recode marital (1 = 2) (2 = 1) (3 = 5)

* eye_dsablty = Difficulty seeing
g eye_dsablty = .

* hear_dsablty = Difficulty hearing
g hear_dsablty = .

* walk_dsablty = Difficulty walking or climbing steps
g walk_dsablty = .

* conc_dsord = Difficulty remembering or concentrating
g conc_dsord = .

* slfcre_dsablty = Difficulty with self-care
g slfcre_dsablty = .

* comm_dsablty = Difficulty communicating
g comm_dsablty = .

* educat7 = Highest level of education completed (7 categories)
*from: educational level - general:
*not literate -01, 
*literate without formal schooling: 
**EGS/ NFEC/ AEC -02, TLC -03, others -04; 
*literate: 
**below primary -05, primary -06, middle -07, secondary -08, higher secondary -10, diploma/certificate course -11, graduate -12, postgraduate and above -13.
destring General_Education, gen(geneducation)
recode geneducation (1/4=1) (5=2) (6=3) (7=4) (8/10=5) (11=6) (12/13=7) (*=.o), g(educat7)

* educat5 = Highest level of education completed (5 categories)
recode educat7 (0=0) (1=1) (2=2) (3/4=3) (5=4) (6/7=5), g(educat5)

* educat4 = Highest level of education completed (4 categories)
recode educat7 (0=0) (1=1) (2/3=2) (4/5=3) (6/7=4), g(educat4)

* educy = Years of completed education
g educy = .

* literacy = Individual can read and write
recode geneducation (1=0) (2/13=1), g(literacy)

* cellphone_i = Ownership of a cell phone (individual)
g cellphone_i = .

* computer = Ownership of a computer
g computer = .

* etablet = Ownership of a electronic tablet
g etablet = .

* internet_athome = Internet available at home, any service (including mobile)
g internet_athome = .

* internet_mobile = has mobile Internet (mobile 2G 3G LTE 4G 5G ), any service
g internet_mobile = .

* internet_mobile4Gplus = has mobile high speed internet (mobile LTE 4G 5G ) services
g internet_mobile4Gplus = .

*********************
* labor

* minlaborage_year = Labor module application age (12-mon ref period)
g minlaborage_year = 0

* lstatus_year = Labor status (12-mon ref period)
destring Usual_Principal_Activity_Status, gen(prn_status)
recode prn_status (11/51 = 1) (81=2) (91/97=3) (99=.a) (*=.), g(lstatus_year)

* nlfreason_year = Reason not in the labor force (12-mon ref period)
recode prn_status (91=1) (92 93=2) (94=3) (95=4) (97=5) (*=.) if lstatus_year==3, g(nlfreason_year)

* unempldur_l_year = Unemployment duration (months) lower bracket (12-mon ref period)
destring Spell_of_unemployment, gen(duration_unemp)
recode duration_unemp (1 2 3 = 0) (4=1) (5=2) (6=5) (7=6) (8=12) (*=.) if lstatus_year==2, g(unempldur_l_year)

* unempldur_u_year = Unemployment duration (months) upper bracket (12-mon ref period)
recode duration_unemp (1 2 =0) (3=1) (4=2) (5=3) (6=6) (7=12) (*=.) if lstatus_year==2, g(unempldur_u_year)

* empstat_year = Employment status, primary job (12-mon ref period)
recode prn_status (11=4) (12=3) (61 62 21=2) (31 41 42 51 52 71 72 98 =1) (81/97 99=.) (*=.) if lstatus_year==1, g(empstat_year)

* ocusec_year = Sector of activity, primary job (12-mon ref period)
destring Enterprise_Type, g(prn_enterprise)
recode prn_enterprise (1/4 6/8 =2) (5=1) (9=4) (*=.) if lstatus_year==1, g(ocusec_year)

* industry_orig_year = Original industry code, primary job (12-mon ref period)
gen industry_orig_year = Usual_Principal_Activity_NIC2008
replace industry_orig_year = "" if lstatus_year~=1

* industrycat10_year = 1 digit industry classification, primary job (12-mon ref period)
destring industry_orig_year, gen(prn_industry)
gen industrycat10_year = floor(prn_industry/1000) if lstatus_year==1
recode industrycat10_year (1/3=1) (5/9=2) (10/33=3) (35/39=4) (41/43=5) (45/47 55/56=6) (49/53 58/63 79=7) (64/68=8) (84=9) (69/78 80/82 85/99=10) (*=.)
	
* industrycat4_year = 4-category industry classification, primary job (12-mon ref period)
recode industrycat10_year (1=1) (2/5=2) (6/9=3) (10=4) if lstatus_year==1, g(industrycat4_year)

* occup_orig_year = Original occupational classification, primary job (12-mon ref period)
g occup_orig_year = Usual_Principal_Activity_NCO2004 if lstatus_year==1

* occup_year = 1 digit occupational classification, primary job (12-mon ref period)
destring occup_orig_year, gen(prn_occ) force
g occup_year = floor(prn_occ/100) if lstatus_year==1

* contract_year = Contract (12-mon ref period)
destring Type_of_Job_Contract, gen(prn_job_contract)
recode prn_job_contract (1=0) (2/4=1) if lstatus_year==1, g(contract_year)

* socialsec_year = Social security (12-mon ref period)
destring(Social_Security_Benefits), g(prn_soc_security)

la def prn_soc_security ///
1 "pension" ///
2 "gratuity" ///
3 "health" ///
4 "pension and gratuity" ///
5 "pension and health" ///
6 "gratuity and health" ///
7 "pension, gratuity, and health" ///
8 "none" ///
9 "not known" 
la val prn_soc_security prn_soc_security

recode prn_soc_security (1/7=1) (8=0) (*=.) if lstatus_year==1, g(socialsec_year)

* healthins_year = Health insurance (12-mon ref period)
recode prn_soc_security (3 5/7=1) (1 2 4 8=0) (*=.) if lstatus_year==1, g(healthins_year)

* pensions_year = Pension main activity (12-mon ref period)
recode prn_soc_security (1 4 5 7=1) (2 3 6 8=0) (*=.) if lstatus_year==1, g(pensions_year)

* paid_leave_year = Eligible for any paid leave, primary job (12-mon ref period)
destring(Eligible_for_Paid_Leave), g(prn_paid_leave)
g paid_leave_year = (prn_paid_leave==1) if lstatus_year==1 & ~missing(prn_paid_leave)

* union_year = Union membership (12-mon ref period)
gen byte union_year = .
replace union_year = 0 if Any_union_association == "2"
replace union_year = 0 if Any_union_association == "1" & Member_union_association == "2"
replace union_year = 1 if Any_union_association == "1" & Member_union_association == "1"
replace union_year = . if missing(empstat_year)

* firmsize_l_year = Firm size (lower bracket), primary job (12-mon ref period)
destring No_of_Workers_in_Enterprise, g(prn_n_workers)
recode prn_n_workers (1=1) (2=6) (3=10) (4=20) (*=.) if lstatus_year==1, g(firmsize_l_year)

* firmsize_u_year = Firm size (upper bracket), primary job (12-mon ref period)
recode prn_n_workers (1=5) (2=9) (3=19) (*=.) if lstatus_year==1, g(firmsize_u_year)

* empldur_orig_year = Original employment duration/tenure, primary job (12-mon ref period)
* empldur_orig_2_year = Original employment duration/tenure, second job (12-mon ref period)
g empldur_orig_year = .
g empldur_orig_2_year = .

* empstat_2_year = Employment status, secondary job (12-mon ref period)
destring Status2, gen(sub_status)
recode sub_status (11=4) (12=3) (61 62 21=2) (31 41 42 51 52 71 72 98 =1) (81/97 99=.) (*=.) if lstatus_year==1, g(empstat_2_year)

* ocusec_2_year = Sector of activity, secondary job (12-mon ref period)
destring Enterprise_Type2, g(sub_enterprise)
recode sub_enterprise (1/4 7 10/12=2) (5/6=1) (8=4) (*=.) if lstatus_year==1, g(ocusec_2_year)

* industry_orig_2_year = Original industry code, secondary job (12-mon ref period)
g industry_orig_2_year = NIC_2008_Code2 if lstatus_year==1
replace industry_orig_2 = "" if missing(empstat_2_year)

* industrycat10_2_year = 1 digit industry classification, secondary job (12-mon ref period)
destring industry_orig_2_year, gen(sub_industry)
recode sub_industry (1/3=1) (4/9=2) (10/33=3) (35/39=4) (41/43=5) (45/47 55/56=6) (49/53 58/63 79=7) (64/68=8) (84=9) (69/78 80/82 85/99=10) (*=.) if lstatus_year==1, g(industrycat10_2_year)

* industrycat4_2_year = 4-category industry classification, secondary job (12-mon ref period)
recode industrycat10_2_year (1=1) (2/5=2) (6/9=3) (10=4) if lstatus_year==1, g(industrycat4_2_year)

* occup_orig_2_year = Original occupational classification, secondary job (12-mon ref period)
g occup_orig_2_year = Usual_SubsidiaryActivity_NCO2004 if lstatus_year==1

* occup_2_year = 1 digit occupational classification, secondary job (12-mon ref period)
destring occup_orig_2_year, gen(sub_occ) force
g occup_2_year = floor(sub_occ/100) if lstatus_year==1

* paid_leave_2_year = Eligible for paid leave, secondary job (12-mon ref period)
g paid_leave_2_year = .

* pensions_2_year = Eligible for pension, secondary job (12-mon ref period)
destring(Social_Security_Benefits2), g(sub_soc_security)
recode sub_soc_security (1 4 5 7=1) (2 3 6 8=0) (*=.) if lstatus_year==1, g(pensions_2_year)

* wmonths_2 = Months worked in the last 12 months for the secondary job
g wmonths_2 = .

* wage_total_2 = Secondary job total wage
g wage_total_2 = .

* firmsize_l_2_year = Firm size (lower bracket), secondary job (12-mon ref period)
destring No_of_Workers_in_Enterprise2, g(sub_n_workers)
recode sub_n_workers (1=1) (2=6) (3=10) (4=20) (*=.) if lstatus_year==1, g(firmsize_l_2_year)

* firmsize_u_2_year = Firm size (upper bracket), secondary job (12-mon ref period)
recode sub_n_workers (1=5) (2=9) (3=19) (*=.) if lstatus_year==1, g(firmsize_u_2_year)

* njobs = Total number of jobs
g njobs = .
replace njobs = 1 if !missing(empstat_year)
replace njobs = 2 if !missing(empstat_2_year)

* variables for other jobs: none can be created
* unitwage_o = Time unit of last wages payment, other jobs (7-day ref period)
* wage_nc_o = Last week wage payment other jobs (different than primary and secondary)
* wage_nc_week_o = Wage payment adjusted to 1 week, other jobs, excl. bonuses, etc. (7-day ref period)
* wage_total_o = Annualized total wage, other job (7-day ref period)
* whours_o = Hours of work in last week for other jobs
* wmonths_o = Months worked in the last 12 months for the others jobs
foreach var in unitwage_o wage_nc_o wage_nc_week_o wage_total_o whours_o wmonths_o {
	g `var' = .
}

*************
* 7-day recall activities

* minlaborage = Labor module application age (7-day ref period)
g minlaborage = 0

* lstatus = Labor status (7-day ref period)
destring Current_Weekly_Activity_Status, gen(status_cws)
recode status_cws (11/72 98=1) (81=2) (82 91/97=3) (*=.), g(lstatus)

* empstat = Employment status, primary job (7-day ref period)
recode status_cws (11=4) (12=3) (61 62 21=2) (31 41 42 51 52 71 72 98 =1) (81/97 99=.) (*=.) if lstatus==1, g(empstat)


// * match daily recall jobs to priamry week recall job
// forval day = 1/7 {
// 	g		act_job1_day`day' = 2 if (status_cws==status_act2_day`day') & (nic_cws==industry_act2_day`day') & !mi(status_cws) & !mi(nic_cws)
// 	replace act_job1_day`day' = 1 if (status_cws==status_act1_day`day') & (nic_cws==industry_act1_day`day') & !mi(status_cws) & !mi(nic_cws)
// 	* identify each day's other activity
// 	recode act_job1_day`day' (2=1) (*=2), g(act_joboth_day`day')
// 	* consolidate job attribute variables from daily recall activities 1 and 2 into ones for the current week main activity, and other activity
// 	foreach job_attribute in status industry hours wage {
// 		foreach activity in job1 joboth {
// 			clonevar `job_attribute'_`activity'_day`day'=`job_attribute'_act1_day`day'  if act_`activity'_day`day'==1
// 			replace `job_attribute'_`activity'_day`day'=`job_attribute'_act2_day`day'  if act_`activity'_day`day'==2 
// 		}
// 	}
// }

// * aggregate primary job status, industry, weekly hours (for everyone), and weekly wages (for casual workers)
// egen status_job1_week = rowmin(status_job1_day?)
// egen industry_job1_week = rowmin(industry_job1_day?)
// egen hours_job1_week = rowtotal(hours_job1_day?), missing
// egen wage_job1_week = rowtotal(wage_job1_day?), missing

// * aggregate secondary job status, industry, weekly hours (for everyone), and weekly wages (for casual workers)
// * step 1: find daily recall second job, based on which status+industry combo has the most # of hours among other (non-primary job) activities.
// tempfile all_individual_data
// save `all_individual_data'
// keep hhid pid *_joboth_day?
// * reshape wide data (IDs: hhid + pid) to long format (unique IDs: hhid + pid + day)
// reshape long status_joboth_day industry_joboth_day hours_joboth_day wage_joboth_day, i(hhid pid) j(day)
// * keep only observations with other jobs, to reduce compute time
// keep if ~mi(status_joboth_day)
// * step 2: sum hours and wages for each person's jobs (status + industry)
// collapse (sum) hours_joboth_day wage_joboth_day, by(hhid pid status_joboth_day industry_joboth_day)
// * step 3: sort jobs by highest hours first, and break ties in # of hours by keeping the highest wage job, and if that is tied break ties using status code and industry code (ie arbitrary but consistent across executions of the do file).
// * note: cannot use "egen hours_joboth_rank = rank(-hours_joboth_day), by(hhid pid) unique" because it breaks ties arbitrarily
// gsort hhid pid -hours_joboth_day -wage_joboth_day status_joboth_day industry_joboth_day
// * step 4: keep only second job (most # of hours among remaining jobs - see step 3 for how ties in # of hours are broken)
// keep if pid~=pid[_n-1]
// * rename variables to indentify they are for the 2nd job, and aggregated to the week
// rename *_joboth_* *_job2_*
// rename *_day *_week
// * merge variables back into the full individual data
// merge 1:1 hhid pid using `all_individual_data', nogen assert(using match)

* match week-recall job1 with 12-month recall job: 1 "1st job - from section 5.1", 2 "2nd job - from section 5.2"
* step 1: match by exact occupation
	destring Current_Weekly_Activity_NCO_2004, g(cws_occupation) force
	* last week job1 occupation = 2nd occupation if they match and are non-missing
	g		lastweek_job1_12mojob = 2 if (cws_occupation==sub_occ) & ~missing(cws_occupation)
	* last week job1 occupation = 1st occupation if they match and are non-missing
	replace lastweek_job1_12mojob = 1 if (cws_occupation==prn_occ) & ~missing(cws_occupation)
* step 2: match by status and aggregate occupation category
	* last week job1 status = 12-month job1 status AND last week job1 aggregate occupation category = 12-month job1 aggregate occupation category AND last week status and occupation are non-missing
	replace lastweek_job1_12mojob = 1 if missing(lastweek_job1_12mojob) & (status_cws==prn_status) & (floor(cws_occupation/100)==floor(prn_occ/100)) & ~missing(status_cws) & ~missing(cws_occupation)
	* last week job1 status = 12-month job2 status AND last week job1 aggregate occupation category = 12-month job2 aggregate occupation category AND last week status and occupation are non-missing
	replace lastweek_job1_12mojob = 2 if missing(lastweek_job1_12mojob) & (status_cws==sub_status) & (floor(cws_occupation/100)==floor(sub_occ/100)) & ~missing(status_cws) & ~missing(cws_occupation)



* empstat_2 = Employment status, secondary job (7-day ref period)
destring Status2, gen(status_job2_week)
recode status_job2_week (11=4) (12=3) (61 62 21=2) (31 41 42 51 52 71 72 98 =1) (81/97 99=.) (*=.) if lstatus==1, g(empstat_2)

* wage_nc = Wage payment, primary job, excl. bonuses, etc. (7-day ref period)
g wage_nc = Wage_and_Salary_Earnings_Total1 if lstatus==1 

* unitwage = Time unit of last wages payment, primary job (7-day ref period)
gen byte unitwage = 2 if lstatus == 1

* wage_nc_week = Wage payment adjusted to 1 week, primary job, excl. bonuses, etc. (7-day ref period)
g wage_nc_week = wage_nc
	
* wage_nc_2 = Wage payment, secondary job, excl. bonuses, etc. (7-day ref period)
g wage_nc_2 = Wage_and_Salary_Earnings_Total2 if lstatus==1 

* unitwage_2 = Time unit of last wages payment, secondary job (7-day ref period)
gen byte unitwage_2 = 2 if lstatus == 1

* wage_nc_week_2 = Wage payment adjusted to 1 week, secondary job, excl. bonuses, etc. (7-day ref period)
g wage_nc_week_2 = wage_nc_2

* whours = Hours of work in last week main activity
g whours = 8*(Total_no_days_in_each_activity1/10) if lstatus==1

* whours_2 = Hours of work in last week for the secondary job
g whours_2 = 8*(Total_no_days_in_each_activity2/10) if lstatus==1

* contract = Contract (7-day ref period)
g		contract = contract_year if lastweek_job1_12mojob==1 & lstatus==1

* from 12-month recall secondary job
destring Type_of_Job_Contract2, g(sub_job_contract)
recode sub_job_contract (1=0) (2/4=1) if lstatus_year==1, g(contract_2_year)
replace	contract = contract_2_year if lastweek_job1_12mojob==2 & lstatus==1

* empldur_orig = Original employment duration/tenure, primary job (7-day ref period)
g		empldur_orig = empldur_orig_year if lastweek_job1_12mojob==1 & lstatus==1
replace	empldur_orig = empldur_orig_2_year if lastweek_job1_12mojob==2 & lstatus==1

* firmsize_l = Firm size (lower bracket), primary job (7-day ref period)
g		firmsize_l = firmsize_l_year if lastweek_job1_12mojob==1 & lstatus==1
replace	firmsize_l = firmsize_l_2_year if lastweek_job1_12mojob==2 & lstatus==1

* firmsize_u = Firm size (upper bracket), primary job (7-day ref period)
g		firmsize_u = firmsize_u_year if lastweek_job1_12mojob==1 & lstatus==1
replace	firmsize_u = firmsize_u_2_year if lastweek_job1_12mojob==2 & lstatus==1

* healthins = Health insurance (7-day ref period)
g		healthins = healthins_year if lastweek_job1_12mojob==1 & lstatus==1
* from 12-month recall secondary job
recode sub_soc_security (3 5/7=1) (1 2 4 8=0) (*=.) if lstatus_year==1, g(healthins_2_year)
replace healthins = healthins_2_year if lastweek_job1_12mojob==2 & lstatus==1

* industry_orig = Original industry code, primary job (7-day ref period)
gen industry_orig = Current_Weekly_Activity_NIC_2008
replace industry_orig = "" if lstatus~=1

* industry_orig_2 = Original industry code, secondary job (7-day ref period)
gen industry_orig_2 = NIC_2008_Code2
replace industry_orig_2 = "" if lstatus~=1

* industrycat10 = 1 digit industry classification, primary job (7-day ref period)
destring Current_Weekly_Activity_NIC_2008, gen(nic_cws)
gen industrycat10 = floor(nic_cws/1000) if lstatus==1
recode industrycat10 (1/3=1) (5/9=2) (10/33=3) (35/39=4) (41/43=5) (45/47 55/56=6) (49/53 58/63 79=7) (64/68=8) (84=9) (69/78 80/82 85/99=10) (*=.)
	
* industrycat10_2 = 1 digit industry classification, secondary job (7-day ref period)
destring industry_orig_2, gen(industry_job2_week)
recode industry_job2_week (1/3=1) (4/9=2) (10/33=3) (35/39=4) (41/43=5) (45/47 55/56=6) (49/53 58/63 79=7) (64/68=8) (84=9) (69/78 80/82 85/99=10) (*=.) if lstatus==1, g(industrycat10_2)

* industrycat4 = 4-category industry classification, primary job (7-day ref period)
recode industrycat10 (1=1) (2/5=2) (6/9=3) (10=4) if lstatus==1, g(industrycat4)

* industrycat4_2 = 4-category industry classification, secondary job (7-day ref period)
recode industrycat10_2 (1=1) (2/5=2) (6/9=3) (10=4) if lstatus==1, g(industrycat4_2)

* nlfreason = Reason not in the labor force (7-day ref period)
recode status_cws (91=1) (92 93=2) (94=3) (95=4) (97=5) (*=.) if lstatus==3, g(nlfreason)

* occup_orig = Original occupational classification, primary job (7-day ref period)
gen occup_orig = Current_Weekly_Activity_NCO_2004
replace occup_orig = "" if lstatus~=1

* occup = 1 digit occupational classification, primary job (7-day ref period)
g occup = floor(cws_occupation/100) if lstatus==1

* ocusec = Sector of activity, primary job (7-day ref period)
g		ocusec = ocusec_year if lastweek_job1_12mojob==1 & lstatus==1
replace	ocusec = ocusec_2_year if lastweek_job1_12mojob==2 & lstatus==1

* ocusec_2 = Sector of activity, secondary job (7-day ref period)
g ocusec_2 = .

* paid_leave = Eligible for paid leave, primary job (7-day ref period)
g		paid_leave = paid_leave_year if lastweek_job1_12mojob==1 & lstatus==1
replace	paid_leave = paid_leave_2_year if lastweek_job1_12mojob==2 & lstatus==1

* paid_leave_2 = Eligible for paid leave, secondary job (7-day ref period)
g paid_leave_2 = .

* pensions = Eligible for pension, primary job (7-day ref period)
g		pensions = pensions_year if lastweek_job1_12mojob==1 & lstatus==1
replace pensions = pensions_2_year if lastweek_job1_12mojob==2 & lstatus==1

* pensions_2 = Eligible for pension, secondary job (7-day ref period)
g pensions_2 = .

* socialsec = Social security (7-day ref period)
g		socialsec = socialsec_year if lastweek_job1_12mojob==1 & lstatus==1
* from 12-month recall secondary job
recode sub_soc_security (1/7=1) (8=0) (*=.) if lstatus_year==1, g(socialsec_2_year)
replace	socialsec = socialsec_2_year if lastweek_job1_12mojob==2 & lstatus==1

* unempldur_l = Unemployment duration (months) lower bracket (7-day ref period)
g unempldur_l = unempldur_l_year if lstatus==2

* unempldur_u = Unemployment duration (months) upper bracket (7-day ref period)
g unempldur_u = unempldur_u_year if lstatus==2

* wage_total = Annualized total wage, primary job (7-day ref period)
g wage_total = .

* wmonths = Months worked in the last 12 months main activity
g wmonths = .

* union = Union membership (7-day ref period)
g union = union_year if lastweek_job1_12mojob==1 & lstatus==1



foreach var in sick_leave sick_leave_year maternity_leave maternity_leave_year annual_leave annual_leave_year wmore stable_occup {
	g `var' = .
}

* label all SARLD harmonized variables and values
do "${rootlabels}/label_SARLAB_variables.do"
save "${output}/`surveyfolder'_v`vm'_M_v`va'_A_`type'_TMP", replace
keep ${keepharmonized}
* save harmonized data
save "${output}/`surveyfolder'_v`vm'_M_v`va'_A_`type'_IND", replace
