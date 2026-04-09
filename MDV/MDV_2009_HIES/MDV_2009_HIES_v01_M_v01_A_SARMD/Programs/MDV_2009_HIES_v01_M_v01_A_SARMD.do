/*****************************************************************************************************
******************************************************************************************************
**                                                                                                  **
**                              SOUTH ASIA MICRO DATABASE (SARMD)                                   **
**                                                                                                  **
** COUNTRY			Maldives
** COUNTRY ISO CODE	MDV
** YEAR				2009
** SURVEY NAME		Vulnerability and poverty assessment survey – 2009
** SURVEY AGENCY	Minister of Planning and National Development
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
	local input "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\MDV\MDV_2009_HIES\MDV_2009_HIES_v01_M"
	local output "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\MDV\MDV_2009_HIES\MDV_2009_HIES_v01_M_v01_A_SARMD"

** LOG FILE
	log using "`input'\Doc\MDV_2009_HIES.log",replace

/*****************************************************************************************************
*                                                                                                    *
                                   * ASSEMBLE DATABASE
*                                                                                                    *
*****************************************************************************************************/


** DATABASE ASSEMBLENT

	use "`input'\Data\Stata\Educ_Empl.dta"
	sort formID pNo
	ren formID ori_hid
	ren pNo iid

	ren Q9 everattend
	ren Q10 attending
	ren Q11 elevel1
	ren Q12 elevel2
	ren Q16 activity
	ren Q17 searchforjob
	ren Q18 availability
	ren Q19 nlfreason

	drop Q13-Q15
	drop Q20-Q22

	tempfile t1
	save `t1', replace

	use "`input'\Data\Stata\Income.dta"
	sort formID pNo
	ren formID ori_hid
	ren pNo iid

	ren Q1 industry
	ren Q2 occupation
	ren Q4 typeofjob
	ren Q5 hours
	ren Q6 months
	ren Q7 empstat
	ren Q8 otherjob

	tempfile t2
	save `t2', replace

	use "`input'\Data\Stata\mdv2009_ind.dta"

	merge m:1 ori_hid using "`input'\Data\Stata\mdv2009_hld.dta"

	drop _merge

	merge 1:1 ori_hid iid using `t1'

	drop _merge

	merge 1:1 ori_hid iid using `t2'

	ren _merge labor_module

		
/*****************************************************************************************************
*                                                                                                    *
                                   * STANDARD SURVEY MODULE
*                                                                                                    *
*****************************************************************************************************/
	

** COUNTRY
	gen str4 countrycode="MDV"
	label var countrycode "Country code"


** YEAR
	gen int year=2009
	label var year "Year of survey"


** INTERVIEW YEAR
	gen byte int_year=.
	label var int_year "Year of the interview"
	
	
** INTERVIEW MONTH
	gen byte int_month=.
	la de lblint_month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
	label value int_month lblint_month
	label var int_month "Month of the interview"


** HOUSEHOLD IDENTIFICATION NUMBER
	tostring ori_hid, gen(idh)
	label var idh "Household id"

	tostring iid, replace

** INDIVIDUAL IDENTIFICATION NUMBER
	egen idp=concat(idh iid), punct(-)
	label var idp "Individual id"


** HOUSEHOLD WEIGHTS
	gen double wgt=wta_hh
	label var wgt "Household sampling weight"


** STRATA
	gen strata=.
	label var strata "Strata"


** PSU
	*gen psu=.
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
	recode rururb (1=0) (2=1), gen(urban)
	label var urban "Urban/Rural"
	la de lblurban 1 "Urban" 0 "Rural"
	label values urban lblurban


** REGIONAL AREA 1 DIGIT ADMN LEVEL
	gen byte subnatid1=geo_1
	recode subnatid1 (8=0) (1 2 = 1) (3=2) (4=3) (5 7=5) (6=4)
	la de lblsubnatid1 0 "Male (capital)" 1 "North" 2 "Central North" 3 "Central" 4 "Central South" 5 "South"
	label var subnatid1 "Region at 1 digit (ADMN1)"
	label values subnatid1 lblsubnatid1


