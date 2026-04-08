/*****************************************************************************************************
******************************************************************************************************
**                                                                                                  **
**                       INTERNATIONAL INCOME DISTRIBUTION DATABASE (I2D2)                          **
**                                                                                                  **
** COUNTRY	Pakistan
** COUNTRY ISO CODE	PAK
** YEAR	2011
** SURVEY NAME	Pakistan Social and Living Standards Measurement Survey (PSLM)
** RESPONSIBLE	Triana Yentzen
** Created	15-08-2014
** Modified	15-04-2015
** NUMBER OF HOUSEHOLDS		16341
** NUMBER OF INDIVIDUALS	108933
** EXPANDED POPULATION		130029110
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
	local input "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\PAK\PAK_2011_PSLM\PAK_2011_PSLM_v01_M"
	local output "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\PAK\PAK_2011_PSLM\PAK_2011_PSLM_v01_M_v01_A_SARMD"

** LOG FILE
	log using "`output'\Doc\PAK_2011_PSLM.log",replace


/*****************************************************************************************************
*                                                                                                    *
                                   * ASSEMBLE DATABASE
*                                                                                                    *
*****************************************************************************************************/


** DATABASE ASSEMBLENT


/*
Household Roster
*/
	use "`input'\Data\Raw\Household\plist.dta", clear
	tempfile aux
	isid hhcode idc

	save `aux', replace


/*
Employment
*/
	use "`input'\Data\Raw\Household\sec_1b.dta", clear
	isid hhcode idc
	merge 1:1 hhcode idc using `aux'
	tab _merge

/*
3 obs deleted
*/
	drop if _merge==1
	drop _merge
	save `aux', replace


/*
Education
*/
	use "`input'\Data\Raw\Household\sec_2a.dta", clear
	isid hhcode idc 
	merge 1:1 hhcode idc using `aux'
	tab _merge

/*
0 obs deleted
*/
	drop if _merge==1
	drop _merge
	save `aux', replace


/*
Detail on the family (housing info)
*/
	use "`input'\Data\Raw\Household\sec_5a.dta", clear
	isid hhcode
	merge 1:m hhcode using `aux'
	tab _merge
	drop if _merge==1

/*
0 obs deleted
*/
	drop _merge
	save `aux', replace

	use "`input'\Data\Raw\Household\sec_00a.dta", clear
	isid hhcode
	merge 1:m hhcode using `aux'
	tab _merge
	drop if _merge==1
	drop _merge
	save `aux', replace

/*
Consumption. From Freeha database.
*/
	use "`input'\Data\Raw\Constructed\Consumption Master File.dta"
	tempfile comp
	keep if year==2011
	keep hhcode nomexpend hhsizeM eqadultM peaexpM psupind pline texpend region
	save  `comp' , replace

	use `aux', clear
	merge m:1 hhcode using `comp'
	tab _merge
	drop if _merge!=3
	drop _merge
	
	
	merge 1:1 hhcode idc using "`input'\Data\Raw\Household\roster.dta"
	tab _merge
	drop if _merge!=3
	drop _merge
	
** COUNTRY
	gen str4 ccode="PAK"
	label var ccode "Country code"


** YEAR
	gen int year=2011
	label var year "Year of survey"

** MONTH
	split enum_date,  parse(/) g(d)
	destring d1 d2 d3, replace
	replace d3=2000+d3
	gen month=mdy(d2,d1,d3)
	format month %td
	gen date=month
	format date %td
	replace month=. if d2<7  & d3==2011 & d2!=.
	replace month=. if d2>=7 & d3==2012 & d2!=.
	label var month "Month of the interview"

	
** HOUSEHOLD IDENTIFICATION NUMBER
	gen double idh_=hhcode
	label var idh "Household id"


** INDIVIDUAL IDENTIFICATION NUMBER
	gen double idp_= hhcode*100+idc
	gen idp=string(idp_,"%16.0g")
	gen idh=string(idh_,"%16.0g")
	label var idp "Individual id"


** HOUSEHOLD WEIGHTS
	gen double wgt=weight
	label var wgt "Household sampling weight"


** STRATA
	gen strata=.
	label var strata "Strata"


** PSU
	*gen psu=psu
	label var psu "Primary sampling units"

