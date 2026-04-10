/*****************************************************************************************************
******************************************************************************************************
**                                                                                                  **
**                                  SOUTH ASIA MICRO DATABASE                                       **
**                                                                                                  **
** COUNTRY	INDIA
** COUNTRY ISO CODE	IND
** YEAR	2011
** SURVEY NAME	NATIONAL SAMPLE SURVEY 68TH ROUND 
*	HOUSEHOLD SCHEDULE 1.0 : CONSUMER EXPENDITURE
** SURVEY AGENCY	GOVERNMENT OF INDIA NATIONAL SAMPLE SURVEY ORGANISATION
** RESPONSIBLE	Triana Yentzen
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
	local input "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\IND\IND_2011_NSS68-SCH10\IND_2011_NSS68-SCH10_v01_M"
	local output "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\IND\IND_2011_NSS68-SCH10\IND_2011_NSS68-SCH10_v01_M_v01_A_SARMD"

** LOG FILE
	log using "`output'\Doc\Technical\IND_2011_NSS68-SCH10_v01_M_v01_A_SARMD.log",replace


/*****************************************************************************************************
*                                                                                                    *
                                   * ASSEMBLE DATABASE
*                                                                                                    *
*****************************************************************************************************/


** DATABASE ASSEMBLENT
	
	* PREPARE DATASETS

	use "`input'\Data\Stata\nsso68eu3.dta"

	sort ID B4_v01
	merge ID B4_v01 using "`input'\Data\Stata\nsso68eu4.dta"
	drop _merge

	sort ID B4_v01
	merge ID B4_v01 using "`input'\Data\Stata\IND_2011_NSS68-SCH10_v01_M_Stata8_Copy\IND_2011_NSS68-SCH10_v01_M_Stata8\NSS68_Sch10_bk_5-2.dta"
	drop _merge

	sort ID B4_v01
	merge ID B4_v01 using "`input'\Data\Stata\IND_2011_NSS68-SCH10_v01_M_Stata8_Copy\IND_2011_NSS68-SCH10_v01_M_Stata8\NSS68_Sch10_bk_5-3.dta"
	drop _merge
	sort ID B4_v01

	merge ID B4_v01 using "`input'\Data\Stata\IND_2011_NSS68-SCH10_v01_M_Stata8_Copy\IND_2011_NSS68-SCH10_v01_M_Stata8\NSS68_Sch10_bk_6.dta"
	drop _merge
	sort ID B4_v01

	merge ID B4_v01 using "`input'\Data\Stata\IND_2011_NSS68-SCH10_v01_M_Stata8_Copy\IND_2011_NSS68-SCH10_v01_M_Stata8\NSS68_Sch10_bk_7.dta"
	drop _merge
	sort ID B4_v01

	merge ID using "`input'\Data\Stata\IND_2011_NSS68-SCH10_v01_M_Stata8_Copy\IND_2011_NSS68-SCH10_v01_M_Stata8\NSS68_Sch10_bk_1_2.dta"
	drop _merge
	sort ID B4_v01

	merge ID using "`input'\Data\Stata\IND_2011_NSS68-SCH10_v01_M_Stata8_Copy\IND_2011_NSS68-SCH10_v01_M_Stata8\NSS68_Sch10_bk_3.dta"
	drop _merge
	sort ID B4_v01

	drop if B53_v03>1 & B53_v03!=.
	* drop if B4_v01==.

	* duplicates drop ID B4_v01,force

	merge ID using "`input'\Other\cons68.dta"

	sort ID
	format ID %9.0f




** COUNTRY
	gen ccode="IND"
	label var ccode "Country code"

** YEAR
	gen year=2011
	label var year "Year of survey"

	tostring ID, gen(idh)


** HOUSEHOLD IDENTIFICATION NUMBER
	label var idh "Household id"
	drop if B4_v01==.


** INDIVIDUAL IDENTIFICATION NUMBER
	egen double idp =concat(idh B4_v01)
	label var idp "Individual id"


	isid idp


** HOUSEHOLD WEIGHTS
	gen wgt=hhwt

	label var wgt "Household sampling weight"


** STRATA
	gen strata=B1_v08
	label var strata "Strata"


