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
** CREATED  BY Triana Yentzen
** MODIFIED BY Fernando Enrique Morales Velandia 
** Modified	 9/12/2017  
                                                              
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
	local input "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\IND\IND_2004_NSS61-SCH1.0\IND_2004_NSS61-SCH1.0_v01_M"
	local output "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\IND\IND_2004_NSS61-SCH1.0\IND_2004_NSS61-SCH1.0_v01_M_v03_A_SARMD"
	glo pricedata "D:\SOUTH ASIA MICRO DATABASE\CPI\cpi_ppp_sarmd_weighted.dta"
	glo fixlabels "D:\SOUTH ASIA MICRO DATABASE\APPS\DATA CHECK\Label fixing"


** LOG FILE
	log using "`output'\Doc\Technical\IND_2004_NSS61-SCH1.0_v01_M_v03_A_SARMD.log",replace



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
	

	*Assets
	use "`input'\Data\Stata\bk_11.dta"
    ren hhid hid
    gen str2 z = string(hhsno,"%02.0f")
	egen hhid = concat(fsu hamlet secstage z)
	sort hhid 
	
	keep if inlist(item_cod, 561, 562, 590, 593, 594, 595, 598, 610, 611, 612, 632, 633)
	keep hhid item_cod possess
	reshape wide possess, i(hhid) j(item_cod)
	tempfile assets
	save `assets'
	
	
	* MERGE DATABASES
	
	use "`input'\Data\Stata\poverty61.dta", clear

	keep hhid sector district state hhsize mpce_mrp a16 pline poor pwt pline_ind_04

	su pline_ind_04 [w=pwt]
	gen pline_mrp=r(mean)

	gen mpce_mrp_real=mpce_mrp*pline_mrp/pline

	sort hhid
	
