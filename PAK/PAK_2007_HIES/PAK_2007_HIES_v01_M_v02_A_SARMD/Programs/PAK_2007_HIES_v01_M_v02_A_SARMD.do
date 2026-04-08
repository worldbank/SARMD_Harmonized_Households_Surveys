/*****************************************************************************************************
******************************************************************************************************
**                                                                                                  **
**                                   SOUTH ASIA MICRO DATABASE                                      **
**                                                                                                  **
** COUNTRY			Pakistan
** COUNTRY ISO CODE	PAK
** YEAR				2007
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
	local input "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\PAK\PAK_2007_PSLM\PAK_2007_PSLM_v01_M"
	local output "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\PAK\PAK_2007_PSLM\PAK_2007_PSLM_v01_M_v02_A_SARMD"

** LOG FILE
	log using "`output'\Doc\Technical\PAK_2007_PSLM_v01_M_v02_A_SARMD.log",replace



/*****************************************************************************************************
*                                                                                                    *
                                   * ASSEMBLE DATABASE
*                                                                                                    *
*****************************************************************************************************/


** DATABASE ASSEMBLENT


	tempfile aux

	use "`input'\Data\Stata\psm4-01A", clear
	gen str2 stra1 = string(a02c,"%02.0f")
	gen str2 stra2 = string(a02d,"%1.0f")
	gen str2 stra3 = string(a03,"%02.0f")
	egen psucode = concat(a02a a02b stra1 stra2)
	destring psucode, replace force
	format psucode %14.0f

	egen hhcode = concat(a02a a02b stra1 stra2 stra3)
	destring hhcode, replace force
	format hhcode %16.0f
	duplicates report hhcode 
	isid hhcode sno 
	ren hhcode HID
	format HID %12.0f
	save `aux', replace


/*
Employment and Income
*/
	use "`input'\Data\Stata\psm4-01B", clear
	gen str2 stra1 = string(a02c,"%02.0f")
	gen str2 stra2 = string(a02d,"%1.0f")
	gen str2 stra3 = string(a03,"%02.0f")
	egen psucode = concat(a02a a02b stra1 stra2)
	destring psucode, replace force
	format psucode %14.0f

	egen hhcode = concat(a02a a02b stra1 stra2 stra3)
	destring hhcode, replace force
	format hhcode %16.0f
	duplicates report hhcode 
	isid hhcode sno 
	ren hhcode HID
	format HID %12.0f

	merge 1:1 HID sno using `aux'
	tab _merge


	drop _merge
	save `aux', replace


/*
Literacy and Formal Education
*/
	use "`input'\Data\Stata\psm4-02A", clear
	gen str2 stra1 = string(a02c,"%02.0f")
	gen str2 stra2 = string(a02d,"%1.0f")
	gen str2 stra3 = string(a03,"%02.0f")
	egen psucode = concat(a02a a02b stra1 stra2)
	destring psucode, replace force
	format psucode %14.0f

	egen hhcode = concat(a02a a02b stra1 stra2 stra3)
	destring hhcode, replace force
	format hhcode %16.0f
	duplicates report hhcode 
	isid hhcode sno 
	ren hhcode HID
	format HID %12.0f

	merge 1:1 HID sno using `aux'
	tab _merge

	drop _merge
	save `aux', replace


/*
Health - Diarre (to obtain child under 5 ID)
*/
	use "`input'\Data\Stata\psm4-03A", clear
	gen str2 stra1 = string(a02c,"%02.0f")
	gen str2 stra2 = string(a02d,"%1.0f")
	gen str2 stra3 = string(a03,"%02.0f")
	egen psucode = concat(a02a a02b stra1 stra2)
	destring psucode, replace force
	format psucode %14.0f

	egen hhcode = concat(a02a a02b stra1 stra2 stra3)
	destring hhcode, replace force
	format hhcode %16.0f
	duplicates report hhcode 
	isid hhcode sno 
	ren hhcode HID
	format HID %12.0f

	merge 1:1 HID sno using `aux'
	tab _merge

/*
22 obs deleted
*/
	drop _merge
	save `aux', replace
	isid HID sno


