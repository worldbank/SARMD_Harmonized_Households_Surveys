/*****************************************************************************************************
******************************************************************************************************
**                                                                                                  **
**                                   SOUTH ASIA MICRO DATABASE                                      **
**                                                                                                  **
** COUNTRY			NEPAL
** COUNTRY ISO CODE	NPL
** YEAR				2003
** SURVEY NAME		NEPAL LIVING STANDARDS SURVEY III 2010
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
	local input "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\NPL\NPL_2010_LSS-III\NPL_2010_LSS-III_v01_M"
	local output "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\NPL\NPL_2010_LSS-III\NPL_2010_LSS-III_v01_M_v01_A_SARMD"

** LOG FILE
	log using "`input'\Doc\NPL_2010_LSS-III.log",replace

/*****************************************************************************************************
*                                                                                                    *
                                   * ASSEMBLE DATABASE
*                                                                                                    *
*****************************************************************************************************/

** DATABASE ASSEMBLENT

	use "`input'\Data\Stata\nlss_train_2010.dta"
	tempfile aux
	destring hhid, g(HID)
	keep HID pline_com hhexp_pc_com
	save `aux'

	use "`input'\Data\Stata\NPL_NLSS_2010_orig.dta"
	ren rpcexp rpcexp_
	merge m:1 HID using `aux'
	tab _merge
	drop _merge
	tostring HID, replace
	save `aux', replace

	use "`input'\Data\Stata\SAS_NPL_2010_11_NLSS3_Silvia.dta"
	gen HID=xhpsu*100+xhnum
	tostring HID, replace
	merge 1:m HID using `aux'
	tab _merge
	drop _merge



/*****************************************************************************************************
*                                                                                                    *
                                   * STANDARD SURVEY MODULE
*                                                                                                    *
*****************************************************************************************************/

	
** COUNTRY
	gen str4 countrycode="NPL"
	la var countrycode "Country name"


** YEAR
	gen year=2010
	label var year "Survey year"


** INTERVIEW YEAR
	gen byte int_year=.
	label var int_year "Year of the interview"
	
	
** INTERVIEW MONTH
	gen int_month=.
	la de lblint_month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
	label value int_month lblint_month
	label var int_month "Month of the interview"

	
** HOUSEHOLD IDENTIFICATION NUMBER
	gen idh= HID
	label var idh "Household id"


** INDIVIDUAL IDENTIFICATION NUMBER
	gen a="-"
	egen byte idp= concat(idh a INDID)
	tostring idh idp, replace
	label var idp "Individual id"


** HOUSEHOLD WEIGHTS
	gen double wgt=wt_hh
	label var wgt "Household sampling weight"


** STRATA
	gen strata=stratum
	label var strata "Strata"


** PSU
	gen psu=xhpsu
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
	gen urban=urbrural
	recode urban (2=0)
	label var urban "Urban/Rural"
	la de lblurban 1 "Urban" 0 "Rural"
	label values urban lblurban


** REGIONAL AREA 1 DIGIT ADMN LEVEL
	gen byte subnatid1=region
	la de lblsubnatid1 1 "Eastern" 2 "Centeral" 3 "Western" 4 "Mid-west" 5 "Far-west"
	label var subnatid1 "Region at 1 digit (ADMN1)"
	label values subnatid1 lblsubnatid1


** REGIONAL AREA 2 DIGIT ADMN LEVEL
	gen byte subnatid2=district
	la de lblsubnatid2 1 "Taplejung" 2 "Panchthar" 3 "Ilam" 4 "Jhapa" 5 "Morang" 6 "Sunsari" 7 "Dhankuta" 8 "Tehrathum" 9 "Sankhuwasabha" 10 "Bhojpur" 11 "Solukhumbu" 12 "Okhaldhunga" 13 "Khotang" 14 "Udayapur" 15 "Saptari" 16 "Siraha" 17 "Dhanusha" 18 "Mahottari" 19 "Sarlahi" 20 "Sindhuli" 21 "Ramechhap" 22 "Dolakha" 23 "Sindhupalchok" 24 "Kavrepalanchok" 25 "Lalitpur" 26 "Bhaktapur" 27 "Kathmandu" 28 "Nuwakot" 29 "Rasuwa" 30 "Dhading" 31 "Makwanpur" 32 "Rautahat"  33 "Bara" 34 "Parsa" 35 "Chitwan" 36 "Gorkha" 37 "Lamjung" 38 "Tanahun" 39 "Syangja" 40 "Kaski" 41 "Manang" 42 "Mustang" 43 "Myagdi"44 "Parbat" 45 "Baglung" 46 "Gulmi" 47 "Palpa" 48 "Nawalparasi" 49 "Rupandehi" 50 "Kapilbastu" 51 "Arghakhanchi" 52 "Pyuthan" 53 "Rolpa" 54 "Rukum" 55 "Salyan" 56 "Dang" 57 "Banke" 58 "Bardiya" 59 "Surkhet" 60 "Dailekh" 61 "Jajarkot" 62 "Dolpa" 63 "Jumla" 64 "Kalikot" 65 "Mugu" 66 "Humla" 67 "Bajura" 68 "Bajhang" 69 "Achham"  70 "Doti" 71 "Kailali" 72 "Kanchanpur" 73 "Dandheldhura" 74 "Baitadi" 75 "Darchula"
	label var subnatid2 "Region at 2 digit (ADMN2)"
	label values subnatid2 lblsubnatid2


** REGIONAL AREA 3 DIGIT ADMN LEVEL
	gen byte subnatid3=.
	label var subnatid3 "Region at 3 digit (ADMN3)"
	label values subnatid3 lblsubnatid3


** HOUSE OWNERSHIP
	recode v02_11 2=0
	gen byte ownhouse=v02_11
	label var ownhouse "House ownership"
	la de lblownhouse 0 "No" 1 "Yes"
	label values ownhouse lblownhouse

	
** WATER PUBLIC CONNECTION
	recode v02_20 2=0
	gen byte water=v02_20
	label var water "Water main source"
	la de lblwater 0 "No" 1 "Yes"
	label values water lblwater

** ELECTRICITY PUBLIC CONNECTION
	gen byte electricity=.
	replace electricity=0 if v02_27==2
	replace electricity=0 if v02_27==3
	replace electricity=0 if v02_27==4
	replace electricity=0 if v02_27==5
	replace electricity=1 if v02_27==1
	label var electricity "Electricity main source"
	la de lblelectricity 0 "No" 1 "Yes"
	label values electricity lblelectricity



** TOILET PUBLIC CONNECTION
	gen byte toilet=.
	replace toilet=1 if v02_26==1
	replace toilet=0 if  v02_26==2 | v02_26==3 | v02_26==4 | v02_26==5
	label var toilet "Toilet facility"
	la de lbltoilet 0 "No" 1 "Yes"
	label values toilet lbltoilet


** LAND PHONE
	recode v02_31a 2=0
	gen byte landphone=v02_31a
	label var landphone "Phone availability"
	la de lbllandphone 0 "No" 1 "Yes"
	label values landphone lbllandphone

** CEL PHONE
	 
	recode v02_31b 2=0
	gen byte cellphone=v02_31b
	label var cellphone "Cell phone"
	la de lblcellphone 0 "No" 1 "Yes"
	label values cellphone lblcellphone


** COMPUTER
	gen byte computer=.
	label var computer "Computer availability"
	la de lblcomputer 0 "No" 1 "Yes"
	label values computer lblcomputer

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
	gen T_T=1 if idp!= " "
	egen hsize=count(T_T), by(idh)
	label var hsize "Household size"

	
** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
	gen byte relationharm=v01_04
	recode relationharm (4 6 7 8 9 10 11=5) (5=4) (12 13 14=6)
	label var relationharm "Relationship to the head of household"
	la de lblrelationharm  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Non-relatives"
	label values relationharm  lblrelationharm

	gen byte relationcs=v01_04
	la var relationcs "Relationship to the head of household country/region specific"
	la define lblrelationcs 1 "Head" 2 "Husband/Wife" 3 "Son/Daughter" 4 "Grandchild" 5 "Father/Mother" 6 "Brother/Sister" 7 "Nephew/Niece" 8 "Son/Daughter-in-law" 9 "Brother/Sister-in-law" 10 "Father/Mother-in-law" 11 "Other family relative" 12 "Servant/servant's relative" 13 "Tenant/tentant's relative" 14 "Other person not related"
	label values relationcs lblrelationcs


** GENDER
	gen byte male=v01_02
	recode male (2=0)
	label var male "Sex of Household Member"
	la de lblmale 1 "Male" 0 "Female"
	label values male lblmale


** AGE
	gen byte age=v01_03
	label var age "Individual age"


** SOCIAL GROUP
	gen byte soc=v01_08
	replace soc=17 if soc>16 & soc!=.
	recode soc 6=5 5=6 8=7 9=8 7=9 15=14 14=15 16=15 17=15
	label var soc "Social group"
	la de lblsoc 1 "Chhetri" 2 "Brahman" 3 "Magar" 4 "Tharu" 5 "Newar" 6  "Tamang" 7 "Kami"  8 "Yadav" 9 "Muslim" 10  "Rai" 11 "Gurung" 12 "Damai" 13 "Limbu" 14 "Sarki" 15 "Other"
	label values soc lblsoc


** MARITAL STATUS
	gen byte marital=v01_06
	recode marital (4 3 2 = 1) (1=2) (6 7 =4) 
	label var marital "Marital status"
	la de lblmarital 1 "Married" 2 "Never Married" 3 "Living Together" 4 "Divorced/separated" 5 "Widowed"
	label values marital lblmarital


/*****************************************************************************************************
*                                                                                                    *
                                   EDUCATION MODULE
*                                                                                                    *
*****************************************************************************************************/


** EDUCATION MODULE AGE
	gen byte ed_mod_age=3
	label var ed_mod_age "Education module application age"


** EVER ATTENDED SCHOOL
	gen byte everattend=.
	replace everattend=0 if v07_08==1
	replace everattend=1 if v07_08==2 | v07_08==3
	label var everattend "Ever attended school"
	la de lbleverattend 0 "No" 1 "Yes"
	label values everattend lbleverattend


** CURRENTLY AT SCHOOL
	gen byte atschool=.
	replace atschool=1 if v07_08==3
	replace atschool=0 if v07_08==2 | v07_08==1
	label var atschool "Attending school"
	la de lblatschool 0 "No" 1 "Yes"
	label values atschool  lblatschool


** CAN READ AND WRITE
	gen byte literacy=.
	replace  literacy=1 if  v07_02==1 & v07_03==1
	replace  literacy=0 if  v07_02==2 | v07_03==2
	label var literacy "Can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy


** YEARS OF EDUCATION COMPLETED
	gen inter_edlevel = v07_18
	replace inter_edlevel = v07_11 if inter_edlevel == .
	replace inter_edlevel = 0 if v07_08 == 1 & inter_edlevel == .
	recode inter_edlevel (16 17 = 0)
	replace inter_edlevel = inter_edlevel -1 if v07_08 ==3
	replace inter_edlevel = 10 if inter_edlevel ==11 & v07_08 ==2  
	gen byte educy= inter_edlevel
	recode educy (-1 = 0) (13 = 15) (14 15 = 17)
	label var educy "Years of education"


** EDUCATIONAL LEVEL 7 CATEGORIES
	recode inter_edlevel  (1/4 = 2) (5/7 = 3) (8/11 = 4) (12=5) (13/15 = 7) (-1 0 = 1), gen(educat7)
	label define lbleducat7 1 "No education" 2 "Primary incomplete" 3 "Primary complete" ///
	4 "Secondary incomplete" 5 "Secondary complete" 6 "Higher than secondary but not university" /// 
	7 "University incomplete or complete" 8 "Other" 9 "Not classified"
	label values educat7 lbleducat7
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
	gen byte educat4=.
	replace educat4=1 if educat7==1 
	replace educat4=2 if educat7==2 | educat7==3
	replace educat4=3 if educat7==4 | educat7==5
	replace educat4=4 if educat7==6 | educat7==7
	label var educat4 "Level of education 4 categories"
	label define lbleducat4 1 "No education" 2 "Primary (complete or incomplete)" ///
	3 "Secondary (complete or incomplete)" 4 "Tertiary (complete or incomplete)"
	label values educat4 lbleducat4


/*****************************************************************************************************
*                                                                                                    *
                                   LABOR MODULE
*                                                                                                    *
*****************************************************************************************************/


** LABOR MODULE AGE
	gen byte lb_mod_age=5
	label var lb_mod_age "Labor module application age"

	* Survey includes agricultural activities not considered 'employment' for the purpose of this data set. Hence, the sizable number of missing values for 'lstatus'.

** LABOR STATUS
	gen byte lstatus=.
	replace lstatus=1 if v10_03<996 & v10_06h>0
	replace lstatus=3 if (v10_06h==0 & (v11_02==2 | v11_03==2)) | v10_03==997 | (v10_03==998 & (v11_02==2 | v11_03==2))| (v10_03==996 & (v11_02==2 | v11_03==2))
	replace lstatus=2 if (v10_06h==0 & v10_01g==0) & lstatus!=3
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus

	* Survey doesn not provide sufficient info to construct all categories.

** EMPLOYMENT STATUS
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


** NUMBER OF ADDITIONAL JOBS
	gen byte njobs=tot_num_job-1
	replace njobs=. if lstatus!=1
	label var njobs "Number of additional jobs"


** SECTOR OF ACTIVITY: PUBLIC - PRIVATE
	gen byte ocusec=.
	label var ocusec "Sector of activity"
	la de lblocusec 1 "Public, state owned, government, army, NGO" 2 "Private"
	label values ocusec lblocusec


** REASONS NOT IN THE LABOR FORCE
	gen byte nlfreason=.
	replace nlfreason=1 if v11_04==1
	replace nlfreason=2 if v11_04==2
	replace nlfreason=3 if v11_04==3
	replace nlfreason=4 if v11_04==4
	replace nlfreason=5 if v11_04==5 |  v11_04==6 |  v11_04==7 |  v11_04==8  |  v11_04==9 |  v11_04==10
	replace nlfreason=. if lstatus!=3
	replace nlfreason=. if age<5
	label var nlfreason "Reason not in the labor force"
	la de lblnlfreason 1 "Student" 2 "Housewife" 3 "Retired" 4 "Disabled" 5 "Other"
	label values nlfreason lblnlfreason


** UNEMPLOYMENT DURATION: MONTHS LOOKING FOR A JOB
	gen byte unempldur_l=.
	label var unempldur_l "Unemployment duration (months) lower bracket"

	gen byte unempldur_u=.
	label var unempldur_u "Unemployment duration (months) upper bracket"


** INDUSTRY CLASSIFICATION
	gen byte industry=v12_02
	recode industry(2 5 =1) (10 11 12 13 14=2)
	forval i= 15/37 {
	recode industry (`i'=3)
	}
	recode industry (40 41 90 =4)(45=5)(50 51 52 55 =6)
	recode industry (60 61 62 63 64 =7)
	recode industry (65 66 67 70 71 72 73 74=8) (75 =9)
	recode industry ( 80 85 90 91 92 93 95 99=10)
	replace industry=. if lstatus!=1
	label var industry "1 digit industry classification"
	la de lblindustry 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Comnunications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industry lblindustry


