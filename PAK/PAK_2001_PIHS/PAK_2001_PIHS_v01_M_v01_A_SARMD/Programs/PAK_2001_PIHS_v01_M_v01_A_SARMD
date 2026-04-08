/*****************************************************************************************************
******************************************************************************************************
**                                                                                                  **
**                                   SOUTH ASIA MICRO DATABASE                                      **
**                                                                                                  **
** COUNTRY			PAKISTAN
** COUNTRY ISO CODE	PAK
** YEAR				2001
** SURVEY NAME		PAKISTAN INTEGRATED HOUSEHOLD SURVEY (PIHS)
** SURVEY AGENCY	PAKISTAN FEDERAL BUREAU OF STATISTICS
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
	local input "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\PAK\PAK_2001_PIHS\PAK_2001_PIHS_v01_M"
	local output "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\PAK\PAK_2001_PIHS\PAK_2001_PIHS_v01_M_v01_A_SARMD"

** LOG FILE
	log using "`output'\Doc\PAK_2001_PIHS_v01_M_v01_A_SARMD.log",replace

/*****************************************************************************************************
*                                                                                                    *
                                   * ASSEMBLE DATABASE
*                                                                                                    *
*****************************************************************************************************/


** DATABASE ASSEMBLENT
	use "`input'\Data\Stata\Consumption Master File.dta"
	keep if year==2001
	keep year hhcode nomexpend eqadultM peaexpM psupind pline texpend region weight poor popwt  hhsize hhsizeM

*	tempfile comp
*	save `comp', replace


	merge m:m hhcode using "`input'\Data\Stata\plist.dta"
	order hhcode idc
	drop _merge

	merge m:m hhcode using "`input'\Data\Stata\educate.dta"
	order hhcode idc
	isid hhcode idc
	drop _merge
	

forval i=1/3{
		merge m:m hhcode idc using "`input'\Data\Stata\educat`i'.dta"
		isid hhcode idc
		drop _merge
}	
		merge m:m hhcode idc using "`input'\Data\Stata\income1.dta"
		isid hhcode idc
		drop _merge
		
		merge m:1 hhcode using "`input'\Data\Stata\intdate.dta"
		drop if _merge==2
		drop _merge
		isid hhcode idc

		merge m:1 hhcode using "`input'\Data\Stata\housing.dta"
		drop _merge
		isid hhcode idc

	
