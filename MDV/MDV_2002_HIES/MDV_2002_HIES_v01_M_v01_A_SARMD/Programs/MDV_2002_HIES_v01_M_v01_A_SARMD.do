/*****************************************************************************************************
******************************************************************************************************
**                                                                                                  **
**                              SOUTH ASIA MICRO DATABASE (SARMD)                                   **
**                                                                                                  **
** COUNTRY			Maldives
** COUNTRY ISO CODE	MDV
** YEAR				2009
** SURVEY NAME		Vulnerability and poverty assessment survey – 2002
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
	local input "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\MDV\MDV_2002_HIES\MDV_2002_HIES_v01_M"
	local output "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\MDV\MDV_2002_HIES\MDV_2002_HIES_v01_M_v01_A_SARMD"

** LOG FILE
	log using "`input'\Doc\Technical\MDV_2002_HIES.log",replace

/*****************************************************************************************************
*                                                                                                    *
                                   * ASSEMBLE DATABASE
*                                                                                                    *
*****************************************************************************************************/

	* PREPARE DATASETS

	* Household
	use "`input'\Data\Stata\A1r-Household-info.dta", clear
	
	ren hhserial hhid
	ren rfoverall wght_hh  
	ren region geo_1
	label var wght_hh "household weight"
	sort hhid
	tempfile household
	save `household'

	* Employment
	use "`input'\Data\Stata\A3r-EmploymentGeneral.dta", clear
	
	ren hhserial hhid
	ren individual pid
	gen njobs=primsec==2
	drop if primsec==2
	sort hhid pid
	tempfile employment
	save `employment'
	
	use "`input'\Data\Stata\wf2002.dta", clear
	sort hhid id
	ren id pid
	keep hhid pid pce* pcer* z* spi* cpi*
	tempfile consumption
	save `consumption'
	
	* MERGE DATASETS
	
	use "`input'\Data\Stata\A2r-Individual-info.dta", clear
	ren hhserial hhid
	ren individual pid
	sort hhid pid
	
	merge m:1 hhid using `household'
	drop _merge
	
	merge 1:1 hhid pid using `employment'
	drop _merge
	
	merge 1:1 hhid pid using `consumption'
	drop _merge


/*****************************************************************************************************
*                                                                                                    *
                                   * STANDARD SURVEY MODULE
*                                                                                                    *
*****************************************************************************************************/
	
	
** COUNTRY
	gen str4 countrycode="MDV"
	label var countrycode "Country code"


** YEAR
	gen int year=2002
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
	tostring hhid, gen(idh)
	label var idh "Household id"

	tostring pid, replace

** INDIVIDUAL IDENTIFICATION NUMBER
	egen idp=concat(idh pid), punct(-)
	label var idp "Individual id"

stop
** HOUSEHOLD WEIGHTS
	gen double wgt=wght_hh
	label var wgt "Household sampling weight"


** STRATA
	gen strata=.
	label var strata "Strata"


** PSU
	gen psu=.
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
	gen urban=.
	label var urban "Urban/Rural"
	la de lblurb 1 "Urban" 0 "Rural"
	label values urban lblurban


** REGIONAL AREA 1 DIGIT ADMN LEVEL
	gen byte subnatid1=geo_1
	la de lblsubnatid1 0 "Male (capital)" 1 "North" 2 "Central North" 3 "Central" 4 "Central South" 5 "South"
	label var subnatid1 "Region at 1 digit (ADMN1)"
	label values subnatid1 lblsubnatid1


** REGIONAL AREA 2 DIGIT ADMN LEVEL
	gen byte subnatid2=.
	label var subnatid2 "Region at 2 digit (ADMN2)"
	label values subnatid2 lblsubnatid2

	
** REGIONAL AREA 3 DIGIT ADMN LEVEL
	gen byte subnatid3=.
	label var subnatid3 "Region at 3 digit (ADMN3)"
	label values subnatid3 lblsubnatid3
	
		
** HOUSE OWNERSHIP
	recode tenuretype (1=1)(2 3=0), gen(ownhouse)
	label var ownhouse "House ownership"
	la de lblownhouse 0 "No" 1 "Yes"
	label values ownhouse lblownhouse


** WATER PUBLIC CONNECTION
	gen byte water=.
	label var water "Water main source"
	la de lblwater 0 "No" 1 "Yes"
	label values water lblwater


** ELECTRICITY PUBLIC CONNECTION
	gen byte electricity=.
	label var electricity "Electricity main source"
	la de lblelectricity 0 "No" 1 "Yes"
	label values electricity lblelectricity


** TOILET PUBLIC CONNECTION
	gen byte toilet=.
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
* Construct "official" hhsize
	# delim ;
	label define membershipstatus 	1 "Household Head" 
									2 "Paying Guest" 
									3 "Foreign Domestic Servant" 
									4 "Local Domestic Servant" 
									5 "Guest" 
									6 "Other Household Member";
	label value membershipstatus membershipstatus;
	# delim cr
		
	/*
	
	The official definition in 2010 included all "family members" 
	and "paying guests" that are used to take meals together
	
	The 2003 questionnaire is different: 
	the first category rather than including "family members" only lists "household heads".
	We assume that all other family members are under the "other hh member" category: 
	the vast majority of individuals hold that category (83%).
	
	*/
	
	gen byte hhs = 0
	replace  hhs = 1 if ((membershipstatus<=2 | membershipstatus==6) & (takemeal==1) & (membershipstatus!=.))
	egen hsize=total(hhs), by(hhid)
	label var hsize "Household size"


** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
	recode membershipstatus (1=1) (6=5) (2/5=6), gen(relationharm)
	label var relationharm "Relationship to the head of household"
	la de lblrelationharm  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Non-relatives"
	label values relationharm  lblrelationharm

	gen byte relationcs=relation
	la var relationcs "Relationship to the head of household country/region specific"
	# delim ;
	label define lblrelationcs 		1 "Household Head" 
									2 "Paying Guest" 
									3 "Foreign Domestic Servant" 
									4 "Local Domestic Servant" 
									5 "Guest" 
									6 "Other Household Member";
	# delim cr
	label values relationcs lblrelationcs


** GENDER
	gen byte male=sex
	recode male (2=1) (1=0)
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
	gen marital=.
	label var marital "Marital status"
	la de lblmarital 1 "Married" 2 "Never Married" 3 "Living Together" 4 "Divorced/separated" 5 "Widowed"
	label values marital lblmarital


/*****************************************************************************************************
*                                                                                                    *
                                   EDUCATION MODULE
*                                                                                                    *
*****************************************************************************************************/


** EDUCATION MODULE AGE
	gen byte ed_mod_age=.
	label var ed_mod_age "Education module application age"


** CURRENTLY AT SCHOOL
	gen byte atschool=.
	label var atschool "Attending school"
	la de lblatschool 0 "No" 1 "Yes"
	label values atschool  lblatschool


** CAN READ AND WRITE
	gen byte literacy=.
	label var literacy "Can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy


** YEARS OF EDUCATION COMPLETED
	gen byte educy=.
	label var educy "Years of education"

** EDUCATIONAL LEVEL 7 CAREGORIES
	gen byte educat7=.
	label define lbleducat7 1 "No education" 2 "Primary incomplete" 3 "Primary complete" ///
	4 "Secondary incomplete" 5 "Secondary complete" 6 "Higher than secondary but not university" /// 
	7 "University incomplete or complete" 8 "Other" 9 "Not classified"
	label values educat7 lbleducat7
	la var educat7 "Level of education 7 categories"


** EDUCATION LEVEL 5 CATEGORIES
	gen educat5=.
	label define lbleducat5 1 "No education" 2 "Primary incomplete" ///
	3 "Primary complete but secondary incomplete" 4 "Secondary complete" ///
	5 "Some tertiary/post-secondary"
	label values educat5 lbleducat5
	la var educat5 "Level of education 5 categories"

	
** EDUCATION LEVEL 4 CATEGORIES
	gen byte educat4=.
	label var educat4 "Level of education 4 categories"
	label define lbleducat4 1 "No education" 2 "Primary (complete or incomplete)" ///
	3 "Secondary (complete or incomplete)" 4 "Tertiary (complete or incomplete)"
	label values educat4 lbleducat4


** EVER ATTENDED SCHOOL
	gen everattend=.
	label var everattend "Ever attended school"
	la de lbleverattend 0 "No" 1 "Yes"
	label values everattend lbleverattend

/*****************************************************************************************************
*                                                                                                    *
                                   LABOR MODULE
*                                                                                                    *
*****************************************************************************************************/


** LABOR MODULE AGE
	gen byte lb_mod_age=15
	label var lb_mod_age "Labor module application age"


** LABOR STATUS
	gen byte lstatus=1 if activitytype==1
	replace lstatus=3 if activitytype!=1 & activitytype!=.
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus


** EMPLOYMENT STATUS
	recode empstatus (1=3) (2=1) (3=4) (5 = 2) (4= 2), gen(empstat)
	replace empstat=. if lstatus==2 | lstatus==3
	label var empstat "Employment status"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other"
	label values empstat lblempstat


** NUMBER OF ADDITIONAL JOBS
	label var njobs "Number of additional jobs"


** SECTOR OF ACTIVITY: PUBLIC - PRIVATE
	gen ocusec=.
	label var ocusec "Sector of activity"
	la de lblocusec 1 "Public, state owned, government, army, NGO" 2 "Private"
	label values ocusec lblocusec


** REASONS NOT IN THE LABOR FORCE
	recode activitytype (2=1) (3=2)(4=5) (1=.), gen(nlfreason)
	label var nlfreason "Reason not in the labor force"
	la de lblnlfreason 1 "Student" 2 "Housewife" 3 "Retired" 4 "Disabled" 5 "Other"
	label values nlfreason lblnlfreason


** UNEMPLOYMENT DURATION: MONTHS LOOKING FOR A JOB
	gen byte unempldur_l=.
	label var unempldur_l "Unemployment duration (months) lower bracket"

	gen byte unempldur_u=.
	label var unempldur_u "Unemployment duration (months) upper bracket"


** INDUSTRY CLASSIFICATION

	replace industry=int(industry/100)
	recode industry  (1/5=1) (10/14=2) (15/37=3) (40/41=4) (45=5) (50/55=6) (60/64=7) (65/74=8) (75=9) (80/99=10)
	label var industry "1 digit industry classification"
	replace industry=. if lstatus==2 | lstatus==3
	la de lblindustry 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transports and comnunications" 8 "Financial and business-oriented services" 9 "Public Administration" 10 "Other services, Unspecified"
	label values industry lblindustry


** OCCUPATION CLASSIFICATION
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
	gen whours=hrsworked*7
	replace whours=. if lstatus==2 | lstatus==3
	label var whours "Hours of work in last week"


** WAGES
	gen double wage=.
	replace wage=. if lstatus==2 | lstatus==3
	replace wage=0 if empstat==2
	label var wage "Last wage payment"


** WAGES TIME UNIT
	gen byte unitwage=.
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


local i=1
foreach x in pce pcer{
foreach y in ztot zt zfood{

gen p`i'=`x'<`y' if `x'!=.
tab p`i' [aw=wgt]
local i=`i'+1
}
}

** SPATIAL DEFLATOR
	gen spdef=spi6
	la var spdef "Spatial deflator"

	
** WELFARE
	gen welfare=pce
	la var welfare "Welfare aggregate"

	gen welfarenom=pce
	la var welfarenom "Welfare aggregate in nominal terms"

	*gen welfaredef=pcer
	gen welfaredef=pcerr_2009/cpi2009
	la var welfaredef "Welfare aggregate spatially deflated"

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
	gen pline_nat=787.44189/cpi2009
	gen pline_nat=ztot
	label variable pline_nat "Poverty Line (National)"


** HEADCOUNT RATION (NATIONAL)
	gen poor_nat=welfaredef<pline_nat & welfaredef!=.
	la var poor_nat "People below Poverty Line (National)"
	la define poor_nat 0 "Not-Poor" 1 "Poor"
	la values poor_nat poor_nat


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


	saveold "`output'\Data\Harmonized\MDV_2002_HIES_v01_M_v01_A_SARMD_IND.dta", replace version(13)
	saveold "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\__REGIONAL\Individual Files\MDV_2002_HIES_v01_M_v01_A_SARMD_IND.dta", replace version(13)
	

	log close












******************************  END OF DO-FILE  *****************************************************/
