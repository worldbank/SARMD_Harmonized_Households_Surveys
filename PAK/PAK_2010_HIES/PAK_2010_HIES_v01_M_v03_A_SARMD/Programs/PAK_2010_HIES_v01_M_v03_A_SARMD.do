/*****************************************************************************************************
******************************************************************************************************
**                                                                                                  **
**                                   SOUTH ASIA MICRO DATABASE                                      **
**                                                                                                  **
** COUNTRY			Pakistan
** COUNTRY ISO CODE	PAK
** YEAR				2010
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
	local input "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\PAK\PAK_2010_PSLM\PAK_2010_PSLM_v01_M"
	local output "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\PAK\PAK_2010_PSLM\PAK_2010_PSLM_v01_M_v03_A_SARMD"

** LOG FILE
	log using "`output'\Doc\Technical\PAK_2010_PSLM_v01_M_v03_A.log",replace


/*****************************************************************************************************
*                                                                                                    *
                                   * ASSEMBLE DATABASE
*                                                                                                    *
*****************************************************************************************************/


** DATABASE ASSEMBLENT

/*
Consumption. From Freeha's Database
*/
	use "`input'\Data\Stata\Consumption Master File with CPI.dta"
	tempfile comp
	keep if year==2010
	keep hhcode nomexpend eqadultM peaexpM psupind new_pline texpend region hhsizeM
	save  `comp' , replace

/*
Household Roster
*/
	use "`input'\Data\Stata\plist.dta", clear
	tempfile aux
	isid hhcode idc
	
	merge m:1 hhcode using `comp'
	drop _merge
	
	save `aux', replace


/*
Employment
*/
	use "`input'\Data\Stata\sec_e_.dta", clear
	isid hhcode idc
	merge 1:1 hhcode idc using `aux'
	tab _merge

/*
3 obs deleted
*/

	*drop if _merge==1
	drop _merge
	save `aux', replace


/*
Education
*/
	use "`input'\Data\Stata\sec c.dta", clear
	isid hhcode idc 
	merge 1:1 hhcode idc using `aux'
	tab _merge

/*
0 obs deleted
*/
	*drop if _merge==1
	drop _merge
	save `aux', replace


/*
Detail on the family (housing info)
*/
	use "`input'\Data\Stata\sec g.dta", clear
	isid hhcode
	merge 1:m hhcode using `aux'
	tab _merge
	*drop if _merge==1

/*
0 obs deleted
*/
	drop _merge
	save `aux', replace

/*
Assets in possession
*/
	use "`input'\Data\Stata\sec f2.dta", clear
	isid hhcode
	merge 1:m hhcode using `aux'
	tab _merge

/*
0 obs deleted
*/
	*drop if _merge==1
	drop _merge
	save `aux', replace

	use "`input'\Data\Stata\sec_a.dta", clear
	isid hhcode
	merge 1:m hhcode using `aux'
	tab _merge
	*drop if _merge==1
	drop _merge
	save `aux', replace

	use `aux', clear
	merge m:1 hhcode using `comp'
	tab _merge
	drop _merge

***************************************************************************************************
* Rename Variables

ren Enu_Date 	enu_date
ren region		urbrural


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
	gen int year=2010
	label var year "Year of survey"
*</_year_>

** SURVEY NAME 
*<_survey_>
	gen str survey="PSLM"
	label var survey "Survey Acronym"
*</_survey_>



	split enu_date,  parse(/) g(d)
	destring d1 d2 d3, replace
	replace d3=2000+d3
	*replace d2=. if d2<7  & d3==2010 & d2!=.
	*replace d2=. if d2>=7 & d3==2011 & d2!=.
	
	
** INTERVIEW YEAR
	gen int_year=d3
	label var int_year "Year of the interview"
*</_int_year_>

	
** INTERVIEW MONTH
	gen int_month=d2
	la de lblint_month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
	label value int_month lblint_month
	label var int_month "Month of the interview"
*</_int_month_>

	
** HOUSEHOLD IDENTIFICATION NUMBER
*<_idh_>
	gen double idh_=hhcode
	gen idh=string(idh_,"%16.0g")
	drop idh_
	label var idh "Household id"
*</_idh_>

** INDIVIDUAL IDENTIFICATION NUMBER
*<_idp_>

	gen double idp_= hhcode*100+idc
	gen idp=string(idp_,"%16.0g")
	label var idp "Individual id"
*</_idp_>



** HOUSEHOLD WEIGHTS
*<_wgt_>
	egen wgt=max(weight), by(idh countrycode year)
	label var wgt "Household sampling weight"
*</_wgt_>


** STRATA
*<_strata_>

	gen strata=.
	label var strata "Strata"
*</_strata_>


** PSU
*<_psu_>
	*gen psu=psu
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
	gen byte urban=urbrural
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
	gen byte subnatid2=province
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
	gen byte ownhouse=1 if sgq01==1 | sgq01==2
	replace ownhouse=0 if sgq01>2 & sgq01<=5
	label var ownhouse "House ownership"
	la de lblownhouse 0 "No" 1 "Yes"
	label values ownhouse lblownhouse
