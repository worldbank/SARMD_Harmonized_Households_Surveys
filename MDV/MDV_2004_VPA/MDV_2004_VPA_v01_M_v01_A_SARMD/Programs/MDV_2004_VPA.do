/*****************************************************************************************************
******************************************************************************************************
**                                                                                                  **
**                       INTERNATIONAL INCOME DISTRIBUTION DATABASE (I2D2)                          **
**                                                                                                  **
** COUNTRY	Maldives
** COUNTRY ISO CODE	MDV
** YEAR	2004
** SURVEY NAME	Vulnerability and poverty assessment survey – 2004
** SURVEY AGENCY	Minister of Planning and National Development
** SURVEY SOURCE	
** UNIT OF ANALYSIS	
** INPUT DATABASES	"D:\__I2D2\Maldives\2004\Original\Data\DataProc\MDV_VPA_2004_2004.dta"
** RESPONSIBLE	Triana Yentzen
** Created	23-03-2012
** Modified	13-10-2014
** NUMBER OF HOUSEHOLDS	2728
** NUMBER OF INDIVIDUALS	16495
** EXPANDED POPULATION	275602,58
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
	local input "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\MDV\MDV_2004_VPA\MDV_2004_VPA_v01_M"
	local output "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\MDV\MDV_2004_VPA\MDV_2004_VPA_v01_M_v01_A_SARMD"

** LOG FILE
	log using "`output'\Doc\MDV_2004_VPA.log",replace



/*****************************************************************************************************
*                                                                                                    *
                                   * ASSEMBLE DATABASE
*                                                                                                    *
*****************************************************************************************************/


** DATABASE ASSEMBLENT

	use "`input'\Data\Original\Constructed\MDV_VPA_2004_2004.dta"


** COUNTRY
	gen str4 countrycode="MDV"
	label var countrycode "Country code"


** YEAR
	gen int year=2004
	label var year "Year of survey"


** MONTH
	gen byte month=.
	la de lblmonth 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
	label value month lblmonth
	label var month "Month of the interview"


** HOUSEHOLD IDENTIFICATION NUMBER
	tostring HID,gen(idh)
	label var idh "Household id"

	tostring INDID,replace

** INDIVIDUAL IDENTIFICATION NUMBER
	egen idp=concat(idh INDID), punct(-)
	label var idp "Individual id"


** HOUSEHOLD WEIGHTS
	gen double wgt=WEIGHT
	label var wgt "Household sampling weight"


** STRATA
	gen strata=STRATA
	label var strata "Strata"


** PSU
	gen psu=PSU
	label var psu "Primary sampling units"


/*****************************************************************************************************
*                                                                                                    *
                                   HOUSEHOLD CHARACTERISTICS MODULE
*                                                                                                    *
*****************************************************************************************************/


** LOCATION (URBAN/RURAL)
	gen byte urban=URBAN
	label var urban "Urban/Rural"
	la de lblurb  1 "Urban" 0 "Rural"
	label values urban lblurb


**REGIONAL AREAS
	gen byte reg01=REGION
	la de lblreg01 0 "Male (capital)" 1 "North" 2 "Central North" 3 "Central" 4 "Central South" 5 "South"
	label var reg01 "Macro regional areas"
	label values reg01 lblreg01
	
	gen subnatid1=reg01


** REGIONAL AREA 1 DIGIT ADMN LEVEL
	*Extract reg02 from 'Islands'
	gen byte reg02=.
	replace reg02=1 if inrange(Island,1001,1008) 
	replace reg02=2 if inrange(Island,2001,2016) 
	replace reg02=3 if inrange(Island,2101,2117) 
	replace reg02=4 if inrange(Island,2201,2215) | Island==2296 
	replace reg02=5 if inrange(Island,2302,2317) 
	replace reg02=6 if inrange(Island,2401,2418) 
	replace reg02=7 if inrange(Island,2501,2516) 
	replace reg02=8 if inrange(Island,2601,2605) 
	replace reg02=9 if inrange(Island,2701,2713) 
	replace reg02=10 if inrange(Island,2801,2809) 
	replace reg02=11 if inrange(Island,2901,2910) 
	replace reg02=12 if inrange(Island,3001,3005) 
	replace reg02=13 if inrange(Island,3101,3109) 
	replace reg02=14 if inrange(Island,3201,3206) 
	replace reg02=15 if inrange(Island,3301,3308) 
	replace reg02=16 if inrange(Island,3401,3413) 
	replace reg02=17 if inrange(Island,3501,3516) 
	replace reg02=18 if inrange(Island,3601,3610) 
	replace reg02=19 if inrange(Island,3701,3710) 
	replace reg02=20 if inrange(Island,3801,3809) 
	replace reg02=21 if inrange(Island,3901,3906) 
	la de lblreg02 1 "Male (capital)" 2 "North Thiladhunmathi" 3 "South Thiladhunmathi" 4 "North Miladhunmadulu" 5 "South Miladhunmadulu" 6 "North Maalhosmadulu" 7 "South Maalhosmadulu" 8 "Faadhippolhu" 9 "Male atoll" 10 "North Ari Atoll" 11 "South Ari Atoll" 12 "Felidhu Atoll" 13 "Mulakatolhu" 14 "North Nilandhe Atoll" 15 "South Nilandhe Atoll" 16 "Kolhumadhulu" 17 "Hadhunmathi" 18 "North Huvadhu Atoll" 19 "South Huvadhu Atoll" 20 "Fuvahmulah" 21 "Addu Atoll"
	label var reg02 "Region at 1 digit (ADMN1)"
	label values reg02 lblreg02


