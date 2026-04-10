/*****************************************************************************************************
******************************************************************************************************
**                                                                                                  **
**                                   SOUTH ASIA MICRO DATABASE                                      **
**                                                                                                  **
** COUNTRY	Sri Lanka
** COUNTRY ISO CODE	LKA
** YEAR	2002
** SURVEY NAME	HOUSEHOLD INCOME AND EXPENDITURE SURVEY - 2002
** SURVEY AGENCY	NATIONAL HOUSEHOLD SAMPLE SURVEY PROGRAMME
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
	set mem 800m
	
** DIRECTORY
	local input "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\LKA\LKA_2002_HIES\LKA_2002_HIES_v01_M"
	local output "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\LKA\LKA_2002_HIES\LKA_2002_HIES_v01_M_v01_A_SARMD\"

** LOG FILE
	log using "`input'\Doc\Technical\LKA_2002_HIES.log",replace

/*****************************************************************************************************
*                                                                                                    *
                                   * ASSEMBLE DATABASE
*                                                                                                    *
*****************************************************************************************************/


** DATABASE ASSEMBLENT

global dataorig "`input'\Data\Stata"

* PREPARE DATABASES
	
* Employment & Income

	use "$dataorig\_occup.dta", clear 
	gen INDID = psrn 
	gen hhid= district*10000 + hhn 
	sort hhid INDID 

	* Only one employment record
	sort hhid INDID prinseco
	bys hhid INDID: gen n=_n
	replace n=n-1
	bys hhid INDID: egen njobs=max(n)
	drop if prinseco==2
	sort hhid INDID wages
	duplicates tag hhid INDID, gen(tag)
	drop if tag==1 & prinseco==.
	drop prinseco tag n

	drop if psrn>=41 
	drop if psrn==. & psrn==. 

	tempfile employment
	save `employment'

* Own House
	* Monthly rental value of owner occupied house
	use "$dataorig\Section_37.dta", clear 
	gen hhid=  district*10000 +  hsno 
	keep hhid r17q1 r17v1 
	sort hhid 
	tempfile own
	save `own'
	
* Poverty
	use "$dataorig\_poverty.dta", clear 
	gen hhid= district*10000 + hhn 
	sort hhid 
	tempfile poverty
	save `poverty'

* MERGE

* Demographic
	use "$dataorig\Section_1.dta", clear 
	
	* Keep only individuals living in the house
	drop if r1c1>=41
	* Keep only people who completed the questionnaire
	drop if rcode!=1
	
	rename ori_hid hhid 
	sort hhid 
	by hhid: egen hhsize= count(r1c1) 
	gen INDID =  r1c1 
	gen psu=district*1000+psun 
	sort hhid INDID 

* Employmen & Income
	merge hhid INDID using `employment'
	tab 	_merge
	drop 	_merge
	sort hhid INDID

* Housing
	merge hhid using `own'
	tab 	_merge
	drop 	_merge
	sort hhid INDID
	
* Poverty
	merge hhid using `poverty'
	tab 	_merge
	drop 	_merge
	sort hhid INDID
	
* Consumption Aggregate

	tostring hhid, replace

	merge m:1 hhid using "`input'\Data\Stata\wfile200102.dta"
	tab _merge
	keep if _merge==3
/*	
stop
	
	use "$dataorig\_poverty.dta", clear 
	gen hhid=  district*10000 +  hhn
	sort hhid 

	merge hhid using "`c'" 
	tab _merge 
	drop _merge 
	sort hhid INDID

	save "`input'\Data\Temporary\hies_2002_i2d2.dta", replace

	use "`input'\Data\Stata\hies_2002.dta", clear

	sort hhid indid
	gen double HHID=real(hhid)
	drop hhid
	ren HHID hhid

	egen byte INDID=group(hhid indid)
	su hhid
	su INDID


	save "`input'\Data\Temporary\hies_2002_v2.dta", replace

	use "`input'\Data\Temporary\hies_2002_i2d2.dta", clear

	egen byte indid=group(hhid INDID)
	drop INDID
	ren indid INDID
	su hhid
	su INDID


	merge 1:1 hhid INDID using "`input'\Data\Temporary\hies_2002_v2.dta"
*/

/*****************************************************************************************************
*                                                                                                    *
                                   * STANDARD SURVEY MODULE
*                                                                                                    *
*****************************************************************************************************/


** COUNTRY
	gen str4 countrycode="LKA"
	label var countrycode "Country code"


** YEAR
	gen int year=2002
	label var year "Year of survey"
	
	
** INTERVIEW YEAR
	gen byte int_year=.
	label var int_year "Year of the interview"
	
	
** INTERVIEW MONTH
	gen byte int_month=month
	la de lblint_month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
	label value int_month lblint_month
	label var int_month "Month of the interview"

