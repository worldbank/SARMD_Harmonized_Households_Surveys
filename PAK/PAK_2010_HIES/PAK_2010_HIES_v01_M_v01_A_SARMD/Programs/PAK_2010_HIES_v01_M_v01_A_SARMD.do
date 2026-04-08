/*****************************************************************************************************
******************************************************************************************************
**                                                                                                  **
**                                   SOUTH ASIA MICRO DATABASE                                      **
**                                                                                                  **
** COUNTRY			Pakistan
** COUNTRY ISO CODE	PAK
** YEAR				2010
** SURVEY NAME		Pakistan Social and Living Standards Measurement Survey (PSLM)
** SURVEY SOURCE	Government of Pakistan Statistics division Federal Statistics Bureau
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
	local input "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\PAK\PAK_2010_PSLM\PAK_2010_PSLM_v01_M"
	local output "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\PAK\PAK_2010_PSLM\PAK_2010_PSLM_v01_M_v01_A_SARMD"

** LOG FILE
	log using "`input'\Doc\Technical\PAK_2010_PSLM.log",replace


/*****************************************************************************************************
*                                                                                                    *
                                   * ASSEMBLE DATABASE
*                                                                                                    *
*****************************************************************************************************/


** DATABASE ASSEMBLENT

/*
Consumption. From Freeha's Database
*/
	use "`input'\Data\Stata\Consumption Master File.dta"
	tempfile comp
	keep if year==2010
	keep hhcode nomexpend eqadultM peaexpM psupind pline texpend region hhsizeM
	save  `comp' , replace

/*
Household Roster
*/
	use "`input'\Data\Stata\plist.dta", clear
	tempfile aux
	isid hhcode idc
	
	merge m:1 hhcode using `comp'
	drop _merge
	
	save `aux', replace


/*
Employment
*/
	use "`input'\Data\Stata\sec_e_.dta", clear
	isid hhcode idc
	merge 1:1 hhcode idc using `aux'
	tab _merge

/*
3 obs deleted
*/

	*drop if _merge==1
	drop _merge
	save `aux', replace


/*
Education
*/
	use "`input'\Data\Stata\sec c.dta", clear
	isid hhcode idc 
	merge 1:1 hhcode idc using `aux'
	tab _merge

/*
0 obs deleted
*/
	*drop if _merge==1
	drop _merge
	save `aux', replace


/*
Detail on the family (housing info)
*/
	use "`input'\Data\Stata\sec g.dta", clear
	isid hhcode
	merge 1:m hhcode using `aux'
	tab _merge
	*drop if _merge==1

/*
0 obs deleted
*/
	drop _merge
	save `aux', replace

/*
Assets in possession
*/
	use "`input'\Data\Stata\sec f2.dta", clear
	isid hhcode
	merge 1:m hhcode using `aux'
	tab _merge

/*
0 obs deleted
*/
	*drop if _merge==1
	drop _merge
	save `aux', replace

	use "`input'\Data\Stata\sec_a.dta", clear
	isid hhcode
	merge 1:m hhcode using `aux'
	tab _merge
	*drop if _merge==1
	drop _merge
	save `aux', replace

	use `aux', clear
	merge m:1 hhcode using `comp'
	tab _merge
	drop _merge

	***************************************************************************************************
* Rename Variables

ren Enu_Date 	enu_date
ren region		urbrural
	
	/*
	***************************************************************************************************
	tempfile aux
	save `aux', replace

	use  "`input'\Data\Stata\PSLM1011_clean.dta"
	ren sex sbq03
	ren relhead sbq02
	ren mstatus sbq06
	ren Scq01 scq01
	ren Scq03 scq03
	ren Scq04 Scq04
	ren Scq05 scq05
	ren Seq01 seq01
	ren Seq03 seq03
	ren Seq04 seq04
	ren Seq05 seq05
	ren Seq06 seq06
	ren Seq08 seq08

	merge 1:1 hhcode idc using `aux'
*/

/*****************************************************************************************************
*                                                                                                    *
                                   * STANDARD SURVEY MODULE
*                                                                                                    *
*****************************************************************************************************/