** OCCUPATION CLASSIFICATION
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



** FIRM SIZE
	gen byte firmsize_l=.
	replace firmsize_l= 1 if v12_20==1
	replace firmsize_l= 2 if v12_20==2
	replace firmsize_l=10 if v12_20==3
	replace firmsize_l=. if lstatus!=1
	label var firmsize_l "Firm size (lower bracket)"

	gen byte firmsize_u=.
	replace firmsize_u= 1 if v12_20==1
	replace firmsize_u= 9 if v12_20==2
	replace firmsize_u=. if v12_20==3
	replace firmsize_u=. if lstatus!=1
	label var firmsize_u "Firm size (upper bracket)"


** HOURS WORKED LAST WEEK
	gen whours=v10_06h
	replace whours=. if lstatus!=1
	label var whours "Hours of work in last week"


** WAGES
	gen double wage=.
	replace wage= v12_15a if v12_15a!=.
	replace wage=v12_08 if v12_08!=.
	replace wage=v12_21 if v12_21!=.
	replace wage=v12_04 if  v12_04!=.
	replace wage=0 if empstat==2
	replace wage=. if lstatus!=1
	label var wage "Last wage payment"


** WAGES TIME UNIT
	gen byte unitwage=.
	replace unitwage=1 if v12_04!=.
	replace unitwage=5 if v12_15a!=.
	replace unitwage=8 if v12_08!=.
	replace unitwage=8 if v12_21!=.
	replace  unitwage=. if lstatus!=1
	label var unitwage "Last wages time unit"
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
                                   WELFARE MODULE
