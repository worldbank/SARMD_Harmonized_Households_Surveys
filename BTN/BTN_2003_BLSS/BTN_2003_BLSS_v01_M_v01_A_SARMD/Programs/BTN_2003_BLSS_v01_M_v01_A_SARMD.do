/*****************************************************************************************************
******************************************************************************************************
**                                                                                                  **
**                       INTERNATIONAL INCOME DISTRIBUTION DATABASE (I2D2)                          **
**                                                                                                  **
** COUNTRY			BHUTAN
** COUNTRY ISO CODE	BTN
** YEAR				2003
** SURVEY NAME		BHUTAN LIVING STANDARD SURVEY (BLSS) 2003
** SURVEY AGENCY	NATIONAL STATISTICAL BUREAU
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
	set mem 500m

** DIRECTORY
	local input "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\BTN\BTN_2003_BLSS\BTN_2003_BLSS_v01_M"
	local output "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\BTN\BTN_2003_BLSS\BTN_2003_BLSS_v01_M_v01_A_SARMD"

** LOG FILE
	log using "`input'\Doc\Technical\BTN_2003_BLSS.log",replace

/*****************************************************************************************************
*                                                                                                    *
                                   * ASSEMBLE DATABASE
*                                                                                                    *
*****************************************************************************************************/


** DATABASE ASSEMBLENT
	use "`input'\Data\Stata\DataOrig.dta", clear

	
/*****************************************************************************************************
*                                                                                                    *
                                   * STANDARD SURVEY MODULE
*                                                                                                    *
*****************************************************************************************************/


** COUNTRY
	gen countrycode="BTN"
	label var countrycode "Country code"


** YEAR
	gen year=2003
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
	destring houseid_str , generate(idh)
	format idh %10.0f
	tostring idh, replace
	label var idh "Household id"

	sort houseid_str
	merge m:1 idh using "`input'\Data\Stata\pcc.dta"


** INDIVIDUAL IDENTIFICATION NUMBER

	gen str2 ind_str= string(idno,"%02.0f") 
	gen str15 indiv=houseid_str+ind_str
	ren indiv idp
	isid idp
	label var idp "Individual id"


** HOUSEHOLD WEIGHTS
	gen wgt=weight
	label var wgt "Household sampling weight"


** STRATA
	gen strata=stratum
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
	gen urban=stratum
	recode urban (2=0)
	label var urban "Urban/Rural"
	la de lblurban 1 "Urban" 0 "Rural"
	label values urban lblurban


**REGIONAL AREAS

** REGIONAL AREA 1 DIGIT ADMN LEVEL
	gen area01=dzongkha
	recode area01 (11 12 13 14  41 = 1) (15 16 17 44 43 = 2) (31/36=3) (21 22 23 42 = 4), gen(subnatid1)
	label var subnatid1 "Region at 1 digit (ADMN1)"
	la de lblsubnatid1 1 "Western" 2 "Central" 3 "Eastern"  4 "Southern"
	label values subnatid1 lblsubnatid1

** REGIONAL AREA 2 DIGIT ADMN LEVEL
	gen subnatid2=dzongkha
	label var subnatid2 "Region at 1 digit (ADMN1)"
	la de lblsubnatid2 11"Chukha" 12"Ha" 13"Paro" 14" Thimphu" 15"Punakha" 16"Gasa" ///
	17"Wangdi" 21"Bumthang" 22"Trongsa" 23 "Zhemgang" 31"Lhuntshi" 32"Mongar" ///
	33"Trashigang" 34"Yangtse" 35"Pemagatshel" 36"Samdrup Jongkhar" 41"Samtse" ///
	42"Sarpang" 43"Tsirang" 44"Dagana"
	label values subnatid2 lblsubnatid2

	
** REGIONAL AREA 3 DIGIT ADMN LEVEL
	gen byte subnatid3=.
	label var subnatid3 "Region at 3 digit (ADMN3)"
	label values subnatid3 lblsubnatid3

	
** HOUSE OWNERSHIP
	gen ownhouse=b1_q2
	label var ownhouse "House ownership"
	recode ownhouse (2=0)
	la de lblownhouse 0 "No" 1 "Yes"
	label values ownhouse lblownhouse


** WATER PUBLIC CONNECTION
	gen water=b1_q12==1
	label var water "Water main source"
	la de lblwater 0 "No" 1 "Yes"
	label values water lblwater


