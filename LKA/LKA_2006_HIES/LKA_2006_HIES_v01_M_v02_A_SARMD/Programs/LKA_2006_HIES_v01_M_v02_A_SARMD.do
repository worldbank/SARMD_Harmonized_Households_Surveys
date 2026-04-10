/*****************************************************************************************************
******************************************************************************************************
**                                                                                                  **
**                                   SOUTH ASIA MICRO DATABASE                                      **
**                                                                                                  **
** COUNTRY			Sri Lanka
** COUNTRY ISO CODE	LKA
** YEAR				2006
** SURVEY NAME		HOUSEHOLD INCOME AND EXPENDITURE SURVEY - 2006/07
** SURVEY AGENCY	NATIONAL HOUSEHOLD SAMPLE SURVEY PROGRAMME
** RESPONSIBLE		Triana Yentzen
**                                                                                                  **
******************************************************************************************************
*****************************************************************************************************/

/*****************************************************************************************************
*                                                                                                    *
                                   INITIAL COMMANDS
*                                                                                                    *
*****************************************************************************************************/


** INITIAL COMMANDS
	cap log close 
	clear
	set more off
	set mem 800m

	
** DIRECTORY
	local input "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\LKA\LKA_2006_HIES\LKA_2006_HIES_v01_M"
	local output "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\LKA\LKA_2006_HIES\LKA_2006_HIES_v01_M_v02_A_SARMD\"

** LOG FILE
	log using "`output'\Doc\Technical\LKA_2006_HIES_v01_M_v02_A_SARMD.log",replace


/*****************************************************************************************************
*                                                                                                    *
                                   * ASSEMBLE DATABASE
*                                                                                                    *
*****************************************************************************************************/


** DATABASE ASSEMBLENT

* PREPARE DATABASES

* School Education
	use "`input'\Data\Stata\sec_2_school_education.dta", clear
	gen double HID=district*1000000 + psu *1000 + sample_n*10 + serial_no
	ren r2_person_serial serial_no_sec_1
	sort HID serial_no_sec_1
	tempfile education
	save `education'
	
* Employment & Income
	use "`input'\Data\Stata\sec_5_1_emp_incomeV2.dta"
	gen double HID=district*1000000 + psu *1000 + sample_n*10 + serial_no
	sort HID serial_no_sec_1 pri_sec
	bys HID serial_no_sec_1: gen n=_n
	replace n=n-1
	bys HID serial_no_sec_1: egen njobs=max(n)
	drop if pri_sec==2
	sort HID serial_no_sec_1 wages_salaries
	duplicates tag HID serial_no_sec_1, gen(tag)
	drop if tag==1 & pri_sec==.
	drop pri_sec tag n
	tempfile employment
	save `employment'
	
*	Housing
	use "`input'\Data\Stata\sec_8_housing.dta", clear
	gen double HID=district*1000000 + psu *1000 + sample_n*10 + serial_no
	sort HID
	tempfile housing
	save `housing'

* Durable Goods
	use "`input'\Data\Stata\sec_6a_durable_goodsV2.dta", clear
	gen double HID=district*1000000 + psu *1000 + sample_n*10 + serial_no
	sort HID
	tempfile durgoods
	save `durgoods'
		
* MERGE

* Demographic
	use "`input'\Data\Stata\sec_1_demographic.dta"
	gen double HID=district*1000000 + psu *1000 + sample_n*10 + serial_no
	ren person_serial_no serial_no_sec_1
	sort HID serial_no_sec_1

* School Education
	merge HID serial_no_sec_1 using `education'
	tab 	_merge
	drop 	_merge
	sort HID serial_no_sec_1

* Employmen & Income
	merge HID serial_no_sec_1 using `employment'
	tab 	_merge
	drop 	_merge
	sort HID serial_no_sec_1