/*****************************************************************************************************
*                                                                                                    *
                                   HOUSEHOLD CHARACTERISTICS MODULE
*                                                                                                    *
*****************************************************************************************************/


** LOCATION (URBAN/RURAL)
	gen byte urb=region
	label var urb "Urban/Rural"
	la de lblurb 1 "Urban" 2 "Rural"
	label values urb lblurb


**REGIONAL AREAS
	gen byte reg01=.
	*la de lblreg01 
	*label var reg01 "Macro regional areas"
	*label values reg01 lblreg01


** REGIONAL AREA 1 DIGIT ADMN LEVEL

/*
*The universe of this survey consists of all urban and rural areas of the four
provinces and Islamabad excluding military restricted areas.
*/
	gen byte reg02=province
	la de lblreg02 1 "Punjab" 2 "Sindh" 3 "Khyber Pakhtunkhwa" 4 "Balochistan"
	label var reg02 "Region at 1 digit (ADMN1)"
	label values reg02 lblreg02


** HOUSE OWNERSHIP
	gen byte ownhouse=1 if s5q02==1 | s5q02==2
	replace ownhouse=0 if s5q02>2 & s5q02<=5
	label var ownhouse "House ownership"
	la de lblownhouse 0 "No" 1 "Yes"
	label values ownhouse lblownhouse


** WATER PUBLIC CONNECTION
	gen byte water=1 if s5q05==1
	replace water=0 if s5q05>=2 & s5q05<=10
	label var water "Water main source"
	la de lblwater 0 "No" 1 "Yes"
	label values water lblwater


** ELECTRICITY PUBLIC CONNECTION

/*
There is no explicit question. Survey asks four main energy used for cooking or lighting. Not for availability of electricity.
*/
	recode s5q04a (2=1) (3=0), gen(electricity)
	label var electricity "Electricity main source"
	la de lblelectricity 0 "No" 1 "Yes"
	label values electricity lblelectricity


** TOILET PUBLIC CONNECTION
	gen byte toilet=1 if s5q06==1
	replace toilet=0 if s5q06>=2 & s5q05<=6

	label var toilet "Toilet facility"
	la de lbltoilet 0 "No" 1 "Yes"
	label values toilet lbltoilet


** LAND PHONE

	recode s5q04c (2=1) (3=0), gen(landphone)
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

/*
Servants and their relatives are not considered as household members.
*/
	gen byte hhsize_i2d2=hhsizeM
	label var hhsize_i2d2 "Household size (i2d2)"


** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
	gen byte relationharm=s1aq02
	recode relationharm (4 6 7 8 9 10 =5) (5=4) (11 12 = 6)
	replace ownhouse=. if relationharm==6
	label var relationharm "Relationship to the head of household"
	la de lblrelationharm  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Non-relatives"
	label values relationharm  lblrelationharm

	gen byte relationcs=s1aq02
	la var relationcs "Relationship to the head of household country/region specific"
	label define lblrelationcs 1 "Head" 2 "Spouse" 3 "Son/Daughter" 4 "Grandchild" 5 "Father/Mother" 6 "Brother/Sister" 7  "Nephew/Niece" 8 "Son/Daughter-in-law" 9 "Brother/Sister-in-law" 10 "Father/Mother-in-law" 11 "Servant/their relatives" 12 "Other"
	label values relationcs lblrelationcs


** GENDER
	gen byte gender=s1aq03
	label var gender "Gender"
	la de lblgender 1 "Male" 2 "Female"
	label values gender lblgender


** AGE
	*gen age=

	label var age "Individual age"


** SOCIAL GROUP
	gen byte soc=.
	label var soc "Social group"
	la de lblsoc 1 ""
	label values soc lblsoc


** MARITAL STATUS
	gen byte marital=1 if s1aq06==2 | s1aq06==5
	replace marital=2 if s1aq06==1
	replace marital=4 if s1aq06==4
	replace marital=5 if s1aq06==3
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
	recode s2bq01 (3=1) (1 2 =0), gen(atschool)
	replace atschool=. if age<ed_mod_age & age!=.
	label var atschool "Attending school"
	la de lblatschool 0 "No" 1 "Yes"
	label values atschool  lblatschool