** ELECTRICITY PUBLIC CONNECTION
	gen electricity=b1_q18==2
	label var electricity "Electricity main source"
	la de lblelectricity 0 "No" 1 "Yes"
	label values electricity lblelectricity


** TOILET PUBLIC CONNECTION
	gen toilet=b1_q16==2
	label var toilet "Toilet facility"
	la de lbltoilet 0 "No" 1 "Yes"
	label values toilet lbltoilet


** LAND PHONE
	gen landphone=b1_q11==1
	label var landphone "Phone availability"
	la de lbllandphone 0 "No" 1 "Yes"
	label values landphone lbllandphone


** CEL PHONE
	gen cellphone=b3_q1mob ==1|b3_q1mob ==2
	label var cellphone "Cell phone"
	la de lblcellphone 0 "No" 1 "Yes"
	label values cellphone lblcellphone


** COMPUTER
	gen computer=1 if b3_q1com ==1|b3_q1com ==2
	replace computer=0 if b3_q1com==3
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


** HOUSEHOLD SIZE
	gen aux=1 if b21_q2<12 & b21_q2!=.
	bys idh: egen hhsize_i2d2=count (aux)
	label var hhsize "Household size (National)"
	ren hh_size hsize
	label var hsize "Household size"

** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
	gen relationharm=b21_q2
	recode relationharm (5/11=5) (12/13=6) 

	replace ownhouse=. if relationharm==6

	label var relationharm "Relationship to the head of household"
	la de lblrelationharm  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Non-relatives"
	label values relationharm  lblrelationharm

	gen byte relationcs=b21_q2
	la var relationcs "Relationship to the head of household country/region specific"
	label define lblrelationcs 1 "Self(head" 2 "Wife/Husband" 3 "Son/daughter" 4 "Father/Mother" 5 "Sister/Brother" 6 "Grandchild" 7 "Niece/nephew" 8 "Son-in-law/daughter-in-law" 9 "Brother-in-law/sister-in-law" 10 "Father-in-law/mother-in-law" 11 "Other family relative" 12 "Live-in-servant" 13 "Other-non-relative"
	label values relationcs lblrelationcs


** GENDER
	gen male=b21_q1
	recode male (2=0)
	label var male "Sex of household member"
	la de lblmale 1 "Male" 0 "Female"
	label values male lblmale


** AGE
	gen age=b21_q3ag
	replace age=98 if age>=98
	label var age "Individual age"


** SOCIAL GROUP
	gen soc=b21_q5
	label var soc "Social group"
	la de lblsoc 1 "Bhutanese" 2 "Other"
	label values soc lblsoc

** MARITAL STATUS
	gen marital=b21_q4
	recode marital (3 4=4) (2=2) (5=5)
	label var marital "Marital status"
	la de lblmarital 1 "Married" 2 "Never Married" 3 "Living Together" 4 "Divorced/separated" 5 "Widowed"
	label values marital lblmarital


/*****************************************************************************************************
*                                                                                                    *
                                   EDUCATION MODULE
*                                                                                                    *
*****************************************************************************************************/


** EDUCATION MODULE AGE
	gen ed_mod_age=3
	label var ed_mod_age "Education module application age"


** EVER ATTENDED SCHOOL
	gen everattend=b22_q8
	recode everattend (2=0)
	label var everattend "Ever attended school"
	la de lbleverattend 0 "No" 1 "Yes"
	label values everattend lbleverattend


** CURRENTLY AT SCHOOL
	gen atschool=b22_q9
	recode atschool (2=0)
	label var atschool "Attending school"
	la de lblatschool 0 "No" 1 "Yes"
	label values atschool  lblatschool


** CAN READ AND WRITE
	gen literacy=.
	replace literacy=0 if b22_q7dz==2 & b22_q7en==2 & b22_q7ot==2 & b22_q7lo==2
	replace literacy=1 if b22_q7dz==1 | b22_q7en==1 | b22_q7ot==1 | b22_q7lo==1
	label var literacy "Can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy


** YEARS OF EDUCATION COMPLETED
	gen educy1=.
	replace educy1=0 if  b22_q10==00 |  b22_q10==01 | b22_q16==00
	replace educy1=1 if  b22_q10==02  | b22_q16==01
	replace educy1=2 if  b22_q10==03 | b22_q16==02
	replace educy1=3 if  b22_q10==04 | b22_q16==03
	replace educy1=4 if  b22_q10==05 | b22_q16==04
	replace educy1=5 if  b22_q10==06 | b22_q16==05
	replace educy1=6 if  b22_q10==07 | b22_q16==06
	replace educy1=7 if  b22_q10==08 | b22_q16==07
	replace educy1=8 if  b22_q10==09 | b22_q16==08
	replace educy1=9 if  b22_q10==10 | b22_q16==09
	replace educy1=10 if  b22_q10==11 | b22_q16==010
	replace educy1=11 if  b22_q10==12 | b22_q16==011
	replace educy1=12 if  b22_q10==13 | b22_q16==012
	replace educy1=13 if  b22_q10==14 | b22_q16==013
	replace educy1=14 if  b22_q10==15 | b22_q16==014
	replace educy1=15 if  b22_q16==015
	replace educy1 = 0 if b22_q8==2 & mi(educy1)

	gen CONEDYEARS=.
	replace CONEDYEARS=educy1

	local i = 1
	while `i'<25 {
	replace CONEDYEARS = `i' if age == (`i'+4) & educy1 > `i' & educy1~=.
	local i = `i'+1
	}
	replace CONEDYEARS = 0 if b22_q8==2 & mi(CONEDYEARS)
	ren CONEDYEARS educy
	label var educy1 "Years of education"

	replace educy=. if educy>age & educy!=. & age!=.

** EDUCATIONAL LEVEL 7 CATEGORIES
	gen byte educat7=.
	replace educat7=1 if educy==0
	replace educat7=2 if educy>0 & educy<8
	replace educat7=3 if educy==8
	replace educat7=4 if educy>8 & educy<12
	replace educat7=5 if educy>=12 & educy<=15
	replace educat7=7 if b22_q17>=1 & b22_q17<5
	replace educat7=6 if b22_q17>=2 & b22_q17<5
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
	
	/*
	gen EDLEVEL=.
	replace EDLEVEL=0 if b22_q8==2
	replace EDLEVEL=1 if  (b22_q10==0 |  b22_q10==1 |  b22_q10==2 |  b22_q10==3 |  b22_q10==4 |  b22_q10==5 |  b22_q10==6) & b22_q9==1
	replace EDLEVEL=1 if  (b22_q16==0 |  b22_q16==1 |  b22_q16==2 |  b22_q16==3 |  b22_q16==4 |  b22_q16==5)  & b22_q9==2
	replace EDLEVEL=2 if  (b22_q10==7 |  b22_q10==8 |  b22_q10==9 |  b22_q10==10)  & b22_q9==1
	replace EDLEVEL=2 if  (b22_q16==6 | b22_q16==7 |  b22_q16==8 |  b22_q16==9)   & b22_q9==2
	replace EDLEVEL=3 if  (b22_q10==11 |  b22_q10==12) & b22_q9==1
	replace EDLEVEL=3 if  (b22_q16==10 | b22_q16==11)  & b22_q9==2
	replace EDLEVEL=4 if  (b22_q10==13 |  b22_q10==14 |  b22_q10==15)    & b22_q9==1
	replace EDLEVEL=4 if  (b22_q16==12 | b22_q16==13 |  b22_q16==14 |  b22_q16==15)     & b22_q9==2

	gen CONEDLEVEL=.
	replace CONEDLEVEL=EDLEVEL
	replace CONEDLEVEL = 1 if educy > 0 & educy <=5
	replace CONEDLEVEL = 2 if educy >=6 & educy <10
	replace CONEDLEVEL = 3 if educy >=10 & educy <12
	replace CONEDLEVEL = 4 if educy >=12 & educy <.
	recode CONEDLEVEL (0=1) (1 =2) (2 3=3) (4=4),gen(edulevel2)
	*/

/*****************************************************************************************************
*                                                                                                    *
                                   LABOR MODULE
*                                                                                                    *
*****************************************************************************************************/


** LABOR MODULE AGE
	gen lb_mod_age=15
	label var lb_mod_age "Labor module application age"


** LABOR STATUS

	gen lstatus = .  
	replace lstatus = 1 if inlist(1,  b24_q33w, b24_q34w, b24_q35w)
	replace lstatus = 2 if  b24_q36==1 & mi(lstatus)
	replace lstatus = 3 if b24_q37!=. & lstatus!=1
	replace lstatus = . if age<15 

	label var lstatus "Labor status"
	label define lstatus 1"Employed" 2"Unemployed" 3"Not-in-labor-force"
	label values lstatus lstatus


