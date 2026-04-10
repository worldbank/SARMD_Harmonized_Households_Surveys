/*****************************************************************************************************
******************************************************************************************************
**                                                                                                  **
**                                  SOUTH ASIA MICRO DATABASE                                       **
**                                                                                                  **
** COUNTRY	India
** COUNTRY ISO CODE	IND
** YEAR	2004
** SURVEY NAME	SOCIO-ECONOMIC SURVEY  SIXTY-FIRST ROUND JULY 2004-JUNE 2005
*	HOUSEHOLD SCHEDULE 10 : EMPLOYMENT AND UNEMPLOYMENT
** SURVEY AGENCY	GOVERNMENT OF INDIA NATIONAL SAMPLE SURVEY ORGANISATION
** RESPONSIBLE	Triana Yentzen
** MODIFIED BY Yurani Arias Granada (05/22/2016)
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
	local input "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\IND\IND_2004_NSS-SCH10\IND_2004_NSS-SCH10_v01_M"
	local output "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\IND\IND_2004_NSS-SCH10\IND_2004_NSS-SCH10_v01_M_v01_A_SARMD"

** LOG FILE
	*log using "`output'\Doc\Technical\IND_2004_NSS-SCH10_v01_M_v01_A_SARMD.log",replace
/*****************************************************************************************************
*                                                                                                    *
                                   * ASSEMBLE DATABASE
*                                                                                                    *
*****************************************************************************************************/


** DATABASE ASSEMBLENT
	use "`input'\Data\Stata\DataOrig_realpccons.dta", clear

/*****************************************************************************************************
*                                                                                                    *
                                   * STANDARD SURVEY MODULE
*                                                                                                    *
*****************************************************************************************************/

** COUNTRY
	gen str4 countrycode="IND"
	label var countrycode "Country code"

** YEAR
    gen int year=2004
	label var year "Year of survey"
	
** SURVEY NAME 
    gen str survey="NSS-SCH10"
	label var survey "Survey Acronym"
	
** INTERVIEW YEAR
gen byte int_year=.
	label var int_year "Year of the interview"

** INTERVIEW MONTH
	gen byte int_month=.
	la de lblint_month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
	label value int_month lblint_month
	label var int_month "Month of the interview"


** HOUSEHOLD IDENTIFICATION NUMBER
    generate idh=string(hid, "%15.0f")
	label var idh "Household id"


** INDIVIDUAL IDENTIFICATION NUMBER
	tostring pid, gen(idp) format(%11.0f)
	label var idp "Individual id"

	duplicates tag idp, gen(flag)
	bys idp flag: gen N=_n
	drop if pid==.
	drop if N!=1 & N!=. & flag>0 & flag!=.
	drop flag N
	isid idp


** HOUSEHOLD WEIGHTS
	gen wgt=mult
	label var wgt "Household sampling weight"


** STRATA
	gen strata=strtm
	label var strata "Strata"



** PSU
	gen psu=fsu
	label var psu "Primary sampling units"
	
	
** MASTER VERSION
	gen vermast="01"
	label var vermast "Master Version"
	
	
** ALTERATION VERSION
	gen veralt="02"
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
    gen subnatid1=region
    label define lblsubnatid1 1 "Northern" 2 "North-Central" 3 "North-Eastern" 4 "Eastern" 5 "Western" 6 "Southern"
	label var subnatid1 "Region at 1 digit (ADMN1)"
	label values subnatid1 lblsubnatid1
	