** CAN READ AND WRITE
	gen byte literacy=.
	replace literacy=1 if s2aq01==1 & s2aq02==1
	replace literacy=0 if s2aq01==0 | s2aq02==0
	replace literacy=. if age<ed_mod_age & age!=.
	label var literacy "Can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy


** YEARS OF EDUCATION COMPLETED
	gen byte educy=s2bq05
	* replace educy=max(s2bq14-1,0) if educy==. & s2bq14<=13
	* replace educy=13 if educy==. & (s2bq14>=14 & s2bq14<=21)  

	
/*
Diploma
*/
	replace educy=13 if s2bq05==11 | s2bq05==12

/*
BA/BSc
*/
	replace educy=15 if s2bq05==13

/*
Engineer
*/
	replace educy=16 if s2bq05==15

/*
Medicine
*/
	replace educy=17 if s2bq05==16

/*
Agriculture
*/
	replace educy=16 if s2bq05==17

/*
Law
*/
	replace educy=16 if s2bq05==18

/*
MA/MSc
*/
	replace educy=17 if s2bq05==14

/*
MPhl/PhD
*/
	replace educy=19 if s2bq05==19

/*
Others
*/
	replace educy=. if s2bq05==20

	replace educy=s2bq14 if educy==. & s2bq14!=.
	replace educy=educy-1 if s2bq14>=1 & s2bq14<=12 & s2bq05==.
	replace educy=12 if (s2bq14==11 | s2bq14==12) & s2bq05==.
	replace educy=13 if s2bq14==13 & s2bq05==.
	replace educy=14 if s2bq14==14 & s2bq05==.
	replace educy=14 if s2bq14==15 & s2bq05==.
	replace educy=15 if s2bq14==16 & s2bq05==.
	replace educy=14 if s2bq14==17 & s2bq05==.
	replace educy=14 if s2bq14==18 & s2bq05==.
	replace educy=17 if s2bq14==19 & s2bq05==.
	replace educy=.  if s2bq14==20 & s2bq05==.
	
	
	
/*
CHECK!! Source: "http://www-db.in.tum.de/teaching/ws1112/hsufg/Taxila/Site/formal.html"
*/
	replace educy=. if age<ed_mod_age & age!=.
	label var educy "Years of education"

	replace educy=. if age<educy & age!=. & educy!=.


** EDUCATIONAL LEVEL 1

	gen byte edulevel1=1 if s2bq05==0
	replace edulevel1=2 if s2bq05 >0 & s2bq05<8
	replace edulevel1=3 if s2bq05==8
	replace edulevel1=4 if s2bq05>8 &  s2bq05<12
	replace edulevel1=5 if s2bq05==12
	replace edulevel1=6 if s2bq05>12 & s2bq05<=19
	replace edulevel1=. if s2bq05==20
	replace edulevel1=. if age<ed_mod_age & age!=.
	label var edulevel1 "Level of education 1"
	la de lbledulevel1 1 "No education" 2 "Primary incomplete" 3 "Primary complete" 4 "Secondary incomplete" 5 "Secondary complete" 6 "Post-secondary" 7 "Adult education or literacy classes"
	label values edulevel1 lbledulevel1


** EDUCATION LEVEL 2
	gen byte edulevel2=edulevel1
	recode edulevel2 (3=2) (4 5 = 3) (6= 4) (7=.)
	replace edulevel2=. if age<ed_mod_age & age!=.
	label var edulevel2 "Level of education 2"
	la de lbledulevel2 1 "No education" 2 "Primary" 3 "Secondary" 4 "Post-secondary"
	label values edulevel2 lbledulevel2


** EVER ATTENDED SCHOOL
	recode s2bq01 (2 3 =1) (1=0), gen(everattend)
	replace educy=0 if everattend==0
	replace edulevel1=1 if everattend==0
	replace edulevel2=1 if everattend==0
	replace everattend=. if age<ed_mod_age & age!=.
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

/*
Reported in monthly basis. (not in a weekly basis)
*/
	gen byte lstatus=1 if s1bq01==1 | s1bq03==1
	replace lstatus=2 if s1bq01==2 & s1bq03==2
	replace lstatus=3 if s1bq01==2 & s1bq03==3
	replace lstatus=. if age<lb_mod_age & age!=.

	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus


