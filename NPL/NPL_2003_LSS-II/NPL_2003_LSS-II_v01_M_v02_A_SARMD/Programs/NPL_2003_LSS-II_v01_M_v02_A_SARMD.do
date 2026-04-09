/*****************************************************************************************************
******************************************************************************************************
**                                                                                                  **
**                                   SOUTH ASIA MICRO DATABASE                                      **
**                                                                                                  **
** COUNTRY			NEPAL
** COUNTRY ISO CODE	NPL
** YEAR				2003
** SURVEY NAME		NEPAL LIVING STANDARDS SURVEY II 2003
** SURVEY AGENCY	CENTRAL BUREAU OF STATISTICS
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
	local input "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\NPL\NPL_2003_LSS-II\NPL_2003_LSS-II_v01_M"
	local output "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\NPL\NPL_2003_LSS-II\NPL_2003_LSS-II_v01_M_v02_A_SARMD"

** LOG FILE
	log using "`output'\Doc\Technical\NPL_2003_LSS-II.log",replace


/*****************************************************************************************************
*                                                                                                    *
                                   * ASSEMBLE DATABASE
*                                                                                                    *
*****************************************************************************************************/


** DATABASE ASSEMBLENT
	
	* PREPARE DATASETS
	
	use "`input'\Data\Stata\R2_Z01A_HHRoster.dta", clear
	sort WWWHH r2_IDC
	tempfile roster
	save `roster'
	
	use "`input'\Data\Stata\R2_Z01C_Activities.dta", clear
	sort WWWHH r2_IDC r2_activcode
	
	merge 1:1 WWWHH r2_IDC r2_activcode using "`input'\Data\Stata\R2_Z10B1_WgEmplmntNAgri.dta"
	ren _merge mergenonag
	
	merge 1:1 WWWHH r2_IDC r2_activcode using "`input'\Data\Stata\R2_Z10A1_WgEmplmntAgri.dta"
	ren _merge mergeag

	gsort WWWHH r2_IDC -r2_12moswrkt -r2_12daypmwr -r2_12hourdwr -r2_7dayswork -r2_7hrperday -r2_7hrperwek
	bys WWWHH r2_IDC: keep if _n==1
	tempfile activities
	save `activities'
	
	use "`input'\Data\Stata\R2_Z01D_Unemployment.dta", clear
	sort WWWHH r2_IDC
	tempfile unemp
	save `unemp'
	
	use "`input'\Data\Stata\R2_Z07A_Literacy.dta", clear
	sort WWWHH r2_IDC
	tempfile literacy
	save `literacy'
	
	use "`input'\Data\Stata\R2_Z07B_PastEnroll.dta", clear
	sort WWWHH r2_IDC
	tempfile pastenroll
	save `pastenroll'
	
	use "`input'\Data\Stata\R2_Z07C_CurrEnroll.dta", clear
	sort WWWHH r2_IDC
	tempfile currenroll
	save `currenroll'
	
	use "`input'\Data\Stata\R2_Z02B_HousingXpns.dta", clear
	sort WWWHH
	tempfile property
	save `property'
	
	use "`input'\Data\Stata\R2_Z02C1_UtilsAmenities1.dta", clear
	sort WWWHH
	tempfile amenities1
	save `amenities1'
	
	use "`input'\Data\Stata\R2_Z02C2_UtilsAmenities2.dta", clear
	sort WWWHH
	tempfile amenities2
	save `amenities2'
	
	* MERGE DATASETS
	
	use "`input'\Data\Stata\SAS_NPL_2003_04_NLSS2.dta"
	ren c2_hhsize c2_hhsize_
	keep WWW WWWHH weight pcexp c2_nompln c2_npcexp c2_hhsize_ c2_poor c2_pindex c2_ra_pcexp
	
	sort WWW
	merge m:1 WWW using "`input'\Data\Stata\sample.dta"
	drop _merge
	
	sort WWWHH
	
	foreach x in property amenities1 amenities2{
	merge 1:1 WWWHH using ``x''
	drop if _merge==2
	drop _merge
	}
	
	merge 1:m WWWHH using `roster'
	drop if _merge==2
	drop _merge
	
	sort WWWHH r2_IDC
	
	foreach x in activities unemp literacy pastenroll currenroll{
	merge 1:1 WWWHH r2_IDC using ``x''
	drop if _merge==2
	drop _merge
	}

/*****************************************************************************************************
*                                                                                                    *
                                   * STANDARD SURVEY MODULE
*                                                                                                    *
*****************************************************************************************************/

	
** COUNTRY
*<_countrycode_>
	gen str4 countrycode="NPL"
	label var countrycode "Country name"
*</_countrycode_>

** YEAR
*<_year_>
	gen int year=2003
	label var year "Survey year"
*</_year_>

** SURVEY NAME 
*<_survey_>
	gen str survey="LSS-II"
	label var survey "Survey Acronym"
*</_survey_>


** INTERVIEW YEAR
*<_int_year_>
	gen byte int_year=.
	label var int_year "Year of the interview"
*</_int_year_>
	
	
** INTERVIEW MONTH
	gen int_month=.
	la de lblint_month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
	label value int_month lblint_month
	label var int_month "Month of the interview"
*</_int_month_>


** HOUSEHOLD IDENTIFICATION NUMBER
*<_idh_>
	tostring WWWHH, gen(idh)
	label var idh "Household id"
*</_idh_>


** INDIVIDUAL IDENTIFICATION NUMBER
*<_idp_>

	egen str idp=concat(idh r2_IDC), punct(-)
	tostring idp idh, replace
	label var idp "Individual id"
*</_idp_>

** HOUSEHOLD WEIGHTS
*<_wgt_>
	gen double wgt=weight
	label var wgt "Household sampling weight"
*</_wgt_>


** STRATA
*<_strata_>

	gen strata=stratum
	label var strata "Strata"
*</_strata_>


** PSU
*<_psu_>
	gen psu=WWW
	label var psu "Primary sampling units"
*</_psu_>


** MASTER VERSION
*<_vermast_>

	gen vermast="01"
	label var vermast "Master Version"
*</_vermast_>
	
	
** ALTERATION VERSION
*<_veralt_>

	gen veralt="02"
	label var veralt "Alteration Version"
*</_veralt_>	
	
/*****************************************************************************************************
*                                                                                                    *
                                   HOUSEHOLD CHARACTERISTICS MODULE
*                                                                                                    *
*****************************************************************************************************/


** LOCATION (URBAN/RURAL)
*<_urban_>
	gen urban=urbrural
	recode urban (2=0)
	label var urban "Urban/Rural"
	la de lblurban 1 "Urban" 0 "Rural"
	label values urban lblurban
*</_urban_>


** REGIONAL AREA 1 DIGIT ADMN LEVEL
*<_subnatid1_>
	gen byte subnatid1=region
	la de lblsubnatid1 1 "Eastern" 2 "Central" 3 "Western" 4 "Mid-west" 5 "Far-west"
	label var subnatid1 "Region at 1 digit (ADMN1)"
	label values subnatid1 lblsubnatid1
*</_subnatid1_>


** REGIONAL AREA 2 DIGIT ADMN LEVEL
*<_subnatid2_>
	gen byte subnatid2=district
	la de lblsubnatid2 1 "Taplejung" 2 "Panchthar" 3 "Ilam" 4 "Jhapa" 5 "Morang" 6 "Sunsari" 7 "Dhankuta" 8 "Tehrathum" 9 "Sankhuwasabha" 10 "Bhojpur" 11 "Solukhumbu" 12 "Okhaldhunga" 13 "Khotang" 14 "Udayapur" 15 "Saptari" 16 "Siraha" 17 "Dhanusha" 18 "Mahottari" 19 "Sarlahi" 20 "Sindhuli" 21 "Ramechhap" 22 "Dolakha" 23 "Sindhupalchok" 24 "Kavrepalanchok" 25 "Lalitpur" 26 "Bhaktapur" 27 "Kathmandu" 28 "Nuwakot" 29 "Rasuwa" 30 "Dhading" 31 "Makwanpur" 32 "Rautahat"  33 "Bara" 34 "Parsa" 35 "Chitwan" 36 "Gorkha" 37 "Lamjung" 38 "Tanahun" 39 "Syangja" 40 "Kaski" 41 "Manang" 42 "Mustang" 43 "Myagdi"44 "Parbat" 45 "Baglung" 46 "Gulmi" 47 "Palpa" 48 "Nawalparasi" 49 "Rupandehi" 50 "Kapilbastu" 51 "Arghakhanchi" 52 "Pyuthan" 53 "Rolpa" 54 "Rukum" 55 "Salyan" 56 "Dang" 57 "Banke" 58 "Bardiya" 59 "Surkhet" 60 "Dailekh" 61 "Jajarkot" 62 "Dolpa" 63 "Jumla" 64 "Kalikot" 65 "Mugu" 66 "Humla" 67 "Bajura" 68 "Bajhang" 69 "Achham"  70 "Doti" 71 "Kailali" 72 "Kanchanpur" 73 "Dandheldhura" 74 "Baitadi" 75 "Darchula"
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
	gen byte ownhouse=r2_dwelowned
	recode ownhous 2=0
	label var ownhouse "House ownership"
	la de lblownhouse 0 "No" 1 "Yes"
	label values ownhouse lblownhouse
*</_ownhouse_>

** WATER PUBLIC CONNECTION
*<_water_>
	gen byte water=r2_waterpipe
	recode water 2=0
	label var water "Water main source"
	la de lblwater 0 "No" 1 "Yes"
	label values water lblwater
*</_water_>

** ELECTRICITY PUBLIC CONNECTION
*<_electricity_>

	gen byte electricity=.
	replace electricity=1 if r2_lightsrs==1
	replace electricity=0 if r2_lightsrs==3
	replace electricity=0 if r2_lightsrs==2
	label var electricity "Electricity main source"
	la de lblelectricity 0 "No" 1 "Yes"
	label values electricity lblelectricity
*</_electricity_>

** TOILET PUBLIC CONNECTION
*<_toilet_>

	gen byte toilet=.
	replace toilet=1 if r2_toilettyp==1
	replace toilet=0 if r2_toilettyp==2
	replace toilet=0 if r2_toilettyp==3
	replace toilet=0 if r2_toilettyp==4
	replace toilet=0 if r2_toilettyp==5
	label var toilet "Toilet facility"
	la de lbltoilet 0 "No" 1 "Yes"
	label values toilet lbltoilet
*</_toilet_>


** LAND PHONE
*<_landphone_>

	gen byte landphone=r2_telephone
	recode landphone 2=0
	label var landphone "Phone availability"
	la de lbllandphone 0 "No" 1 "Yes"
	label values landphone lbllandphone
*</_landphone_>


** CEL PHONE
*<_cellphone_>

	gen byte cellphone= r2_teleph_mb
	recode cellphone 2=0
	label var cellphone "Cell phone"
	la de lblcellphone 0 "No" 1 "Yes"
	label values cellphone lblcellphone
*</_cellphone_>


** COMPUTER
*<_computer_>
	gen byte computer=.
	label var computer "Computer availability"
	la de lblcomputer 0 "No" 1 "Yes"
	label values computer lblcomputer
*</_computer_>


** INTERNET
	gen byte internet=r2_internet
	recode internet 2=0
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

	gen byte hsize=c2_hhsize_
	la var hsize "Household size"
*</_hsize_>

	
** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
*<_relationharm_>
	gen byte relationharm=r2_relation
	recode relationharm (5=4) (4 6 7 8 9 0 10 11=5) (12 13 14=6)
	label var relationharm "Relationship to the head of household"
	la de lblrelationharm  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Non-relatives"
	label values relationharm  lblrelationharm
*</_relationharm_>

** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
*<_relationcs_>

	gen byte relationcs=r2_relation
	la var relationcs "Relationship to the head of household country/region specific"
	la define lblrelationcs 1 "Head" 2 "Husband/Wife" 3 "Son/Daughter" 4 "Grandchild" 5 "Father/Mother" 6 "Brother/Sister" 7 "Nephew/Niece" 8 "Son/Daughter-in-law" 9 "Brother/Sister-in-law" 10 "Father/Mother-in-law" 11 "Other family relative" 12 "Servant/servant's relative" 13 "Tenant/tentant's relative" 14 "Other person not related"
	label values relationcs lblrelationcs
*</_relationcs_>

* FIX HARMONIZED RELATIONSHIP TO HEAD OF HOUSEHOLDS FOR HOUSEHOLDS WITH MORE OR LESS THAN ONE HEAD

	gen head=relationharm==1
	bys idh: egen heads=total(head)
	
	replace relationharm=1 if r2_relation==2 & heads==0
	drop head heads
	
	gen head=relationharm==1
	bys idh: egen heads=total(head)
	
	replace relationharm=5 if r2_relation==1 & heads>1 & heads!=. & r2_IDC!=1

	drop head heads

** GENDER
*<_male_>
	gen byte male=r2_sex
	recode male (2=0)
	label var male "Sex of Household Member"
	la de lblmale 1 "Male" 0 "Female"
	label values male lblmale
*</_male_>


** AGE
*<_age_>
	gen byte age=r2_age
	label var age "Age of individual"
*</_age_>


** SOCIAL GROUP
*<_soc_>
	gen byte soc=r2_ethncity
	recode soc 6=5 5=6 8=7 9=8 7=9 14=15 15=14 16/102=15
	label var soc "Social group"
	la de lblsoc 1 "Chhetri" 2 "Brahman" 3 "Magar" 4 "Tharu" 5 "Newar" 6  "Tamang" 7 "Kami"  8 "Yadav" 9 "Muslim" 10  "Rai" 11 "Gurung" 12 "Damai" 13 "Limbu" 14 "Sarki" 15 "Other"
	label values soc lblsoc
*</_soc_>


** MARITAL STATUS
*<_marital_>	
	recode r2_martstats (2 3 =4) (5=2)  (4=5) , gen(marital)
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
	gen byte ed_mod_age=5
	label var ed_mod_age "Education module application age"
*</_ed_mod_age_>


** CURRENTLY AT SCHOOL
*<_atschool_>
	gen byte atschool=.
	replace atschool=1 if r2_educbckr==3
	replace atschool=0 if r2_educbckr==2 | r2_educbckr==1
	label var atschool "Attending school"
	la de lblatschool 0 "No" 1 "Yes"
	label values atschool  lblatschool
*</_atschool_>


** CAN READ AND WRITE
*<_literacy_>
	gen byte literacy=.
	replace  literacy=1 if  r2_canread==1 & r2_canwrite==1
	replace  literacy=0 if  r2_canread==2 | r2_canwrite==2
	label var literacy "Can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy
*</_literacy_>


** YEARS OF EDUCATION COMPLETED
*<_educy_>
	gen inter_edlevel = r2_attendcls
	replace inter_edlevel = r2_edlevcmpl if inter_edlevel == .
	replace inter_edlevel = 0 if r2_educbckr == 1 & inter_edlevel == .
	recode inter_edlevel (16 17 = 0)
	replace inter_edlevel = inter_edlevel -1 if r2_educbckr ==3
	replace inter_edlevel = 10 if inter_edlevel ==11 & r2_educbckr ==2  
	gen byte educy= inter_edlevel
	recode educy (-1 = 0) (13 = 15) (14 15 = 17)
	label var educy "Years of education"
*</_educy_>


** EDUCATION LEVEL 7 CATEGORIES
*<_educat7_>
	recode inter_edlevel  (1/4 = 2) (5/7 = 3) (8/11 = 4) (12=5) (13/15 = 7) (-1 0 = 1), gen(educat7)
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
	gen byte everattend=.
	replace everattend=0 if r2_educbckr==1
	replace everattend=1 if r2_educbckr==2 | r2_educbckr==3
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

 gen byte lb_mod_age=5
	label var lb_mod_age "Labor module application age"
*</_lb_mod_age_>



** LABOR STATUS
*<_lstatus_>
	gen byte lstatus=.
	replace lstatus=1 if r2_occupcode>=1 & r2_occupcode<990
	replace lstatus=2 if r2_unm_avwkr==1 & r2_unm_lkwkr==1
	replace lstatus=3 if r2_unm_avwkr==2
	replace lstatus=2 if r2_unm_avwkr==1 & r2_unm_lkwkr==2
	replace lstatus=3 if r2_occupcode==998
	replace lstatus=3 if r2_occupcode==997
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus
*</_lstatus_>

** EMPLOYMENT STATUS
*<_empstat_>
	gen byte empstat=.
	replace empstat=1 if r2_wgemplagr==1 | r2_wgemplnag==1
	replace empstat=4 if r2_slemplagr==1 | r2_slemplnag==1
	*replace empstat=3 if EMPTYPE_MAIN==2
	*replace empstat=4 if EMPTYPE_MAIN==3
	replace empstat=. if lstatus==2 | lstatus==3
	label var empstat "Employment status"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed"
	label values empstat lblempstat
*</_empstat_>


** SECTOR OF ACTIVITY: PUBLIC - PRIVATE
*<_njobs_>
	gen byte njobs=.
	label var njobs "Number of additional jobs"
*</_njobs_>


** SECTOR OF ACTIVITY: PUBLIC - PRIVATE
*<_ocusec_>
	gen byte ocusec=.
	label var ocusec "Sector of activity"
	la de lblocusec 1 "Public, state owned, government, army, NGO" 2 "Private"
	label values ocusec lblocusec
*</_ocusec_>


** REASONS NOT IN THE LABOR FORCE
*<_nlfreason_>
	gen byte nlfreason=.
	replace nlfreason=1 if r2_unm_whynt==1
	replace nlfreason=2 if r2_unm_whynt==2
	replace nlfreason=3 if r2_unm_whynt==3
	replace nlfreason=5 if r2_unm_whynt==4 | r2_unm_whynt==12
	replace nlfreason=4 if r2_unm_whynt==5
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
	recode r2_nagacnsic (1/5=1) (10/14=2) (15/36=3) (37/41=4) (45=5) (50/55=6) (60/64=7) (65/74=8) (75=9) (80/99=10) , gen(industry)
	replace industry=1 if mergeag==3
	replace industry=. if lstatus==2| lstatus==3
	label var industry "1 digit industry classification"
	la de lblindustry 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Comnunications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industry lblindustry
*</_industry_>


** OCCUPATION CLASSIFICATION
*<_occup_>
	gen occup=int(r2_occupcode/100)
	replace occup=. if r2_occupcode==997 | r2_occupcode==998 | r2_occupcode==999
	replace occup=10 if r2_occupcode==11
	replace occup=. if lstatus==2| lstatus==3
	label var occup "1 digit occupational classification"
	la de lbloccup 1 "Senior officials" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup lbloccup
*</_occup_>

	* Fix industry based on occupation
	replace industry=1 if occup==6 & lstatus==1
	
	
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
	gen whours=r2_7hrperwek
	label var whours "Hours of work in last week"
*</_whours_>


** WAGES
*<_wage_>
	*gen double wage=INCOME_MAIN_def if INCOME_MAIN_def>=0 
	gen wage=.
	replace wage=0 if empstat==2
	replace wage=. if lstatus==2  | lstatus==3
	label var wage "Last wage payment"
*</_wage_>


** WAGES TIME UNIT
*<_unitwage_>
	gen byte unitwage=.
	label var unitwage "Last wages time unit"
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
	gen spdef=c2_pindex
	la var spdef "Spatial deflator"
*</_spdef_>


** WELFARE
*<_welfare_>
	gen welfare=c2_ra_pcexp/12
	la var welfare "Welfare aggregate"
*</_welfare_>

*<_welfarenom_>
	gen welfarenom=c2_npcexp/12
	la var welfarenom "Welfare aggregate in nominal terms"
*</_welfarenom_>

*<_welfaredef_>
	gen welfaredef=c2_ra_pcexp/12
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
	gen welfarenat=c2_npcexp/12
	la var welfarenat "Welfare aggregate for national poverty"
*</_welfarenat_>

/*****************************************************************************************************
*                                                                                                    *
                                   NATIONAL POVERTY
*                                                                                                    *
*****************************************************************************************************/

	
** POVERTY LINE (NATIONAL)
*<_pline_nat_>
	gen pline_nat=c2_nompln/12
	label variable pline_nat "Poverty Line (National)"
*</_pline_nat_>


** HEADCOUNT RATIO (NATIONAL)
*<_poor_nat_>
	gen poor_nat=welfarenat<pline_nat if welfarenat!=.
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

	saveold "`output'\Data\Harmonized\NPL_2003_LSS-II_v01_M_v02_A_SARMD_IND.dta", replace version(12)
	saveold "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\__REGIONAL\Individual Files\NPL_2003_LSS-II_v01_M_v02_A_SARMD_IND.dta", replace version(12)
	


	log close









******************************  END OF DO-FILE  *****************************************************/