/*
Survey information variables
*/
	use "`input'\Data\Stata\psm4-00A", clear
	gen str2 stra1 = string(a02c,"%02.0f")
	gen str2 stra2 = string(a02d,"%1.0f")
	gen str2 stra3 = string(a03,"%02.0f")
	egen psucode = concat(a02a a02b stra1 stra2)
	destring psucode, replace force
	format psucode %14.0f

	egen hhcode = concat(a02a a02b stra1 stra2 stra3)
	destring hhcode, replace force
	format hhcode %16.0f
	duplicates report hhcode 
	isid hhcode sno 

/*
For the survey information variables, as there was no way to determine which serial number (variable “sno”) went with the female questionnaires and which went with the male questionnaires, only those observations with serial number equal to “0” were retained and applied to both the male and female questions. (Source: "D:\__I2D2\Pakistan\2007\PSLM\Original\Reports\README_PAK_PSLM_0708.pdf")
*/
	keep if sno==0
	drop sno
	ren hhcode HID
	format HID %12.0f
	sort HID

	merge 1:m HID using `aux'
	tab _merge

/*
0 obs deleted
*/
	drop _merge
	save `aux', replace


/*
Housing
*/
	use "`input'\Data\Stata\psm4-05A", clear
	gen str2 stra1 = string(a02c,"%02.0f")
	gen str2 stra2 = string(a02d,"%1.0f")
	gen str2 stra3 = string(a03,"%02.0f")
	egen psucode = concat(a02a a02b stra1 stra2)
	destring psucode, replace force
	format psucode %14.0f
	drop sno
	egen hhcode = concat(a02a a02b stra1 stra2 stra3)
	destring hhcode, replace force
	format hhcode %16.0f
	duplicates report hhcode 
	ren hhcode HID
	format HID %12.0f
	sort HID

	merge 1:m HID using `aux'
	tab _merge

/*
0 obs deleted
*/
	drop if _merge==1
	drop _merge
	save `aux', replace




/*
Consumption
*/
	use "`input'\Data\Stata\psm4-05A", clear
	gen str2 stra1 = string(a02c,"%02.0f")
	gen str2 stra2 = string(a02d,"%1.0f")
	gen str2 stra3 = string(a03,"%02.0f")
	egen psucode = concat(a02a a02b stra1 stra2)
	destring psucode, replace force
	format psucode %14.0f

	egen hhcode = concat(a02a a02b stra1 stra2 stra3)
	destring hhcode, replace force
	format hhcode %16.0f
	duplicates report hhcode 
	ren hhcode HID
	format HID %12.0f
	sort HID
	drop sno
	merge 1:m HID using `aux'
	tab _merge

/*
0 obs deleted
*/
	drop _merge
	save `aux', replace




/*
Selected durable goods
*/
	/*use "`input'\Data\Stata\psm4-07A", clear
	gen str2 stra1 = string(a02c,"%02.0f")
	gen str2 stra2 = string(a02d,"%1.0f")
	gen str2 stra3 = string(a03,"%02.0f")
	egen psucode = concat(a02a a02b stra1 stra2)
	destring psucode, replace force
	format psucode %14.0f

	egen hhcode = concat(a02a a02b stra1 stra2 stra3)
	destring hhcode, replace force
	format hhcode %16.0fdistin
	duplicates report hhcode 
	ren hhcode HID
	format HID %12.0f
	sort HID
	drop sno
	merge 1:m HID using `aux'
	tab _merge
	drop _merge
	save `aux', replace*/