** EMPLOYMENT STATUS
	gen byte empstat=1 if s1bq06==4
	replace empstat=2 if s1bq06==5
	replace empstat=3 if s1bq06==1 | s1bq06==2
	replace empstat=4 if s1bq06==3 | s1bq06>=6 & s1bq06<=9

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
	gen byte industry=1 if s1bq05>=1 & s1bq05<=5
	replace industry=2 if s1bq05>=10 & s1bq05<=14
	replace industry=3 if s1bq05>=15 & s1bq05<=37
	replace industry=4 if s1bq05>=40 & s1bq05<=41
	replace industry=5 if s1bq05==45
	replace industry=6 if s1bq05>=51 & s1bq05<=55
	replace industry=7 if s1bq05>=60 & s1bq05<=64
	replace industry=8 if s1bq05>=65 & s1bq05<=74
	replace industry=9 if s1bq05==75
	replace industry=10 if s1bq05>=80 & s1bq05<=99
	replace industry=. if lstatus!=1
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
	gen double wage=s1bq08
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


** INCOME PER CAPITA
	gen double pci_i2d2=.
	label var pci_i2d2 "Monthly income per capita"


** DECILES OF PER CAPITA INCOME
	*xtile pci_d=pci [w=wgt], nq(10) 
	*label var pci_d "Income per capita deciles"
	gen pci_d_i2d2=.

** CONSUMPTION PER CAPITA
	gen double pcc_i2d2=texpend/hhsize_i2d2
	*egen p=mean(pcc_i2d2)
	*replace pcc_i2d2=p
	label var pcc_i2d2 "Monthly consumption per capita (I2D2)"



** DECILES OF PER CAPITA CONSUMPTION
	xtile pcc_d_i2d2=pcc_i2d2 [w=wgt], nq(10) 
	label var pcc_d_i2d2 "Consumption per capita deciles (I2D2)"


/*****************************************************************************************************
*                                                                                                    *
                                   SAR MODULE
*                                                                                                    *
*****************************************************************************************************/


**WELFARE DENOMINATOR - National
	gen hhsize_nat=eqadultM
	label var hhsize_nat "Household size (National)"


**WELFARE DENOMINATOR  - at 1.25 USD a day
	gen aux=1
	egen hhsize_125=count(aux), by(idh)
	label var hhsize_125 "Household size (Povcalnet)"


**CONSUMPTION PER CAPITA - for National poverty rate
	gen double pcc_nat=peaexpM
	label var pcc_nat "Monthly consumption per adult equivalent (National)"


** DECILES OF PER CAPITA CONSUMPTION - for National poverty rate
	xtile pcc_d_nat=pcc_nat [w=wgt], nq(10) 
	label var pcc_d_nat "Consumption per adult equivalent deciles (National)


**CONSUMPTION PER CAPITA - for 1.25 USD poverty rate

/*
Povcalnet does not make regional adjustemnts.
*/
	gen double pcc_125=nomexpend/hhsize_125
	label var pcc_125 "Monthly consumption per capita (Povcalnet)"


** DECILES OF PER CAPITA CONSUMPTION - for 1.25 USD poverty rate
	xtile pcc_d_125=pcc_125 [w=wgt], nq(10) 
	label var pcc_d_125 "Consumption per capita deciles (Povcalnet)"



**NATIONAL POVERTY LINE
	gen pline_nat=pline
	label var pline_nat "National Poverty Line"


**POOR - National
	gen poor_nat=1 if pcc_nat<pline_nat
	replace poor_nat=0 if pcc_nat>=pline_nat & pcc_nat!=.
	label var poor_nat "People below pline_nat"
	la define lblpoor_nat 0 "Not-Poor" 1 "Poor"
	la values poor_nat lblpoor_nat


**POVERTY LINE at 1.25 USD a day
	gen pline_125=1.25*(365/12)*20.7118985485756*2.126316 // [1.25 per day *365/12]*PPPFactor*CPI(2005=100)
	label var pline_125  "Poverty Line at 1.25 USD a day"


**POOR - at 1.25 USD a day
	gen poor_125=1 if pcc_125<pline_125
	replace poor_125=0 if pcc_125>=pline_125 & pcc_125!=.
	la var poor_125 "People below pline125"
	la define poor125 0 "Not-Poor" 1 "Poor"
	la values poor_125 poor125


