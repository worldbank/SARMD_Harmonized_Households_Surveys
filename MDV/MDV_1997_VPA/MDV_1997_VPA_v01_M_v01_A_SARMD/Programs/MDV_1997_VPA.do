/*****************************************************************************************************
******************************************************************************************************
**                                                                                                  **
**                       INTERNATIONAL INCOME DISTRIBUTION DATABASE (I2D2)                          **
**                                                                                                  **
** COUNTRY	Maldives
** COUNTRY ISO CODE	MDV
** YEAR	1998
** SURVEY NAME	Vulnerability and poverty assessment survey – 1998
** SURVEY AGENCY	Minister of Planning and National Development
** SURVEY SOURCE	
** UNIT OF ANALYSIS	
** INPUT DATABASES	"D:\__I2D2\Maldives\2004\Data\Raw\Household\DataProc\MDV_VPA_2004_2004.dta"
** RESPONSIBLE	Triana Yentzen
** Created	23-03-2012
** Modified	12-09-2014
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
	local input "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\MDV\MDV_1997_VPA\MDV_1997_VPA_v01_M"
	local output "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\MDV\MDV_1997_VPA\MDV_1997_VPA_v01_M_v01_A_SARMD"

** LOG FILE
	cap log using "`input'\Doc\MDV_1997_VPA.log",replace


/*****************************************************************************************************
*                                                                                                    *
                                   * ASSEMBLE DATABASE
*                                                                                                    *
*****************************************************************************************************/


** DATABASE ASSEMBLENT

	use "`input'\Data\Original\Household\individual.dta", clear
	sort hhserial individual
	merge hhserial individual using "`input'\Data\Original\Household\employment.dta"
	sort hhserial individual
	drop _merge
	merge hhserial individual using "`input'\Data\Original\Household\wagemonthly.dta"
	sort hhserial individual
	drop _merge
	merge hhserial using "`input'\Data\Original\Household\household.dta"
	sort hhserial individual
	drop _merge
	merge hhserial using "`input'\Data\Original\Household\expenditure.dta"
	sort hhserial individual
	drop _merge
	merge hhserial using "`input'\Data\Original\Household\vpa1_hh.dta"
	sort hhserial individual
	drop _merge


** COUNTRY
	gen str4 countrycode="MDV"
	label var countrycode "Country code"


** YEAR
	gen int year=1997
	label var year "Year of survey"


** MONTH
	gen byte month=.
	la de lblmonth 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
	label value month lblmonth
	label var month "Month of the interview"


** HOUSEHOLD IDENTIFICATION NUMBER
	tostring hhserial,gen(idh)
	label var idh "Household id"

	tostring individual,replace

** INDIVIDUAL IDENTIFICATION NUMBER
	egen idp=concat(idh individual), punct(-)
	label var idp "Individual id"


** HOUSEHOLD WEIGHTS
	gen double wgt=hh_weight
	label var wgt "Household sampling weight"


** STRATA
	gen strata=.
	label var strata "Strata"


** PSU
	gen psu=.
	label var psu "Primary sampling units"


/*****************************************************************************************************
*                                                                                                    *
                                   HOUSEHOLD CHARACTERISTICS MODULE
*                                                                                                    *
*****************************************************************************************************/


** LOCATION (URBAN/RURAL)
	gen byte urban=maleatl
	recode urban (1=1) (2=0)
	label var urban "Urban/Rural"
	la de lblurb  1 "Urban" 0 "Rural"
	label values urban lblurb


**REGIONAL AREAS
	gen byte reg01=region
	la de lblreg01 0 "Male (capital)" 1 "North" 2 "Central North" 3 "Central" 4 "Central South" 5 "South"
	label var reg01 "Macro regional areas"
	label values reg01 lblreg01
	gen subnatid1=reg01

** REGIONAL AREA 1 DIGIT ADMN LEVEL
	*Extract reg02 from 'Islands'
	gen byte reg02=id4atoll
	recode reg02 (10=1) (31=2) (32=3) (33=4) (34=5) (35=6) (36=7) (37=8) (38=9) (39=10) (40=11) (41=12) (42=13) (43=14) (44=15) (45=16) (46=17) (47=18) (48=19) (49=20) (50=21)
	la de lblreg02 1 "Male (capital)" 2 "North Thiladhunmathi" 3 "South Thiladhunmathi" 4 "North Miladhunmadulu" 5 "South Miladhunmadulu" 6 "North Maalhosmadulu" 7 "South Maalhosmadulu" 8 "Faadhippolhu" 9 "Male atoll" 10 "North Ari Atoll" 11 "South Ari Atoll" 12 "Felidhu Atoll" 13 "Mulakatolhu" 14 "North Nilandhe Atoll" 15 "South Nilandhe Atoll" 16 "Kolhumadhulu" 17 "Hadhunmathi" 18 "North Huvadhu Atoll" 19 "South Huvadhu Atoll" 20 "Fuvahmulah" 21 "Addu Atoll"
	label var reg02 "Region at 1 digit (ADMN1)"
	label values reg02 lblreg02
	gen subnatid2=reg02


