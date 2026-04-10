/*****************************************************************************************************
******************************************************************************************************
**                                                                                                  **
**                                    SOUTH ASIA MICRO DATABASE                                     **
**                                                                                                  **
** COUNTRY	India
** COUNTRY ISO CODE	IND
** YEAR	1993
** SURVEY NAME	SOCIO-ECONOMIC SURVEY  FIFTIETH ROUND JULY 1993-JUNE 1994
*	HOUSEHOLD SCHEDULE 10 : EMPLOYMENT AND UNEMPLOYMENT
** SURVEY AGENCY	GOVERNMENT OF INDIA NATIONAL SAMPLE SURVEY ORGANISATION
** CREATED  BY Triana Yentzen
** MODIFIED BY Yurani Arias Granada 
** Modified	 11/08/2016                                                                                                   **

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
	local input "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\IND\IND_1993_NSS50-SCH10\IND_1993_NSS50-SCH10_v01_M"
	local output "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\IND\IND_1993_NSS50-SCH10\IND_1993_NSS50-SCH10_v01_M_v01_A_SARMD"
    glo pricedata "D:\SOUTH ASIA MICRO DATABASE\CPI\cpi_ppp_sarmd_weighted.dta"

** LOG FILE
	log using "`output'\Doc\Technical\IND_1993_NSS-SCH10_v01_M_v01_A_SARMD.log",replace


/*****************************************************************************************************
*                                                                                                    *
                                   * ASSEMBLE DATABASE
*                                                                                                    *
*****************************************************************************************************/


** DATABASE ASSEMBLENT

    * PREPARE DATASETS
	use "`input'\Data\Stata\DataOrig.dta", clear

	
/*****************************************************************************************************
*                                                                                                    *
                                   * STANDARD SURVEY MODULE
*                                                                                                    *
*****************************************************************************************************/


** COUNTRY
	gen str4 countrycode="IND"
	label var countrycode "Country code"


** YEAR
	gen int year=1993
	label var year "Year of survey"

** SURVEY NAME 
gen str survey="NSS-SCH10"
	label var survey "Survey Acronym"

** INTERVIEW YEAR
gen byte int_year=.
	label var int_year "Year of the interview"

** INTERVIEW MONTH
	gen byte int_month=.
	la de lblint_month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
	label value int_month lblint_month
	label var int_month "Month of the interview"

** HOUSEHOLD IDENTIFICATION NUMBER
    generate idh=string(hid, "%15.0f")
	label var idh "Household id"
	
** INDIVIDUAL IDENTIFICATION NUMBER
    egen str idp=concat(idh B4_C1)
	label var idp "Individual id"
   
** HOUSEHOLD WEIGHTS
	gen wgt=mult
	label var wgt "Household sampling weight"

** STRATA
	gen strata=stratum
	destring strata, replace
	label var strata "Strata"

** PSU
	gen psu=fsu
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
	la de lblurban 1 "Urban" 0 "Rural"
	label values urban lblurban
	