/*****************************************************************************************************
*                                                                                                    *
                                   GMD
*                                                                                                    *
*****************************************************************************************************/



** SPATIAL DEFLATOR
	gen spdef=psupind
	la var spdef "Spatial deflator"


**WEIGHT TYPE
	gen weighttype="PW"
	la var weighttype"Weight type (frequency, probability, analytical, importance)"


** CPI
	gen cpi=2.126316
	la var cpi "CPI ratio value of survey (rebased to 2005 on base 1)"


**CPI PERIOD
	gen cpiperiod="year"
	la var cpiperiod "Periodicity of CPI (year, year&month, year&quarter, weighted)"


**SURVEY
	gen survey=""
	la var survey "Type of survey"


** VERSION NUMBERS
	gen vermast=""
	la var vermast "Version number of master data file"

	gen veralt=""
	la var veralt "Version number of adaptation of the master data file"


** WELFARE
	gen welfare=pcc_125

	gen welfarenom=pcc_125
	la var welfarenom "Welfare aggregate in nominal terms"

	gen welfaredef=pcc_i2d2
	la var welfaredef "Welfare aggregate spatially deflated"

	gen welfshprosperity=welfaredef
	la var welfshprosperity "Welfare aggregate for shared prosperity"

	gen welfaretype="CONS"
	la var welfaretype "Type of welfare measure (income, consumption or expenditure) for welfare, welfarenom, welfaredef"

	gen welfareother=pcc_nat
	la var welfareother "Welfare Aggregate if different welfare type is used from welfare, welfarenom, welfaredef"

	gen welfareothertype="CON"
	la var welfareothertype "Type of welfare measure (income, consumption or expenditure) for welfareother"







** EDUCATION
	gen educat5=.
	replace educat5=1 if edulevel1==1
	replace educat5=2 if edulevel1==2
	replace educat5=3 if edulevel1==3 | edulevel1==4
	replace educat5=4 if edulevel1==5
	replace educat5=5 if edulevel1==6

	la var educat5 "Level of education 5 categories"


	gen educat7=.
	replace educat7=edulevel1
	recode educat7 6=7
	replace educat7=6 if s2bq05==17
	la var educat7 "Level of education 7 categories"



preserve
/*****************************************************************************************************
*                                                                                                    *
                                   FINAL STEPS
*                                                                                                    *
*****************************************************************************************************/


** KEEP VARIABLES - ALL
	keep ccode year month date idh idp wgt strata psu urb reg01 reg02 ownhouse water electricity toilet landphone cellphone computer internet ///
	     hhsize_i2d2 hhsize_nat relationharm relationcs gender age soc marital ed_mod_age everattend atschool electricity ///
	     literacy educy edulevel1 edulevel2 lb_mod_age lstatus empstat njobs ocusec nlfreason                         ///
	     unempldur_l unempldur_u industry occup firmsize_l firmsize_u whours wage unitwage contract      ///
	     healthins socialsec union pci_i2d2 pci_d_i2d2 pcc_i2d2 pcc_d_i2d2 pcc_nat  pcc_d_nat pcc_125 pcc_d_125 pline_nat pline_125 poor_nat poor_125      ///
	spdef weighttype cpi cpiperiod survey vermast veralt welfare welfarenom welfaredef welfareother welfshprosperity welfareothertype welfaretype educat5 educat7


** ORDER VARIABLES

	order ccode year month date idh idp wgt strata psu urb reg01 reg02 ownhouse water electricity toilet landphone cellphone computer internet ///
	     hhsize_i2d2 hhsize_nat relationharm relationcs gender age soc marital ed_mod_age everattend atschool electricity ///
	     literacy educy edulevel1 edulevel2 lb_mod_age lstatus empstat njobs ocusec nlfreason                         ///
	     unempldur_l unempldur_u industry occup firmsize_l firmsize_u whours wage unitwage contract      ///
	     healthins socialsec union pci_i2d2 pci_d_i2d2 pcc_i2d2 pcc_d_i2d2 pcc_nat  pcc_d_nat pcc_125 pcc_d_125 pline_nat pline_125 poor_nat poor_125      ///
	spdef weighttype cpi cpiperiod survey vermast veralt welfare welfarenom welfaredef welfareother welfshprosperity welfareothertype welfaretype educat5 educat7

	compress

