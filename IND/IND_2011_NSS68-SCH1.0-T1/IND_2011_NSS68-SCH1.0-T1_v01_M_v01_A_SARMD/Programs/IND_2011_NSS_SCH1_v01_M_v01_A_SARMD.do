/*****************************************************************************************************
******************************************************************************************************
**                                                                                                  **
**                                   SOUTH ASIA MICRO DATABASE                                      **
**                                                                                                  **
** COUNTRY			INDIA
** COUNTRY ISO CODE	IND
** YEAR				2011
** SURVEY NAME		NATIONAL SAMPLE SURVEY 68TH ROUND 
*					HOUSEHOLD SCHEDULE 1.0 : CONSUMER EXPENDITURE
** SURVEY AGENCY	GOVERNMENT OF INDIA NATIONAL SAMPLE SURVEY ORGANISATION
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
	set mem 700m
	
** DIRECTORY
	local input "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\IND\IND_2011_NSS-SCH1\IND_2011_NSS-SCH1_v01_M"
	local output "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\IND\IND_2011_NSS-SCH1\IND_2011_NSS-SCH1_v01_M_v01_A_SARMD"

** LOG FILE
	log using "`input'\Doc\Technical\IND_2011_NSS-SCH1.log",replace


/*****************************************************************************************************
*                                                                                                    *
                                   * ASSEMBLE DATABASE
*                                                                                                    *
*****************************************************************************************************/