** REGIONAL AREA 2 DIGIT ADMN LEVEL
    gen REG=state
	label define REG  28 "Andhra Pradesh"  18 "Assam"  10 "Bihar" 24 "Gujarat" 06 "Haryana"  02 "HimachalPradesh" ///
	01 "Jammu & Kashmir" 29"Karnataka" 32 "Kerala" 23 "Madhya Pradesh" 27  "Maharashtra" ///  
	14 "Manipur"   17 "Meghalaya"  13 "Nagaland"  21 "Orissa"  03 "Punjab" 08 "Rajasthan" 11 "Sikkim" ///
	33 "Tamil Nadu"  16 "Tripura"  09 "Uttar Pradesh"  19 "West Bengal" 35 "A & N Islands" ///
	12 "Arunachal Pradesh"  4 "Chandigarh" 26 "Dadra & Nagar Haveli" 7 "Delhi"  30 "Goa" ///
	31"Lakshdweep" 15 "Mizoram"  34 "Pondicherry"  25 "Daman & Diu" 22"Chhattisgarh" 20"Jharkhand" 5"Uttaranchal"
	gen subnatid2=REG
	label values subnatid2 REG
	label var subnatid2 "Region at 2 digit(ADMN2)"


** REGIONAL AREA 3 DIGITS ADM LEVEL (ADMN3)
	en byte subnatid3=.
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

** ELECTRICITY PUBLIC CONNECTION

	gen electricity=.
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

**HOUSEHOLD SIZE
	ren hhsize HHSIZE
	gen one=1
	egen two=group(idp one)
	bys idh: egen hhsize= count(two) if relntohead>=1 & relntohead<=8
	label var hhsize "Household size"
	drop one two


** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
	bys idh: gen one=1 if relntohead==1 
	bys idh: egen temp=count(one) 
	keep if temp==1

	gen relationharm= relntohead
	recode head (3 5 = 3) (7=4) (4 6 8 = 5) (9=6)
	label var head "Relationship to the head of household"
	la de lblhead  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Non-relatives"
	label values head  lblhead
	
	
** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
	gen byte relationcs=relntohead
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
* socialgrp
	label var soc "Social group"
	label define soc 1 "Hinduism" 2 "Islam" 3 "Sikhism" 4 "Jainism" 5"Buddhism" 6"Zoroastrianism" 7"Others"  9"Others'
	label values soc soc


** MARITAL STATUS
	gen marital=.
	replace marital=. if maritalstatus==0
	replace marital=1 if maritalstatus==2
	replace marital=4 if maritalstatus==4
	replace marital=5 if maritalstatus==3
	replace marital=2 if maritalstatus==1
	label var marital "Marital status"
	la de lblmarital 1 "Married" 2 "Never Married" 3 "Living together" 4 "Divorced/Separated" 5 "Widowed"
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
	gen atschool=1  if currattend>=21 & currattend!=.
	replace atschool=0 if currattend<21 | currattend==.
	label var atschool "Attending school"
	la de lblatschool 0 "No" 1 "Yes"
	label values atschool  lblatschool


** CAN READ AND WRITE
	gen literacy=1 
	replace literacy=0 if genedulev==1
	replace literacy=. if genedulev==0 | genedulev==.
	label var literacy "Can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy


** YEARS OF EDUCATION COMPLETED
	gen educy=.
	/* no education */
	replace educy=0 if genedulev==01 | genedulev==02 | genedulev==03 | genedulev==04 
	/* below primary */
	replace educy=1 if genedulev==05
	/* primary */
	replace educy=5 if genedulev==06
	/* middle */
	replace educy=8 if genedulev==07
	/* secondary */
	replace educy=10 if genedulev==8
	/* higher secondary */
	replace educy=12 if genedulev==9
	/* graduate and above in agriculture, engineering/technology, medicine */
	replace educy=16 if genedulev==10 | genedulev==11 | genedulev==12
	/* graduate and above in other subjects */
	replace educy=15 if genedulev==13
	gen ageminus4=age-4
	replace educy=ageminus4 if (educy>ageminus4)& (educy>0) & (ageminus4>0) & (educy!=.)
	replace educy=0 if (educy>ageminus4) & (educy>0) &(ageminus4<=0) & (educy!=.)
	label var educy "Years of education"
	

	** EDUCATION LEVEL 7 CATEGORIES
	gen edulevel1=.
	replace edulevel1=1 if genedulev==1
	replace edulevel1=2 if genedulev==5
	replace edulevel1=3 if genedulev==6
	replace edulevel1=4 if genedulev==7|genedulev==8