** DELETE MISSING VARIABLES
	local keep ""
	qui levelsof ccode, local(cty)
	foreach var of varlist urb - educat7{
	qui sum `var'
	scalar sclrc = r(mean)
	if sclrc==. {
	     display as txt "Variable " as result "`var'" as txt " for ccode " as result `cty' as txt " contains all missing values -" as error " Variable Deleted"
	}
	else {
	     local keep `keep' `var'
	}
	}
	keep ccode year month date idh idp wgt strata psu `keep' *type
	
	save "`output'\Doc\PAK_2011_PSLM_date.dta", replace
restore

/*****************************************************************************************************
*                                                                                                    *
                                   FINAL STEPS
*                                                                                                    *
*****************************************************************************************************/


** KEEP VARIABLES - ALL
	keep ccode year month idh idp wgt strata psu urb reg01 reg02 ownhouse water electricity toilet landphone cellphone computer internet ///
	     hhsize_i2d2 hhsize_nat relationharm relationcs gender age soc marital ed_mod_age everattend atschool electricity ///
	     literacy educy edulevel1 edulevel2 lb_mod_age lstatus empstat njobs ocusec nlfreason                         ///
	     unempldur_l unempldur_u industry occup firmsize_l firmsize_u whours wage unitwage contract      ///
	     healthins socialsec union pci_i2d2 pci_d_i2d2 pcc_i2d2 pcc_d_i2d2 pcc_nat  pcc_d_nat pcc_125 pcc_d_125 pline_nat pline_125 poor_nat poor_125      ///
	spdef weighttype cpi cpiperiod survey vermast veralt welfare welfarenom welfaredef welfareother welfshprosperity welfareothertype welfaretype educat5 educat7


** ORDER VARIABLES

	order ccode year month idh idp wgt strata psu urb reg01 reg02 ownhouse water electricity toilet landphone cellphone computer internet ///
	     hhsize_i2d2 hhsize_nat relationharm relationcs gender age soc marital ed_mod_age everattend atschool electricity ///
	     literacy educy edulevel1 edulevel2 lb_mod_age lstatus empstat njobs ocusec nlfreason                         ///
	     unempldur_l unempldur_u industry occup firmsize_l firmsize_u whours wage unitwage contract      ///
	     healthins socialsec union pci_i2d2 pci_d_i2d2 pcc_i2d2 pcc_d_i2d2 pcc_nat  pcc_d_nat pcc_125 pcc_d_125 pline_nat pline_125 poor_nat poor_125      ///
	spdef weighttype cpi cpiperiod survey vermast veralt welfare welfarenom welfaredef welfareother welfshprosperity welfareothertype welfaretype educat5 educat7



	compress


** DELETE MISSING VARIABLES
	local keep ""
	qui levelsof ccode, local(cty)
	foreach var of varlist urb - educat7{
	qui sum `var'
	scalar sclrc = r(mean)
	if sclrc==. {
	     display as txt "Variable " as result "`var'" as txt " for ccode " as result `cty' as txt " contains all missing values -" as error " Variable Deleted"
	}
	else {
	     local keep `keep' `var'
	}
	}
	keep ccode year month idh idp wgt strata psu `keep' *type
	
	saveold "`output'\Data\Harmonized\PAK_2011_PSLM.dta", replace
	save "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\__REGIONAL\Final Files\Individual Files\PAK_2011_PSLM.dta", replace

	/*
	drop pcc_nat pcc_nat_d pcc_125 pcc_125_d hhsize_nat hhsize_125 pline_nat poor_nat pline_125 poor_125
	ren pcc_i2d2 pcc
	ren pcc_i2d2_d pcc_d
	ren hhsize_i2d2 hhsize
	label var pcc "Monthly consumption per capita"
	label var pcc_d "Consumption per capita deciles"
	label var hhsize "Household size"
	save "D:\__I2D2\Pakistan\2011\Processed\PAK_2011_I2D2_PSLM.dta", replace
	save "D:\__CURRENT\PAK_2011_I2D2_PSLM.dta", replace
	*/
	log close


















******************************  END OF DO-FILE  *****************************************************/
