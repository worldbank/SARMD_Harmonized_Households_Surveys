/*****************************************************************************************************
******************************************************************************************************
**                                                                                                  **
**                       INTERNATIONAL INCOME DISTRIBUTION DATABASE (I2D2)                          **
**                                                                                                  **
** COUNTRY	India
** COUNTRY ISO CODE	IND
** YEAR	2009
** SURVEY NAME	SOCIO-ECONOMIC SURVEY  SIXTY-SIXTH ROUND: JULY 2009 – JUNE 2010
*	HOUSEHOLD SCHEDULE 10 : EMPLOYMENT AND UNEMPLOYMENT
** SURVEY AGENCY	GOVERNMENT OF INDIA NATIONAL SAMPLE SURVEY ORGANISATION
** SURVEY SOURCE	
** UNIT OF ANALYSIS	
** INPUT DATABASES	C:\_I2D2\Dan\Beckup Data\SA\India\2009\Original\Data\India_NSS_2009_10_DataOrig.dta 
** RESPONSIBLE	Triana Yentzen
** Created	19-11-2009
** Modified	"5/28/2013"
** NUMBER OF HOUSEHOLDS	100957
** NUMBER OF INDIVIDUALS	458967
** EXPANDED POPULATION	1019558417
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
	local input "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\IND\IND_2009_NSS_SCH1\IND_2009_NSS_SCH1_v01_M"
	local output "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\IND\IND_2009_NSS_SCH1\IND_2009_NSS_SCH1_v01_M_v01_A_SARMD"

** LOG FILE
	log using "`input'\Doc\IND_2009_NSS_SCH1.log",replace


/*****************************************************************************************************
*                                                                                                    *
                                   * ASSEMBLE DATABASE
*                                                                                                    *
*****************************************************************************************************/


** DATABASE ASSEMBLENT
	use "`input'\Data\Raw\Household\nsso66ce1typ1.dta ", clear
	keep hhid state sample sector nssreg district stratum substratum
	merge 1:1 hhid using "`input'\Data\Raw\Household\nsso66ce2typ1"
	keep hhid state sample sector nssreg district stratum substratum  hhtype religion sgroup hhsize  landown landowntyp nic5 nic3 hhwt pwt
	merge 1:1 hhid using "`input'\Data\Raw\Household\nsso66ce3typ1"
	drop _m
	merge 1:m hhid using "`input'\Data\Raw\Household\nsso66ce4typ1"
	ren a15 nss
	ren a16 nsc
	ren a17 mlt
	drop a1 a13 a14 a18 a19
	sort hhid pid hhsize

	sort hhid
	format hhid %9.0f

	drop _merge
	ren mpce_mrp mpce_mrp_365
	merge m:m hhid using "`input'\Data\Raw\Constructed\pcc66.dta"


** COUNTRY
	gen ccode="IND"
	label var ccode "Country code"

** YEAR
	gen year=2009
	label var year "Year of survey"

** HOUSEHOLD IDENTIFICATION NUMBER

	tostring hhid, gen(idh)
	label var idh "Household id"

** INDIVIDUAL IDENTIFICATION NUMBER
	tostring pid, gen(idp) format(%12.0f)
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


/*****************************************************************************************************
*                                                                                                    *
                                   HOUSEHOLD CHARACTERISTICS MODULE
*                                                                                                    *
*****************************************************************************************************/


** LOCATION (URBAN/RURAL)
	gen urb=.
	replace urb=1 if sector==2
	replace urb=2 if sector==1
	label var urb "Urban/Rural"
	la de lblurb 1 "Urban" 2 "Rural"
	label values urb lblurb


**REGIONAL AREAS
	recode state (1 2 3 4 6 8 = 1) (5 7 9 10 23 = 2) (12/18 = 3) (11 19 20 21 22 35 = 4) ( 24 25 26 27 30 = 5) (28 29 31 32 33 34 = 6), gen(reg01)
	label define lblreg01 1 "Northern" 2 "North-Central" 3 "North-Eastern" 4 "Eastern" 5 "Western" 6 "Southern"
	label values reg01 lblreg01
	label var reg01 "Macro regional areas"


