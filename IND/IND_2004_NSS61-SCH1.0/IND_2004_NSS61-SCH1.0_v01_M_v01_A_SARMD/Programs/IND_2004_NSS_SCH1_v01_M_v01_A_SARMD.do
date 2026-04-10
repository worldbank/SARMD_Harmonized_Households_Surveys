/*****************************************************************************************************
******************************************************************************************************
**                                                                                                  **
**                                   SOUTH ASIA MICRO DATABASE                                      **
**                                                                                                  **
** COUNTRY	India
** COUNTRY ISO CODE	IND
** YEAR	2004
** SURVEY NAME	SOCIO-ECONOMIC SURVEY  SIXTY-FIRST ROUND JULY 2004-JUNE 2005
*	HOUSEHOLD SCHEDULE 10 : EMPLOYMENT AND UNEMPLOYMENT
** SURVEY AGENCY	GOVERNMENT OF INDIA NATIONAL SAMPLE SURVEY ORGANISATION
** RESPONSIBLE	Triana Yentzen
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
	set mem 700m


** DIRECTORY
	local input "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\IND\IND_2004_NSS-SCH1\IND_2004_NSS-SCH1_v01_M"
	local output "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\IND\IND_2004_NSS-SCH1\IND_2004_NSS-SCH1_v01_M_v01_A_SARMD"

** LOG FILE
	log using "`input'\Doc\Technical\IND_2004_NSS-SCH1.log",replace



/*****************************************************************************************************
*                                                                                                    *
                                   * ASSEMBLE DATABASE
*                                                                                                    *
*****************************************************************************************************/


** DATABASE ASSEMBLENT

	* PREPARE DATASETS
	
	use "`input'\Data\Stata\bk_4.dta"
	ren hhid hid
	* hhid = fsu hamlet secstage hhsno
	gen str2 z = string(hhsno,"%02.0f")
	egen hhid = concat(fsu hamlet secstage z)
	sort hhid personno
	tempfile roster
	save `roster'

	
	use "`input'\Data\Stata\bk_1_2_12.dta"
	ren hhid hid
	* hhid = fsu hamlet secstage hhsno
	gen str2 z = string(hhsno,"%02.0f")
	egen hhid = concat(fsu hamlet secstage z)
	sort hhid 
	tempfile survey
	save `survey'
	
	use "`input'\Data\Stata\bk_3a.dta"
	ren hhid hid
	* hhid = fsu hamlet secstage hhsno
	gen str2 z = string(hhsno,"%02.0f")
	egen hhid = concat(fsu hamlet secstage z)
	sort hhid 
	tempfile household1
	save `household1'

	use "`input'\Data\Stata\bk_3b.dta"
	ren hhid hid
	* hhid = fsu hamlet secstage hhsno
	gen str2 z = string(hhsno,"%02.0f")
	egen hhid = concat(fsu hamlet secstage z)
	sort hhid 
	tempfile household2
	save `household2'
	


	* MERGE DATABASES
	
	use "`input'\Data\Stata\poverty61.dta", clear

	keep hhid sector district hhsize mpce_mrp a16 pline poor pwt pline_ind_04

	su pline_ind_04 [w=pwt]
	gen pline_mrp=r(mean)

	gen mpce_mrp_real=mpce_mrp*pline_mrp/pline

	sort hhid
	
	gen pline_urp_sector=.
	replace pline_urp_sector=425.1 if sector==1
	replace pline_urp_sector=641.4 if sector==2

	su pline_urp_sector [w=pwt]
	gen pline_urp=r(mean)

	destring a16, gen(mpce_urp_100)
	gen mpce_urp=mpce_urp_100/(100*hhsize)

	gen mpce_urp_real=mpce_urp*(pline_urp/pline_urp_sector)
	la var mpce_urp_real "Real PC Monthly Consumption (URP)"
	ren pline_ind_04 pline_mrp_sector

	keep hhid mpce_urp_real mpce_mrp_real pline_urp pline_mrp pline_urp_sector pline_mrp_sector pline pwt

	order hhid mpce_urp_real mpce_mrp_real pline_urp pline_mrp pline_urp_sector pline_mrp_sector pline pwt

	* MERGE DATASETS
	
	merge 1:1 hhid using `survey'
	drop _merge
	
	merge 1:1 hhid using `household1'
	drop _merge
		
	merge 1:1 hhid using `household2'
	drop _merge
	
	merge 1:m hhid using `roster'
	drop _merge

