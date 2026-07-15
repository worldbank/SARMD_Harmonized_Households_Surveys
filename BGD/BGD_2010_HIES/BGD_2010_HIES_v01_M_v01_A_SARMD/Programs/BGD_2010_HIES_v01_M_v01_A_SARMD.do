/*****************************************************************************************************
******************************************************************************************************
**                                                                                                  **
**                                   SOUTH ASIA MICRO DATABASE                                      **
**                                                                                                  **
** COUNTRY			Bangladesh
** COUNTRY ISO CODE	BGD
** YEAR				2010
** SURVEY NAME		HOUSEHOLD INCOME AND EXPENDITURE SURVEY-2010
** SURVEY AGENCY	BANGLADESH BUREAU OF STATISTICS
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
	local input "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\BGD\BGD_2010_HIES\BGD_2010_HIES_v01_M"
	local output "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\BGD\BGD_2010_HIES\BGD_2010_HIES_v01_M_v01_A_SARMD"

** LOG FILE
	log using "`input'\Doc\Technical\BGD_2010_HIES.log",replace

/*****************************************************************************************************
*                                                                                                    *
                                   * ASSEMBLE DATABASE
*                                                                                                    *
*****************************************************************************************************/


	
	use "`input'\Data\Stata\rt002.dta",clear
	tempfile BGD1
	destring psu hhold idcode,replace
	egen indvid=group(psu hhold idcode)
	isid indvid
	sort indvid
	save `BGD1', replace
	use "`input'\Data\Stata\rt003.dta",clear
	tempfile BGD2
	destring psu hhold idcode,replace
	egen indvid=group(psu hhold idcode)
	drop if indvid==.
	*isid indvid


	bys indvid: egen max_month=max(s04a_q02)
	bys indvid: egen max_day=max(s04a_q03)
	bys indvid: egen max_hour=max(s04a_q04)
	bys indvid: gen n=_n

	bys indvid: egen njobs=max(n)
	drop n

	duplicates tag indvid, gen (TAG)
	keep if TAG==0 | (TAG!=0 & s04a_q02==max_month)

	duplicates tag indvid, gen(TAG2)
	keep if TAG2==0 | (TAG2!=0 & s04a_q03==max_day)

	duplicates tag indvid, gen(TAG3)
	keep if TAG3==0 | (TAG3!=0 & s04a_q04==max_hour)

	drop TAG*
	drop max*

	duplicates tag indvid, gen(TAG)

	gen WAGE=.
	replace WAGE=s04b_q02 if s04b_q01==1
	replace WAGE=s04b_q08 if s04b_q01==2

	bys indvid: egen max_WAGE=max(WAGE)
	bys indvid:  gen n=_n

	drop if TAG==1 & max_WAGE==. & n==2
	keep if TAG==0 | (TAG==1 & (max_WAGE==s04b_q02 | max_WAGE==s04b_q08 ) )

	drop TAG
	duplicates tag indvid, gen(TAG)
	drop if TAG==1 & n==2

	drop TAG n

	isid indvid

	sort indvid 
	save `BGD2',replace
	use "`input'\Data\Stata\rt001.dta",clear
	tempfile BGD3
	destring psu hhold,replace
	sort psu hhold
	save `BGD3',replace

	use  `BGD1',clear
	merge indvid using `BGD2', _merge(merge1)
	tab merge1
	sort psu hhold
	merge psu hhold using `BGD3', _merge(merge2)
	tab merge2
	drop merge*
	sort psu hhold
	merge m:1 psu hhold using "`input'\Data\Stata\Old\consumption.dta"



/*****************************************************************************************************
*                                                                                                    *
                                   * STANDARD SURVEY MODULE
*                                                                                                    *
*****************************************************************************************************/
	

** COUNTRY
	gen str4 countrycode="BGD"
	label var countrycode "Country code"


** YEAR
	gen int year=2010
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
	egen idh=concat(psu hhold), punct(-)

	label var idh "Household id"


** INDIVIDUAL IDENTIFICATION NUMBER
	egen idp=concat(idh idcode), punct(-)

	label var idp "Individual id"


** HOUSEHOLD WEIGHTS
	*gen double wgt=WEIGHT
	label var wgt "Household sampling weight"

	destring stratum, replace