** HOUSEHOLD IDENTIFICATION NUMBER
	gen idh=hhid
	label var idh "Household id"

** INDIVIDUAL IDENTIFICATION NUMBER
	egen idp=concat(idh INDID)
	label var idp "Individual id"


** HOUSEHOLD WEIGHTS
	gen double wgt=weight
	label var wgt "Household sampling weight"


** STRATA
	gen strata=sector
	label var strata "Strata"


** PSU
	*gen psu=psu
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
	gen byte urban=sector
	recode urban (1=1) (2=0) (3=0)
	label var urban "Urban/Rural"
	la de lblurban 1 "Urban" 0 "Rural"
	label values urban lblurban

	
** REGIONAL AREA 1 DIGIT ADMN LEVEL
	gen byte subnatid1= prov
	la de lblsubnatid1 1 "Western" 2 "Central" 3 "Southern" 4 "Northern" 5 "Eastern" 6 "North Western" 7 "North Central" 8 "Uva" 9 "Sabaragamuwa"
	label var subnatid1 "Macro subnatid1al areas"
	label values subnatid1 lblsubnatid1


** REGIONAL AREA 2 DIGIT ADMN LEVEL
	gen byte subnatid2=district
	la de lblsubnatid2  11 "Colombo" 12 "Gampaha" 13 "Kalutara" 21 "Kandy" 22 "Matale" 23 "Nuwara-eliya" 31 "Galle" 32 "Matara" 33 "Hambantota" 41 "Jaffna" 42 "Mannar" 43 "Vavuniya" 44 "Mullaitivu" 45 "Kilinochchi" 51 "Batticaloa" 52 "Ampara" 53 "Tricomalee" 61 "Kurunegala" 62 "Puttlam" 71 "Anuradhapura" 72 "Polonnaruwa" 81 "Badulla" 82 "Moneragala" 91 "Ratnapura" 92 "Kegalle"
	label var subnatid2 "Region at 1 digit (ADMN1)"
	label values subnatid2 lblsubnatid2

	
** REGIONAL AREA 3 DIGIT ADMN LEVEL
	gen byte subnatid3=.
	label var subnatid3 "Region at 3 digit (ADMN3)"
	label values subnatid3 lblsubnatid3
	

** HOUSE OWNERSHIP
	gen byte ownhouse= r17q1
	recode ownhouse (2=0)
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
	gen byte landphone=.
	label var landphone "Phone availability"
	la de lbllandphone 0 "No" 1 "Yes"
	label values landphone lbllandphone


** CEL PHONE
	gen byte cellphone=.
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
	label var hsize "Household size"


** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
	gen byte relationharm=r1c3
	recode relationharm ( 6/9=6)
	label var relationharm "Relationship to the head of household"
	la de lblrelationharm  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Non-relatives"
	label values relationharm  lblrelationharm

	gen byte relationcs=r1c3
	la var relationcs "Relationship to the head of household country/region specific"
	la define lblrelationcs 1 "Head" 2 "Wife/Husband" 3 "Son/Daughter" 4 "Parents" 5 "Other relative" 6 "Domestic servants" 7 "Boarder" 9 "Other"
	label values relationcs lblrelationcs


** GENDER
	gen byte male= r1c4
	recode male (2=0)
	label var male "Sex of household member"
	la de lblmale 1 "Male" 0 "Female"
	label values male lblmale


** AGE
	gen byte age= r1c5
	label var age "Individual age"


** SOCIAL GROUP
	gen byte soc=r1c6
	recode soc (9=7)
	label var soc "Social group"
	la de lblsoc 1 "Sinhala" 2 "Sri Lanka Tamil" 3 "Indian Tamil" 4 "Sri Lanka Moors" 5 "Malay" 6 "Burgher" 7 "Other"
	label values soc lblsoc

** MARITAL STATUS
	gen byte marital=r1c9
	recode marital (1=2) (2=1) (3=5) (4/5=4)
	label var marital "Marital status"
	la de lblmarital 1 "Married" 2 "Never Married" 3 "Living Together" 4 "Divorced/separated" 5 "Widowed"
	label values marital lblmarital


/*****************************************************************************************************
*                                                                                                    *
                                   EDUCATION MODULE
*                                                                                                    *
*****************************************************************************************************/


** EDUCATION MODULE AGE
	gen byte ed_mod_age=5
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
	gen byte educy=r1c8
	recode educy (19 91 = 0) (14=13) (15 = 17) (16 = 19)
	label var educy "Years of education"