*</_ownhouse_>

** WATER PUBLIC CONNECTION
*<_water_>
	gen byte water=1 if sgq05==1
	replace water=0 if sgq05>=2 & sgq05<=10
	label var water "Water main source"
	la de lblwater 0 "No" 1 "Yes"
	label values water lblwater
*</_water_>

** ELECTRICITY PUBLIC CONNECTION
*<_electricity_>

/*
There is no explicit question. Survey asks four main energy used for cooking or lighting. Not for availability of electricity.
*/
	recode sgq08 (1=1) (2 3 4 5 6 = 0), gen(electricity)
	label var electricity "Electricity main source"
	la de lblelectricity 0 "No" 1 "Yes"
	label values electricity lblelectricity
	note electricity: this variable is generated if hh main source of lighting is electricity
*</_electricity_>

** TOILET PUBLIC CONNECTION
*<_toilet_>

	gen byte toilet=1 if sgq06==2
	replace toilet=0 if sgq06==1 | sgq06>2 & sgq05<=7

	label var toilet "Toilet facility"
	la de lbltoilet 0 "No" 1 "Yes"
	label values toilet lbltoilet
*</_toilet_>


** LAND PHONE
*<_landphone_>

	gen byte landphone=1 if sgq09==2 | sgq09==4
	replace landphone=0 if sgq09==1 | sgq09==3
	label var landphone "Phone availability"
	la de lbllandphone 0 "No" 1 "Yes"
	label values landphone lbllandphone
*</_landphone_>


** CEL PHONE
*<_cellphone_>

	gen byte cellphone=1 if sgq09==3 | sgq09==4
	replace cellphone=0 if sgq09==1 | sgq09==2
	label var cellphone "Cell phone"
	la de lblcellphone 0 "No" 1 "Yes"
	label values cellphone lblcellphone
*</_cellphone_>


** COMPUTER
*<_computer_>
	gen byte computer=1 if sf2q11l==1
	replace computer=0 if sf2q11l==2
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
	g aux=1
	egen hsize2=sum(aux), by(idh)
	sort idh idp
	drop if hsize==. & hsize!=hsize2 & hsize2!=1
	replace hsize=hsize2 if hsize==. & hsize2==1
	drop aux hsize2
*</_hsize_>


** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
*<_relationharm_>
	gen byte relationharm=Sbq02
	recode relationharm (4 6 7 8 9 10 =5) (5=4) (11 12 = 6)
	label var relationharm "Relationship to the head of household"
	la de lblrelationharm  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Non-relatives"
	label values relationharm  lblrelationharm
*</_relationharm_>

** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
*<_relationcs_>

	gen byte relationcs=Sbq02
	la var relationcs "Relationship to the head of household country/region specific"
	label define lblrelationcs 1 "Head" 2 "Spouse" 3 "Son/Daughter" 4 "Grandchild" 5 "Father/Mother" 6 "Brother/Sister" 7  "Nephew/Niece" 8 "Son/Daughter-in-law" 9 "Brother/Sister-in-law" 10 "Father/Mother-in-law" 11 "Servant/their relatives" 12 "Other"
	label values relationcs lblrelationcs
*</_relationcs_>


** GENDER
*<_male_>
	gen byte male=Sbq03
	recode male (2=0)
	label var male "Sex of household member"
	la de lblmale 1 "Male" 0 "Female"
	label values male lblmale
*</_male_>


** AGE
*<_age_>
	gen age=Age
	label var age "Age of individual"
*</_age_>


** SOCIAL GROUP
*<_soc_>
	gen byte soc=.
	label var soc "Social group"
	la de lblsoc 1 ""
	label values soc lblsoc
*</_soc_>


** MARITAL STATUS
*<_marital_>
	gen byte marital=1 if Sbq06==2 | Sbq06==5
	replace marital=2 if Sbq06==1
	replace marital=4 if Sbq06==4
	replace marital=5 if Sbq06==3
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
	gen byte atschool=1 if Scq05==1
	replace atschool=0 if Scq05==2
	replace atschool=0 if Scq03==2
	replace atschool=. if age<ed_mod_age & age!=.
	label var atschool "Attending school"
	la de lblatschool 0 "No" 1 "Yes"
	label values atschool  lblatschool
*</_atschool_>


** CAN READ AND WRITE
*<_literacy_>
	gen byte literacy=Scq01
	replace literacy=0 if Scq01==2

	replace literacy=. if age<ed_mod_age & age!=.
	label var literacy "Can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy
*</_literacy_>


** YEARS OF EDUCATION COMPLETED
*<_educy_>
	gen byte educy=Scq04
	replace educy=13 if Scq04==17 /* Diploma */
	replace educy=14 if Scq04==14 /* BA/BSc */
	replace educy=16 if Scq04==18 /* Engineer */
	replace educy=17 if Scq04==19 /* Medicine */
	replace educy=16 if Scq04==20 /* Agriculture */
	replace educy=16 if Scq04==21 /* Law */
	replace educy=16 if Scq04==16 /* MA/MSc */
	replace educy=19 if Scq04==22 /* MPhl/PhD */
	replace educy=. if Scq04==23 /* Others */