/*****************************************************************************************************
*                                                                                                    *
                                   * STANDARD SURVEY MODULE
*                                                                                                    *
*****************************************************************************************************/


** COUNTRY
	gen countrycode="IND"
	label var countrycode "Country code"
	

** YEAR
	gen year=2004
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
	gen idh =hhid
	label var idh "Household id"

	sort hhid personno

** INDIVIDUAL IDENTIFICATION NUMBER
	egen  idp =concat(hhid personno)
	label var idp "Individual id"

** HOUSEHOLD WEIGHTS
	gen wgt=weight
	label var wgt "Household sampling weight"


** STRATA
	gen strata=stratum
	label var strata "Strata"

** PSU
	gen psu=fsu
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
	gen urban=.
	replace urban=1 if sector==2
	replace urban=0 if sector==1
	label var urban "Urban/Rural"
	la de lblurban 1 "Urban" 0 "Rural"
	label values urban lblurban

	
** REGIONAL AREA 1 DIGIT ADMN LEVEL
	tostring stat_reg, replace
	gen state=substr(stat_reg,1,length(stat_reg)-1)
	destring state, replace
	recode state (1 2 3 4 6 8 = 1) (5 7 9 10 23 = 2) (12/18 = 3) (11 19 20 21 22 35 = 4) ( 24 25 26 27 30 = 5) (28 29 31 32 33 34 = 6), gen(subnatid1)
	label define lblsubnatid1 1 "Northern" 2 "North-Central" 3 "North-Eastern" 4 "Eastern" 5 "Western" 6 "Southern"
	label var subnatid1 "Region at 1 digit (ADMN1)"
	label values subnatid1 lblsubnatid1


** REGIONAL AREA 2 DIGIT ADMN LEVEL
	gen subnatid2=state
	label define lblsubnatid2  28 "Andhra Pradesh"  18 "Assam"  10 "Bihar" 24 "Gujarat" 06 "Haryana"  02 "HimachalPradesh" ///
	01 "Jammu & Kashmir" 29"Karnataka" 32 "Kerala" 23 "Madhya Pradesh" 27  "Maharashtra" ///  
	14 "Manipur"   17 "Meghalaya"  13 "Nagaland"  21 "Orissa"  03 "Punjab" 08 "Rajasthan" 11 "Sikkim" ///
	33 "Tamil Nadu"  16 "Tripura"  09 "Uttar Pradesh"  19 "West Bengal" 35 "A & N Islands" ///
	12 "Arunachal Pradesh"  4 "Chandigarh" 26 "Dadra & Nagar Haveli" 7 "Delhi"  30 "Goa" ///
	31"Lakshdweep" 15 "Mizoram"  34 "Pondicherry"  25 "Daman & Diu" 22"Chhattisgarh" 20"Jharkhand" 5"Uttaranchal"
	label values subnatid2 lblsubnatid2
	label var subnatid2 "Region at 2 digit (ADMN2)"

	
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

	destring (lighting relation sex marstat age educatio), replace

** ELECTRICITY PUBLIC CONNECTION
	gen electricity=lighting==5
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
	ren hhsize hsize
	la variable hsize "Household size"

	bys idh: gen one=1 if  relation==1 
	bys idh: egen temp=count(one) 
	keep if temp==1


** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
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
The caste variable exist too, named "socialgrp"
*/
	gen soc=religion
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



** CAN READ AND WRITE
	gen literacy=educatio
	recode literacy (2/13 = 1) (1= 0)
	label var literacy "Can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy


** YEARS OF EDUCATION COMPLETED
	gen educy=educatio
	recode educy ( 1/2= 0) (3=2) (4=5) (5=8) (6 7=10) (8=12) (10=15) (11=17)
	label var educy "Years of education"

	