** REGIONAL AREA 2 DIGIT ADMN LEVEL
	ren state state_50
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

	gen subnatid2=state
	label var subnatid2 "Region at 2 digit (ADMN2)"

	label define subnatid2 1 "Jammu & Kashmir", modify
	label define subnatid2 2 "Himachal Pradesh", modify
	label define subnatid2 3 "Punjab", modify
	label define subnatid2 4 "Chandigarh", modify
	label define subnatid2 5 "Uttaranchal", modify
	label define subnatid2 6 "Haryana", modify
	label define subnatid2 7 "Delhi", modify
	label define subnatid2 8 "Rajasthan", modify
	label define subnatid2 9 "Uttar Pradesh", modify
	label define subnatid2 10 "Bihar", modify
	label define subnatid2 11 "Sikkim", modify
	label define subnatid2 12 "Arunachal Pradesh", modify
	label define subnatid2 13 "Nagaland", modify
	label define subnatid2 14 "Manipur", modify
	label define subnatid2 15 "Mizoram", modify
	label define subnatid2 16 "Tripura", modify
	label define subnatid2 17 "Meghalaya", modify
	label define subnatid2 18 "Assam", modify
	label define subnatid2 19 "West Bengal", modify
	label define subnatid2 20 "Jharkhand", modify
	label define subnatid2 21 "Orissa", modify
	label define subnatid2 22 "Chattisgarh", modify
	label define subnatid2 23 "Madhya Pradesh", modify
	label define subnatid2 24 "Gujarat", modify
	label define subnatid2 25 "Daman & Diu", modify
	label define subnatid2 26 "D & N Haveli", modify
	label define subnatid2 27 "Maharastra", modify
	label define subnatid2 28 "Andhra Pradesh", modify
	label define subnatid2 29 "Karnataka", modify
	label define subnatid2 30 "Goa", modify
	label define subnatid2 31 "Lakshadweep", modify
	label define subnatid2 32 "Kerala", modify
	label define subnatid2 33 "Tamil Nadu", modify
	label define subnatid2 34 "Pondicherry", modify
	label define subnatid2 35 "A & N Islands", modify
	label values subnatid2 subnatid2

	** REGIONAL AREA 1 DIGIT ADMN LEVEL
	recode state (1 2 3 4 6 8 = 1) (5 7 9 10 23 = 2) (12/18 = 3) (11 19 20 21 22 35 = 4) ( 24 25 26 27 30 = 5) (28 29 31 32 33 34 = 6), gen(subnatid1)
	label define lblsubnatid1 1 "Northern" 2 "North-Central" 3 "North-Eastern" 4 "Eastern" 5 "Western" 6 "Southern"
	label var subnatid1 "Region at 1 digit (ADMN1)"
	label values subnatid1 lblsubnatid1

** REGIONAL AREA 3 DIGIT ADMN LEVEL
	gen byte subnatid3=.
	label var subnatid3 "Region at 3 digit (ADMN3)"
	label values subnatid3 lblsubnatid3

** HOUSE OWNERSHIP
	gen ownhouse=.
	label var ownhouse "House ownership"
	la de lblownhouse 0 "No" 1 "Yes"
	label values ownhouse lblownhouse

** WATER PUBLIC CONNECTION
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


** HOUSEHOLD SIZE
	cap drop hhsize
	bys idh: egen hhsize=count(B4_C3) if B4_C3>=1 & B4_C3<=8
	label var hhsize "Household size"

	bys idh: gen one=1 if B4_C3==1 
	bys idh: egen temp=count(one) 
	keep if temp==1


** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
	gen relationharm=B4_C3
	recode relationharm (3 5 = 3) (7=4) (4 6 8 = 5) (9=6) (0=.)
	label var relationharm "Relationship to the head of household"
	la de lblrelationharm  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Non-relatives"
	label values relationharm  lblrelationharm
	

	** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
    gen byte relationcs=B4_C3
	la var relationcs "Relationship to the head of household country/region specific"
	label define lblrelationcs 1 "Head" 2 "Spouse of head" 3 "married child" 4 "spouse of married child" 5 "unmarried child" 6 "grandchild" 7 "father/mother/father-in-law/mother-in-law" 8 "brother/sister/brother-in-law/sister-in-law/other relations" 9 "servant/employee/other non-relative"
	label values relationcs lblrelationcs

** GENDER
	gen male=B4_C4
	recode male (2=0)
	label var male "Sex of household member"
	la de lblmale 1 "Male" 0 "Female"
	label values male lblmale


** AGE
    gen age=B4_C5
	replace age=98 if age>=98 & age!=.
	label var age "Individual age"


** SOCIAL GROUP

/*
The caste variable exist too, named "socialgrp"
*/
	gen soc=B3_C4
* socialgrp
	label var soc "Social group"
	label define soc 1 "Hinduism" 2 "Islam" 3 "Christianity" 4 "Sikhism" 
	label define soc 5 "Jainism" 6 "Buddhism" 7 "Zoroastrianism" 9 "Others", add
	label values soc soc