** REGIONAL AREA 2 DIGIT ADMN LEVEL
	* obtain subnatid2 from geo_2
	gen subnatid2=int(geo_2/100)
	recode subnatid2 (10=1) (20=2) (21=3) (22=4) (23=5) (24=6) (25=7) (26=8) (27=9) (28=10) (29=11) (30=12) (31=13) (32=14) (33=15) (34=16) (35=17) (36=18) (37=19) (38=20) (39=21)
	la de lblsubnatid2 1 "Male (capital)" 2 "North Thiladhunmathi" 3 "South Thiladhunmathi" 4 "North Miladhunmadulu" 5 "South Miladhunmadulu" 6 "North Maalhosmadulu" 7 "South Maalhosmadulu" 8 "Faadhippolhu" 9 "Male atoll" 10 "North Ari Atoll" 11 "South Ari Atoll" 12 "Felidhu Atoll" 13 "Mulakatolhu" 14 "North Nilandhe Atoll" 15 "South Nilandhe Atoll" 16 "Kolhumadhulu" 17 "Hadhunmathi" 18 "North Huvadhu Atoll" 19 "South Huvadhu Atoll" 20 "Fuvahmulah" 21 "Addu Atoll"
	label var subnatid2 "Region at 2 digit (ADMN2)"
	label values subnatid2 lblsubnatid2

	
** REGIONAL AREA 3 DIGIT ADMN LEVEL
	gen byte subnatid3=.
	label var subnatid3 "Region at 3 digit (ADMN3)"
	label values subnatid3 lblsubnatid3
	
	
** HOUSE OWNERSHIP
	label var ownhouse "House ownership"
	la de lblownhouse 0 "No" 1 "Yes"
	label values ownhouse lblownhouse


** WATER PUBLIC CONNECTION
	*gen byte water=.
	label var water "Water main source"
	la de lblwater 0 "No" 1 "Yes"
	label values water lblwater


** ELECTRICITY PUBLIC CONNECTION
	gen byte electricity=.
	label var electricity "Electricity main source"
	la de lblelectricity 0 "No" 1 "Yes"
	label values electricity lblelectricity


** TOILET PUBLIC CONNECTION
	*gen byte toilet=.
	label var toilet "Toilet facility"
	la de lbltoilet 0 "No" 1 "Yes"
	label values toilet lbltoilet


** LAND PHONE
	ren phone landphone
	label var landphone "Phone availability"
	la de lbllandphone 0 "No" 1 "Yes"
	label values landphone lbllandphone


** CEL PHONE
	ren cphone cellphone
	label var cellphone "Cell phone"
	la de lblcellphone 0 "No" 1 "Yes"
	label values cellphone lblcellphone


** COMPUTER

	label var computer "Computer availability"
	la de lblcomputer 0 "No" 1 "Yes"
	label values computer lblcomputer


** INTERNET
	gen byte internet= .

	label var internet "Internet connection"
	la de lblinternet 0 "No" 1 "Yes"
	label values internet lblinternet


/*****************************************************************************************************
*                                                                                                    *
                                   DEMOGRAPHIC MODULE
*                                                                                                    *
*****************************************************************************************************/


** HOUSEHOLD SIZE
	ren hhsize hsize
	la var hsize "Household size"

	bys idh: gen head=relation==1
	bys idh: egen heads=total(head)
	replace relation=1 if heads==0 & iid=="1"


** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
	recode relation (3/4=3) (7=4) (5 6 8  9=5) (10=6) (99=.), gen(relationharm)

	label var relationharm "Relationship to the head of household"
	la de lblrelationharm  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Non-relatives"
	label values relationharm  lblrelationharm

	gen byte relationcs=relation
	la var relationcs "Relationship to the head of household country/region specific"
	label define lblrelationcs 1 "Household head" 2 "Spouse" 3 "Child" 4 "Step Child" 5 "Brother/Sister" 6 "Grand child" 7 "Parents /Step Parents" 8 "Son/Daughter-in-law" 9 "Other relative" 10"Non-relative"
	label values relationcs lblrelationcs