** EDUCATION LEVEL 7 CATEGORIES
	gen educat7=.
	replace educat7=1 if educatio==1 
	replace educat7=2 if educatio==3
	replace educat7=3 if educatio==4
	replace educat7=4 if educatio==5|educatio==6
	replace educat7=5 if educatio==7
	replace educat7=6 if educatio==8
	replace educat7=7 if educatio>8 & educatio!=.
	replace educat7=8 if educatio==2 
	label define lbleducat7 1 "No education" 2 "Primary incomplete" 3 "Primary complete" ///
	4 "Secondary incomplete" 5 "Secondary complete" 6 "Higher than secondary but not university" /// 
	7 "University incomplete or complete" 8 "Other" 9 "Not classified"
	label values educat7 educat7
	la var educat7 "Level of education 7 categories"

	
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

	recode educatio (1 2 = 0) (3/11=1), gen (everattend)
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

	gen industry=.

** INDUSTRY CLASSIFICATION
	label var industry "1 digit industry classification"
	la de lblindustry 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transports and comnunications" 8 "Financial and business-oriented services" 9 "Community and family oriented services" 10 "Others"
	label values industry lblindustry



** OCCUPATION CLASSIFICATION
	gen occup=.
	label var occup "1 digit occupational classification"
	label define lbloccup 1 "Senior officials" 2 "Professionals" 3 "Technicians" 4 "Clerks" ///
	5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" ///
	8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup lbloccup


**FIRMSIZE
	gen firmsize_l=.
	label var firmsize_l "Firm size (lower bracket)"

	gen firmsize_u=.
	label var firmsize_u "Firm size (upper bracket)"


**HOURS OF WORK
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


	gen healthins=.

** HEALTH INSURANCE
	label var healthins "Health insurance"
	la de lblhealthins 0 "Without health insurance" 1 "With health insurance"
	label values healthins lblhealthins

	gen socialsec=.

** SOCIAL SECURITY
	label var socialsec "Social security"
	la de lblsocialsec 1 "With" 0 "Without"
	label values socialsec lblsocialsec

	gen union=.