*secondary complete is not available
	replace edulevel1=5 if genedulev==9
	replace edulevel1=7 if genedulev>=10 & genedulev!=.
	replace edulevel1=8 if genedulev==2 |genedulev==3|genedulev==4
	label var edulevel1 "Level of education 1"
	la de lbledulevel1 1 "No education" 2 "Primary incomplete" 3 "Primary complete" 4 "Secondary incomplete" 5 "Secondary complete" 6 "Higher than secondary but not university" 7 "University incomplete or complete" 8 "Other" 9 "Not classified"
	label values edulevel1 lbledulevel1
	

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
	recode genedulev (1 2 3 4= 0) (5 6 7 8 9 10 11 12 13=1), gen (everattend)
	label var everattend "Ever attended school"
	la de lbleverattend 0 "No" 1 "Yes"
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
	label var lb_mod_age "Labor module application age"

	
** LABOR STATUS
    gen lstatus=.
	gen days_main_week=.
	replace days_main_week=totdaysactivity_1 if statusweek==status_1 & days_main_week==.
	replace days_main_week=totdaysactivity_2 if statusweek==status_2 & days_main_week==.
	replace days_main_week=totdaysactivity_3 if statusweek==status_3 & days_main_week==.
	replace days_main_week=totdaysactivity_4 if statusweek==status_4 & days_main_week==.

	replace lstatus=2 if  statusweek==81 
	replace lstatus=1 if days_main_week>=0.5 & (statusweek==11 | statusweek==12 | statusweek==21 | statusweek==31 | statusweek==41 | statusweek==51 ) 
	replace lstatus=1 if (statusweek==61 | statusweek==62 | statusweek==71 | statusweek==72) 
	replace lstatus=3 if (lstatus!=1 & lstatus!=2)
	gen daysmain=days_main_week if lstatus==1
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus
	replace lstatus=. if  age<lb_mod_age

** EMPLOYMENT STATUS
	gen empstat=.
	replace empstat=1  if statusualprincact==31 | statusualprincact==41 | statusualprincact==51 
	replace empstat=3 if statusualprincact==12
	replace empstat=4 if statusualprincact==11
	replace empstat=2 if statusualprincact==21 
	replace empstat=. if lstatus!=1 | age<lb_mod_age

	label var empstat "Employment status"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed"
	label values empstat lblempstat


** NUMBER OF ADDITIONAL JOBS
	gen njobs=.
	label var njobs "Number of additional jobs"


** SECTOR OF ACTIVITY: PUBLIC - PRIVATE
	gen ocusec=.
	replace ocusec=1 if enterprisetype==5 |enterprisetype==7
	replace ocusec=2 if  enterprisetype>=1 & enterprisetype<=4
	replace ocusec=2 if  enterprisetype==8 |enterprisetype==6
	replace ocusec=. if  enterprisetype==9 
	label var ocusec "Sector of activity"
	la de lblocusec 1 "Public, state owned, government, army, NGO" 2 "Private"
	label values ocusec lblocusec
	replace ocusec=. if lstatus!=1