** GENDER
	gen byte male=sex
	recode male (2=0)
	label var male "Sex of household member"
	la de lblmale 1 "Male" 0 "Female"
	label values male lblmale


** AGE
	label var age "Individual age"


** SOCIAL GROUP
	gen byte soc=.
	label var soc "Social group"
	la de lblsoc 1 "Dhivehi" 2 "English" 3 "Other" 4 "None"
	label values soc lblsoc


** MARITAL STATUS

	recode marital (1=2) (2 = 1) (3=4) (4=5)
	label var marital "Marital status"
	la de lblmarital 1 "Married" 2 "Never Married" 3 "Living Together" 4 "Divorced/separated" 5 "Widowed"
	label values marital lblmarital


/*****************************************************************************************************
*                                                                                                    *
                                   EDUCATION MODULE
*                                                                                                    *
*****************************************************************************************************/


** EDUCATION MODULE AGE
	gen byte ed_mod_age=6
	label var ed_mod_age "Education module application age"


** CURRENTLY AT SCHOOL
	gen byte atschool=attending==1
	replace atschool=. if attending==.
	label var atschool "Attending school"
	la de lblatschool 0 "No" 1 "Yes"
	label values atschool  lblatschool


** CAN READ AND WRITE
	gen byte literacy=1 if elevel2!=0
	replace literacy=0 if elevel2==12
	replace literacy=. if age<ed_mod_age

	label var literacy "Can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy


** YEARS OF EDUCATION COMPLETED
	gen byte educy=elevel2
	recode educy (18 19 20 = 0) (13=16) (15=16) (16 17 = 14)
	label var educy "Years of education"

	replace educy=. if educy>age & age!=. & educy!=.


** EDUCATIONAL LEVEL 7 CAREGORIES
	gen byte educat7=elevel2
	recode educat7 (18 19 = 7) (0 20 = 1) (1/4 = 2) (5=3) (6/11=4) (12=5) (14 16 17 =6) (13 15=7)
	replace educat7=1 if educy==0
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
	gen byte educat4=educat7
	recode educat4 ( 2/3=2) (4/5=3) (6/7 =4)
	replace educat4=1 if educy==0
	label var educat4 "Level of education 4 categories"
	label define lbleducat4 1 "No education" 2 "Primary (complete or incomplete)" ///
	3 "Secondary (complete or incomplete)" 4 "Tertiary (complete or incomplete)"
	label values educat4 lbleducat4


** EVER ATTENDED SCHOOL
	recode everattend (2=0)


	label var everattend "Ever attended school"
	la de lbleverattend 0 "No" 1 "Yes"
	label values everattend lbleverattend

	replace  educy=0 if everattend==0
	replace  educat4=1 if everattend==0
	replace  educat5=1 if everattend==0
	replace  educat7=1 if everattend==0


	local ed_var "everattend atschool literacy educy educat4 educat5 educat7 "
	foreach v in `ed_var'{
	replace `v'=. if( age<ed_mod_age & age!=.)
	}


/*****************************************************************************************************
*                                                                                                    *
                                   LABOR MODULE
*                                                                                                    *
*****************************************************************************************************/


** LABOR MODULE AGE
	gen byte lb_mod_age=15
	label var lb_mod_age "Labor module application age"


** LABOR STATUS
	gen byte lstatus=1 if activity==1
	replace lstatus=2 if activity==2 & searchforjob==1
	replace lstatus=3 if activity==2 & searchforjob==2
	replace lstatus=3 if availability==2
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus


** EMPLOYMENT STATUS
	recode empstat (1=3) (2=1) (3=4) (5 = 2) (4= 5)

	replace empstat=. if lstatus==2 | lstatus==3
	label var empstat "Employment status"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other"
	label values empstat lblempstat


** NUMBER OF ADDITIONAL JOBS
	recode otherjob (2=0), gen(njobs)

	label var njobs "Number of additional jobs"


** SECTOR OF ACTIVITY: PUBLIC - PRIVATE
	recode typeofjob (1 2 5 6 = 1) (3 4 7 0 =2) (8=.), gen(ocusec)

	replace ocusec=. if lstatus==2 | lstatus==3
	label var ocusec "Sector of activity"
	la de lblocusec 1 "Public, state owned, government, army, NGO" 2 "Private"
	label values ocusec lblocusec


** REASONS NOT IN THE LABOR FORCE
	recode nlfreason (1 2 3 5 6 7 =5) (4= 2)

	label var nlfreason "Reason not in the labor force"
	la de lblnlfreason 1 "Student" 2 "Housewife" 3 "Retired" 4 "Disabled" 5 "Other"
	label values nlfreason lblnlfreason


** UNEMPLOYMENT DURATION: MONTHS LOOKING FOR A JOB
	gen byte unempldur_l=.
	label var unempldur_l "Unemployment duration (months) lower bracket"

	gen byte unempldur_u=.
	label var unempldur_u "Unemployment duration (months) upper bracket"


** INDUSTRY CLASSIFICATION

	replace industry="" if industry=="Q17" | industry=="Q18" | industry=="Q19"
	destring industry, replace
	replace industry=int(industry/100)
	recode industry (0=10) (1/5=1) (10/14=2) (15/37=3) (40/41=4) (45=5) (50/55=6) (60/64=7) (65/74=8) (75=9) (80/99=10)
	label var industry "1 digit industry classification"
	replace industry=. if lstatus==2 | lstatus==3
	la de lblindustry 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transports and comnunications" 8 "Financial and business-oriented services" 9 "Public Administration" 10 "Other services, Unspecified"
	label values industry lblindustry


** OCCUPATION CLASSIFICATION
	replace occupation="" if occupation=="Q17" | occupation=="Q18" | occupation=="Q19"
	destring occupation, replace
	gen byte occup=int(occupation/100)
	recode occup (0/10=10) (11/19=1) (21/29=2) (31/39=3) (41/49=4) (51/59=5) (61/69=6) (71/79=7) (81/89=8) (91/99=9)
	label var occup "1 digit occupational classification"
	replace occup=. if lstatus==2 | lstatus==3
	la de lbloccup 1 "Senior officials" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup lbloccup


** FIRM SIZE
	gen byte firmsize_l=.
	label var firmsize_l "Firm size (lower bracket)"

	gen byte firmsize_u=.
	label var firmsize_u "Firm size (upper bracket)"


** HOURS WORKED LAST WEEK
	gen whours=hours*7
	replace whours=. if lstatus==2 | lstatus==3
	label var whours "Hours of work in last week"


** WAGES
	gen double wage=Q161Primary
	replace wage=. if lstatus==2 | lstatus==3
	replace wage=0 if empstat==2
	label var wage "Last wage payment"


** WAGES TIME UNIT
	gen byte unitwage=5

	label var unitwage "Last wages time unit"
	replace unitwage=. if lstatus==2 | lstatus==3
	la de lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Quarterly" 7 "Biannual" 8 "Annually" 9 "Hourly" 10 "Other"
	label values unitwage lblunitwage


** CONTRACT
	gen byte contract=.
	label var contract "Contract"
	la de lblcontract 0 "Without contract" 1 "With contract"
	label values contract lblcontract


** HEALTH INSURANCE
	gen byte healthins=.
	label var healthins "Health insurance"
	la de lblhealthins 0 "Without health insurance" 1 "With health insurance"
	label values healthins lblhealthins


