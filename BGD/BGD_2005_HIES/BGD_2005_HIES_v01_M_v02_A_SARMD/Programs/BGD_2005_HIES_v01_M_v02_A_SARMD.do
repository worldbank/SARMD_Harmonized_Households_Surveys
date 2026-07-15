/*****************************************************************************************************
******************************************************************************************************
**                                                                                                  **
**                                   SOUTH ASIA MICRO DATABASE                                      **
**                                                                                                   **
** COUNTRY			Bangladesh
** COUNTRY ISO CODE	BGD
** YEAR				2005
** SURVEY NAME		HOUSEHOLD INCOME AND EXPENDITURE SURVEY-2005
** SURVEY AGENCY	BANGLADESH BUREAU OF STATISTICS
** RESPONSIBLE		Triana Yentzen
**
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
	local input "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\BGD\BGD_2005_HIES\BGD_2005_HIES_v01_M"
	local output "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\BGD\BGD_2005_HIES\BGD_2005_HIES_v01_M_v02_A_SARMD"

** LOG FILE
	log using "`output'\Doc\Technical\BGD_2005_HIES_v01_M_v02_A_SARMD.log",replace


/*****************************************************************************************************
*                                                                                                    *
                                   * ASSEMBLE DATABASE
*                                                                                                    *
*****************************************************************************************************/


	* PREPARE DATASETS

	use "`input'\Data\Stata\s5b.dta", clear
	duplicates drop

	merge 1:1 hhold idc as using "`input'\Data\Stata\s5a.dta"
	drop _merge

	* LABEL VARIABLES
	
	la var as "Activity serial"
	la var q01a_5a "Description of Activity"
	la var q01b_5a "Occupation code"
	la var q01c_5a "Industry code"
	la var q02_5a "Months worked 12mo"
	la var q03_5a "Days per month"
	la var q04_5a "Hours per day"
	la var q06_5a "Nature of activity"
	la var q07_5a "Work status agri"
	la var q08_5a "Work status non-agri"

	drop q05a_5a q05b_5a

	la var q01_5b "Daily basis payment"
	la var q02a_5b "Max. Daily wage"
	la var q02b_5b "Min. Daily wage"
	la var q02c_5b "Avg. Daily wage"
	la var q06_5b "Type of institution worked for"
	la var q07_5b "gross monthly remuneration"
	la var q08_5b "net monthly remuneration"

	drop q03_5b-q05b_5b q09_5b

	* Register number of jobs
	bys hhold idc: gen n=_n
	bys hhold idc: egen njobs=max(n)
	drop n

	* Keep Job that has the maximum time dedication
	bys hhold idc: egen max_month=max(q02_5a)
	bys hhold idc: egen max_days=max(q03_5a)
	bys hhold idc: egen max_hours=max(q04_5a)

	* Months
	duplicates tag hhold idc, gen (TAG)
	keep if TAG==0 | (TAG!=0 & q02_5a==max_month)

	* Days
	duplicates tag hhold idc, gen(TAG2)
	keep if TAG2==0 | (TAG2!=0 & q03_5a==max_days)

	*Hours
	duplicates tag hhold idc, gen(TAG3)
	keep if TAG3==0 | (TAG3!=0 & q04_5a==max_hours)

	drop TAG*
	drop max*

	* If both jobs have same time dedication, keep the highest paying job
	duplicates tag hhold idc, gen(TAG)

	gen WAGE=q02c_5b if q01_5b==1
	replace WAGE=q07_5b if q01_5b==2

	bys hhold idc: egen max_WAGE=max(WAGE)
	bys hhold idc:  gen n=_n

	drop if TAG==1 & max_WAGE==. & n==2
	keep if TAG==0 | (TAG==1 & (max_WAGE==q02c_5b | max_WAGE==q07_5b ) )

	drop TAG*

	duplicates tag hhold idc, gen(TAG)

	* If Time and Wage fail, keep most probable Activity
	drop if TAG==1 & (as=="D" | as=="C" )
	drop if hhold=="2960509168" & as=="B"

	drop TAG* max*
	
	order hhold idc
	sort hhold idc
	
	tempfile labor
	save `labor'
	

	use "`input'\Data\Stata\s1b.dta", clear

	la var hhold "Household Code"
	la var idc "Id code"
	la var q01_1b "Work 7ds"
	la var q02_1b "Available 7ds"
	la var q03_1b "Look for work 7ds"
	la var q04_1b "Reason not available/look"
	duplicates drop

	* Keep most complete history when duplicates exist
	duplicates tag hhold idc, gen(TAG)
	drop if TAG==1 & q04_1b==.
	drop TAG

	duplicates tag hhold idc, gen(TAG)
	bys hhold idc: egen pointer=max(q03_1b) if TAG==1
	bys hhold idc: gen n=_n if TAG==1

	drop if TAG==1 & ((pointer!=. & q03_1b==.)| (pointer==. & n==2))
	drop pointer TAG n

	tempfile employment
	save `employment'
	
	use "`input'\Data\Stata\consumption_00_05_10.dta", clear
	keep if year==2
	drop year stratum div
	ren id hhold
	sort hhold
	destring hhold, gen(HID)
	sort HID
	tempfile consumption
	save `consumption', replace


	use "`input'\Data\Stata\s0.dta", clear

	la var reg "Region"
	la var dis "District"
	la var tha "Thana"
	la var uni "Union/Ward"
	la var mau "Mautza/Mohalla"
	la var rmo "Rural (1,3), PSA(2), SMA(2,4)"

	drop fema inte
	tempfile initial
	save `initial'

	
	use "`input'\Data\Stata\s2.dta", clear

	drop q01_2-q05_2
	drop q08_2 q09_2 q16_2 q17_2 q19_2

	la var q06_2 "Type of latrine"
	la var q07_2 "Drinking water source"
	la var q10_2 "From where drinking water use"
	la var  q11_2 "Water for other use"
	la var  q12_2 "Connection of electricity"
	la var q13_2 "Connection of telephone"
	la var q14_2 "Connection of mobile phone"
	la var  q15_2 "Connection of computer"
	la var q18_2 "Ownership of the house"
	
	tempfile household
	save `household'
	
	use "`input'\Data\Stata\s3a.dta", clear

	la var q01_3a "Can read a letter"
	la var q02_3a "Can write a letter"
	la var q03_3a "Highest class completed"
	la var q04_3a "From where learnt"
	la var q05_3a "Type of school last attended"
	
	* Keep most complete history
	duplicates tag hhold idc, gen(TAG)
	bys hhold idc: egen pointer=max(q02_3a) if TAG==1
	bys hhold idc: gen n=_n if TAG==1
	drop if TAG==1 & ((pointer!=. & q02_3a==.)| (pointer==. & n==2))
	drop pointer TAG n
	duplicates drop

	tempfile education
	save `education'


	use "`input'\Data\Stata\s3b1.dta", clear

	la var q01_3b1 "Currently attending school"
	la var q02_3b1 "Class currently attending"

	drop q03_3b1-q07_3b1

	duplicates drop

	* Keep most complete history
	duplicates tag hhold idc, gen(TAG)
	bys hhold idc: egen pointer=max(q02_3b1) if TAG==1
	bys hhold idc: gen n=_n if TAG==1
	drop if TAG!=0 & q01_3b1==1 & age>=30 & age!=.
	drop pointer TAG n
	duplicates tag hhold idc, gen(TAG)
	bys hhold idc: egen pointer=max(q02_3b1) if TAG==1
	bys hhold idc: gen n=_n if TAG==1
	drop if TAG==1 & ((pointer!=. & q02_3b1==.)| (pointer==. & n==2))
	drop pointer TAG n
	duplicates tag hhold idc, gen(TAG)
	drop if TAG==1 & q02_3b1==16
	drop TAG
	
	tempfile education2
	save `education2'
	
	* MERGE DATASETS
	
	use "`input'\Data\Stata\s1a.dta", clear

	la var q01_1a "Name"
	la var q02_1a "Sex"
	la var q03_1a "Relationship with head"
	la var q04_1a "Age"
	la var q05_1a "Religion"
	la var q06_1a "Marital status"
	drop q07_1a-q10_1a

	order rec_type hhold idc

	
	merge 1:1 hhold idc using `labor'
	ren _merge mergelabor
	
	merge 1:1 hhold idc using `employment'
	ren _merge mergelabor2

	merge 1:1 hhold idc using `education'
	ren _merge mergeeducation
	
	merge 1:1 hhold idc using `education2'
	ren _merge mergeeducation2
	
	merge m:1 hhold using `household'
	ren _merge mergehousehold
	
	destring rmo,replace
	merge m:1 hhold using `initial'
	ren _merge mergeinitial
	
	destring hhold, gen(HID)
	sort HID

	merge m:1 HID using `consumption'
	ren _merge merge_cons

	drop if merge_cons==1
	drop if mergeeducation==2
	drop if mergeeducation2==2
	drop if mergelabor==2
	drop if mergelabor2==2
	
	drop merge* HID

/*****************************************************************************************************
*                                                                                                    *
                                   * STANDARD SURVEY MODULE
*                                                                                                    *
*****************************************************************************************************/

** COUNTRY
*<_countrycode_>
	gen str4 countrycode="BGD"
	label var countrycode "Country code"
*</_countrycode_>


** YEAR
*<_year_>
	gen int year=2005
	label var year "Year of survey"
*</_year_>

** SURVEY NAME 
*<_survey_>
	gen str survey="HIES"
	label var survey "Survey Acronym"
*</_survey_>



** INTERVIEW YEAR
*<_int_year_>
	gen byte int_year=.
	label var int_year "Year of the interview"
*</_int_year_>
	
	
** INTERVIEW MONTH
*<_int_month_>
	gen byte int_month=.
	la de lblint_month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
	label value int_month lblint_month
	label var int_month "Month of the interview"
*</_int_month_>


** HOUSEHOLD IDENTIFICATION NUMBER
*<_idh_>
	gen idh=hhold
	label var idh "Household id"
*</_idh_>


** INDIVIDUAL IDENTIFICATION NUMBER
*<_idp_>

	egen idp=concat(idh idc)
	label var idp "Individual id"
*</_idp_>


** HOUSEHOLD WEIGHTS
*<_wgt_>
	drop wgt
	gen wgt=wgt05
	label var wgt "Household sampling weight"
*</_wgt_>


** STRATA
*<_strata_>
	gen strata=strat05
	label var strata "Strata"
*</_strata_>

	drop psu

** PSU
*<_psu_>
	gen psu=substr(hhold,1,3)
	destring psu, replace
	label var psu "Primary sampling units"
*</_psu_>


** MASTER VERSION
*<_vermast_>

	gen vermast="02"
	label var vermast "Master Version"
*</_vermast_>
	
	
** ALTERATION VERSION
*<_veralt_>

	gen veralt="01"
	label var veralt "Alteration Version"
*</_veralt_>	
	
/*****************************************************************************************************
*                                                                                                    *
                                   HOUSEHOLD CHARACTERISTICS MODULE
*                                                                                                    *
*****************************************************************************************************/


** LOCATION (URBAN/RURAL)
*<_urban_>
	gen urban=urbrural
	recode urban (1=0) (2=1)
	label var urban "Urban/Rural"
	la de lblurban 1 "Urban" 0 "Rural"
	label values urban lblurban
*</_urban_>


** REGIONAL AREA 1 DIGIT ADMN LEVEL
*<_subnatid1_>
	recode reg (5 75 = 10) (7 15 25 46 65 84 = 20) (30 40 42 48 60 95 = 30) (45 50 55 = 40) (10 35 70 80 85=50) (90 = 60), gen(subnatid1)
	replace subnatid1=55 if dis==85 | dis==27 | dis==49 | dis==32 | dis==73 | dis==77 | dis==94 | dis==52
	la de lblsubnatid1 10 "Barisal" 20"Chittagong" 30"Dhaka" 40"Khulna" 50"Rajshahi" 55"Rangpur" 60"Sylhet"
	label var subnatid1 "Region at 1 digit (ADMN1)"
	label values subnatid1 lblsubnatid1
*</_subnatid1_>

** REGIONAL AREA 2 DIGIT ADMN LEVEL
*<_subnatid2_>
	gen subnatid2=dis
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
*</_subnatid2_>

	
** REGIONAL AREA 3 DIGIT ADMN LEVEL
*<_subnatid3_>
	gen byte subnatid3=.
	label var subnatid3 "Region at 3 digit (ADMN3)"
	label values subnatid3 lblsubnatid3
*</_subnatid3_>
	
	
** HOUSE OWNERSHIP
*<_ownhouse_>
	gen byte ownhouse=q18_2
	replace ownhouse=0 if  q18_2>1 &  q18_2<=6
	label var ownhouse "House ownership"
	la de lblownhouse 0 "No" 1 "Yes"
	label values ownhouse lblownhouse
*</_ownhouse_>

** WATER PUBLIC CONNECTION
*<_water_>
	gen byte water= (q07_2==1)
	label var water "Water main source"
	la de lblwater 0 "No" 1 "Yes"
	label values water lblwater
*</_water_>

** ELECTRICITY PUBLIC CONNECTION
*<_electricity_>

	gen byte electricity=q12_2
	recode electricity (2=0)
	label var electricity "Electricity main source"
	la de lblelectricity 0 "No" 1 "Yes"
	label values electricity lblelectricity
*</_electricity_>

** TOILET PUBLIC CONNECTION
*<_toilet_>

	gen byte toilet=q06_2
	recode toilet  2/6=0
	label var toilet "Toilet facility"
	la de lbltoilet 0 "No" 1 "Yes"
	label values toilet lbltoilet
*</_toilet_>


** LAND PHONE
*<_landphone_>

	gen byte landphone=q13_2
	recode landphone 2=0
	label var landphone "Phone availability"
	la de lbllandphone 0 "No" 1 "Yes"
	label values landphone lbllandphone
*</_landphone_>


** CEL PHONE
*<_cellphone_>

	gen byte cellphone=q14_2
	recode cellphone (2=0)
	label var cellphone "Cell phone"
	la de lblcellphone 0 "No" 1 "Yes"
	label values cellphone lblcellphone
*</_cellphone_>


** COMPUTER
*<_computer_>
	gen byte computer= q15_2
	recode computer (2=0)
	label var computer "Computer availability"
	la de lblcomputer 0 "No" 1 "Yes"
	label values computer lblcomputer
*</_computer_>


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
*<_hsize_>

	ren q03_1a RELATION
	bys idh: egen hsize=count(year)
	label var hsize "Household size"
*</_hsize_>


** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
*<_relationharm_>

	* Fix relationship variable
	gen head=RELATION==1
	bys idh: egen heads=total(head)
	destring idc, gen(temp)
	replace RELATION=1 if heads==0 &temp==1
	drop head heads
	gen head=RELATION==1
	bys idh: egen heads=total(head)
	replace RELATION=1 if RELATION==2 & heads==0
	drop heads head temp
	
	gen byte relationharm=RELATION
	recode relationharm  (6=4) (4 5 7 8 9  10 11=5) (12 13 14 = 6)
	label var relationharm "Relationship to the head of household"
	la de lblrelationharm  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Non-relatives"
	label values relationharm  lblrelationharm
*</_relationharm_>

** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
*<_relationcs_>

	gen byte relationcs=RELATION
	la var relationcs "Relationship to the head of household country/region specific"
	label define lblrelationcs 1 "Head" 2 "Husband/Wife" 3 "Son/Daughter" 4 "Spouse of Son/Daughter" 5 "Grandchild" 6 "Father/Mother" 7 "Brother/Sister" 8 "Niece/Nephew" 9 "Father/Mother-in-law" 10 "Brother/Sister-in-law" 11 "Other relative" 12 "Servant" 13 "Employee" 14 "Other"
	label values relationcs lblrelationcs
*</_relationcs_>


** GENDER
*<_male_>
	gen byte male=q02_1a
	recode male (2=0)
	label var male "Sex of household member"
	la de lblmale 1 "Male" 0 "Female"
	label values male lblmale
*</_male_>

	ren age AGE

** AGE
*<_age_>
	gen byte age= q04_1a
	label var age "Age of individual"
*</_age_>


** SOCIAL GROUP
*<_soc_>
	gen byte soc=q05_1a
	label var soc "Social group"
	la de lblsoc 1 "Islam" 2 "Hinduism" 3 "Buddhism" 4 "Christianity" 5 "Other"
	label values soc lblsoc
*</_soc_>


** MARITAL STATUS
*<_marital_>
	gen byte marital=q06_1a
	recode marital 0=. 1=1 4/5=4 3=5 2=2
	label var marital "Marital status"
	la de lblmarital 1 "Married" 2 "Never Married" 3 "Living Together" 4 "Divorced/separated" 5 "Widowed"
	label values marital lblmarital
*</_marital_>


/*****************************************************************************************************
*                                                                                                    *
                                   EDUCATION MODULE
*                                                                                                    *
*****************************************************************************************************/


** EDUCATION MODULE AGE
*<_ed_mod_age_>
	gen byte ed_mod_age=5
	label var ed_mod_age "Education module application age"
*</_ed_mod_age_>

	ren q01_3b1 CURRENT_ATTEND
	recode CURRENT_ATTEND 2=0

** CURRENTLY AT SCHOOL
*<_atschool_>
	gen byte atschool=CURRENT_ATTEND 
	replace atschool =. if  age<5
	label var atschool "Attending school"
	la de lblatschool 0 "No" 1 "Yes"
	label values atschool  lblatschool
*</_atschool_>


** CAN READ AND WRITE
*<_literacy_>
	gen byte literacy=1 if q01_3a==1 & q02_3a==1
	replace literacy=0 if literacy!=1 & (q01_3a!=.  | q02_3a!=.)
	replace literacy =. if  age<5
	label var literacy "Can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy
*</_literacy_>


** YEARS OF EDUCATION COMPLETED
*<_educy_>
	recode q02_3b1 (11 = 12) (12 = 16) (13 = 18 ) (14 = 19) (15 = 17) (16 =.)
	gen byte educy=q03_3a
	recode educy (11 = 12) (12 = 16) (13 = 18 ) (14 = 19) (15 = 17) (16 =.)
	replace educy=q02_3b1 if educy==. & q02_3b1!=.
	replace educy=educy-1 if  q02_3b1!=. & q03_3a==.
	replace educy=0 if educy==-1
	replace educy=. if age<5
	label var educy "Years of education"
*</_educy_>


** EDUCATION LEVEL 7 CATEGORIES
*<_educat7_>
	gen byte educat7=.
	replace educat7=1 if educy==0
	replace educat7=2 if (educy>0 & educy<5)
	replace educat7=3 if (educy==5)
	replace educat7=4 if (educy>5 & educy<12)
	replace educat7=5 if (educy==12)
	replace educat7=7 if (educy>12 & educy<23)
	replace educat7=. if age<5
	label define lbleducat7 1 "No education" 2 "Primary incomplete" 3 "Primary complete" ///
	4 "Secondary incomplete" 5 "Secondary complete" 6 "Higher than secondary but not university" /// 
	7 "University incomplete or complete" 8 "Other" 9 "Not classified"
	label values educat7 lbleducat7
	la var educat7 "Level of education 7 categories"
*</_educat7_>



** EDUCATION LEVEL 4 CATEGORIES
*<_educat4_>
	gen byte educat4=.
	replace educat4=1 if educat7==1 
	replace educat4=2 if educat7==2 |educat7==3
	replace educat4=3 if educat7==4 |educat7==5
	replace educat4=4 if educat7==6 | educat7==7
	label var educat4 "Level of education 4 categories"
	label define lbleducat4 1 "No education" 2 "Primary (complete or incomplete)" ///
	3 "Secondary (complete or incomplete)" 4 "Tertiary (complete or incomplete)"
	label values educat4 lbleducat4
*</_educat4_>



** EDUCATION LEVEL 5 CATEGORIES
*<_educat5_>
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
*</_educat5_>

	la var educat5 "Level of education 5 categories"


	
** EVER ATTENDED SCHOOL
*<_everattend_>
	gen byte everattend=.
	replace everattend=0 if educat7==1
	replace everattend=1 if educat7>=2 | atschool==1
	replace everattend=. if age<5
	label var everattend "Ever attended school"
	la de lbleverattend 0 "No" 1 "Yes"
	label values everattend lbleverattend
*</_everattend_>

	replace educy=0 if everattend==0
	replace educat7=1 if everattend==0
	replace educat4=1 if everattend==0


/*****************************************************************************************************
*                                                                                                    *
                                   LABOR MODULE
*                                                                                                    *
*****************************************************************************************************/


** LABOR MODULE AGE
*<_lb_mod_age_>

 gen byte lb_mod_age=5
	label var lb_mod_age "Labor module application age"
*</_lb_mod_age_>



** LABOR STATUS
*<_lstatus_>
	gen byte lstatus=q01_1b
	replace lstatus=2 if lstatus!=1 &( (q01_1b==2 &q03_1b==1 & q02_1b==1) | (q02_1b==2 & q03_1b==.))
	replace lstatus=3 if q02_1b==2 | q03_1b==2
	replace lstatus=2 if lstatus==3 & (q04_1b==8 | q04_1b==8)
	replace lstatus=. if age<lb_mod_age
	replace lstatus=. if age<lb_mod_age
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus
*</_lstatus_>



** EMPLOYMENT STATUS
*<_empstat_>
	gen byte empstat=q07_5a if q06_5a==1
	replace empstat=q08_5a if q06_5a==2
	recode empstat (1 4 = 1) (2 = 4) (3 = 3)
	replace empstat=. if lstatus==2| lstatus==3
	label var empstat "Employment status"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other"
	label values empstat lblempstat
*</_empstat_>


** SECTOR OF ACTIVITY: PUBLIC - PRIVATE
*<_njobs_>

	label var njobs "Number of additional jobs"
*</_njobs_>

	ren q06_5b OCUSEC

** SECTOR OF ACTIVITY: PUBLIC - PRIVATE
*<_ocusec_>
	gen ocusec=OCUSEC
	recode ocusec (1 2 4 6 7 = 1) (3 5 8 9= 2)(0=.)
	replace ocusec=. if lstatus==2| lstatus==3
	label var ocusec "Sector of activity"
	la de lblocusec 1 "Public, state owned, government, army, NGO" 2 "Private"
	label values ocusec lblocusec
*</_ocusec_>

	rename q04_1b WHYINACTIVE

** REASONS NOT IN THE LABOR FORCE
*<_nlfreason_>
	gen byte nlfreason=WHYINACTIVE
	recode nlfreason (3=1) (2=2) (4=3) (7=4) (1 5 6 8 9 10 = 5)
	replace nlfreason=. if lstatus!=3
	label var nlfreason "Reason not in the labor force"
	la de lblnlfreason 1 "Student" 2 "Housewife" 3 "Retired" 4 "Disable" 5 "Other"
	label values nlfreason lblnlfreason
*</_nlfreason_>

** UNEMPLOYMENT DURATION: MONTHS LOOKING FOR A JOB
*<_unempldur_l_>
	gen byte unempldur_l=.
	label var unempldur_l "Unemployment duration (months) lower bracket"
*</_unempldur_l_>

*<_unempldur_u_>

	gen byte unempldur_u=.
	label var unempldur_u "Unemployment duration (months) upper bracket"
*</_unempldur_u_>

** INDUSTRY CLASSIFICATION
*<_industry_>
	gen byte industry=q01c_5a
	recode industry (1/5=1) (10/14=2) (15/37=3) (40/43=4) (45=5) (50/59=6) (60/64=7) (65/74=8) (75=9) (76/99=10)

	label var industry "1 digit industry classification"
	replace industry=. if lstatus==2| lstatus==3
	la de lblindustry 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transports and comnunications" 8 "Financial and business-oriented services" 9 "Public Administration" 10 "Other services, Unspecified"
	label values industry lblindustry
*</_industry_>


** OCCUPATION CLASSIFICATION
*<_occup_>

	gen occup= 1 if  inrange(q01b_5a,20,30) | q01b_5a==40
	replace occup= 2 if  inlist(q01b_5a,2,4,6) |inrange(q01b_5a,8,13)|inrange(q01b_5a,15,19)
	replace occup= 3 if  inlist(q01b_5a,1,3,5,7,14)
	replace occup= 4 if  inrange(q01b_5a,31,33) | q01b_5a==39
	replace occup= 5 if  inrange(q01b_5a,50,59)
	replace occup=6 if  inrange(q01b_5a,60,66)
	replace occup=7 if  inrange(q01b_5a,40,46) | q01b_5a==49
	replace occup=8 if  inrange(q01b_5a,34,38) |inrange(q01b_5a,70,86)
	replace occup=9 if  inrange(q01b_5a,87,99)

	replace occup=. if lstatus==2| lstatus==3
	label var occup "1 digit occupational classification"
	la de lbloccup 1 "Senior officials" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup lbloccup
*</_occup_>


** FIRM SIZE
*<_firmsize_l_>
	gen byte firmsize_l=.
	label var firmsize_l "Firm size (lower bracket)"
*</_firmsize_l_>

*<_firmsize_u_>

	gen byte firmsize_u=.
	label var firmsize_u "Firm size (upper bracket)"

*</_firmsize_u_>


** HOURS WORKED LAST WEEK
*<_whours_>
	gen whours=int(q04_5a*q03_5a)/4.25
	replace whours=. if lstatus==2| lstatus==3
	label var whours "Hours of work in last week"
*</_whours_>


** WAGES
*<_wage_>
	gen double wage=WAGE


	replace wage=. if lstatus!=1
	replace wage=0 if empstat==2
	label var wage "Last wage payment"
*</_wage_>


** WAGES TIME UNIT
*<_unitwage_>
	gen byte unitwage=.
	replace unitwage=1 if q01_5b==1
	replace unitwage=5 if q01_5b==2
	replace unitwage=. if lstatus!=1
	label var unitwage "Last wages time unit"
	la de lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Quarterly" 7 "Biannual" 8 "Annually" 9 "Hourly" 10 "Other"
	label values unitwage lblunitwage
*</_wageunit_>


** CONTRACT
*<_contract_>
	gen byte contract=.
	label var contract "Contract"
	la de lblcontract 0 "Without contract" 1 "With contract"
	label values contract lblcontract
*</_contract_>


** HEALTH INSURANCE
*<_healthins_>
	gen byte healthins=.
	label var healthins "Health insurance"
	la de lblhealthins 0 "Without health insurance" 1 "With health insurance"
	label values healthins lblhealthins
*</_healthins_>


** SOCIAL SECURITY
*<_socialsec_>
	gen byte socialsec=.
	label var socialsec "Social security"
	la de lblsocialsec 1 "With" 0 "Without"
	label values socialsec lblsocialsec
*</_socialsec_>


** UNION MEMBERSHIP
*<_union_>
	gen byte union=.
	label var union "Union membership"
	la de lblunion 0 "No member" 1 "Member"
	label values union lblunion
*</_union_>


/*****************************************************************************************************
*                                                                                                    *
                                   WELFARE MODULE
*                                                                                                    *
*****************************************************************************************************/


** SPATIAL DEFLATOR
*<_spdef_>
	gen spdef=zu05
	la var spdef "Spatial deflator"
*</_spdef_>


** WELFARE
*<_welfare_>
	gen welfare=pcexp
	la var welfare "Welfare aggregate"
*</_welfare_>

*<_welfarenom_>
	gen welfarenom=pcexp
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
	gen welfareothertype=" "
	la var welfareothertype "Type of welfare measure (income, consumption or expenditure) for welfareother"
*</_welfareothertype_>

*<_welfarenat_>
	gen welfarenat=welfare
	la var welfarenat "Welfare aggregate for national poverty"
*</_welfarenat_>	
/*****************************************************************************************************
*                                                                                                    *
                                   NATIONAL POVERTY
*                                                                                                    *
*****************************************************************************************************/


** POVERTY LINE (NATIONAL)
*<_pline_nat_>
	gen pline_nat=zu05
	label variable pline_nat "Poverty Line (National)"
*</_pline_nat_>


** HEADCOUNT
	gen poor_nat=welfarenat<pline_nat & welfare!=.
	la var poor_nat "People below Poverty Line (National)"
	la define poor_nat 0 "Not Poor" 1 "Poor" 
	la values poor_nat poor_nat
*</_poor_nat_>

	
/*****************************************************************************************************
*                                                                                                    *
                                   INTERNATIONAL POVERTY
*                                                                                                    *
*****************************************************************************************************/


	local year=2005
	
** USE SARMD CPI AND PPP
*<_cpi_>
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
*</_cpi_>
	
	
** PPP VARIABLE
*<_ppp_>
	ren ppp`year' 	ppp
	label variable ppp "PPP `year'"