** DATABASE ASSEMBLENT

	* PREPARE DATASETS
	
	use "`input'\Data\Stata\NSS68_Sch1-T1_bk_4.dta"
	sort ID B4_v01
	format ID %9.0f
	tempfile roster
	save `roster'

	use "`input'\Data\Stata\NSS68_Sch1-T1_bk_1_2.dta"
	sort ID
	format ID %9.0f
	tempfile survey
	save `survey'
	
	use "`input'\Data\Stata\NSS68_Sch1-T1_bk_3.dta"
	sort ID
	format ID %9.0f
	tempfile household
	save `household'

	
	use "`input'\Data\Stata\poverty68.dta", clear

	*REAL CONSUMPTION IN 2011-12 ALL INDIA RURAL/URBAN RUPEES accordingly
	gen real_mpce111=mpce_mrp*(pline_ind_11/pline)
	la var real_mpce111 "Real-PC Monthly Cons-in Urb/Rural Rupees"

	* WEIGHTED AVERAGE POVERTY LINE
	qui su pline_ind_11 [aw=pwt]
	gen pline_mrp=r(mean)
	* 868.57233

	* SPATIALY DEFLATED CONSUMPTION VARIABLE (TO NATIONAL)
	gen mpce_mrp_real=real_mpce111*(pline_mrp/pline_ind_11)
	la var mpce_mrp_real "Real PC Monthly Consumption (MRP)"

	sort hhid
	ren hhid ID

	format ID %9.0f

	gen pline_urp_sector=.
	replace pline_urp_sector=763.9 	if sector==1
	replace pline_urp_sector=1114.0	if sector==2

	su pline_urp_sector [w=pwt]
	gen pline_urp=r(mean)

	gen mpce_urp_real=mpce_urp*(pline_urp/pline_urp_sector)
	la var mpce_urp_real "Real PC Monthly Consumption (URP)"
	ren pline_ind_11 pline_mrp_sector
	keep ID mpce_urp_real mpce_mrp_real pline_urp pline_mrp pline_urp_sector pline_mrp_sector pline pwt

	order ID mpce_urp_real mpce_mrp_real pline_urp pline_mrp pline_urp_sector pline_mrp_sector pline pwt

	* MERGE DATASETS
	
	merge 1:1 ID using `survey'
	drop _merge
	
	merge 1:1 ID using `household'
	drop _merge
	
	merge 1:m ID using `roster'


/*****************************************************************************************************
*                                                                                                    *
                                   * STANDARD SURVEY MODULE
*                                                                                                    *
*****************************************************************************************************/
	
	
** COUNTRY
	gen countrycode="IND"
	label var countrycode "Country code"

** YEAR
	gen year=2011
	label var year "Year of survey"

	tostring ID, gen(idh)


** INTERVIEW YEAR
	gen byte int_year=.
	label var int_year "Year of the interview"
	
	
** INTERVIEW MONTH
	gen byte int_month=.
	la de lblint_month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
	label value int_month lblint_month
	label var int_month "Month of the interview"
	
	
** HOUSEHOLD IDENTIFICATION NUMBER
	label var idh "Household id"
	*drop if B4_v01==.


** INDIVIDUAL IDENTIFICATION NUMBER
	egen double idp =concat(idh B4_v01)
	label var idp "Individual id"

	isid idp


** HOUSEHOLD WEIGHTS
	gen wgt=hhwt

	label var wgt "Household sampling weight"


** STRATA
	gen strata=B1_v08
	label var strata "Strata"


** PSU
	gen psu=B1_v01 
	destring psu , replace
	label var psu "Primary sampling units"


** MASTER VERSION
	gen vermast="01"
	label var vermast "Master Version"
	
	
** ALTERATION VERSION
	gen veralt="01"
	label var veralt "Alteration Version"
	
	

/*****************************************************************************************************
*                                                                                                    *
                                   HOUSEHOLD CHARACTERISTICS MODULE
*                                                                                                    *
*****************************************************************************************************/


** LOCATION (URBAN/RURAL)
	gen urban=B1_v05
	recode urban (2=1) (1=0)
	label var urban "Urban/Rural"
	la de lblurban 1 "Urban" 0 "Rural"
	label values urban lblurban

	
** REGIONAL AREA 1 DIGIT ADMN LEVEL
	recode state (1 2 3 4 6 8 = 1) (5 7 9 10 23 = 2) (12/18 = 3) (11 19 20 21 22 35 = 4) ( 24 25 26 27 30 = 5) (28 29 31 32 33 34 = 6), gen(subnatid1)
	label define lblsubnatid1 1 "Northern" 2 "North-Central" 3 "North-Eastern" 4 "Eastern" 5 "Western" 6 "Southern"
	label var subnatid1 "Region at 1 digit (ADMN1)"
	label values subnatid1 lblsubnatid1


** REGIONAL AREA 2 DIGIT ADMN LEVEL
	gen REG=state
	label define lblsubnatid2  28 "Andhra Pradesh"  18 "Assam"  10 "Bihar" 24 "Gujarat" 06 "Haryana"  02 "HimachalPradesh" ///
	01 "Jammu & Kashmir" 29"Karnataka" 32 "Kerala" 23 "Madhya Pradesh" 27  "Maharashtra" ///  
	14 "Manipur"   17 "Meghalaya"  13 "Nagaland"  21 "Orissa"  03 "Punjab" 08 "Rajasthan" 11 "Sikkim" ///
	33 "Tamil Nadu"  16 "Tripura"  9 "Uttar Pradesh"  19 "West Bengal" 35 "A & N Islands" ///
	12 "Arunachal Pradesh"  4 "Chandigarh" 26 "Dadra & Nagar Haveli" 7 "Delhi"  30 "Goa" ///
	31"Lakshdweep" 15 "Mizoram"  34 "Pondicherry"  25 "Daman & Diu" 22"Chhattisgarh" 20"Jharkhand" 5"Uttaranchal"
	gen subnatid2=REG
	label var subnatid2 "Region at 2 digit (ADMN2)"
	label values subnatid2 lblsubnatid2

	
** REGIONAL AREA 3 DIGIT ADMN LEVEL
	gen byte subnatid3=.
	label var subnatid3 "Region at 3 digit (ADMN3)"
	label values subnatid3 lblsubnatid3
	

** HOUSE OWNERSHIP
	gen ownhouse=B3_v18 
	recode ownhouse (2 3 9=0)
	label var ownhouse "House ownership"
	la de lblownhouse 0 "No" 1 "Yes"
	label values ownhouse lblownhouse


** WATER PUBLIC CONNECTION
	gen water=.
	label var water "Water main source"
	la de lblwater 0 "No" 1 "Yes"
	label values water lblwater


** ELECTRICITY PUBLIC CONNECTION
	gen electricity=B3_v17
	recode electricity (5=1) (1 2 3 4 6 9=0)
	label var electricity "Electricity main source"
	la de lblelectricity 0 "No" 1 "Yes"
	label values electricity lblelectricity


** TOILET PUBLIC CONNECTION
	gen toilet=.
	label var toilet "Toilet facility"
	la de lbltoilet 0 "No" 1 "Yes"
	label values toilet lbltoilet


** LAND PHONE
	gen landphone=.
	label var landphone "Phone availability"
	la de lbllandphone 0 "No" 1 "Yes"
	label values landphone lbllandphone


** CEL PHONE
	gen cellphone=.
	label var cellphone "Cell phone"
	la de lblcellphone 0 "No" 1 "Yes"
	label values cellphone lblcellphone


** COMPUTER
	gen computer=.
	label var computer "Computer availability"
	la de lblcomputer 0 "No" 1 "Yes"
	label values computer lblcomputer


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
	
	
**HOUSEHOLD SIZE
	gen byte hsize=B3_v01
	label var hsize "Household size"


** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
	gen relationharm=B4_v03 
	recode relationharm (3 5 = 3) (7=4) (4 6 8 = 5) (9=6)
	label var relationharm "Relationship to the head of household"
	la de lblrelationharm  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Non-relatives"
	label values relationharm  lblrelationharm

	gen byte relationcs=B4_v03
	la var relationcs "Relationship to the head of household country/region specific"
	label define lblrelationcs 1 "Head" 2 "Spouse of head" 3 "married child" 4 "spouse of married child" 5 "unmarried child" 6 "grandchild" 7 "father/mother/father-in-law/mother-in-law" 8 "brother/sister/brother-in-law/sister-in-law/other relations" 9 "servant/employee/other non-relative"
	label values relationcs lblrelationcs


** GENDER
	gen male=B4_v04
	recode male (2=0)
	label var male "Sex of household member"
	la de lblmale 1 "Male" 0 "Female"
	label values male lblmale


** AGE
	gen age=B4_v05
	label var age "Individual age"


** SOCIAL GROUP

/*
The variable caste exist too, named "B3_v06"
*/
	gen soc=B3_v05 
	label var soc "Social group"
	label define soc 1 "Hinduism" 2 "Islam" 3 "Christianity" 4 "Sikhism" 5 "Jainism" 6 "Buddhism" 7 "Zoroastrianism" 9 "Others"
	label values soc soc


** MARITAL STATUS
	gen marital=B4_v06 
	recode marital (1=2) (2=1) (3=5)
	label var marital "Marital status"
	la de lblmarital 1 "Married" 2 "Never Married" 3 "Living Together" 4 "Divorced/separated" 5 "Widowed"
	label values marital lblmarital


/*****************************************************************************************************
*                                                                                                    *
                                   EDUCATION MODULE
*                                                                                                    *
*****************************************************************************************************/


** EDUCATION MODULE AGE
	gen ed_mod_age=0
	label var ed_mod_age "Education module application age"


** CURRENTLY AT SCHOOL
	gen atschool=.
	label var atschool "Attending school"
	la de lblatschool 0 "No" 1 "Yes"
	label values atschool  lblatschool


** CAN READ AND WRITE
	gen literacy=B4_v07
	recode literacy (1=0) (2/13 =1)
	label var literacy "Can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy

** YEARS OF EDUCATION COMPLETED
	recode B4_v07 (1/4=0)(5=2)(6=5) (7=8) (8 10=10) (11=12) (12=15) (13=17), gen(educy)
	label var educy "Years of education"
	replace educy=. if educy>age & educy!=. & age!=.


** EDUCATION LEVEL 7 CATEGORIES
	gen educat7=B4_v07
	recode educat7 (1=1)(2 3 4 =7)(5=2)(6=3) (7 8 =4) (10=5) (11=6) (12 13=7)
	label define lbleducat7 1 "No education" 2 "Primary incomplete" 3 "Primary complete" ///
	4 "Secondary incomplete" 5 "Secondary complete" 6 "Higher than secondary but not university" /// 
	7 "University incomplete or complete" 8 "Other" 9 "Not classified"
	label values educat7 lbleducat7
	la var educat7 "Level of education 7 categories"


** EDUCATION LEVEL 5 CATEGORIES
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
	la var educat5 "Level of education 5 categories"


** EDUCATION LEVEL 4 CATEGORIES
	gen educat4=.
	replace educat4=1 if educat7==1
	replace educat4=2 if educat7==2 | educat7==3
	replace educat4=3 if educat7==4 | educat7==5
	replace educat4=4 if educat7==6 | educat7==7
	label var educat4 "Level of education 4 categories"
	label define lbleducat4 1 "No education" 2 "Primary (complete or incomplete)" ///
	3 "Secondary (complete or incomplete)" 4 "Tertiary (complete or incomplete)"
	label values educat4 lbleducat4


** EVER ATTENDED SCHOOL
	recode B4_v07 (1 2 3 4 = 0) (5 6 7 8 9 10 11 12 13=1), gen (everattend)
	label var everattend "Ever attended school"
	la de lbleverattend 0 "No" 1 "Yes"
	label values everattend lbleverattend


/*****************************************************************************************************
*                                                                                                    *
                                   LABOR MODULE
*                                                                                                    *
*****************************************************************************************************/
** LABOR MODULE AGE
	gen lb_mod_age=.
	label var lb_mod_age "Labor module application age"



** LABOR STATUS
	gen lstatus=.
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus
	replace lstatus=. if  age<lb_mod_age


** EMPLOYMENT STATUS
	gen empstat=.
	label var empstat "Employment status"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed"
	label values empstat lblempstat


** NUMBER OF ADDITIONAL JOBS
	gen njobs=.
	label var njobs "Number of additional jobs"


** SECTOR OF ACTIVITY: PUBLIC - PRIVATE
	gen ocusec=.
	label var ocusec "Sector of activity"
	la de lblocusec 1 "Public, state owned, government, army" 2 "NGO" 3 "Private"
	label values ocusec lblocusec
	replace ocusec=. if lstatus!=1


** REASONS NOT IN THE LABOR FORCE
	gen nlfreason=.
	label var nlfreason "Reason not in the labor force"
	la de lblnlfreason 1 "Student" 2 "Housewife" 3 "Retired" 4 "Disable" 5 "Other"
	label values nlfreason lblnlfreason


** UNEMPLOYMENT DURATION: MONTHS LOOKING FOR A JOB
	gen unempldur_l=.
	label var unempldur_l "Unemployment duration (months) lower bracket"

	gen unempldur_u=.
	label var unempldur_u "Unemployment duration (months) upper bracket"

	gen industry=.

** INDUSTRY CLASSIFICATION
	label var industry "1 digit industry classification"
	la de lblindustry 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transports and comnunications" 8 "Financial and business-oriented services" 9 "Community and family oriented services" 10 "Others"
	label values industry lblindustry



** OCCUPATION CLASSIFICATION
	gen occup=.
	label var occup "1 digit occupational classification"
	label define lbloccup 1 "Senior officials" 2 "Professionals" 3 "Technicians" 4 "Clerks" ///
	5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" ///
	8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup lbloccup


**FIRMSIZE
	gen firmsize_l=.
	label var firmsize_l "Firm size (lower bracket)"

	gen firmsize_u=.
	label var firmsize_u "Firm size (upper bracket)"


**HOURS OF WORK
	gen whours=.
	label var whours "Hours of work in last week"


** WAGES
	gen wage=.
	label var wage "Last wage payment"

** WAGES TIME UNIT

	gen unitwage=.
	label var unitwage "Last wages time unit"
	la de lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Trimester" 7 "Biannual" 8 "Annually" 9 "Hourly" 
	label values unitwage lblunitwage


** CONTRACT
	gen contract=.
	label var contract "Contract"
	la de lblcontract 0 "Without contract" 1 "With contract"
	label values contract lblcontract


	gen healthins=.

** HEALTH INSURANCE
	label var healthins "Health insurance"
	la de lblhealthins 0 "Without health insurance" 1 "With health insurance"
	label values healthins lblhealthins

	gen socialsec=.

** SOCIAL SECURITY
	label var socialsec "Social security"
	la de lblsocialsec 1 "With" 0 "Without"
	label values socialsec lblsocialsec

	gen union=.

** UNION MEMBERSHIP
	la de lblunion 0 "No member" 1 "Member"
	label var union "Union membership"
	label values union lblunion

	local lb_var "lstatus empstat njobs ocusec nlfreason unempldur_l unempldur_u industry occup firmsize_l firmsize_u whours wage unitwage contract healthins socialsec union"
	foreach v in `lb_var'{
	di "check `v' only for age>=lb_mod_age"

	replace `v'=. if( age<lb_mod_age & age!=.)
	}
	label var occup "1 digit occupational classification"
	label define occup 1 "Senior officials" 2 "Professionals" 3 "Technicians" 4 "Clerks" ///
	5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" ///
	8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup occup
	replace occup=. if lstatus!=1
	
/*****************************************************************************************************
*                                                                                                    *
                                   LABOR MODULE FOR INDIA
*                                                                                                    *
*****************************************************************************************************/

* main income earner OF THE HOUSEHOLD (_e)

** LABOR STATUS
	gen lstatus_e=1 if B3_v04!=.
	replace lstatus_e=2 if B3_v03=="X00" /* Looking for Employment*/
	label var lstatus_e "Labor status (main earner)"
	la de lbllstatus_e 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus_e lbllstatus_e

** EMPLOYMENT STATUS
	recode B3_v04a (13 22 = 1) (11 12 21 = 4) (14 15 19 23 29=5), gen(empstat_e)
	label var empstat_e "Employment status (main earner)"
	la de lblempstat_e 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other"
	replace empstat_e=. if lstatus_e!=1
	label values empstat_e lblempstat_e

** INDUSTRY CLASSIFICATION
	gen ind=substr(B3_v02,1,2)
	destring ind, replace
	recode ind 	(1/3=1) (5/9=2) (10/33=3) (35/39=4) (41/43=5) (45/47=6) (49/63=7) (64/82=8) (84=9) (85/99=10), gen(industry_e)
	label var industry_e "1 digit industry classification (main earner)"
	la de lblindustry_e 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transports and comnunications" 8 "Financial and business-oriented services" 9 "Public Administration" 10 "Other services, Unspecified"
	label values industry_e lblindustry_e

** OCCUPATION CLASSIFICATION
	gen ocup=substr(B3_v03,1,1)
	replace ocup="99" if ocup=="X"
	destring ocup, replace
	gen occup_e=ocup
	replace occup_e=. if ocup==99
	label var occup_e "1 digit occupational classification (main earner)"
	label define occup_e 1 "Senior officials" 2 "Professionals" 3 "Technicians" 4 "Clerks" ///
	5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" ///
	8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup_e occup_e


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
	gen spdef=pline
	la var spdef "Spatial deflator"

** WELFARE
	gen welfare=B3_v24
	la var welfare "Welfare aggregate"

	gen welfarenom=B3_v24
	la var welfarenom "Welfare aggregate in nominal terms"

	gen welfaredef=mpce_urp_real
	la var welfaredef "Welfare aggregate spatially deflated"

	gen welfshprosperity=welfaredef
	la var welfshprosperity "Welfare aggregate for shared prosperity"

	gen welfaretype="CONS"
	la var welfaretype "Type of welfare measure (income, consumption or expenditure) for welfare, welfarenom, welfaredef"

	gen welfareother=B3_v25
	la var welfareother "Welfare Aggregate if different welfare type is used from welfare, welfarenom, welfaredef"

	gen welfareothertype="CONS"
	la var welfareothertype "Type of welfare measure (income, consumption or expenditure) for welfareother"

	
/*****************************************************************************************************
*                                                                                                    *
                                   NATIONAL POVERTY
*                                                                                                    *
*****************************************************************************************************/


** POVERTY LINE (NATIONAL)
	ren pline pline_nat
	label variable pline_nat "Poverty Line (National)"


** HEADCOUNT RATIO (NATIONAL)
	gen poor_nat=welfareother<pline_nat & welfareother!=.
	la var poor_nat "People below Poverty Line (National)"
	la define poor_nat 0 "Not Poor" 1 "Poor"
	la values poor_nat poor_nat


/*****************************************************************************************************
*                                                                                                    *
                                   INTERNATIONAL POVERTY
*                                                                                                    *
*****************************************************************************************************/


	local year=2011
	
** USE SARMD CPI AND PPP
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
	
	
** PPP VARIABLE
	ren ppp`year' 	ppp
	label variable ppp "PPP `year'"

	