** MARITAL STATUS
	gen marital=.
	replace marital=1 if B4_C6==2
	replace marital=2 if B4_C6==1
	replace marital=4 if B4_C6==4
	replace marital=5 if B4_C6==3
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
	gen atschool=.
	replace atschool=0 if B4_C9==1
	replace atschool=1 if B4_C9>1 & B4_C9!=.
	label var atschool "Attending school"
	la de lblatschool 0 "No" 1 "Yes"
	label values atschool  lblatschool


** CAN READ AND WRITE
	gen literacy=B4_C7
	recode literacy (2/13 = 1) (1= 0) (0=.)
	label var literacy "Can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy

** YEARS OF EDUCATION COMPLETED
	gen educy=.
	/* no education */
	replace educy=0 if genedulev==01 | genedulev==02 | genedulev==03 | genedulev==04 
	/* below primary */
	replace educy=1 if genedulev==05
	/* primary */
	replace educy=5 if genedulev==06
	/* middle */
	replace educy=8 if genedulev==07
	/* secondary */
	replace educy=10 if genedulev==8
	/* higher secondary */
	replace educy=12 if genedulev==9
	/* graduate and above in agriculture, engineering/technology, medicine */
	replace educy=16 if genedulev==10 | genedulev==11 | genedulev==12
	/* graduate and above in other subjects */
	replace educy=15 if genedulev==13
	gen ageminus4=age-4
	replace educy=ageminus4 if (educy>ageminus4)& (educy>0) & (ageminus4>0) & (educy!=.)
	replace educy=0 if (educy>ageminus4) & (educy>0) &(ageminus4<=0) & (educy!=.)
	label var educy "Years of education"


** EDUCATION LEVEL 7 CATEGORIES
	gen educat7=.
	replace educat7=1 if genedulev==01 
	replace educat7=2 if genedulev==5
	replace educat7=3 if genedulev==6
	replace educat7=4 if genedulev==7 | genedulev==8
	replace educat7=5 if genedulev==9
	replace educat7=7 if genedulev==10 | genedulev==11 | genedulev==12 | genedulev==13
	replace educat7=8 if  genedulev==02 | genedulev==03 | genedulev==04
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
	recode B4_C7 (1 2 3 4= 0) (5 6 7 8 9 10 11 12 13=1), gen (everattend)
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
	gen lb_mod_age=0
	label var lb_mod_age "Labor module application age"

	
** LABOR STATUS
    gen lstatus=.
	gen days_main_week=.
	replace days_main_week=totdaysactivity_1 if statusweek==status_1 & days_main_week==. 
	replace days_main_week=totdaysactivity_2 if statusweek==status_2 & days_main_week==.
	replace days_main_week=totdaysactivity_3 if statusweek==status_3 & days_main_week==.
	replace days_main_week=totdaysactivity_4 if statusweek==status_4 & days_main_week==.
	replace days_main_week=. if statusweek==.
	replace lstatus=2 if  statusweek==81 
	replace lstatus=1 if days_main_week>=0.5 & (statusweek==11 | statusweek==12 | statusweek==21 | statusweek==31 | statusweek==41 | statusweek==51 ) 
	replace lstatus=1 if (statusweek==61 | statusweek==62 | statusweek==71 | statusweek==72) 
	replace lstatus=3 if (lstatus!=1 & lstatus!=2)
	gen daysmain=days_main_week if lstatus==1
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus


** EMPLOYMENT STATUS
	gen empstat=.
	replace empstat=1  if statusweek==31 | statusweek==41 | statusweek==51 | statusweek==71 | statusweek==72
	replace empstat=3 if statusweek==12
	replace empstat=4 if statusweek==11
	replace empstat=2 if statusweek==21 | statusweek==61 | statusweek==62 
	replace empstat=. if lstatus==2 | lstatus==3
	label var empstat "Employment status"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed"
	label values empstat lblempstat


