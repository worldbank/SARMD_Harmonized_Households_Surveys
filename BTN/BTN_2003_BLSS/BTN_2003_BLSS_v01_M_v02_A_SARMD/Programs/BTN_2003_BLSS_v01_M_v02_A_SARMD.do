/*****************************************************************************************************
******************************************************************************************************
**                                                                                                  **
**                       INTERNATIONAL INCOME DISTRIBUTION DATABASE (I2D2)                          **
**                                                                                                  **
** COUNTRY			BHUTAN
** COUNTRY ISO CODE	BTN
** YEAR				2003
** SURVEY NAME		BHUTAN LIVING STANDARD SURVEY (BLSS) 2003
** SURVEY AGENCY	NATIONAL STATISTICAL BUREAU
** RESPONSIBLE		Triana Yentzen
**                                                                                                  **
******************************************************************************************************
*****************************************************************************************************/

/*****************************************************************************************************
*                                                                                                    *
                                   INITIAL COMMANDSF
*                                                                                                    *
*****************************************************************************************************/


** INITIAL COMMANDS
	cap log close
	clear
	set more off
	set mem 500m

** DIRECTORY
	local input "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\BTN\BTN_2003_BLSS\BTN_2003_BLSS_v01_M"
	local output "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\BTN\BTN_2003_BLSS\BTN_2003_BLSS_v01_M_v02_A_SARMD"

** LOG FILE
	log using "`output'\Doc\Technical\BTN_2003_BLSS_v01_M_v02_A_SARMD.log",replace

/*****************************************************************************************************
*                                                                                                    *
                                   * ASSEMBLE DATABASE
*                                                                                                    *
*****************************************************************************************************/