** REASONS NOT IN THE LABOR FORCE
	gen nlfreason=.
	replace nlfreason=1 if statusualprincact==91
	replace nlfreason=2 if statusualprincact==92|statusualprincact==93
	replace nlfreason=3 if statusualprincact==94
	replace nlfreason=4 if statusualprincact==95
	replace nlfreason=5 if statusualprincact==97 
	replace nlfreason=. if lstatus~=3
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
	gen str5 princind_ISIC = string(  industryweek,"%05.0f") 
	gen princind_CODE=substr(princind_ISIC,1,2) 
	drop princind_ISIC
	destring princind_CODE, generate(princind_ISIC)
	replace industry=1 if princind_ISIC==01 |princind_ISIC==02 |princind_ISIC==05
	replace industry=2 if princind_ISIC>=10 & princind_ISIC<=14
	replace industry=3 if princind_ISIC>=15 & princind_ISIC<=37
	replace industry=4 if princind_ISIC>=40 | princind_ISIC==41 
	replace industry=5 if princind_ISIC==45 
	replace industry=6 if princind_ISIC>=50 | princind_ISIC==51| princind_ISIC==52| princind_ISIC==55
	replace industry=7 if princind_ISIC>=60 & princind_ISIC<=64
	replace industry=8 if princind_ISIC>=65 & princind_ISIC<=67
	replace industry=8 if princind_ISIC>=70 & princind_ISIC<=74
	replace industry=9 if  princind_ISIC==75
	replace industry=10 if princind_ISIC==80 | princind_ISIC==85| princind_ISIC==91| princind_ISIC==92| princind_ISIC==93|princind_ISIC==95| princind_ISIC==99
	replace industry=10 if industry==. & princind_ISIC!=.
	label var industry "1 digit industry classification"
	la de lblindustry 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transports and comnunications" 8 "Financial and business-oriented services" 9 "Community and family oriented services" 10 "Others"
	label values industry lblindustry
	replace industry=. if lstatus!=1