* Housing
	merge HID using `housing'
	tab 	_merge
	drop 	_merge
	sort HID serial_no_sec_1

* Durable Goods
	merge HID using `durgoods'
	tab 	_merge
	drop 	_merge

* Consumption Aggregate

	gen district_s  = string(district, "%02.0f")
	gen psu_s = string(psu, "%03.0f")
	gen sample_s = string(sample, "%02.0f")
	gen hhno_s=string(serial_no)

	order district* psu* sample* hhno*
	egen hhid = concat( district_s  psu_s  sample_s hhno_s)
	assert hhid != ""
	lab var hhid "household id"

	merge m:1 hhid using "`input'\Data\Stata\wfile200607.dta"
	tab _merge
	keep if _merge==3
	
* Drop people not living in the house
	drop if serial_no_sec_1>=40
	
	
/*****************************************************************************************************
*                                                                                                    *
                                   * STANDARD SURVEY MODULE
*                                                                                                    *
*****************************************************************************************************/


** COUNTRY
*<_countrycode_>
	gen str4 countrycode="LKA"
	label var countrycode "Country code"
*</_countrycode_>


** YEAR
*<_year_>
	gen int year=2006
	label var year "Year of survey"
*</_year_>


** SURVEY NAME 
*<_survey_>
	gen str survey="HIES"
	label var survey "Survey Acronym"
*</_survey_>


** INTERVIEW YEAR
*<_int_year_>
	gen byte int_year=.
	label var int_year "Year of the interview"
*</_int_year_>
	
	
** INTERVIEW MONTH
*<_int_month_>
	gen byte int_month=month
	la de lblint_month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
	label value int_month lblint_month
	label var int_month "Month of the interview"
*</_int_month_>
	

	tostring HID, replace
	tostring serial_no, replace

	
** HOUSEHOLD IDENTIFICATION NUMBER
*<_idh_>
	egen idh=concat(HID serial_no)
	label var idh "Household id"
*</_idh_>

	tostring serial_no_sec_1, gen(INDID)

	
** INDIVIDUAL IDENTIFICATION NUMBER
*<_idp_>

	egen idp=concat(idh INDID)
	label var idp "Individual id"
*</_idp_>
	destring INDID, replace


** HOUSEHOLD WEIGHTS
*<_wgt_>
	gen double wgt=weight
	label var wgt "Household sampling weight"
*</_wgt_>


** STRATA
*<_strata_>
	gen strata=.
	label var strata "Strata"
*</_strata_>


** PSU
*<_psu_>
	*gen psu= psu
	label var psu "Primary sampling units"
*</_psu_>

	
** MASTER VERSION
*<_vermast_>

	gen vermast="02"
	label var vermast "Master Version"
*</_vermast_>
	
	
** ALTERATION VERSION
*<_veralt_>

	gen veralt="01"
	label var veralt "Alteration Version"
*</_veralt_>	
	
/*****************************************************************************************************
*                                                                                                    *
                                   HOUSEHOLD CHARACTERISTICS MODULE
*                                                                                                    *
*****************************************************************************************************/


** LOCATION (URBAN/RURAL)
*<_urban_>
	gen byte urban=sector
	recode urban (1=1) (2 3=0)
	label var urban "Urban/Rural"
	la de lblurban 1 "Urban" 0 "Rural"
	label values urban lblurban
*</_urban_>

** LOCATION (ESTATE)
*<_sector_>
*	gen byte sector=sector
	label define lblsector 1 "Urban" 2 "Rural" 3 "Estate"
	label values sector lblsector
	label var sector "Sector (Sri Lanka)"
*</_sector_>


** REGIONAL AREA 1 DIGIT ADMN LEVEL
*<_subnatid1_>
	gen byte subnatid1= province
	la de lblsubnatid1 1 "Western" 2 "Central" 3 "Southern" 4 "Northern" 5 "Eastern" 6 "North-Western" 7"North-Central" 8"Uva" 9"Sabaragamuwa"
	label var subnatid1 "Macro subnatid1al areas"
	label values subnatid1 lblsubnatid1