*                                                                                                    *
*****************************************************************************************************/


** SPATIAL DEFLATOR
	gen spdef=pindex
	la var spdef "Spatial deflator"

** WELFARE
	gen welfare=pcexp*(1/12)
	la var welfare "Welfare aggregate"

	gen welfarenom=totcons_pc_7/12
	la var welfarenom "Welfare aggregate in nominal terms"

	gen welfaredef=rpcexp/12
	la var welfaredef "Welfare aggregate spatially deflated"

	gen welfaretype="CONS"
	la var welfaretype "Type of welfare measure (income, consumption or expenditure) for welfare, welfarenom, welfaredef"

	gen welfareother=(hhexp_pc_com/12)*(.9295744/.371117)
	la var welfareother "Welfare Aggregate if different welfare type is used from welfare, welfarenom, welfaredef"

	gen welfareothertype="CON"
	la var welfareothertype "Type of welfare measure (income, consumption or expenditure) for welfareother"

	
/*****************************************************************************************************
*                                                                                                    *
                                   NATIONAL POVERTY
*                                                                                                    *
*****************************************************************************************************/



** POVERTY LINE (NATIONAL)
	gen pline_nat=pline_7/12
	label var pline_nat "National Poverty Line"

	
** HEADCOUNT RATIO (NATIONAL)
	gen poor_nat=welfaredef<pline_nat if welfare!=.
	la var poor_nat "People below Poverty Line (National)"
	la define poor_nat 0 "Not-Poor" 1 "Poor"
	la values poor_nat poor_nat

	
