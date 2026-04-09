/*****************************************************************************************************
******************************************************************************************************
**                                                                                                  **
**                                   SOUTH ASIA MICRO DATABASE                                      **
**                                                                                                  **
** COUNTRY	NEPAL
** COUNTRY ISO CODE	NPL
** YEAR	2010
** SURVEY NAME	Nepal Living Standards Survey – III 2010
** SURVEY AGENCY	Central Bureau of Statistics
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
	set mem 800m


** DIRECTORY
	local input "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\NPL\NPL_2010_LSS-III\NPL_2010_LSS-III_v01_M"
	local output "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\NPL\NPL_2010_LSS-III\NPL_2010_LSS-III_v01_M_v02_A_SARMD"
	local cpi "D:\SOUTH ASIA MICRO DATABASE\CPI"

** LOG FILE
	log using "`output'\Doc\Technical\NPL_2010_LSS.log",replace

/*****************************************************************************************************
*                                                                                                    *
                                   * ASSEMBLE DATABASE
*                                                                                                    *
*****************************************************************************************************/


** DATABASE ASSEMBLENT

* PREPARE DATASETS

	use "`input'\Data\Stata\S02.dta", clear
	sort xhpsu xhnum
	qui compress
	tempfile housing
	save `housing'

	use "`input'\Data\Stata\S01.dta", clear
	ren *idc idc
	sort xhpsu xhnum idc
	qui compress
	tempfile roster
	save `roster'
	
	use "`input'\Data\Stata\S07.dta", clear
	ren *idc idc
	sort xhpsu xhnum idc
	qui compress
	tempfile education
	save `education'

	use "`input'\Data\Stata\S11.dta", clear
	ren *idc idc
	sort xhpsu xhnum idc
	qui compress
	tempfile employment
	save `employment'
	
	use "`input'\Data\Stata\S12.dta", clear
	ren v12_01 idc
	ren v12_01_job idj
	sort xhpsu xhnum idc idj
	qui compress
	tempfile employment2
	save `employment2'
	
	use "`input'\Data\Stata\S10B.dta", clear
	ren v10_02 idc
	ren v10_02_job idj
	sort xhpsu xhnum idc idj
	gen njobs=idj-1
	
	merge 1:1 xhpsu xhnum idc idj using `employment2'
	drop _merge
	bys xhpsu xhnum idc: egen minj=min(idj)
	keep if idj==minj
	drop minj idj
	qui compress
	tempfile employment3
	save `employment3'
	
	use "`input'\Data\Stata\S10A.dta", clear
	ren *idc idc
	sort xhpsu xhnum idc
	qui compress
	tempfile employment4
	save `employment4'
	
	* MERGE DATASETS
	
	use `roster', clear
	
	merge m:1 xhpsu xhnum using `housing'
	drop _merge
	
	foreach x in education employment employment3 employment4{
	merge 1:1 xhpsu xhnum idc using ``x''
	drop _merge
	}
	
	sort xhpsu xhnum
	tempfile raw
	save `raw'
	
	use "`input'\Data\Stata\FINAL_PREF.dta", clear
	sort xhpsu xhnum
	merge 1:m xhpsu xhnum using `raw'
	
	order xhpsu xhnum idc
	sort xhpsu xhnum idc

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
	gen int year=2010
	label var year "Survey year"
*</_year_>


** SURVEY NAME 
*<_survey_>
	gen str survey="LSS-III"
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
	egen str idh= concat(xhpsu xhnum), punct(-)
	label var idh "Household id"
*</_idh_>


** INDIVIDUAL IDENTIFICATION NUMBER
*<_idp_>

	egen str idp= concat(idh idc), punct(-)
	label var idp "Individual id"
*</_idp_>


** HOUSEHOLD WEIGHTS
*<_wgt_>
	gen double wgt=wt_hh
	replace wgt=0 if wgt==.
	label var wgt "Household sampling weight"
*</_wgt_>


** STRATA
*<_strata_>

	gen strata=stratum
	label var strata "Strata"
*</_strata_>


** PSU
*<_psu_>
	gen psu=xhpsu
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
	gen urban=urbrur
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
	recode v02_11 2=0
	gen byte ownhouse=v02_11
	label var ownhouse "House ownership"
	la de lblownhouse 0 "No" 1 "Yes"
	label values ownhouse lblownhouse
*</_ownhouse_>
	
** WATER PUBLIC CONNECTION
*<_water_>

	recode v02_20 2=0
	gen byte water=v02_20
	label var water "Water main source"
	la de lblwater 0 "No" 1 "Yes"
	label values water lblwater
*</_water_>
	
** ELECTRICITY PUBLIC CONNECTION
*<_electricity_>


	gen byte electricity=.
	replace electricity=0 if v02_27==2
	replace electricity=0 if v02_27==3
	replace electricity=0 if v02_27==4
	replace electricity=0 if v02_27==5
	replace electricity=1 if v02_27==1
	label var electricity "Electricity main source"
	la de lblelectricity 0 "No" 1 "Yes"
	label values electricity lblelectricity
*</_electricity_>

** TOILET PUBLIC CONNECTION
*<_toilet_>

	gen byte toilet=.
	replace toilet=1 if v02_26==1
	replace toilet=0 if  v02_26==2 | v02_26==3 | v02_26==4 | v02_26==5
	label var toilet "Toilet facility"
	la de lbltoilet 0 "No" 1 "Yes"
	label values toilet lbltoilet
*</_toilet_>


** LAND PHONE
*<_landphone_>

	recode v02_31a 2=0
	gen byte landphone=v02_31a
	label var landphone "Phone availability"
	la de lbllandphone 0 "No" 1 "Yes"
	label values landphone lbllandphone
*</_landphone_>

	
** CEL PHONE
*<_cellphone_>

	recode v02_31b 2=0
	gen byte cellphone=v02_31b
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

	recode v02_31d 2=0

** INTERNET
	gen byte internet=v02_31d
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

	gen hsize=hhsize
	replace hsize=. if v01_10==2
	la var hsize "Household size"
*</_hsize_>

** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
*<_relationharm_>
	gen byte relationharm=v01_04
	recode relationharm (4 6 7 8 9 10 11=5) (5=4) (12 13 14=6)
	label var relationharm "Relationship to the head of household"
	la de lblrelationharm  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Non-relatives"
	label values relationharm  lblrelationharm
*</_relationharm_>

** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
*<_relationcs_>

	gen byte relationcs=v01_04
	la var relationcs "Relationship to the head of household country/region specific"
	la define lblrelationcs 1 "Head" 2 "Husband/Wife" 3 "Son/Daughter" 4 "Grandchild" 5 "Father/Mother" 6 "Brother/Sister" 7 "Nephew/Niece" 8 "Son/Daughter-in-law" 9 "Brother/Sister-in-law" 10 "Father/Mother-in-law" 11 "Other family relative" 12 "Servant/servant's relative" 13 "Tenant/tentant's relative" 14 "Other person not related"
	label values relationcs lblrelationcs
*</_relationcs_>


** GENDER
*<_male_>
	gen byte male=v01_02
	recode male (2=0)
	label var male "Sex of Household Member"
	la de lblmale 1 "Male" 0 "Female"
	label values male lblmale
*</_male_>


** AGE
*<_age_>
	gen byte age=v01_03
	label var age "Age of individual"
*</_age_>


** SOCIAL GROUP
*<_soc_>
	gen byte soc=v01_08
	replace soc=17 if soc>16 & soc!=.
	recode soc 6=5 5=6 8=7 9=8 7=9 15=14 14=15 16=15 17=15
	label var soc "Social group"
	la de lblsoc 1 "Chhetri" 2 "Brahman" 3 "Magar" 4 "Tharu" 5 "Newar" 6  "Tamang" 7 "Kami"  8 "Yadav" 9 "Muslim" 10  "Rai" 11 "Gurung" 12 "Damai" 13 "Limbu" 14 "Sarki" 15 "Other"
	label values soc lblsoc
*</_soc_>


** MARITAL STATUS
*<_marital_>
	gen byte marital=v01_06
	recode marital (4 3 2 = 1) (1=2) (6 7 =4) 
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
	gen byte ed_mod_age=3
	label var ed_mod_age "Education module application age"
*</_ed_mod_age_>

	gen byte everattend=.

** EVER ATTENDED SCHOOL
*<_everattend_>
	replace everattend=0 if v07_08==1
	replace everattend=1 if v07_08==2 | v07_08==3
	label var everattend "Ever attended school"
	la de lbleverattend 0 "No" 1 "Yes"
	label values everattend lbleverattend
*</_everattend_>



** CURRENTLY AT SCHOOL
*<_atschool_>
	gen byte atschool=.
	replace atschool=1 if v07_08==3
	replace atschool=0 if v07_08==2 | v07_08==1
	label var atschool "Attending school"
	la de lblatschool 0 "No" 1 "Yes"
	label values atschool  lblatschool
*</_atschool_>


** CAN READ AND WRITE
*<_literacy_>
	gen byte literacy=.
	replace  literacy=1 if  v07_02==1 & v07_03==1
	replace  literacy=0 if  v07_02==2 | v07_03==2
	label var literacy "Can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy
*</_literacy_>


** YEARS OF EDUCATION COMPLETED
*<_educy_>
	gen inter_edlevel = v07_18
	replace inter_edlevel = v07_11 if inter_edlevel == .
	replace inter_edlevel = 0 if v07_08 == 1 & inter_edlevel == .
	recode inter_edlevel (16 17 = 0)
	replace inter_edlevel = inter_edlevel -1 if v07_08 ==3
	replace inter_edlevel = 10 if inter_edlevel ==11 & v07_08 ==2  
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


	* Survey includes agricultural activities not considered 'employment' for the purpose of this data set. Hence, the sizable number of missing values for 'lstatus'.

** LABOR STATUS
*<_lstatus_>
	gen byte lstatus=.
	replace lstatus=1 if v10_03<996 & v10_06h>0
	replace lstatus=3 if (v10_06h==0 & (v11_02==2 | v11_03==2)) | v10_03==997 | (v10_03==998 & (v11_02==2 | v11_03==2))| (v10_03==996 & (v11_02==2 | v11_03==2))
	replace lstatus=2 if (v10_06h==0 & v10_01g==0) & lstatus!=3
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus
*</_lstatus_>

	* Survey doesn not provide sufficient info to construct all categories.

** EMPLOYMENT STATUS
*<_empstat_>
	gen byte empstat=.
/*
non paid employee and employer are not available
*/
	replace empstat=1 if v10_07==1 | v10_07==2
	replace empstat=4 if v10_07==3 | v10_07==4
	replace empstat=. if lstatus!=1
	label var empstat "Employment status"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed"
	label values empstat lblempstat
*</_empstat_>


** SECTOR OF ACTIVITY: PUBLIC - PRIVATE
*<_njobs_>
	replace njobs=. if lstatus!=1
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
	replace nlfreason=1 if v11_04==1
	replace nlfreason=2 if v11_04==2
	replace nlfreason=3 if v11_04==3
	replace nlfreason=4 if v11_04==4
	replace nlfreason=5 if v11_04==5 |  v11_04==6 |  v11_04==7 |  v11_04==8  |  v11_04==9 |  v11_04==10
	replace nlfreason=. if lstatus!=3
	replace nlfreason=. if age<5
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
	gen byte industry=v12_02
	recode industry(1 2 5 =1) (10 11 12 13 14=2)
	forval i= 15/37 {
	recode industry (`i'=3)
	}
	recode industry (40 41 90 =4)(45=5)(50 51 52 55 =6)
	recode industry (60 61 62 63 64 =7)
	recode industry (65 66 67 70 71 72 73 74=8) (75 =9)
	recode industry ( 80 85 90 91 92 93 95 99=10)
	replace industry=. if lstatus!=1
	label var industry "1 digit industry classification"
	la de lblindustry 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Communications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industry lblindustry