** DATABASE ASSEMBLENT
	
	* PREPARE DATASETS
	
	use "`input'\Data\Stata\hroster_edited.dta" 
	order stratum dzongkha town block houseno idno
	sort  stratum dzongkha town block houseno idno
	tempfile roster
	save `roster'
	
	use "`input'\Data\Stata\block2_edited.dta" 
	order stratum dzongkha town block houseno idno
	sort  stratum dzongkha town block houseno idno
	tempfile individual
	save `individual'
	
	use "`input'\Data\Stata\block1_edited.dta" 
	order stratum dzongkha town block houseno
	sort  stratum dzongkha town block houseno
	tempfile housing
	save `housing'
	
	use "`input'\Data\Stata\block3_edited.dta" 
	order stratum dzongkha town block houseno
	sort  stratum dzongkha town block houseno
	tempfile assets
	save `assets'
	
	use "`input'\Data\Stata\block7_edited.dta" 
	order stratum dzongkha town block houseno
	sort  stratum dzongkha town block houseno
	tempfile income
	save `income'
	
	use "`input'\Data\Stata\paachse_index.dta" 
	order stratum dzongkha town block houseno
	sort  stratum dzongkha town block houseno
	tempfile weight
	save `weight'
	
	use "`input'\Data\Stata\consumption_total.dta" 
	order stratum dzongkha town block houseno
	sort  stratum dzongkha town block houseno
	tempfile consumption
	save `consumption'
	
	* MERGE DATASETS
	
	use `roster' 
	merge 1:1 stratum dzongkha town block houseno idno using `individual'
	drop _merge
	
	merge m:1 stratum dzongkha town block houseno using `housing'
	drop _merge
	
	merge m:1 stratum dzongkha town block houseno using `assets'
	drop _merge
	
	merge m:1 stratum dzongkha town block houseno using `income'
	drop _merge

	merge m:1 stratum dzongkha town block houseno using `weight'
	drop _merge

	merge m:1 stratum dzongkha town block houseno using `consumption'
	drop _merge


	* MERGE WITH OLD CONSUMPTION AGGREGATE (Can't find a new one)
	gen stratum_	= string(stratum,"%02.0f")
	gen dzongkha_	= string(dzongkha,"%02.0f")
	gen town_		= string(town,"%02.0f")
	gen block_		= string(block,"%02.0f")
	replace block_	="00" if block==.
	gen houseno_	= string(houseno,"%02.0f")

	egen houseid_str=concat(stratum_ dzongkha_ town_ block_ houseno_)
	destring houseid_str , generate(idh)
	format idh %10.0f
	tostring idh, replace
	label var idh "Household id"
*</_idh_>
	
	merge m:1 idh using "`input'\Data\Stata\pcc.dta" 
	drop _merge
	
	
/*****************************************************************************************************
*                                                                                                    *
                                   * STANDARD SURVEY MODULE
*                                                                                                    *
*****************************************************************************************************/


** COUNTRY
*<_countrycode_>
	gen str4 countrycode="BTN"
	label var countrycode "Country code"
*</_countrycode_>


** YEAR
*<_year_>
	gen int year=2003
	label var year "Year of survey"
*</_year_>

** SURVEY NAME 
*<_survey_>
	gen str survey="BLSS"
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
	label var idh "Household id"
*</_idh_>


** INDIVIDUAL IDENTIFICATION NUMBER
*<_idp_>

	gen ind_str	= string(idno,"%02.0f")
	egen idp	= concat(idh ind_str)
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
	*egen psu=group(stratum_ dzongkha_ town_ block_ )
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
	gen urban=stratum
	recode urban (2=0)
	label var urban "Urban/Rural"
	la de lblurban 1 "Urban" 0 "Rural"
	label values urban lblurban
*</_urban_>


**REGIONAL AREAS

** REGIONAL AREA 1 DIGIT ADMN LEVEL
*<_subnatid1_>
	gen area01=dzongkha
	recode area01 (11 12 13 14  41 = 1) (15 16 17 44 43 = 2) (31/36=3) (21 22 23 42 = 4), gen(subnatid1)
	label var subnatid1 "Region at 1 digit (ADMN1)"
	la de lblsubnatid1 1 "Western" 2 "Central" 3 "Eastern"  4 "Southern"
	label values subnatid1 lblsubnatid1
*</_subnatid1_>

** REGIONAL AREA 2 DIGIT ADMN LEVEL
*<_subnatid2_>
	gen subnatid2=dzongkha
	label var subnatid2 "Region at 1 digit (ADMN1)"
	la de lblsubnatid2 11 "Chukha" 12 "Ha" 13 "Paro" 14 "Thimphu" 15 "Punakha" 16 "Gasa" ///
	17 "Wangdi Phodrang" 21 "Bumthang" 22 "Trongsa" 23 "Zhemgang" 31 "Lhuntshi" 32 "Mongar" ///
	33 "Trashigang" 34 "Tashi Yangtse" 35 "Pemagatshel" 36 "Samdrup Jongkhar" 41 "Samtse" ///
	42 "Sarpang" 43 "Tsirang" 44 "Dagana"
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
	gen ownhouse=b1_q2
	label var ownhouse "House ownership"
	recode ownhouse (2=0)
	la de lblownhouse 0 "No" 1 "Yes"
	label values ownhouse lblownhouse
*</_ownhouse_>

** WATER PUBLIC CONNECTION
*<_water_>
	gen water=b1_q12==1
	label var water "Water main source"
	la de lblwater 0 "No" 1 "Yes"
	label values water lblwater
*</_water_>

** ELECTRICITY PUBLIC CONNECTION
*<_electricity_>

	gen electricity=b1_q18==2
	label var electricity "Electricity main source"
	la de lblelectricity 0 "No" 1 "Yes"
	label values electricity lblelectricity
*</_electricity_>

** TOILET PUBLIC CONNECTION
*<_toilet_>

	gen toilet=b1_q16==2
	label var toilet "Toilet facility"
	la de lbltoilet 0 "No" 1 "Yes"
	label values toilet lbltoilet
*</_toilet_>


** LAND PHONE
*<_landphone_>

	gen landphone=b1_q11==1
	label var landphone "Phone availability"
	la de lbllandphone 0 "No" 1 "Yes"
	label values landphone lbllandphone
*</_landphone_>


** CEL PHONE
*<_cellphone_>

	gen cellphone=b3_q1mob ==1|b3_q1mob ==2
	label var cellphone "Cell phone"
	la de lblcellphone 0 "No" 1 "Yes"
	label values cellphone lblcellphone
*</_cellphone_>


** COMPUTER
*<_computer_>
	gen computer=1 if b3_q1com ==1|b3_q1com ==2
	replace computer=0 if b3_q1com==3
	label var computer "Computer availability"
	la de lblcomputer 0 "No" 1 "Yes"
	label values computer lblcomputer
*</_computer_>


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

	ren hh_size hsize
	label var hsize "Household size"
*</_hsize_>


** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
*<_relationharm_>
	gen relationharm=b21_q2
	recode relationharm (5/11=5) (12/13=6) 
	label var relationharm "Relationship to the head of household"
	la de lblrelationharm  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Non-relatives"
	label values relationharm  lblrelationharm
*</_relationharm_>

** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
*<_relationcs_>

	gen byte relationcs=b21_q2
	la var relationcs "Relationship to the head of household country/region specific"
	label define lblrelationcs 1 "Self(head" 2 "Wife/Husband" 3 "Son/daughter" 4 "Father/Mother" 5 "Sister/Brother" 6 "Grandchild" 7 "Niece/nephew" 8 "Son-in-law/daughter-in-law" 9 "Brother-in-law/sister-in-law" 10 "Father-in-law/mother-in-law" 11 "Other family relative" 12 "Live-in-servant" 13 "Other-non-relative"
	label values relationcs lblrelationcs
*</_relationcs_>


** GENDER
*<_male_>
	gen male=b21_q1
	recode male (2=0)
	label var male "Sex of household member"
	la de lblmale 1 "Male" 0 "Female"
	label values male lblmale
*</_male_>


** AGE
*<_age_>
	*gen age=b21_q3ag
	label var age "Age of individual"
*</_age_>


** SOCIAL GROUP
*<_soc_>
	gen soc=b21_q5
	label var soc "Social group"
	la de lblsoc 1 "Bhutanese" 2 "Other"
	label values soc lblsoc
*</_soc_>


** MARITAL STATUS
*<_marital_>
gen marital=b21_q4
	recode marital (3 4=4) (2=2) (5=5)
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
	gen ed_mod_age=3
	label var ed_mod_age "Education module application age"
*</_ed_mod_age_>


** EVER ATTENDED SCHOOL
*<_everattend_>
	gen everattend=b22_q8
	recode everattend (2=0)
	label var everattend "Ever attended school"
	la de lbleverattend 0 "No" 1 "Yes"
	label values everattend lbleverattend
*</_everattend_>



** CURRENTLY AT SCHOOL
*<_atschool_>
	gen atschool=b22_q9
	recode atschool (2=0)
	label var atschool "Attending school"
	la de lblatschool 0 "No" 1 "Yes"
	label values atschool  lblatschool
*</_atschool_>


** CAN READ AND WRITE
*<_literacy_>
	gen literacy=.
	replace literacy=0 if b22_q7dz==2 & b22_q7en==2 & b22_q7ot==2 & b22_q7lo==2
	replace literacy=1 if b22_q7dz==1 | b22_q7en==1 | b22_q7ot==1 | b22_q7lo==1
	label var literacy "Can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy
*</_literacy_>


** YEARS OF EDUCATION COMPLETED
*<_educy_>
	gen educy1=.
	replace educy1=0 if  b22_q10==00 |  b22_q10==01 | b22_q16==00
	replace educy1=1 if  b22_q10==02  | b22_q16==01
	replace educy1=2 if  b22_q10==03 | b22_q16==02
	replace educy1=3 if  b22_q10==04 | b22_q16==03
	replace educy1=4 if  b22_q10==05 | b22_q16==04
	replace educy1=5 if  b22_q10==06 | b22_q16==05
	replace educy1=6 if  b22_q10==07 | b22_q16==06
	replace educy1=7 if  b22_q10==08 | b22_q16==07
	replace educy1=8 if  b22_q10==09 | b22_q16==08
	replace educy1=9 if  b22_q10==10 | b22_q16==09
	replace educy1=10 if  b22_q10==11 | b22_q16==010
	replace educy1=11 if  b22_q10==12 | b22_q16==011
	replace educy1=12 if  b22_q10==13 | b22_q16==012
	replace educy1=13 if  b22_q10==14 | b22_q16==013
	replace educy1=14 if  b22_q10==15 | b22_q16==014
	replace educy1=15 if  b22_q16==015
	replace educy1 = 0 if b22_q8==2 & mi(educy1)

	gen CONEDYEARS=.
	replace CONEDYEARS=educy1

	local i = 1
	while `i'<25 {
	replace CONEDYEARS = `i' if age == (`i'+4) & educy1 > `i' & educy1!=.
	local i = `i'+1
	}
	replace CONEDYEARS = 0 if b22_q8==2 & mi(CONEDYEARS)
	ren CONEDYEARS educy
	label var educy "Years of education"