** NUMBER OF ADDITIONAL JOBS
	gen njobs=.
	label var njobs "Number of additional jobs"


** SECTOR OF ACTIVITY: PUBLIC - PRIVATE
	gen ocusec=.
	replace ocusec=1 if B7_C20==1|B7_C20==2
	replace ocusec=2 if B7_C20==3
	label var ocusec "Sector of activity"
	la de lblocusec 1 "Public, state owned, government, army, NGO" 2 "Private"
	label values ocusec lblocusec
	replace ocusec=. if lstatus==2 | lstatus==3

** REASONS NOT IN THE LABOR FORCE
	gen nlfreason=.
	label var nlfreason "Reason not in the labor force"
	la de lblnlfreason 1 "Student" 2 "Housewife" 3 "Retired" 4 "Disable" 5 "Other"
	label values nlfreason lblnlfreason


** UNEMPLOYMENT DURATION: MONTHS LOOKING FOR A JOB
	gen unempldur_l=.
	replace unempldur_l=0 if B6_C8<=3
	replace unempldur_l=1 if B6_C8==4
	replace unempldur_l=2 if B6_C8==5
	replace unempldur_l=3 if B6_C8==6
	replace unempldur_l=6 if B6_C8==7
	replace unempldur_l=12 if B6_C8==8
	replace unempldur_l=. if B6_C8==.
	replace unempldur_l=. if lstatus!=2
	label var unempldur_l "Unemployment duration (months) lower bracket"

	gen unempldur_u=.
	replace unempldur_u=1 if B6_C8<=3
	replace unempldur_u=2 if B6_C8==4
	replace unempldur_u=3 if B6_C8==5
	replace unempldur_u=6 if B6_C8==6
	replace unempldur_u=12 if B6_C8==7
	replace unempldur_u=. if B6_C8==8 |B6_C8==.
	replace unempldur_u=. if lstatus!=2
	label var unempldur_u "Unemployment duration (months) upper bracket"


** INDUSTRY CLASSIFICATION
	gen industry=.
	gen str5 princind_ISIC=industryweek
	gen princind_CODE=substr(princind_ISIC,1,2)
	drop princind_ISIC
	destring princind_CODE, generate(princind_ISIC)
	replace industry=1 if princind_ISIC>=00 & princind_ISIC<=09 
	replace industry=2 if princind_ISIC>=10 & princind_ISIC<=19
	replace industry=3 if princind_ISIC>=20 & princind_ISIC<=39
	replace industry=4 if princind_ISIC>=40 & princind_ISIC<=47 
	replace industry=5 if princind_ISIC>=50 & princind_ISIC<=59 
	replace industry=6 if princind_ISIC>=60 & princind_ISIC<=69
	replace industry=7 if princind_ISIC>=70 & princind_ISIC<=79
	replace industry=8 if princind_ISIC>=80 & princind_ISIC<=89
	replace industry=9 if  princind_ISIC==90
	replace industry=10 if princind_ISIC>=91 & princind_ISIC<=99
	replace industry=10 if industry==. & princind_ISIC!=.
	label var industry "1 digit industry classification"
	la de lblindustry 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transports and comnunications" 8 "Financial and business-oriented services" 9 "Community and family oriented services" 10 "Others"
	label values industry lblindustry
	replace industry=. if lstatus==2 | lstatus==3


** INDUSTRY
	gen byte industry=industry
	recode industry (1=1)(2 3 4 5 =2)(6 7 8 9=3)(10=4)
	replace industry=. if lstatus!=1
	label var industry "1 digit industry classification (Broad Economic Activities)"
	la de lblindustry 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other"
	label values industry lblindustry