*</_industry_>


** OCCUPATION CLASSIFICATION
*<_occup_>
	gen byte occup=.
	replace occup=1 if v10_03>=111 & v10_03<=131
	replace occup=2 if v10_03>=211 & v10_03<=246
	replace occup=3 if v10_03>=311 & v10_03<=348
	replace occup=4 if v10_03>=411 & v10_03<=422
	replace occup=5 if v10_03>=511 & v10_03<=523
	replace occup=6 if v10_03>=611 & v10_03<=621
	replace occup=7 if v10_03>=711 & v10_03<=744
	replace occup=8 if v10_03>=811 & v10_03<=833
	replace occup=9 if v10_03>=911 & v10_03<=933
	replace occup=10 if v10_03==11
	replace occup=99 if v10_03==999
	replace occup=. if lstatus!=1
	label var occup "1 digit occupational classification"
	la de lbloccup 1 "Senior officials" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup lbloccup
*</_occup_>


** FIRM SIZE
*<_firmsize_l_>
	gen byte firmsize_l=.
	replace firmsize_l= 1 if v12_20==1
	replace firmsize_l= 2 if v12_20==2
	replace firmsize_l=10 if v12_20==3
	replace firmsize_l=. if lstatus!=1
	label var firmsize_l "Firm size (lower bracket)"