*</_subnatid1_>


** REGIONAL AREA 2 DIGIT ADMN LEVEL
*<_subnatid2_>
	gen byte subnatid2=district
	la de lblsubnatid2  11 "Colombo" 12 "Gampaha" 13 "Kalutara" 21 "Kandy" 22 "Matale" 23 "Nuwara-eliya" 31 "Galle" 32 "Matara" 33 "Hambantota" 41 "Jaffna" 42 "Mannar" 43 "Vavuniya" 44 "Mullaitivu" 45 "Kilinochchi" 51 "Batticaloa" 52 "Ampara" 53 "Tricomalee" 61 "Kurunegala" 62 "Puttlam" 71 "Anuradhapura" 72 "Polonnaruwa" 81 "Badulla" 82 "Moneragala" 91 "Ratnapura" 92 "Kegalle"
	label var subnatid2 "Region at 1 digit (ADMN1)"
	label values subnatid2 lblsubnatid2
*</_subnatid2_>

	
** REGIONAL AREA 3 DIGIT ADMN LEVEL
*<_subnatid3_>
	gen byte subnatid3=.
	label var subnatid3 "Region at 3 digit (ADMN3)"
	label values subnatid3 lblsubnatid3
*</_subnatid3_>


** HOUSE OWNERSHIP
*<_ownhouse_>
	gen byte ownhouse=.
	replace ownhouse=1 if  ownership<=4
	replace ownhouse=0 if  ownership>4
	label var ownhouse "House ownership"
	la de lblownhouse 0 "No" 1 "Yes"
	label values ownhouse lblownhouse
*</_ownhouse_>

** WATER PUBLIC CONNECTION
*<_water_>
	gen byte water=.
	replace water=1 if drinking_water==5 | drinking_water==6
	replace water=0 if drinking_water<5 | drinking_water>6
	label var water "Water main source"
	la de lblwater 0 "No" 1 "Yes"
	label values water lblwater
*</_water_>

** ELECTRICITY PUBLIC CONNECTION
*<_electricity_>

	gen byte electricity=.
	replace electricity=1 if lite_source==2
	replace electricity=0 if lite_source==1 | lite_source>2
	label var electricity "Electricity main source"
	la de lblelectricity 0 "No" 1 "Yes"
	label values electricity lblelectricity
*</_electricity_>

** TOILET PUBLIC CONNECTION
*<_toilet_>

	gen byte toilet=.
	replace toilet=1 if  toilet_type<=2
	replace toilet=0 if  toilet_type>=3
	label var toilet "Toilet facility"
	la de lbltoilet 0 "No" 1 "Yes"
	label values toilet lbltoilet
*</_toilet_>


** LAND PHONE
*<_landphone_>

	gen byte landphone=telephone
	recode landphone (2=0)
	label var landphone "Phone availability"
	la de lbllandphone 0 "No" 1 "Yes"
	label values landphone lbllandphone
*</_landphone_>


** CEL PHONE
*<_cellphone_>

	gen byte cellphone=telephone_mobile
	recode cellphone (2=0)
	label var cellphone "Cell phone"
	la de lblcellphone 0 "No" 1 "Yes"
	label values cellphone lblcellphone
*</_cellphone_>


** COMPUTER
*<_computer_>
	gen byte computer= computers
	recode computer (2=0)
	label var computer "Computer availability"
	la de lblcomputer 0 "No" 1 "Yes"
	label values computer lblcomputer
*</_computer_>


** INTERNET
	gen byte internet=.
	label var internet "Internet connection"
	la de lblinternet 0 "No" 1 "Yes"
	label values internet lblinternet



/*****************************************************************************************************
*                                                                                                    *
                                   DEMOGRAPHIC MODULE
*                                                                                                    *
*****************************************************************************************************/