** PSU
	gen psu=B1_v01 
	destring psu , replace
	label var psu "Primary sampling units"


/*****************************************************************************************************
*                                                                                                    *
                                   HOUSEHOLD CHARACTERISTICS MODULE
*                                                                                                    *
*****************************************************************************************************/


** LOCATION (URBAN/RURAL)
	gen urb=B1_v05
	recode urb (2=1) (1=2)

	label var urb "Urban/Rural"
	la de lblurb 1 "Urban" 2 "Rural"
	label values urb lblurb


**REGIONAL AREAS
	gen reg01=.
	label var reg01 "Macro regional areas"

	gen REG=state
	label define REG  28 "Andhra Pradesh"  18 "Assam"  10 "Bihar" 24 "Gujarat" 06 "Haryana"  02 "HimachalPradesh" ///
	01 "Jammu & Kashmir" 29"Karnataka" 32 "Kerala" 23 "Madhya Pradesh" 27  "Maharashtra" ///  

** REGIONAL AREA 1 DIGIT ADMN LEVEL
	14 "Manipur"   17 "Meghalaya"  13 "Nagaland"  21 "Orissa"  03 "Punjab" 08 "Rajasthan" 11 "Sikkim" ///
	33 "Tamil Nadu"  16 "Tripura"  09 "Uttar Pradesh"  19 "West Bengal" 35 "A & N Islands" ///
	12 "Arunachal Pradesh"  4 "Chandigarh" 26 "Dadra & Nagar Haveli" 7 "Delhi"  30 "Goa" ///
	31"Lakshdweep" 15 "Mizoram"  34 "Pondicherry"  25 "Daman & Diu" 22"Chhattisgarh" 20"Jharkhand" 5"Uttaranchal"
	gen reg02=REG
	label values reg02 REG
	label var reg02 "Region at 1 digit(ADMN1)"


** HOUSE OWNERSHIP
	gen ownhouse=.
	label var ownhouse "House ownership"
	la de lblownhouse 0 "No" 1 "Yes"
	label values ownhouse lblownhouse


** WATER PUBLIC CONNECTION
	gen water=. /* B7_v18 bringing water from outside premises */
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

	ren hhsize hhsize_nat

	bys idh: egen hhsize_i2d2= count(B4_v03) if B4_v03!=9 & B4_v03!=.

**HOUSEHOLD SIZE
	label var hhsize_i2d2 "Household size (I2D2)"



** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
	gen head=B4_v03 
	recode head (3/8=3) (9=.)
	label var head "Relationship to the head of household"
	la de lblhead  1 "Head of household" 2 "Spouse" 3 "Other"
	label values head  lblhead


** GENDER
	gen gender=B4_v04
	label var gender "Gender"
	la de lblgender 1 "Male" 2 "Female"
	label values gender lblgender
	gen age=B4_v05


** AGE
	label var age "Individual age"
	replace age=98 if age>=98


** SOCIAL GROUP

/*
The variable caste exist too, named "B3_v06"
*/
	gen soc=B3_v05 
* B3_v06
	label var soc "Social group"
	label define soc 1 "Hinduism" 2 "Islam" 3 "Christianity" 4 "Sikhism" 5 "Jainism" 6 "Buddhism" 7 "Zoroastrianism" 9 "Others"
	label values soc soc


** MARITAL STATUS
	gen marital=B4_v06 
	recode marital (1=4) (2=1) (4=2)
	label var marital "Marital status"
	la de lblmarital 1 "Married or live together" 2 "Divorced/separated" 3 "Widow/er" 4 "Single"
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
	replace atschool=1 if B4_v09>=24 & B4_v09<=32
	replace atschool=0 if (B4_v09>=1 & B4_v09<24)  | (B4_v09>=33 & B4_v09<44)
	label var atschool "Attending school"
	la de lblatschool 0 "No" 1 "Yes"
	label values atschool  lblatschool


** CAN READ AND WRITE
	gen literacy=.
	label var literacy "Can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy


** YEARS OF EDUCATION COMPLETED
	gen educy=.

/*
variable not available
*/
	label var educy "Years of education"


