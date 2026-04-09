/*****************************************************************************************************
******************************************************************************************************
**                                                                                                  **
**                                   SOUTH ASIA MICRO DATABASE                                      **
**                                                                                                  **
** COUNTRY			NEPAL
** COUNTRY ISO CODE	NPL
** YEAR				1995
** SURVEY NAME		NEPAL LIVING STANDARDS SURVEY 1995
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
	clear
	cap log close
	set more off
	set mem 500m

** DIRECTORY
	local input "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\NPL\NPL_1995_LSS-I\NPL_1995_LSS-I_v01_M"
	local output "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\NPL\NPL_1995_LSS-I\NPL_1995_LSS-I_v01_M_v01_A_SARMD"

** LOG FILE
	log using "`input'\Doc\Technical\NPL_1995_LSS.log",replace

/*****************************************************************************************************
*                                                                                                    *
                                   * DATABASE ASSEMBLENT
*                                                                                                    *
*****************************************************************************************************/


** DATABASE ASSEMBLENT
	*use "`input'\Original\_new files\DataProc\NPL_NLSS_1995_1996.dta",clear
	*destring WWW HH, replace
	*merge m:1 WWWHH using "`input'\Original\_new files\Original Data\c1_nlssdata.dta"

	use "`input'\Data\Stata\NPL_NLSS_1995_1996.dta",clear
	drop   weight WWW district urbrural belt region stratum group c1_totlpop phase team DEMOGRAPHICS c1_hhsize c1_nkids06 c1_nkids715 c1_nelderly c1_namen c1_nawomen c1_skids06 c1_skids715 c1_samen c1_sawomen c1_selderly c1_nkids06T c1_hhsizeT c1_depratio1 c1_depratio2 c1_depratio3 HOUSEHOLD_HEAD r1_IDC c1_ethnic_hhead c1_educ_hhead c1_type_hhead c1_occup_hhead PRICE_INDEXES c1_fpi_ret_95 c1_fpi_ret_03 c1_nfpi_ret_95 c1_nfpi_ret_03 c1_pi_ret_95 c1_pi_ret_03 c1_fpindex c1_nfpindex c1_ra_pindex c1_pi_nepal95 c1_pi_nepal03 c1_av03_to_av95 POVERTY_LINES c1_nomfpln c1_nomnfpln c1_nompln c1_95nompln c1_95nomfpln c1_95nomnfpln EXPENDITURE c1_totcons c1_hhrent c1_food c1_nfood c1_tobacco c1_fuel c1_educatn c1_consdur c1_garbage c1_electric c1_telephon c1_totnfood c1_hproduct c1_inkind c1_nfooditm c1_npcexp c1_npcfexp c1_npcnfexp c1_npcrentexp c1_sfood c1_stobacco c1_snfood c1_seducatn c1_sconsdur c1_shhrent c1_stelephon c1_rexp c1_rfexp c1_rrentexp c1_rpcexp c1_rpcfexp c1_rpcnfexp c1_rpcrentexp WELFARE_INDICATORS c1_nwdecile c1_nwquint c1_rdecile c1_rquint c1_rurexp_quint c1_poor c1_inc_poor DURABLES c1_durbl_yn501 c1_durbl_yn502 c1_durbl_yn503 c1_durbl_yn504 c1_durbl_yn505 c1_durbl_yn506 c1_durbl_yn507 c1_durbl_yn508 c1_durbl_yn509 c1_durbl_yn510 c1_durbl_yn511 c1_durbl_yn512 c1_durbl_yn513 c1_durbl_yn514 c1_durbl_yn515 c1_durbl_yn516 ADEQUACY r1_subpres_idc r1_subpfood r1_subphous r1_subpclth r1_subpheal r1_subpschl r1_subpincm r1_enohfood INCOME c1_hhtotinc c1_npctotinc c1_r95pctotinc c1_r95pcfarminc c1_r95pcwageinc c1_r95pcremitinc c1_r95pcentrpinc c1_r95pcpropinc c1_r95pchousinc c1_r95pcothinc c1_farminc_shr c1_wageinc_shr c1_agwageinc_shr c1_nagwageinc_shr c1_entrpinc_shr c1_propinc_shr c1_remitinc_shr c1_housinc_shr c1_othinc_shr c1_nofarminc c1_nowageinc c1_noagwageinc c1_nonagwageinc c1_noentrpinc c1_nopropinc c1_noremitinc c1_nohousinc c1_noothinc c1_rpcinc_quintile c1_rpcinc_quartile OUTLIERS incoutlier0 incoutlier1 incoutlier2 expoutlier0 constant REAL_ALLNEPAL size sfexp fexp basefexp_95 basefexp_03 c1_ra_pcexp c1_ra_pcinc c1_ra95_pcexp c1_ra95_pcinc c1_ra95pc_totinc c1_ra95pc_farminc c1_ra95pc_wageinc c1_ra95pc_remitinc c1_ra95pc_entrpinc c1_ra95pc_propinc c1_ra95pc_housinc c1_ra95pc_othinc r1_sex r1_age nworking nworkmen nworkwom ndep nindep
	destring WWW HH, replace
	merge m:1 WWWHH using "`input'\Data\Stata\SAS_NPL_1995_96_NLSS1.dta

	