** REGIONAL AREA 1 DIGIT ADMN LEVEL
	gen reg02=state
	label define lblreg02  28 "Andhra Pradesh"  18 "Assam"  10 "Bihar" 24 "Gujarat" 06 "Haryana"  02 "HimachalPradesh" ///
	01 "Jammu & Kashmir" 29"Karnataka" 32 "Kerala" 23 "Madhya Pradesh" 27  "Maharashtra" ///  
	14 "Manipur"   17 "Meghalaya"  13 "Nagaland"  21 "Orissa"  03 "Punjab" 08 "Rajasthan" 11 "Sikkim" ///
	33 "Tamil Nadu"  16 "Tripura"  09 "Uttar Pradesh"  19 "West Bengal" 35 "A & N Islands" ///
	12 "Arunachal Pradesh"  4 "Chandigarh" 26 "Dadra & Nagar Haveli" 7 "Delhi"  30 "Goa" ///
	31"Lakshdweep" 15 "Mizoram"  34 "Pondicherry"  25 "Daman & Diu" 22"Chhattisgarh" 20"Jharkhand" 5"Uttaranchal"
	label values reg02 lblreg02


	label var reg02 "Region at 1 digit(ADMN1)"


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
	gen electricity=lightmode==5
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
	recode internet (2=0)
	label var internet "Internet connection"
	la de lblinternet 0 "No" 1 "Yes"
	label values internet lblinternet


**HOUSEHOLD SIZE
	replace relation=. if relation==0
	replace relation=. if relation==9
	bys hhid: egen hhsize_i2d2=count(relation)
	label var hhsize_i2d2 "Household size (I2D2)"



** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
	bys idh: gen head=relation==1
	bys idh: egen heads=total(head)
	drop if heads!=1

	gen relationharm= relation
	recode relationharm (3 5 = 3) (7=4) (4 6 8 = 5) (9=6)
	label var relationharm "Relationship to the head of household"
	la de lblrelationharm  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Non-relatives"
	label values relationharm  lblrelationharm

	gen byte relationcs=relation
	la var relationcs "Relationship to the head of household country/region specific"
	label define lblrelationcs 1 "Head" 2 "Spouse of head" 3 "married child" 4 "spouse of married child" 5 "unmarried child" 6 "grandchild" 7 "father/mother/father-in-law/mother-in-law" 8 "brother/sister/brother-in-law/sister-in-law/other relations" 9 "servant/employee/other non-relative"
	label values relationcs lblrelationcs


** GENDER
	gen gender= sex
	label var gender "Gender"
	la de lblgender 1 "Male" 2 "Female"
	label values gender lblgender


** AGE
	label var age "Individual age"



** SOCIAL GROUP

/*
The caste variable exist too, named "c3_6"
*/
	gen soc=religion
* c3_6
	label var soc "Social group"
	label define soc 1 "Hinduism" 2 "Islam" 3 "Christianity" 4 "Sikhism" 5 "Jainism" 6 "Buddhism" 7 "Zoroastrianism" 9 "Others"
	label values soc soc


** MARITAL STATUS
	gen marital=marstat
	recode marital (1=2) (2=1) (3=5)
	label var marital "Marital status"
	la de lblmarital 1 "Married" 2 "Never Married" 3 "Living Together" 4 "Divorced/separated" 5 "Widowed"
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
	label var atschool "Attending school"
	la de lblatschool 0 "No" 1 "Yes"
	label values atschool  lblatschool

	gen literacy=edugen

** CAN READ AND WRITE
	recode literacy (2/13 = 1) (1= 0)
	label var literacy "Can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy

	gen educy=edugen

** YEARS OF EDUCATION COMPLETED
	recode educy ( 1/4= 0) (5=2)(6=5) (7=8) (8 10 =10)  (11=12) (12=15) (13=17)
	label var educy "Years of education"

	replace educy=. if educy>age & educy!=. & age!=.



** EDUCATIONAL LEVEL 1
	gen edulevel1=.
	replace edulevel1=1 if edugen==1
	replace edulevel1=2 if edugen==5
	replace edulevel1=3 if edugen==6
	replace edulevel1=4 if edugen==7|edugen==8
	replace edulevel1=5 if edugen==10
	replace edulevel1=6 if edugen>=11 & edugen!=.
	replace edulevel1=7 if edugen==2 |edugen==3|edugen==4
	#delimit;
	label define edulevel1 1"No education" 2"Primary incomplete" 3"Primary complete" 
	4"Secondary incomplete" 5"Secondary complete" 6"Post secondary" 7"Adult education or literacy";
	label values edulevel1 edulevel1;
	label var edulevel1 "Level of education 1";
	#delimit cr