** STRATA
	gen strata= stratum
	label var strata "Strata"


** PSU
	*gen psu=PSU
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
	gen byte urban=.
	replace urban=1 if (urbanrur==2 & spc!="Municipal") | (urbanrur==4 & spc=="SMA")
	replace urban=0 if (urbanrur==1 & spc=="Rural") | (urbanrur==3 & spc=="Rural")
	label var urban "Urban/Rural"
	la de lblurban 1 "Urban" 0 "Rural"
	label values urban lblurban


**REGIONAL AREAS

** REGIONAL AREA 1 DIGIT ADMN LEVEL
	gen byte subnatid1=region
	la de lblsubnatid1 10 "Barisal" 20"Chittagong" 30"Dhaka" 40"Khulna" 50"Rajshahi" 55"Rangpur" 60"Sylhet"
	label var subnatid1 "Region at 1 digit (ADMN1)"
	label values subnatid1 lblsubnatid1


** REGIONAL AREA 2 DIGIT ADMN LEVEL
	gen byte subnatid2=district
	label define lblsubnatid2 1 "Bagerhat", add
	label define lblsubnatid2 3 "Bandarban", add
	label define lblsubnatid2 4 "Barguna", add
	label define lblsubnatid2 6 "Barisal", add
	label define lblsubnatid2 9 "Bhola", add
	label define lblsubnatid2 10 "Bogra", add
	label define lblsubnatid2 12 "Brahmanbaria", add
	label define lblsubnatid2 13 "Chandpur", add
	label define lblsubnatid2 15 "Chittagong", add
	label define lblsubnatid2 18 "Chuadanga", add
	label define lblsubnatid2 19 "Comilla", add
	label define lblsubnatid2 22 "Cox's bazar", add
	label define lblsubnatid2 26 "Dhaka", add
	label define lblsubnatid2 27 "Dinajpur", add
	label define lblsubnatid2 29 "Faridpur", add
	label define lblsubnatid2 30 "Feni", add
	label define lblsubnatid2 32 "Gaibandha", add
	label define lblsubnatid2 33 "Gazipur", add
	label define lblsubnatid2 34 "Rajbari", add
	label define lblsubnatid2 35 "Gopalganj", add
	label define lblsubnatid2 36 "Habiganj", add
	label define lblsubnatid2 38 "Jaipurhat", add
	label define lblsubnatid2 39 "Jamalpur", add
	label define lblsubnatid2 41 "Jessore", add
	label define lblsubnatid2 42 "Jhalokati", add
	label define lblsubnatid2 44 "Jhenaidah", add
	label define lblsubnatid2 46 "Khagrachari", add
	label define lblsubnatid2 47 "Khulna", add
	label define lblsubnatid2 48 "Kishoreganj", add
	label define lblsubnatid2 49 "Kurigram", add
	label define lblsubnatid2 50 "Kushtia", add
	label define lblsubnatid2 51 "Lakshmipur", add
	label define lblsubnatid2 52 "Lalmonirhat", add
	label define lblsubnatid2 54 "Madaripur", add
	label define lblsubnatid2 55 "Magura", add
	label define lblsubnatid2 56 "Manikganj", add
	label define lblsubnatid2 57 "Meherpur", add
	label define lblsubnatid2 58 "Maulvibazar", add
	label define lblsubnatid2 59 "Munshigan", add
	label define lblsubnatid2 61 "Mymensingh", add
	label define lblsubnatid2 64 "Naogaon", add
	label define lblsubnatid2 65 "Narail", add
	label define lblsubnatid2 67 "Narayanganj", add
	label define lblsubnatid2 68 "Narsingdi", add
	label define lblsubnatid2 69 "Natore", add
	label define lblsubnatid2 70 "Nawabganj", add
	label define lblsubnatid2 72 "Netrokona", add
	label define lblsubnatid2 73 "Nilphamari", add
	label define lblsubnatid2 75 "Noakhali", add
	label define lblsubnatid2 76 "Pabna", add
	label define lblsubnatid2 77 "Panchagar", add
	label define lblsubnatid2 78 "Patuakhali", add
	label define lblsubnatid2 79 "Pirojpur", add
	label define lblsubnatid2 81 "Rajshahi", add
	label define lblsubnatid2 82 "Rajbari", add
	label define lblsubnatid2 84 "Rangamati", add
	label define lblsubnatid2 85 "Rangpur", add
	label define lblsubnatid2 86 "Shariatpur", add
	label define lblsubnatid2 87 "Satkhira", add
	label define lblsubnatid2 88 "Sirajganj", add
	label define lblsubnatid2 89 "Sherpur", add
	label define lblsubnatid2 90 "Sunamganj", add
	label define lblsubnatid2 91 "Sylhet", add
	label define lblsubnatid2 93 "Tangail", add
	label define lblsubnatid2 94 "Thakurgaon", add
	label var subnatid2 "Region at 2 digit (ADMN2)"
	label values subnatid2 lblsubnatid2