** COUNTRY
	gen str4 countrycode="PAK"
	label var countrycode "Country code"


** YEAR
	gen int year=2010
	label var year "Year of survey"


	split enu_date,  parse(/) g(d)
	destring d1 d2 d3, replace
	replace d3=2000+d3
	*replace d2=. if d2<7  & d3==2010 & d2!=.
	*replace d2=. if d2>=7 & d3==2011 & d2!=.
	
	
** INTERVIEW YEAR
	gen int_year=d3
	label var int_year "Year of the interview"

	
** INTERVIEW MONTH
	gen int_month=d2
	la de lblint_month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
	label value int_month lblint_month
	label var int_month "Month of the interview"

	
** HOUSEHOLD IDENTIFICATION NUMBER
	gen double idh_=hhcode


** INDIVIDUAL IDENTIFICATION NUMBER
	gen double idp_= hhcode*100+idc
	gen idp=string(idp_,"%16.0g")
	gen idh=string(idh_,"%16.0g")
	label var idp "Individual id"
	label var idh "Household id"


** HOUSEHOLD WEIGHTS
	gen double wgt=weight
	label var wgt "Household sampling weight"


** STRATA
	gen strata=.
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
	gen byte ownhouse=1 if sgq01==1 | sgq01==2
	replace ownhouse=0 if sgq01>2 & sgq01<=5
	label var ownhouse "House ownership"
	la de lblownhouse 0 "No" 1 "Yes"
	label values ownhouse lblownhouse


** WATER PUBLIC CONNECTION
	gen byte water=1 if sgq05==1
	replace water=0 if sgq05>=2 & sgq05<=10
	label var water "Water main source"
	la de lblwater 0 "No" 1 "Yes"
	label values water lblwater


** ELECTRICITY PUBLIC CONNECTION
/*
There is no explicit question. Survey asks four main energy used for cooking or lighting. Not for availability of electricity.
*/
	recode sgq08 (1=1) (2 3 4 5 6 = 0), gen(electricity)
	label var electricity "Electricity main source"
	la de lblelectricity 0 "No" 1 "Yes"
	label values electricity lblelectricity


** TOILET PUBLIC CONNECTION
	gen byte toilet=1 if sgq06==2
	replace toilet=0 if sgq06==1 | sgq06>2 & sgq05<=7

	label var toilet "Toilet facility"
	la de lbltoilet 0 "No" 1 "Yes"
	label values toilet lbltoilet


** LAND PHONE
	gen byte landphone=1 if sgq09==2 | sgq09==4
	replace landphone=0 if sgq09==1 | sgq09==3
	label var landphone "Phone availability"
	la de lbllandphone 0 "No" 1 "Yes"
	label values landphone lbllandphone


** CEL PHONE
	gen byte cellphone=1 if sgq09==3 | sgq09==4
	replace cellphone=0 if sgq09==1 | sgq09==2
	label var cellphone "Cell phone"
	la de lblcellphone 0 "No" 1 "Yes"
	label values cellphone lblcellphone


** COMPUTER
	gen byte computer=1 if sf2q11l==1
	replace computer=0 if sf2q11l==2
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
	gen byte relationharm=Sbq02
	recode relationharm (4 6 7 8 9 10 =5) (5=4) (11 12 = 6)
	label var relationharm "Relationship to the head of household"
	la de lblrelationharm  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Non-relatives"
	label values relationharm  lblrelationharm

	gen byte relationcs=Sbq02
	la var relationcs "Relationship to the head of household country/region specific"
	label define lblrelationcs 1 "Head" 2 "Spouse" 3 "Son/Daughter" 4 "Grandchild" 5 "Father/Mother" 6 "Brother/Sister" 7  "Nephew/Niece" 8 "Son/Daughter-in-law" 9 "Brother/Sister-in-law" 10 "Father/Mother-in-law" 11 "Servant/their relatives" 12 "Other"
	label values relationcs lblrelationcs


** GENDER
	gen byte male=Sbq03
	recode male (2=0)
	label var male "Sex of household member"
	la de lblmale 1 "Male" 0 "Female"
	label values male lblmale


** AGE
	gen age=Age
	label var age "Individual age"