/*
Consumption. 
*/
		use "`input'\Data\Stata\Consumption Master File with CPI.dta"
	tempfile comp
	keep if year==2007
	keep hhcode nomexpend hhsizeM eqadultM peaexpM psupind new_pline texpend region weight
	save  `comp' , replace

	use `aux', clear
	ren HID hhcode
	merge m:1 hhcode using `comp'
	tab _merge
	drop _merge

	ren hhcode HID

	
/*****************************************************************************************************
*                                                                                                    *
                                   * STANDARD SURVEY MODULE
*                                                                                                    *
*****************************************************************************************************/

	
** COUNTRY
*<_countrycode_>
	gen str4 countrycode="PAK"
	label var countrycode "Country code"
*</_countrycode_>


** YEAR

*<_year_>
	gen int year=2007
	label var year "Year of survey"
*</_year_> 


* Clean imposibble survey years
	replace a0m12=. if a0y12<2007
	replace a0y12=. if a0y12<2007
*	replace a0m12=. if a0m12<7  & a0y12==2007 & a0m12!=.
*	replace a0m12=. if a0m12>=7 & a0y12==2008 & a0m12!=.

	
** INTERVIEW YEAR
	gen int_year=a0y12
	label var int_year "Year of the interview"
*</_int_year_>

	
** INTERVIEW MONTH
	gen int_month=a0m12
	la de lblint_month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
	label value int_month lblint_month
	label var int_month "Month of the interview"
*</_int_month_>
	
	
** HOUSEHOLD IDENTIFICATION NUMBER
*<_idh_>
	gen double idh=HID
	label var idh "Household id"


** INDIVIDUAL IDENTIFICATION NUMBER
*<_idp_>

	gen double idp_=idh*100+sno
	tostring idh, replace
	gen idp=string(idp_,"%14.0g")
	label var idp "Individual id"
*</_idp_>


** HOUSEHOLD WEIGHTS
*<_wgt_>
	gen double wgt=weight
	label var wgt "Household sampling weight"
*</_wgt_>


** STRATA
*<_strata_>


/*
Variable is available but there is no clear info about what variable should be used.
*/
	gen strata=.
	label var strata "Strata"
*</_strata_>


** PSU
*<_psu_>
	gen psu=psucode
	label var psu "Primary sampling units"
*</_psu_>

	
** MASTER VERSION
*<_vermast_>

	gen vermast="01"
	label var vermast "Master Version"
*</_vermast_>
	
	
** ALTERATION VERSION
*<_veralt_>

	gen veralt="02"
	label var veralt "Alteration Version"
*</_veralt_>	
	
/*****************************************************************************************************
*                                                                                                    *
                                   HOUSEHOLD CHARACTERISTICS MODULE
*                                                                                                    *
*****************************************************************************************************/


** LOCATION (URBAN/RURAL)
*<_urban_>
/*
Checked replicating data 
*/
	gen byte urban=a02b
	recode urban (2=0)
	label var urban "Urban/Rural"
	la de lblurban 1 "Urban" 0 "Rural"
	label values urban lblurban
*</_urban_>


** REGIONAL AREA 1 DIGIT ADMN LEVEL
*<_subnatid1_>
	gen byte subnatid1=.
	label var subnatid1 "Region at 1 digit (ADMN1)"


** REGIONAL AREA 2 DIGIT ADMN LEVEL
*<_subnatid2_>
	gen byte subnatid2=pv
	la de lblsubnatid2 1 "Punjab" 2 "Sindh" 3 "Khyber Pakhtunkhwa" 4 "Balochistan"
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

/* Original Question
What is your present tenurial status?
RENTER .............. 1
OWNER ............... 2 (5)
PROVIDED FREE OF CHARGE
BY RELATIVES, EMPLOYER
OR LANDLORD ........ 3 (5)
OTHER ............... 4 (5)
*/
	gen byte ownhouse=1 if a0502==1 | a0502==2
	replace ownhouse = 0 if a0502!=. & ownhouse==.
	label var ownhouse "House ownership"
	la de lblownhouse 0 "No" 1 "Yes"
	label values ownhouse lblownhouse
*</_ownhouse_>

** WATER PUBLIC CONNECTION
*<_water_>
	gen byte water=1 if a0505==1
	replace water=0 if a0505!=. & a0505!=1
	label var water "Water main source"
	la de lblwater 0 "No" 1 "Yes"
	label values water lblwater
*</_water_>
** ELECTRICITY PUBLIC CONNECTION
*<_electricity_>

	gen byte electricity=1 if a0541==3 | a0541==2
	replace electricity=0 if a0541==1
	label var electricity "Electricity main source"
	la de lblelectricity 0 "No" 1 "Yes"
	label values electricity lblelectricity
*</_electricity_>

** TOILET PUBLIC CONNECTION
*<_toilet_>

	gen byte toilet=1 if a0514==1
	replace toilet=0 if a0514!=1 & a0514!=.
	la de lbltoilet 0 "No" 1 "Yes"
	label values toilet lbltoilet
*</_toilet_>


** LAND PHONE
*<_landphone_>

	gen byte landphone=1 if a0543==1 | a0543==2
	replace landphone=0 if a0543==3
	label var landphone "Phone availability"
	la de lbllandphone 0 "No" 1 "Yes"
	label values landphone lbllandphone
*</_landphone_>


** CEL PHONE
*<_cellphone_>

	gen byte cellphone=.
	label var cellphone "Cell phone"
	la de lblcellphone 0 "No" 1 "Yes"
	label values cellphone lblcellphone
*</_cellphone_>


** COMPUTER
*<_computer_>
	gen byte computer=.
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

	gen byte hsize=hhsizeM
	la var hsize "Household size"
*</_hsize_>


** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
*<_relationharm_>
	gen byte relationharm=a0102
	recode relationharm (4 6 7 8 9 10=5) (5=4) (11 12 = 6)
	* Add household head to households without head
	* If there's a male with serial number 1, select as head
	gen x=1 if relationharm==1
	egen y=sum(x), by(idh)
	replace relationharm=1 if y==0 & sno==1
	drop x y
	gen x=1 if relationharm==1
	egen y=sum(x), by(idh)
	* If there's no male with serial number 1, select female with serial number 1 (51)
	replace relationharm=1 if y==0 & sno==51
	drop x y
	gen x=1 if relationharm==1
	egen y=sum(x), by(idh)
	* Remove household heads to households with more than 1 head
	* Recode as other members individuals that don't have first serial number for either female or male
	replace relationharm=5 if y!=1 & relationharm==1 & sno!=1 & sno!=51
	drop x y 
	gen x=1 if relationharm==1
	egen y=sum(x), by(idh)
	* If household has both male and female head, select only male.
	replace relationharm=5 if relationharm==1 & sno!=1 & y!=1
	drop x y
	gen x=1 if relationharm==1
	egen y=sum(x), by(idh)
	label var relationharm "Relationship to the head of household"
	la de lblrelationharm  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Non-relatives"
	label values relationharm  lblrelationharm
*</_relationharm_>

** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
*<_relationcs_>

	gen byte relationcs=a0102
	la var relationcs "Relationship to the head of household country/region specific"
	label define lblrelationcs 1 "Head" 2 "Spouse" 3 "Son/Daughter" 4 "Grandchild" 5 "Father/Mother" 6 "Brother/Sister" 7  "Nephew/Niece" 8 "Son/Daughter-in-law" 9 "Brother/Sister-in-law" 10 "Father/Mother-in-law" 11 "Servant/their relatives" 12 "Other"
	label values relationcs lblrelationcs
*</_relationcs_>


** GENDER
*<_male_>
	gen byte male=a0103
	recode male (2=0)
	label var male "Sex of household member"
	la de lblmale 1 "Male" 0 "Female"
	label values male lblmale
*</_male_>

	
** AGE
*<_age_>
	gen byte age=a0105
	label var age "Age of individual"
*</_age_>


** SOCIAL GROUP
*<_soc_>

/*
Could the language of the interview used as soc?
*/
	gen byte soc=.
	label var soc "Social group"
	la de lblsoc 1 "Muslim" 2 "Christian" 3 "Others"
	label values soc lblsoc
*</_soc_>


** MARITAL STATUS
*<_marital_>
	gen byte marital=1 if a0106==2 | a0106==5
	replace marital=4 if a0106==4
	replace marital=5 if a0106==3
	replace marital=2 if a0106==1
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
	gen byte ed_mod_age=4
	label var ed_mod_age "Education module application age"
*</_ed_mod_age_>


** CURRENTLY AT SCHOOL
*<_atschool_>
	gen byte atschool=1 if b0201==3
	replace atschool=0 if b0201==1 | b0201==2
	replace atschool=. if age<ed_mod_age & age!=.
	label var atschool "Attending school"
	la de lblatschool 0 "No" 1 "Yes"
	label values atschool  lblatschool
*</_atschool_>


** CAN READ AND WRITE
*<_literacy_>

/*
Literacy rate is asked only to individuals 10 years and older.
*/
	gen byte literacy=1 if a0201==1 & a0202==1
	replace literacy=0 if a0201==2 | a0202==2
	replace literacy=. if age<ed_mod_age & age!=.
	label var literacy "Can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy
*</_literacy_>


** YEARS OF EDUCATION COMPLETED
*<_educy_>
	gen byte educy=b0205
	replace educy=13 if b0205==17 /* Diploma */
	replace educy=15 if b0205==14 /* BA/BSc */
	replace educy=16 if b0205==18 /* Engineer */
	replace educy=17 if b0205==19 /* Medicine */
	replace educy=16 if b0205==20 /* Agriculture */
	replace educy=16 if b0205==21 /* Law */
	replace educy=16 if b0205==16 /* MA/MSc */
	replace educy=19 if b0205==22 /* MPhl/PhD */
	replace educy=. if b0205==23 /* Others */
/*
CHECK!! Source: "http://www-db.in.tum.de/teaching/ws1112/hsufg/Taxila/Site/formal.html"
*/
	replace educy=max(b0214-1,0) if educy==. & b0214<=13
	replace educy=13 if b0214==14 & b0205==.
	replace educy=13 if b0214==15 & b0205==.
	replace educy=14 if b0214==16 & b0205==.
	replace educy=12 if b0214==17 & b0205==.
	replace educy=14 if b0214==18 & b0205==.
	replace educy=15 if b0214==19 & b0205==.
	replace educy=14 if b0214==20 & b0205==.
	replace educy=14 if b0214==21 & b0205==.
	replace educy=17 if b0214==22 & b0205==.
	replace educy=.  if b0214==23 & b0205==.
	replace educy=. if age<ed_mod_age & age!=.
	label var educy "Years of education"
*</_educy_>
	replace educy=. if educy>age & age!=. & educy!=.


** EDUCATION LEVEL 7 CATEGORIES
*<_educat7_>
	gen byte educat7=1 if educy==0
	replace educat7=2 if educy >0 & educy<8
	replace educat7=3 if educy==8
	replace educat7=4 if educy>8 &  educy<12
	replace educat7=5 if educy==12
	replace educat7=7 if educy>12 & educy<=22
	replace educat7=6 if b0205==17
	replace educat7=2 if b0214==1
	replace educat7=. if age<ed_mod_age & age!=.
	label define lbleducat7 1 "No education" 2 "Primary incomplete" 3 "Primary complete" ///
	4 "Secondary incomplete" 5 "Secondary complete" 6 "Higher than secondary but not university" /// 
	7 "University incomplete or complete" 8 "Other" 9 "Not classified"
	label values educat7 lbleducat7
	la var educat7 "Level of education 7 categories"
*</_educat7_>



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

	
** EDUCATION LEVEL 4 CATEGORIES
*<_educat4_>
	gen byte educat4=.
	replace educat4=1 if educat7==1 
	replace educat4=2 if educat7==2 | educat7==3
	replace educat4=3 if educat7==4 | educat7==5
	replace educat4=4 if educat7==6 | educat7==7
	label var educat4 "Level of education 4 categories"
	label define lbleducat4 1 "No education" 2 "Primary (complete or incomplete)" ///
	3 "Secondary (complete or incomplete)" 4 "Tertiary (complete or incomplete)"
	label values educat4 lbleducat4
*</_educat4_>

	
	
** EVER ATTENDED SCHOOL
*<_everattend_>
	gen byte everattend=1 if b0201==3 | b0201==2
	replace everattend=0 if b0201==1
	replace everattend=. if age<ed_mod_age & age!=.
	label var everattend "Ever attended school"
	la de lbleverattend 0 "No" 1 "Yes"
	label values everattend lbleverattend
*</_everattend_>



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
*<_lb_mod_age_>


/*
There is no labor module. Some info is available in  "source of income"  section.
*/
	gen byte lb_mod_age=10
	label var lb_mod_age "Labor module application age"
*</_lb_mod_age_>



** LABOR STATUS
*<_lstatus_>

/*
Question is asked in a monthly basis.
*/
	gen byte lstatus=1 if b0101==1 | b0103==1
	replace lstatus=2 if b0103==2
	replace lstatus=3 if b0103==3

	replace lstatus=. if age<lb_mod_age & age!=.
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus
*</_lstatus_>
 // 3

** EMPLOYMENT STATUS
*<_empstat_>
	gen byte empstat=1 if b0106==4 // 3
	replace empstat=2 if b0106==5 // 4
	replace empstat=3 if b0106==1 | b0106==2 // 1
	replace empstat=4 if b0106==3 | b0106>=6 & b0106<=9 // 2

	replace empstat=. if lstatus!=1 // 4
	label var empstat "Employment status" // 5
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classificable by status" // 4
	label values empstat lblempstat
*</_empstat_> // 4


** SECTOR OF ACTIVITY: PUBLIC - PRIVATE
*<_njobs_>
	gen byte  njobs=.

	replace njobs=. if lstatus!=1
	label var njobs "Number of additional jobs"
*</_njobs_>


** SECTOR OF ACTIVITY: PUBLIC - PRIVATE
*<_ocusec_>
	gen byte ocusec=.
	replace ocusec=. if lstatus!=1
	label var ocusec "Sector of activity"
	la de lblocusec 1 "Public, state owned, government, army, NGO" 2 "Private"
	label values ocusec lblocusec
*</_ocusec_>


** REASONS NOT IN THE LABOR FORCE
*<_nlfreason_>
	gen byte nlfreason=.
	replace nlfreason=. if lstatus!=3
	label var nlfreason "Reason not in the labor force"
	la de lblnlfreason 1 "Student" 2 "Housewife" 3 "Retired" 4 "Disable" 5 "Other"
	label values nlfreason lblnlfreason
*</_nlfreason_>

** UNEMPLOYMENT DURATION: MONTHS LOOKING FOR A JOB
*<_unempldur_l_>
	gen byte unempldur_l=.
	replace unempldur_l=. if lstatus!=2
	label var unempldur_l "Unemployment duration (months) lower bracket"
*</_unempldur_l_>

*<_unempldur_u_>

	gen byte unempldur_u=.
	replace unempldur_u=. if lstatus!=2
	label var unempldur_u "Unemployment duration (months) upper bracket"
*</_unempldur_u_>

** INDUSTRY CLASSIFICATION
*<_industry_>
	gen byte industry=.
	replace industry=1 if b0105>=11 & b0105<=13
	replace industry=2 if b0105>=21 & b0105<=29
	replace industry=3 if b0105>=31 & b0105<=39
	replace industry=4 if b0105>=41 & b0105<=42
	replace industry=5 if b0105>=51 & b0105<=59
	replace industry=6 if b0105>=61 & b0105<=63
	replace industry=7 if b0105>=71 & b0105<=72
	replace industry=8 if b0105>=81 & b0105<=83
	replace industry=9 if b0105==91
	replace industry=10 if b0105>=92 & b0105<=96
	replace industry=10 if b0105==00

	replace industry=. if lstatus!=1
	label var industry "1 digit industry classification"
	la de lblindustry 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Comnunications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industry lblindustry
*</_industry_>


** OCCUPATION CLASSIFICATION
*<_occup_>
	gen byte occup=.
	replace occup=10 if b0104==0
	replace occup=1 if b0104>=11 & b0104<=13
	replace occup=2 if b0104>=21 & b0104<=24
	replace occup=3 if b0104>=31 & b0104<=34
	replace occup=4 if b0104>=41 & b0104<=42
	replace occup=5 if b0104>=51 & b0104<=52
	replace occup=6 if b0104>=61 & b0104<=62
	replace occup=7 if b0104>=71 & b0104<=74
	replace occup=8 if b0104>=81 & b0104<=83
	replace occup=9 if b0104>=91 & b0104<=93

	replace occup=. if lstatus!=1
	label var occup "1 digit occupational classification"
	la de lbloccup 1 "Senior officials" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup lbloccup
*</_occup_>


** FIRM SIZE
*<_firmsize_l_>
	gen byte firmsize_l=.
	replace firmsize_l=. if lstatus!=1
	label var firmsize_l "Firm size (lower bracket)"
*</_firmsize_l_>

*<_firmsize_u_>

	gen byte firmsize_u=.
	replace firmsize_u=. if lstatus!=1
	label var firmsize_u "Firm size (upper bracket)"

*</_firmsize_u_>


** HOURS WORKED LAST WEEK
*<_whours_>
	gen whours=.
	replace whours=. if lstatus!=1
	label var whours "Hours of work in last week"
*</_whours_>


** WAGES
*<_wage_>
	gen double wage=.
	replace wage=. if lstatus!=1
	label var wage "Last wage payment"
*</_wage_>


** WAGES TIME UNIT
*<_unitwage_>
	gen byte unitwage=.
	replace unitwage=. if lstatus!=1
	label var unitwage "Last wages time unit"
	la de lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Every two months"  5 "Monthly" 6 "Quarterly" 7 "Every six months" 8 "Annually" 9 "Hourly" 10 "Other"
	label values unitwage lblunitwage
*</_wageunit_>


** CONTRACT
*<_contract_>
	gen byte contract=.
	replace contract=. if lstatus!=1
	label var contract "Contract"
	la de lblcontract 0 "Without contract" 1 "With contract"
	label values contract lblcontract
*</_contract_>


** HEALTH INSURANCE
*<_healthins_>
	gen byte healthins=.
	replace healthins=. if lstatus!=1
	label var healthins "Health insurance"
	la de lblhealthins 0 "Without health insurance" 1 "With health insurance"
	label values healthins lblhealthins
*</_healthins_>


** SOCIAL SECURITY
*<_socialsec_>
	gen byte socialsec=.
	replace socialsec=. if lstatus!=1
	label var socialsec "Social security"
	la de lblsocialsec 1 "With" 0 "Without"
	label values socialsec lblsocialsec
*</_socialsec_>


** UNION MEMBERSHIP
*<_union_>
	gen byte union=.
	replace union=. if lstatus!=1
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
	gen spdef=psupind
	la var spdef "Spatial deflator"
*</_spdef_>


** WELFARE
*<_welfare_>
	gen welfare=nomexpend/hsize
	la var welfare "Welfare aggregate"
*</_welfare_>

*<_welfarenom_>
	gen welfarenom=nomexpend/hsize
	la var welfarenom "Welfare aggregate in nominal terms"
*</_welfarenom_>

*<_welfaredef_>
	gen welfaredef=texpend/hsize
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
	gen welfareother=peaexpM
	la var welfareother "Welfare Aggregate if different welfare type is used from welfare, welfarenom, welfaredef"
*</_welfareother_>

*<_welfareothertype_>
	gen welfareothertype="CON"
	la var welfareothertype "Type of welfare measure (income, consumption or expenditure) for welfareother"
*</_welfareothertype_>

*<_welfarenat_>
	gen welfarenat=peaexpM
	la var welfarenat "Welfare aggregate for national poverty"
*</_welfarenat_>

/*****************************************************************************************************
*                                                                                                    *
                                   NATIONAL POVERTY
*                                                                                                    *
*****************************************************************************************************/

	
**ADULT EQUIVALENCY
	gen eqadult=eqadultM
	label var eqadult "Adult Equivalent (Household)"


** POVERTY LINE (NATIONAL)
*<_pline_nat_>
	gen pline_nat=new_pline
	label variable pline_nat "Poverty Line (National)"
*</_pline_nat_>


** HEADCOUNT RATIO (NATIONAL)
*<_poor_nat_>
	gen poor_nat=welfarenat<pline_nat if welfarenat!=.
	la var poor_nat "People below Poverty Line (National)"
	la define poor_nat 0 "Not-Poor" 1 "Poor"
	la values poor_nat poor_nat
*</_poor_nat_>


/*****************************************************************************************************
*                                                                                                    *
                                   INTERNATIONAL POVERTY
*                                                                                                    *
*****************************************************************************************************/


	local year=2011
	
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
	gen pline_int=1.90*cpi*ppp*365/12
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

	keep countrycode year idh idp wgt strata psu vermast veralt urban int_month int_year ///
	     subnatid1 subnatid2 subnatid3 ownhouse water electricity toilet landphone cellphone ///
	     computer internet hsize eqadult relationharm relationcs male age soc marital ed_mod_age everattend ///
	     atschool electricity literacy educy educat4 educat5 educat7 lb_mod_age lstatus empstat njobs ///
	     ocusec nlfreason unempldur_l unempldur_u industry occup firmsize_l firmsize_u whours wage ///
		 unitwage contract healthins socialsec union pline_nat pline_int poor_nat poor_int spdef cpi ppp ///
		 cpiperiod welfare welfarenom welfaredef welfarenat welfareother welfaretype welfareothertype

** ORDER VARIABLES

	order countrycode year idh idp wgt strata psu vermast veralt urban int_month int_year ///
	      subnatid1 subnatid2 subnatid3 ownhouse water electricity toilet landphone cellphone ///
	     computer internet hsize eqadult relationharm relationcs male age soc marital ed_mod_age everattend ///
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
	keep countrycode year idh idp wgt strata psu vermast veralt `keep' *type

	compress

	
	saveold "`output'\Data\Harmonized\PAK_2007_PSLM_v01_M_v02_A_SARMD_IND.dta", replace version(12)
	saveold "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\__REGIONAL\Individual Files\PAK_2007_PSLM_v01_M_v02_A_SARMD_IND.dta", replace  version(13)


	log close


















******************************  END OF DO-FILE  *****************************************************/