/* POVERTY COMPARABLE WITH OLDER SURVEYS

**NATIONAL POVERTY LINE (Comparable)
Consumption aggregates measure changed from 30 days to 7 days basis, so they are not strictly comparable. That's why comparable variable are created (welfareother, pline_com, poor_com)
	
	ren pline_com pline_com_
	gen pline_com=(pline_com_/12)*(.9295744/.371117)
	label var pline_com "National Poverty Line (comparable)"



**POOR - National (Comparable)
Consumption aggregates measure changed from 30 days to 7 days basis, so they are not strictly comparable. That's why comparable variable are created (welfareother, pline_com, poor_com)

	gen poor_com=1 if welfareother<pline_com
	replace poor_com=0 if welfareother>=pline_com & welfareother!=.
	label var poor_com "People below pline_com"
	la define lblpoor_com 0 "Not-Poor" 1 "Poor"
	la values poor_com lblpoor_com

*/


/*****************************************************************************************************
*                                                                                                    *
                                   INTERNATIONAL POVERTY
*                                                                                                    *
*****************************************************************************************************/


	local year=2011
	
** USE SARMD CPI AND PPP
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

	keep countrycode year idh idp wgt strata psu vermast veralt urban int_month int_year ///
	     subnatid1 subnatid2 subnatid3 ownhouse water electricity toilet landphone cellphone ///
	     computer internet hsize relationharm relationcs male age soc marital ed_mod_age everattend ///
	     atschool electricity literacy educy educat4 educat5 educat7 lb_mod_age lstatus empstat njobs ///
	     ocusec nlfreason unempldur_l unempldur_u industry occup firmsize_l firmsize_u whours wage ///
		 unitwage contract healthins socialsec union pline_nat pline_int poor_nat poor_int spdef cpi ppp ///
		 cpiperiod welfare welfarenom welfaredef welfareother welfaretype welfareothertype

** ORDER VARIABLES

	order countrycode year idh idp wgt strata psu vermast veralt urban int_month int_year ///
	      subnatid1 subnatid2 subnatid3 ownhouse water electricity toilet landphone cellphone ///
	      computer internet hsize relationharm relationcs male age soc marital ed_mod_age everattend ///
	      atschool electricity literacy educy educat4 educat5 educat7 lb_mod_age lstatus empstat njobs ///
	      ocusec nlfreason unempldur_l unempldur_u industry occup firmsize_l firmsize_u whours wage ///
		 unitwage contract healthins socialsec union pline_nat pline_int poor_nat poor_int spdef cpi ppp ///
		 cpiperiod welfare welfarenom welfaredef welfareother welfaretype welfareothertype
	
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

	saveold "`output'\Data\Harmonized\NPL_2010_LSS-III_v01_M_v01_A_SARMD_IND.dta", replace version(13)
	saveold "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\__REGIONAL\Individual Files\NPL_2010_LSS-III_v01_M_v01_A_SARMD_IND.dta", replace version(13)
	
	
	log close




******************************  END OF DO-FILE  *****************************************************/