** EDUCATIONAL LEVEL 1
	gen edulevel1=B4_v07
	recode edulevel1 (2 3 4=7) (5=2) (6=3) (7 8 =4) (10=5) (11 12 13=6)
	label define edulevel1 1"No education" 2"Primary incomplete" 3"Primary complete" 4"Secondary incomplete" 5"Secondary complete" 6"Post secondary" 7"Adult education or literacy"
	label values edulevel1 edulevel1
	label var edulevel1 "Level of education 1"


** EDUCATION LEVEL 2
	gen edulevel2=.
	replace edulevel2=1 if edulevel1==1|edulevel1==7
	replace edulevel2=3 if edulevel1==2|edulevel1==3
	replace edulevel2=5 if edulevel1==4|edulevel1==5
	replace edulevel2=6 if edulevel1==6
	recode edulevel2 (1=1) (3=2) (5=3) (6=4)
	label var edulevel2 "Level of education 2"
	la de lbledulevel2 1 "No education" 2 "Primary" 3 "Secondary" 4 "Post-secondary"
	label values edulevel2 lbledulevel2


** EVER ATTENDED SCHOOL
	gen everattend=.
	replace everattend=1 if edulevel1>1 & edulevel1!=.
	replace everattend=0 if edulevel1==1
	replace everattend=1 if atschool==1
	label var everattend "Ever attended school"
	la de lbleverattend 0 "No" 1 "Yes"
	label values everattend lbleverattend


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
	replace lstatus=1 if B51_v03>=11 & B51_v03<=51
	replace lstatus=2 if B51_v03==81
	replace lstatus=3 if B51_v03>=91 & B51_v03<=97
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus
	replace lstatus=. if  age<lb_mod_age


** EMPLOYMENT STATUS
	gen empstat=.
	replace empstat=1  if B51_v03>=31 & B51_v03<=51
	replace empstat=3 if B51_v03==12
	replace empstat=4 if B51_v03==11
	replace empstat=2 if B51_v03==21 
	replace empstat=. if lstatus!=1 | age<lb_mod_age
	label var empstat "Employment status"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed"
	label values empstat lblempstat


** NUMBER OF ADDITIONAL JOBS
	gen njobs=.
	label var njobs "Number of additional jobs"


** SECTOR OF ACTIVITY: PUBLIC - PRIVATE
	gen ocusec=.
	replace ocusec=1 if B51_v09==5 |  B51_v09==7
	replace ocusec=3 if  B51_v09>=1 & B51_v09<=4
	replace ocusec=3 if B51_v09==8 |B51_v09==6
	replace ocusec=. if  B51_v09==9 
	label var ocusec "Sector of activity"
	la de lblocusec 1 "Public, state owned, government, army" 2 "NGO" 3 "Private"
	label values ocusec lblocusec
	replace ocusec=. if lstatus!=1


** REASONS NOT IN THE LABOR FORCE
	gen nlfreason=.
	replace nlfreason=1 if B51_v03==91
	replace nlfreason=2 if B51_v03==92|B51_v03==93
	replace nlfreason=3 if B51_v03==94
	replace nlfreason=4 if B51_v03==95
	replace nlfreason=5 if B51_v03==97 
	replace nlfreason=. if lstatus~=3
	label var nlfreason "Reason not in the labor force"
	la de lblnlfreason 1 "Student" 2 "Housewife" 3 "Retired" 4 "Disable" 5 "Other"
	label values nlfreason lblnlfreason


** UNEMPLOYMENT DURATION: MONTHS LOOKING FOR A JOB
	gen unempldur_l=.
	label var unempldur_l "Unemployment duration (months) lower bracket"

	gen unempldur_u=.
	label var unempldur_u "Unemployment duration (months) upper bracket"


	tostring B53_v21,gen(x1)
	gen x2="0"+x1 if B53_v21<10000
	replace x2=x1 if B53_v21>=10000
	gen x3=real(substr(x2,1,2))


** INDUSTRY CLASSIFICATION
	gen industry=x3
	recode industry (1/9 = 1) (10/14= 2) (15/39=3) (40/44=4) (45=5) (46/59=6) (60/64=7) (65/74=8) (75/98=9) (99= 10)

	replace industry = . if lstatus!=1
	label var industry "1 digit industry classification"
	la de lblindustry 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transports and comnunications" 8 "Financial and business-oriented services" 9 "Community and family oriented services" 10 "Others"
	label values industry lblindustry