** EDUCATION LEVEL 2
	gen edulevel2=.
	replace edulevel2=1 if edulevel1==1 |edulevel1==7
	replace edulevel2=3 if edulevel1==2|edulevel1==3
	replace edulevel2=5 if edulevel1==4|edulevel1==5
	replace edulevel2=6 if edulevel1==6
	recode edulevel2 (1=1) (3=2) (5=3) (6=4)
	label var edulevel2 "Level of education 2"
	la de lbledulevel2 1 "No education" 2 "Primary" 3 "Secondary" 4 "Post-secondary"
	label values edulevel2 lbledulevel2


** EVER ATTENDED SCHOOL
	recode edugen (1 2 3 4 = 0) (5 6 7 8 9 10 11 12 13=1), gen (everattend)
	label var everattend "Ever attended school"
	la de lbleverattend 0 "No" 1 "Yes"
	label values everattend lbleverattend


/*****************************************************************************************************
*                                                                                                    *
                                   LABOR MODULE
*                                                                                                    *
*****************************************************************************************************/


** LABOR MODULE AGE
	gen lb_mod_age=.
	label var lb_mod_age "Labor module application age"



** LABOR STATUS
	gen lstatus=.
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus
	replace lstatus=. if  age<lb_mod_age


** EMPLOYMENT STATUS
	gen empstat=.
	label var empstat "Employment status"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed"
	label values empstat lblempstat


** NUMBER OF ADDITIONAL JOBS
	gen njobs=.
	label var njobs "Number of additional jobs"


** SECTOR OF ACTIVITY: PUBLIC - PRIVATE
	gen ocusec=.
	label var ocusec "Sector of activity"
	la de lblocusec 1 "Public, state owned, government, army" 2 "NGO" 3 "Private"
	label values ocusec lblocusec
	replace ocusec=. if lstatus!=1


** REASONS NOT IN THE LABOR FORCE
	gen nlfreason=.
	label var nlfreason "Reason not in the labor force"
	la de lblnlfreason 1 "Student" 2 "Housewife" 3 "Retired" 4 "Disable" 5 "Other"
	label values nlfreason lblnlfreason


** UNEMPLOYMENT DURATION: MONTHS LOOKING FOR A JOB
	gen unempldur_l=.
	label var unempldur_l "Unemployment duration (months) lower bracket"

	gen unempldur_u=.
	label var unempldur_u "Unemployment duration (months) upper bracket"


** INDUSTRY CLASSIFICATION
	gen industry=.
	label var industry "1 digit industry classification"
	la de lblindustry 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transports and comnunications" 8 "Financial and business-oriented services" 9 "Community and family oriented services" 10 "Others"
	label values industry lblindustry


** OCCUPATION CLASSIFICATION
	gen occup=.
	label var occup "1 digit occupational classification"
	label define occup 1 "Senior officials" 2 "Professionals" 3 "Technicians" 4 "Clerks" ///
	5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" ///
	8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup occup


** FIRM SIZE
	gen firmsize_l=.
	label var firmsize_l "Firm size (lower bracket)"

	gen firmsize_u=.
	label var firmsize_u "Firm size (upper bracket)"


** HOURS WORKED LAST WEEK
	gen whours=.
	label var whours "Hours of work in last week"


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
	gen pci_i2d2=.
	label var pci_i2d2 "Monthly income per capita"

** DECILES OF PER CAPITA INCOME

	gen pci_d_i2d2=.


** CONSUMPTION PER CAPITA
	gen pcc_i2d2=mpce_urp_real
	label var pcc_i2d2 "Monthly consumption per capita (I2D2)"


** DECILES OF PER CAPITA CONSUMPTION
	xtile pcc_d_i2d2=pcc_i2d2[w=wgt], nq(10)
	label var pcc_d_i2d2 "Consumption per capita deciles (I2D2)"


/*****************************************************************************************************
*                                                                                                    *
                                   SAR2D2 PROCESS
*                                                                                                    *
*****************************************************************************************************/


