/*****************************************************************************************************
******************************************************************************************************
**                                                                                                  **
**                              SOUTH ASIA MICRO DATABASE (SARMD)                                   **
**                                                                                                  **
** COUNTRY			Maldives
** COUNTRY ISO CODE	MDV
** YEAR				2009
** SURVEY NAME		Vulnerability and poverty assessment survey – 2009
** SURVEY AGENCY	Minister of Planning and National Development
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
	local input "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\MDV\MDV_2009_HIES\MDV_2009_HIES_v01_M"
	local output "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\MDV\MDV_2009_HIES\MDV_2009_HIES_v01_M_v02_A_SARMD"
	glo pricedata "D:\SOUTH ASIA MICRO DATABASE\CPI\cpi_ppp_sarmd_weighted.dta"

** LOG FILE
	log using "`output'\Doc\Technical\MDV_2009_HIES.log",replace

/*****************************************************************************************************
*                                                                                                    *
                                   * ASSEMBLE DATABASE
*                                                                                                    *
*****************************************************************************************************/


	* PREPARE DATASETS

	* Education & Employment
	use "`input'\Data\Stata\Educ_Empl.dta"
	sort formID pNo
	ren formID hhid
	ren pNo pid

	ren Q9 everattend
	ren Q10 attending
	ren Q11 elevel1
	ren Q12 elevel2
	ren Q13 marital
	ren Q16 activity
	ren Q17 searchforjob
	ren Q18 availability
	ren Q19 nlfreason

	drop Q14-Q15
	drop Q20-Q22

	tempfile educ_empl
	save `educ_empl', replace

	* Income
	use "`input'\Data\Stata\Income_microdatalib.dta"
	sort formID pNo
	ren formID hhid
	ren pNo pid

	ren Q1 industry
	ren Q2 occupation
	ren Q4 typeofjob
	ren Q5 hours
	ren Q6 months
	ren Q7 empstat
	ren Q8 otherjob

	tempfile income
	save `income', replace
	
	* Roster
	use "`input'\Data\Stata\Form2_First page.dta"
	sort formID
	ren formID hhid
	tempfile form2
	save `form2'
	
	* Consumption
	use "`input'\Data\Stata\wf2009.dta"
	sort hhid pid
	keep hhid pid pce pcer z* spi hhsize wght_hh
	
	tempfile consumption
	save `consumption'
	
	* Weights
	use "`input'\Data\Stata\Form8_ind.dta"
	sort id
	ren formID hhid
	keep id hhid raisingfactor
	tempfile weight
	save `weight'
	
	* Assets
	/*
	use "`input'\Data\Stata\ConsumerTC.dta"
	ren formID hhid
	sort hhid
	replace itemDesc=lower(itemDesc)
	gen mp=itemDesc=="mobile phone"
	gen p=itemDesc=="telephone"
	sort hhid
	egen telephone=max(p), by(hhid)
	egen cellphone=max(mp), by(hhid)
	duplicates drop hhid, force
	tempfile phones
	save `phones'
	*/
	* Demographics
	use "`input'\Data\Stata\Demogr.dta"
	sort formID pNo
	ren formID hhid
	ren pNo pid

	foreach var in Male Female Q41 Q42 Q51 Q52 Q53 Q54 Q55 Q56 Q57 Q58 Q59 Q510 Q61 Q62 Q63 Q64 Q65 Q71 Q72 Q81 Q82{
	replace `var'=1 if `var'>0 & `var'!=.
	}
	
	gen relation=.
	forval i=1/10{
	replace relation=`i' if Q5`i'==1	
	}
	drop Q5*

	merge 1:1 hhid pid using `consumption'
	ren _merge merge_cons
	
	merge 1:1 hhid pid using `educ_empl'
	ren _merge merge_educ_empl
	
	merge 1:1 hhid pid using `income'
	ren _merge merge_income
	
	merge m:1 hhid using `form2'
	ren _merge merge_form2
	
	sort id
	merge 1:1 id using `weight'
	ren _merge merge_weight
	drop if merge_cons!=3
	drop merge*

	* Change variable formats
	destring atollIsland, gen(geo_2)
	destring Region, gen(geo_1)

	
/*****************************************************************************************************
*                                                                                                    *
                                   * STANDARD SURVEY MODULE
*                                                                                                    *
*****************************************************************************************************/
	

** COUNTRY
*<_countrycode_>
	gen str4 countrycode="MDV"
	label var countrycode "Country code"
*</_countrycode_>


** YEAR
*<_year_>
	gen int year=2009
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
	tostring hhid, gen(idh)
	label var idh "Household id"
*</_idh_>


** INDIVIDUAL IDENTIFICATION NUMBER
*<_idp_>
	tostring pid, replace
	egen idp=concat(idh pid), punct(-)
	label var idp "Individual id"
*</_idp_>


** HOUSEHOLD WEIGHTS
*<_wgt_>
	bys idh: egen wgt=mean(wght_hh)
	label var wgt "Household sampling weight"
*</_wgt_>


** STRATA
*<_strata_>
	gen strata=.
	label var strata "Strata"
*</_strata_>


** PSU
*<_psu_>
	gen psu=.
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
	gen urban = 2 if geo_2!=.
	replace urban=1 if inlist(geo_2,1001,1002,1003,1004,1005,2010,2112,2215,2312,2407,2510,2602,2704,2802,2904,3003,3105,3204,3308,3411,3508,3602,3710,3801,3902)
	recode urban (2=0)
	label var urban "Urban/Rural"
	la de lblurban 1 "Urban" 0 "Rural"
	label values urban lblurban
*</_urban_>


** REGIONAL AREA 1 DIGIT ADMN LEVEL
*<_subnatid1_>
	*gen byte subnatid1=geo_1
	*# delimit ;
	*la def lblsubnatid1
	*1 "Region 1 (Ha, HDh, Sh)"
	*2 "Region 2 (N, R, B, Lh)"
	*3 "Region 3 (K, AA, Adh, V)"
	*4 "Region 4 (M, F, Dh)"
	*5 "Region 5 (Th, L)"
	*6 "Region 6 (Ga, GDh)"
	*7 "Region 6 (Gn, S)"
	*8 "Male' ";
	*# delimit cr
	gen byte 	subnatid1=1 if geo_1==8
	replace		subnatid1=2 if geo_1!=8 & geo_1!=.
	la de lblsubnatid1 1 "Male" 2 "Atolls"
	label var subnatid1 "Region at 1 digit (ADMN1)"
	label values subnatid1 lblsubnatid1
*</_subnatid1_>

** REGIONAL AREA 2 DIGIT ADMN LEVEL
*<_subnatid2_>
	gen subnatid2=geo_2
	# delimit ;
	la def lblsubnatid2
	1001 "Henveiru"
	1002 "Galolhu"
	1003 "Machchangolhi"
	1004 "Maafannu"
	1005 "Villigili"
	1009 "HulhuMale"
	2006 "Hoarafushi"
	2007 "Ihavandhoo"
	2010 "Dhidhdhoo"
	2111 "Kuburudhoo"
	2112 "Kulhudhuffushi"
	2205 "Feevah"
	2213 "Komandoo"
	2309 "Lhohi"
	2407 "Ugoofaaru"
	2417 "Kinolhas"
	2510 "Eydhafushi"
	2512 "Thulhaadhoo"
	2601 "Hinnavaru"
	2602 "Naifaru"
	2704 "Thulusdhoo"
	2712 "Maafushi"
	2804 "Ukulhas"
	2904 "Mahibadhoo"
	2908 "Fenfushi"
	3003 "Felidhoo"
	3105 "Muli"
	3106 "Naalaafushi"
	3201 "Feeali"
	3205 "Dharaboodhoo"
	3308 "Kudahuvadhoo"
	3407 "Vandhoo"
	3410 "Thimarafushi"
	3411 "Veymandoo"
	3501 "Isdhoo"
	3506 "Gamu"
	3604 "Nilandhoo"
	3606 "Dhevvadhoo"
	3704 "Gadhdhoo"
	3710 "Thinadhoo"
	3801 "Foammulah"
	3902 "Hithadhoo"
	3903 "Maradhoo"
	3904 "Feydhoo"
	3905 "Maradhoo-Feydhoo";
# delimit cr
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
	recode tenureType (1=1)(2 3=0), gen(ownhouse)
	label var ownhouse "House ownership"
	la de lblownhouse 0 "No" 1 "Yes"
	label values ownhouse lblownhouse
*</_ownhouse_>

** WATER PUBLIC CONNECTION
*<_water_>
	gen byte water=.
	label var water "Water main source"
	la de lblwater 0 "No" 1 "Yes"
	label values water lblwater
*</_water_>

** ELECTRICITY PUBLIC CONNECTION
*<_electricity_>

	gen byte electricity=.
	label var electricity "Electricity main source"
	la de lblelectricity 0 "No" 1 "Yes"
	label values electricity lblelectricity
*</_electricity_>

** TOILET PUBLIC CONNECTION
*<_toilet_>

	gen byte toilet=.
	label var toilet "Toilet facility"
	la de lbltoilet 0 "No" 1 "Yes"
	label values toilet lbltoilet
*</_toilet_>


** LAND PHONE
*<_landphone_>

	*ren phone landphone
	gen landphone=.
	label var landphone "Phone availability"
	la de lbllandphone 0 "No" 1 "Yes"
	label values landphone lbllandphone
*</_landphone_>


** CEL PHONE
*<_cellphone_>

	*ren cphone cellphone
	gen cellphone=.
	label var cellphone "Cell phone"
	la de lblcellphone 0 "No" 1 "Yes"
	label values cellphone lblcellphone
*</_cellphone_>


** COMPUTER
*<_computer_>
	gen computer=.
	label var computer "Computer availability"
	la de lblcomputer 0 "No" 1 "Yes"
	label values computer lblcomputer
*</_computer_>


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
*<_hsize_>

	ren hhsize hsize
	la var hsize "Household size"
*</_hsize_>

	bys idh: gen head=relation==1
	bys idh: egen heads=total(head)
	replace relation=1 if heads==0 & pid=="1"
	drop head heads
	
** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
*<_relationharm_>
	recode relation (3/4=3) (7=4) (5 6 8  9=5) (10=6) (99=.), gen(relationharm)

	label var relationharm "Relationship to the head of household"
	la de lblrelationharm  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Non-relatives"
	label values relationharm  lblrelationharm
*</_relationharm_>

** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
*<_relationcs_>

	gen byte relationcs=relation
	la var relationcs "Relationship to the head of household country/region specific"
	label define lblrelationcs 1 "Household head" 2 "Spouse" 3 "Child" 4 "Step Child" 5 "Brother/Sister" 6 "Grand child" 7 "Parents /Step Parents" 8 "Son/Daughter-in-law" 9 "Other relative" 10"Non-relative"
	label values relationcs lblrelationcs
*</_relationcs_>


** GENDER
*<_male_>
	gen byte male=.
	replace male=1 if Male==1
	replace male=0 if Female==1
	label var male "Sex of household member"
	la de lblmale 1 "Male" 0 "Female"
	label values male lblmale
*</_male_>


** AGE
*<_age_>
	label var age "Age of individual"
*</_age_>


** SOCIAL GROUP
*<_soc_>
	gen byte soc=.
	label var soc "Social group"
	la de lblsoc 1 "Dhivehi" 2 "English" 3 "Other" 4 "None"
	label values soc lblsoc
*</_soc_>


** MARITAL STATUS
*<_marital_>	recode marital (1=2) (2 = 1) (3=4) (4=5)
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
	gen byte ed_mod_age=6
	label var ed_mod_age "Education module application age"
*</_ed_mod_age_>


** CURRENTLY AT SCHOOL
*<_atschool_>
	gen byte atschool=attending==1
	replace atschool=. if attending==.
	label var atschool "Attending school"
	la de lblatschool 0 "No" 1 "Yes"
	label values atschool  lblatschool
*</_atschool_>


** CAN READ AND WRITE
*<_literacy_>
	gen byte literacy=1 if elevel2!=0
	replace literacy=0 if elevel2==12
	replace literacy=. if age<ed_mod_age

	label var literacy "Can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy
*</_literacy_>


** YEARS OF EDUCATION COMPLETED
*<_educy_>
	gen byte educy=elevel2
	recode educy (18 19 20 = 0) (13=16) (15=16) (16 17 = 14)
	label var educy "Years of education"
*</_educy_>
	replace educy=. if educy>age & age!=. & educy!=.


** EDUCATION LEVEL 7 CATEGORIES
*<_educat7_>

	gen byte educat7=elevel2
	recode educat7 (18 19 = 7) (0 20 = 1) (1/4 = 2) (5=3) (6/11=4) (12=5) (14 16 17 =6) (13 15=7)
	replace educat7=1 if educy==0
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
	gen byte educat4=educat7
	recode educat4 ( 2/3=2) (4/5=3) (6/7 =4)
	replace educat4=1 if educy==0
	label var educat4 "Level of education 4 categories"
	label define lbleducat4 1 "No education" 2 "Primary (complete or incomplete)" ///
	3 "Secondary (complete or incomplete)" 4 "Tertiary (complete or incomplete)"
	label values educat4 lbleducat4
*</_educat4_>


	
** EVER ATTENDED SCHOOL
*<_everattend_>
	recode everattend (2=0)
	label var everattend "Ever attended school"
	la de lbleverattend 0 "No" 1 "Yes"
	label values everattend lbleverattend
*</_everattend_>


	replace educy=0 if everattend==0
	replace  educat7=1 if everattend==0
	replace  educat5=1 if everattend==0
	replace  educat4=1 if everattend==0

	local ed_var "everattend atschool literacy educy educat4 educat5 educat7 "
	foreach v in `ed_var'{
	replace `v'=. if( age<ed_mod_age & age!=.)
	}


/*****************************************************************************************************
*                                                                                                    *
                                   LABOR MODULE
*                                                                                                    *
*****************************************************************************************************/


** LABOR MODULE AGE
*<_lb_mod_age_>

 gen byte lb_mod_age=15
	label var lb_mod_age "Labor module application age"
*</_lb_mod_age_>



** LABOR STATUS
*<_lstatus_>
	gen byte lstatus=1 if activity==1
	replace lstatus=2 if activity==2 & searchforjob==1
	replace lstatus=3 if activity==2 & searchforjob==2
	replace lstatus=3 if availability==2
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus
*</_lstatus_>


** EMPLOYMENT STATUS
*<_empstat_>
	recode empstat (1=3) (2=1) (3=4) (5 = 2) (4= 5)

	replace empstat=. if lstatus==2 | lstatus==3
	label var empstat "Employment status"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other"
	label values empstat lblempstat
*</_empstat_>


** SECTOR OF ACTIVITY: PUBLIC - PRIVATE
*<_njobs_>
	recode otherjob (2=0), gen(njobs)

	label var njobs "Number of additional jobs"
*</_njobs_>


** SECTOR OF ACTIVITY: PUBLIC - PRIVATE
*<_ocusec_>
	recode typeofjob (1 2 5 6 = 1) (3 4 7 0 =2) (8=.), gen(ocusec)

	replace ocusec=. if lstatus==2 | lstatus==3
	label var ocusec "Sector of activity"
	la de lblocusec 1 "Public, state owned, government, army, NGO" 2 "Private"
	label values ocusec lblocusec
*</_ocusec_>


** REASONS NOT IN THE LABOR FORCE
*<_nlfreason_>
	recode nlfreason (1 2 3 5 6 7 =5) (4= 2)

	label var nlfreason "Reason not in the labor force"
*</_nlfreason_>
	la de lblnlfreason 1 "Student" 2 "Housewife" 3 "Retired" 4 "Disabled" 5 "Other"
	label values nlfreason lblnlfreason


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

	replace industry="" if industry=="Q17" | industry=="Q18" | industry=="Q19"
	destring industry, replace
	replace industry=int(industry/100)
	recode industry (0=10) (1/5=1) (10/14=2) (15/37=3) (40/41=4) (45=5) (50/55=6) (60/64=7) (65/74=8) (75=9) (80/99=10)
	label var industry "1 digit industry classification"
	replace industry=. if lstatus==2 | lstatus==3
	la de lblindustry 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transports and comnunications" 8 "Financial and business-oriented services" 9 "Public Administration" 10 "Other services, Unspecified"
	label values industry lblindustry
*</_industry_>


** OCCUPATION CLASSIFICATION
*<_occup_>
	replace occupation="" if occupation=="Q17" | occupation=="Q18" | occupation=="Q19"
	destring occupation, replace
	gen byte occup=int(occupation/100)
	recode occup (0/10=10) (11/19=1) (21/29=2) (31/39=3) (41/49=4) (51/59=5) (61/69=6) (71/79=7) (81/89=8) (91/99=9)
	label var occup "1 digit occupational classification"
	replace occup=. if lstatus==2 | lstatus==3
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
	gen whours=hours*7
	replace whours=. if lstatus==2 | lstatus==3
	label var whours "Hours of work in last week"
*</_whours_>


** WAGES
*<_wage_>
	gen double wage=Q161Primary
	replace wage=. if lstatus==2 | lstatus==3
	replace wage=0 if empstat==2
	label var wage "Last wage payment"
*</_wage_>


** WAGES TIME UNIT
*<_unitwage_>
	gen byte unitwage=5

	label var unitwage "Last wages time unit"
	replace unitwage=. if lstatus==2 | lstatus==3
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


** SPATIAL DEFLATOR
*<_spdef_>
	gen spdef=spi
	la var spdef "Spatial deflator"
*</_spdef_>

** WELFARE
*<_welfare_>
	gen welfare=pcer
	la var welfare "Welfare aggregate"
*</_welfare_>

*<_welfarenom_>
	gen welfarenom=pce
	la var welfarenom "Welfare aggregate in nominal terms"
*</_welfarenom_>

*<_welfaredef_>
	gen welfaredef=pcer
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
	gen welfareothertype=""
	la var welfareothertype "Type of welfare measure (income, consumption or expenditure) for welfareother"
*</_welfareothertype_>

*<_welfarenat_>
	gen welfarenat=welfaredef
	la var welfarenat "Welfare aggregate for national poverty"
*</_welfarenat_>	
/*****************************************************************************************************
*                                                                                                    *
                                   NATIONAL POVERTY
*                                                                                                    *
*****************************************************************************************************/

	
	
** POVERTY LINE (NATIONAL)
*<_pline_nat_>
	gen pline_nat=ztot
	label variable pline_nat "Poverty Line (National)"
*</_pline_nat_>


** HEADCOUNT RATIO (NATIONAL)
*<_poor_nat_>
	gen poor_nat=welfarenat<pline_nat if welfarenat!=. & pline_nat!=.
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
	merge m:1 countrycode year urb using "$pricedata", ///
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

	keep countrycode year survey idh idp wgt strata psu vermast veralt urban int_month int_year  ///
	     subnatid1 subnatid2 subnatid3 ownhouse water electricity toilet landphone cellphone ///
	     computer internet hsize relationharm relationcs male age soc marital ed_mod_age everattend ///
	     atschool electricity literacy educy educat4 educat5 educat7 lb_mod_age lstatus empstat njobs ///
	     ocusec nlfreason unempldur_l unempldur_u industry occup firmsize_l firmsize_u whours wage ///
		 unitwage contract healthins socialsec union pline_nat pline_int poor_nat poor_int spdef cpi ppp ///
		 cpiperiod welfare welfarenom welfaredef welfarenat welfareother welfaretype welfareothertype

** ORDER VARIABLES

	order countrycode year survey idh idp wgt strata psu vermast veralt urban int_month int_year ///
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


	saveold "`output'\Data\Harmonized\MDV_2009_HIES_v01_M_v02_A_SARMD_IND.dta", replace version(12)
	saveold "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\__REGIONAL\Individual Files\MDV_2009_HIES_v01_M_v02_A_SARMD_IND.dta", replace version(12)


	log close












******************************  END OF DO-FILE  *****************************************************/