** SOCIAL GROUP
	gen byte soc=.
	label var soc "Social group"
	la de lblsoc 1 ""
	label values soc lblsoc


** MARITAL STATUS
	gen byte marital=1 if Sbq06==2 | Sbq06==5
	replace marital=2 if Sbq06==1
	replace marital=4 if Sbq06==4
	replace marital=5 if Sbq06==3
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
	gen byte atschool=1 if Scq05==1
	replace atschool=0 if Scq05==2
	replace atschool=0 if Scq03==2
	replace atschool=. if age<ed_mod_age & age!=.
	label var atschool "Attending school"
	la de lblatschool 0 "No" 1 "Yes"
	label values atschool  lblatschool


** CAN READ AND WRITE
	gen byte literacy=Scq01
	replace literacy=0 if Scq01==2
	replace literacy=. if age<ed_mod_age & age!=.
	label var literacy "Can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy


** YEARS OF EDUCATION COMPLETED
	gen byte educy=Scq04
	replace educy=13 if Scq04==17 /* Diploma */
	replace educy=14 if Scq04==14 /* BA/BSc */
	replace educy=16 if Scq04==18 /* Engineer */
	replace educy=17 if Scq04==19 /* Medicine */
	replace educy=16 if Scq04==20 /* Agriculture */
	replace educy=16 if Scq04==21 /* Law */
	replace educy=16 if Scq04==16 /* MA/MSc */
	replace educy=19 if Scq04==22 /* MPhl/PhD */
	replace educy=. if Scq04==23 /* Others */

/*
CHECK!! Source: "http://www-db.in.tum.de/teaching/ws1112/hsufg/Taxila/Site/formal.html"
*/
	replace educy=. if age<ed_mod_age & age!=.
	label var educy "Years of education"
	replace educy=. if age<educy & age!=. & educy!=.


** EDUCATIONAL LEVEL 7 CATEGORIES
	gen byte educat7=1 if Scq04==0
	replace educat7=2 if Scq04 >0 & Scq04<8
	replace educat7=3 if Scq04==8
	replace educat7=4 if Scq04>8 &  Scq04<12
	replace educat7=5 if Scq04==12
	replace educat7=7 if Scq04>12 & Scq04<=22
	replace educat7=6 if Scq04==17
	replace educat7=. if Scq04==23
	replace educat7=. if age<ed_mod_age & age!=.
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
	gen byte everattend=Scq03
	replace everattend=0 if everattend==2
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

/*
Reported in monthly basis. (not in a weekly basis)
*/
	gen byte lstatus=1 if Seq01==1 | Seq03==1
	replace lstatus=2 if Seq01==2 & Seq03==2
	replace lstatus=3 if Seq01==2 & Seq03==3
	replace lstatus=. if age<lb_mod_age & age!=.

	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus


** EMPLOYMENT STATUS
	gen byte empstat=1 if Seq06==4
	replace empstat=2 if Seq06==5
	replace empstat=3 if Seq06==1 | Seq06==2
	replace empstat=4 if Seq06==3 | Seq06>=6 & Seq06<=9

	replace empstat=. if lstatus!=1
	label var empstat "Employment status"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed"
	label values empstat lblempstat


** NUMBER OF ADDITIONAL JOBS
	gen byte njobs=.

	replace njobs=. if lstatus!=1
	label var njobs "Number of additional jobs"


** SECTOR OF ACTIVITY: PUBLIC - PRIVATE
	gen byte ocusec=.
	replace ocusec=. if lstatus!=1
	label var ocusec "Sector of activity"
	la de lblocusec 1 "Public, state owned, government, army, NGO" 2 "Private"
	label values ocusec lblocusec


** REASONS NOT IN THE LABOR FORCE
	gen byte nlfreason=.
	replace nlfreason=. if lstatus!=3
	label var nlfreason "Reason not in the labor force"
	la de lblnlfreason 1 "Student" 2 "Housewife" 3 "Retired" 4 "Disable" 5 "Other"
	label values nlfreason lblnlfreason