** HOUSEHOLD SIZE
*<_hsize_>

	ren hhsize hsize
	la var hsize "Household size"
*</_hsize_>


** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
*<_relationharm_>
	gen byte relationharm=relationship
	recode relationharm ( 6/9=6)
	label var relationharm "Relationship to the head of household"
	la de lblrelationharm  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Non-relatives"
	label values relationharm  lblrelationharm
*</_relationharm_>

** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
*<_relationcs_>

	gen byte relationcs=relationship
	la var relationcs "Relationship to the head of household country/region specific"
	la define lblrelationcs 1 "Head" 2 "Wife/Husband" 3 "Son/Daughter" 4 "Parents" 5 "Other relative" 6 "Domestic servants" 7 "Boarder" 9 "Other"
	label values relationcs lblrelationcs
*</_relationcs_>


** GENDER
*<_male_>
	gen byte male=sex
	recode male (2=0)
	label var male "Sex of household member"
	la de lblmale 1 "Male" 0 "Female"
	label values male lblmale
*</_male_>

	
** AGE
*<_age_>
* Generate Age based on Month and Year of Birth for missing cases
	gen 	year_interview=2006 if month>=7 & month!=.
	replace year_interview=2007 if month<=6
	gen birth_year_b=.
	replace birth_year_b=2000 if birth_year<=7
	replace birth_year_b=1900 if birth_year>7 & birth_year!=.
	replace birth_year=birth_year+birth_year_b
	gen dob=mdy(birth_month,1,birth_year)
	gen date=mdy(month,1,year_interview)
	gen age_date=int((date-dob)/365)
	replace age_date=. if age!=.
	replace age_date=. if age_date!=. & relationship!=3
	replace age=age_date if age==. & age_date!=.	
	label var age "Age of individual"
*</_age_>

** SOCIAL GROUP
*<_soc_>
	gen byte soc=ethnicity
	recode soc (9=7)
	label var soc "Social group"
	la de lblsoc 1 "Sinhala" 2 "Sri Lanka Tamil" 3 "Indian Tamil" 4 "Sri Lanka Moors" 5 "Malay" 6 "Burgher" 7 "Other"
	label values soc lblsoc
*</_soc_>


** MARITAL STATUS
*<_marital_>
	gen byte marital=marital_status
	recode marital (1=2) (2=1) (3=5) (4/5=4)
	label var marital "Marital status"
	la de lblmarital 1 "Married" 2 "Never Married" 3 "Living Together" 4 "Divorced/separated" 5 "Widowed"
	label values marital lblmarital
*</_marital_>


/*****************************************************************************************************
*                                                                                                    *
                                   EDUCATION MODULE
*                                                                                                    *
*****************************************************************************************************/


** EDUCATION MODULE AGE
*<_ed_mod_age_>
	gen byte ed_mod_age=5
	label var ed_mod_age "Education module application age"
*</_ed_mod_age_>


** CURRENTLY AT SCHOOL
*<_atschool_>
	gen byte atschool=.
	replace atschool=1 if r2_school_education==1
	replace atschool=0 if r2_school_education==2 | r2_school_education==3
	label var atschool "Attending school"
	la de lblatschool 0 "No" 1 "Yes"
	label values atschool  lblatschool
*</_atschool_>


** CAN READ AND WRITE
*<_literacy_>
	gen byte literacy=.
	label var literacy "Can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy
*</_literacy_>


** YEARS OF EDUCATION COMPLETED
*<_educy_>
	gen byte educy=education
	recode educy  (17=.) (19 = 0) (14=13) (15 = 17) (16 = 19)
	label var educy "Years of education"
*</_educy_>
	replace educy=0 if education==19
	replace educy=. if educy>=age-2 & educy!=. & age!=.
	replace age=. 	if educy>=age-2 & educy!=. & age!=.

	