** EDUCATIONAL LEVEL 7 CATEGORIES
	gen byte educat7= r1c8
	recode educat7 (19 91 = 1) (0/5 = 2) (6 = 3) (7/10 = 4) (11/14 = 5) (15/16 = 7)
	replace educat7=. if age<5
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
	gen byte everattend=.
	replace everattend=0 if educat4==1
	replace everattend=1 if educat4>1 | atschool==1
	label var everattend "Ever attended school"
	la de lbleverattend 0 "No" 1 "Yes"
	label values everattend lbleverattend


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
	replace lstatus=1 if r1c10==1
	replace lstatus=2 if r1c10==2
	replace lstatus=3 if r1c10>2
	replace lstatus=. if age<10
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus


** EMPLOYMENT STATUS
	gen byte empstat=1 if r1c11==1
	replace empstat=4 if r1c12==1| r1c13==1 | r1c14==1
	label var empstat "Employment status"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed"
	label values empstat lblempstat
	replace empstat=. if lstatus!=1

** NUMBER OF ADDITIONAL JOBS
	label var njobs "Number of additional jobs"

** SECTOR OF ACTIVITY: PUBLIC - PRIVATE
	gen byte ocusec=.
	label var ocusec "Sector of activity"
	la de lblocusec 1 "Public, state owned, government, army, NGO" 2 "Private"
	label values ocusec lblocusec

** REASONS NOT IN THE LABOR FORCE
	recode r1c10 (1 2 = . ) (3=1) (4=2) (5 9 =5), gen(nlfreason)
	label var nlfreason "Reason not in the labor force"
	la de lblnlfreason 1 "Student" 2 "Housewife" 3 "Retired" 4 "Disable" 5 "Other"
	label values nlfreason lblnlfreason

** UNEMPLOYMENT DURATION: MONTHS LOOKING FOR A JOB
	gen byte unempldur_l=.
	label var unempldur_l "Unemployment duration (months) lower bracket"

	gen byte unempldur_u=.
	label var unempldur_u "Unemployment duration (months) upper bracket"

** INDUSTRY CLASSIFICATION
	gen byte industry=.
	gen str4 ind_ISIC = string(  indus, "%04.0f") 
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


** OCCUPATION CLASSIFICATION
	gen byte occup=int(occp/1000)
	recode occup (0 =10)
	replace occup=. if lstatus!=1
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
	gen double wage=wages
	replace wage=. if lstatus!=1
	label var wage "Last wage payment"


** WAGES TIME UNIT
	gen byte unitwage=5
	replace unitwage=. if wage==.
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
	gen spdef=rpccons/npccons
	la var spdef "Spatial deflator"


** WELFARE
	gen welfare=npccons
	la var welfare "Welfare aggregate"

	gen welfarenom=npccons
	la var welfarenom "Welfare aggregate in nominal terms"

	gen welfaredef=rpccons
	la var welfaredef "Welfare aggregate spatially deflated"

	gen welfaretype="CONS"
	la var welfaretype "Type of welfare measure (income, consumption or expenditure) for welfare, welfarenom, welfaredef"

	gen welfareother=pcincome
	la var welfareother "Welfare Aggregate if different welfare type is used from welfare, welfarenom, welfaredef"

	gen welfareothertype="INC"
	la var welfareothertype "Type of welfare measure (income, consumption or expenditure) for welfareother"

	
/*****************************************************************************************************
*                                                                                                    *
                                   NATIONAL POVERTY
*                                                                                                    *
*****************************************************************************************************/


** POVERTY LINE (NATIONAL)
	gen pline_nat=1423
	label variable pline_nat "Poverty Line (National)"

	
** HEADCOUNT RATIO (NATIONAL)
	gen poor_nat=welfaredef<pline_nat if welfaredef!=.
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

	keep countrycode year idh idp wgt strata psu vermast veralt urban int_month int_year ///
	     subnatid1 subnatid2 subnatid3 ownhouse water electricity toilet landphone cellphone ///
	     computer internet hsize relationharm relationcs male age soc marital ed_mod_age everattend ///
	     atschool electricity literacy educy educat4 educat5 educat7 lb_mod_age lstatus empstat njobs ///
	     ocusec nlfreason unempldur_l unempldur_u industry occup firmsize_l firmsize_u whours wage ///
		 unitwage contract healthins socialsec union pline_nat pline_int poor_nat poor_int spdef cpi ppp ///
		 cpiperiod welfare welfarenom welfaredef welfareother welfaretype welfareothertype

** ORDER VARIABLES

	order countrycode year idh idp wgt strata psu vermast veralt urban int_month int_year ///
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

	save "`output'\Data\Harmonized\LKA_2002_HIES_v01_M_v01_A_SARMD_IND.dta", replace
	save "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\__REGIONAL\Individual Files\LKA_2002_HIES_v01_M_v01_A_SARMD_IND.dta", replace


	log close




******************************  END OF DO-FILE  *****************************************************/