** UNEMPLOYMENT DURATION: MONTHS LOOKING FOR A JOB
	gen byte unempldur_l=.
	replace unempldur_l=. if lstatus!=2
	label var unempldur_l "Unemployment duration (months) lower bracket"

	gen byte unempldur_u=.
	replace unempldur_u=. if lstatus!=2
	label var unempldur_u "Unemployment duration (months) upper bracket"


** INDUSTRY CLASSIFICATION
	gen byte industry=1 if Seq05>=1 & Seq05<=5
	replace industry=2 if Seq05>=10 & Seq05<=14
	replace industry=3 if Seq05>=15 & Seq05<=37
	replace industry=4 if Seq05>=40 & Seq05<=41
	replace industry=5 if Seq05==45
	replace industry=6 if Seq05>=51 & Seq05<=55
	replace industry=7 if Seq05>=60 & Seq05<=64
	replace industry=8 if Seq05>=65 & Seq05<=74
	replace industry=9 if Seq05==75
	replace industry=10 if Seq05>=80 & Seq05<=99
	replace industry=. if lstatus!=1
	label var industry "1 digit industry classification"
	la de lblindustry 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Comnunications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industry lblindustry


** OCCUPATION CLASSIFICATION
	gen byte occup=.
	replace occup=10 if Seq04==1
	replace occup=1 if Seq04>=11 & Seq04<=13
	replace occup=2 if Seq04>=21 & Seq04<=24
	replace occup=3 if Seq04>=31 & Seq04<=34
	replace occup=4 if Seq04>=41 & Seq04<=42
	replace occup=5 if Seq04>=51 & Seq04<=52
	replace occup=6 if Seq04>=61 & Seq04<=62
	replace occup=7 if Seq04>=71 & Seq04<=74
	replace occup=8 if Seq04>=81 & Seq04<=83
	replace occup=9 if Seq04>=91 & Seq04<=93

	replace occup=. if lstatus!=1
	label var occup "1 digit occupational classification"
	la de lbloccup 1 "Senior officials" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup lbloccup


** FIRM SIZE
	gen byte firmsize_l=.
	replace firmsize_l=. if lstatus!=1
	label var firmsize_l "Firm size (lower bracket)"

	gen byte firmsize_u=.
	replace firmsize_u=. if lstatus!=1
	label var firmsize_u "Firm size (upper bracket)"


** HOURS WORKED LAST WEEK
	gen whours=.
	replace whours=. if lstatus!=1
	label var whours "Hours of work in last week"


** WAGES

/*
Last monthly wage in main occupation (when wage is reported in monthly basis)
*/
	gen double wage=Seq08
	replace wage=. if lstatus!=1
	label var wage "Last wage payment"


** WAGES TIME UNIT

/*
Reported in monthly basis. (main occupation in the last month)
*/
	gen byte unitwage=5

	replace unitwage=. if lstatus!=1
	label var unitwage "Last wages time unit"
	la de lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Every two months"  5 "Monthly" 6 "Quarterly" 7 "Every six months" 8 "Annually" 9 "Hourly" 10 "Other"
	label values unitwage lblunitwage


** CONTRACT
	gen byte contract=.
	replace contract=. if lstatus!=1
	label var contract "Contract"
	la de lblcontract 0 "Without contract" 1 "With contract"
	label values contract lblcontract


** HEALTH INSURANCE
	gen byte healthins=.
	replace healthins=. if lstatus!=1
	label var healthins "Health insurance"
	la de lblhealthins 0 "Without health insurance" 1 "With health insurance"
	label values healthins lblhealthins


** SOCIAL SECURITY
	gen byte socialsec=.
	replace socialsec=. if lstatus!=1
	label var socialsec "Social security"
	la de lblsocialsec 1 "With" 0 "Without"
	label values socialsec lblsocialsec


** UNION MEMBERSHIP
	gen byte union=.
	replace union=. if lstatus!=1
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

	
	saveold "`output'\Data\Harmonized\PAK_2010_PSLM_v01_M_v01_A_SARMD_IND.dta", replace version(13)
	saveold "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\__REGIONAL\Individual Files\PAK_2010_PSLM_v01_M_v01_A_SARMD_IND.dta", replace version(13)


	log close


















******************************  END OF DO-FILE  *****************************************************/