** EDUCATION LEVEL 7 CATEGORIES
*<_educat7_>
	gen byte educat7=education
	recode educat7 (19 = 1) (0/5 = 2) (6 = 3) (7/10 = 4) (11/14 = 5) (15/16 = 7) (17=.)
	replace educat7=. if age<5
	label define lbleducat7 1 "No education" 2 "Primary incomplete" 3 "Primary complete" ///
	4 "Secondary incomplete" 5 "Secondary complete" 6 "Higher than secondary but not university" /// 
	7 "University incomplete or complete" 8 "Other" 9 "Not classified"
	label values educat7 lbleducat7
	la var educat7 "Level of education 7 categories"
*</_educat7_>


	
** EDUCATION LEVEL 5 CATEGORIES
*<_educat5_>
	gen educat5=.
	replace educat5=1 if educat7==1
	replace educat5=2 if educat7==2
	replace educat5=3 if educat7==3 | educat7==4
	replace educat5=4 if educat7==5
	replace educat5=5 if educat7==6 | educat7==7
	label define lbleducat5 1 "No education" 2 "Primary incomplete" ///
	3 "Primary complete but secondary incomplete" 4 "Secondary complete" ///
	5 "Some tertiary/post-secondary"
	label values educat5 lbleducat5
*</_educat5_>

	la var educat5 "Level of education 5 categories"

	
** EDUCATION LEVEL 4 CATEGORIES
*<_educat4_>
	gen byte educat4=.
	replace educat4=1 if educat7==1 
	replace educat4=2 if educat7==2 | educat7==3
	replace educat4=3 if educat7==4 | educat7==5
	replace educat4=4 if educat7==6 | educat7==7
	label var educat4 "Level of education 4 categories"
	label define lbleducat4 1 "No education" 2 "Primary (complete or incomplete)" ///
	3 "Secondary (complete or incomplete)" 4 "Tertiary (complete or incomplete)"
	label values educat4 lbleducat4
*</_educat4_>


	
** EVER ATTENDED SCHOOL
*<_everattend_>
	gen byte everattend=.
	replace everattend=1 if r2_school_education==1 |  r2_school_education==3
	replace everattend=0 if r2_school_education==2
	label var everattend "Ever attended school"
	la de lbleverattend 0 "No" 1 "Yes"
	label values everattend lbleverattend
*</_everattend_>