** HOUSE OWNERSHIP
	gen byte ownhouse=tenuretype
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
	gen byte internet= .

	label var internet "Internet connection"
	la de lblinternet 0 "No" 1 "Yes"
	label values internet lblinternet


/*****************************************************************************************************
*                                                                                                    *
                                   DEMOGRAPHIC MODULE
*                                                                                                    *
*****************************************************************************************************/


** HOUSEHOLD SIZE
	bys idh: egen hhsize_i2d2=count(year) if relationship>=1 & relationship<10
	label var hhsize_i2d2 "Household size (I2D2)"

	bys idh: egen hhsize_nat=count(year)
	label var hhsize_nat "Household size (National)"
	* Harmonized
	gen hsize=hhsize_nat
	
	
** POPULATION WEIGHT
	gen pop_wgt=wgt*hsize
	la var pop_wgt "Population weight"

	
** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
	gen byte head=relationship
	recode head (3/9=3) (10=4)
	label var head "Relationship to the head of household"
	la de lblhead  1 "Head of household" 2 "Spouse" 3 "Other relatives" 4 "Non-relatives"
	label values head  lblhead


** GENDER
	gen byte male=sex
	label var male "Gender"
	recode male (2=1)(1=0)
	la de lblgender 1 "Male" 0 "Female"
	label values male lblgender

	
** AGE
	gen byte age=ageyears
	replace age=98 if age>98 & age!=.
	label var age "Individual age"


** SOCIAL GROUP
	gen byte soc=.
	replace soc=1 if langdhivehi==1
	replace soc=2 if  langenglish==1
	replace soc=3 if langother==1
	replace soc=4 if  langnone==1
	label var soc "Social group"
	la de lblsoc 1 "Dhivehi" 2 "English" 3 "Other" 4 "None"
	label values soc lblsoc


** MARITAL STATUS
	gen byte marital=.

	label var marital "Marital status"
	la de lblmarital 1 "Married or live together" 2 "Divorced/separated" 3 "Widow/er" 4 "Single"
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
	gen byte atschool=educationnow
	recode atschool (2=0) (0=.)
	label var atschool "Attending school"
	la de lblatschool 0 "No" 1 "Yes"
	label values atschool  lblatschool


** CAN READ AND WRITE
	gen byte literacy=soc
	recode literacy (1/3=1) (4=0)


	label var literacy "Can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy


** YEARS OF EDUCATION COMPLETED
	gen byte educy=highestlevel
	replace educy=0 if highestlevel==20 | educationpast==2
	recode educy (13 14 17 = 12) (16 18 19=0)
	replace educy=0 if educationpast!=1
	replace educy=. if age<ed_mod_age
	label var educy "Years of education"


** EDUCATIONAL LEVEL 1
	gen byte edulevel1=.
	replace edulevel=1 if educy==0
	replace edulevel=2 if educy>=1 & educy<=4
	replace edulevel=3 if educy==5
	replace edulevel=4 if educy>=6 & educy<=9
	replace edulevel=5 if educy==10            /* years 11 and 12 are higher secondary which is attended by few */
	replace edulevel=6 if educy>=11 & educy<=15
	label var edulevel1 "Level of education 1"
	la de lbledulevel1 1 "No education" 2 "Primary incomplete" 3 "Primary complete" 4 "Secondary incomplete" 5 "Secondary complete" 6 "Post-secondary" 7 "Adult education or literacy classes"
	label values edulevel1 lbledulevel1


** EDUCATION LEVEL 2
	gen byte edulevel2=edulevel1
	recode edulevel2 (2/3=2) (4/5=3) (6=4) (7=.)
	label var edulevel2 "Level of education 2"
	la de lbledulevel2 1 "No education" 2 "Primary" 3 "Secondary" 4 "Post-secondary"
	label values edulevel2 lbledulevel2