** UNION MEMBERSHIP
	la de lblunion 0 "No member" 1 "Member"
	label var union "Union membership"
	label values union lblunion

	local lb_var "lstatus empstat njobs ocusec nlfreason unempldur_l unempldur_u industry occup firmsize_l firmsize_u whours wage unitwage contract healthins socialsec union"
	foreach v in `lb_var'{
	di "check `v' only for age>=lb_mod_age"

	replace `v'=. if( age<lb_mod_age & age!=.)
	}
	label var occup "1 digit occupational classification"
	label define occup 1 "Senior officials" 2 "Professionals" 3 "Technicians" 4 "Clerks" ///
	5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" ///
	8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup occup
	replace occup=. if lstatus!=1

/*****************************************************************************************************
*                                                                                                    *
                                   LABOR MODULE FOR INDIA
*                                                                                                    *
*****************************************************************************************************/

* main income earner OF THE HOUSEHOLD (_e)

** LABOR STATUS
	gen lstatus_e=1 if hh_type!=.
	label var lstatus_e "Labor status (main earner)"
	la de lbllstatus_e 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus_e lbllstatus_e

** EMPLOYMENT STATUS
	gen empstat_e=.
	replace empstat_e=1 if hh_type==2
	replace empstat_e=4 if hh_type==1 | hh_type==4
	replace empstat_e=5 if hh_type==3 | hh_type==9
	label var empstat_e "Employment status (main earner)"
	la de lblempstat_e 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other"
	label values empstat_e lblempstat_e

** INDUSTRY CLASSIFICATION
	gen ind=int(nic_code/100)
	recode ind 	(11/50=1) (100/142=2) (150/390=3) (400/410=4) (450/470=5) (500/552=6) (601/642=7) (651/749=8) (750/753=9) (801/999=10), gen(industry_e)
	label var industry_e "1 digit industry classification (main earner)"
	la de lblindustry_e 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transports and comnunications" 8 "Financial and business-oriented services" 9 "Public Administration" 10 "Other services, Unspecified"
	label values industry_e lblindustry_e


** OCCUPATION CLASSIFICATION
	gen str3 princocc_NCO = string(nco_code,"%03.0f")
	gen princocc_CODE2=substr(princocc_NCO,1,2) 
	gen princocc_CODE3= princocc_NCO
	drop princocc_NCO
	gen occup_e=.

	*professional

	replace occup_e=2 if princocc_CODE3=="000" | princocc_CODE3=="001" | princocc_CODE3=="002" | princocc_CODE3=="003"
	replace occup_e=2 if princocc_CODE3=="004" | princocc_CODE3=="006" | princocc_CODE3=="008"
	replace occup_e=2 if princocc_CODE3=="020" | princocc_CODE3=="021" | princocc_CODE3=="022" | princocc_CODE3=="023"
	replace occup_e=2 if princocc_CODE3=="024" | princocc_CODE3=="025" | princocc_CODE3=="026" | princocc_CODE3=="027"
	replace occup_e=2 if princocc_CODE3=="050" | princocc_CODE3=="051" | princocc_CODE3=="052" | princocc_CODE3=="053"
	replace occup_e=2 if princocc_CODE3=="054" | princocc_CODE3=="057" 
	replace occup_e=2 if princocc_CODE3=="070" | princocc_CODE3=="071" | princocc_CODE3=="072" | princocc_CODE3=="073"

	replace occup_e=2 if princocc_CODE3=="074" | princocc_CODE3=="075" | princocc_CODE3=="076" | princocc_CODE3=="084"
	replace occup_e=2 if princocc_CODE3=="085"  | princocc_CODE3=="147"
	replace occup_e=2 if princocc_CODE3=="140" | princocc_CODE3=="141" | princocc_CODE3=="149" | princocc_CODE3=="180"

	replace occup_e=2 if princocc_CODE3=="181" | princocc_CODE3=="182" | princocc_CODE3=="183" | princocc_CODE3=="185"
	replace occup_e=2 if princocc_CODE3=="186" | princocc_CODE3=="187" | princocc_CODE3=="188" | princocc_CODE3=="189"

	replace occup_e=2 if princocc_CODE2=="10" | princocc_CODE2=="11" | princocc_CODE2=="12" | princocc_CODE2=="13"

	replace occup_e=2 if princocc_CODE2=="15" | princocc_CODE2=="16" | princocc_CODE2=="17" | princocc_CODE2=="19"

	*technician and associate profesionals

	replace occup_e=3 if princocc_CODE3=="009" | princocc_CODE3=="010" | princocc_CODE3=="019" | princocc_CODE3=="028"
	replace occup_e=3 if princocc_CODE3=="011" | princocc_CODE3=="012" | princocc_CODE3=="014" | princocc_CODE3=="015"
	replace occup_e=3 if princocc_CODE3=="017" | princocc_CODE3=="018" 
	replace occup_e=3 if princocc_CODE3=="029" | princocc_CODE3=="059" | princocc_CODE3=="077" | princocc_CODE3=="078"
	replace occup_e=3 if princocc_CODE3=="079" | princocc_CODE3=="080" | princocc_CODE3=="081" | princocc_CODE3=="082"
	replace occup_e=3 if princocc_CODE3=="083" | princocc_CODE3=="086" | princocc_CODE3=="087" | princocc_CODE3=="088"
	replace occup_e=3 if princocc_CODE3=="089" | princocc_CODE3=="142" | princocc_CODE3=="184" 

	replace occup_e=3 if princocc_CODE2=="03" | princocc_CODE2=="04" | princocc_CODE2=="06" | princocc_CODE2=="09"

	*legislators, senior officials and managers

	replace occup_e=1 if princocc_CODE2=="20" | princocc_CODE2=="21" | princocc_CODE2=="22" | princocc_CODE2=="23"
	replace occup_e=1 if princocc_CODE2=="24" | princocc_CODE2=="25" | princocc_CODE2=="26" | princocc_CODE2=="29" | princocc_CODE2=="27" | princocc_CODE2=="28"

	replace occup_e=1 if princocc_CODE2=="30" | princocc_CODE2=="31" | princocc_CODE2=="36"  | princocc_CODE2=="60" 

	*clerks

	replace occup_e=4 if princocc_CODE2=="32" | princocc_CODE2=="33" | princocc_CODE2=="34" | princocc_CODE2=="35"

	replace occup_e=4 if princocc_CODE2=="37" | princocc_CODE2=="38" | princocc_CODE2=="39" 

	replace occup_e=4 if princocc_CODE3=="302" 

	*Service workers and shop and market sales

	replace occup_e=5 if princocc_CODE2=="40" | princocc_CODE2=="41" | princocc_CODE2=="42" | princocc_CODE2=="43"
	replace occup_e=5 if princocc_CODE2=="44" | princocc_CODE2=="45" | princocc_CODE2=="49" | princocc_CODE2=="50"
	replace occup_e=5 if princocc_CODE2=="46" | princocc_CODE2=="47" | princocc_CODE2=="48" 
	replace occup_e=5 if princocc_CODE2=="51" | princocc_CODE2=="52" | princocc_CODE2=="53" | princocc_CODE2=="54"
	replace occup_e=5 if princocc_CODE2=="55" | princocc_CODE2=="56" | princocc_CODE2=="57" | princocc_CODE2=="58" | princocc_CODE2=="59"

	*skilled agricultural and fishery workers

	replace occup_e=6 if princocc_CODE2=="61" | princocc_CODE2=="62" | princocc_CODE2=="63" | princocc_CODE2=="64"
	replace occup_e=6 if princocc_CODE2=="65" | princocc_CODE2=="66" | princocc_CODE2=="67" | princocc_CODE2=="68" | princocc_CODE2=="69"

	*Craft and related trades

	replace occup_e=7 if princocc_CODE2=="71" | princocc_CODE2=="72" | princocc_CODE2=="73" | princocc_CODE2=="75" | princocc_CODE2=="70"
	replace occup_e=7 if princocc_CODE2=="76" | princocc_CODE2=="77" | princocc_CODE2=="78" | princocc_CODE2=="79"
	replace occup_e=7 if princocc_CODE2=="80" | princocc_CODE2=="81" | princocc_CODE2=="82" | princocc_CODE2=="92"
	replace occup_e=7 if princocc_CODE2=="93" | princocc_CODE2=="94" | princocc_CODE2=="95" 

	*Plant and machine operators and assemblers

	replace occup_e=8 if princocc_CODE2=="74" | princocc_CODE2=="83" | princocc_CODE2=="84" | princocc_CODE2=="85"
	replace occup_e=8 if princocc_CODE2=="86" | princocc_CODE2=="87" | princocc_CODE2=="88" | princocc_CODE2=="89"
	replace occup_e=8 if princocc_CODE2=="90" | princocc_CODE2=="91" | princocc_CODE2=="96" | princocc_CODE2=="97"
	replace occup_e=8 if princocc_CODE2=="98" 
	replace occup_e=8 if princocc_CODE3=="813" 

	*elementary occupations

	replace occup_e=9 if princocc_CODE2=="99" 

	*other/unspecified

	replace occup_e=99 if princocc_CODE2=="X0" | princocc_CODE2=="X1" | princocc_CODE2=="X9" 

	*legislators, senior officials and managers CONTT.

	replace occup_e=1 if princocc_CODE3=="710" | princocc_CODE3=="720" | princocc_CODE3=="730" | princocc_CODE3=="740"
	replace occup_e=1 if princocc_CODE3=="750" | princocc_CODE3=="760" | princocc_CODE3=="770" | princocc_CODE3=="780"  
	replace occup_e=1 if princocc_CODE3=="790" | princocc_CODE3=="800" | princocc_CODE3=="810" | princocc_CODE3=="820" 
	replace occup_e=1 if princocc_CODE3=="830" | princocc_CODE3=="840" | princocc_CODE3=="850" | princocc_CODE3=="860"  
	replace occup_e=1 if princocc_CODE3=="870" | princocc_CODE3=="880" | princocc_CODE3=="890" | princocc_CODE3=="900" 
	replace occup_e=1 if princocc_CODE3=="910" | princocc_CODE3=="920" | princocc_CODE3=="930" | princocc_CODE3=="940"  
	replace occup_e=1 if princocc_CODE3=="950" | princocc_CODE3=="960" | princocc_CODE3=="970" | princocc_CODE3=="980"

	drop  princocc_CODE2 princocc_CODE3

	label var occup_e "1 digit occupational classification (main earner)"
	label define occup_e 1 "Senior officials" 2 "Professionals" 3 "Technicians" 4 "Clerks" ///
	5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" ///
	8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup_e occup_e

	note lstatus_e: 	Data recolected only for main income earner of the household.
	note empstat_e: 	Data recolected only for main income earner of the household.
	note industry_e: 	Data recolected only for main income earner of the household.
	note occup_e: 		Data recolected only for main income earner of the household.

/*****************************************************************************************************
*                                                                                                    *
                                   WELFARE MODULE
*                                                                                                    *
*****************************************************************************************************/


** SPATIAL DEFLATOR
	gen spdef=pline
	la var spdef "Spatial deflator"


** WELFARE
	gen welfare=mpce30d/(hsize*100)
	la var welfare "Welfare aggregate"

	gen welfarenom=welfare
	la var welfarenom "Welfare aggregate in nominal terms"

	gen welfaredef=mpce_urp_real
	la var welfaredef "Welfare aggregate spatially deflated"

	gen welfaretype="CONS"
	la var welfaretype "Type of welfare measure (income, consumption or expenditure) for welfare, welfarenom, welfaredef"

	gen welfareother=mpce365/(hsize*100)
	la var welfareother "Welfare Aggregate if different welfare type is used from welfare, welfarenom, welfaredef"

	gen welfareothertype="CON"
	la var welfareothertype "Type of welfare measure (income, consumption or expenditure) for welfareother"


/*****************************************************************************************************
*                                                                                                    *
                                   NATIONAL POVERTY
*                                                                                                    *
*****************************************************************************************************/


** POVERTY LINE (NATIONAL)
	ren pline pline_nat
	label variable pline_nat "Poverty Line (National)"


** HEADCOUNT RATIO (NATIONAL)
	gen poor_nat=welfareother<pline_nat & welfareother!=.
	la var poor_nat "People below Poverty Line (National)"
	la define poor_nat 0 "Not Poor" 1 "Poor"
	la values poor_nat poor_nat


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
	gen pline_int=1.90*cpi*ppp*365/12
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

	keep countrycode year idh idp wgt strata psu vermast veralt urban int_month int_year  ///
	     subnatid1 subnatid2 subnatid3 ownhouse water electricity toilet landphone cellphone ///
	     computer internet hsize relationharm relationcs male age soc marital ed_mod_age everattend ///
	     atschool electricity literacy educy educat4 educat5 educat7 lb_mod_age lstatus empstat njobs ///
	     ocusec nlfreason unempldur_l unempldur_u industry occup firmsize_l firmsize_u whours wage ///
		 unitwage contract healthins socialsec union lstatus_e empstat_e industry_e occup_e  ///
		 pline_nat pline_int poor_nat poor_int spdef cpi ppp cpiperiod welfare welfarenom welfaredef ///
		 welfareother welfaretype welfareothertype

** ORDER VARIABLES

	order countrycode year idh idp wgt strata psu vermast veralt urban int_month int_year  ///
	      subnatid1 subnatid2 subnatid3 ownhouse water electricity toilet landphone cellphone ///
	      computer internet hsize relationharm relationcs male age soc marital ed_mod_age everattend ///
	      atschool electricity literacy educy educat4 educat5 educat7 lb_mod_age lstatus empstat njobs ///
	      ocusec nlfreason unempldur_l unempldur_u industry occup firmsize_l firmsize_u whours wage ///
		  unitwage contract healthins socialsec union lstatus_e empstat_e industry_e occup_e  ///
		  pline_nat pline_int poor_nat poor_int spdef cpi ppp cpiperiod welfare welfarenom welfaredef ///
		  welfareother welfaretype welfareothertype
	
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

	saveold "`output'\Data\Harmonized\IND_2004_NSS-SCH1_v01_M_v01_A_SARMD_IND.dta", replace version(13)
	saveold "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\__REGIONAL\Individual Files\IND_2004_NSS-SCH1_v01_M_v01_A_SARMD_IND.dta", replace version(13)


	log close



******************************  END OF DO-FILE  *****************************************************/
