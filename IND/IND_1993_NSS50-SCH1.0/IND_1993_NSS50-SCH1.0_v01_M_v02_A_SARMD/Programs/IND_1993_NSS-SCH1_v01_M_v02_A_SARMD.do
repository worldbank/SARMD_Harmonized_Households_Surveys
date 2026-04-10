/*****************************************************************************************************
******************************************************************************************************
**                                                                                                  **
**                                   SOUTH ASIA MICRO DATABASE                                      **
**                                                                                                  **
** COUNTRY	India
** COUNTRY ISO CODE	IND
** YEAR	1993
** SURVEY NAME	SOCIO-ECONOMIC SURVEY  FIFTIETH ROUND JULY 1993-JUNE 1994
*	HOUSEHOLD SCHEDULE 1 
** SURVEY AGENCY	GOVERNMENT OF INDIA NATIONAL SAMPLE SURVEY ORGANISATION
** RESPONSIBLE	Triana Yentzen

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
	set mem 500m


** DIRECTORY
	local input "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\IND\IND_1993_NSS-SCH1\IND_1993_NSS-SCH1_v01_M"
	local output "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\IND\IND_1993_NSS-SCH1\IND_1993_NSS-SCH1_v01_M_v02_A_SARMD"

** LOG FILE
	log using "`output'\Doc\IND_1993_NSS-SCH1_v01_M_v02_A_SARMD.log",replace



/*****************************************************************************************************
*                                                                                                    *
                                   * ASSEMBLE DATABASE
*                                                                                                    *
*****************************************************************************************************/


** DATABASE ASSEMBLENT
	
	* PREPARE DATASETS

	use "`input'\Data\Stata\NSS50_Sch1_bk4.dta", clear
	order sector stratum subround FSU_No secstgstr hhno pid
	sort subsample sector stratum subround FSU_No secstgstr hhno pid

	ren pid indid
	drop hhid
	
	order FSU_No secstgstr hhno indid
	sort FSU_No secstgstr hhno indid
	
	ren FSU_No fsu
	ren secstgstr secondstage
	ren subround subrnd
	
	tempfile roster
	save `roster'
	
	use "`input'\Data\Stata\NSS50_Sch1_bk_1_31.dta", clear
	order sector stratum subround FSU_No secstgstr hhno
	sort subsample sector stratum subround FSU_No secstgstr hhno

	drop hhid
	
	order FSU_No secstgstr hhno
	sort FSU_No secstgstr hhno
	
	ren FSU_No fsu
	ren secstgstr secondstage
	ren subround subrnd
	
	tempfile household
	save `household'
	

	use "`input'\Data\Stata\NSS50_Sch1_bk12_13.dta", clear
	order sector stratum subround FSU_No secstgstr hhno
	sort subsample sector stratum subround FSU_No secstgstr hhno

	drop hhid
	
	order FSU_No secstgstr hhno
	sort FSU_No secstgstr hhno
	
	ren FSU_No fsu
	ren secstgstr secondstage
	ren subround subrnd
	
	tempfile dwelling
	save `dwelling'

	
	* COMBINE DATASETS
	
	use "`input'\Data\Stata\poverty50.dta", clear

	su pline_ind_93 [w=pwt]
	gen pline_mrp=r(mean)

	gen mpce_mrp_real=mpce_mrp*pline_mrp/pline

	sor hhid
	