** EMPLOYMENT STATUS
	gen empstat=b24_q38
	recode empstat 2 6=1 5=2 3=4 7=5 4=3
	label var empstat "Employment status"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other"
	label values empstat lblempstat
	replace empstat =. if lstatus~=1


** NUMBER OF ADDITIONAL JOBS
	gen njobs=.
	label var njobs "Number of additional jobs"


** SECTOR OF ACTIVITY: PUBLIC - PRIVATE
	gen ocusec=b24_q41
	recode ocusec (1 2 =1) ( 3/8 10 =3)  (9 11=.)
	recode ocusec (3=2)
	label var ocusec "Sector of activity"
	la de lblocusec 1 "Public, state owned, government, army, NGO" 2 "Private"
	label values ocusec lblocusec
	replace ocusec=. if lstatus!=1 | age<15


** REASONS NOT IN THE LABOR FORCE
	gen nlfreason=b24_q37
	recode nlfreason (5=1) (6=2) (7 8=3) (9=4) (1/4  10/11=5)
	 replace nlfreason=. if lstatus~=3
	label var nlfreason "Reason not in the labor force"
	la de lblnlfreason 1 "Student" 2 "Housewife" 3 "Retired" 4 "Disable" 5 "Other"
	label values nlfreason lblnlfreason


** UNEMPLOYMENT DURATION: MONTHS LOOKING FOR A JOB
	gen unempldur_l=.
	label var unempldur_l "Unemployment duration (months) lower bracket"

	gen unempldur_u=.
	label var unempldur_u "Unemployment duration (months) upper bracket"


** INDUSTRY CLASSIFICATION
	gen industry=b24_q40
	recode industry (7=6) (8=7) (9 10=8) (11=9) (12/14=10)
	replace  industry =. if age<15 | industry==11
	label var industry "1 digit industry classification"
	la de lblindustry 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Comnunications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industry lblindustry


** OCCUPATION CLASSIFICATION
	gen occup=int(b24_q39/100)
	recode occup (0=10)
	recode occup(9=99) if b24_q39==999
	label var occup "1 digit occupational classification"
	la de occup 1 "Senior officials" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup occup
	replace occup=. if lstatus!=1 | age<15


** FIRM SIZE
	gen firmsize_l=.
	label var firmsize_l "Firm size (lower bracket)"

	gen firmsize_u=.
	label var firmsize_u "Firm size (upper bracket)"


** HOURS WORKED LAST WEEK
	gen whours=b24_q47m
	*infeasible weekly working hours reported - to be recoded to missing
	*histogram whours if whours<100
	replace whours=. if whours>98
	label var whours "Hours of work in last week"
	replace whours=. if lstatus!=1 | age<15


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


** HEALTH INSURANCE
	gen healthins=.
	label var healthins "Health insurance"
	la de lblhealthins 0 "Without health insurance" 1 "With health insurance"
	label values healthins lblhealthins


** SOCIAL SECURITY
	gen socialsec=.
	label var socialsec "Social security"
	la de lblsocialsec 1 "With" 0 "Without"
	label values socialsec lblsocialsec


** UNION MEMBERSHIP
	gen union=.
	label var union "Union membership"
	la de lblunion 0 "No member" 1 "Member"
	label values union lblunion


/*****************************************************************************************************
*                                                                                                    *
                                   WELFARE MODULE
*                                                                                                    *
*****************************************************************************************************/


** SPATIAL DEFLATOR
	gen spdef=reg_defl
	la var spdef "Spatial deflator"


** WELFARE
	gen welfare=pcc_t_mo
	la var welfare "Welfare aggregate"

	gen welfarenom=pcc_t_mo
	la var welfarenom "Welfare aggregate in nominal terms"

	gen welfaredef=pcc_t_mo*reg_defl
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
	ren povline_month pline_nat
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

	saveold "`output'\Data\Harmonized\BTN_2003_BLSS_v01_M_v01_A_SARMD_IND.dta", replace version(13)
	saveold "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\__REGIONAL\Individual Files\BTN_2003_BLSS_v01_M_v01_A_SARMD_IND.dta", replace version(13)


	log close




******************************  END OF DO-FILE  *****************************************************/