*</_firmsize_l_>

*<_firmsize_u_>

	gen byte firmsize_u=.
	replace firmsize_u= 1 if v12_20==1
	replace firmsize_u= 9 if v12_20==2
	replace firmsize_u=. if v12_20==3
	replace firmsize_u=. if lstatus!=1
	label var firmsize_u "Firm size (upper bracket)"

*</_firmsize_u_>


** HOURS WORKED LAST WEEK
*<_whours_>
	gen whours=v10_06h
	replace whours=. if lstatus!=1
	label var whours "Hours of work in last week"
*</_whours_>


** WAGES
*<_wage_>
	gen double wage=.
	replace wage= v12_15a if v12_15a!=.
	replace wage=v12_08 if v12_08!=.
	replace wage=v12_21 if v12_21!=.
	replace wage=v12_04 if  v12_04!=.
	replace wage=0 if empstat==2
	replace wage=. if lstatus!=1
	label var wage "Last wage payment"
*</_wage_>


** WAGES TIME UNIT
*<_unitwage_>
	gen byte unitwage=.
	replace unitwage=1 if v12_04!=.
	replace unitwage=5 if v12_15a!=.
	replace unitwage=8 if v12_08!=.
	replace unitwage=8 if v12_21!=.
	replace  unitwage=. if lstatus!=1
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
	gen spdef=pindex
	la var spdef "Spatial deflator"