** HOUSE OWNERSHIP
	gen byte ownhouse=f4hh_a7_TenureType
	recode  ownhouse (2 3=0)
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
	gen byte internet= f4hh_a1_InternetAccess
	recode internet (1=1) (2=0) (0=.)
	label var internet "Internet connection"
	la de lblinternet 0 "No" 1 "Yes"
	label values internet lblinternet


/*****************************************************************************************************
*                                                                                                    *
                                   DEMOGRAPHIC MODULE
*                                                                                                    *
*****************************************************************************************************/


** HOUSEHOLD SIZE
	gen byte hhsize_i2d2=HHSIZE
	label var hhsize_i2d2 "Household size I2D2"

	ren a0_RltnshpWHshldHd relation
	
** POPULATION WEIGHT
	gen pop_wgt=wgt*HHSIZE
	la var pop_wgt "Population weight"
	
	
** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
	recode relation (3/4=3) (7=4) (5 6 8  9=5) (10=6) (99=.), gen(relationharm)

	label var relationharm "Relationship to the head of household"
	la de lblrelationharm  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Non-relatives"
	label values relationharm  lblrelationharm

	gen byte relationcs=relation
	la var relationcs "Relationship to the head of household country/region specific"
	label define lblrelationcs 1 "Household head" 2 "Spouse" 3 "Child" 4 "Step Child" 5 "Brother/Sister" 6 "Grand child" 7 "Parents /Step Parents" 8 "Son/Daughter-in-law" 9 "Other relative" 10"Non-relative"
	label values relationcs lblrelationcs
	
** GENDER
	gen byte male=MALE
	recode male (2=0)(1=1)
	label var male "Gender"
	la de lblgender 1 "Male" 0 "Female"
	label values male lblgender


** AGE
	gen byte age=AGEY
	label var age "Individual age"


** SOCIAL GROUP
	gen byte soc=.
	replace soc=1 if a8_LngDhive==1
	replace soc=2 if  a8_LngEng==1
	replace soc=3 if a8_LngOthr==1
	replace soc=4 if  a8_LngNone==1
	label var soc "Social group"
	la de lblsoc 1 "Dhivehi" 2 "English" 3 "Other" 4 "None"
	label values soc lblsoc

** MARITAL STATUS

	recode MARSTAT (1=2) (2 = 1) (3=4) (4=5), gen(marital)
	label var marital "Marital status"
	la de lblmarital 1 "Married" 2 "Never Married" 3 "Living Together" 4 "Divorced/separated" 5 "Widowed"
	label values marital lblmarital


/*****************************************************************************************************
*                                                                                                    *
                                   EDUCATION MODULE
*                                                                                                    *
*****************************************************************************************************/


** EDUCATION MODULE AGE
	gen byte ed_mod_age=6
	label var ed_mod_age "Education module application age"


** CURRENTLY AT SCHOOL
	gen byte atschool=a5_AttndEdctnInsttNow
	recode atschool (2=0) (0=.)
	label var atschool "Attending school"
	la de lblatschool 0 "No" 1 "Yes"
	label values atschool  lblatschool


** CAN READ AND WRITE
	gen byte literacy=.
	replace  literacy=1 if a8_LngDhivehi==1 | a8_LngEng==1 | a8_LngOthr==1
	replace  literacy=0 if a8_LngNone==1
	replace literacy=. if age<6
	label var literacy "Can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy


** YEARS OF EDUCATION COMPLETED
	gen byte educy=EDYEARS
	label var educy "Years of education"