*</_ppp_>

	
** CPI PERIOD
*<_cpiperiod_>
	gen cpiperiod=syear
	label var cpiperiod "Periodicity of CPI (year, year&month, year&quarter, weighted)"
*</_cpiperiod_>	
	
** POVERTY LINE (POVCALNET)
*<_pline_int_>
	gen pline_int=1.25*cpi*ppp*365/12
	label variable pline_int "Poverty Line (Povcalnet)"
*</_pline_int_>
	
	
** HEADCOUNT RATIO (POVCALNET)
*<_poor_int_>
	gen poor_int=welfare<pline_int & welfare!=.
	la var poor_int "People below Poverty Line (Povcalnet)"
	la define poor_int 0 "Not Poor" 1 "Poor"
	la values poor_int poor_int
*</_poor_int_>

/*****************************************************************************************************
*                                                                                                    *
                                   FINAL STEPS
*                                                                                                    *
*****************************************************************************************************/


** KEEP VARIABLES - ALL

	keep countrycode year survey idh idp wgt strata psu vermast veralt urban int_month int_year ///	     
		subnatid1 subnatid2 subnatid3 ownhouse water electricity toilet landphone cellphone ///
		 computer internet hsize relationharm relationcs male age soc marital ed_mod_age everattend ///
	     atschool electricity literacy educy educat4 educat5 educat7 lb_mod_age lstatus empstat njobs ///
	     ocusec nlfreason unempldur_l unempldur_u industry occup firmsize_l firmsize_u whours wage ///
		 unitwage contract healthins socialsec union pline_nat pline_int poor_nat poor_int spdef cpi ppp ///
		 cpiperiod welfare welfarenom welfaredef welfarenat welfareother welfaretype welfareothertype

** ORDER VARIABLES

	order countrycode year idh idp wgt strata psu vermast veralt urban int_month int_year ///
	      subnatid1 subnatid2 subnatid3 ownhouse water electricity toilet landphone cellphone ///
	      computer internet hsize relationharm relationcs male age soc marital ed_mod_age everattend ///
	      atschool electricity literacy educy educat4 educat5 educat7 lb_mod_age lstatus empstat njobs ///
	      ocusec nlfreason unempldur_l unempldur_u industry occup firmsize_l firmsize_u whours wage ///
		 unitwage contract healthins socialsec union pline_nat pline_int poor_nat poor_int spdef cpi ppp ///
		 cpiperiod welfare welfarenom welfaredef welfarenat welfareother welfaretype welfareothertype
	
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



	saveold "`output'\Data\Harmonized\BGD_2005_HIES_v01_M_v02_A_SARMD_IND.dta", replace
	saveold "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\__REGIONAL\Individual Files\BGD_2005_HIES_v01_M_v02_A_SARMD_IND.dta", replace

	log close




******************************  END OF DO-FILE  *****************************************************/