** EVER ATTENDED SCHOOL
	gen byte everattend=educationpast
	recode everattend (2=0)

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
	gen byte lb_mod_age=12
	label var lb_mod_age "Labor module application age"


** LABOR STATUS
	gen byte lstatus=employed
	replace lstatus=3 if unemployed==2 & lstatus!=1
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus


** EMPLOYMENT STATUS
	gen byte empstat=empstatus
	recode empstat (2=1) (4=2) (1=3) (3=4) (5=5)
	replace empstat=. if lstatus==2 | lstatus==3
	label var empstat "Employment status"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other"
	label values empstat lblempstat


** NUMBER OF ADDITIONAL JOBS
	gen byte njobs=.
	label var njobs "Number of additional jobs"


** SECTOR OF ACTIVITY: PUBLIC - PRIVATE
	gen byte ocusec=estbtype
	recode ocusec (1 2 4 =1) (3 5 6 =2)
	replace ocusec=. if lstatus==2 | lstatus==3
	label var ocusec "Sector of activity"
	la de lblocusec 1 "Public, state owned, government, army, NGO" 2 "Private"
	label values ocusec lblocusec


** REASONS NOT IN THE LABOR FORCE
	gen byte nlfreason=activitytype
	recode nlfreason (1=.) (2=1) (3=2)
	replace nlfreason=. if lstatus!=3
	label var nlfreason "Reason not in the labor force"
	la de lblnlfreason 1 "Student" 2 "Housewife" 3 "Retired" 4 "Disabled" 5 "Other"
	label values nlfreason lblnlfreason


** UNEMPLOYMENT DURATION: MONTHS LOOKING FOR A JOB
	gen byte unempldur_l=.
	label var unempldur_l "Unemployment duration (months) lower bracket"

	gen byte unempldur_u=.
	label var unempldur_u "Unemployment duration (months) upper bracket"


** INDUSTRY CLASSIFICATION
	recode industry (1/999=1) (1000/1499=2) (1500/3999=3) (4000/4499=4) (4500/4999=5) (5000/5999=6) (6000/6499=7) (6500/7499=8) (7500/9999=9)
	label var industry "1 digit industry classification"
	replace industry=. if lstatus==2 | lstatus==3
	la var industry "Industry Code"
	la de lblindustry 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transports and comnunications" 8 "Financial and business-oriented services" 9 "Community and family oriented services" 10 "Other services, Unspecified"
	label values industry lblindustry


** OCCUPATION CLASSIFICATION
	gen byte occup=occupation
	recode occup (1000/1999=1) (2000/2999=2) (3000/3999=3) (4000/4999=4) (5000/5999=5) (6000/6999=6) (7000/7999=7) (8000/8999=8) (9000/9999=9) (110=10)
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
	gen whours=hrsworked
	replace whours=. if lstatus==2 | lstatus==3
	label var whours "Hours of work in last week"


** WAGES
	gen double wage=value
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
                                   FINAL FIXES
*                                                                                                    *
*****************************************************************************************************/

	qui su wage
	replace wage=0 if empstat==2 & r(N)!=0
	replace ownhouse=. if head==4

/*****************************************************************************************************
*                                                                                                    *
                                   WELFARE MODULE
*                                                                                                    *
*****************************************************************************************************/


** INCOME PER CAPITA
	gen double pci= .
	label var pci "Monthly income per capita"


** DECILES OF PER CAPITA INCOME
	gen pci_d=.
	label var pci_d "Income per capita deciles"


** CONSUMPTION PER CAPITA
	gen double pcc_i2d2=monthlyvpaexpinclactrent/hhsize_i2d2
	label var pcc_i2d2 "Monthly consumption per capita (I2D2)"


** DECILES OF PER CAPITA CONSUMPTION
	xtile pcc_d_i2d2=pcc_i2d2 [w=wgt], nq(10) 
	label var pcc_d_i2d2 "Consumption per capita deciles (I2D2)"



/*****************************************************************************************************
*                                                                                                    *
                                   SAR2D2 PROCESS
*                                                                                                    *
*****************************************************************************************************/



** HOUSEHOLD SIZE
	la variable hhsize_i2d2 "Household Size (I2D2)
	la variable hhsize_nat "Household Size (National)"


** CONSUMPTION PER CAPITA (NATIONAL)
	gen pcc_nat=pcc_i2d2*hhsize_i2d2/hhsize_nat
	label var pcc_nat "Monthly consumption per capita (National)"