/*
CHECK ASSEMBLEMENT because this database contains more households than nobuos dataset.

	use "`input'\Data\Stata\PAK_PSLM_2001.dta"
	merge m:1 hhcode using `comp'
	tab _merge
	drop _merge
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
	label var year "Year of survey"


** INTERVIEW YEAR
	gen int_year=2000+fyear1
	label var int_year "Year of the interview"

	
** INTERVIEW MONTH
	gen int_month=fmon1
	la de lblint_month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
	label value int_month lblint_month
	label var int_month "Month of the interview"
	

** HOUSEHOLD IDENTIFICATION NUMBER
	gen double idh= hhcode
	label var idh "Household id"


** INDIVIDUAL IDENTIFICATION NUMBER
	gen double idp_= idh*100+idc
	gen idp=string(idp_,"%14.0g")
	isid idp
	label var idp "Individual id"
	tostring idh, replace

	
** HOUSEHOLD WEIGHTS
	gen double wgt=weight
	label var wgt "Household sampling weight"


** STRATA

	* The four digit code in major uran areas includes economic stratification.  
	* This needs to be removed from the geographic coding
	* such that only the major urban areas are represented.  
	* Administrative districts remain in other urban and rural as geographic codes.
	* The stratum varies from geo_2 only in that includes the economic stratification done 
	* in the major urban areas (considered as sub strata).

	gen ori_hid=string(hhcode,"%15.0g")
	gen geo_2=real(substr(ori_hid,1,4))
	replace geo_2=real(substr(ori_hid,1,3)) if substr(ori_hid,2,1)=="1" & substr(ori_hid,3,1)~="0"
	gen strata=real(substr(ori_hid,1,4))
	drop ori_hid
	label var strata "Strata"

** PSU
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
	gen byte urban=region
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
	replace ownhouse=1 if s5q02==1 | s5q02==2
	replace ownhouse=0 if s5q02==3 |s5q02==4 |s5q02==5
	label var ownhouse "House ownership"
	la de lblownhouse 0 "No" 1 "Yes"
	label values ownhouse lblownhouse


** WATER PUBLIC CONNECTION
	gen byte water=.
	replace water=1 if s5q05==1
	replace water=0 if inlist( s5q05,2,3,4,5,6,7,8,9)
	label var water "Water main source"
	la de lblwater 0 "No" 1 "Yes"
	label values water lblwater


** ELECTRICITY PUBLIC CONNECTION
	gen byte electricity=.
	replace electricity=1 if s5q04a==1 | s5q04a==2
	replace electricity=0 if s5q04a==3
	label var electricity "Electricity main source"
	la de lblelectricity 0 "No" 1 "Yes"
	label values electricity lblelectricity

** TOILET PUBLIC CONNECTION
	gen byte toilet=s5q14
	recode toilet (1=1)(2=0)(3=0)(4=0)(5=0)(6=0)
	label var toilet "Toilet facility"
	la de lbltoilet 0 "No" 1 "Yes"
	label values toilet lbltoilet


** LAND PHONE
	gen byte landphone=s5q04c
	recode landphone (1 2=1)(3=0)
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
	gen byte hsize=hhsizeM
	label var hsize "Household size"


** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
	gen byte relationharm=s1aq02
	recode relationharm (4 6 7 8 9 10 =5) (5=4) (11 12 = 6)
	label var relationharm "Relationship to the head of household"
	la de lblrelationharm  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Non-relatives"
	label values relationharm  lblrelationharm

	gen byte relationcs=s1aq02
	la var relationcs "Relationship to the head of household country/region specific"
	label define lblrelationcs 1 "Head" 2 "Spouse" 3 "Son/Daughter" 4 "Grandchild" 5 "Father/Mother" 6 "Brother/Sister" 7 "Nephew/Niece" 8 "Son/Daughter-in-law" 9 "Brother/sister-in-law" 10 "Father/Mother-in-law" 11 "Servant/their relatives" 12 "Other"
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
	*label var soc "Social group"
	*la de lblsoc 1 ""
	*label values soc lblsoc


** MARITAL STATUS
	gen byte marital=mstatus
	recode marital ( 2 5 =1) (1=2) (4=4) (3=5)
	label var marital "Marital status"
	la de lblmarital 1 "Married" 2 "Never Married" 3 "Living Together" 4 "Divorced/separated" 5 "Widowed"
	label values marital lblmarital


/*****************************************************************************************************
*                                                                                                    *
                                   EDUCATION MODULE
*                                                                                                    *
*****************************************************************************************************/


** EDUCATION MODULE AGE
	gen byte ed_mod_age=10
	label var ed_mod_age "Education module application age"


** CURRENTLY AT SCHOOL
	gen byte atschool=s2bq01
	recode atschool (3=1) (2 1=0)
	replace atschool=. if age<ed_mod_age
	label var atschool "Attending school"
	la de lblatschool 0 "No" 1 "Yes"
	label values atschool  lblatschool


** CAN READ AND WRITE
	gen byte literacy=1 if s2aq21==1 & s2aq22==1
	replace literacy=0 if s2aq21==2 | s2aq22==2
	replace literacy=. if age<ed_mod_age
	label var literacy "Can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy

** YEARS OF EDUCATION COMPLETED
	recode s2bq06 (17=13) (14=14) (18=16) (19=17) (20=16) (16=16) (22=19) (23=.), gen(educy1)
	recode s2bq18 (17=13) (14=14) (18=16) (19=17) (20=16) (16=16) (22=19) (23=.), gen(educy2)

/*

s2bq06:
	0	less than class 1
	1	class 1
	2	class 2
	3	class 3
	4	class 4
	5	class 5
	6	class 6
	7	class 7
	8	class 8
	9	class 9
	10	class 10
	11	class 11
	12	class 12
	13	class 13
	14	b.a/b.sc.
	15	class 15
	16	post graduate (m.a/m.sc.)
	17	diploma
	18	degree in engineering
	19	degree in medicine
	20	degree in agriculture
	21	degree in law
	22	m. phil, ph.d
	23	other

*/