foreach var in atschool literacy everattend educat4 educat5 educat7{
replace `var'=. if age<ed_mod_age
}

/*****************************************************************************************************
*                                                                                                    *
                                   LABOR MODULE
*                                                                                                    *
*****************************************************************************************************/


** LABOR MODULE AGE
*<_lb_mod_age_>

 gen byte lb_mod_age=10
	label var lb_mod_age "Labor module application age"
*</_lb_mod_age_>



** LABOR STATUS
*<_lstatus_>
	gen byte lstatus=main_act
	recode lstatus (3 4 5 6=3) (9=.)
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus
*</_lstatus_>


** EMPLOYMENT STATUS
*<_empstat_>
	gen byte empstat=employment_st
	recode empstat (1 2 3=1) (6=2) (4=3) (5=4) (9=.)
	label var empstat "Employment status"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed"
	label values empstat lblempstat
*</_empstat_>
	replace empstat=. if lstatus!=1

** SECTOR OF ACTIVITY: PUBLIC - PRIVATE
*<_njobs_>
	label var njobs "Number of additional jobs"
*</_njobs_>


** SECTOR OF ACTIVITY: PUBLIC - PRIVATE
*<_ocusec_>
	gen byte ocusec=employment_st
	recode ocusec (2=1) (3/6=2) (9=.)
	label var ocusec "Sector of activity"
	la de lblocusec 1 "Public, state owned, government, army, NGO" 2 "Private"
	label values ocusec lblocusec
*</_ocusec_>
	replace ocusec=. if lstatus!=1

** REASONS NOT IN THE LABOR FORCE
*<_nlfreason_>
	gen byte nlfreason=.
	replace nlfreason=1 if main_activity==3
	replace nlfreason=2 if main_activity==4
	replace nlfreason=5 if main_activity==5 | main_activity==6 | main_activity==9
	label var nlfreason "Reason not in the labor force"
	la de lblnlfreason 1 "Student" 2 "Housewife" 3 "Retired" 4 "Disable" 5 "Other"
	label values nlfreason lblnlfreason
*</_nlfreason_>	replace nlfreason=. if lstatus!=3

** UNEMPLOYMENT DURATION: MONTHS LOOKING FOR A JOB
*<_unempldur_l_>
	gen byte unempldur_l=.
	label var unempldur_l "Unemployment duration (months) lower bracket"
*</_unempldur_l_>

*<_unempldur_u_>

	gen byte unempldur_u=.
	label var unempldur_u "Unemployment duration (months) upper bracket"
*</_unempldur_u_>
	rename industry ind

** INDUSTRY CLASSIFICATION
*<_industry_>
	gen byte industry=.
	gen str4 ind_ISIC = string(  ind, "%04.0f") 
	gen ind_CODE=substr(ind_ISIC,1,2) 
	drop ind_ISIC
	destring ind_CODE, gen(ind_ISIC)

	replace industry=1 if ind_ISIC>=01 & ind_ISIC<=06 
	replace industry=2 if ind_ISIC>=10 & ind_ISIC<=14
	replace industry=3 if ind_ISIC>=15 & ind_ISIC<=37
	replace industry=4 if ind_ISIC>=40 & ind_ISIC<=41
	replace industry=5 if ind_ISIC>=45 & ind_ISIC<=45
	replace industry=6 if ind_ISIC>=50 & ind_ISIC<=55
	replace industry=7 if ind_ISIC>=60 & ind_ISIC<=64
	replace industry=8 if ind_ISIC>=65 & ind_ISIC<=74
	replace industry=9 if ind_ISIC>=75 & ind_ISIC<=75 
	replace industry=10 if ind_ISIC>=80 & ind_ISIC<=99
	replace industry=10 if industry==. & ind_ISIC!=.
	replace  industry=. if lstatus!=1
	label var industry "1 digit industry classification"
	la de lblindustry 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transports and comnunications" 8 "Financial and business-oriented services" 9 "Public Administration" 10 "Other services, unspecified"
	label values industry lblindustry
*</_industry_>

** OCCUPATION CLASSIFICATION
*<_occup_>
	gen byte occup=.
	rename  main_occupation ocu
	gen str4 ocu_ISCO = string(  ocu, "%04.0f") 
	gen ocu_CODE=substr(ocu_ISCO,1,1) 
	drop ocu_ISCO
	destring ocu_CODE, gen(ocu_ISCO)

	replace occup=ocu_ISCO
	replace occup=10 if ocu==0110
	replace  occup=. if lstatus!=1
	label var occup "1 digit occupational classification"
	la de lbloccup 1 "Senior officials" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup lbloccup
*</_occup_>


** FIRM SIZE
*<_firmsize_l_>
	gen byte firmsize_l=.
	label var firmsize_l "Firm size (lower bracket)"
*</_firmsize_l_>

*<_firmsize_u_>

	gen byte firmsize_u=.
	label var firmsize_u "Firm size (upper bracket)"

*</_firmsize_u_>


** HOURS WORKED LAST WEEK
*<_whours_>
	gen whours=.
	label var whours "Hours of work in last week"
*</_whours_>


** WAGES
*<_wage_>
	gen double wage=wages_salaries // LAST MONTH
	label var wage "Last wage payment"
*</_wage_>


** WAGES TIME UNIT
*<_unitwage_>
	gen byte unitwage=5
	label var unitwage "Last wages time unit"
	la de lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Quarterly" 7 "Biannual" 8 "Annually" 9 "Hourly" 10 "Other"
	label values unitwage lblunitwage
*</_wageunit_>


** CONTRACT
*<_contract_>
	gen byte contract=.
	label var contract "Contract"
	la de lblcontract 0 "Without contract" 1 "With contract"
	label values contract lblcontract
*</_contract_>


** HEALTH INSURANCE
*<_healthins_>
	gen byte healthins=.
	label var healthins "Health insurance"
	la de lblhealthins 0 "Without health insurance" 1 "With health insurance"
	label values healthins lblhealthins
*</_healthins_>


** SOCIAL SECURITY
*<_socialsec_>
	gen byte socialsec=.
	label var socialsec "Social security"
	la de lblsocialsec 1 "With" 0 "Without"
	label values socialsec lblsocialsec
*</_socialsec_>


** UNION MEMBERSHIP
*<_union_>
	gen byte union=.
	label var union "Union membership"
	la de lblunion 0 "No member" 1 "Member"
	label values union lblunion
*</_union_>


/*****************************************************************************************************
*                                                                                                    *
                                   WELFARE MODULE
*                                                                                                    *
*****************************************************************************************************/

	
** SPATIAL DEFLATOR
*<_spdef_>
	gen spdef=rpccons/(ncons/hsize)
	la var spdef "Spatial deflator"
*</_spdef_>

** WELFARE
*<_welfare_>
	gen welfare=ncons/hsize
	la var welfare "Welfare aggregate"
*</_welfare_>

*<_welfarenom_>
	gen welfarenom=ncons/hsize
	la var welfarenom "Welfare aggregate in nominal terms"
*</_welfarenom_>

*<_welfaredef_>
	gen welfaredef=rpccons
	la var welfaredef "Welfare aggregate spatially deflated"
*</_welfaredef_>

*<_welfshprosperity_>
	gen welfshprosperity=welfare
	la var welfshprosperity "Welfare aggregate for shared prosperity"
*</_welfshprosperity_>

*<_welfaretype_>
	gen welfaretype="EXP"
	la var welfaretype "Type of welfare measure (income, consumption or expenditure) for welfare, welfarenom, welfaredef"
*</_welfaretype_>

*<_welfareother_>
	gen welfareother=.
	la var welfareother "Welfare Aggregate if different welfare type is used from welfare, welfarenom, welfaredef"
*</_welfareother_>

*<_welfareothertype_>
	gen welfareothertype=""
	la var welfareothertype "Type of welfare measure (income, consumption or expenditure) for welfareother"
*</_welfareothertype_>

*<_welfarenat_>
	gen welfarenat=rpccons
	la var welfarenat "Welfare aggregate for national poverty"
*</_welfarenat_>	
/*****************************************************************************************************
*                                                                                                    *
                                   NATIONAL POVERTY
*                                                                                                    *
*****************************************************************************************************/


** POVERTY LINE (NATIONAL)
*<_pline_nat_>
	gen pline_nat=2142
	label variable pline_nat "Poverty Line (National)"
*</_pline_nat_>


** HEADCOUNT RATIO (NATIONAL)
*<_poor_nat_>
	gen poor_nat=welfarenat<pline_nat if welfarenat!=.
	la var poor_nat "People below Poverty Line (National)"
	la define poor_nat 0 "Not Poor" 1 "Poor"
	la values poor_nat poor_nat
*</_poor_nat_>


/*****************************************************************************************************
*                                                                                                    *
                                   INTERNATIONAL POVERTY
*                                                                                                    *
*****************************************************************************************************/


	local year=2011
	
** USE SARMD CPI AND PPP
*<_cpi_>
	capture drop _merge
	gen urb=.
	merge m:1 countrycode year urb using "D:\SOUTH ASIA MICRO DATABASE\DOCS\CPI and PPP\cpi_ppp_sarmd.dta", ///
	keepusing(countrycode year urb syear cpi`year'_w ppp`year')
	drop urb
	drop if _merge!=3
	drop _merge
	
	