*</_educy_>

	replace educy=. if educy>age & educy!=. & age!=.



** EDUCATION LEVEL 7 CATEGORIES
*<_educat7_>
	gen byte educat7=.
	replace educat7=1 if educy==0
	replace educat7=2 if educy>0 & educy<8
	replace educat7=3 if educy==8
	replace educat7=4 if educy>8 & educy<12
	replace educat7=5 if educy>=12 & educy<=15
	replace educat7=6 if b22_q17>=2 & b22_q17<5
	replace educat7=. if educat7==6 & educy<12
	replace educy=. if educat7==.
	replace educat7=7 if b22_q17==1
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

	

/*****************************************************************************************************
*                                                                                                    *
                                   LABOR MODULE
*                                                                                                    *
*****************************************************************************************************/


** LABOR MODULE AGE
*<_lb_mod_age_>

	gen lb_mod_age=15
	label var lb_mod_age "Labor module application age"
*</_lb_mod_age_>



** LABOR STATUS
*<_lstatus_>
	gen lstatus = .  
	replace lstatus = 1 if inlist(1,  b24_q33w, b24_q34w, b24_q35w)
	replace lstatus = 2 if  b24_q36==1 & mi(lstatus)
	replace lstatus = 3 if b24_q37!=. & lstatus!=1
	replace lstatus = . if age<15 

	label var lstatus "Labor status"
	label define lbllstatus 1"Employed" 2"Unemployed" 3"Not-in-labor-force"
	label values lstatus lbllstatus
