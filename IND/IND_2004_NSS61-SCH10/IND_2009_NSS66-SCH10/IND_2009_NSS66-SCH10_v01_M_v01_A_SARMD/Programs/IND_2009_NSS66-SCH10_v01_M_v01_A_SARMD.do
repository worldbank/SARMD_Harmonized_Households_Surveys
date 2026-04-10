/*****************************************************************************************************
******************************************************************************************************
**                                                                                                  **
**                                  SOUTH ASIA MICRO DATABASE                                       **
**                                                                                                  **
** COUNTRY	India
** COUNTRY ISO CODE	IND
** YEAR	2009
** SURVEY NAME	SOCIO-ECONOMIC SURVEY  SIXTY-SIXTH ROUND: JULY 2009 – JUNE 2010
*	HOUSEHOLD SCHEDULE 10 : EMPLOYMENT AND UNEMPLOYMENT
** SURVEY AGENCY	GOVERNMENT OF INDIA NATIONAL SAMPLE SURVEY ORGANISATION
** RESPONSIBLE	Triana Yentzen
** MODIFIED BY Yurani Arias Granada (05/22/2016)
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
	local input "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\IND\IND_2009_NSS-SCH10\IND_2009_NSS-SCH10_v01_M"
	local output "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\IND\IND_2009_NSS-SCH10\IND_2009_NSS-SCH10_v01_M_v01_A_SARMD"

** LOG FILE
	*log using "`output'\Doc\Technical\IND_2009_NSS-SCH10_v01_M_v01_A_SARMD.log",replace


/*****************************************************************************************************
*                                                                                                    *
                                   * ASSEMBLE DATABASE
*                                                                                                    *
*****************************************************************************************************/


** DATABASE ASSEMBLENT
	use "`input'\Data\stata\India_NSS_2009_10_DataOrig.dta ", clear

/*****************************************************************************************************
*                                                                                                    *
                                   HOUSEHOLD CHARACTERISTICS MODULE
*                                                                                                    *
*****************************************************************************************************/


** COUNTRY
	gen str4 countrycode="IND"
	label var ccode "Country code"

** YEAR
	gen int year=2009
	label var year "Year of survey"

** SURVEY NAME 
gen str survey="NSS-SCH10"
	label var survey "Survey Acronym"

** INTERVIEW YEAR
gen byte int_year=.
	label var int_year "Year of the interview"
	
	
** INTERVIEW MONTH
	gen byte month=.
	la de lblmonth 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
	label value month lblmonth
	label var month "Month of the interview"


** HOUSEHOLD IDENTIFICATION NUMBER
	egen idh = concat(fsu sub_block ss_stratum hhnumber)
	label var idh "Household id"


** INDIVIDUAL IDENTIFICATION NUMBER
	egen idp = concat(idh  person_no)
	label var idp "Individual id"
	isid idp


** HOUSEHOLD WEIGHTS
	gen wgt=mlt/100 if nss==nsc
	replace wgt= mlt/200 if nss!=nsc
	label var wgt "Household sampling weight"


** STRATA
	gen strata=stratum
	label var strata "Strata"


** PSU
	gen psu=fsu
	destring psu , replace
	label var psu "Primary sampling units"


** MASTER VERSION
	gen vermast="01"
	label var vermast "Master Version"

** ALTERATION VERSION
	gen veralt="02"
	label var veralt "Alteration Version"


/*****************************************************************************************************
*                                                                                                    *
                                   HOUSEHOLD CHARACTERISTICS MODULE
*                                                                                                    *
*****************************************************************************************************/


** LOCATION (URBAN/RURAL)
	gen urban=.
	replace urban=1 if sector==2
	replace urban=0 if sector==1
	label var urban "Urban/Rural"
	la de lblurb 1 "Urban" 0 "Rural"
	label values urban lblurban