/*****************************************************************************************************
*                                                                                                    *
                                   * STANDARD SURVEY MODULE
*                                                                                                    *
*****************************************************************************************************/


** COUNTRY
	gen str4 countrycode="NPL"
	la var countrycode "Country name"


** YEAR
	gen year=1995
	label var year "Survey year"


** INTERVIEW YEAR
	gen byte int_year=.
	label var int_year "Year of the interview"
	
	
** INTERVIEW MONTH
	* S00DINTD phase
	gen int_month=.
	la de lblint_month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
	label value int_month lblint_month
	label var int_month "Month of the interview"
	

** HOUSEHOLD IDENTIFICATION NUMBER
	gen idh=WWWHH
	label var idh "Household ID number"
	sort idh
	egen INDIDC=seq() 
	recode INDID (.=555)
	sort INDID
	replace INDID=INDIDC if INDID==555
	tostring idh, replace


** INDIVIDUAL IDENTIFICATION NUMBER
	gen a="-"
	egen idp=concat(idh a INDID), format(%15.0f)
	tostring idp, replace
	label var idp "Individual id"


** HOUSEHOLD WEIGHTS
	gen wgt=weight
	label var wgt "Household weights"


** STRATA
	gen strata=STRATA
	label var strata "Survey strata"
	

** PSU
	gen psu=real(PSU)
	label var psu "Primary sampling unit"


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
	gen urban=URBAN
	egen p=mean(urban), by(idh)
	replace urban=p if urban==.
	label var urban "Urban/Rural"
	la de lblurban 1 "Urban" 0 "Rural"
	label values urban lblurban
	drop p
	
	
** REGIONAL AREA 1 DIGIT ADMN LEVEL
	gen subnatid1=region
	egen rrr=mean(subnatid1), by(idh)
	replace subnatid1=rrr if subnatid1==.
	label var subnatid1 "Region at 1 digit (ADMN1)"
	label define lblsubnatid1 1 "Eastern" 2 "Central" 3 "Western" 4 "Midwest" 5 "Farwest"
	label values subnatid1 lblsubnatid1