** SOCIAL SECURITY
	gen byte socialsec=.
	label var socialsec "Social security"
	la de lblsocialsec 1 "With" 0 "Without"
	label values socialsec lblsocialsec


** UNION MEMBERSHIP
	gen byte union=.
	label var union "Union membership"
	la de lblunion 0 "No member" 1 "Member"
	label values union lblunion

	local lb_var "lstatus empstat njobs ocusec nlfreason unempldur_l unempldur_u industry occup firmsize_l firmsize_u whours wage unitwage contract healthins socialsec union"
	foreach v in `lb_var'{
	di "check `v' only for age>=lb_mod_age"

	replace `v'=. if( age<lb_mod_age & age!=.)
	}


/*****************************************************************************************************
*                                                                                                    *
                                   WELFARE MODULE
*                                                                                                    *
*****************************************************************************************************/


** SPATIAL DEFLATOR
	gen spdef=tocon_de/tocon_nd
	la var spdef "Spatial deflator"

** WELFARE
	gen welfare=tocon_nd/(12*hsize)
	la var welfare "Welfare aggregate"

	gen welfarenom=tocon_nd/(12*hsize)
	la var welfarenom "Welfare aggregate in nominal terms"

	gen welfaredef=tocon_de/(12*hsize)
	la var welfaredef "Welfare aggregate spatially deflated"

	gen welfshprosperity=.
	la var welfshprosperity "Welfare aggregate for shared prosperity"

	gen welfaretype="CONS"
	la var welfaretype "Type of welfare measure (income, consumption or expenditure) for welfare, welfarenom, welfaredef"

	gen welfareother=.
	la var welfareother "Welfare Aggregate if different welfare type is used from welfare, welfarenom, welfaredef"

	gen welfareothertype=""
	la var welfareothertype "Type of welfare measure (income, consumption or expenditure) for welfareother"


/*****************************************************************************************************
*                                                                                                    *
                                   NATIONAL POVERTY
*                                                                                                    *
*****************************************************************************************************/


** POVERTY LINE (NATIONAL)
	gen pline_nat=22*365/12
	label var pline_nat "National Poverty Line 22 Rf"


** HEADCOUNT RATION (NATIONAL)
	gen poor_nat=(welfare<pline_nat) if welfare!=.
	label var poor_nat "Headcount (National) (22)"
	la define lblpoor_nat 0 "Not-Poor" 1 "Poor"
	la values poor_nat lblpoor_nat


/*****************************************************************************************************
*                                                                                                    *
                                   INTERNATIONAL POVERTY
*                                                                                                    *
*****************************************************************************************************/


	local year=2011
	
** USE SARMD CPI AND PPP
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
		 unitwage contract healthins socialsec union pline_nat pline_int poor_nat poor_int spdef cpi ppp ///
		 cpiperiod welfare welfarenom welfaredef welfareother welfaretype welfareothertype

** ORDER VARIABLES

	order countrycode year idh idp wgt strata psu vermast veralt urban int_month int_year  ///
	      subnatid1 subnatid2 subnatid3 ownhouse water electricity toilet landphone cellphone ///
	      computer internet hsize relationharm relationcs male age soc marital ed_mod_age everattend ///
	      atschool electricity literacy educy educat4 educat5 educat7 lb_mod_age lstatus empstat njobs ///
	      ocusec nlfreason unempldur_l unempldur_u industry occup firmsize_l firmsize_u whours wage ///
		 unitwage contract healthins socialsec union pline_nat pline_int poor_nat poor_int spdef cpi ppp ///
		 cpiperiod welfare welfarenom welfaredef welfareother welfaretype welfareothertype
	
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


	saveold "`output'\Data\Harmonized\MDV_2009_HIES_v01_M_v01_A_SARMD_IND.dta", replace version(13)
	saveold "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\__REGIONAL\Individual Files\MDV_2009_HIES_v01_M_v01_A_SARMD_IND.dta", replace version(13)
	
	
	log close












******************************  END OF DO-FILE  *****************************************************/