** REGIONAL AREA 3 DIGIT ADMN LEVEL
	gen byte subnatid3=.
	label var subnatid3 "Region at 3 digit (ADMN3)"
	label values subnatid3 lblsubnatid3
		

** HOUSE OWNERSHIP
	gen byte ownhouse=.
	replace ownhouse=0 if  s08a_q05==2
	replace ownhouse=1 if s08a_q05==1
	label var ownhouse "House ownership"
	la de lblownhouse 0 "No" 1 "Yes"
	label values ownhouse lblownhouse


** WATER PUBLIC CONNECTION
	gen byte water=.
	replace water=1 if s06a_q09==1
	replace water=0 if s06a_q09>1 & s06a_q09<7
	label var water "Water main source"
	la de lblwater 0 "No" 1 "Yes"
	label values water lblwater


** ELECTRICITY PUBLIC CONNECTION
	gen byte electricity= s06a_q14
	recode electricity (2=0)
	label var electricity "Electricity main source"
	la de lblelectricity 0 "No" 1 "Yes"
	label values electricity lblelectricity


** TOILET PUBLIC CONNECTION
	gen byte toilet= s06a_q08
	recode toilet  2/6=0
	label var toilet "Toilet facility"
	la de lbltoilet 0 "No" 1 "Yes"
	label values toilet lbltoilet


** LAND PHONE
	gen byte landphone=.
	replace landphone=1 if s06a_q17==1
	replace landphone=0 if s06a_q17==0
	label var landphone "Phone availability"
	la de lbllandphone 0 "No" 1 "Yes"
	label values landphone lbllandphone


** CEL PHONE
	gen byte cellphone=.
	replace cellphone=1 if s06a_q16==1
	replace cellphone=0 if s06a_q16==2
	label var cellphone "Cell phone"
	la de lblcellphone 0 "No" 1 "Yes"
	label values cellphone lblcellphone


** COMPUTER
	gen byte computer= .
	replace computer=1 if s06a_q18==1
	replace computer=0 if s06a_q18==2
	label var computer "Computer availability"
	la de lblcomputer 0 "No" 1 "Yes"
	label values computer lblcomputer


** INTERNET
	gen byte internet=.
	replace internet=1  if s06a_q19==1
	replace internet=0  if s06a_q19==2
	label var internet "Internet connection"
	la de lblinternet 0 "No" 1 "Yes"
	label values internet lblinternet


/*****************************************************************************************************
*                                                                                                    *
                                   DEMOGRAPHIC MODULE
*                                                                                                    *
*****************************************************************************************************/


** HOUSEHOLD SIZE
	ren member hsize
	label var hsize "Household size"


** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
	gen byte relationharm=s01a_q03
	recode relationharm  (6=4) (4 5 7 8 9  10 11=5) (12 13 14 = 6)


	label var relationharm "Relationship to the head of household"
	la de lblrelationharm  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Non-relatives"
	label values relationharm  lblrelationharm

	gen byte relationcs=s01a_q03
	la var relationcs "Relationship to the head of household country/region specific"
	label define lblrelationcs 1 "Head" 2 "Husband/Wife" 3 "Son/Daughter" 4 "Spouse of Son/Daughter" 5 "Grandchild" 6 "Father/Mother" 7 "Brother/Sister" 8 "Niece/Nephew" 9 "Father/Mother-in-law" 10 "Brother/Sister-in-law" 11 "Other relative" 12 "Servant" 13 "Employee" 14 "Other"
	label values relationcs lblrelationcs