/*
CHECK!! Source: "http://www-db.in.tum.de/teaching/ws1112/hsufg/Taxila/Site/formal.html"
*/
	gen byte 	educy=educy1
	replace 	educy=educy2 if educy==.
	replace 	educy=0 if s2bq01==1
	replace educy=. if age<ed_mod_age & age!=.
	label var educy "Years of education"
	replace educy=. if educy>age & age!=. & educy!=.


** EDUCATIONAL LEVEL 7 CATEGORIES
	gen byte educat7=1 if educy==0
	replace educat7=2 if educy >0 & educy<8
	replace educat7=3 if educy==8
	replace educat7=4 if educy>8 &  educy<12
	replace educat7=5 if educy==12
	replace educat7=7 if educy>12 & educy<=22
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
	gen byte everattend=.
	replace everattend=0 if s2bq01==1
	replace everattend=1 if s2bq01==2 | s2bq01==3 | atschool==1
	replace everattend=. if age<ed_mod_age
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
	replace lstatus=1 if s1bq01==1
	replace lstatus=1 if s1bq03==1
	replace lstatus=2 if s1bq01==2 & s1bq03==2
	replace lstatus=3 if s1bq01==2 & s1bq03==3
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus


** EMPLOYMENT STATUS
	gen byte empstat=s1bq06
	recode empstat (4=1) (5=2) (1 2=3) (3 6 7 8 9=4) 
	label var empstat "Employment status"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed"
	label values empstat lblempstat


** NUMBER OF ADDITIONAL JOBS
	gen byte njobs=.
	label var njobs "Number of additional jobs"


** SECTOR OF ACTIVITY: PUBLIC - PRIVATE
	gen byte ocusec=.
	label var ocusec "Sector of activity"
	la de lblocusec 1 "Public, state owned, government, army" 2 "NGO" 3 "Private"
	label values ocusec lblocusec


** REASONS NOT IN THE LABOR FORCE
	gen byte nlfreason=.
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
	replace industry=1 if s1bq05>=11 & s1bq05<=13
	replace industry=2 if s1bq05>=21 & s1bq05<=29
	replace industry=3 if s1bq05>=31 & s1bq05<=39
	replace industry=4 if s1bq05>=41 & s1bq05<=42
	replace industry=5 if s1bq05>=51 & s1bq05<=59
	replace industry=6 if s1bq05>=61 & s1bq05<=63
	replace industry=7 if s1bq05>=71 & s1bq05<=72
	replace industry=8 if s1bq05>=81 & s1bq05<=83
	replace industry=9 if s1bq05==91
	replace industry=10 if s1bq05>=92 & s1bq05<=96
	replace industry=10 if s1bq05==0
	label var industry "1 digit industry classification"
	la de lblindustry 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Comnunications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industry lblindustry


** OCCUPATION CLASSIFICATION
	gen byte occup=.
	replace occup=10 if s1bq04==1
	replace occup=1 if s1bq04>=11 & s1bq04<=13
	replace occup=2 if s1bq04>=21 & s1bq04<=24
	replace occup=3 if s1bq04>=31 & s1bq04<=34
	replace occup=4 if s1bq04>=41 & s1bq04<=42
	replace occup=5 if s1bq04>=51 & s1bq04<=52
	replace occup=6 if s1bq04>=61 & s1bq04<=62
	replace occup=7 if s1bq04>=71 & s1bq04<=74
	replace occup=8 if s1bq04>=81 & s1bq04<=83
	replace occup=9 if s1bq04>=91 & s1bq04<=93
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
	replace wage=s1bq08 if s1bq08!=.
	replace wage=s1bq10 if s1bq10!=.
	replace wage=. if lstatus!=1
	label var wage "Last wage payment"


** WAGES TIME UNIT
	gen byte unitwage=.
	replace unitwage=5 if s1bq08!=.
	replace unitwage=8 if s1bq10!=.

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

	
	saveold "`output'\Data\Harmonized\PAK_2001_PIHS_v01_M_v01_A_SARMD_IND.dta", replace version(13)
	saveold "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\__REGIONAL\Individual Files\PAK_2001_PIHS_v01_M_v01_A_SARMD_IND.dta", replace version(13)

	
	log close




******************************  END OF DO-FILE  *****************************************************/