** EDUCATIONAL LEVEL 1
	gen byte edulevel1=.
	label var edulevel1 "Level of education 1"
	la de lbledulevel1 1 "No education" 2 "Primary incomplete" 3 "Primary complete" 4 "Secondary incomplete" 5 "Secondary complete" 6 "Post-secondary" 7 "Adult education or literacy classes"
	label values edulevel1 lbledulevel1


** EDUCATION LEVEL 2
	gen byte edulevel2=EDLEVEL
	recode edulevel2 (0=1) (1=2) (2 3=3) (4=4)
	label var edulevel2 "Level of education 2"
	la de lbledulevel2 1 "No education" 2 "Primary" 3 "Secondary" 4 "Post-secondary"
	label values edulevel2 lbledulevel2


** EVER ATTENDED SCHOOL
	gen byte everattend=.
	replace everattend=1 if a4_AttndEdctnInsttPast==1 | a5_AttndEdctnInsttNow==1
	replace everattend=0 if a4_AttndEdctnInsttPast==2 & a5_AttndEdctnInsttNow==2
	label var everattend "Ever attended school"
	la de lbleverattend 0 "No" 1 "Yes"
	label values everattend lbleverattend

	replace educy=0 if everattend==0
	replace  edulevel1=1 if everattend==0
	replace  edulevel2=1 if everattend==0

	local ed_var "everattend atschool literacy educy edulevel1 edulevel2"
	foreach v in `ed_var'{
	replace `v'=. if( age<ed_mod_age & age!=.)
	}


/*****************************************************************************************************
*                                                                                                    *
                                   LABOR MODULE
*                                                                                                    *
*****************************************************************************************************/


** LABOR MODULE AGE
	gen byte lb_mod_age=15
	label var lb_mod_age "Labor module application age"


** LABOR STATUS
	gen byte lstatus=EMP_STAT
	recode lstatus (4=3)
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus


** EMPLOYMENT STATUS
	gen byte empstat=EMPTYPE_MAIN
	recode empstat (1=1) (2=3) (3=4)  (4=2)
	replace empstat=. if lstatus==2 | lstatus==3
	label var empstat "Employment status"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other"
	label values empstat lblempstat


** NUMBER OF ADDITIONAL JOBS
	gen byte njobs=.
	label var njobs "Number of additional jobs"


** SECTOR OF ACTIVITY: PUBLIC - PRIVATE
	gen byte ocusec=f6a5_EstbType
	recode ocusec (1 2 4=1)  (3 5 6=2)  (7=.) (0=.)
	replace ocusec=. if lstatus==2 | lstatus==3
	label var ocusec "Sector of activity"
	la de lblocusec 1 "Public, state owned, government, army, NGO" 2 "Private"
	label values ocusec lblocusec


** REASONS NOT IN THE LABOR FORCE
	gen byte nlfreason=WHYINACTIVE_mahesh
	recode nlfreason (2=1) (3=2) (4=4) (6=5)
	label var nlfreason "Reason not in the labor force"
	la de lblnlfreason 1 "Student" 2 "Housewife" 3 "Retired" 4 "Disabled" 5 "Other"
	label values nlfreason lblnlfreason


** UNEMPLOYMENT DURATION: MONTHS LOOKING FOR A JOB
	gen byte unempldur_l=.
	label var unempldur_l "Unemployment duration (months) lower bracket"

	gen byte unempldur_u=.
	label var unempldur_u "Unemployment duration (months) upper bracket"


** INDUSTRY CLASSIFICATION
	gen byte industry=SECTOR_MAIN
	label var industry "1 digit industry classification"
	replace industry=. if lstatus==2 | lstatus==3
	la de lblindustry 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transports and comnunications" 8 "Financial and business-oriented services" 9 "Public Administration" 10 "Other services, Unspecified"
	label values industry lblindustry


** OCCUPATION CLASSIFICATION
	gen byte occup=OCC_MAIN
	label var occup "1 digit occupational classification"
	replace occup=. if lstatus==2 | lstatus==3
	la de lbloccup 1 "Senior officials" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup lbloccup


** FIRM SIZE
	gen byte firmsize_l=.
	label var firmsize_l "Firm size (lower bracket)"

	gen byte firmsize_u=.
	label var firmsize_u "Firm size (upper bracket)"


** HOURS WORKED LAST WEEK
	gen whours=HOURWRKMAIN_week
	replace whours=. if lstatus==2 | lstatus==3
	label var whours "Hours of work in last week"


** WAGES
	gen double wage=income_main
	replace wage=. if lstatus==2 | lstatus==3
	replace wage=0 if empstat==2
	label var wage "Last wage payment"


