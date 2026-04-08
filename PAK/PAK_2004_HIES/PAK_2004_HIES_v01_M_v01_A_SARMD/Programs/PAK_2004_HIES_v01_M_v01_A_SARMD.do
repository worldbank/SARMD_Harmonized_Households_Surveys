/*****************************************************************************************************
******************************************************************************************************
**                                                                                                  **
**                       INTERNATIONAL INCOME DISTRIBUTION DATABASE (I2D2)                          **
**                                                                                                  **
** COUNTRY			PAKISTAN
** COUNTRY ISO CODE	PAK
** YEAR				2004
** SURVEY NAME		PAKISTAN SOCIAL AND LIVING STANDARDS  MEASUREMENT SURVEY (ROUND-1)
** SURVEY AGENCY	Government of Pakistan Statistics divisionFederal Statistics Bureau
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
	local input "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\PAK\PAK_2004_PSLM\PAK_2004_PSLM_v01_M"
	local output "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\PAK\PAK_2004_PSLM\PAK_2004_PSLM_v01_M_v01_A_SARMD"

** LOG FILE
	log using "`input'\Doc\Technical\PAK_2004_PSLM.log",replace



/*****************************************************************************************************
*                                                                                                    *
                                   * ASSEMBLE DATABASE
*                                                                                                    *
*****************************************************************************************************/