** GENDER
	drop male
	gen byte male= s01a_q02
	recode male (2=0)
	label var male "Sex of household member"
	la de lblmale 1 "Male" 0 "Female"
	label values male lblmale


** AGE
	gen byte age=  s01a_q04
	label var age "Individual age"


** SOCIAL GROUP
	gen byte soc=s01a_q05
	label var soc "Social group"
	la de lblsoc 1 "Islam" 2 "Hinduism" 3 "Buddhism" 4 "Christianity" 5 "Other"
	label values soc lblsoc


** MARITAL STATUS
	gen byte marital=.
	replace marital=1 if s01a_q06==1
	replace marital=4 if s01a_q06==5 | s01a_q06==4
	replace marital=5 if s01a_q06==3
	replace marital=2 if s01a_q06==2
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
	gen byte atschool=s02b_q01
	replace atschool=0 if s02b_q01==2
	replace atschool=. if age<5

	label var atschool "Attending school"
	la de lblatschool 0 "No" 1 "Yes"
	label values atschool  lblatschool


** CAN READ AND WRITE
	gen byte literacy=.
	replace literacy=1 if s02a_q03==1 & s02a_q04==1
	replace literacy=0 if s02a_q03==0 | s02a_q04==0
	replace literacy=. if age<ed_mod_age
	label var literacy "Can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy


** YEARS OF EDUCATION COMPLETED
	recode s02b_q02 (11 = 12) (12 = 16) (13 = 18 ) (14 = 19) (15 = 17) (16 =14) (17=14) (18=16) (19=.)
	gen byte educy=s02a_q05
	recode educy (11 = 12) (12 = 16) (13 = 18 ) (14 = 19) (15 = 17) (16 =14) (17=14) (18=16) (19=.)
	replace educy=s02b_q02 if educy==. & s02b_q02!=.
	replace educy=educy-1 if s02a_q05==. & s02b_q02!=.
	replace educy=0 if educy==-1
	replace educy=. if educy==50
	replace educy=. if age<5
	label var educy "Years of education"

	replace educy=. if educy>age & educy!=. & age!=.


** EDUCATIONAL LEVEL 7 CATEGORIES
	gen byte educat7=.
	replace educat7=1 if educy==0
	replace educat7=2 if (educy>0 & educy<5)
	replace educat7=3 if (educy==5)
	replace educat7=4 if (educy>5 & educy<12)
	replace educat7=5 if (educy==12)
	replace educat7=7 if (educy>12 & educy<23)
	replace educat7=6 if s02a_q05==16 | s02a_q05==17
	replace educat7=6 if s02b_q02==16 | s02b_q02==17
	replace educat7=. if age<5
	label define lbleducat7 1 "No education" 2 "Primary incomplete" 3 "Primary complete" ///
	4 "Secondary incomplete" 5 "Secondary complete" 6 "Higher than secondary but not university" /// 
	7 "University incomplete or complete" 8 "Other" 9 "Not classified"
	label values educat7 lbleducat7
	la var educat7 "Level of education 7 categories"


** EDUCATION LEVEL 4 CATEGORIES
	gen byte educat4=.
	replace educat4=1 if educat7==1 
	replace educat4=2 if educat7==2 |educat7==3
	replace educat4=3 if educat7==4 |educat7==5
	replace educat4=4 if educat7==6 |educat7==7
	label var educat4 "Level of education 4 categories"
	label define lbleducat4 1 "No education" 2 "Primary (complete or incomplete)" ///
	3 "Secondary (complete or incomplete)" 4 "Tertiary (complete or incomplete)"
	label values educat4 lbleducat4

	
** EDUCATION LEVEL 5 CATEGORIES
	gen educat5=.
	replace educat5=1 if educat7==1
	replace educat5=2 if educat7==2
	replace educat5=3 if educat7==3 | educat7==4
	replace educat5=4 if educat7==5
	replace educat5=5 if educat7==6 |educat7==7
	label define lbleducat5 1 "No education" 2 "Primary incomplete" ///
	3 "Primary complete but secondary incomplete" 4 "Secondary complete" ///
	5 "Some tertiary/post-secondary"
	label values educat5 lbleducat5
	la var educat5 "Level of education 5 categories"