*	gen pline_urp_sector=.
*	replace pline_urp_sector=425.1 if sector==1
*	replace pline_urp_sector=641.4 if sector==2

	su pline [w=pwt]
	gen pline_urp=r(mean)

	destring a16, gen(mpce_urp_100)
	gen mpce_urp=mpce_urp_100/(100*hhsize)

	gen mpce_urp_real=mpce_urp*(pline_urp/pline)
	la var mpce_urp_real "Real PC Monthly Consumption (URP)"
	ren pline_ind_04 pline_mrp_sector

	keep  state hhid mpce_urp_real mpce_mrp_real pline_urp pline_mrp pline_mrp_sector pline pwt

	order state hhid mpce_urp_real mpce_mrp_real pline_urp pline_mrp pline_mrp_sector pline pwt

	* MERGE DATASETS
	
	merge 1:1 hhid using `survey'
	drop _merge
	
	merge 1:1 hhid using `household1'
	drop _merge
		
	merge 1:1 hhid using `household2'
	drop _merge
	
	merge 1:1 hhid using `assets'
	drop _merge
	
	
	merge 1:m hhid using `roster'
	drop _merge
	

/*****************************************************************************************************
*                                                                                                    *
                                   * STANDARD SURVEY MODULE
*                                                                                                    *
*****************************************************************************************************/

	
** COUNTRY
*<_countrycode_>
	gen str4 countrycode="IND"
	label var countrycode "Country code"
*</_countrycode_>
	

** YEAR
*<_year_>
	gen int year=2004
	label var year "Year of survey"
*</_year_>

** SURVEY NAME 
*<_survey_>
	gen str survey="NSS-SCH1"
	label var survey "Survey Acronym"
*</_survey_>


	
** INTERVIEW YEAR
*<_int_year_>
	tostring date_srv,replace
	gen year1=substr( date_srv, 4,2 ) if strlen( date_srv )==5
	replace year1=substr( date_srv, 5,2 ) if strlen( date_srv )==6
	destring year1, replace
	replace year1=2004 if year1==4
	replace year1=2005 if year1==5
	ren year1 int_year
	label var int_year "Year of the interview"
*</_int_year_>
	
	
** INTERVIEW MONTH
*<_int_month_>
	gen month1=substr( date_srv, 2,2 ) if strlen( date_srv )==5
	replace month1=substr( date_srv, 3,2 ) if strlen( date_srv )==6
	destring month1, replace 
	gen byte int_month=month1
	la de lblint_month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
	label value int_month lblint_month
	label var int_month "Month of the interview"
	replace int_month=. if int_month>=7 & int_year==2005

*</_int_month_>
	
	
**FIELD WORKD***
*<_fieldwork_> 
gen fieldwork=ym(int_year, int_month)
format %tm fieldwork
replace fieldwork=. if int_month>=7 & int_year==2005
replace int_year=. if int_month>=7 & int_year==2005

la var fieldwork "Date of fieldwork"
*<_/fieldwork_> 
		
** HOUSEHOLD IDENTIFICATION NUMBER
*<_idh_>
	gen idh =hhid
	label var idh "Household id"
	sort hhid personno
*</_idh_>

	
** INDIVIDUAL IDENTIFICATION NUMBER
*<_idp_>

	egen  idp =concat(hhid personno), punct(-)	
	label var idp "Individual id"
*</_idp_>

	
** HOUSEHOLD WEIGHTS
*<_wgt_>
	gen wgt=weight
	label var wgt "Household sampling weight"
*</_wgt_>


** STRATA
*<_strata_>
	gen strata=stratum
	label var strata "Strata"
*</_strata_>

** PSU
*<_psu_>
	gen psu=fsu
	label var psu "Primary sampling units"
*</_psu_>

	
** MASTER VERSION
*<_vermast_>

	gen vermast="01"
	label var vermast "Master Version"
*</_vermast_>
	
	
** ALTERATION VERSION
*<_veralt_>

	gen veralt="03"
	label var veralt "Alteration Version"
*</_veralt_>	
	
	
/*****************************************************************************************************
*                                                                                                    *
                                   HOUSEHOLD CHARACTERISTICS MODULE
*                                                                                                    *
*****************************************************************************************************/


** LOCATION (URBAN/RURAL)
*<_urban_>
	gen urban=.
	replace urban=1 if sector==2
	replace urban=0 if sector==1
	label var urban "Urban/Rural"
	la de lblurban 1 "Urban" 0 "Rural"
	label values urban lblurban
*</_urban_>

	
/*** REGIONAL AREA 1 DIGIT ADMN LEVEL
*<_subnatid1_>
	recode state (1 2 3 4 6 8 = 1) (5 7 9 10 23 = 2) (12/18 = 3) (11 19 20 21 22 35 = 4) ( 24 25 26 27 30 = 5) (28 29 31 32 33 34 = 6), gen(subnatid1)
	label define lblsubnatid1 1 "Northern" 2 "North-Central" 3 "North-Eastern" 4 "Eastern" 5 "Western" 6 "Southern"*/
	gen subnatid2=.
	label values subnatid2 lblsubnatid2
	label var subnatid2 "Region at 2 digit (ADMN2)"
*</_subnatid1_>


** REGIONAL AREA 2 DIGIT ADMN LEVEL
*<_subnatid2_>
	gen subnatid1=state
	label define lblsubnatid1 1 "Jammu & Kashmir" 2 "Himachal Pradesh" 3 "Punjab" 4 "Chandigarh"          ///
	5 "Uttaranchal" 6 "Haryana" 7 "Delhi" 8 "Rajasthan" 9 "Uttar Pradesh" 10 "Bihar" 11 "Sikkim"           /// 
	12 "Arunachal Pradesh" 13 "Nagaland" 14 "Manipur" 15 "Mizoram" 16 "Tripura" 17 "Meghalaya"              ///
	18 "Assam" 19 "West Bengal" 20"Jharkhand" 21 "Orissa" 22"Chhattisgarh" 23 "Madhya Pradesh"              ///
	24 "Gujarat" 25 "Daman & Diu" 26 "Dadra & Nagar Haveli" 27 "Maharashtra" 28 "Andhra Pradesh"           ///
	29"Karnataka" 30 "Goa" 31"Lakshadweep" 32 "Kerala" 33 "Tamil Nadu" 34 "Pondicherry" 35 "A & N Islands"         
	label values subnatid1 lblsubnatid1
	label var subnatid1 "Region at 1 digit (ADMN1)"

*</_subnatid2_>

	
** REGIONAL AREA 3 DIGIT ADMN LEVEL
*<_subnatid3_>
	gen byte subnatid3=.
	label var subnatid3 "Region at 3 digit (ADMN3)"
	label values subnatid3 lblsubnatid3
*</_subnatid3_>
	

** HOUSE OWNERSHIP
*<_ownhouse_>
	gen ownhouse=1 if dwelling==1
	replace ownhouse=0 if !inlist(dwelling, 1, .)
	label var ownhouse "House ownership"
	la de lblownhouse 0 "No" 1 "Yes"
	label values ownhouse lblownhouse
*</_ownhouse_>

** TENURE OF DWELLING
*<_tenure_>
   gen tenure=.
   replace tenure=1 if dwelling==1
   replace tenure=2 if dwelling==2 
   replace tenure=3 if dwelling==3 | dwelling==9
   label var tenure "Tenure of Dwelling"
   la de lbltenure 1 "Owner" 2"Renter" 3"Other"
   la val tenure lbltenure
*</_tenure_>


** LANDHOLDING
*<_landholding_>
   gen landholding=1 if ownland==1
   replace landholding=0 if ownland==2
   label var landholding "Household owns any land"
   la de lbllandholding 0 "No" 1 "Yes"
   la val landholding lbllandholding
*</_landholding_>	


** WATER PUBLIC CONNECTION
*<_water_>
	gen water=.
	label var water "Water main source"
	la de lblwater 0 "No" 1 "Yes"
	label values water lblwater
*</_water_>


** ELECTRICITY PUBLIC CONNECTION
*<_electricity_>
	destring (lighting relation sex marstat age educatio), replace
	gen electricity=lighting
	recode electricity (5=1) (1 2 3 4 6 9=0)	
	label var electricity "Electricity main source"
	la de lblelectricity 0 "No" 1 "Yes"
	label values electricity lblelectricity
*</_electricity_>

** TOILET PUBLIC CONNECTION
*<_toilet_>

	gen toilet=.
	label var toilet "Toilet facility"
	la de lbltoilet 0 "No" 1 "Yes"
	label values toilet lbltoilet
*</_toilet_>


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
*<_hsize_>
	ren hhsize hsize
	label var hsize "Household size"
*</_hsize_>


**POPULATION WEIGHT
*<_pop_wgt_>
	gen pop_wgt=wgt*hsize
	la var pop_wgt "Population weight"
*</_pop_wgt_>

** HOUSEHOLD WEIGHTS FOR THE WDI
*<_wgt_wdi_>

egen wgt_urban=total(wgt) if urban==1
egen wgt_rural=total(wgt) if urban==0

gen wgt_wdi=wgt*(329985059/wgt_urban) if urban==1
replace wgt_wdi=wgt*(805142166.5/wgt_rural) if urban==0
label var wgt_wdi "Household sampling weight using WDI population growth"
*</_wgt_wdi_>

** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
*<_relationharm_>
	gen relationharm= relation
	recode relationharm (3 5 = 3) (7=4) (4 6 8 = 5) (9=6)
	label var relationharm "Relationship to the head of household"
	la de lblrelationharm  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Non-relatives"
	label values relationharm  lblrelationharm
*</_relationharm_>

** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
*<_relationcs_>

	gen byte relationcs=relation
	la var relationcs "Relationship to the head of household country/region specific"
	label define lblrelationcs 1 "Head" 2 "Spouse of head" 3 "married child" 4 "spouse of married child"  ///
	5 "unmarried child" 6 "grandchild" 7 "father/mother/father-in-law/mother-in-law" ///
	8 "brother/sister/brother-in-law/sister-in-law/other relations" 9 "servant/employee/other non-relative"
	label values relationcs lblrelationcs
*</_relationcs_>

** GENDER
*<_male_>
	gen male= sex
	recode male (2=0)
	label var male "Sex of household member"
	la de lblmale 1 "Male" 0 "Female"
	label values male lblmale
*</_male_>


** AGE
*<_age_>
	label var age "Age of individual"
	* Fix Age
	replace age=. if age>200
	gen head_age=age if relationharm==1
	bys idh: egen h_age=max(head_age)
	gen spouse=1 if relationharm==2
	bys idh: egen spouses=total(spouse)
	replace relationharm=6 if relationharm==2 & spouses>1 & spouses!=. & age>h_age+20
	drop head_age h_age spouse spouses
	replace age=98 if age>98 & age<.
	
*</_age_>	

** SOCIAL GROUP
*<_soc_>

/*
The caste variable exist too, named "socialgrp"
*/
	gen soc=religion
	label var soc "Social group"
	label define lblsoc 1 "Hinduism" 2 "Islam" 3 "Christianity" 4 "Sikhism" 5 "Jainism" 6 "Buddhism" 7 "Zoroastrianism" 9 "Others"
	label values soc lblsoc
*</_soc_>


** MARITAL STATUS
*<_marital_>
gen marital=marstat
	recode marital (1=2) (2=1) (3=5)
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
	gen ed_mod_age=0
	label var ed_mod_age "Education module application age"
*</_ed_mod_age_>


** CURRENTLY AT SCHOOL
*<_atschool_>
	gen atschool=.
	label var atschool "Attending school"
	la de lblatschool 0 "No" 1 "Yes"
	label values atschool  lblatschool
*</_atschool_>



** CAN READ AND WRITE
*<_literacy_>
	gen literacy=educatio
	recode literacy (2/13 = 1) (1= 0)
	label var literacy "Can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy
*</_literacy_>


** YEARS OF EDUCATION COMPLETED
*<_educy_>
	gen educy=educatio
	recode educy ( 1/2= 0) (3=2) (4=5) (5=8) (6 7=10) (8=12) (10=15) (11=17)
	label var educy "Years of education"
	replace educy=. if educy>age & educy!=. & age!=.
*</_educy_>

** EDUCATION LEVEL 7 CATEGORIES
*<_educat7_>
	gen educat7=.
	replace educat7=1 if educatio==1 | educatio==2
	replace educat7=2 if educatio==3
	replace educat7=3 if educatio==4
	replace educat7=4 if educatio==5 | educatio==6
	replace educat7=5 if educatio==7
	replace educat7=6 if educatio==8
	replace educat7=7 if educatio>8 & educatio!=.
	la var educat7 "Level of education 7 categories"
	label define lbleducat7 1 "No education" 2 "Primary incomplete" 3 "Primary complete" ///
	4 "Secondary incomplete" 5 "Secondary complete" 6 "Higher than secondary but not university" /// 
	7 "University incomplete or complete" 8 "Other" 9 "Not classified"
	label values educat7 lbleducat7 
*</_educat7_>

	
** EDUCATION LEVEL 5 CATEGORIES
*<_educat5_>
	gen educat5=.
	replace educat5=1 if educat7==1 
	replace educat5=2 if educat7==2
	replace educat5=3 if educat7==3 | educat7==4
	replace educat5=4 if educat7==5
	replace educat5=5 if educat7==6 | educat7==7
	la var educat5 "Level of education 5 categories"
	label define lbleducat5 1 "No education" 2 "Primary incomplete" ///
	3 "Primary complete but secondary incomplete" 4 "Secondary complete" ///
	5 "Some tertiary/post-secondary"
	label values educat5 lbleducat5
*</_educat5_>


** EDUCATION LEVEL 4 CATEGORIES
*<_educat4_>
	gen educat4=.
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
	recode educatio (1 2 = 0) (3/11=1), gen (everattend)
	label var everattend "Ever attended school"
	la de lbleverattend 0 "No" 1 "Yes"
	label values everattend lbleverattend
*</_everattend_>

/*****************************************************************************************************
*                                                                                                    *
                                   LABOR MODULE
*                                                                                                    *
*****************************************************************************************************/


** LABOR MODULE AGE
*<_lb_mod_age_>
	gen lb_mod_age=.
	label var lb_mod_age "Labor module application age"
*</_lb_mod_age_>


** LABOR STATUS
*<_lstatus_>
	gen lstatus=.
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus
*</_lstatus_>
	replace lstatus=. if  age<lb_mod_age


** EMPLOYMENT STATUS
*<_empstat_>
	gen empstat=.
	label var empstat "Employment status"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed"
	label values empstat lblempstat
*</_empstat_>


** SECTOR OF ACTIVITY: PUBLIC - PRIVATE
*<_njobs_>
	gen njobs=.
	label var njobs "Number of additional jobs"
*</_njobs_>


** SECTOR OF ACTIVITY: PUBLIC - PRIVATE
*<_ocusec_>
	gen ocusec=.
	label var ocusec "Sector of activity"
	la de lblocusec 1 "Public, state owned, government, army" 2 "NGO" 3 "Private"
	label values ocusec lblocusec
*</_ocusec_>
	replace ocusec=. if lstatus!=1


** REASONS NOT IN THE LABOR FORCE
*<_nlfreason_>
	gen nlfreason=.
	label var nlfreason "Reason not in the labor force"
	la de lblnlfreason 1 "Student" 2 "Housewife" 3 "Retired" 4 "Disable" 5 "Other"
	label values nlfreason lblnlfreason
*</_nlfreason_>

** UNEMPLOYMENT DURATION: MONTHS LOOKING FOR A JOB
*<_unempldur_l_>
	gen unempldur_l=.
	label var unempldur_l "Unemployment duration (months) lower bracket"
*</_unempldur_l_>

*<_unempldur_u_>
	gen unempldur_u=.
	label var unempldur_u "Unemployment duration (months) upper bracket"
*</_unempldur_u_>
	gen industry=.

** INDUSTRY CLASSIFICATION
*<_industry_>
	label var industry "1 digit industry classification"
	la de lblindustry 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transports and comnunications" 8 "Financial and business-oriented services" 9 "Community and family oriented services" 10 "Others"
	label values industry lblindustry
*</_industry_>


** OCCUPATION CLASSIFICATION
*<_occup_>
	gen occup=.
	label var occup "1 digit occupational classification"
	label define lbloccup 1 "Senior officials" 2 "Professionals" 3 "Technicians" 4 "Clerks" ///
	5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" ///
	8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup lbloccup
*</_occup_>


** FIRM SIZE
*<_firmsize_l_>
	gen firmsize_l=.
	label var firmsize_l "Firm size (lower bracket)"
*</_firmsize_l_>

*<_firmsize_u_>
	gen firmsize_u=.
	label var firmsize_u "Firm size (upper bracket)"
*</_firmsize_u_>


** HOURS WORKED LAST WEEK
*<_whours_>
	gen whours=.
	label var whours "Hours of work in last week"
*</_whours_>


** WAGES
*<_wage_>
	gen wage=.
	label var wage "Last wage payment"
*</_wage_>

** WAGES TIME UNIT
*<_unitwage_>
	gen unitwage=.
	label var unitwage "Last wages time unit"
	la de lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Trimester" 7 "Biannual" 8 "Annually" 9 "Hourly" 
	label values unitwage lblunitwage
*</_wageunit_>


** CONTRACT
*<_contract_>
	gen contract=.
	label var contract "Contract"
	la de lblcontract 0 "Without contract" 1 "With contract"
	label values contract lblcontract
*</_contract_>


** HEALTH INSURANCE
*<_healthins_>
    gen healthins=.
	label var healthins "Health insurance"
	la de lblhealthins 0 "Without health insurance" 1 "With health insurance"
	label values healthins lblhealthins
*</_healthins_>

	

** SOCIAL SECURITY
*<_socialsec_>
    gen socialsec=.
	label var socialsec "Social security"
	la de lblsocialsec 1 "With" 0 "Without"
	label values socialsec lblsocialsec
*</_socialsec_>

	
** UNION MEMBERSHIP
*<_union_>
    gen union=.
	la de lblunion 0 "No member" 1 "Member"
	label var union "Union membership"
	label values union lblunion
*</_union_>

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

** LABOR STATUS MAIN EARNER
*<_lstatus_e_>
	gen lstatus_e=.
	label var lstatus_e "Labor status (main earner)"
	la de lbllstatus_e 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus_e lbllstatus_e
*</_lstatus_e_>


** EMPLOYMENT STATUS MAIN EARNER
*<_empstat_e_>
	gen empstat_e=.
	replace empstat_e=1 if hh_type==2
	replace empstat_e=4 if hh_type==1 | hh_type==4
	replace empstat_e=5 if hh_type==3 | hh_type==9
	label var empstat_e "Employment status (main earner)"
	la de lblempstat_e 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other"
	label values empstat_e lblempstat_e
*</_empstat_e_>

**ORIGINAL INDUSTRY CLASSIFICATION
*<_industry_e_orig_>
	gen industry_e_orig=nic_code
	la val industry_e_orig lblindustry_e_orig
	la var industry_e_orig "Original industry code"
*</_industry_e_orig_>

** INDUSTRY CLASSIFICATION MAIN EARNER
*<_industry_e_>
	gen ind=int(nic_code/100)
	recode ind 	(11/50=1) (100/142=2) (151/372=3) (401/410=4) (451/455=5) (501/552=6) ///
	(601/642=7) (651/749=8) (751/753=9) (801/990=10), gen(industry_e)
	label var industry_e "1 digit industry classification (main earner)"
	la de lblindustry_e 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities"  ///
	5 "Construction"  6 "Commerce" 7 "Transports and comnunications" ///
	8 "Financial and business-oriented services" 9 "Public Administration" 10 "Other services, Unspecified"
	label values industry_e lblindustry_e
*</_industry_e_>




**ORIGINAL OCCUPATION CLASSIFICATION
*<_occup_orig_>
	gen occup_e_orig=nco_code
	#delimit
	label define lbloccup_e_orig 
	0	"Physicist"
	1	"Chemists (Excluding Pharmaceutical Chemists)"
	2	"Geologists And Geophysicists"
	3	"Meteorologist"
	9	"Physical Scientists, N"
	10	"Physical Science Technicians"
	20	"Architects And Town Planners"
	21	"Civil Engineers"
	22	"Electrical And Electronic Engineers"
	23	"Mechanical Engineers"
	24	"Chemical Engineers"
	25	"Metallurgists"
	26	"Mining Engineers"
	27	"Industrial Engineers"
	28	"Surveyors"
	29	"Architects, Engineers, Technologists And Surveyors ,N"
	30	"Draughtsmen"
	31	"Civil Engineering Overseers And Technicians"
	32	"Electrical And Electronic Engineering Overseers And Technicians"
	33	"Mechanical Engineering Overseers And Technicians"
	34	"Chemical Engineering Technicians"
	35	"Metallurgical Technicians"
	36	"Mining Technicians"
	37	"Survey Technicians"
	39	"Engineering Technicians, N"
	40	"Aircraft Pilots"
	41	"Flight Engineers"
	42	"Flight Navigators"
	43	"Ship'S Deck Officers And Pilots"
	44	"Ships Engineers"
	49	"Aircraft And Ship'S Officers, N"
	50	"Biologists, Zoologists, Botanists And Related Scientists"
	51	"Bacteriologists, Pharmacologists &Related Scientists"
	52	"Silviculturists"
	53	"Agronomists And Agricultural Scientists"
	59	"Life Scientists, N"
	60	"Life Science Technicians"
	70	"Physicians And Surgeons, Allopathic"
	71	"Physicians And Surgeons, Ayurvedic"
	72	"Physicians And Surgeons, Homoeopathic"
	73	"Physician And Surgeons, Unani"
	74	"Dental Surgeons"
	75	"Veterinarians"
	76	"Pharmacists"
	77	"Dieticians And Nutritionists"
	78	"Public Health Physicians"
	79	"Physicians And Surgeons, N"
	80	"Vaccinators, Inoculators And Medical Assistants"
	81	"Dental Assistants"
	83	"Pharmaceutical Assistants"
	84	"Nurses"
	85	"Midwives And Health Visitors"
	86	"X-Ray Technicians"
	87	"Optometrists And Opticians"
	88	"Physiotherapists And Occupational Therapists"
	89	"Technicians , N"
	90	"Scientific Medical And Technical Persons, Other"
	100	"Mthematiciansa"
	101	"Statisticians"
	102	"Actuaries"
	103	"System Analysts And Programmers"
	104	"Statistical Investigators And Related Workers"
	109	"Mathematicians, Statisticians & Related Workers ,N"
	110	"Economists"
	111	"Economic Investigators And Related Workers"
	119	"Economists And Related Workers, N"
	120	"Accountants And Auditors"
	121	"Cost And Works Accountants"
	129	"Accountants, Auditors And Related Workers, N"
	130	"Sociologists And Anthropologists"
	131	"Historians, Archeologists & Political Scientists & Related Workers"
	132	"Geographers"
	133	"Psychologists"
	134	"Librarians, Archivists And Curators"
	135	"Philologists, Translators And Interpreters"
	136	"Personnel And Occupational Specialists"
	137	"Labour, Social Welfare & Political Workers"
	139	"Social Scientists And Related Workers, N"
	140	"Lawyers"
	141	"Judges And Magistrates"
	142	"Legal Assistants"
	149	"Jurists, N"
	150	"Teachers, University And Colleges"
	151	"Teachers, Higher Secondary & Secondary Schools"
	152	"Teachers, Middle School"
	153	"Teachers, Primary"
	154	"Teachers, Pre-Primary"
	155	"Teachers, Special Education"
	156	"Teachers, Craft"
	159	"Teachers, N"
	160	"Poets, Authors And Critics"
	161	"Editors And Journalists"
	169	"Poets, Authors, Journalists And Related Workers, N"
	170	"Sculptors, Painters And Related Artists"
	171	"Commercial Artists, Interior Decorators& Designers"
	172	"Movie Camera Operators"
	173	"Photographers, Other"
	179	"Sculptors, Painters, Photographers &Related Creative Artists, N"
	180	"Composers, Musicians And Singers"
	181	"Choreographers And Dancers"
	182	"Actors"
	183	"Stage & Film Directors & Producers (Performing Arts)"
	184	"Circus Performers"
	189	"Composers And Performing Artists, N"
	190	"Ordained Religious Workers"
	191	"Non-Ordained Religious Workers"
	192	"Astrologers, Palmists And Related Workers"
	193	"Athletes, Sportsmen And Related Workers"
	199	"Professional Workers N"
	200	"Elected Officials, Union Government"
	201	"Elected Officials, State Government"
	202	"Elected Officials, Local Bodies"
	209	"Elected Officials, N"
	210	"Administrative & Executive Officials, Union Govt"
	211	"Administrative & Executive Officials, State Government"
	212	"Administrative& Executive Officials, Quasi G Overnment"
	213	"Administrative &Executive Officials, Local Bodies"
	219	"Administrative &Executive Officials, Govt & Local Bodies, N"
	220	"Working Proprietors, Directors & Managers, Wholesale"
	221	"Working Proprietors, Directors & Managers, Retail Trade"
	229	"Working Proprietors, Directors And Managers Wholesale & Retail Trade, N"
	230	"Directors And Managers, Bank"
	231	"Directors And Managers, Insurance"
	239	"Directors And Managers, Financial Institution N"
	240	"Working Proprietors ,Directors &Managers, Mining, Quarrying And Well Drilling"
	241	"Working Proprietors, Directors & Managers, Construction"
	242	"Working Proprietors, Directors & Managers, Electricity, Gas And Water"
	243	"Working Proprietors, Directors & Managers, Manufacturing"
	249	"Manufacturing And Related Concerns, N"
	250	"Working Proprietors, Directors ,Managers & Related Executives, Transport"
	251	"Directors, Managers & Related Executives, Communication"
	252	"Warehouse"
	259	"Storage And Communication, N"
	260	"Working Proprietors, Directors & Managers, Lodging &Catering Services"
	261	"Working Props, Dirs & Managers, Recreation & Entertain"
	269	"Working Proprietors, Directors, Managers,& Related Executives, Other Services"
	299	"Administrative, Executive &Ma Nagerial Workers, N"
	300	"Clerical Supervisors,( Office"
	301	"Other Supervisors (Inspectors, Etc"
	302	"Ministerial And Office Assistants"
	309	"Clerical And Other Supervisors, Other"
	310	"Village Officials"
	320	"Stenographers And Steno-Typists"
	321	"Typists"
	322	"Tele-Typists"
	323	"Card & Tapepunching Machine Operators"
	329	"Stenographer, Typist & Card & Tape Punching Operators, N"
	330	"Book Keepers And Accounts Clerks"
	331	"Cashiers"
	339	"Bookkeepers, Cashiers & Related Workers, N"
	340	"Book-Keeping & Calculating Machine Operators"
	341	"Automatic Data Processing Machine Operators"
	349	"Computing Machine Operators, N"
	350	"Clerks, General"
	351	"Store Keeper And Related Workers"
	352	"Receptionists"
	353	"Library Clerks"
	354	"Time Keepers"
	355	"Coders"
	356	"Ticket Sellers"
	358	"Office Attendants (Peons, Daftries, Etc)"
	359	"Clerical & Related Workers(Including Proof Readers &Copy Holders), N"
	360	"Station Masters And Station Superintendents, Transport"
	361	"Postmasters, Telegraph Masters And Other Supervisors"
	369	"Transport & Communication Supervisor, N"
	370	"Guards And Breaks Men, Railway"
	371	"Conductors, Transport"
	379	"Transport Conductors And Guards, N"
	380	"Postmen"
	381	"Messengers And Dispatch Riders"
	389	"Mail Distributors And Related Workers, N"
	390	"Telephone Operators"
	391	"Telegraphists And Signallers"
	392	"Radio Communication And Wireless Operators"
	399	"Telephone And Telegraph Operators, N"
	400	"Merchants And Shopkeepers, Wholesale Trade"
	401	"Merchants And Shopkeepers, Retail Trade"
	409	"Merchants & Shop Keepers & Wholesale & Retail Trade, N"
	410	"Sales Supervisors"
	411	"Purchasing Agents"
	412	"Selling Agents"
	419	"Manufacturers Agents, N"
	420	"Technical Salesmen And Service Advisors"
	421	"Commercial Travellers"
	429	"Technical Salesmen And Commercial Travellers, N"
	430	"Salesmen, Shop Assistants And Demonstrators"
	431	"Street Vendors, Canvassers And News Vendors"
	439	"Salesmen, Shop Assistants & Related Workers, N"
	440	"Agents And Salesmen, Insurance"
	441	"Agents, Brokers And Salesmen, Real Estate"
	442	"Agents And Brokers, Securities And Shares"
	443	"Agents, Brokers & Salesmen, Advertising & Other Business Services"
	444	"Auctioneers"
	445	"Valuers And Appraisers"
	449	"NEC"
	450	"Money Lenders (Including Indigenous Bankers)"
	451	"Pawn Brokers"
	459	"Money Lenders And Pawn Brokers, N"
	490	"Sales Workers, N"
	500	"Hotel And Restaurant Keepers"
	510	"House Keepers, Matrons And Stewards"
	520	"Cooks And Cook Bearers"
	521	"Butlers, Bearers And Waiters"
	522	"Bartenders And Related Workers"
	529	"Cooks, Waiters And Related Workers, N"
	530	"Ayahs, Nurse, Maids"
	531	"Domestic Servants"
	539	"Maids And Related Housekeeping Service Workers, N"
	540	"Building Caretakers"
	541	"Sweepers, Cleaners And Related Workers"
	542	"Watermen"
	549	"Building Caretakers, Sweepers, Cleaners & Related Workers, N"
	550	"Laundrymen, Washermen And Dhobis"
	551	"Dry Cleaners And Pressers"
	559	"Launderers, Dry Cleaners And Pressers, N"
	560	"Hair D Ressers, Barbers, Beauticians & Related Workers"
	570	"Fire Fighters"
	571	"Policemen And Detectives"
	572	"Customs Examiners, Patrollers & Related Workers"
	573	"Protection Force, Home Guard And Security Workers"
	574	"Watchmen, Chowkidars And Gate Keepers"
	579	"Protective Service Workers, N"
	590	"Guides"
	591	"Undertakers And Embalmers"
	599	"Service Workers, N"
	600	"Farm Managers & Supervisors, Crop Production"
	601	"Manager, Plantation"
	602	"Farm Managers, Horticulture"
	603	"Farm Manager, Livestock Farm"
	604	"Farm Manager, Dairy Farm"
	605	"Farm Manager, Poultry Farm"
	609	"Farm Managers And Supervisors, N"
	610	"Cultivators (Owners)"
	611	"Cultivators (Tenants)"
	619	"Cultivators, N"
	620	"Planters"
	621	"Livestock Farmers"
	622	"Dairy Farmers"
	623	"Poultry Farmers"
	624	"Insect Rearers"
	625	"Orchard, Vineyard And Related Workers"
	629	"Farmers, Other Than Cultivators, N"
	630	"Agricultural Labourers"
	640	"Plantation Labourers"
	641	"Tappers, (Palm, Rubber Trees, Etc"
	649	"Plantation Labourers And Related Workers, N"
	650	"Farm Machinery Operators"
	651	"Farm Workers, Animal, Birds And Insect Rearing"
	652	"Gardeners And Nursery Workers"
	659	"Other Farm Workers, N"
	660	"Foresters And Related Workers"
	661	"Harvesters & Gatherers Of Forest Products Including Lac(Except Logs)"
	662	"Log Fellers And Wood Cutters"
	663	"Charcoal Burners & Forest Product Processors"
	669	"Loggers And Other Forestry Workers, N"
	670	"Hunters"
	671	"Trappers"
	679	"Hunters And Related Workers, N"
	680	"Fishermen, Deep Sea"
	681	"Fishermen, Inland And Coastal Waters"
	682	"Conch & Shell Gatherers, Sponge & Pearl Divers"
	689	"Fishermen And Related Workers, N"
	710	"Supervisor & Foreman, Mining, Quarrying, Well Drilling & Related Activities"
	711	"Miners"
	712	"Quarrymen"
	713	"Drillers, Mines And Quarries"
	714	"Shot Firers"
	715	"Miners And Quarrymen, Other"
	716	"Well Drillers, Petroleum And Gas"
	717	"Well Drillers, Other Than Petroleum And Gas"
	718	"Mineral Treaters"
	719	"Miners, Quarrymen & Related Workers, N"
	720	"Supervisors & Foremen, Metal Smelting Converting Refining"
	721	"Metal Smelting, Converting & Refining Furnace Men"
	722	"Metal Rolling Mill Workers"
	723	"Metal Melters And Reheaters"
	724	"Metal Casters"
	725	"Metal Moulder And Core Makers"
	726	"Metal Annealers, Temperers And Case Hardeners"
	727	"Metal Drawers And Extruders"
	728	"Metal Platters And Coaters"
	729	"Metal Processors, N"
	730	"Supervisor & Foreman, Wood Preparation & Paper Making"
	731	"Wood Treaters"
	732	"Sawyers, Plywood Makers & Related Wood Processing Workers"
	733	"Paper Pulp Preparers"
	734	"Paper Makers"
	739	"Wood Preparation And Paper Making Workers N"
	740	"Supervisor & Foreman, Chemical Processing & Related Activities"
	741	"Crushers, Grinders And Mixers"
	742	"Cookers, Roasters And Related Heat Treaters"
	743	"Filter And Separator Operators"
	744	"Still And Reactor Operators"
	745	"Petroleum Refining Workers,"
	749	"Chemical Processors And Related Workers, N"
	750	"Supervisors & Foremen, Spinning, Weaving, Knitting, Dyeing & Related"
	751	"Fibre Preparers"
	752	"Spinners And Winders"
	753	"Warpers And Sizers"
	754	"Weaving & Knitting Machine Setters & Pattern Card Preparers"
	755	"Weavers And Related Workers"
	756	"Carpet Makers And Finishers"
	757	"Knitters"
	758	"Bleachers, Dyers And Textile Product Finishers"
	759	"Spinners, Weavers,K Nitters,Dyers & Related Workers, N"
	760	"Supervisors & Foremen, Tanning & Pelt Dressing"
	761	"Tanners And Fell Mongers"
	762	"Pelt Dressers"
	769	"Fell Mongers And Pelt Dressers, N"
	770	"Supervisors & Foremen, Food & Beverage Processing"
	771	"Grain Millers, Parchers And Related Workers"
	772	"Crushers And Pressers, Oil Seeds"
	773	"Khandsari, Sugar And Gur Makers"
	774	"Butchers And Meat Preparers"
	775	"Food Preservers And Canners"
	776	"Dairy Product Processors"
	777	"Bakers, Confectioners, Candy & Sweet Meat Makers, Other Food Processors"
	778	"Tea, Coffee & Cocoa Prepares"
	779	"Brewers & Aerated Water & Beverage Makers"
	780	"Supervisors & Foremen Tobacco & Tobacco Product Makers"
	781	"Tobacco Prepares"
	782	"Cigar Makers"
	783	"Cigarette Makers"
	784	"Bidi Makers"
	789	"Tobacco Prepares And Tobacco Product Makers, N"
	790	"Supervisors & Foremen, Tailoring, Dress Making, Sewing, Upholsterywork"
	791	"Tailors And Dress Makers"
	793	"Milliners, Hat And Cap Makers"
	794	"Pattern Makers And Cutters"
	795	"Sewers And Embroiders"
	796	"Upholsterers And Related Workers"
	799	"Tailors, Dressmakers, Sewers, Upholsterers & Related Workers, N"
	800	"Supervisor & Foremen, Shoe & Leather Goods Making"
	801	"Shoe Makers & Shoe Repairers"
	802	"Shoe Cutters, Lasters, Sewers And Related Workers"
	803	"Harness And Saddle Makers"
	809	"Leather, Cutters, Lasters & Sewers & Related Workers, N"
	810	"Processes"
	811	"Carpenter"
	813	"Wood Working Machine Operators"
	814	"Cart Builders And Wheel Wrights"
	815	"Coach And Body Builders"
	816	"Shipwrights And Boat Builders"
	819	"Carpenters, Cabinet Makers & Related Workers,N"
	820	"Supervisors And Foremen, Stone Cutting And Carving"
	821	"Stone Cutter And Carvers"
	829	"Stone Cutters And Carvers, N"
	830	"Supervisors & Foremen, Blacksmithy, Tool Making And Machine Tool Operations"
	831	"Blacksmiths, Hammersmiths & Forgin G Press Operators"
	832	"Metal Markers"
	833	"Tool Makers And Metal Pattern Makers"
	834	"Machine Tool Setters"
	835	"Machine Tool Operators"
	836	"Metal Grinders, Polishers And Tool Sharpeners"
	839	"Blacksmiths, Toolmakers, Machine Tool Operators, N"
	840	"Instrument Making (Except Electrical)"
	841	"Watch, Clock & Precision Instrument Makers(Except Electrical)"
	842	"Machinery Fitters And Machine Assemblers"
	843	"Motor Vehicle Mechanics"
	844	"Aircraft Engine Mechanics"
	845	"Mechanics, Repairmen, Other"
	849	"Electrical),N"
	850	"Installing & Repairing"
	851	"Electricians, Electrical Fitters And Related Workers"
	852	"Electronics Fitters"
	853	"Electric And Electronic Equipment Assemblers"
	854	"Radio Television Mechanics And Repairmen"
	855	"Electrical Wiremen"
	856	"Telephone And Telegraph Installers And Repairmen"
	857	"Electric Linemen And Cable Jointers"
	859	"Electrical Fitters & Related Electrical & Electronic Workers, N"
	860	"Supvisors, Broadcasting, Audio-Visual Projection & Sound Equipment Operators"
	861	"Radio Broadcasting Televisio N Operators"
	862	"Sound Equipment Operators & Cinema Projectionists"
	869	"Broadcasting Station & Sound Equipment Operators & Cinema Projectionists"
	870	"Supervisors, Foremen, Plumbing, Welding Structural & Sheet Metal Working"
	871	"Plumbers And Pipe Fitters"
	872	"Welders And Flame Cutters"
	873	"Sheet Metal Workers"
	874	"Metal Plate And Structural Metal Workers"
	879	"Plumbers, Welders, Sheet Metal & Structural Metal Preparers & Erectors, N"
	880	"Supervisors, Jewellery And Precious Metal Working"
	881	"Jewellers, Goldsmiths & Silversmiths"
	882	"Jewellery Engravers"
	883	"Other Metal Engravers (Except Printing)"
	889	"Jewellers & Precious Metal Workers, N"
	890	"Supervisors & Foremen, Glass Forming, Pottery & Related Activities"
	891	"Glass Formers, Cutters, Grinders And Finishers"
	892	"Potters And Related Clay & Abrasive Formers"
	893	"Glass And Ceramic Kilnmen"
	894	"Glass Engravers And Etchers"
	895	"Glass And Ceramics Painters And Decorators"
	899	"Glass Formers, Potters & Related Workers, N"
	900	"Supervisors &Foremen, Rubber &Plastics Product Making"
	901	"Plastics Product Makers"
	902	"Rubber Product Makers ( Except Tyre Makers & Vulcanisers)"
	903	"Tyre Makers And Vulcanisers"
	909	"Rubber And Plastics Product Makers, N"
	910	"Supervisors & Foremen Paper & Paper Board Product Making"
	911	"Paper And Paper Board Product Makers"
	919	"Paper And Paper Product Makers, N"
	920	"Supervisors & Foremen Printing & Related Work"
	921	"Compositors"
	922	"Type Setters And Photo-Type Setters"
	923	"Printing Pressman"
	924	"Stereo-Typers And Electro-Typers"
	925	"Engravers, Printing(Except Photo Engravers)"
	926	"Photo Engravers"
	927	"Book Binders And Related Workers"
	928	"Photographic Dark Room Workers"
	929	"Printers And Related Workers, N"
	930	"Supervisors And Foremen, Painting"
	931	"Painters, Construction"
	932	"Painters, Spray And Sign Writing"
	939	"Painters, N"
	940	"Supervisors And Foremen Production & Related Activities, N"
	941	"Musical Instrument Makers And Tuners"
	942	"Basketry Weavers And Brush Makers"
	943	"Non-Metallic Mineral Product Makers"
	949	"Production And Related Workers, N"
	950	"Supervisors & Foremen, Bricklaying Other Construction Work"
	951	"Bricklayers, Stone Masons And Tile Setters"
	952	"Reinforced Concreters, Cement Finishers And Terrazzo Workers"
	953	"Roofers"
	954	"Parquetry Workers"
	955	"Plasterers"
	956	"Insulators"
	957	"Glaziers"
	958	"Hut Builders And Thatchers"
	959	"Construction Workers, N"
	960	"Supervisors & Foremen, Stationary &Related Equipment Operations"
	961	"Stationary Engine &Related Equipment Operators"
	962	"Boilermen And Firemen"
	963	"Oilers & Greasers (Including Cleaners Motor Vehicle)"
	969	"Stationary Engine & Related Equipment Operators, N"
	970	"Supervisors & Foremen, Material & Freight Handling & Related Equipment"
	971	"Loaders And Unloaders"
	972	"Riggers And Cable Splicer"
	973	"Crane And Hoist Operators"
	974	"Earth Moving & Related Machinery Operators"
	975	"Checkers, Testers, Sorters, Weighers And Counters"
	976	"Packers, Labellers And Related Workers"
	979	"Material Handling Equipment Operators, N"
	980	"Supervisors &Foremen, Transport Equipment Operation"
	981	"Ships 'Deck Ratings, Barge Crews And Boatmen"
	982	"Ships' Engine Room Ratings"
	983	"Drivers, Railways"
	984	"Firemen, Railways"
	985	"Pointsmen, Signalmen And Shunters, Railways"
	986	"Tram Car And Motor Vehicle Drivers"
	987	"Drivers, Animal And Animal Drawn Vehicles"
	988	"Cycle Rickshaw Drivers And Rickshaw Pullers"
	989	"Transport Equipment Operators And Drivers, N";
	#delimit cr
	la val occup_e_orig lbloccup_e_orig
	la var occup_e_orig "Original occupation code"
*</_occup_orig_>



** OCCUPATION CLASSIFICATION MAIN EARNER
*<_occup_e_>

    /*Please see the excel file called "occupation_classification" in folder doc-techinical to see how this variable
	was constructed using the ISCO-08. It is important to note that the difference between category 7 and 8 in 
	the India NCO 1968 is not very clear. */
	
	gen str3 occup3=string(nco_code,"%03.0f")
    gen str3 occup2=substr(occup3,1,2)
	gen occup_e=.
	
	**Senior officials, Managers
	replace occup_e=2 if inrange(occup2, "20","31")
    replace occup_e=2 if inlist(occup2, "36","60")
	
	**Professionals
	replace occup_e=2 if inlist(occup2, "00","02","05","07","86")
    replace occup_e=2 if inrange(occup2, "10","19")

	**Technicians and associate professionals
	replace occup_e=3 if inlist(occup2, "01","03","04","06","08","09")
	
	**Clerical support workers
	replace occup_e=4 if inrange(occup2, "32","35")
    replace occup_e=4 if inrange(occup2, "37","39")

	*Service and sales workers
	replace occup_e=5 if inrange(occup2, "40","59")
  
	*Skilled agricultural, forestry and fishery workers
	replace occup_e=6 if inrange(occup2, "61","68")

	*Craft and related trades workers
	replace occup_e=7 if inrange(occup2, "71","73")
	replace occup_e=7 if inrange(occup2, "75","82")
	replace occup_e=7 if inlist(occup2, "84","85")
	replace occup_e=7 if inrange(occup2, "92","95")

	
	*Plant and machine operators, and assemblers
	replace occup_e=8 if inlist(occup2, "74","83")
    replace occup_e=8 if inrange(occup2, "87","91")
	replace occup_e=8 if inrange(occup2, "96","98")
	
	*Elementary occupations
	replace occup_e=9 if occup2=="99"
	
	*other/unspecified
	replace occup_e=99 if inlist(occup2,"X0","X1","X9")

		   
	*Next occupations are classified as professionals 
	replace occup_e=2 if inlist(occup3, "084","085","085","087","088")
	
	*Next occupations are classified as Senior officials, Managers 
	replace occup_e=1 if inlist(occup3,"710","720","730","740","750","760","770","780","790")
	replace occup_e=1 if inlist(occup3,"800","810","820","830","840","850","860","870","880")
    replace occup_e=1 if inlist(occup3,"890","900","910","920","930","940","950","960","970")
	replace occup_e=1 if inlist(occup3,"980")

    drop  occup2 occup3 

	label var occup_e "1 digit occupational classification (main earner)"
	label define occup_e 1 "Senior officials" 2 "Professionals" 3 "Technicians" 4 "Clerks" ///
	5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" ///
	8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup_e occup_e	
*</_occup_e_>

	note lstatus_e: "IND 2004" 	Data recolected only for main income earner of the household.
	note empstat_e: "IND 2004"	Data recolected only for main income earner of the household.
	note industry_e: "IND 2004"	Data recolected only for main income earner of the household.
	note occup_e: 	"IND 2004"	Data recolected only for main income earner of the household.
	note _dta: "IND 2004" No information on second occupations for this survey.


/*****************************************************************************************************
*                                                                                                    *
                                            ASSETS 
*                                                                                                    *
*****************************************************************************************************/
	
** LAND PHONE
*<_landphone_>
	gen landphone=.
	label var landphone "Phone availability"
	la de lbllandphone 0 "No" 1 "Yes"
	label values landphone lbllandphone
*</_landphone_>


** CEL PHONE
*<_cellphone_>
	gen cellphone=.
	label var cellphone "Household has a cell phone"
	la de lblcellphone 0 "No" 1 "Yes"
	label values cellphone lblcellphone
*</_cellphone_>


** COMPUTER
*<_computer_>
	gen computer=.
	label var computer "Household has a computer"
	la de lblcomputer 0 "No" 1 "Yes"
	label values computer lblcomputer
*</_computer_>

** RADIO
*<_radio_>
	gen radio=1 if possess561==1
	replace radio=0 if possess561==2
	label var radio "household has a radio"
	la de lblradio 0 "No" 1 "Yes"
	label val radio lblradio
*</_radio_>

** TELEVISION
*<_television_>
	gen television=1 if possess562==1
	replace television=0 if possess562==2
	label var television "Household has a television"
	la de lbltelevision 0 "No" 1 "Yes"
	label val television lbltelevision
*</_television>

** FAN
*<_fan_>
	gen fan=1 if possess590==1
	replace fan=0 if possess590==2
	label var fan "Household has a fan"
	la de lblfan 0 "No" 1 "Yes"
	label val fan lblfan
*</_fan>

** SEWING MACHINE
*<_sewingmachine_>
	gen sewingmachine=1 if possess594==1
	replace sewingmachine=0 if possess594==2
	label var sewingmachine "Household has a sewing machine"
	la de lblsewingmachine 0 "No" 1 "Yes"
	label val sewingmachine lblsewingmachine
*</_sewingmachine>

** WASHING MACHINE
*<_washingmachine_>
	gen washingmachine=1 if possess595==1
	replace washingmachine=0 if possess595==2
	label var washingmachine "Household has a washing machine"
	la de lblwashingmachine 0 "No" 1 "Yes"
	label val washingmachine lblwashingmachine
*</_washingmachine>

** REFRIGERATOR
*<_refrigerator_>
	gen refrigerator=1 if possess598==1
	replace refrigerator=0 if possess598==2
	label var refrigerator "Household has a refrigerator"
	la de lblrefrigerator 0 "No" 1 "Yes"
	label val refrigerator lblrefrigerator
*</_refrigerator>

** LAMP
*<_lamp_>
	gen lamp=1 if possess593==1
	replace lamp=0 if possess593==2
	label var lamp "Household has a lamp"
	la de lbllamp 0 "No" 1 "Yes"
	label val lamp lbllamp
*</_lamp>

** BYCICLE
*<_bycicle_>
	gen bicycle=1 if possess610==1
	replace bicycle=0 if possess610==2
	label var bicycle "Household has a bicycle"
	la de lblbycicle 0 "No" 1 "Yes"
	label val bicycle lblbycicle
*</_bycicle>

** MOTORCYCLE
*<_motorcycle_>
	gen motorcycle=1 if possess611==1
	replace motorcycle=0 if possess611==2
	label var motorcycle "Household has a motorcycle"
	la de lblmotorcycle 0 "No" 1 "Yes"
	label val motorcycle lblmotorcycle
*</_motorcycle>

** MOTOR CAR
*<_motorcar_>
	gen motorcar=1 if possess612==1
	replace motorcar=0 if possess612==2
	label var motorcar "household has a motor car"
	la de lblmotorcar 0 "No" 1 "Yes"
	label val motorcar lblmotorcar
*</_motorcar>

** COW
*<_cow_>
	gen cow=.
	label var cow "Household has a cow"
	la de lblcow 0 "No" 1 "Yes"
	label val cow lblcow
*</_cow>

** BUFFALO
*<_buffalo_>
	gen buffalo=.
	label var buffalo "Household has a buffalo"
	la de lblbuffalo 0 "No" 1 "Yes"
	label val buffalo lblbuffalo
*</_buffalo>

** CHICKEN
*<_chicken_>
	gen chicken=.
	label var chicken "Household has a chicken"
	la de lblchicken 0 "No" 1 "Yes"
	label val chicken lblchicken
*</_chicken>		
	
	
	
/*****************************************************************************************************
*                                                                                                    *
                                   WELFARE MODULE
*                                                                                                    *
*****************************************************************************************************/


** SPATIAL DEFLATOR
*<_spdef_>
	gen spdef=pline
	la var spdef "Spatial deflator"
*</_spdef_>

	
** WELFARE
*<_welfare_>
	gen welfare=mpce30d/(hsize*100)
	la var welfare "Welfare aggregate"
*</_welfare_>

*<_welfarenom_>
	gen welfarenom=welfare
	la var welfarenom "Welfare aggregate in nominal terms"
*</_welfarenom_>

*<_welfaredef_>
	gen welfaredef=mpce_urp_real
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
	gen welfareother=mpce365/(hsize*100)
	la var welfareother "Welfare Aggregate if different welfare type is used from welfare, welfarenom, welfaredef"
*</_welfareother_>

*<_welfareothertype_>
	gen welfareothertype="EXP"
	la var welfareothertype "Type of welfare measure (income, consumption or expenditure) for welfareother"
*</_welfareothertype_>

*<_welfarenat_>
	gen welfarenat=mpce365/(hsize*100)
	la var welfarenat "Welfare aggregate for national poverty"
*</_welfarenat_>

/*****************************************************************************************************
*                                                                                                    *
                                   NATIONAL POVERTY
*                                                                                                    *
*****************************************************************************************************/


** POVERTY LINE (NATIONAL)
*<_pline_nat_>
	ren pline pline_nat
	label variable pline_nat "Poverty Line (National)"
*</_pline_nat_>


** HEADCOUNT RATIO (NATIONAL)
*<_poor_nat_>
	gen poor_nat=welfarenat<pline_nat & welfarenat!=.
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
*<_cpi_>
	capture drop _merge
	gen urb=urban
	merge m:1 countrycode year urb using "$pricedata", keepusing(countrycode year urb syear cpi`year'_w ppp`year')
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
	do "$fixlabels\fixlabels", nostop

	keep countrycode year survey idh idp wgt pop_wgt wgt_wdi strata psu vermast veralt urban int_month int_year fieldwork  ///
	     subnatid1 subnatid2 subnatid3 ownhouse landholding tenure water electricity toilet internet ///
		 hsize relationharm relationcs male age soc marital ed_mod_age everattend ///
	     atschool electricity literacy educy educat4 educat5 educat7 lb_mod_age lstatus empstat njobs ///
	     ocusec nlfreason unempldur_l unempldur_u industry  occup firmsize_l firmsize_u whours wage ///
		 unitwage contract healthins socialsec union lstatus_e empstat_e industry_e_orig industry_e occup_e_orig occup_e  ///
		 landphone cellphone computer radio television fan sewingmachine washingmachine  ///
		 refrigerator lamp bicycle motorcycle motorcar cow buffalo chicken  ///
		 pline_nat pline_int poor_nat poor_int spdef cpi ppp cpiperiod welfare welfshprosperity welfarenom welfaredef ///
		 welfarenat welfareother welfaretype welfareothertype