** REGIONAL AREA 2 DIGIT ADMN LEVEL
	gen byte subnatid2=district
	egen rr=mean(subnatid2), by(idh)
	replace subnatid2=rr if subnatid2==.
	la de lblsubnatid2 1 "Taplejung" 2 "Panchthar" 3 "Ilam" 4 "Jhapa" 5 "Morang" 6 "Sunsari" 7 "Dhankuta" 8 "Tehrathum" 9 "Sankhuwasabha" 10 "Bhojpur" 11 "Solukhumbu" 12 "Okhaldhunga" 13 "Khotang" 14 "Udayapur" 15 "Saptari" 16 "Siraha" 17 "Dhanusha" 18 "Mahottari" 19 "Sarlahi" 20 "Sindhuli" 21 "Ramechhap" 22 "Dolakha" 23 "Sindhupalchok" 24 "Kavrepalanchok" 25 "Lalitpur" 26 "Bhaktapur" 27 "Kathmandu" 28 "Nuwakot" 29 "Rasuwa" 30 "Dhading" 31 "Makwanpur" 32 "Rautahat"  33 "Bara" 34 "Parsa" 35 "Chitwan" 36 "Gorkha" 37 "Lamjung" 38 "Tanahun" 39 "Syangja" 40 "Kaski" 41 "Manang" 42 "Mustang" 43 "Myagdi"44 "Parbat" 45 "Baglung" 46 "Gulmi" 47 "Palpa" 48 "Nawalparasi" 49 "Rupandehi" 50 "Kapilbastu" 51 "Arghakhanchi" 52 "Pyuthan" 53 "Rolpa" 54 "Rukum" 55 "Salyan" 56 "Dang" 57 "Banke" 58 "Bardiya" 59 "Surkhet" 60 "Dailekh" 61 "Jajarkot" 62 "Dolpa" 63 "Jumla" 64 "Kalikot" 65 "Mugu" 66 "Humla" 67 "Bajura" 68 "Bajhang" 69 "Achham"  70 "Doti" 71 "Kailali" 72 "Kanchanpur" 73 "Dandheldhura" 74 "Baitadi" 75 "Darchula"
	label var subnatid2 "Region at 2 digit (ADMN2)"
	label values subnatid2 lblsubnatid2


** REGIONAL AREA 3 DIGIT ADMN LEVEL
	gen byte subnatid3=.
	label var subnatid3 "Region at 3 digit (ADMN3)"
	label values subnatid3 lblsubnatid3
	
	
** HOUSE OWNERSHIP
	gen ownhouse=.
	label var ownhouse "Home ownership"
	la de lblownhouse 0 "No" 1 "Yes"
	label values ownhouse lblownhouse


** WATER PUBLIC CONNECTION
	gen water=.
	label define water 0"No" 1"Yes"
	label values water water
	label var water " Water public connection"


** ELECTRICITY PUBLIC CONNECTION
	gen electricity=.
	label define electricity 0"No" 1"Yes"
	label values electricity electricity
	label var electricity "Electricity public connection"


** TOILET PUBLIC CONNECTION
	gen toilet=.
	label var toilet "Toilet public connection"
	label define toilet 0"No" 1"Yes"
	label values toilet toilet
	label var toilet "Toilet public connection"


** LAND PHONE
	gen landphone=.
	label var landphone "Landphone public connection"
	la de lbllandphone 0 "No" 1 "Yes"
	label values landphone lbllandphone


** CEL PHONE
	gen cellphone=.
	label var cellphone "Cell phone"
	la de lblcellphone 0 "No" 1 "Yes"
	label values cellphone lblcellphone


** COMPUTER
	gen computer=.
	label var computer "Computer"
	label define computer 0"No" 1"Yes"
	label values computer computer


** INTERNET
	gen internet=.
	label var internet "internet"
	label define internet 0"No" 1"Yes"
	label values internet internet
	label var internet "internet"


/*****************************************************************************************************
*                                                                                                    *
                                   DEMOGRAPHIC MODULE
*                                                                                                    *
*****************************************************************************************************/


** HOUSEHOLD SIZE
	gen x=1 if S01A_03==1
	egen y=sum(x), by(idh)
	*drop if y!=1

	gen hsize=c1_hhsize
	label var hsize "Household size"


** RELATIONSHIP TO THE HOUSEHOLD HEAD
	gen byte relationharm=S01A_03
	recode relationharm (5=4) (4 6 7 8 9 0 10 11=5) (12 13 14=6)
	label var relationharm "Relationship to the head of household"
	la de lblrelationharm  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Non-relatives"
	label values relationharm  lblrelationharm

	gen byte relationcs=S01A_03
	la var relationcs "Relationship to the head of household country/region specific"
	la define lblrelationcs 1 "Head" 2 "Husband/Wife" 3 "Son/Daughter" 4 "Grandchild" 5 "Father/Mother" 6 "Brother/Sister" 7 "Nephew/Niece" 8 "Son/Daughter-in-law" 9 "Brother/Sister-in-law" 10 "Father/Mother-in-law" 11 "Other family relative" 12 "Servant/servant's relative" 13 "Tenant/tentant's relative" 14 "Other person not related"
	label values relationcs lblrelationcs

	