** DECILES OF CONSUMPTION PER CAPITA (NATIONAL)
	xtile pcc_d_nat=pcc_nat [w=wgt], nq(10) 
	label var pcc_d_nat "Consumption per capita deciles (National)"


** CONSUMPTION PER CAPITA (POVCALNET)
	gen pcc_125=pcc_nat
	label var pcc_125 "Monthly consumption per capita (Povcalnet)"


** DECILES OF CONSUMPTION PER CAPITA (POVCALNET)
	xtile pcc_d_125=pcc_125 [w=wgt], nq(10)
	label var pcc_d_125 "Consumption per capita deciles (Povcalnet)"


** POVERTY LINES

	gen pline_7_nat=228.125
	label variable pline_7_nat "Poverty Line (National) (7.5)"

	gen pline_10_nat=304.166666666667
	label variable pline_10_nat "Poverty Line (National) (10)"

	gen pline_15_nat=456.25
	label variable pline_15_nat "Poverty Line (National) (15)"

	gen pline_125=342.812569032916

** HEADCOUNT
	la var pline_125 "Poverty Line (Povcalnet)

	foreach x in 7 10 15{
	gen poor_`x'_nat=pcc_nat<pline_`x'_nat & pcc_nat!=.
	la var poor_`x'_nat "People below Poverty Line (National) (`x')"
	la define poor_`x'_nat 0 "Not-Poor" 1 "Poor"
	la values poor_`x'_nat poor_`x'_nat
	}
	gen poor_125=pcc_125<pline_125 & pcc_125!=.

	la var poor_125 "People below Poverty Line (Povcalnet)"
	la define poor_125 0 "Not-Poor" 1 "Poor"
	la values poor_125 poor_125

/*****************************************************************************************************
*                                                                                                    *
                                   FINAL STEPS
*                                                                                                    *
*****************************************************************************************************/


** KEEP VARIABLES - ALL

	keep countrycode year idh idp wgt pop_wgt strata psu urban reg01 reg02 subnatid1 subnatid2 ownhouse water electricity toilet landphone cellphone computer internet ///
	     hhsize_i2d2 hhsize_nat hsize head male age soc marital ed_mod_age everattend atschool electricity ///
	     literacy educy edulevel1 edulevel2 lb_mod_age lstatus empstat njobs ocusec nlfreason                         ///
	     unempldur_l unempldur_u industry occup firmsize_l firmsize_u whours wage unitwage contract      ///
	     healthins socialsec union pci pci_d pcc_i2d2 pcc_d_i2d2 pcc_nat  pcc_d_nat pcc_125 pcc_d_125 pline_7_nat pline_10_nat pline_15_nat pline_125 poor_7_nat poor_10_nat poor_15_nat poor_125

** ORDER VARIABLES

	order countrycode year idh idp wgt pop_wgt strata psu urban reg01 reg02 subnatid1 subnatid2 ownhouse water electricity toilet landphone cellphone computer internet ///
	     hhsize_i2d2 hhsize_nat hsize head male age soc marital ed_mod_age everattend atschool electricity ///
	     literacy educy edulevel1 edulevel2 lb_mod_age lstatus empstat njobs ocusec nlfreason                         ///
	     unempldur_l unempldur_u industry occup firmsize_l firmsize_u whours wage unitwage contract      ///
	     healthins socialsec union pci pci_d pcc_i2d2 pcc_d_i2d2 pcc_nat  pcc_d_nat pcc_125 pcc_d_125 pline_7_nat pline_10_nat pline_15_nat pline_125 poor_7_nat poor_10_nat poor_15_nat poor_125

	compress

** DELETE MISSING VARIABLES

	local keep ""
	qui levelsof countrycode, local(cty)
	foreach var of varlist urban - poor_125 {
	qui sum `var'
	scalar sclrc = r(mean)
	if sclrc==. {
	     display as txt "Variable " as result "`var'" as txt " for countrycode " as result `cty' as txt " contains all missing values -" as error " Variable Deleted"
	}
	else {
	     local keep `keep' `var'
	}
	}
	keep countrycode year idh idp wgt pop_wgt strata psu `keep' 


	compress


	save "`output'\Data\Harmonized\MDV_1997_VPA_v01_M_v01_A_SARMD_IND.dta", replace
	save "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\__REGIONAL\Individual Files\MDV_1997_VPA_v01_M_v01_A_SARMD_IND.dta", replace
	

	cap log close




******************************  END OF DO-FILE  *****************************************************/