** ORDER VARIABLES

	order countrycode year survey idh idp wgt pop_wgt wgt_wdi strata psu vermast veralt urban int_month int_year fieldwork  ///
	      subnatid1 subnatid2 subnatid3 ownhouse landholding tenure water electricity toilet internet ///
	      hsize relationharm relationcs male age soc marital ed_mod_age everattend ///
	      atschool electricity literacy educy educat4 educat5 educat7 lb_mod_age lstatus empstat njobs ///
	      ocusec nlfreason unempldur_l unempldur_u industry occup firmsize_l firmsize_u whours wage ///
		  unitwage contract healthins socialsec union lstatus_e empstat_e industry_e_orig industry_e  occup_e_orig occup_e  ///
		  landphone cellphone computer radio television fan sewingmachine washingmachine  ///
		  refrigerator lamp bicycle motorcycle motorcar cow buffalo chicken  ///
		  pline_nat pline_int poor_nat poor_int spdef cpi ppp cpiperiod welfare welfshprosperity welfarenom welfaredef ///
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
	keep countrycode year survey idh idp wgt pop_wgt wgt_wdi strata psu vermast veralt `keep' *type
    sort idh idp
	
	compress

	saveold "`output'\Data\Harmonized\IND_2004_NSS61-SCH1.0_v01_M_v03_A_SARMD_IND.dta", replace version(12)
	saveold "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\__REGIONAL\Individual Files\IND_2004_NSS61-SCH1.0_v01_M_v03_A_SARMD_IND.dta", replace version(12)

	
	log close



******************************  END OF DO-FILE  *****************************************************/