** GENDER
	gen male=MALE
	label var male "Sex of household member"
	la de lblmale 1 "Male" 0 "Female"
	label values male lblmale


** AGE
	gen age=AGEY
	replace age=98 if age>=98 & age<.
	label var age "Age"


** SOCIAL GROUP
	rename S00_ETHN soc
	label var soc "Social group"


** MARITAL STATUS
	gen marital=.
	replace marital=1 if MARSTAT==2
	replace marital=2 if MARSTAT==4 | MARSTAT==5
	replace marital= 3 if MARSTAT==6
	replace marital=4 if MARSTAT==1
	label var marital "Marital status"
	la de lblmarital 1 "Married or live together" 2 "Divorced/separated" 3 "Widow/er" 4 "Single"
	label values marital lblmarital


/*****************************************************************************************************
*                                                                                                    *
                                   EDUCATION MODULE
*                                                                                                    *
*****************************************************************************************************/


** EDUCATION MODULE AGE
	gen ed_mod_age=5
	label var ed_mod_age "Age at which the education module applies"


** CURRENTLY AT SCHOOL
	gen atschool=CURRENT_ATTEND
	la de atschool 0 "No" 1 "Yes"
	label values atschool  atschool 
	label var atschool "Currently at school"

** CAN READ AND WRITE

	gen literacy=LITERATE
	label var literacy "Can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy


** YEARS OF EDUCATION COMPLETED
	gen educy=EDYEARS
	replace educy=. if age<5 
	label var educy "Years of education completed"


** EDUCATIONAL LEVEL 7 CATEGORIES
	gen educat7=.
	replace educat7=1 if educy==0 
	replace educat7=2 if educy>=1 & educy<5
	replace educat7=3 if educy==5
	replace educat7=4 if educy>=6 & educy<12
	replace educat7=5 if educy==12
	replace educat7=7 if educy>12 & educy!=.
	replace educat7=. if age<5
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


** EVER ATTENDED SCHOOL
	gen everattend=.
	replace everattend=1 if educat4>=2 & educat4<=4
	replace everattend=0 if educat4==1
	replace everattend=1 if atschool==1
	la de lbleverattend 0 "No" 1 "Yes"
	label var everattend "Ever attended school"
	label values everattend lbleverattend

	replace educy=0 if everattend==0
	replace educat7=1 if everattend==0
	replace educat5=1 if everattend==0
	replace educat4=1 if everattend==0

	
	local ed_var "everattend atschool literacy educy educat7 educat5 educat4"
	foreach v in `ed_var'{
	replace `v'=. if( age<ed_mod_age & age!=.)
	}


/*****************************************************************************************************
*                                                                                                    *
                                   LABOR MODULE
*                                                                                                    *
*****************************************************************************************************/


** LABOR MODULE AGE
	gen lb_mod_age=5
	label var lb_mod_age "Age at which the labor module applies"


** LABOR STATUS
	gen lstatus=EMP_STAT
	recode lstatus (2 3=2) (4=3)
	label var lstatus "Labor Status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus


** EMPLOYMENT STATUS
	gen empstat=EMPTYPE_MAIN
	recode empstat (2=3) (3=4) (4=2)
	replace empstat=. if lstatus!=1
	label var empstat "Employment status"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed"
	label values empstat lblempstat



** NUMBER OF ADDITIONAL JOBS
	gen byte njobs=.
	label var njobs "Number of additional jobs"


** SECTOR OF ACTIVITY: PUBLIC - PRIVATE
	gen ocusec=.
	label var ocusec "Sector of activity"
	la de lblocusec 1 "Public, state owned, government, army, NGO" 2 "Private"
	label values ocusec lblocusec
	replace ocusec=. if lstatus!=1