** REGIONAL AREA 1 DIGIT ADMN LEVEL
   gen REG=int(state_region/10)
   gen state=REG
   recode state (1 2 3 4 6 8 = 1) (5 7 9 10 23 = 2) (12/18 = 3) (11 19 20 21 22 35 = 4) ( 24 25 26 27 30 = 5) (28 29 31 32 33 34 = 6), gen(subnatid1)
   label define lblsubnatid1 1 "Northern" 2 "North-Central" 3 "North-Eastern" 4 "Eastern" 5 "Western" 6 "Southern"
   label var subnatid1 "Region at 1 digit (ADMN1)"
   label values subnatid1 lblsubnatid1
	
	
** REGIONAL AREA 2 DIGIT ADMN LEVEL
	label define REG  28 "Andhra Pradesh"  18 "Assam"  10 "Bihar" 24 "Gujarat" 06 "Haryana"  02 "HimachalPradesh" ///
	01 "Jammu & Kashmir" 29"Karnataka" 32 "Kerala" 23 "Madhya Pradesh" 27  "Maharashtra" ///  
	14 "Manipur"   17 "Meghalaya"  13 "Nagaland"  21 "Orissa"  03 "Punjab" 08 "Rajasthan" 11 "Sikkim" ///
	33 "Tamil Nadu"  16 "Tripura"  09 "Uttar Pradesh"  19 "West Bengal" 35 "A & N Islands" ///
	12 "Arunachal Pradesh"  4 "Chandigarh" 26 "Dadra & Nagar Haveli" 7 "Delhi"  30 "Goa" ///
	31"Lakshdweep" 15 "Mizoram"  34 "Pondicherry"  25 "Daman & Diu" 22"Chhattisgarh" 20"Jharkhand" 5"Uttaranchal"
	gen subnatid2=REG
	label values subnatid2 REG
	label var subnatid2 "Region at 2 digit(ADMN2)"


** REGIONAL AREA 3 DIGIT ADMN LEVEL
	gen byte subnatid3=.
	label var subnatid3 "Region at 3 digit (ADMN3)"
	label values subnatid3 lblsubnatid3


** HOUSE OWNERSHIP
	gen ownhouse=.
	label var ownhouse "House ownership"
	la de lblownhouse 0 "No" 1 "Yes"


** WATER PUBLIC CONNECTION
	label values ownhouse lblownhouse
	gen water=.
	label var water "Water main source"
	la de lblwater 0 "No" 1 "Yes"
	label values water lblwater


** ELECTRICITY PUBLIC CONNECTION
	gen electricity=.
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
	gen one=1
	egen two=group(idp one)
	bys idh: egen hhsize= count(two) if rel_head>=1 & rel_head<=8
	label var hhsize "Household size"
	drop one two


** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
	bys idh: gen one=1 if  rel_head==1 
	bys idh: egen temp=count(one) 
	keep if temp==1

	gen relationharm= rel_head
	recode relationharm (3 5 = 3) (7=4) (4 6 8 = 5) (9=6)
	label var relationharm "Relationship to the head of household"
	la de lblrelationharm  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Non-relatives"
	label values relationharm lblrelationharm
	drop if relationharm==.
	
	
** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
	gen byte relationcs=rel_head
	la var relationcs "Relationship to the head of household country/region specific"
	label define lblrelationcs 1 "Head" 2 "Spouse of head" 3 "married child" 4 "spouse of married child" 5 "unmarried child" 6 "grandchild" 7 "father/mother/father-in-law/mother-in-law" 8 "brother/sister/brother-in-law/sister-in-law/other relations" 9 "servant/employee/other non-relative"
	label values relationcs lblrelationcs


** GENDER
	gen male= sex
	recode male (2=0)
	label var male "Sex of household member"
	la de lblmale 1 "Male" 0 "Female"
	label values male lblmale
	
	
** AGE
	label var age "Individual age"
	replace age=98 if age>=98


** SOCIAL GROUP

/*
The caste variable exist too, named "c3_6"
*/
	gen soc=c3_5
* c3_6
	label var soc "Social group"
	label define soc 1 "Hinduism" 2 "Islam" 3 "Christianity" 4 "Sikhism" 5 "Jainism" 6 "Buddhism" 7 "Zoroastrianism" 9 "Others"
	label values soc soc