*</_spdef_>


** WELFARE
*<_welfare_>
	gen welfare=rpcexp/12
	replace welfare=. if v01_10==2
	la var welfare "Welfare aggregate"
*</_welfare_>

*<_welfarenom_>
	gen welfarenom=totcons_pc_7/12
	replace welfarenom=. if v01_10==2
	la var welfarenom "Welfare aggregate in nominal terms"
*</_welfarenom_>

*<_welfaredef_>
	gen welfaredef=welfare
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
	gen welfareother=totcons_pc_30/12
	replace welfareother=. if v01_10==2
	la var welfareother "Welfare Aggregate if different welfare type is used from welfare, welfarenom, welfaredef"
*</_welfareother_>

*<_welfareothertype_>
	gen welfareothertype="CON"
	la var welfareothertype "Type of welfare measure (income, consumption or expenditure) for welfareother"
*</_welfareothertype_>

*<_welfarenat_>
	gen welfarenat=rpcexp/12
	replace welfarenat=. if v01_10==2
	la var welfarenat "Welfare aggregate for national poverty"
*</_welfarenat_>	
	

/*****************************************************************************************************
*                                                                                                    *
                                   NATIONAL POVERTY
*                                                                                                    *
*****************************************************************************************************/


** POVERTY LINE (NATIONAL)
*<_pline_nat_>
	gen pline_nat=pline_7/12
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
	merge m:1 countrycode year urb using "`cpi'\cpi_ppp_sarmd_weighted.dta", ///
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

	saveold "`output'\Data\Harmonized\NPL_2010_LSS-III_v01_M_v02_A_SARMD_IND.dta", replace version(12)
	saveold "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\__REGIONAL\Individual Files\NPL_2010_LSS-III_v01_M_v02_A_SARMD_IND.dta", replace version(12)
	

	log close




******************************  END OF DO-FILE  *****************************************************/