** WAGES TIME UNIT
	gen byte unitwage=.
	replace unitwage=5 if wage!=. 
	label var unitwage "Last wages time unit"
	replace unitwage=. if lstatus==2 | lstatus==3
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

	local lb_var "lstatus empstat njobs ocusec nlfreason unempldur_l unempldur_u industry occup firmsize_l firmsize_u whours wage unitwage contract healthins socialsec union"
	foreach v in `lb_var'{
	di "check `v' only for age>=lb_mod_age"

	replace `v'=. if( age<lb_mod_age & age!=.)
	}


/*****************************************************************************************************
*                                                                                                    *
                                   WELFARE MODULE
*                                                                                                    *
*****************************************************************************************************/


** INCOME PER CAPITA
	gen double pci_i2d2= HHINCOME_TOT_def/(12*hhsize)
	label var pci_i2d2 "Monthly income per capita"


** DECILES OF PER CAPITA INCOME
	 xtile pci_d_i2d2=pci_i2d2 [w=wgt], nq(10) 
	label var pci_d_i2d2 "Income per capita deciles"


** CONSUMPTION PER CAPITA
	gen double pcc_i2d2=CONS_PC_mon_def
	label var pcc_i2d2 "Monthly consumption per capita (I2D2)"


** DECILES OF PER CAPITA CONSUMPTION
	xtile pcc_d_i2d2=pcc [w=wgt], nq(10) 
	label var pcc_d_i2d2 "Consumption per capita deciles (I2D2)"

	***spatial deflator has been set up to 1 so ne need to make changes to the deflated values of pci and pcc

/*****************************************************************************************************
*                                                                                                    *
                                   FINAL FIXES
*                                                                                                    *
*****************************************************************************************************/

	qui su wage
	replace wage=0 if empstat==2 & r(N)!=0
	replace ownhouse=. if relationharm==6


/*****************************************************************************************************
*                                                                                                    *
                                   SAR MODULE
*                                                                                                    *
*****************************************************************************************************/


**WELFARE DENOMINATOR - National
	gen hhsize_nat=HHSIZE
	la variable hhsize_nat "Household Size (National)"
	* Harmonize name
	gen hsize=hhsize_nat
**WELFARE DENOMINATOR  - at 1.25 USD a day
	gen T_T=1 if idp!=  " "
	egen hhsize_125=count(T_T), by(idh)
	label var hhsize_125 "Household size (SAR). For 1.25 USD poverty rate."


**CONSUMPTION PER CAPITA - for National poverty rate
	gen double pcc_nat=CONS_PC_mon_def
	label var pcc_nat "Monthly consumption per capita (National)"


** DECILES OF PER CAPITA CONSUMPTION - for National poverty rate
	xtile pcc_d_nat=pcc_nat [w=wgt], nq(10) 
	label var pcc_d_nat "Consumption per capita deciles (National)"


**CONSUMPTION PER CAPITA - for 1.25 USD poverty rate

/*
*
*/
	gen double pcc_125= pcc_nat
	label var pcc_125 "Monthly consumption per capita (Povcalnet)"


** DECILES OF PER CAPITA CONSUMPTION - for 1.25 USD poverty rate
	xtile pcc_d_125=pcc_125 [w=wgt], nq(10) 
	label var pcc_d_125 "Consumption per capita deciles (Povcalnet)"



**NATIONAL POVERTY LINE

/*
Poverty lines were defined according to 2004 income, so it is assumed that they are expressed in 2004 prices.
*/
	gen pline_7_nat=240.299650043745
	label variable pline_7_nat "Poverty Line (National) (7.5)"



**NATIONAL POVERTY LINE

/*
Poverty lines were defined according to 2004 income, so it is assumed that they are expressed in 2004 prices.
*/
	gen pline_10_nat=320.399533391659
	label variable pline_10_nat "Poverty Line (National) (10)"


/*
Poverty lines were defined according to 2004 income, so it is assumed that they are expressed in 2004 prices.
*/


**NATIONAL POVERTY LINE
	gen pline_15_nat=480.599300087489
	label variable pline_15_nat "Poverty Line (National) (15)"

	foreach x in 7 10 15{

**POOR - National
	gen poor_`x'_nat= pcc_nat<pline_`x'_nat if pcc_nat!=.

	la var poor_`x'_nat "People below Poverty Line (National) (`x')"
	la define poor_`x'_nat 0 "Not-Poor" 1 "Poor"
	la values poor_`x'_nat poor_`x'_nat
	}

**POVERTY LINE at 1.25 USD a day
	gen pline_125=361.107902988303
	la var pline_125 "Poverty Line (Povcalnet)