** REASONS NOT IN THE LABOR FORCE
	gen nlfreason=WHYINACTIVE   
	recode nlfreason (1=.) (2=1) (3=2) (4=3) (5 6=4) (12=5)
	label var nlfreason "Reason not in the labor force"
	la de lblnlfreason 1 "Student" 2 "Housewife" 3 "Retired" 4 "Disabled" 5 "Other"
	label values nlfreason lblnlfreason
	replace nlfreason=. if lstatus!=3
	replace nlfreason=. if age<5


** UNEMPLOYMENT DURATION: MONTHS LOOKING FOR A JOB
	gen byte unempldur_l= .
	label var unempldur_l "Unemployment duration (months) lower bracket"

	gen byte unempldur_u= .
	label var unempldur_u "Unemployment duration (months) upper bracket"



** INDUSTRY CLASSIFICATION
	gen industry=SECTOR_MAIN
	recode industry  (99=.) (11=10)
	replace industry=. if lstatus!=1
	la de lblindustry 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Comnunications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label var industry "Industry code"


** OCCUPATION CLASSIFICATION
	gen occup=OCC_MAIN
	replace occup=. if lstatus!=1
	label var occup "1 digit occupational classification"
	la de lbloccup 1 "Senior officials" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup lbloccup


** FIRM SIZE
	gen byte firmsize_l=.
	label var firmsize_l "Firm size (lower bracket)"

	gen byte firmsize_u=.
	label var firmsize_u "Firm size (upper bracket)"


** HOURS WORKED LAST WEEK
	gen whours=.
	label var whours "Hours of work in last week"
	replace whours=. if lstatus!=1


** WAGES
	gen wage=INCOME_MAIN_def if INCOME_MAIN_def>=0
	replace wage=. if lstatus!=1
	replace wage=0 if empstat==2
	label var wage "Last wage payment"


** WAGES TIME UNIT
	gen unitwage=.
	recode unitwage (3=5) (4 5 9=.)
	replace unitwage=. if lstatus!=1
	label var unitwage "Wages' time unit"
	la de lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Trimester" 7 "Biannual" 8 "Annually" 9 "Hourly"
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
	gen spdef=c1_pindex
	la var spdef "Spatial deflator"


** WELFARE
	gen welfare=pcexp/12
	la var welfare "Welfare aggregate"

	gen welfarenom=pcexp/12
	la var welfarenom "Welfare aggregate in nominal terms"

	gen welfaredef=(c1_npcexp/12)
	la var welfaredef "Welfare aggregate spatially deflated"

	gen welfaretype="CONS"
	la var welfaretype "Type of welfare measure (income, consumption or expenditure) for welfare, welfarenom, welfaredef"

	gen welfareother=.
	la var welfareother "Welfare Aggregate if different welfare type is used from welfare, welfarenom, welfaredef"

	gen welfareothertype=""
	la var welfareothertype "Type of welfare measure (income, consumption or expenditure) for welfareother"



/*****************************************************************************************************
*                                                                                                    *
                                   NATIONAL POVERTY
*                                                                                                    *
*****************************************************************************************************/
	

** POVERTY LINE (NATIONAL)
	gen pline_nat=c1_nompln/12
	label var pline_nat "National Poverty Line"


** HEADCOUNT RATIO (NATIONAL)
	gen poor_nat=welfaredef<pline_nat if welfaredef!=.
	la var poor_nat "People below Poverty Line (National)"
	la define poor_nat 0 "Not-Poor" 1 "Poor"
	la values poor_nat poor_nat


/*****************************************************************************************************
*                                                                                                    *
                                   INTERNATIONAL POVERTY
*                                                                                                    *
*****************************************************************************************************/


	local year=2011
	
** USE SARMD CPI AND PPP
	capture drop _merge
	gen urb=.
	merge m:1 countrycode year urb using "D:\SOUTH ASIA MICRO DATABASE\DOCS\CPI and PPP\cpi_ppp_povcalnet.dta", ///
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
	
	saveold "`output'\Data\Harmonized\NPL_1995_LSS-I_v01_M_v01_A_SARMD_IND.dta", replace version(13)
	saveold "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\__REGIONAL\Individual Files\NPL_1995_LSS-I_v01_M_v01_A_SARMD_IND.dta", replace version(13)
	

	log close





******************************  END OF DO-FILE  *****************************************************/