** CPI VARIABLE
	ren cpi`year'_w cpi
	label variable cpi "CPI (Base `year'=1)"
*</_cpi_>
	
	
** PPP VARIABLE
*<_ppp_>
	ren ppp`year' 	ppp
	label variable ppp "PPP `year'"
*</_ppp_>

	
** CPI PERIOD
*<_cpiperiod_>
	gen cpiperiod=syear
	label var cpiperiod "Periodicity of CPI (year, year&month, year&quarter, weighted)"
*</_cpiperiod_>	
	
** POVERTY LINE (POVCALNET)
*<_pline_int_>
	gen pline_int=1.90*cpi*ppp*365/12
	label variable pline_int "Poverty Line (Povcalnet)"
*</_pline_int_>
	
	
** HEADCOUNT RATIO (POVCALNET)
*<_poor_int_>
	gen poor_int=welfare<pline_int & welfare!=.
	la var poor_int "People below Poverty Line (Povcalnet)"
	la define poor_int 0 "Not Poor" 1 "Poor"
	la values poor_int poor_int
*</_poor_int_>


/*****************************************************************************************************
*                                                                                                    *
                                   FINAL STEPS
*                                                                                                    *
*****************************************************************************************************/


** KEEP VARIABLES - ALL

	keep countrycode year survey idh idp wgt strata psu vermast veralt urban sector int_month int_year ///
		subnatid1 subnatid2 subnatid3 ownhouse water electricity toilet landphone cellphone ///
	     computer internet hsize relationharm relationcs male age soc marital ed_mod_age everattend ///
	     atschool electricity literacy educy educat4 educat5 educat7 lb_mod_age lstatus empstat njobs ///
	     ocusec nlfreason unempldur_l unempldur_u industry occup firmsize_l firmsize_u whours wage ///
		 unitwage contract healthins socialsec union pline_nat pline_int poor_nat poor_int spdef cpi ppp ///
		 cpiperiod welfare welfarenom welfaredef welfarenat welfareother welfaretype welfareothertype