**POOR - at 1.25 USD a day
	gen poor_125=pcc_125<pline_125 & pcc_125!=.

	la var poor_125 "People below Poverty Line (Povcalnet)"
	la define poor125 0 "Not-Poor" 1 "Poor"
	la values poor_125 poor125

/*****************************************************************************************************
*                                                                                                    *
                                   GMD
*                                                                                                    *
*****************************************************************************************************/



** SPATIAL DEFLATOR
	gen spdef=.
	la var spdef "Spatial deflator"


**WEIGHT TYPE
	gen weighttype="PW"
	la var weighttype"Weight type (frequency, probability, analytical, importance)"


** CPI
	gen cpi=.
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


	gen welfarenom=pcc_nat
	la var welfarenom "Welfare aggregate in nominal terms"

	gen welfaredef=.
	la var welfaredef "Welfare aggregate spatially deflated"

	gen welfshprosperity=welfaredef
	la var welfshprosperity "Welfare aggregate for shared prosperity"

	gen welfaretype="CONS"
	la var welfaretype "Type of welfare measure (income, consumption or expenditure) for welfare, welfarenom, welfaredef"

	gen welfareother=.
	la var welfareother "Welfare Aggregate if different welfare type is used from welfare, welfarenom, welfaredef"

	gen welfareothertype=""
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
	la var educat7 "Level of education 7 categories"









/*****************************************************************************************************
*                                                                                                    *
                                   FINAL STEPS
*                                                                                                    *
*****************************************************************************************************/


** KEEP VARIABLES - ALL
	keep countrycode year idh idp wgt pop_wgt strata psu urb reg01 subnatid1 reg02 ownhouse water electricity toilet landphone cellphone computer internet ///
	     hhsize_i2d2 hhsize_nat hsize relationharm relationcs male age soc marital ed_mod_age everattend atschool electricity ///
	     literacy educy edulevel1 edulevel2 lb_mod_age lstatus empstat njobs ocusec nlfreason                         ///
	     unempldur_l unempldur_u industry occup firmsize_l firmsize_u whours wage unitwage contract      ///
	     healthins socialsec union pci_i2d2 pci_d_i2d2 pcc_i2d2 pcc_d_i2d2 pcc_nat  pcc_d_nat pcc_125 pcc_d_125 pline_7_nat pline_10_nat pline_15_nat pline_125 poor_7_nat poor_10_nat poor_15_nat poor_125      ///
	spdef cpi cpiperiod survey vermast veralt welfare welfarenom welfaredef welfareother welfshprosperity welfareothertype welfaretype educat5 educat7

** ORDER VARIABLES


	order countrycode year idh idp wgt pop_wgt strata psu urb reg01 subnatid1 reg02 ownhouse water electricity toilet landphone cellphone computer internet ///
	     hhsize_i2d2 hhsize_nat hsize relationharm relationcs male age soc marital ed_mod_age everattend atschool electricity ///
	     literacy educy edulevel1 edulevel2 lb_mod_age lstatus empstat njobs ocusec nlfreason                         ///
	     unempldur_l unempldur_u industry occup firmsize_l firmsize_u whours wage unitwage contract      ///
	     healthins socialsec union pci_i2d2 pci_d_i2d2 pcc_i2d2 pcc_d_i2d2 pcc_nat  pcc_d_nat pcc_125 pcc_d_125 pline_7_nat pline_10_nat pline_15_nat pline_125 poor_7_nat poor_10_nat poor_15_nat poor_125      ///
	spdef cpi cpiperiod survey vermast veralt welfare welfarenom welfaredef welfareother welfshprosperity welfareothertype welfaretype educat5 educat7


	compress


	local keep ""
	qui levelsof countrycode, local(cty)

** DELETE MISSING VARIABLES
	foreach var of varlist urb - educat7 {
	qui sum `var'
	scalar sclrc = r(mean)
	if sclrc==. {
	     display as txt "Variable " as result "`var'" as txt " for countrycode " as result `cty' as txt " contains all missing values -" as error " Variable Deleted"
	}
	else {
	     local keep `keep' `var'
	}
	}
	keep countrycode year idh idp wgt pop_wgt strata psu `keep' *type
	
	save "`output'\Data\Harmonized\MDV_2004_VPA_v01_M_v01_A_SARMD_IND.dta", replace
	save "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\__REGIONAL\Individual Files\MDV_2004_VPA_v01_M_v01_A_SARMD_IND.dta", replace
	
	
	log close












******************************  END OF DO-FILE  *****************************************************/