** HOUSEHOLD SIZE
	ren hhsize hhsize_nat
	la variable hhsize_nat "Household size (National)"


** CONSUMPTION PER CAPITA (NATIONAL)
	gen pcc_nat=mpce_mrp
	label var pcc_nat "Monthly consumption per capita (National)"


** DECILES OF CONSUMPTION PER CAPITA (NATIONAL)
	xtile pcc_d_nat=pcc_nat[w=wgt], nq(10)
	label var pcc_d_nat "Consumption per capita deciles (National)"


** CONSUMPTION PER CAPITA (POVCALNET)
	gen pcc_125=mpce_urp/100
	label var pcc_125 "Monthly consumption per capita (Povcalnet)"


** DECILES OF CONSUMPTION PER CAPITA (POVCALNET)
	xtile pcc_d_125=pcc_125[w=wgt], nq(10)
	label var pcc_d_125 "Consumption per capita deciles (Povcalnet)"


** POVERTY LINES
	ren pline_urp pline_125
	label variable pline_125 "Poverty Line (Povcalnet)"
	ren pline pline_nat
	label variable pline_nat "Poverty Line (National)"


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
                                   GMD
*                                                                                                    *
*****************************************************************************************************/



** SPATIAL DEFLATOR
	gen spdef=pline_nat
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


	gen welfarenom=mpce_urp
	la var welfarenom "Welfare aggregate in nominal terms"

	gen welfaredef=pcc_125
	la var welfaredef "Welfare aggregate spatially deflated"

	gen welfshprosperity=welfaredef
	la var welfshprosperity "Welfare aggregate for shared prosperity"

	gen welfaretype="CONS"
	la var welfaretype "Type of welfare measure (income, consumption or expenditure) for welfare, welfarenom, welfaredef"

	gen welfareother=mpce_mrp_real
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
	replace educat7=6 if edugen==11
	la var educat7 "Level of education 7 categories"









/*****************************************************************************************************
*                                                                                                    *
                                   FINAL STEPS
*                                                                                                    *
*****************************************************************************************************/


** KEEP VARIABLES - ALL


	keep ccode year idh idp wgt strata psu urb reg01 reg02 ownhouse water electricity toilet landphone cellphone computer internet ///
	     hhsize_i2d2 hhsize_nat relationharm relationcs gender age soc marital ed_mod_age everattend atschool electricity ///
	     literacy educy edulevel1 edulevel2 lb_mod_age lstatus empstat njobs ocusec nlfreason                         ///
	     unempldur_l unempldur_u industry occup firmsize_l firmsize_u whours wage unitwage contract      ///
	     healthins socialsec union pci_i2d2 pci_d_i2d2 pcc_i2d2 pcc_d_i2d2 pcc_nat  pcc_d_nat pcc_125 pcc_d_125 pline_nat pline_125 poor_nat poor_125      ///
	spdef weighttype cpi cpiperiod survey vermast veralt welfare welfarenom welfaredef welfareother welfshprosperity welfareothertype welfaretype educat5 educat7



** ORDER VARIABLES
	order ccode year idh idp wgt strata psu urb reg01 reg02 ownhouse water electricity toilet landphone cellphone computer internet ///
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
	keep ccode year idh idp wgt strata psu `keep' *type

	save "`output'\Data\Harmonized\IND_2009_NSS_SCH1.dta", replace
	save "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\__REGIONAL\Final Files\Individual Files\IND_2009_NSS_SCH1.dta", replace
	/*

** FIXES FOR NORMAL I2D2
	drop *_nat *_125

	cap ren pci_i2d2 pci
	cap la var pci "Monthly Income Per Capita"

	cap ren pci_d_i2d2 pci_d
	cap label var pci_d "Income per capita deciles"

	cap ren pcc_i2d2 pcc
	cap la var pcc "Monthly Consumption Per Capita"

	cap ren pcc_d_i2d2 pcc_d
	cap label var pcc_d "Consumption per capita deciles"

	cap ren hhsize_i2d2 hhsize
	cap la var hhsize "Household Size"

	save "`input'\Processed\IND_2009_I2D2_NSS_SCH1.dta", replace
	save "D:\__CURRENT\IND_2009_I2D2_NSS_SCH1.dta", replace
	*/

	log close

















******************************  END OF DO-FILE  *****************************************************/