** EVER ATTENDED SCHOOL
	gen byte everattend=.
	replace everattend=0 if educat7==1 
	replace everattend=1 if educat7>=2 | atschool==1
	replace everattend=. if age<5
	label var everattend "Ever attended school"
	la de lbleverattend 0 "No" 1 "Yes"
	label values everattend lbleverattend



/*****************************************************************************************************
*                                                                                                    *
                                   LABOR MODULE
*                                                                                                    *
*****************************************************************************************************/


** LABOR MODULE AGE
	gen byte lb_mod_age=5
	label var lb_mod_age "Labor module application age"


** LABOR STATUS
	gen byte lstatus=.
	replace lstatus=1 if s01b_q01==1
	replace lstatus=2 if s01b_q01==2 & s01b_q02==1 & s01b_q03==1 & lstatus==.
	replace lstatus=3 if s01b_q01==2 & s01b_q02==2 & s01b_q02==2
	replace lstatus=. if  age<5
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus


** EMPLOYMENT STATUS
	gen byte empstat=.
	replace empstat=1 if s04a_q07==1|s04a_q08==1|s04a_q07==4|s04a_q08==4
	replace empstat=3 if s04a_q07==3| s04a_q08==3
	replace empstat=4 if s04a_q07==2| s04a_q08==2
	replace empstat=. if lstatus!=1

	label var empstat "Employment status"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other"
	label values empstat lblempstat


** NUMBER OF ADDITIONAL JOBS

	label var njobs "Number of additional jobs"


** SECTOR OF ACTIVITY: PUBLIC - PRIVATE
	gen byte ocusec=.
	replace ocusec= 1 if s04b_q06== 1 |s04b_q06==2 | s04b_q06==4 | s04b_q06==6
	replace ocusec= 1 if s04b_q06==7
	replace ocusec= 2 if s04b_q06==3 |s04b_q06==5 | s04b_q06==8
	replace ocusec=. if lstatus!=1
	label var ocusec "Sector of activity"
	la de lblocusec 1 "Public, state owned, government, army, NGO" 2 "Private"
	label values ocusec lblocusec


** REASONS NOT IN THE LABOR FORCE
	gen byte nlfreason=.
	replace nlfreason=1 if s01b_q04==3
	replace nlfreason=2 if s01b_q04==2|s01b_q04==1
	replace nlfreason=3 if s01b_q04==4
	replace nlfreason=4 if s01b_q04==7
	replace nlfreason=5 if s01b_q04==5|s01b_q04==6|s01b_q04>=8 & s01b_q04<=11
	replace nlfreason=. if s01b_q04==0 | s01b_q04==25 | lstatus!=3
	label var nlfreason "Reason not in the labor force"
	la de lblnlfreason 1 "Student" 2 "Housewife" 3 "Retired" 4 "Disable" 5 "Other"
	label values nlfreason lblnlfreason


** UNEMPLOYMENT DURATION: MONTHS LOOKING FOR A JOB
	gen byte unempldur_l=.
	label var unempldur_l "Unemployment duration (months) lower bracket"

	gen byte unempldur_u=.
	label var unempldur_u "Unemployment duration (months) upper bracket"


** INDUSTRY CLASSIFICATION
	gen industry=s04a_q_2
	destring industry,replace
	recode industry (1/5=1) (10/14=2) (15/39=3) (40/43=4) (45/49=5) (50/59=6) (60/64=7) (65/74=8) (75=9) (76/99=10)
	replace industry=. if lstatus==2| lstatus==3
	label var industry "1 digit industry classification"
	replace industry=. if lstatus!=1
	la de lblindustry 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transports and comnunications" 8 "Financial and business-oriented services" 9 "Public Administration" 10 "Other services, Unspecified"
	label values industry lblindustry