** OCCUPATION CLASSIFICATION

	gen str3 princocc_NCO =  occupweek
	gen princocc_CODE2=substr(princocc_NCO,1,2) 
	gen princocc_CODE3= princocc_NCO
	drop princocc_NCO
	gen occup=.

	*professional

	replace occup=2 if princocc_CODE3=="000" | princocc_CODE3=="001" | princocc_CODE3=="002" | princocc_CODE3=="003"
	replace occup=2 if princocc_CODE3=="004" | princocc_CODE3=="006" | princocc_CODE3=="008"
	replace occup=2 if princocc_CODE3=="020" | princocc_CODE3=="021" | princocc_CODE3=="022" | princocc_CODE3=="023"
	replace occup=2 if princocc_CODE3=="024" | princocc_CODE3=="025" | princocc_CODE3=="026" | princocc_CODE3=="027"
	replace occup=2 if princocc_CODE3=="050" | princocc_CODE3=="051" | princocc_CODE3=="052" | princocc_CODE3=="053"
	replace occup=2 if princocc_CODE3=="054" | princocc_CODE3=="057" 
	replace occup=2 if princocc_CODE3=="070" | princocc_CODE3=="071" | princocc_CODE3=="072" | princocc_CODE3=="073"

	replace occup=2 if princocc_CODE3=="074" | princocc_CODE3=="075" | princocc_CODE3=="076" | princocc_CODE3=="084"
	replace occup=2 if princocc_CODE3=="085"  | princocc_CODE3=="147"
	replace occup=2 if princocc_CODE3=="140" | princocc_CODE3=="141" | princocc_CODE3=="149" | princocc_CODE3=="180"

	replace occup=2 if princocc_CODE3=="181" | princocc_CODE3=="182" | princocc_CODE3=="183" | princocc_CODE3=="185"
	replace occup=2 if princocc_CODE3=="186" | princocc_CODE3=="187" | princocc_CODE3=="188" | princocc_CODE3=="189"

	replace occup=2 if princocc_CODE2=="10" | princocc_CODE2=="11" | princocc_CODE2=="12" | princocc_CODE2=="13"

	replace occup=2 if princocc_CODE2=="15" | princocc_CODE2=="16" | princocc_CODE2=="17" | princocc_CODE2=="19"

	*technician and associate pro

	replace occup=3 if princocc_CODE3=="009" | princocc_CODE3=="010" | princocc_CODE3=="019" | princocc_CODE3=="028"
	replace occup=3 if princocc_CODE3=="011" | princocc_CODE3=="012" | princocc_CODE3=="014" | princocc_CODE3=="015"
	replace occup=3 if princocc_CODE3=="017" | princocc_CODE3=="018" 
	replace occup=3 if princocc_CODE3=="029" | princocc_CODE3=="059" | princocc_CODE3=="077" | princocc_CODE3=="078"
	replace occup=3 if princocc_CODE3=="079" | princocc_CODE3=="080" | princocc_CODE3=="081" | princocc_CODE3=="082"
	replace occup=3 if princocc_CODE3=="083" | princocc_CODE3=="086" | princocc_CODE3=="087" | princocc_CODE3=="088"
	replace occup=3 if princocc_CODE3=="089" | princocc_CODE3=="142" | princocc_CODE3=="184" 

	replace occup=3 if princocc_CODE2=="03" | princocc_CODE2=="04" | princocc_CODE2=="06" | princocc_CODE2=="09"

	*legislators, senior officials and managers

	replace occup=1 if princocc_CODE2=="20" | princocc_CODE2=="21" | princocc_CODE2=="22" | princocc_CODE2=="23"
	replace occup=1 if princocc_CODE2=="24" | princocc_CODE2=="25" | princocc_CODE2=="26" | princocc_CODE2=="29" | princocc_CODE2=="27" | princocc_CODE2=="28"

	replace occup=1 if princocc_CODE2=="30" | princocc_CODE2=="31" | princocc_CODE2=="36"  | princocc_CODE2=="60" 

	*clerks

	replace occup=4 if princocc_CODE2=="32" | princocc_CODE2=="33" | princocc_CODE2=="34" | princocc_CODE2=="35"

	replace occup=4 if princocc_CODE2=="37" | princocc_CODE2=="38" | princocc_CODE2=="39" 

	replace occup=4 if princocc_CODE3=="302" 

	*Service workers and shop and market sales

	replace occup=5 if princocc_CODE2=="40" | princocc_CODE2=="41" | princocc_CODE2=="42" | princocc_CODE2=="43"
	replace occup=5 if princocc_CODE2=="44" | princocc_CODE2=="45" | princocc_CODE2=="49" | princocc_CODE2=="50"
	replace occup=5 if princocc_CODE2=="46" | princocc_CODE2=="47" | princocc_CODE2=="48" 
	replace occup=5 if princocc_CODE2=="51" | princocc_CODE2=="52" | princocc_CODE2=="53" | princocc_CODE2=="54"
	replace occup=5 if princocc_CODE2=="55" | princocc_CODE2=="56" | princocc_CODE2=="57" | princocc_CODE2=="58" | princocc_CODE2=="59"

	*skilled agricultural and fishery workers

	replace occup=6 if princocc_CODE2=="61" | princocc_CODE2=="62" | princocc_CODE2=="63" | princocc_CODE2=="64"
	replace occup=6 if princocc_CODE2=="65" | princocc_CODE2=="66" | princocc_CODE2=="67" | princocc_CODE2=="68" | princocc_CODE2=="69"

	*Craft and related trades

	replace occup=7 if princocc_CODE2=="71" | princocc_CODE2=="72" | princocc_CODE2=="73" | princocc_CODE2=="75" | princocc_CODE2=="70"
	replace occup=7 if princocc_CODE2=="76" | princocc_CODE2=="77" | princocc_CODE2=="78" | princocc_CODE2=="79"
	replace occup=7 if princocc_CODE2=="80" | princocc_CODE2=="81" | princocc_CODE2=="82" | princocc_CODE2=="92"
	replace occup=7 if princocc_CODE2=="93" | princocc_CODE2=="94" | princocc_CODE2=="95" 

	*Plant and machine operators and assemblers

	replace occup=8 if princocc_CODE2=="74" | princocc_CODE2=="83" | princocc_CODE2=="84" | princocc_CODE2=="85"
	replace occup=8 if princocc_CODE2=="86" | princocc_CODE2=="87" | princocc_CODE2=="88" | princocc_CODE2=="89"
	replace occup=8 if princocc_CODE2=="90" | princocc_CODE2=="91" | princocc_CODE2=="96" | princocc_CODE2=="97"
	replace occup=8 if princocc_CODE2=="98" 
	replace occup=8 if princocc_CODE3=="813" 

	*elementary occupations

	replace occup=9 if princocc_CODE2=="99" 

	*other/unspecified

	replace occup=99 if princocc_CODE2=="X0" | princocc_CODE2=="X1" | princocc_CODE2=="X9" 

	*legislators, senior officials and managers CONTT.

	replace occup=1 if princocc_CODE3=="710" | princocc_CODE3=="720" | princocc_CODE3=="730" | princocc_CODE3=="740"
	replace occup=1 if princocc_CODE3=="750" | princocc_CODE3=="760" | princocc_CODE3=="770" | princocc_CODE3=="780"  
	replace occup=1 if princocc_CODE3=="790" | princocc_CODE3=="800" | princocc_CODE3=="810" | princocc_CODE3=="820" 
	replace occup=1 if princocc_CODE3=="830" | princocc_CODE3=="840" | princocc_CODE3=="850" | princocc_CODE3=="860"  
	replace occup=1 if princocc_CODE3=="870" | princocc_CODE3=="880" | princocc_CODE3=="890" | princocc_CODE3=="900" 
	replace occup=1 if princocc_CODE3=="910" | princocc_CODE3=="920" | princocc_CODE3=="930" | princocc_CODE3=="940"  
	replace occup=1 if princocc_CODE3=="950" | princocc_CODE3=="960" | princocc_CODE3=="970" | princocc_CODE3=="980"

	drop  princocc_CODE2 princocc_CODE3

	label var occup "1 digit occupational classification"
	label define occup 1 "Senior officials" 2 "Professionals" 3 "Technicians" 4 "Clerks" ///
	5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" ///
	8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup occup
	replace occup=. if lstatus!=1
	drop princind_CODE princind_ISIC