*	gen pline_urp_sector=.
*	replace pline_urp_sector=236.6 if sector==1
*	replace pline_urp_sector=318.2 if sector==2

	su pline [w=pwt]
	gen pline_urp=r(mean)

	gen mpce_urp_real=mpce_urp*(pline_urp/pline)
	la var mpce_urp_real "Real PC Monthly Consumption (URP)"
	ren pline_ind_93 pline_mrp_sector

	keep hhsize hhid fsu secondstage hhno mpce_urp mpce_mrp mpce_urp_real mpce_mrp_real pline_urp pline_mrp pline_mrp_sector pline pwt

	order hhid fsu secondstage hhno mpce_urp mpce_mrp mpce_urp_real mpce_mrp_real pline_urp pline_mrp pline_mrp_sector pline pwt hhsize

	sort fsu secondstage hhno
	
	merge 1:m fsu secondstage hhno using `roster'
	drop if _merge==2
	drop _merge 
	
	merge m:1 fsu secondstage hhno using `household'
	drop if _merge==2
	drop _merge 
	
	merge m:1 fsu secondstage hhno using `dwelling'
	drop if _merge==2
	drop _merge 


/*****************************************************************************************************
*                                                                                                    *
                                   * STANDARD SURVEY MODULE
*                                                                                                    *
*****************************************************************************************************/

	
** COUNTRY
*<_countrycode_>
	gen str4 countrycode="IND"
	label var countrycode "Country code"
*</_countrycode_>


** YEAR
*<_year_>
	gen int year=1993
	label var year "Year of survey"
*</_year_>

** SURVEY NAME 
*<_survey_>
	gen str survey="NSS-SCH1"
	label var survey "Survey Acronym"
*</_survey_>

	
** INTERVIEW YEAR
*<_int_year_>
	gen byte int_year=.
	label var int_year "Year of the interview"
*</_int_year_>
	
	
** INTERVIEW MONTH
*<_int_month_>
	gen byte int_month=.
	la de lblint_month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
	label value int_month lblint_month
	label var int_month "Month of the interview"
*</_int_month_>
	

** HOUSEHOLD IDENTIFICATION NUMBER
*<_idh_>
	generate idh=string(hhid, "%15.0f")
	label var idh "Household id"
*</_idh_>


** INDIVIDUAL IDENTIFICATION NUMBER
*<_idp_>

	egen str idp=concat(idh indid)
	label var idp "Individual id"
*</_idp_>
	isid idp


** HOUSEHOLD WEIGHTS
*<_wgt_>
	gen wgt=MLT_combined/100
	label var wgt "Household sampling weight"
*</_wgt_>

** STRATA
*<_strata_>
	gen strata=stratum
	label var strata "Strata"
*</_strata_>

** PSU
*<_psu_>
	gen psu=fsu
	label var psu "Primary sampling units"
*</_psu_>
	
	
** MASTER VERSION
*<_vermast_>

	gen vermast="01"
	label var vermast "Master Version"
*</_vermast_>
	
	
** ALTERATION VERSION
*<_veralt_>

	gen veralt="02"
	label var veralt "Alteration Version"
*</_veralt_>	

/*****************************************************************************************************
*                                                                                                    *
                                   HOUSEHOLD CHARACTERISTICS MODULE
*                                                                                                    *
*****************************************************************************************************/


** LOCATION (URBAN/RURAL)
*<_urban_>
	gen urban=sector
	recode urb (2=1) (1=0)
	label var urban "Urban/Rural"
	la de lblurban 1 "Urban" 0 "Rural"
	label values urban lblurban
*</_urban_>


**REGIONAL AREAS
	recode state (1 2 3 4 6 8 = 1) (5 7 9 10 23 = 2) (12/18 = 3) (11 19 20 21 22 35 = 4) ( 24 25 26 27 30 = 5) (28 29 31 32 33 34 = 6), gen(subnatid1)
	label define lblsubnatid1 1 "Northern" 2 "North-Central" 3 "North-Eastern" 4 "Eastern" 5 "Western" 6 "Southern"
	label values subnatid1 lblsubnatid1
*</_subnatid1_>
	label var subnatid1 "Region at 1 digit (ADMN1)"
	label values subnatid1 lblsubnatid1
*</_subnatid1_>

** REGIONAL AREA 2 DIGIT ADMN LEVEL
*<_subnatid2_>

	/*
	ren state state_50
	stop

/*
state=.
*/
	g state=.
	replace state=35 if state_50==27
	replace state=28 if state_50==2
	replace state=12 if state_50==3
	replace state=18 if state_50==4
	replace state=10 if state_50==5
	replace state=4 if state_50==28
	replace state=22 if state_50==35
	replace state=26 if state_50==29
	replace state=25 if state_50==30
	replace state=7 if state_50==31
	replace state=30 if state_50==6
	replace state=24 if state_50==7
	replace state=6 if state_50==8
	replace state=2 if state_50==9
	replace state=1 if state_50==10
	replace state=20 if state_50==34
	replace state=29 if state_50==11
	replace state=32 if state_50==12
	replace state=31 if state_50==32
	replace state=23 if state_50==13
	replace state=27 if state_50==14
	replace state=14 if state_50==15
	replace state=17 if state_50==16
	replace state=15 if state_50==17
	replace state=13 if state_50==18
	replace state=21 if state_50==19
	replace state=34 if state_50==33
	replace state=3 if state_50==20
	replace state=8 if state_50==21
	replace state=11 if state_50==22
	replace state=33 if state_50==23
	replace state=16 if state_50==24
	replace state=9 if state_50==25
	replace state=5 if state_50==36
	replace state=19 if state_50==26
	lab var state "State recoded to 61st, 66th, and 68th state values"
	*/


	gen subnatid2=state
	label define lblsubnatid2 1 "Jammu & Kashmir", modify
	label define lblsubnatid2 2 "Himachal Pradesh", modify
	label define lblsubnatid2 3 "Punjab", modify
	label define lblsubnatid2 4 "Chandigarh", modify
	label define lblsubnatid2 5 "Uttaranchal", modify
	label define lblsubnatid2 6 "Haryana", modify
	label define lblsubnatid2 7 "Delhi", modify
	label define lblsubnatid2 8 "Rajasthan", modify
	label define lblsubnatid2 9 "Uttar Pradesh", modify
	label define lblsubnatid2 10 "Bihar", modify
	label define lblsubnatid2 11 "Sikkim", modify
	label define lblsubnatid2 12 "Arunachal Pradesh", modify
	label define lblsubnatid2 13 "Nagaland", modify
	label define lblsubnatid2 14 "Manipur", modify
	label define lblsubnatid2 15 "Mizoram", modify
	label define lblsubnatid2 16 "Tripura", modify
	label define lblsubnatid2 17 "Meghalaya", modify
	label define lblsubnatid2 18 "Assam", modify
	label define lblsubnatid2 19 "West Bengal", modify
	label define lblsubnatid2 20 "Jharkhand", modify
	label define lblsubnatid2 21 "Orissa", modify
	label define lblsubnatid2 22 "Chhattisgarh", modify
	label define lblsubnatid2 23 "Madhya Pradesh", modify
	label define lblsubnatid2 24 "Gujarat", modify
	label define lblsubnatid2 25 "Daman & Diu", modify
	label define lblsubnatid2 26 "Dadra & Nagar Haveli", modify
	label define lblsubnatid2 27 "Maharashtra", modify
	label define lblsubnatid2 28 "Andhra Pradesh", modify
	label define lblsubnatid2 29 "Karnataka", modify
	label define lblsubnatid2 30 "Goa", modify
	label define lblsubnatid2 31 "Lakshadweep", modify
	label define lblsubnatid2 32 "Kerala", modify
	label define lblsubnatid2 33 "Tamil Nadu", modify
	label define lblsubnatid2 34 "Pondicherry", modify
	label define lblsubnatid2 35 "A & N Islands", modify
	label var subnatid2 "Region at 2 digit (ADMN2)"
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
	gen ownhouse=.
	label var ownhouse "House ownership"
	la de lblownhouse 0 "No" 1 "Yes"
	label values ownhouse lblownhouse
*</_ownhouse_>
** WATER PUBLIC CONNECTION
*<_water_>
	gen water=.
	label var water "Water main source"
	la de lblwater 0 "No" 1 "Yes"
	label values water lblwater
*</_water_>

** ELECTRICITY PUBLIC CONNECTION
*<_electricity_>

	gen electricity=S1B31_v22==5
	label var electricity "Electricity main source"
	la de lblelectricity 0 "No" 1 "Yes"
	label values electricity lblelectricity
*</_electricity_>

** TOILET PUBLIC CONNECTION
*<_toilet_>

	gen toilet=.
	label var toilet "Toilet facility"
	la de lbltoilet 0 "No" 1 "Yes"
	label values toilet lbltoilet
*</_toilet_>


** LAND PHONE
*<_landphone_>

	gen landphone=.
	label var landphone "Phone availability"
	la de lbllandphone 0 "No" 1 "Yes"
	label values landphone lbllandphone
*</_landphone_>


** CEL PHONE
*<_cellphone_>

	gen cellphone=.
	label var cellphone "Cell phone"
	la de lblcellphone 0 "No" 1 "Yes"
	label values cellphone lblcellphone
*</_cellphone_>


** COMPUTER
*<_computer_>
	gen computer=.
	label var computer "Computer availability"
	la de lblcomputer 0 "No" 1 "Yes"
	label values computer lblcomputer
*</_computer_>


** INTERNET
	gen internet=.
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
	label var hsize "Household size"
*</_hsize_>
	
** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
*<_relationharm_>
	gen relationharm = S1B4_v3
	recode relationharm (3 5 = 3) (7=4) (4 6 8 = 5) (9=6) (0=.)
	label var relationharm "Relationship to the head of household"
	la de lblrelationharm  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Non-relatives"
	label values relationharm  lblrelationharm
*</_relationharm_>

** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
*<_relationcs_>

	gen byte relationcs = S1B4_v3
	la var relationcs "Relationship to the head of household country/region specific"
	label define lblrelationcs 1 "Head" 2 "Spouse of head" 3 "married child" 4 "spouse of married child" 5 "unmarried child" 6 "grandchild" 7 "father/mother/father-in-law/mother-in-law" 8 "brother/sister/brother-in-law/sister-in-law/other relations" 9 "servant/employee/other non-relative"
	label values relationcs lblrelationcs
*</_relationcs_>

	
	* FIX RELATIONSHIP TO HEAD VARIABLE MANUALLY
	
	gen head=relationharm==1
	bys idh: egen heads=total(head)
	
	replace relationharm=1 if indid==1 & heads==0
	
	drop head heads
	
	gen head=relationharm==1
	bys idh: egen heads=total(head)
	
	replace relationharm=1 if relationharm==2 & heads==0

	drop head heads

	gen head=relationharm==1
	bys idh: egen heads=total(head)
	
	bys idh: egen min_rel=min(relationcs)
	
	replace relationharm=1 if min_rel==3 & relationcs==3
	replace relationharm=2 if min_rel==3 & relationcs==4
	replace relationharm=3 if min_rel==3 & relationcs==6
	
	drop head heads min_rel
	
	gen head=relationharm==1
	bys idh: egen heads=total(head)	
	
	bys idh: egen max_age=max(S1B4_v5)
	
	replace relationharm=1 if heads==0 & S1B4_v5==max_age
	
	drop head heads
	
	gen head=relationharm==1
	bys idh: egen heads=total(head)	
	
	replace relationharm=2 if relationharm==1 & indid!=1 & heads==2
	
	drop head heads
	
	gen head=relationharm==1
	bys idh: egen heads=total(head)	
	
	replace relationharm=1 if heads==0 & indid==1
	
	drop head heads
	
	gen head=relationharm==1
	bys idh: egen heads=total(head)	
	
	replace relationharm=5 if relationharm==1 & heads!=1 & indid!=1
	
	drop head heads
	
	gen head=relationharm==1
	bys idh: egen heads=total(head)	
	
	replace relationharm=1 if heads==0 & indid==1
	
	drop head heads
	
		
** GENDER
*<_male_>
	gen male= S1B4_v4
	recode male (2=0)
	label var male "Sex of household member"
	la de lblmale 1 "Male" 0 "Female"
	label values male lblmale
*</_male_>


** AGE
*<_age_>
	gen age=S1B4_v5
	label var age "Age of individual"
*</_age_>


** SOCIAL GROUP
*<_soc_>

/*
The caste variable exist too, named "S1B31_v5"
*/
	gen soc=S1B31_v4
	label var soc "Social group"
	label define lblsoc 1 "Hinduism" 2 "Islam" 3 "Christianity" 4 "Sikhism" 
	label define lblsoc 5 "Jainism" 6 "Buddhism" 7 "Zoroastrianism" 9 "Others", add
	label values soc lblsoc
*</_soc_>


** MARITAL STATUS
*<_marital_>
gen marital=S1B4_v6
	recode marital (1=2) (2=1) (3=5) (8=.)
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
	gen ed_mod_age=0
	label var ed_mod_age "Education module application age"
*</_ed_mod_age_>


** CURRENTLY AT SCHOOL
*<_atschool_>
	gen atschool=.
	label var atschool "Attending school"
	la de lblatschool 0 "No" 1 "Yes"
	label values atschool  lblatschool
*</_atschool_>


** CAN READ AND WRITE
*<_literacy_>
	gen literacy=S1B4_v7
	recode literacy (2/13 = 1) (1= 0) (0=.)
	label var literacy "Can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy
*</_literacy_>


** YEARS OF EDUCATION COMPLETED
*<_educy_>
	recode S1B4_v7 (1/4=0)(5=2)(6=5) (7=8) (8 9=10) (10=15) (11=15) (12=15) (13=15) (0=.), gen(educy)
	label var educy "Years of education"
*</_educy_>
	replace educy=. if educy>age & age!=. & educy!=.


** EDUCATION LEVEL 7 CATEGORIES
*<_educat7_>

	gen educat7=S1B4_v7
	recode educat7 (1=1) (2 3 4=7) (5=2) (6=3) (7 8 =4) (9=5) (10 11 12 13=7)	(0=.)
	label define lbleducat7 1 "No education" 2 "Primary incomplete" 3 "Primary complete" ///
	4 "Secondary incomplete" 5 "Secondary complete" 6 "Higher than secondary but not university" /// 
	7 "University incomplete or complete" 8 "Other" 9 "Not classified"
	label values educat7 educat7
	la var educat7 "Level of education 7 categories"

	
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
	gen educat4=.
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
	recode S1B4_v7 (1 2 3 4= 0) (5 6 7 8 9 10 11 12 13=1), gen (everattend)
	label var everattend "Ever attended school"
	la de lbleverattend 0 "No" 1 "Yes"
	label values everattend lbleverattend
*</_everattend_>


	replace educy=0 if everattend==0
	replace educat7=1 if everattend==0
	replace educat5=1 if everattend==0
	replace educat5=1 if everattend==0

/*****************************************************************************************************
*                                                                                                    *
                                   LABOR MODULE
*                                                                                                    *
*****************************************************************************************************/


** LABOR MODULE AGE
*<_lb_mod_age_>

	gen lb_mod_age=0
	label var lb_mod_age "Labor module application age"
*</_lb_mod_age_>



** LABOR STATUS
*<_lstatus_>
	gen lstatus=.
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus
*</_lstatus_>


** EMPLOYMENT STATUS
*<_empstat_>
	gen empstat=.
	label var empstat "Employment status"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed"
	label values empstat lblempstat
*</_empstat_>


** SECTOR OF ACTIVITY: PUBLIC - PRIVATE
*<_njobs_>
	gen njobs=.
	label var njobs "Number of additional jobs"
*</_njobs_>


** SECTOR OF ACTIVITY: PUBLIC - PRIVATE
*<_ocusec_>
	gen ocusec=.
	label var ocusec "Sector of activity"
	la de lblocusec 1 "Public, state owned, government, army" 2 "NGO" 3 "Private"
	label values ocusec lblocusec
*</_ocusec_>


** REASONS NOT IN THE LABOR FORCE
*<_nlfreason_>
	gen nlfreason=.
	label var nlfreason "Reason not in the labor force"
	la de lblnlfreason 1 "Student" 2 "Housewife" 3 "Retired" 4 "Disable" 5 "Other"
	label values nlfreason lblnlfreason
*</_nlfreason_>



** UNEMPLOYMENT DURATION: MONTHS LOOKING FOR A JOB
*<_unempldur_l_>
	gen unempldur_l=.
	replace unempldur_l=. if lstatus!=2
	label var unempldur_l "Unemployment duration (months) lower bracket"
*</_unempldur_l_>

*<_unempldur_u_>

	gen unempldur_u=.
	replace unempldur_u=. if lstatus!=2
	label var unempldur_u "Unemployment duration (months) upper bracket"
*</_unempldur_u_>

** INDUSTRY CLASSIFICATION
*<_industry_>
	gen industry=.
	label var industry "1 digit industry classification"
	la de lblindustry 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transports and comnunications" 8 "Financial and business-oriented services" 9 "Community and family oriented services" 10 "Others"
	label values industry lblindustry
*</_industry_>
	replace industry=. if lstatus==2 | lstatus==3


** OCCUPATION CLASSIFICATION
*<_occup_>

	gen occup=.
	label var occup "1 digit occupational classification"
	label define occup 1 "Senior officials" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers"  8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"


** FIRM SIZE
*<_firmsize_l_>
	gen firmsize_l=.
	label var firmsize_l "Firm size (lower bracket)"
*</_firmsize_l_>

*<_firmsize_u_>

	gen firmsize_u=.
	label var firmsize_u "Firm size (upper bracket)"

*</_firmsize_u_>

** HOURS WORKED LAST WEEK
*<_whours_>
	gen whours=.
	label var whours "Hours of work in last week"
*</_whours_>

** WAGES
*<_wage_>
	gen wage=.
	replace wage=. if lstatus==2 | lstatus==3
	replace wage=0 if empstat==2
	label var wage "Last wage payment"
*</_wage_>


** WAGES TIME UNIT
*<_unitwage_>
	gen unitwage=.
	label var unitwage "Last wages time unit"
	la de lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Trimester" 7 "Biannual" 8 "Annually" 9 "Hourly"
	label values unitwage lblunitwage
*</_wageunit_>


** CONTRACT
*<_contract_>
	gen contract=.
	label var contract "Contract"
	la de lblcontract 0 "Without contract" 1 "With contract"
	label values contract lblcontract
*</_contract_>
	replace contract=. if lstatus==2 | lstatus==3


** HEALTH INSURANCE
*<_healthins_>
	gen healthins=.
	label var healthins "Health insurance"
	la de lblhealthins 0 "Without health insurance" 1 "With health insurance"
	label values healthins lblhealthins
*</_healthins_>


** SOCIAL SECURITY
*<_socialsec_>
	gen socialsec=.
	label var socialsec "Social security"
	la de lblsocialsec 1 "With" 0 "Without"
	label values socialsec lblsocialsec
*</_socialsec_>


** UNION MEMBERSHIP
*<_union_>
	gen union=.
	label var union "Union membership"

	replace union=. if  lstatus==2 | lstatus==3
	la de lblunion 0 "No member" 1 "Member"
	label values union lblunion
*</_union_>

	local lb_var "lstatus empstat njobs ocusec nlfreason unempldur_l unempldur_u industry occup firmsize_l firmsize_u whours wage unitwage contract healthins socialsec union"
	foreach v in `lb_var'{
	di "check `v' only for age>=lb_mod_age"

	replace `v'=. if( age<lb_mod_age & age!=.)
	}

/*****************************************************************************************************
*                                                                                                    *
                                   LABOR MODULE FOR INDIA
*                                                                                                    *
*****************************************************************************************************/

* main income earner OF THE HOUSEHOLD (_e)

** LABOR STATUS MAIN EARNER
*<_lstatus_e_>
	gen lstatus_e=1 if S1B31_v3!=.
	label var lstatus_e "Labor status (main earner)"
	la de lbllstatus_e 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus_e lbllstatus_e
*</_lstatus_e_>

** EMPLOYMENT STATUS MAIN EARNER
*<_empstat_e_>
	gen empstat_e=.
	replace empstat_e=1 if S1B31_v3==2
	replace empstat_e=4 if S1B31_v3==1 | S1B31_v3==4
	replace empstat_e=5 if S1B31_v3==3 | S1B31_v3==9
	label var empstat_e "Employment status (main earner)"
	la de lblempstat_e 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other"
	label values empstat_e lblempstat_e
*</_empstat_e_>

** INDUSTRY CLASSIFICATION MAIN EARNER
*<_industry_e_>
	gen ind=int(S1B31_v2i/100)
	recode ind 	(0=1) (1=2) (2/3=3) (4=4) (5=5) (6=6) (7=7) (8=8) (9=10), gen(industry_e)
	replace industry_e=9 if S1B31_v2i>=900 & S1B31_v2i<=910
	label var industry_e "1 digit industry classification (main earner)"
	la de lblindustry_e 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transports and comnunications" 8 "Financial and business-oriented services" 9 "Public Administration" 10 "Other services, Unspecified"
	label values industry_e lblindustry_e
*</_industry_e_>


** OCCUPATION CLASSIFICATION MAIN EARNER
*<_occup_e_>
	gen str3 princocc_NCO = string(S1B31_v2ii,"%03.0f")
	gen princocc_CODE2=substr(princocc_NCO,1,2) 
	gen princocc_CODE3= princocc_NCO
	drop princocc_NCO
	gen occup_e=.

	*professional

	replace occup_e=2 if princocc_CODE3=="000" | princocc_CODE3=="001" | princocc_CODE3=="002" | princocc_CODE3=="003"
	replace occup_e=2 if princocc_CODE3=="004" | princocc_CODE3=="006" | princocc_CODE3=="008"
	replace occup_e=2 if princocc_CODE3=="020" | princocc_CODE3=="021" | princocc_CODE3=="022" | princocc_CODE3=="023"
	replace occup_e=2 if princocc_CODE3=="024" | princocc_CODE3=="025" | princocc_CODE3=="026" | princocc_CODE3=="027"
	replace occup_e=2 if princocc_CODE3=="050" | princocc_CODE3=="051" | princocc_CODE3=="052" | princocc_CODE3=="053"
	replace occup_e=2 if princocc_CODE3=="054" | princocc_CODE3=="057" 
	replace occup_e=2 if princocc_CODE3=="070" | princocc_CODE3=="071" | princocc_CODE3=="072" | princocc_CODE3=="073"

	replace occup_e=2 if princocc_CODE3=="074" | princocc_CODE3=="075" | princocc_CODE3=="076" | princocc_CODE3=="084"
	replace occup_e=2 if princocc_CODE3=="085"  | princocc_CODE3=="147"
	replace occup_e=2 if princocc_CODE3=="140" | princocc_CODE3=="141" | princocc_CODE3=="149" | princocc_CODE3=="180"

	replace occup_e=2 if princocc_CODE3=="181" | princocc_CODE3=="182" | princocc_CODE3=="183" | princocc_CODE3=="185"
	replace occup_e=2 if princocc_CODE3=="186" | princocc_CODE3=="187" | princocc_CODE3=="188" | princocc_CODE3=="189"

	replace occup_e=2 if princocc_CODE2=="10" | princocc_CODE2=="11" | princocc_CODE2=="12" | princocc_CODE2=="13"

	replace occup_e=2 if princocc_CODE2=="15" | princocc_CODE2=="16" | princocc_CODE2=="17" | princocc_CODE2=="19"

	*technician and associate profesionals

	replace occup_e=3 if princocc_CODE3=="009" | princocc_CODE3=="010" | princocc_CODE3=="019" | princocc_CODE3=="028"
	replace occup_e=3 if princocc_CODE3=="011" | princocc_CODE3=="012" | princocc_CODE3=="014" | princocc_CODE3=="015"
	replace occup_e=3 if princocc_CODE3=="017" | princocc_CODE3=="018" 
	replace occup_e=3 if princocc_CODE3=="029" | princocc_CODE3=="059" | princocc_CODE3=="077" | princocc_CODE3=="078"
	replace occup_e=3 if princocc_CODE3=="079" | princocc_CODE3=="080" | princocc_CODE3=="081" | princocc_CODE3=="082"
	replace occup_e=3 if princocc_CODE3=="083" | princocc_CODE3=="086" | princocc_CODE3=="087" | princocc_CODE3=="088"
	replace occup_e=3 if princocc_CODE3=="089" | princocc_CODE3=="142" | princocc_CODE3=="184" 

	replace occup_e=3 if princocc_CODE2=="03" | princocc_CODE2=="04" | princocc_CODE2=="06" | princocc_CODE2=="09"

	*legislators, senior officials and managers

	replace occup_e=1 if princocc_CODE2=="20" | princocc_CODE2=="21" | princocc_CODE2=="22" | princocc_CODE2=="23"
	replace occup_e=1 if princocc_CODE2=="24" | princocc_CODE2=="25" | princocc_CODE2=="26" | princocc_CODE2=="29" | princocc_CODE2=="27" | princocc_CODE2=="28"

	replace occup_e=1 if princocc_CODE2=="30" | princocc_CODE2=="31" | princocc_CODE2=="36"  | princocc_CODE2=="60" 

	*clerks

	replace occup_e=4 if princocc_CODE2=="32" | princocc_CODE2=="33" | princocc_CODE2=="34" | princocc_CODE2=="35"

	replace occup_e=4 if princocc_CODE2=="37" | princocc_CODE2=="38" | princocc_CODE2=="39" 

	replace occup_e=4 if princocc_CODE3=="302" 

	*Service workers and shop and market sales

	replace occup_e=5 if princocc_CODE2=="40" | princocc_CODE2=="41" | princocc_CODE2=="42" | princocc_CODE2=="43"
	replace occup_e=5 if princocc_CODE2=="44" | princocc_CODE2=="45" | princocc_CODE2=="49" | princocc_CODE2=="50"
	replace occup_e=5 if princocc_CODE2=="46" | princocc_CODE2=="47" | princocc_CODE2=="48" 
	replace occup_e=5 if princocc_CODE2=="51" | princocc_CODE2=="52" | princocc_CODE2=="53" | princocc_CODE2=="54"
	replace occup_e=5 if princocc_CODE2=="55" | princocc_CODE2=="56" | princocc_CODE2=="57" | princocc_CODE2=="58" | princocc_CODE2=="59"

	*skilled agricultural and fishery workers

	replace occup_e=6 if princocc_CODE2=="61" | princocc_CODE2=="62" | princocc_CODE2=="63" | princocc_CODE2=="64"
	replace occup_e=6 if princocc_CODE2=="65" | princocc_CODE2=="66" | princocc_CODE2=="67" | princocc_CODE2=="68" | princocc_CODE2=="69"

	*Craft and related trades

	replace occup_e=7 if princocc_CODE2=="71" | princocc_CODE2=="72" | princocc_CODE2=="73" | princocc_CODE2=="75" | princocc_CODE2=="70"
	replace occup_e=7 if princocc_CODE2=="76" | princocc_CODE2=="77" | princocc_CODE2=="78" | princocc_CODE2=="79"
	replace occup_e=7 if princocc_CODE2=="80" | princocc_CODE2=="81" | princocc_CODE2=="82" | princocc_CODE2=="92"
	replace occup_e=7 if princocc_CODE2=="93" | princocc_CODE2=="94" | princocc_CODE2=="95" 

	*Plant and machine operators and assemblers

	replace occup_e=8 if princocc_CODE2=="74" | princocc_CODE2=="83" | princocc_CODE2=="84" | princocc_CODE2=="85"
	replace occup_e=8 if princocc_CODE2=="86" | princocc_CODE2=="87" | princocc_CODE2=="88" | princocc_CODE2=="89"
	replace occup_e=8 if princocc_CODE2=="90" | princocc_CODE2=="91" | princocc_CODE2=="96" | princocc_CODE2=="97"
	replace occup_e=8 if princocc_CODE2=="98" 
	replace occup_e=8 if princocc_CODE3=="813" 

	*elementary occupations

	replace occup_e=9 if princocc_CODE2=="99" 

	*other/unspecified

	replace occup_e=99 if princocc_CODE2=="X0" | princocc_CODE2=="X1" | princocc_CODE2=="X9" 

	*legislators, senior officials and managers CONTT.

	replace occup_e=1 if princocc_CODE3=="710" | princocc_CODE3=="720" | princocc_CODE3=="730" | princocc_CODE3=="740"
	replace occup_e=1 if princocc_CODE3=="750" | princocc_CODE3=="760" | princocc_CODE3=="770" | princocc_CODE3=="780"  
	replace occup_e=1 if princocc_CODE3=="790" | princocc_CODE3=="800" | princocc_CODE3=="810" | princocc_CODE3=="820" 
	replace occup_e=1 if princocc_CODE3=="830" | princocc_CODE3=="840" | princocc_CODE3=="850" | princocc_CODE3=="860"  
	replace occup_e=1 if princocc_CODE3=="870" | princocc_CODE3=="880" | princocc_CODE3=="890" | princocc_CODE3=="900" 
	replace occup_e=1 if princocc_CODE3=="910" | princocc_CODE3=="920" | princocc_CODE3=="930" | princocc_CODE3=="940"  
	replace occup_e=1 if princocc_CODE3=="950" | princocc_CODE3=="960" | princocc_CODE3=="970" | princocc_CODE3=="980"

	drop  princocc_CODE2 princocc_CODE3

	label var occup_e "1 digit occupational classification (main earner)"
	label define occup_e 1 "Senior officials" 2 "Professionals" 3 "Technicians" 4 "Clerks" ///
	5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" ///
	8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup_e occup_e
*</_occup_e_>

	note lstatus_e: 	Data recolected only for main income earner of the household.
	note empstat_e: 	Data recolected only for main income earner of the household.
	note industry_e: 	Data recolected only for main income earner of the household.
	note occup_e: 		Data recolected only for main income earner of the household.

/*****************************************************************************************************
*                                                                                                    *
                                   WELFARE MODULE
*                                                                                                    *
*****************************************************************************************************/


** SPATIAL DEFLATOR
*<_spdef_>
	gen spdef=pline
	la var spdef "Spatial deflator"
*</_spdef_>


** WELFARE
*<_welfare_>
	gen welfare=mpce_urp
	la var welfare "Welfare aggregate"
*</_welfare_>

*<_welfarenom_>
	gen welfarenom=mpce_urp
	la var welfarenom "Welfare aggregate in nominal terms"
*</_welfarenom_>

*<_welfaredef_>
	gen welfaredef=mpce_urp_real
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
	gen welfareother=mpce_mrp
	la var welfareother "Welfare Aggregate if different welfare type is used from welfare, welfarenom, welfaredef"
*</_welfareother_>

*<_welfareothertype_>
	gen welfareothertype="CON"
	la var welfareothertype "Type of welfare measure (income, consumption or expenditure) for welfareother"
*</_welfareothertype_>

*<_welfarenat_>
	gen welfarenat=mpce_mrp
	la var welfarenat "Welfare aggregate for national poverty"
*</_welfarenat_>	
/*****************************************************************************************************
*                                                                                                    *
                                   NATIONAL POVERTY
*                                                                                                    *
*****************************************************************************************************/


** POVERTY LINE (NATIONAL)
*<_pline_nat_>
	ren pline pline_nat
	label variable pline_nat "Poverty Line (National)"
*</_pline_nat_>


** HEADCOUNT RATIO (NATIONAL)
*<_poor_nat_>
	gen poor_nat=welfarenat<pline_nat & welfarenat!=.
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
	gen urb=urban
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

	keep countrycode year survey idh idp wgt strata psu vermast veralt urban int_month int_year  ///
	     subnatid1 subnatid2 subnatid3 ownhouse water electricity toilet landphone cellphone ///
	     computer internet hsize relationharm relationcs male age soc marital ed_mod_age everattend ///
	     atschool electricity literacy educy educat4 educat5 educat7 lb_mod_age lstatus empstat njobs ///
	     ocusec nlfreason unempldur_l unempldur_u industry occup firmsize_l firmsize_u whours wage ///
		 unitwage contract healthins socialsec union lstatus_e empstat_e industry_e occup_e  ///
		 pline_nat pline_int poor_nat poor_int spdef cpi ppp cpiperiod welfare welfarenom welfaredef ///
		  welfarenat welfareother welfaretype welfareothertype

** ORDER VARIABLES

	order countrycode year survey idh idp wgt strata psu vermast veralt urban int_month int_year  ///
	      subnatid1 subnatid2 subnatid3 ownhouse water electricity toilet landphone cellphone ///
	      computer internet hsize relationharm relationcs male age soc marital ed_mod_age everattend ///
	      atschool electricity literacy educy educat4 educat5 educat7 lb_mod_age lstatus empstat njobs ///
	      ocusec nlfreason unempldur_l unempldur_u industry occup firmsize_l firmsize_u whours wage ///
		  unitwage contract healthins socialsec union lstatus_e empstat_e industry_e occup_e  ///
		  pline_nat pline_int poor_nat poor_int spdef cpi ppp cpiperiod welfare welfarenom welfaredef ///
		  welfarenat welfareother welfaretype welfareothertype
	
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


	saveold "`output'\Data\Harmonized\IND_1993_NSS-SCH1_v01_M_v02_A_SARMD_IND.dta", replace version(12)
	saveold "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\__REGIONAL\Individual Files\IND_1993_NSS-SCH1_v01_M_v02_A_SARMD_IND.dta", replace version(12)
	
	
	log close




















******************************  END OF DO-FILE  *****************************************************/