** OCCUPATION CLASSIFICATION
	destring s04a_q_1,replace
	gen occup= 1 if  inrange(s04a_q_1,20,30) | s04a_q_1==40
	replace occup= 2 if  inlist(s04a_q_1,2,4,6) |inrange(s04a_q_1,8,13)|inrange(s04a_q_1,15,19)
	replace occup= 3 if  inlist(s04a_q_1,1,3,5,7,14)
	replace occup= 4 if  inrange(s04a_q_1,31,33) | s04a_q_1==39
	replace occup= 5 if  inrange(s04a_q_1,50,59)
	replace occup=6 if  inrange(s04a_q_1,60,66)
	replace occup=7 if  inrange(s04a_q_1,40,46) | s04a_q_1==49
	replace occup=8 if  inrange(s04a_q_1,34,38) |inrange(s04a_q_1,70,86)
	replace occup=9 if  inrange(s04a_q_1,87,99)
	sum occup s04a_q_1
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
	gen whours=s04a_q04*5.5
	replace whours=. if lstatus!=1
	label var whours "Hours of work in last week"


** WAGES
	gen double wage=.
	replace wage=s04b_q02 if s04b_q01==1
	replace wage=s04b_q08 if s04b_q01==2
	replace wage=. if lstatus!=1
	label var wage "Last wage payment"


** WAGES TIME UNIT
	gen byte unitwage=.
	replace unitwage=1 if s04b_q01==1
	replace unitwage=5 if s04b_q01==2
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

	drop union

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
	gen spdef=zu10
	la var spdef "Spatial deflator"

** WELFARE
	gen welfare=p_cons
	la var welfare "Welfare aggregate"

	gen welfarenom=.
	la var welfarenom "Welfare aggregate in nominal terms"

	gen welfaredef=p_cons
	la var welfaredef "Welfare aggregate spatially deflated"

	gen welfshprosperity=welfaredef
	la var welfshprosperity "Welfare aggregate for shared prosperity"

	gen welfaretype="CONS"
	la var welfaretype "Type of welfare measure (income, consumption or expenditure) for welfare, welfarenom, welfaredef"

	gen welfareother=p_income
	la var welfareother "Welfare Aggregate if different welfare type is used from welfare, welfarenom, welfaredef"

	gen welfareothertype="INC"
	la var welfareothertype "Type of welfare measure (income, consumption or expenditure) for welfareother"



/*****************************************************************************************************
*                                                                                                    *
                                   NATIONAL POVERTY
*                                                                                                    *
*****************************************************************************************************/


** POVERTY LINE (NATIONAL)
	gen pline_nat=zu10
	label variable pline_nat "Poverty Line (National)"


** HEADCOUNT RATIO (NATIONAL)
	gen poor_nat=welfare<pline_nat & welfare!=.
	la var poor_nat "People below Poverty Line (National)"
	la define poor_nat 0 "Not Poor" 1 "Poor"
	la values poor_nat poor_nat

/*****************************************************************************************************
*                                                                                                    *
                                   INTERNATIONAL POVERTY
*                                                                                                    *
*****************************************************************************************************/


	local year=2005
	
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
	gen pline_int=1.25*cpi*ppp*365/12
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

	keep countrycode year idh idp wgt strata psu vermast veralt urban int_month int_year region ///
	     subnatid1 subnatid2 subnatid3 ownhouse water electricity toilet landphone cellphone ///
	     computer internet hsize relationharm relationcs male age soc marital ed_mod_age everattend ///
	     atschool electricity literacy educy educat4 educat5 educat7 lb_mod_age lstatus empstat njobs ///
	     ocusec nlfreason unempldur_l unempldur_u industry occup firmsize_l firmsize_u whours wage ///
		 unitwage contract healthins socialsec union pline_nat pline_int poor_nat poor_int spdef cpi ppp ///
		 cpiperiod welfare welfarenom welfaredef welfareother welfaretype welfareothertype

** ORDER VARIABLES

	order countrycode year idh idp wgt strata psu vermast veralt urban int_month int_year region ///
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


	saveold "`output'\Data\Harmonized\BGD_2010_HIES_v01_M_v01_A_SARMD_IND.dta", replace version(13)
	saveold "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\__REGIONAL\Individual Files\BGD_2010_HIES_v01_M_v01_A_SARMD_IND.dta", replace version(13)

	log close




******************************  END OF DO-FILE  *****************************************************/