** FIRM SIZE
	gen firmsize_l=.
	replace firmsize_l=1 if noworkersenterprise==1
	replace firmsize_l=6 if noworkersenterprise==2
	replace firmsize_l=10 if noworkersenterprise==3
	replace firmsize_l=20 if noworkersenterprise==4
	replace firmsize_l=. if noworkersenterprise==9
	replace firmsize_l=. if lstatus!=1
	label var firmsize_l "Firm size (lower bracket)"

	gen firmsize_u=noworkersenterprise
	replace firmsize_u=6 if noworkersenterprise==1
	replace firmsize_u=9 if noworkersenterprise==2
	replace firmsize_u=20 if noworkersenterprise==3
	replace firmsize_u=. if noworkersenterprise==4
	replace firmsize_u=. if noworkersenterprise==9
	replace firmsize_u=. if lstatus!=1
	label var firmsize_u "Firm size (upper bracket)"


** HOURS WORKED LAST WEEK

	gen HOURWRKMAIN_mon=.

	#delimit;
	gen mainhrs=.;
	forval i = 1/4 { ;
	replace mainhrs = totdaysactivity_`i' if statusweek == status_`i' & mi(mainhrs) & 
	inlist(status_`i', 11, 12, 21, 31, 41, 51);
	};
	#delimit cr
	replace mainhrs=. if lstatus!=1
	replace mainhrs=0 if lstatus==1 & mi(mainhrs)
	replace HOURWRKMAIN_mon=8*mainhrs*52/12
	drop mainhrs
	gen HOURWRKMAIN_week=HOURWRKMAIN_mon*12/52
	ren HOURWRKMAIN_week whours
	label var whours "Hours of work in last week"


** WAGES

/*
WEEKLY
*/
	gen wage=wagecashrs_1 
	replace wage=. if lstatus!=1
	replace wage=0 if empstat==2
	label var wage "Last wage payment"


** WAGES TIME UNIT
	gen unitwage=.
	replace unitwage=1 if modepayment_1==1|modepayment_1==16
	replace unitwage=2 if modepayment_1==2|modepayment_1==17
	replace unitwage=3 if modepayment_1==3|modepayment_1==18
	replace unitwage=5 if modepayment_1==4|modepayment_1==19
	replace unitwage=. if lstatus!=1
	label var unitwage "Last wages time unit"
	la de lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Trimester" 7 "Biannual" 8 "Annually" 9 "Hourly" 
	label values unitwage lblunitwage


** CONTRACT
	gen contract=typejobcontract
	recode contract (1=0) (2 3 4=1)
	replace contract=. if lstatus!=1
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
	gen union=. if memberunion==""
	forval i=1/5 {
	replace union=`i' if memberunion=="`i'"
	}
	replace union=. if memberunion=="X" | memberunion=="0"
	label var union "Union membership"
	recode union (2 3 4 5=0)
	replace union=. if lstatus!=1
	la de lblunion 0 "No member" 1 "Member"
	label values union lblunion

	local lb_var "lstatus empstat njobs ocusec nlfreason unempldur_l unempldur_u industry industry1 occup firmsize_l firmsize_u whours wage unitwage contract healthins socialsec union"
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
	gen spdef=.
	la var spdef "Spatial deflator"
*</_spdef_>

	
** WELFARE
*<_welfare_>
	gen welfare=monthhhexp/hhsize
	la var welfare "Welfare aggregate"
*</_welfare_>

*<_welfarenom_>
	gen welfarenom=welfare
	la var welfarenom "Welfare aggregate in nominal terms"
*</_welfarenom_>

*<_welfaredef_>
	gen welfaredef=.
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
	gen welfareothertype=.
	la var welfareothertype "Type of welfare measure (income, consumption or expenditure) for welfareother"
*</_welfareothertype_>

*<_welfarenat_>
	gen welfarenat=.
	la var welfarenat "Welfare aggregate for national poverty"
*</_welfarenat_>

/*****************************************************************************************************
*                                                                                                    *
                                   NATIONAL POVERTY
*                                                                                                    *
*****************************************************************************************************/


** POVERTY LINE (NATIONAL)
*<_pline_nat_>
	gen pline_nat=.
	label variable pline_nat "Poverty Line (National)"
*</_pline_nat_>


** HEADCOUNT RATIO (NATIONAL)
*<_poor_nat_>
	gen poor_nat=.
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
    *_pctile pcexp [aw=mult], percent(32.8)
    *di r(r1)
	gen pline_int=423
	label variable pline_int "Poverty Line (Povcalnet)"

	
** HEADCOUNT RATIO (POVCALNET)
	gen poor_int=welfare<pline_int & welfare!=.
	la var poor_int "People below Poverty Line (Povcalnet)"
	la define poor_int 0 "Not Poor" 1 "Poor"
	la values poor_int poor_int


*/*****************************************************************************************************
*                                                                                                    *
                                   FINAL FIXES
*                                                                                                    *
*****************************************************************************************************/

	qui su wage
	replace wage=0 if empstat==2 & r(N)!=0
	replace ownhouse=. if head==6

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
		 unitwage contract healthins socialsec union  ///
		 pline_nat pline_int poor_nat poor_int spdef cpi ppp cpiperiod welfare welfarenom welfaredef ///
		 welfarenat welfareother welfaretype welfareothertype

** ORDER VARIABLES

	order countrycode year survey idh idp wgt strata psu vermast veralt urban int_month int_year  ///
	      subnatid1 subnatid2 subnatid3 ownhouse water electricity toilet landphone cellphone ///
	      computer internet hsize relationharm relationcs male age soc marital ed_mod_age everattend ///
	      atschool electricity literacy educy educat4 educat5 educat7 lb_mod_age lstatus empstat njobs ///
	      ocusec nlfreason unempldur_l unempldur_u industry occup firmsize_l firmsize_u whours wage ///
		  unitwage contract healthins socialsec union   ///
		  pline_nat pline_int poor_nat poor_int spdef cpi ppp cpiperiod welfare welfarenom welfaredef ///
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
	keep countrycode year survey idh idp wgt strata psu vermast veralt `keep' *type

	compress


	saveold "`output'\Data\Harmonized\IND_2004_NSS-SCH10_v01_M_v01_A_SARMD.dta", replace version(12)
	saveold "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\__REGIONAL\Individual Files\IND_2004_NSS-SCH10_v01_M_v01_A_SARMD.dta", replace version(12)


	log close

******************************  END OF DO-FILE  *****************************************************/