*</_lstatus_>


** EMPLOYMENT STATUS
*<_empstat_>
	gen empstat=b24_q38
	recode empstat 2 6=1 5=2 3=4 7=5 4=3
	label var empstat "Employment status"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other"
	replace empstat =. if lstatus!=1
	label values empstat lblempstat
*</_empstat_>

** SECTOR OF ACTIVITY: PUBLIC - PRIVATE
*<_njobs_>
	gen njobs=.
	label var njobs "Number of additional jobs"
*</_njobs_>


** SECTOR OF ACTIVITY: PUBLIC - PRIVATE
*<_ocusec_>
	gen ocusec=b24_q41
	recode ocusec (1 2 =1) ( 3/8 10 =3)  (9 11=.)
	recode ocusec (3=2)
	label var ocusec "Sector of activity"
	la de lblocusec 1 "Public, state owned, government, army, NGO" 2 "Private"
	label values ocusec lblocusec
*</_ocusec_>
	replace ocusec=. if lstatus!=1 | age<15


** REASONS NOT IN THE LABOR FORCE
*<_nlfreason_>
	gen nlfreason=b24_q37
	recode nlfreason (5=1) (6=2) (7 8=3) (9=4) (1/4  10/11=5)
	 replace nlfreason=. if lstatus!=3
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

** INDUSTRY CLASSIFICATION
*<_industry_>
	gen industry=b24_q40
	recode industry (7=6) (8=7) (9 10=8) (11=9) (12/14=10)
	replace  industry =. if age<15 | industry==11
	label var industry "1 digit industry classification"
	la de lblindustry 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Comnunications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industry lblindustry
*</_industry_>


** OCCUPATION CLASSIFICATION
*<_occup_>
	gen occup=int(b24_q39/100)
	recode occup (0=10)
	recode occup(9=99) if b24_q39==999
	label var occup "1 digit occupational classification"
	la de occup 1 "Senior officials" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup occup
	replace occup=. if lstatus!=1 | age<15


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
	gen whours=b24_q47m
	*infeasible weekly working hours reported - to be recoded to missing
	*histogram whours if whours<100
	replace whours=. if whours>98
	label var whours "Hours of work in last week"
*</_whours_>
	replace whours=. if lstatus!=1 | age<15


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
	gen spdef=paachse
	la var spdef "Spatial deflator"
*</_spdef_>

** WELFARE
*<_welfare_>
	gen welfare=pcc_t_mo
	la var welfare "Welfare aggregate"
*</_welfare_>

*<_welfarenom_>
	gen welfarenom=pcc_t_mo
	la var welfarenom "Welfare aggregate in nominal terms"
*</_welfarenom_>

*<_welfaredef_>
	gen welfaredef=pcc_t_mo*paachse
	la var welfaredef "Welfare aggregate spatially deflated"
*</_welfaredef_>

*<_welfshprosperity_>
	gen welfshprosperity=welfaredef
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
	gen pline_nat=740.36
	label variable pline_nat "Poverty Line (National)"
*</_pline_nat_>

	
** HEADCOUNT RATIO (NATIONAL)
*<_poor_nat_>
	gen poor_nat=welfarenat<pline_nat if welfaredef!=.
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

	keep countrycode year survey idh idp wgt strata psu vermast veralt urban int_month int_year ///
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


	saveold "`output'\Data\Harmonized\BTN_2003_BLSS_v01_M_v02_A_SARMD_IND.dta", replace version(12)
	saveold "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\__REGIONAL\Individual Files\BTN_2003_BLSS_v01_M_v02_A_SARMD_IND.dta", replace version(12)

	log close




******************************  END OF DO-FILE  *****************************************************/