/*
CHECK!! Source: "http://www-db.in.tum.de/teaching/ws1112/hsufg/Taxila/Site/formal.html"
*/

	replace educy=. if age<ed_mod_age & age!=.
	label var educy "Years of education"
*</_educy_>
	replace educy=. if age<educy & age!=. & educy!=.


** EDUCATION LEVEL 7 CATEGORIES
*<_educat7_>
	gen byte educat7=1 if Scq04==0
	replace educat7=2 if Scq04 >0 & Scq04<8
	replace educat7=3 if Scq04==8
	replace educat7=4 if Scq04>8 &  Scq04<12
	replace educat7=5 if Scq04==12
	replace educat7=7 if Scq04>12 & Scq04<=22
	replace educat7=6 if Scq04==17
	replace educat7=. if Scq04==23
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
	gen byte everattend=Scq03
	replace everattend=0 if everattend==2
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

 gen byte lb_mod_age=10
	label var lb_mod_age "Labor module application age"
*</_lb_mod_age_>



** LABOR STATUS
*<_lstatus_>

/*
Reported in monthly basis. (not in a weekly basis)
*/
	gen byte lstatus=1 if Seq01==1 | Seq03==1
	replace lstatus=2 if Seq01==2 & Seq03==2
	replace lstatus=3 if Seq01==2 & Seq03==3
	replace lstatus=. if age<lb_mod_age & age!=.

	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus
*</_lstatus_>


** EMPLOYMENT STATUS
*<_empstat_>
	gen byte empstat=1 if Seq06==4
	replace empstat=2 if Seq06==5
	replace empstat=3 if Seq06==1 | Seq06==2
	replace empstat=4 if Seq06==3 | Seq06>=6 & Seq06<=9

	replace empstat=. if lstatus!=1
	label var empstat "Employment status"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed"
	label values empstat lblempstat
*</_empstat_>


** SECTOR OF ACTIVITY: PUBLIC - PRIVATE
*<_njobs_>
	gen byte njobs=.

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
	gen byte industry=1 if Seq05>=1 & Seq05<=5
	replace industry=2 if Seq05>=10 & Seq05<=14
	replace industry=3 if Seq05>=15 & Seq05<=37
	replace industry=4 if Seq05>=40 & Seq05<=41
	replace industry=5 if Seq05==45
	replace industry=6 if Seq05>=51 & Seq05<=55
	replace industry=7 if Seq05>=60 & Seq05<=64
	replace industry=8 if Seq05>=65 & Seq05<=74
	replace industry=9 if Seq05==75
	replace industry=10 if Seq05>=80 & Seq05<=99
	replace industry=. if lstatus!=1
	label var industry "1 digit industry classification"
	la de lblindustry 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Comnunications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industry lblindustry
*</_industry_>


** OCCUPATION CLASSIFICATION
*<_occup_>
	gen byte occup=.
	replace occup=10 if Seq04==1
	replace occup=1 if Seq04>=11 & Seq04<=13
	replace occup=2 if Seq04>=21 & Seq04<=24
	replace occup=3 if Seq04>=31 & Seq04<=34
	replace occup=4 if Seq04>=41 & Seq04<=42
	replace occup=5 if Seq04>=51 & Seq04<=52
	replace occup=6 if Seq04>=61 & Seq04<=62
	replace occup=7 if Seq04>=71 & Seq04<=74
	replace occup=8 if Seq04>=81 & Seq04<=83
	replace occup=9 if Seq04>=91 & Seq04<=93

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
	/*
Last monthly wage in main occupation (when wage is reported in monthly basis)
*/
	gen double wage=Seq08
	replace wage=. if lstatus!=1
	label var wage "Last wage payment"
*</_wage_>


** WAGES TIME UNIT
*<_unitwage_>

/*
Reported in monthly basis. (main occupation in the last month)
*/
	gen byte unitwage=5

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
	     computer internet hsize eqadult relationharm relationcs male age soc marital ed_mod_age everattend ///
	     atschool electricity literacy educy educat4 educat5 educat7 lb_mod_age lstatus empstat njobs ///
	     ocusec nlfreason unempldur_l unempldur_u industry occup firmsize_l firmsize_u whours wage ///
		 unitwage contract healthins socialsec union pline_nat pline_int poor_nat poor_int spdef cpi ppp ///
		 cpiperiod welfare welfarenom welfaredef welfarenat welfareother welfaretype welfareothertype

** ORDER VARIABLES

	order countrycode year survey idh idp wgt strata psu vermast veralt urban int_month int_year ///
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
	keep countrycode year survey idh idp wgt strata psu vermast veralt `keep' *type

	compress

	
	saveold "`output'\Data\Harmonized\PAK_2010_PSLM_v01_M_v03_A_SARMD_IND.dta", replace version(13)
	saveold "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\__REGIONAL\Individual Files\PAK_2010_PSLM_v01_M_v03_A_SARMD_IND.dta", replace version(13)


	log close


















******************************  END OF DO-FILE  *****************************************************/