** OCCUPATION CLASSIFICATION
	destring B53_v22, ignore(x X) gen(occ_main)
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
	replace firmsize_l=1 if B51_v11==1
	replace firmsize_l=6 if B51_v11==2
	replace firmsize_l=10 if B51_v11==3
	replace firmsize_l=20 if B51_v11==4
	replace firmsize_l=. if B51_v11==9
	label var firmsize_l "Firm size (lower bracket)"

	gen firmsize_u=.
	replace firmsize_u=6 if B51_v11==1
	replace firmsize_u=9 if B51_v11==2
	replace firmsize_u=20 if B51_v11==3
	replace firmsize_u=. if B51_v11==4 |B51_v11==9
	label var firmsize_u "Firm size (upper bracket)"


** HOURS WORKED LAST WEEK
	gen whours=.


** WAGES
	gen wage= B53_v15
	replace wage=. if lstatus!=1
	replace wage=0 if empstat==2
	label var wage "Last wage payment"


** WAGES TIME UNIT
	gen unitwage=.
	replace unitwage=1 if  B53_v18==1| B53_v18==16
	replace unitwage=2 if  B53_v18==2| B53_v18==17
	replace unitwage=3 if  B53_v18==3| B53_v18==18
	replace unitwage=5 if  B53_v18==4| B53_v18==19
	replace unitwage=. if lstatus!=1 |empstat!=1
	label var unitwage "Last wages time unit"
	la de lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Trimester" 7 "Biannual" 8 "Annually" 9 "Hourly" 
	label values unitwage lblunitwage


** CONTRACT
	gen contract=B51_v12
	recode contract (1=0) (2 3 4=1)
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
	gen union= B6_v15
	recode union (2=0)
	replace union=. if lstatus!=1
	la de lblunion 0 "No member" 1 "Member"
	label var union "Union membership"
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
	gen pci=.
	label var pci "Monthly income per capita"


** DECILES OF PER CAPITA INCOME
	gen pci_d=.


** CONSUMPTION PER CAPITA
	gen pcc_i2d2=mpce_mrp_real*(hhsize_i2d2/hhsize_nat)
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
	la variable hhsize_nat "Household size (National)"



** CONSUMPTION PER CAPITA (NATIONAL)
	gen pcc_nat=mpce_mrp_real
	label var pcc_nat "Monthly consumption per capita (National)"


** DECILES OF CONSUMPTION PER CAPITA (NATIONAL)
	xtile pcc_d_nat=pcc_nat[w=wgt], nq(10)
	label var pcc_d_nat "Consumption per capita deciles (National)"


*(POVCALNET)
	gen pcc_125=mpce_mrp_real*(pline_125/pline_nat)
	label var pcc_125 "Monthly consumption per capita (Povcalnet)"


*PER CAPITA (POVCALNET)
	xtile pcc_d_125=pcc_125[w=wgt], nq(10)
	label var pcc_d_125 "Consumption per capita deciles (Povcalnet)"



** POVERTY LINES
	la variable pline_nat "Poverty Line (National)"
	label variable pline_125 "Poverty Line (Povcalnet)"


** HEADCOUNT
	gen poor_nat=1 if pcc_nat<pline_nat & pcc_nat!=.
	replace poor_nat=0 if pcc_nat>=pline_nat & pcc_nat!=.
	la var poor_nat "People below Poverty Line (National)"
	la define poor_nat 0 "Not-Poor" 1 "Poor"
	la values poor_nat poor_nat


	gen poor_125=1 if pcc_125<pline_125 & pcc_125!=.
	replace poor_125=0 if pcc_125>=pline_125 & pcc_125!=.
	la var poor_125 "People below Poverty Line (Povcalnet)"
	la define poor_125 0 "Not-Poor" 1 "Poor"
	la values poor_125 poor_125

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


	saveold "`output'\Data\Harmonized\IND_2011_NSS68-SCH10_v01_M_v01_A_SARMD.dta", replace version(12)
	saveold "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\__REGIONAL\Individual Files\IND_2011_NSS68-SCH10_v01_M_v01_A_SARMD.dta", replace version(12)


	log close





******************************  END OF DO-FILE  *****************************************************/