** OCCUPATION CLASSIFICATION
	destring occupweek,replace
	gen occup=.
	replace occup=1 if (occupweek>=100 & occupweek<200) |(occupweek>=1 & occupweek<20)
	replace occup=2 if (occupweek>=200 & occupweek<300) |(occupweek>=20 & occupweek<30)
	replace occup=3 if (occupweek>=300 & occupweek<400) |(occupweek>=30 & occupweek<40)
	replace occup=4 if (occupweek>=400 & occupweek<500) |(occupweek>=40 & occupweek<50)
	replace occup=5 if (occupweek>=500 & occupweek<600) |(occupweek>=50 & occupweek<60)
	replace occup=6 if (occupweek>=600 & occupweek<700) |(occupweek>=60 & occupweek<70)
	replace occup=7 if (occupweek>=700 & occupweek<800) |(occupweek>=70 & occupweek<80)
	replace occup=8 if (occupweek>=800 & occupweek<900)|(occupweek>=80 & occupweek<90)
	replace occup=9 if (occupweek>=900 & occupweek<1000) |(occupweek>=90 & occupweek<100)
	replace occup=. if lstatus!=1
	label var occup "1 digit occupational classification"
	label define occup 1 "Senior officials" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers"  8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"

	# delimit;

*** FIRM SIZE
	gen firmsize_l=.;
	label var firmsize_l "Firm size (lower bracket)";

	gen firmsize_u=.;
	label var firmsize_u "Firm size (upper bracket)";


*** HOURS WORKED LAST WEEK
	gen HOURWRKMAIN_mon=.;

	gen mainhrs=.;
	forval i = 1/4 { ;
	replace mainhrs = totdaysactivity_`i' if statusweek == status_`i' & mi(mainhrs) & 
	inlist(status_`i', 11, 12, 21, 31, 41, 51);
	};
	replace mainhrs=. if  lstatus==2 | lstatus==3;
	replace mainhrs=0 if lstatus==1 & mi(mainhrs);
	replace HOURWRKMAIN_mon=8*mainhrs*52/12; drop mainhrs;
	gen HOURWRKMAIN_week=HOURWRKMAIN_mon*12/52;
	ren HOURWRKMAIN_week whours;
	label var whours "Hours of work in last week";
	# delimit cr


** WAGES
	gen wage=wagecashrs_1
	replace wage=. if lstatus==2 | lstatus==3
	replace wage=0 if empstat==2
	label var wage "Last wage payment"


** WAGES TIME UNIT
	gen unitwage=2 if lstatus==1 & empstat==1
	recode unitwage (0=.)
	label var unitwage "Last wages time unit"
	la de lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Trimester" 7 "Biannual" 8 "Annually" 9 "Hourly"
	label values unitwage lblunitwage


** CONTRACT
	gen contract=0 if statusweek==41 | statusweek==51
	replace contract=1 if statusweek==31 | statusweek==71 | statusweek==72
	label var contract "Contract"
	la de lblcontract 0 "Without contract" 1 "With contract"
	label values contract lblcontract
	replace contract=. if lstatus==2 | lstatus==3


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
	gen union=B7_C18
	label var union "Union membership"
	recode union (2=0)
	replace union=. if  lstatus==2 | lstatus==3
	la de lblunion 0 "No member" 1 "Member"
	label values union lblunion

	local lb_var "lstatus empstat njobs ocusec nlfreason unempldur_l unempldur_u industry industry1  occup firmsize_l firmsize_u whours wage unitwage contract healthins socialsec union"
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
	gen welfare=pcexp
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
    *_pctile pcexp [aw=mult], percent(46.23)
    *di r(r1)
	gen pline_int=246.96001
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
	replace ownhouse=. if head==4

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


	saveold "`output'\Data\Harmonized\IND_1993_NSS50-SCH10\IND_1993_NSS50-SCH10_v01_M_v01_A_SARMD", replace version(12)
	saveold "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\__REGIONAL\Individual Files\IND_1993_NSS50-SCH10\IND_1993_NSS50-SCH10_v01_M_v01_A_SARMD", replace version(12)


	log close

******************************  END OF DO-FILE  *****************************************************/