** MARITAL STATUS
	gen marital=mar_stat
	recode marital (1=2) (2=1) (3=5)
	replace marital=. if mar_stat==0
	label var marital "Marital status"
	la de lblmarital 1 "Married" 2 "Never Married" 3 "Living together" 4 "Divorced/Separated" 5 "Widowed"
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
	gen atschool=1  if c4_9>=21 & c4_9!=.
	replace atschool=0 if c4_9<21 | c4_9==.
	label var atschool "Attending school"
	la de lblatschool 0 "No" 1 "Yes"
	label values atschool  lblatschool


** CAN READ AND WRITE
	recode c4_7 (2/13 = 1) (1= 0), gen(literacy)
	label var literacy "Can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy


** YEARS OF EDUCATION COMPLETED
	recode c4_7 ( 1/4= 0) (5 = 2) (6=5) (7=8) (8 10 =10) (11=12) (12=15) (13=17), gen(educy)
	replace educy = 16 if  educy==15 & c4_8==2 
	label var educy "Years of education"


** EDUCATION LEVEL 7 CATEGORIES
	gen educat7=.
	replace educat7=1 if c4_7==1
	replace educat7=2 if c4_7==5
	replace educat7=3 if c4_7==6
	replace educat7=4 if c4_7==7|c4_7==8
	replace educat7=5 if c4_7==10
	replace educat7=7 if c4_7>=11 & c4_7!=.
	replace educat7=8 if c4_7==2 |c4_7==3|c4_7==4
	label var educat7 "Level of education 1"
	la de lbleducat7 1 "No education" 2 "Primary incomplete" 3 "Primary complete" 4 "Secondary incomplete" 5 "Secondary complete" 6 "Higher than secondary but not university" 7 "University incomplete or complete" 8 "Other" 9 "Not classified"
	label values educat7 lbleducat7

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
	** EVER ATTENDED SCHOOL
*<_everattend_>
	recode c4_7 (1 2 3 4 = 0) (5 6 7 8 9 10 11 12 13=1), gen (everattend)
	label var everattend "Ever attended school"
	la de lbleverattend 0 "No" 1 "Yes"
	label values everattend lbleverattend

	replace educy=0 if everattend==0 
	replace educat7=1 if everattend==0 
	replace educat5=1 if everattend==0 
	replace educat4=1 if everattend==0 

	local ed_var "everattend atschool literacy educy educat7 educat5 educat4"
	foreach v in `ed_var'{
	replace `v'=. if( age<ed_mod_age & age!=.)
	}


/*****************************************************************************************************
*                                                                                                    *
                                   LABOR MODULE
*                                                                                                    *
*****************************************************************************************************/


** LABOR MODULE AGE
	gen lb_mod_age=5
	label var lb_mod_age "Labor module application age"

	gen lstatus=.

** LABOR STATUS
	gen days_main_week=.
	replace days_main_week = c53_141 if c53_201 == c53_41 & days_main_week==.
	replace days_main_week = c53_142 if c53_202 == c53_42 & days_main_week==.
	replace days_main_week = c53_143 if c53_203 == c53_43 & days_main_week==.
	replace days_main_week = c53_144 if c53_204 == c53_44 & days_main_week==.

	replace lstatus=1 if days_main_week>=0.5 & inlist(c53_201, 11,12,21,31,41,42,51,61,62,71,72)
	replace lstatus=2 if  c53_201==81 
	replace lstatus=3 if !inlist(lstatus,1,2)
	drop days_main_week

	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus
	replace lstatus=. if  age<lb_mod_age


** EMPLOYMENT STATUS
	gen empstat=.
	replace empstat=1  if c51_3==31 | c51_3==41 | c51_3==51 
	replace empstat=3 if c51_3==12
	replace empstat=4 if c51_3==11
	replace empstat=2 if c51_3==21 
	replace empstat=. if lstatus!=1 | age<lb_mod_age
	label var empstat "Employment status"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed"
	label values empstat lblempstat