** CPI PERIOD
	gen cpiperiod=syear
	label var cpiperiod "Periodicity of CPI (year, year&month, year&quarter, weighted)"
	

** POVERTY LINE (POVCALNET)
	gen pline_int=1.90*cpi*ppp*365/12
	label variable pline_int "Poverty Line (Povcalnet)"
	
	
** HEADCOUNT RATIO (POVCALNET)
	gen poor_int=welfare<pline_int & welfare!=.
	la var poor_int "People below Poverty Line (Povcalnet)"
	la define poor_int 0 "Not Poor" 1 "Poor"
	la values poor_int poor_int


/*****************************************************************************************************
*                                                                                                    *
                                   FINAL STEPS
*                                                                                                    *
*****************************************************************************************************/


** KEEP VARIABLES - ALL

	keep countrycode year idh idp wgt strata psu vermast veralt urban int_month int_year  ///
	     subnatid1 subnatid2 subnatid3 ownhouse water electricity toilet landphone cellphone ///
	     computer internet hsize relationharm relationcs male age soc marital ed_mod_age everattend ///
	     atschool electricity literacy educy educat4 educat5 educat7 lb_mod_age lstatus empstat njobs ///
	     ocusec nlfreason unempldur_l unempldur_u industry occup firmsize_l firmsize_u whours wage ///
		 unitwage contract healthins socialsec union lstatus_e empstat_e industry_e occup_e  ///
		 pline_nat pline_int poor_nat poor_int spdef cpi ppp cpiperiod welfare welfarenom welfaredef ///
		 welfareother welfaretype welfareothertype