** DATABASE ASSEMBLENT

	use "`input'\Data\Stata\pslmA.dta", clear
	duplicates list hhcode
	ren hhcode HID
	format HID %12.0f
	sort HID

	preserve

	use "`input'\Data\Stata\PLSMclean.dta", clear
	ren hhcode HID
	format HID %12.0f
	sort HID
	tempfile wgt
	save `wgt'

	restore
	merge HID using `wgt'
	tab _
	drop _

	sort HID
	tempfile basic_info
	save `basic_info'

	use "`input'\Data\Stata\pslmB.dta", clear
	ren hhcode HID
	format HID %12.0f


	sort HID serialno
	tempfile temp
	save `temp'

	use "`input'\Data\Stata\pslmC.dta", clear
	ren hhcode HID
	format HID %12.0f
	duplicates examples HID serialno

	sort HID serialno
	merge HID serialno using `temp'
	tab _
	drop if _==1
	drop _
	duplicates examples HID serialno
	sort HID 
	save `temp', replace

	use "`input'\Data\Stata\pslmG.dta", clear
	ren hhcode HID
	format HID %12.0f
	sort HID
	merge HID using `temp'
	tab _m
	drop _m
	sort HID
	save `temp', replace

	use "`input'\Data\Stata\pslmH1_inc.dta", clear
	ren hhcode HID
	format HID %12.0f
	egen total_inc = rowtotal( inc1 inc2 inc3 inc4 inc5 inc6 inc7 inc8 inc9 inc10 inc11 inc12), missing
	sort HID
	merge HID using `temp'
	tab _m
	drop _m
	sort HID serialno
	save `temp', replace

	use "`input'\Data\Stata\pslmE.dta", clear
	ren hhcode HID
	format HID %12.0f
	sort HID serialno
	merge HID serialno using `temp'
	tab _m
	drop _m
	sort HID serialno
	merge HID using  `basic_info'
	drop _merge
	save `temp', replace

	/*
Consumption. 
*/
	use "`input'\Data\Stata\Consumption Master File.dta"
	tempfile comp
	keep if year==2004
	keep hhcode nomexpend hhsizeM eqadultM peaexpM psupind pline texpend region weight
	ren hhcode HID

	merge 1:m HID using `temp'
	tab _merge
	keep if _merge==3
	drop _merge

	save `temp', replace
	use "`input'\Data\Stata\consumption (L1-3).dta
	ren hhcode HID
	keep HID stratum substrat 
	duplicates drop stratum substrat HID, force
	
	merge 1:m HID using `temp'
	tab _merge
	keep if _merge==3

	
/*****************************************************************************************************
*                                                                                                    *
                                   * STANDARD SURVEY MODULE
*                                                                                                    *
*****************************************************************************************************/


** COUNTRY
	gen str4 countrycode="PAK"
	label var countrycode "Country code"


** YEAR
	gen int year=2004
	label var year "Year of survey"

	* There are many coding errors for the date of interview
	replace year1=2000+year1
	*replace month1=. 	if month1<9  & year1==2004 & month1!=.
	*replace month1=. 	if month1>=7 & year1==2005 & month1!=.
	*replace year1=. 	if month1<9  & year1==2004 & month1!=.
	*replace year1=. 	if month1>=7 & year1==2005 & month1!=.
	replace month1=. 	if year1!=2004 & year1!=2005
	replace year1=. 	if year1!=2004 & year1!=2005
	replace month1=. 	if month1>12 & month1!=.
	replace year1=. 	if month1>12 & month1!=.
	
** INTERVIEW YEAR
	gen int_year=year1
	label var int_year "Year of the interview"

	
** INTERVIEW MONTH
	gen int_month=month1
	la de lblint_month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
	label value int_month lblint_month
	label var int_month "Month of the interview"
	
	
** HOUSEHOLD IDENTIFICATION NUMBER
	gen double idh=HID
	label var idh "Household id"


** INDIVIDUAL IDENTIFICATION NUMBER
	gen double idp_= 100*idh+serialno
	gen idp=string(idp_,"%14.0g")
	tostring idh, replace
	label var idp "Individual id"


** HOUSEHOLD WEIGHTS
	gen double wgt=hweight
	label var wgt "Household sampling weight"


** STRATA
	gen strata=stratum
	label var strata "Strata"

	drop psu

** PSU
	gen psu= psucode
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
	gen byte urban=urbrural
	recode urban (2=0)
	label var urban "Urban/Rural"
	la de lblurban 1 "Urban" 0 "Rural"
	label values urban lblurban


** REGIONAL AREA 1 DIGIT ADMN LEVEL
	gen byte subnatid1=.
	label var subnatid1 "Region at 1 digit (ADMN1)"


** REGIONAL AREA 2 DIGIT ADMN LEVEL
	gen byte subnatid2=province
	la de lblsubnatid2 1 "Punjab" 2 "Sindh" 3 "Khyber Pakhtunkhwa" 4 "Balochistan"
	label var subnatid2 "Region at 2 digit (ADMN2)"
	label values subnatid2 lblsubnatid2

	
** REGIONAL AREA 3 DIGIT ADMN LEVEL
	gen byte subnatid3=.
	label var subnatid3 "Region at 3 digit (ADMN3)"
	label values subnatid3 lblsubnatid3


** HOUSE OWNERSHIP
	gen byte ownhouse=.
	replace ownhouse=1 if g01==1
	replace ownhouse=0 if inlist(g01,2,3,4)
	label var ownhouse "House ownership"
	la de lblownhouse 0 "No" 1 "Yes"
	label values ownhouse lblownhouse


** WATER PUBLIC CONNECTION
	gen byte water=.
	replace water=1 if g05==1
	replace water=0 if inlist(g05,2,3,4,5,6,7,8,9)
	label var water "Water main source"
	la de lblwater 0 "No" 1 "Yes"
	label values water lblwater


** ELECTRICITY PUBLIC CONNECTION
	gen byte electricity=.
	replace electricity=1 if g08==1
	replace electricity=0 if inlist(g08,2,3,4,5,6)
	label var electricity "Electricity main source"
	la de lblelectricity 0 "No" 1 "Yes"
	label values electricity lblelectricity


** TOILET PUBLIC CONNECTION
	gen byte toilet=.
	replace toilet=1 if g06==2
	replace toilet=0 if inlist(g06,1,3,4,5,6,7)
	label var toilet "Toilet facility"
	la de lbltoilet 0 "No" 1 "Yes"
	label values toilet lbltoilet


** LAND PHONE
	gen byte landphone=.
	replace landphone=1 if g09==2 | g09==4
	replace landphone=0 if inlist(g09,1,3)
	label var landphone "Phone availability"
	la de lbllandphone 0 "No" 1 "Yes"
	label values landphone lbllandphone


** CEL PHONE
	gen byte cellphone=.
	replace cellphone=1 if g09==3 | g09==4
	replace cellphone=0 if inlist(g09,1,2)
	label var cellphone "Cell phone"
	la de lblcellphone 0 "No" 1 "Yes"
	label values cellphone lblcellphone


** COMPUTER
	gen byte computer=.
	label var computer "Computer availability"
	la de lblcomputer 0 "No" 1 "Yes"
	label values computer lblcomputer


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
	gen byte hsize=hhsizeM
	label var hsize "Household size"

	
** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
	gen byte relationharm=rel
	recode relationharm (5=4) (4 6 7 8 9 = 5) (10 = 6) (0=.)
	label var relationharm "Relationship to the head of household"
	la de lblrelationharm  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Non-relatives"
	label values relationharm  lblrelationharm
	label values relationharm  lblrelationharm

	gen byte relationcs=rel
	la var relationcs "Relationship to the head of household country/region specific"
	label define lblrelationcs 1 "Head" 2 "Spouse" 3 "Child" 4 "Grandchild" 5 "Parent" 6 "Brother/Sister" 7  "Son/Daughter-in-law" 8 "Father/Mother-in-law" 9 "Other relative" 10 "Not related"
	label values relationcs lblrelationcs


** GENDER
	gen byte male= sex
	recode male (2=0)
	label var male "Sex of household member"
	la de lblmale 1 "Male" 0 "Female"
	label values male lblmale


** AGE
	*gen byte age=age
	label var age "Individual age"


** SOCIAL GROUP
	gen byte soc=.
	label var soc "Social group"
	*la de lblsoc 1 ""
	*label values soc lblsoc


** MARITAL STATUS
	*gen byte marital=marital
	recode marital (1=2) (2 5 =1) (4=5) (3=4)
	label var marital "Marital status"
	la de lblmarital 1 "Married" 2 "Never Married" 3 "Living Together" 4 "Divorced/separated" 5 "Widowed"
	label values marital lblmarital


/*****************************************************************************************************
*                                                                                                    *
                                   EDUCATION MODULE
*                                                                                                    *
*****************************************************************************************************/


** EDUCATION MODULE AGE
	gen byte ed_mod_age=4
	label var ed_mod_age "Education module application age"


** CURRENTLY AT SCHOOL
	gen byte atschool=.
	replace atschool=1 if c05==1
	replace atschool=0 if c05==2 | c03==2
	label var atschool "Attending school"
	la de lblatschool 0 "No" 1 "Yes"
	label values atschool  lblatschool

	*Literacy question asked only for people age 10 and over

** CAN READ AND WRITE
	gen byte literacy=.
	replace literacy=1 if c01==1
	replace literacy=0 if c01==2
	label var literacy "Can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy


** YEARS OF EDUCATION COMPLETED
	gen byte educy=.
	replace educy=0 if c03==2
	replace educy = c04
	replace educy = 12 if c04 == 11 
	replace educy = 14 if c04 == 12 
	replace educy = 17 if c04 == 14
	replace educy = 16 if (c04 == 13 | c04 == 15 | c04 == 16 | c04 == 17)
	replace educy = 20 if c04 == 18
	replace educy = . if c04 == 19
	label var educy "Years of education"


** EDUCATIONAL LEVEL 7 CATEGORIES
	gen byte educat7=.
	replace educat7=1 if educy==0
	replace educat7=2 if educy>=1 & educy<8
	replace educat7=3 if educy==8
	replace educat7=4 if educy>8 & educy<12
	replace educat7=5 if educy==12
	replace educat7=7 if educy>12 & educy!=.
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
	gen byte educat4=.
	replace educat4=1 if educat7==1 
	replace educat4=2 if educat7==2 | educat7==3
	replace educat4=3 if educat7==4 | educat7==5
	replace educat4=4 if educat7==6 | educat7==7
	label var educat4 "Level of education 4 categories"
	label define lbleducat4 1 "No education" 2 "Primary (complete or incomplete)" ///
	3 "Secondary (complete or incomplete)" 4 "Tertiary (complete or incomplete)"
	label values educat4 lbleducat4


** EVER ATTENDED SCHOOL
	gen byte everattend=c03
	recode everattend (2=0)
	replace everattend=1 if atschool==1
	replace everattend=. if age<ed_mod_age & age!=.
	label var everattend "Ever attended school"
	la de lbleverattend 0 "No" 1 "Yes"
	label values everattend lbleverattend


	replace educy=0 	if everattend==0
	replace educat7=1 	if everattend==0
	replace educat5=1 	if everattend==0
	replace educat4=1 	if everattend==0
	

/*****************************************************************************************************
*                                                                                                    *
                                   LABOR MODULE
*                                                                                                    *
*****************************************************************************************************/


** LABOR MODULE AGE
	gen byte lb_mod_age=10
	label var lb_mod_age "Labor module application age"


** LABOR STATUS
	gen byte lstatus=.
	replace lstatus = 1 if e01== 1 | (e01 == 2 & e02 == 1) | (e01 == 2 & e03 == 1) | (e01 == 2 & e06 == 3) | (e01 == 2 & e06 == 4)
	replace lstatus = 2 if e01 == 2 & e02 == 2 & e03 == 2
	replace lstatus = 3 if e01 == 2 & e02 == 2 & e03 == 2 & inlist(e05,1,2,4,5,6,7,8,9)
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus


** EMPLOYMENT STATUS
	gen byte empstat=e07
	recode empstat (1=1) (2 3 4 5 8 = 4) (6=2)  (7=3)
	replace empstat=. if lstatus!=1
	label var empstat "Employment status"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed"
	label values empstat lblempstat


** NUMBER OF ADDITIONAL JOBS
	gen byte njobs=.
	label var njobs "Number of additional jobs"


** SECTOR OF ACTIVITY: PUBLIC - PRIVATE
	gen byte ocusec=e08
	recode ocusec (1=1) (2 3 =2) (4=1) (5=.)
	replace  ocusec=. if lstatus!=1
	label var ocusec "Sector of activity"
	la de lblocusec 1 "Public, state owned, government, army, NGO" 2 "Private"
	label values ocusec lblocusec


** REASONS NOT IN THE LABOR FORCE

	gen byte nlfreason=.
	replace nlfreason=1 if e05==5
	replace nlfreason=2 if e05==6
	replace nlfreason=3 if e05==7
	replace nlfreason=4 if e05==1
	replace nlfreason=5 if inlist(e05,0,2,3,4,8,9)
	replace nlfreason=. if lstatus!=3
	label var nlfreason "Reason not in the labor force"
	la de lblnlfreason 1 "Student" 2 "Housewife" 3 "Retired" 4 "Disable" 5 "Other"
	label values nlfreason lblnlfreason


** UNEMPLOYMENT DURATION: MONTHS LOOKING FOR A JOB
	gen byte unempldur_l=.
	label var unempldur_l "Unemployment duration (months) lower bracket"

	gen byte unempldur_u=.
	label var unempldur_u "Unemployment duration (months) upper bracket"


** INDUSTRY CLASSIFICATION
	gen byte industry=e10
	recode industry (9=10)
	label var industry "1 digit industry classification"

/*
Original data includes Public Administration in a bigger group called "Social & Personal services". It is coded as 10.
*/
	la de lblindustry 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Comnunications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industry lblindustry


** OCCUPATION CLASSIFICATION
	gen byte occup=e09
	label var occup "1 digit occupational classification"
	la de lbloccup 1 "Senior officials" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup lbloccup


** FIRM SIZE
	gen byte firmsize_l=.
	label var firmsize_l "Firm size (lower bracket)"

	gen byte firmsize_u=.
	label var firmsize_u "Firm size (upper bracket)"


** HOURS WORKED LAST WEEK
	gen whours=.
	label var whours "Hours of work in last week"


** WAGES
	gen double wage=.
	replace wage=e13 if e13!=.
	replace wage=e16 if e16!=.
	replace wage=. if lstatus!=1
	label var wage "Last wage payment"


** WAGES TIME UNIT
	gen byte unitwage=.
	replace unitwage=2 if e13!=.
	replace unitwage=8 if e16!=.
	replace unitwage=. if lstatus!=1
	label var unitwage "Last wages time unit"
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


/*****************************************************************************************************
*                                                                                                    *
                                   WELFARE MODULE
*                                                                                                    *
*****************************************************************************************************/


** SPATIAL DEFLATOR
	gen spdef=psupind
	la var spdef "Spatial deflator"


** WELFARE
	gen welfare=nomexpend/hsize
	la var welfare "Welfare aggregate"

	gen welfarenom=nomexpend/hsize
	la var welfarenom "Welfare aggregate in nominal terms"

	gen welfaredef=texpend/hsize
	la var welfaredef "Welfare aggregate spatially deflated"

	gen welfaretype="CONS"
	la var welfaretype "Type of welfare measure (income, consumption or expenditure) for welfare, welfarenom, welfaredef"

	gen welfareother=peaexpM
	la var welfareother "Welfare Aggregate if different welfare type is used from welfare, welfarenom, welfaredef"

	gen welfareothertype="CON"
	la var welfareothertype "Type of welfare measure (income, consumption or expenditure) for welfareother"


/*****************************************************************************************************
*                                                                                                    *
                                   NATIONAL POVERTY
*                                                                                                    *
*****************************************************************************************************/

	
**ADULT EQUIVALENCY
	gen eqadult=eqadultM
	label var eqadult "Adult Equivalent (Household)"


**NATIONAL POVERTY LINE
	gen pline_nat=pline
	label var pline_nat "National Poverty Line"


** HEADCOUNT RATIO (NATIONAL)
	gen poor_nat=welfareother<pline_nat if welfareother!=.
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
	merge m:1 countrycode year urb using "D:\SOUTH ASIA MICRO DATABASE\DOCS\CPI and PPP\cpi_ppp_povcalnet.dta", ///
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

	keep countrycode year idh idp wgt strata psu vermast veralt urban int_month int_year ///
	     subnatid1 subnatid2 subnatid3 ownhouse water electricity toilet landphone cellphone ///
	     computer internet hsize eqadult relationharm relationcs male age soc marital ed_mod_age everattend ///
	     atschool electricity literacy educy educat4 educat5 educat7 lb_mod_age lstatus empstat njobs ///
	     ocusec nlfreason unempldur_l unempldur_u industry occup firmsize_l firmsize_u whours wage ///
		 unitwage contract healthins socialsec union pline_nat pline_int poor_nat poor_int spdef cpi ppp ///
		 cpiperiod welfare welfarenom welfaredef welfareother welfaretype welfareothertype

** ORDER VARIABLES

	order countrycode year idh idp wgt strata psu vermast veralt urban int_month int_year ///
	      subnatid1 subnatid2 subnatid3 ownhouse water electricity toilet landphone cellphone ///
	     computer internet hsize eqadult relationharm relationcs male age soc marital ed_mod_age everattend ///
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

	
	saveold "`output'\Data\Harmonized\PAK_2004_PSLM_v01_M_v01_A_SARMD_IND.dta", replace version(13)
	saveold "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\__REGIONAL\Individual Files\PAK_2004_PSLM_v01_M_v01_A_SARMD_IND.dta", replace version(13)


	log close




******************************  END OF DO-FILE  *****************************************************/