** NUMBER OF ADDITIONAL JOBS
	gen njobs=.
	label var njobs "Number of additional jobs"


** SECTOR OF ACTIVITY: PUBLIC - PRIVATE
	gen ocusec=.
	replace ocusec=1 if c51_9==5 | c51_9==7
	replace ocusec=2 if  c51_9>=1 & c51_9<=4
	replace ocusec=2 if c51_9==8 |c51_9==6
	replace ocusec=. if  c51_9==9 
	label var ocusec "Sector of activity"
	la de lblocusec 1 "Public, state owned, government, army, NGO" 2 "Private"
	label values ocusec lblocusec
	replace ocusec=. if lstatus!=1


** REASONS NOT IN THE LABOR FORCE
	gen nlfreason=.
	replace nlfreason=1 if c51_3==91
	replace nlfreason=2 if c51_3==92|c51_3==93
	replace nlfreason=3 if c51_3==94
	replace nlfreason=4 if c51_3==95
	replace nlfreason=5 if c51_3==97 
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

	gen sector_main = substr(c53_211, 1,2)
	destring sector_main, replace 
	recode sector_main (1/5 = 1) (10/14= 2) (15/37=3) (40/41=4) (45=5) (50/55=6) ///
	(60/64=7) (65/74=8) (75=9) (80/99= 10) (nonm = 11), gen(industry)
	recode industry (11=10)
	replace industry=10 if industry==. & sector_main!=.
	replace industry = . if lstatus!=1
	label var industry "1 digit industry classification"
	la de lblindustry 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transports and comnunications" 8 "Financial and business-oriented services" 9 "Community and family oriented services" 10 "Others"
	label values industry lblindustry

** OCCUPATION CLASSIFICATION
	destring c53_221, ignore(X) gen(occ_main)
	gen occup= int(occ_main/100) 
	recode occup(0 = 99)
	replace occup = . if lstatus!=1
	label var occup "1 digit occupational classification"
	label define occup 1 "Senior officials" 2 "Professionals" 3 "Technicians" 4 "Clerks" ///
	5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" ///
	8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup occup


** FIRM SIZE
	gen firmsize_l=.
	replace firmsize_l=1 if c51_11==1
	replace firmsize_l=6 if c51_11==2
	replace firmsize_l=10 if c51_11==3
	replace firmsize_l=20 if c51_11==4
	replace firmsize_l=. if c51_11==9
	replace firmsize_l=. if lstatus!=1
	label var firmsize_l "Firm size (lower bracket)"

	gen firmsize_u=.
	replace firmsize_u=6 if c51_11==1
	replace firmsize_u=9 if c51_11==2
	replace firmsize_u=20 if c51_11==3
	replace firmsize_u=. if c51_11==4 |c51_11==9
	replace firmsize_u=. if lstatus!=1
	label var firmsize_u "Firm size (upper bracket)"