** ORDER VARIABLES

	order countrycode year survey idh idp wgt strata psu vermast veralt urban sector int_month int_year ///
		subnatid1 subnatid2 subnatid3 ownhouse water electricity toilet landphone cellphone ///
	      computer internet hsize relationharm relationcs male age soc marital ed_mod_age everattend ///
	      atschool electricity literacy educy educat4 educat5 educat7 lb_mod_age lstatus empstat njobs ///
	      ocusec nlfreason unempldur_l unempldur_u industry occup firmsize_l firmsize_u whours wage ///
		 unitwage contract healthins socialsec union pline_nat pline_int poor_nat poor_int spdef cpi ppp ///
		 cpiperiod welfare welfarenom welfaredef welfarenat welfareother welfaretype welfareothertype
	
	compress

** DELETE MISSING VARIABLES

	local keep ""
	qui levelsof countrycode, local(cty)
	foreach var of varlist urban - welfareother {
	qui sum `var'
	scalar sclrc = r(mean)
	if sclrc==. {
	     display as txt "Variable " as result "`var'" as txt " for countrycode " as result `cty' as txt " contains all missing values -" as error " Variable Deleted"
	}
	else {
	     local keep `keep' `var'
	}
	}
	
	foreach w in welfare welfareother{
	qui su `w'
	if r(N)==0{
	drop `w'type
}
}
	keep countrycode year survey idh idp wgt strata psu vermast veralt `keep' *type
	compress


	saveold "`output'\Data\Harmonized\LKA_2006_HIES_v01_M_v02_A_SARMD_IND.dta", replace version(12)
	saveold "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\__REGIONAL\Individual Files\LKA_2006_HIES_v01_M_v02_A_SARMD_IND.dta", replace version(12)

	
	log close




******************************  END OF DO-FILE  *****************************************************/