** ORDER VARIABLES

	order countrycode year idh idp wgt strata psu vermast veralt urban int_month int_year  ///
	      subnatid1 subnatid2 subnatid3 ownhouse water electricity toilet landphone cellphone ///
	      computer internet hsize relationharm relationcs male age soc marital ed_mod_age everattend ///
	      atschool electricity literacy educy educat4 educat5 educat7 lb_mod_age lstatus empstat njobs ///
	      ocusec nlfreason unempldur_l unempldur_u industry occup firmsize_l firmsize_u whours wage ///
		  unitwage contract healthins socialsec union lstatus_e empstat_e industry_e occup_e  ///
		  pline_nat pline_int poor_nat poor_int spdef cpi ppp cpiperiod welfare welfarenom welfaredef ///
		  welfareother welfaretype welfareothertype
	
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
	keep countrycode year idh idp wgt strata psu vermast veralt `keep' *type

	compress



	saveold "`output'\Data\Harmonized\IND_2011_NSS-SCH1_v01_M_v01_A_SARMD_IND.dta", replace version(13)
	saveold "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\__REGIONAL\Individual Files\IND_2011_NSS-SCH1_v01_M_v01_A_SARMD_IND.dta", replace version(13)

	log close





******************************  END OF DO-FILE  *****************************************************/