** HOURS WORKED LAST WEEK

	gen HOURWRKMAIN_mon=.

	#delimit;
	gen mainhrs=.;
	forval i = 1/4 { ;
	replace mainhrs = c53_14`i' if c53_201 == c53_4`i' & mi(mainhrs) &
	inlist(c53_4`i', 11, 12, 21, 31, 41, 42, 51); 
	};
	#delimit cr
	replace mainhrs=. if lstatus!=1
	replace mainhrs=0 if lstatus==1 & mi(mainhrs)
	replace HOURWRKMAIN_mon=8*mainhrs*52/12
	drop mainhrs
	gen HOURWRKMAIN_week=HOURWRKMAIN_mon*12/52
	ren HOURWRKMAIN_week whours
	label var whours "Hours of work in last week"


** WAGES
	gen wage= c53_151
	replace wage=. if lstatus!=1
	replace wage=0 if empstat==2
	label var wage "Last wage payment"


** WAGES TIME UNIT
	gen unitwage=.
	replace unitwage=1 if  c53_181==1| c53_181==16
	replace unitwage=2 if  c53_181==2| c53_181==17
	replace unitwage=3 if  c53_181==3| c53_181==18
	replace unitwage=5 if  c53_181==4| c53_181==19
	replace unitwage=. if lstatus!=1 |empstat!=1
	label var unitwage "Last wages time unit"
	la de lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Trimester" 7 "Biannual" 8 "Annually" 9 "Hourly" 
	label values unitwage lblunitwage


** CONTRACT
	gen contract= c51_12
	recode contract (1=0) (2 3 4=1)
	replace contract=. if lstatus!=1
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
	gen union= c72_6
	recode union (2=0)
	replace union=. if lstatus!=1
	la de lblunion 0 "No member" 1 "Member"
	label var union "Union membership"
	label values union lblunion

	local lb_var "lstatus empstat njobs ocusec nlfreason unempldur_l unempldur_u industry industry1 occup firmsize_l firmsize_u whours wage unitwage contract healthins socialsec union"
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
*<_spdef_>
	gen spdef=.
	la var spdef "Spatial deflator"
*</_spdef_>

	
** WELFARE
*<_welfare_>
	gen welfare=hhexp_mon/hhsize
	la var welfare "Welfare aggregate"
*</_welfare_>

*<_welfarenom_>
	gen welfarenom=welfare
	la var welfarenom "Welfare aggregate in nominal terms"
*</_welfarenom_>

*<_welfaredef_>
	gen welfaredef=.
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
	gen welfareothertype=.
	la var welfareothertype "Type of welfare measure (income, consumption or expenditure) for welfareother"
*</_welfareothertype_>

*<_welfarenat_>
	gen welfarenat=.
	la var welfarenat "Welfare aggregate for national poverty"
*</_welfarenat_>

/*****************************************************************************************************
*                                                                                                    *
                                   NATIONAL POVERTY
*                                                                                                    *
*****************************************************************************************************/


** POVERTY LINE (NATIONAL)
*<_pline_nat_>
	gen pline_nat=.
	label variable pline_nat "Poverty Line (National)"
*</_pline_nat_>


** HEADCOUNT RATIO (NATIONAL)
*<_poor_nat_>
	gen poor_nat=.
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
    *_pctile welfare [aw=mult], percent(31.68)
    *di r(r1)
	gen pline_int=675
	label variable pline_int "Poverty Line (Povcalnet)"

	
** HEADCOUNT RATIO (POVCALNET)
	gen poor_int=welfare<pline_int & welfare!=.
	la var poor_int "People below Poverty Line (Povcalnet)"
	la define poor_int 0 "Not Poor" 1 "Poor"
	la values poor_int poor_int
	

/*****************************************************************************************************
*                                                                                                    *
                                   FINAL FIXES
*                                                                                                    *
*****************************************************************************************************/

	qui su wage
	replace wage=0 if empstat==2 & r(N)!=0
	replace ownhouse=. if head==6

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
		 unitwage contract healthins socialsec union  ///
		 pline_nat pline_int poor_nat poor_int spdef cpi ppp cpiperiod welfare welfarenom welfaredef ///
		 welfarenat welfareother welfaretype welfareothertype

** ORDER VARIABLES

	order countrycode year survey idh idp wgt strata psu vermast veralt urban int_month int_year  ///
	      subnatid1 subnatid2 subnatid3 ownhouse water electricity toilet landphone cellphone ///
	      computer internet hsize relationharm relationcs male age soc marital ed_mod_age everattend ///
	      atschool electricity literacy educy educat4 educat5 educat7 lb_mod_age lstatus empstat njobs ///
	      ocusec nlfreason unempldur_l unempldur_u industry occup firmsize_l firmsize_u whours wage ///
		  unitwage contract healthins socialsec union   ///
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

	compress


	saveold "`output'\Data\Harmonized\IND_2009_NSS-SCH10_v01_M_v01_A_SARMD.dta", replace version(12)
	saveold "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\__REGIONAL\Individual Files\IND_2009_NSS-SCH10_v01_M_v01_A_SARMD.dta", replace version(12)


	log close

******************************  END OF DO-FILE  *****************************************************/
