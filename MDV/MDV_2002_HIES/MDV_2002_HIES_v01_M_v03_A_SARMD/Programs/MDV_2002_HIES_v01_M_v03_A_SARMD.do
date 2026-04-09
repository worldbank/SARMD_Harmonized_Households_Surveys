/*****************************************************************************************************
******************************************************************************************************
**                                                                                                  **
**                              SOUTH ASIA MICRO DATABASE (SARMD)                                   **
**                                                                                                  **
** COUNTRY			Maldives
** COUNTRY ISO CODE	MDV
** YEAR				2009
** SURVEY NAME		Vulnerability and poverty assessment survey – 2002
** SURVEY AGENCY	Minister of Planning and National Development
** RESPONSIBLE		Triana Yentzen
** MODIFIED BY		Julian Eduardo Diaz Gutierrez
** Date			    06/12/2016
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
	local input "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\MDV\MDV_2002_HIES\MDV_2002_HIES_v01_M"
	local output "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\MDV\MDV_2002_HIES\MDV_2002_HIES_v01_M_v03_A_SARMD"
	glo pricedata "D:\SOUTH ASIA MICRO DATABASE\CPI\cpi_ppp_sarmd_weighted.dta"
	glo shares "D:\SOUTH ASIA MICRO DATABASE\APPS\DATA CHECK\Food and non-food shares\MDV"
	glo fixlabels "D:\SOUTH ASIA MICRO DATABASE\APPS\DATA CHECK\Label fixing"

** LOG FILE
	log using "`output'\Doc\Technical\MDV_2002_HIES_v01_M_v03_A_SARMD.log",replace

/*****************************************************************************************************
*                                                                                                    *
                                   * ASSEMBLE DATABASE
*                                                                                                    *
*****************************************************************************************************/

	* PREPARE DATASETS

	* Household
	use "`input'\Data\Stata\A1r-Household-info.dta", clear
	
	ren hhserial hhid
	ren rfoverall wght_hh  
	ren region geo_1
	label var wght_hh "household weight"
	sort hhid
	tempfile household
	save `household'

	* Employment
	use "`input'\Data\Stata\A3r-EmploymentGeneral.dta", clear
	
	ren hhserial hhid
	ren individual pid
	egen njob=max( primsec), by(hhid pid)

*	gen njobs=primsec==2 if primsec<. 
	*drop if primsec==2
	keep hhid pid primsec industry occupation estbtype hrsworked mthsworked empstatus njob
	reshape wide industry occupation estbtype hrsworked mthsworked empstatus, i(hhid pid) j( primsec)
	sort hhid pid
	tempfile employment
	save `employment'
	
	use "`input'\Data\Stata\wf2002.dta", clear
	sort hhid id
	ren id pid
	keep hhid pid pce* pcer* z* spi* cpi* hhsize hhsize_off
	tempfile consumption
	save `consumption'
	
	*Add durables
	use "`input'\Data\Stata\A7r-ConsumerDurables_without_duplicates.dta", clear
	keep hhserial numitems descript
	gen des=upper(descript)
	replace des=strtoname(des)
	keep hhserial numitems des
	reshape wide numitems , i( hhserial ) j( des ) string
	ren hhserial hhid
 	tempfile durables
	save `durables'
	
	
	* MERGE DATASETS
	
	use "`input'\Data\Stata\A2r-Individual-info.dta", clear
	ren hhserial hhid
	ren individual pid
	sort hhid pid
	
	merge m:1 hhid using `household'
	drop _merge
	
	merge m:1 hhid using `durables'
	drop _merge

	
	merge 1:1 hhid pid using `employment'
	drop _merge
	
	merge 1:1 hhid pid using `consumption'
	drop _merge

	
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
	gen int year=2002
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
	gen double wgt=wght_hh
	label var wgt "Household sampling weight"
*</_wgt_>


** STRATA
*<_strata_>
	gen strata=geo_1
	label var strata "Strata"
*</_strata_>
notes _dta: "MDV 2002" region is used as strata

** PSU
*<_psu_>
	gen psu=.
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
	gen urban=geo_1==0
	label var urban "Urban/Rural"
	la de lblurb 1 "Urban" 0 "Rural"
	label values urban lblurb
	notes urban:  "MDV 2002" the urban area in this context is comprised by Male'. Rural areas are the rest of Atolls
*</_urban_>


** REGIONAL AREA 1 DIGIT ADMN LEVEL
*<_subnatid1_>
	*gen byte subnatid1=geo_1
	*la de lblsubnatid1 0 "Male (capital)" 1 "North" 2 "Central North" 3 "Central" 4 "Central South" 5 "South"
	gen byte 	subnatid1=1 if geo_1==0
	replace		subnatid1=2 if geo_1!=0 & geo_1!=.
	la de lblsubnatid1 1 "Male" 2 "Atolls"
	label var subnatid1 "Region at 1 digit (ADMN1)"
	label values subnatid1 lblsubnatid1
*</_subnatid1_>


** REGIONAL AREA 2 DIGIT ADMN LEVEL
*<_subnatid2_>
	gen byte subnatid2=.
	label var subnatid2 "Region at 2 digit (ADMN2)"
	label values subnatid2 lblsubnatid2
	notes subnatid2: "MDV 2002" no coding information available for this variable
*</_subnatid2_>

	
** REGIONAL AREA 3 DIGIT ADMN LEVEL
*<_subnatid3_>
	gen byte subnatid3=.
	label var subnatid3 "Region at 3 digit (ADMN3)"
	label values subnatid3 lblsubnatid3
*</_subnatid3_>
	
		
** HOUSE OWNERSHIP
*<_ownhouse_>
	recode tenuretype (1=1)(2 3=0), gen(ownhouse)
	label var ownhouse "House ownership"
	la de lblownhouse 0 "No" 1 "Yes"
	label values ownhouse lblownhouse
*</_ownhouse_>


** TENURE OF DWELLING
*<_tenure_>
   gen tenure=.
   replace tenure=1 if tenuretype==1
   replace tenure=2 if tenuretype==3
   replace tenure=3 if tenuretype==2
   label var tenure "Tenure of Dwelling"
   la de lbltenure 1 "Owner" 2"Renter" 3"Other"
   la val tenure lbltenure
  *</_tenure_>	


** LANDHOLDING
*<_lanholding_>
   gen landholding=.
   label var landholding "Household owns any land"
   la de lbllandholding 0 "No" 1 "Yes"
   la val landholding lbllandholding
*</_tenure_>	



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

** INTERNET
*<_intenet_>
	gen byte internet= .
	label var internet "Internet connection"
	la de lblinternet 0 "No" 1 "Yes"
	label values internet lblinternet
*</_intenet_>


/*****************************************************************************************************
*                                                                                                    *
                                   DEMOGRAPHIC MODULE
*                                                                                                    *
*****************************************************************************************************/


** HOUSEHOLD SIZE
*<_hsize_>

* Construct "official" hhsize
	# delim ;
	label define membershipstatus 	1 "Household Head" 
									2 "Paying Guest" 
									3 "Foreign Domestic Servant" 
									4 "Local Domestic Servant" 
									5 "Guest" 
									6 "Other Household Member";
	label value membershipstatus membershipstatus;
	# delim cr
		
	/*
	
	The official definition in 2009 included all "family members" 
	and "paying guests" that are used to take meals together
	
	The 2002 questionnaire is different: 
	the first category rather than including "family members" only lists "household heads".
	We assume that all other family members are under the "other hh member" category: 
	the vast majority of individuals hold that category (83%).
	
	
	
	gen byte hhs = 0
	replace  hhs = 1 if ((membershipstatus<=2 | membershipstatus==6) & (takemeal==1) & (membershipstatus!=.))
	egen hsize=total(hhs), by(hhid)*/
	ren hhsize hsize
	la var hsize "Household size"
*</_hsize_>

**POPULATION WEIGHT
*<_pop_wgt_>
	gen pop_wgt=wgt*hsize
	la var pop_wgt "Population weight"
*</_pop_wgt_>


** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
*<_relationharm_>
	recode membershipstatus (1=1) (6=5) (2/5=6), gen(relationharm)
	label var relationharm "Relationship to the head of household"
	la de lblrelationharm  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Non-relatives"
	label values relationharm  lblrelationharm
*</_relationharm_>

** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
*<_relationcs_>

	gen byte relationcs=relation
	la var relationcs "Relationship to the head of household country/region specific"
	# delim ;
	label define lblrelationcs 		1 "Household Head" 
									2 "Paying Guest" 
									3 "Foreign Domestic Servant" 
									4 "Local Domestic Servant" 
									5 "Guest" 
									6 "Other Household Member";
	# delim cr
	label values relationcs lblrelationcs
*</_relationcs_>


** GENDER
*<_male_>
	gen byte male=sex
	recode male (2=1) (1=0)
	label var male "Sex of household member"
	la de lblmale 1 "Male" 0 "Female"
	label values male lblmale
*</_male_>


** AGE
*<_age_>
	label var age "Age of individual"
	replace age=98 if age>=98 & age!=.
*</_age_>

** SOCIAL GROUP
*<_soc_>
	gen byte soc=.
	label var soc "Social group"
	la de lblsoc 1 "Dhivehi" 2 "English" 3 "Other" 4 "None"
	label values soc lblsoc
*</_soc_>


** MARITAL STATUS
*<_marital_>
	gen marital=.
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
	gen byte ed_mod_age=.
	label var ed_mod_age "Education module application age"
*</_ed_mod_age_>


** CURRENTLY AT SCHOOL
*<_atschool_>
	gen byte atschool=.
	label var atschool "Attending school"
	la de lblatschool 0 "No" 1 "Yes"
	label values atschool  lblatschool
*</_atschool_>


** CAN READ AND WRITE
*<_literacy_>
	gen byte literacy=.
	label var literacy "Can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy
*</_literacy_>


** YEARS OF EDUCATION COMPLETED
*<_educy_>
	gen byte educy=.
	label var educy "Years of education"
*</_educy_>

** EDUCATION LEVEL 7 CATEGORIES
*<_educat7_>
	gen byte educat7=.
	label define lbleducat7 1 "No education" 2 "Primary incomplete" 3 "Primary complete" ///
	4 "Secondary incomplete" 5 "Secondary complete" 6 "Higher than secondary but not university" /// 
	7 "University incomplete or complete" 8 "Other" 9 "Not classified"
	label values educat7 lbleducat7
	la var educat7 "Level of education 7 categories"
*</_educat7_>



** EDUCATION LEVEL 5 CATEGORIES
*<_educat5_>
	gen educat5=.
	label define lbleducat5 1 "No education" 2 "Primary incomplete" ///
	3 "Primary complete but secondary incomplete" 4 "Secondary complete" ///
	5 "Some tertiary/post-secondary"
	label values educat5 lbleducat5
*</_educat5_>

	la var educat5 "Level of education 5 categories"

	
** EDUCATION LEVEL 4 CATEGORIES
*<_educat4_>
	gen byte educat4=.
	label var educat4 "Level of education 4 categories"
	label define lbleducat4 1 "No education" 2 "Primary (complete or incomplete)" ///
	3 "Secondary (complete or incomplete)" 4 "Tertiary (complete or incomplete)"
	label values educat4 lbleducat4
*</_educat4_>

  ** EVER ATTENDED SCHOOL
*<_everattend_>
	gen everattend=.
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

 gen byte lb_mod_age=15
	label var lb_mod_age "Labor module application age"
*</_lb_mod_age_>


** LABOR STATUS
*<_lstatus_>
	gen byte lstatus=1 if activitytype==1
	replace lstatus=3 if activitytype!=1 & activitytype!=.
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus
	notes lstatus: "MDV 2002" It is not possible to identify "Unemployed" on this round in the screening process because there are not questions if people are seeking for jobs in case they are not employed
*</_lstatus_>


** LABOR STATUS LAST YEAR
*<_lstatus_year_>
	gen byte lstatus_year=.
	replace lstatus_year=. if age<lb_mod_age & age!=.
	label var lstatus_year "Labor status during last year"
	la de lbllstatus_year 1 "Employed" 2 "Unemployed" 3 "Non-in-labor force"
	label values lstatus_year lbllstatus_year
*</_lstatus_year_>

** EMPLOYMENT STATUS
*<_empstat_>`
	recode empstatus1 (1=3) (2=1) (3=4) (5 = 2) (4= 2), gen(empstat)
	replace empstat=. if lstatus==2 | lstatus==3
	label var empstat "Employment status"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other"
	label values empstat lblempstat
*</_empstat_>

** EMPLOYMENT STATUS LAST YEAR
*<_empstat_year_>
	gen byte empstat_year=.
	replace empstat_year=. if lstatus_year!=1
	label var empstat_year "Employment status during last year"
	la de lblempstat_year 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat_year lblempstat_year
*</_empstat_year_>


** SECTOR OF ACTIVITY: PUBLIC - PRIVATE
*<_njobs_>
	gen byte njobs=1 if njob==2
	label var njobs "Number of additional jobs"
*</_njobs_>

** NUMBER OF ADDITIONAL JOBS LAST YEAR
*<_njobs_year_>
	gen byte njobs_year=.
	replace njobs_year=. if lstatus_year!=1
	label var njobs_year "Number of additional jobs during last year"
*</_njobs_year_>

** SECTOR OF ACTIVITY: PUBLIC - PRIVATE
*<_ocusec_>
	gen ocusec=.
	label var ocusec "Sector of activity"
	la de lblocusec 1 "Public, state owned, government, army, NGO" 2 "Private"
	label values ocusec lblocusec
	notes ocusec: "MDV 2002" The question for classification of type of establishment (public/private) is ambiguous on categories and variable was left as missing
*</_ocusec_>


** REASONS NOT IN THE LABOR FORCE
*<_nlfreason_>
	recode activitytype (2=1) (3=2)(4=5) (1=.), gen(nlfreason)
	label var nlfreason "Reason not in the labor force"
	la de lblnlfreason 1 "Student" 2 "Housewife" 3 "Retired" 4 "Disabled" 5 "Other"
	label values nlfreason lblnlfreason
*</_nlfreason_>


** UNEMPLOYMENT DURATION: MONTHS LOOKING FOR A JOB
*<_unempldur_l_>
	gen byte unempldur_l=.
	label var unempldur_l "Unemployment duration (months) lower bracket"
*</_unempldur_l_>

*<_unempldur_u_>

	gen byte unempldur_u=.
	label var unempldur_u "Unemployment duration (months) upper bracket"
*</_unempldur_u_>

**ORIGINAL INDUSTRY CLASSIFICATION
*<_industry_orig_>
	rename industry1 industry
	gen industry_orig=industry
	#delimit
la def lblindustry_orig
	111	"Growing of cereal and other crops n.e.c."
	112	"Growing of vegetables, horticultural specialties and nursery products"
	113	"Growing  of fruits, nuts, beverage and spice crops"
	121	"Farming of cattle, sheep, goats, horses, asses, mules and hinnies; dairy farming"
	122	"Other animal farming: production of animal products n.e.c."
	130	"Growing of crops combined with farming of animals (mixed farming)"
	140	"Agricultural and animal husbandry service activities, except veterinary activities"
	150	"Hunting, trapping and game propagation including related service activities"
	200	"Forestry, logging and related service activities"
	500	"Fishing, operation of fish hatcheries and fish farms: service activities incidental to fishing"
	1010	"Mining and agglomeration of hard coal"
	1020	"Mining and agglomeration of lignite"
	1030	"Extraction and agglomeration of peat"
	1110	"Extraction of crude petroleum and natural gas"
	1120	"Service activities incidental to oil and gas extraction excluding surveying"
	1200	"Mining of uranium and thorium ores"
	1310	"Mining of iron ores"
	1320	"Mining of non-ferrous metal ores, except uranium and thorium ores"
	1410	"Quarrying of stone, sand and clay"
	1421	"Mining of chemical and fertilizer minerals"
	1422	"Extraction of salt"
	1429	"Other mining and quarrying n.e.c."
	1511	"Production, processing and preserving of meat and meat products"
	1512	"Processing and preserving of fish and fish products"
	1513	"Processing and preserving of fruit and vegetables"
	1514	"Manufacture of vegetable and animal oils and fats"
	1520	"Manufacture of dairy products"
	1531	"Manufacture of grain mill products"
	1532	"Manufacture of starches and starch products"
	1533	"Manufacture of prepared animal feeds"
	1541	"Manufacture of bakery products"
	1542	"Manufacture of sugar"
	1543	"Manufacture of cocoa, chocolate and sugar confectionery"
	1544	"Manufacture of macaroni, noodles, couscous and similar farinaceous products"
	1549	"Manufacture of other food products n.e.c."
	1551	"Distilling, rectifying and blending of spirits: ethyl alcohol production from fermented materials"
	1552	"Manufacture of wines"
	1553	"Manufacture of malt liquors and malt"
	1554	"Manufacture of soft drinks production of mineral waters"
	1600	"Manufacture of tobacco products"
	1711	"Preparation and spinning of textile fibres; weaving of textiles"
	1712	"Finishing of textiles"
	1721	"Manufacture of made-up textile articles, except apparel"
	1722	"Manufacture of carpets and rugs"
	1723	"Manufacture of cordage, rope, twine and netting"
	1729	"Manufacture of other textiles n.e.c."
	1730	"Manufacture of knitted and crocheted fabrics and articles"
	1810	"Manufacture of wearing apparel, except fur apparel"
	1820	"Dressing and dyeing of fur: manufacture of articles"
	1911	"Tanning and dressing of leather"
	1912	"Manufacture of luggage, handbags and the like, saddlery and harness"
	1920	"Manufacture of footwear"
	2010	"Sawmilling and planing of wood"
	2021	"Manufacture of veneer sheets; Manufacture of plywood, laminboard, particle board and other panels and boards"
	2022	"Manufacture of builders' carpentry and joinery"
	2023	"Manufacture of wooden containers"
	2029	"Manufacture of other products of wood; manufacture of articles of cork, straw and plaiting materials"
	2101	"Manufacture of pulp, paper and paperboard"
	2102	"Manufacture of corrugated paper and paperboard and of containers of paper and paperboard"
	2109	"Manufacture of other articles of paper and paperboard"
	2211	"Publishing of books, brochures, musical books and other publications"
	2212	"Publishing of newspapers, journals and periodicals"
	2213	"Publishing of recorded media"
	2219	"Other publishing"
	2221	"Printing"
	2222	"Service activities related to printing"
	2230	"Reproduction of recorded media"
	2310	"Manufacture of coke oven products"
	2320	"Manufacture of refined petroleum products"
	2330	"Processing of nuclear fuel"
	2411	"Manufacture of basic chemicals, except fertilizers and nitrogen compounds"
	2412	"Manufacture of fertilizers and nitrogen compounds"
	2413	"Manufacture of plastic in primary and forms and of synthetic rubber"
	2421	"Manufacture of pesticides and other agro-chemical products"
	2422	"Manufacture of  paints, varnishes and similar coatings, printing ink and mastics"
	2423	"Manufacture of pharmaceuticals, medicinal chemicals and botanical products"
	2424	"Manufacture of soap and detergents, cleaning and polishing preparations, perfumes and toilet preparations"
	2429	"Manufacture of other chemical products n.e.c."
	2430	"Manufacture of man-made fibres"
	2511	"Manufacture of rubber tyres and tubes; retreading and rebuilding  of rubber tyres"
	2519	"Manufacture of other rubber products"
	2520	"Manufacture of plastic products"
	2610	"Manufacture of glass and glass products"
	2691	"Manufacture of  non-structural non-refractory ceramic ware"
	2692	"Manufacture of   refractory ceramic products"
	2693	"Manufacture of  structural non-refractory clay and ceramic products"
	2694	"Manufacture of  cement, lime and plaster"
	2695	"Manufacture of  articles of concrete, cement and plaster"
	2696	"Cutting, shaping and finishing of stone"
	2699	"Manufacture of  other non-metallic mineral products n.e.c."
	2710	"Manufacture of  basic iron and steel"
	2720	"Manufacture of basic precious and non-ferrous metals"
	2731	"Casting of iron and steel"
	2732	"Casting of non-ferrous metals"
	2811	"Manufacture of structural metal products"
	2812	"Manufacture of tanks, reservoirs and containers of metal"
	2813	"Manufacture of steam generators, except central heating hot water boilers"
	2891	"Forging, pressing, stamping and roll-forming of metal: power metallurgy"
	2892	"Treatment and coating of metals: general mechanical engineering on a fee or contract basis"
	2893	"Manufacture of cutlery, hand tools and general hardware"
	2899	"Manufacture of other fabricated metal products n.e.c."
	2911	"Manufacture of engines and turbines, except aircraft, vehicle and cycle engines"
	2912	"Manufacture of pumps, compressors, taps and valves"
	2913	"Manufacture of bearings, gears, gearing and driving elements"
	2914	"Manufacture of ovens, furnaces and furnace burners"
	2915	"Manufacture of lifting and handling equipment"
	2919	"Manufacture of  other general purpose machinery"
	2921	"Manufacture of  agricultural and forestry machinery"
	2922	"Manufacture of machine-tools"
	2923	"Manufacture of machinery for metallurgy"
	2924	"Manufacture of machinery for mining , quarrying and construction"
	2925	"Manufacture of machinery for food, beverage and tobacco processing"
	2926	"Manufacture of machinery for textile, apparel and leather production"
	2927	"Manufacture of  weapons and ammunition"
	2929	"Manufacture of other special purpose machinery"
	2930	"Manufacture of domestic appliances n.e.c."
	3000	"Manufacture of office, accounting and computing machinery"
	3110	"Manufacture of  electric motors, generators and transformers"
	3120	"Manufacture of  electricity distribution and control apparatus"
	3130	"Manufacture of  insulated wire and cable"
	3140	"Manufacture of  accumulators, primary cells and primary batteries"
	3150	"Manufacture of  electric lamps and lighting equipment"
	3190	"Manufacture of   other electrical equipment n.e.c."
	3210	"Manufacture of  electronic valves and tubes and other electronic components"
	3220	"Manufacture of  television and radio transmitters and apparatus for line telephony and line telegraphy"
	3230	"Manufacture of  television and radio receivers, sound or video recording or reproducing apparatus, and associated goods"
	3311	"Manufacture of   medical  and surgical equipment  and orthopaedic appliances"
	3312	"Manufacture of  instruments and appliances for measuring, checking, testing, navigating and other purposes, except industrial process control equipment"
	3313	"Manufacture of  industrial process control equipment"
	3320	"Manufacture of  optical instruments and photographic equipment"
	3330	"Manufacture of  watches and clocks"
	3410	"Manufacture of  motor vehicles"
	3420	"Manufacture of  bodies  (coachwork) for motor vehicles: manufacture of trailers and semi-trailers"
	3430	"Manufacture of  parts and accessories for motor vehicles and their engines"
	3511	"Building and repairing of ships"
	3512	"Building and repairing of pleasure and sporting boats"
	3520	"Manufacture of  railway and  tramway locomotives and rolling stock"
	3530	"Manufacture of  aircraft and spacecraft"
	3591	"Manufacture of  motorcycles"
	3592	"Manufacture of  bicycles and invalid carriages"
	3599	"Manufacture of  other transport equipment n.e.c."
	3610	"Manufacture of  furniture"
	3691	"Manufacture of  jewellery and related articles"
	3692	"Manufacture of  musical instruments"
	3693	"Manufacture of  sports goods"
	3694	"Manufacture of  games and toys"
	3699	"Other manufacturing n.e.c."
	3710	"Recycling of metal waste and scrap"
	3720	"Recycling of non-metal waste and scrap"
	4010	"Production, collection and distribution of electricity"
	4020	"Manufacture of gas; distribution of gaseous fuels through mains"
	4030	"Steam and hot water supply"
	4100	"Collection, purification and distribution of water"
	4510	"Site preparation"
	4520	"Building of complete constructions or parts thereof; civil engineering"
	4530	"Building installation"
	4540	"Building completion"
	4550	"Renting of construction or demolition equipment with operator"
	5010	"Sale of motor vehicles"
	5020	"Maintenance and repair of motor vehicles"
	5030	"Sale of motor vehicle parts and accessories"
	5040	"Sale, maintenance and repair of motorcycles and related parts and accessories"
	5050	"Retail sale of automotive fuel"
	5110	"Wholesale on a fee or contract basis"
	5121	"Wholesale of agricultural raw materials and live animals"
	5122	"Wholesale of food, beverages and tobacco"
	5131	"Wholesale of textiles, clothing and footwear"
	5139	"Wholesale of other household goods"
	5141	"Wholesale of solid, liquid and gaseous fuels and related products"
	5142	"Wholesale of metals and metal ores"
	5143	"Wholesale of  construction materials, hardware, plumbing and heating equipment and supplies"
	5149	"Wholesale of other intermediate products, waste and scrap"
	5150	"Wholesale of machinery, equipment and supplies"
	5190	"Other wholesale"
	5211	"Retail sale in non-specialized stores with food, beverages or tobacco predominating"
	5219	"Other retail sale in non-specialized stores"
	5220	"Retail sale of food, beverages and tobacco in specialized stores"
	5231	"Retail sale of pharmaceutical and medical goods, cosmetic and toilet articles"
	5232	"Retail sale of textiles, clothing, footwear and leather goods"
	5233	"Retail sale of household appliances, articles and equipment"
	5234	"Retail sale of hardware, paints and glass"
	5239	"Other retail sale in specialized stores"
	5240	"Retail sale of second-hand goods in stores"
	5251	"Retail sale via mail order houses"
	5252	"Retail sale via stalls and markets"
	5259	"Other non-store retail sale"
	5260	"Repair of personal and household goods"
	5510	"Hotels camping sites and other provision of short-stay accommodation"
	5520	"Restaurants, bars and canteens"
	6010	"Transport via railways"
	6021	"Other scheduled passenger land transport"
	6022	"Other non-scheduled passenger land transport"
	6023	"Freight transport by road"
	6030	"Transport via pipelines"
	6110	"Sea and coastal water transport"
	6120	"Inland water transport"
	6210	"Scheduled air transport"
	6220	"Non-scheduled air transport"
	6301	"Cargo handling"
	6302	"Storage and warehousing"
	6303	"Other supporting transport activities"
	6304	"Activities of travel agencies and tour operators; tourist assistance activities n.e.c."
	6309	"Activities of other transport agencies"
	6411	"National post activities"
	6412	"Courier activities other than national post"
	6420	"Telecommunications"
	6511	"Central banking"
	6519	"Other monetary intermediation"
	6591	"Financial leasing"
	6592	"Other credit granting"
	6599	"Other financial intermediation n.e.c."
	6601	"Life insurance"
	6602	"Pension funding"
	6603	"Non-life insurance"
	6711	"Administration of financial markets"
	6712	"Security dealing activities"
	6719	"Activities auxiliary to financial intermediation n.e.c."
	6720	"Activities auxiliary to insurance and pension funding"
	7010	"Real estate activities with own or leased property"
	7020	"Real estate activities on a fee or contract basis"
	7111	"Renting of land transport equipment"
	7112	"Renting of water transport equipment"
	7113	"Renting of air transport equipment"
	7121	"Renting of agricultural machinery and equipment"
	7122	"Renting of construction  and civil engineering machinery and equipment"
	7123	"Renting of office machinery and equipment (including computers)"
	7129	"Renting of other machinery and equipment n.e.c."
	7130	"Renting of personal and household goods n.e.c."
	7210	"Hardware consultancy"
	7220	"software consultancy and supply"
	7230	"Data processing"
	7240	"Data base activities"
	7250	"Maintenance and repair of office, accounting and computing machinery"
	7290	"Other computer related activities"
	7310	"Research and experimental development on natural sciences and engineering (NSE)"
	7320	"Research and experimental development on social sciences and humanities (SSH)"
	7411	"Legal activities"
	7412	"Accounting, book-keeping and auditing activities; tax consultancy"
	7413	"Market research and public opinion polling"
	7414	"Business and management consultancy activities"
	7421	"Architectural and engineering activities and related technical consultancy"
	7422	"Technical testing and analysis"
	7430	"Advertising"
	7491	"Labour recruitment and provision of personnel"
	7492	"Investigation and security activities"
	7493	"Building-cleaning activities"
	7494	"Photographic activities"
	7495	"Packaging activities"
	7499	"Other business activities n.e.c."
	7511	"General (overall) public service activities"
	7512	"Regulation of the activities of agencies that provide health care, education, cultural services and other social services, excluding social security"
	7513	"Regulation of and contribution to more efficient operation of business"
	7514	"Ancillary service activities for the Government as a whole"
	7521	"Foreign affairs"
	7522	"Defence activities"
	7523	"Public order and safety activities"
	7530	"Compulsory social security activities"
	8010	"Primary education"
	8021	"General secondary education"
	8022	"Technical and vocational secondary education"
	8030	"Higher education"
	8090	"Adult and other education"
	8511	"Hospital activities"
	8512	"Medical and dental practice activities"
	8519	"Other human health activities"
	8520	"Veterinary activities"
	8531	"Social work with accommodation"
	8532	"Social work without accommodation"
	9000	"Sewage and refuse disposal, sanitation and similar activities"
	9111	"Activities of business and employers' organizations"
	9112	"Activities of professional organization"
	9120	"Activities of trade unions"
	9191	"Activities of religious organization"
	9192	"Activities of political organizations"
	9199	"Activities of other membership organization n.e.c."
	9211	"Motion picture and video production and distribution"
	9212	"Motion picture projection"
	9213	"Radio and television activities"
	9214	"Dramatic arts, music and other arts activities"
	9219	"Other entertainment activities n.e.c."
	9220	"News agency activities"
	9231	"Library and archives activities"
	9232	"Museums activities and preservation of historical sites and buildings"
	9233	"Botanical and zoological gardens and nature reserves activities"
	9241	"Sporting activities"
	9249	"Other recreational activities"
	9301	"Washing and (dry-) cleaning of textile and fur products"
	9302	"Hairdressing and other beauty treatment"
	9303	"Funeral and related activities"
	9309	"Other service activities n.e.c."
	9500	"Private household with employed persons"
	9900	"Extra-territorial organizations and bodies"
	9999	"NOT STATED";
	#delimit cr
	la val industry_orig lblindustry_orig
	replace industry_orig=. if lstatus!=1
	la var industry_orig "Original industry code"
*</_industry_orig_>

** INDUSTRY CLASSIFICATION
*<_industry_>
	replace industry=int(industry/100)
	recode industry  (1/5=1) (10/14=2) (15/37=3) (40/41=4) (45=5) (50/55=6) (60/64=7) (65/74=8) (75=9) (80/99=10)
	label var industry "1 digit industry classification"
	replace industry=. if lstatus==2 | lstatus==3
	la de lblindustry 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transports and comnunications" 8 "Financial and business-oriented services" 9 "Public Administration" 10 "Other services, Unspecified"
	label values industry lblindustry
*</_industry_>



**ORIGINAL OCCUPATION CLASSIFICATION
*<_occup_orig_>
ren occupation1 occupation
	gen occup_orig=occupation
#delimit
label define lbloccup_orig 
	 110 "110 Armed forces" 
	 1000 "1000 Legislators, senior officials and managers" 
	 1100 "1100 Legislators and senior officials" 
	 1110 "1110 Legislators" 
	 1111 "1111 Legislators" 
	 1112 "1112 Ministers" 
	 1120 "1120 Senior government officials" 
	 1121 "1121 Senior Government Officials (not further specified)" 
	 1122 "1122 Senior Government Officials in Ministries and other Central  Government Organizations (Nomenklatura)" 
	 1123 "1123 Senior Government Officials in Ministries and other Central  Government Organizations (non-Nomenklatura)" 
	 1124 "1124 Local Government Officials - Nomenklatura" 
	 1125 "1125 Local Government Officials - Non-Nomenklatura" 
	 1130 "1130 Traditional chiefs and heads of villages" 
	 1140 "1140 Senior officials of special interest organizations" 
	 1141 "1141 Senior officials of political-party organisations" 
	 1142 "1142 Senior officials of employers', workers' and other economic-interest organisations" 
	 1143 "1143 Senior officials of humanitarian and other special-interest organisations" 
	 1150 "1150 Communist Party Officials" 
	 1151 "1151 Central Committee Members" 
	 1152 "1152 Central Committee Apparatus - Nomenklatura" 
	 1153 "1153 Central Committee Apparatus - Non-Nomenklatura" 
	 1154 "1154 Local Party Officials - Nomenklatura" 
	 1155 "1155 Local Party Officials - Non-Nomenklatura" 
	 1156 "1156 Party Officials in Economic Enterprises - Nomenklatura" 
	 1157 "1157 Party Officials in Economic Enterprises - Non-Nomenklatura" 
	 1158 "1158 Party Officials in Party Enterprises - Nomenklatura" 
	 1159 "1159 Party Officials in Party Enterprises - Non-Nomenklatura" 
	 1160 "1160 Administrators of Mass Organizations" 
	 1161 "1161 Trade Union Officials - Nomenklatura" 
	 1162 "1162 Trade Union Officials - Non-Nomenklatura" 
	 1163 "1163 Youth Organization Officials - Nomenklatura" 
	 1164 "1164 Youth Organization Officials - Non-Nomenklatura" 
	 1165 "1165 Administrators of Other Communist Mass Orgs - Nomenklatura" 
	 1166 "1166 Administrators of Other Communist Mass Orgs -  Non-Nomenklatura" 
	 1200 "1200 Corporate managers" 
	 1210 "1210 Directors and chief executives" 
	 1211 "1211 Directors and Chief Executives" 
	 1212 "1212 Deputy Directors, Chief Engineers and Chief Accountants" 
	 1220 "1220 Production and operations department managers" 
	 1221 "1221 Production and operations department managers in agriculture, hunting, forestry and fishing" 
	 1222 "1222 Production and operations department managers in manufacturing" 
	 1223 "1223 Production and operations department managers in construction" 
	 1224 "1224 Production and operations department managers in wholesale and retail trade" 
	 1225 "1225 Production and operations department managers in restaurants and hotels" 
	 1226 "1226 Production and operations department managers in transport, storage and communications" 
	 1227 "1227 Production and operations department managers in business services" 
	 1228 "1228 Production and operations department managers in personal care, cleaning and related services" 
	 1229 "1229 Production and operations department managers not elsewhere classified" 
	 1230 "1230 Other departmental managers" 
	 1231 "1231 Finance and administration department managers" 
	 1232 "1232 Personnel and industrial relations department managers" 
	 1233 "1233 Sales and marketing department managers" 
	 1234 "1234 Advertising and public relations department managers" 
	 1235 "1235 Supply and distribution department managers" 
	 1236 "1236 Computing services department managers" 
	 1237 "1237 Research and development department managers" 
	 1239 "1239 Other department managers not elsewhere classified" 
	 1240 "1240 [Office Manager]" 
	 1250 "1250 [Military Officers]" 
	 1251 "1251 [High Military Officers]" 
	 1252 "1252 [Lower Military Officers]" 
	 1300 "1300 General managers" 
	 1310 "1310 General managers" 
	 1311 "1311 General managers in agriculture, hunting, forestry/ and fishing" 
	 1312 "1312 General managers in manufacturing" 
	 1313 "1313 General managers in construction" 
	 1314 "1314 General managers in wholesale and retail trade" 
	 1315 "1315 General managers of restaurants and hotels" 
	 1316 "1316 General managers in transport, storage and communications" 
	 1317 "1317 General managers of business services" 
	 1318 "1318 General managers in personal care, cleaning and related services" 
	 1319 "1319 General managers not elsewhere classified" 
	 1320 "1320 Businessman/Trader/Entrepreneur, not further specified  [used only in Czech Republic and Slovakia]" 
	 2000 "2000 Professionals" 
	 2010 "2010 [Scientific, Cultural and Media Nomenklatura]" 
	 2011 "2011 Media Nomenklatura" 
	 2012 "2012 Scientific and Cultural Nomenklatura" 
	 2100 "2100 Physical, mathematical and engineering science professionals" 
	 2110 "2110 Physicists, chemists and related professionals" 
	 2111 "2111 Physicists and astronomers" 
	 2112 "2112 Meteorologists" 
	 2113 "2113 Chemists" 
	 2114 "2114 Geologists and geophysicists" 
	 2120 "2120 Mathematicians, statisticians and related professionals" 
	 2121 "2121 Mathematicians and related professionals" 
	 2122 "2122 Statisticians" 
	 2130 "2130 Computing professionals" 
	 2131 "2131 Computer systems designers and analysts" 
	 2132 "2132 Computer programmers" 
	 2139 "2139 Computing professionals not elsewhere classified" 
	 2140 "2140 Architects, engineers and related professionals" 
	 2141 "2141 Architects, town and traffic planners" 
	 2142 "2142 Civil engineers" 
	 2143 "2143 Electrical engineers" 
	 2144 "2144 Electronics and telecommunications engineers" 
	 2145 "2145 Mechanical engineers" 
	 2146 "2146 Chemical engineers" 
	 2147 "2147 Mining engineers, metallurgists and related professionals" 
	 2148 "2148 Cartographers and surveyors" 
	 2149 "2149 Architects, engineers and related professionals not elsewhere classified" 
	 2200 "2200 Life science and health professionals" 
	 2210 "2210 Life science professionals" 
	 2211 "2211 Biologists, botanists, zoologists and related professionals" 
	 2212 "2212 Pharmacologists, pathologists and related professionals" 
	 2213 "2213 Agronomists and related professionals" 
	 2220 "2220 Health professionals (except nursing)" 
	 2221 "2221 Medical doctors" 
	 2222 "2222 Dentists" 
	 2223 "2223 Veterinarians" 
	 2224 "2224 Pharmacists" 
	 2229 "2229 Health professionals (except nursing) not elsewhere classified" 
	 2230 "2230 Nursing and midwifery professionals" 
	 2300 "2300 Teaching professionals" 
	 2310 "2310 College, university and higher education teaching professionals" 
	 2320 "2320 Secondary education teaching professionals" 
	 2321 "2321 [Second Teacher, Academic Track]" 
	 2322 "2322 [Second Vocational Track]" 
	 2323 "2323 Middle School Teacher" 
	 2330 "2330 Primary and pre-primary education teaching professionals" 
	 2331 "2331 Primary education teaching professionals" 
	 2332 "2332 Pre-primary education teaching professionals" 
	 2340 "2340 Special education teaching professionals" 
	 2350 "2350 Other teaching professionals" 
	 2351 "2351 Education methods specialists" 
	 2352 "2352 School inspectors" 
	 2359 "2359 Other teaching professionals not elsewhere classified" 
	 2400 "2400 Other professionals" 
	 2410 "2410 Business professionals" 
	 2411 "2411 Accountants" 
	 2412 "2412 Personnel and careers professionals" 
	 2419 "2419 Business professionals not elsewhere classified" 
	 2420 "2420 Legal professionals" 
	 2421 "2421 Lawyers" 
	 2422 "2422 Judges" 
	 2429 "2429 Legal professionals not elsewhere classified" 
	 2430 "2430 Archivists, librarians and related information professionals" 
	 2431 "2431 Archivists and curators" 
	 2432 "2432 Librarians and related information professionals" 
	 2440 "2440 Social sciences and related professionals" 
	 2441 "2441 Economists" 
	 2442 "2442 Sociologists, anthropologists and related professionals" 
	 2443 "2443 Philosophers, historians and political scientists" 
	 2444 "2444 Philologists, translators and interpreters" 
	 2445 "2445 Psychologists" 
	 2446 "2446 Social work professionals" 
	 2450 "2450 Writers and creative or performing artists" 
	 2451 "2451 Authors, journalists and other writers" 
	 2452 "2452 Sculptors, painters and related artists" 
	 2453 "2453 Composers, musicians and singers" 
	 2454 "2454 Choreographers and dancers" 
	 2455 "2455 Film, stage and related actors and directors" 
	 2460 "2460 Religious professionals" 
	 3000 "3000 Technicians and associate professionals" 
	 3100 "3100 Physical and engineering science associate professionals" 
	 3110 "3110 Physical and engineering science technicians" 
	 3111 "3111 Chemical and physical science technicians" 
	 3112 "3112 Civil engineering technicians" 
	 3113 "3113 Electrical engineering technicians" 
	 3114 "3114 Electronics and telecommunications engineering technicians" 
	 3115 "3115 Mechanical engineering technicians" 
	 3116 "3116 Chemical engineering technicians" 
	 3117 "3117 Mining and metallurgical technicians" 
	 3118 "3118 Draughtspersons" 
	 3119 "3119 Physical and engineering science technicians not elsewhere classified" 
	 3120 "3120 Computer associate professionals" 
	 3121 "3121 Computer assistants" 
	 3122 "3122 Computer equipment operators" 
	 3123 "3123 Industrial robot controllers" 
	 3130 "3130 Optical and electronic equipment operators" 
	 3131 "3131 Photographers and image and sound recording equipment operators" 
	 3132 "3132 Broadcasting and telecommunications equipment operators" 
	 3133 "3133 Medical equipment operators" 
	 3139 "3139 Optical and electronic equipment operators not elsewhere classified" 
	 3140 "3140 Ship and aircraft controllers and technicians" 
	 3141 "3141 Ships' engineers" 
	 3142 "3142 Ships' deck officers and pilots" 
	 3143 "3143 Aircraft pilots and related associate professionals" 
	 3144 "3144 Air traffic controllers" 
	 3145 "3145 Air traffic safety technicians" 
	 3150 "3150 Safety and quality inspectors" 
	 3151 "3151 Building and fire inspectors" 
	 3152 "3152 Safety, health and quality inspectors" 
	 3200 "3200 Life science and health associate professionals" 
	 3210 "3210 Life science technicians and related associate professionals" 
	 3211 "3211 Life science technicians" 
	 3212 "3212 Agronomy and forestry technicians" 
	 3213 "3213 Farming and forestry advisers" 
	 3220 "3220 Modern health associate professionals (except nursing)" 
	 3221 "3221 Medical assistants" 
	 3222 "3222 Sanitarians" 
	 3223 "3223 Dieticians and nutritionists" 
	 3224 "3224 Optometrists and opticians" 
	 3225 "3225 Dental assistants" 
	 3226 "3226 Physiotherapists and related associate professionals" 
	 3227 "3227 Veterinary assistants" 
	 3228 "3228 Pharmaceutical assistants" 
	 3229 "3229 Modern health associate professionals (except nursing) not elsewhere classified" 
	 3230 "3230 Nursing and midwifery associate professionals" 
	 3231 "3231 Nursing associate professionals" 
	 3232 "3232 Midwifery associate professionals" 
	 3240 "3240 Traditional medicine practitioners and faith-healers" 
	 3241 "3241 Traditional medicine practitioners" 
	 3242 "3242 Faith healers" 
	 3300 "3300 Teaching associate professionals" 
	 3310 "3310 Primary education teaching associate professionals" 
	 3320 "3320 Pre-primary education teaching associate professionals" 
	 3330 "3330 Special education teaching associate professionals" 
	 3340 "3340 Other teaching associate professionals" 
	 3400 "3400 Other associate professionals" 
	 3410 "3410 Finance and sales associate professionals" 
	 3411 "3411 Securities and finance dealers and brokers" 
	 3412 "3412 Insurance representatives" 
	 3413 "3413 Estate agents" 
	 3414 "3414 Travel consultants and organisers" 
	 3415 "3415 Technical and commercial sales representatives" 
	 3416 "3416 Buyers" 
	 3417 "3417 Appraisers, valuers and auctioneers" 
	 3419 "3419 Finance and sales associate professionals not elsewhere classified" 
	 3420 "3420 Business services agents and trade brokers" 
	 3421 "3421 Trade brokers" 
	 3422 "3422 Clearing and forwarding agents" 
	 3423 "3423 Employment agents and labour contractors" 
	 3429 "3429 Business services agents and trade brokers not elsewhere classified" 
	 3430 "3430 Administrative associate professionals" 
	 3431 "3431 Administrative secretaries and related associate professionals" 
	 3432 "3432 Legal and related business associate professionals" 
	 3433 "3433 Bookkeepers" 
	 3434 "3434 Statistical, mathematical and related associate professionals" 
	 3439 "3439 Administrative associate professionals not elsewhere classified" 
	 3440 "3440 Customs, tax and related government associate professionals" 
	 3441 "3441 Customs and border inspectors" 
	 3442 "3442 Government tax and excise officials" 
	 3443 "3443 Government social benefits officials" 
	 3444 "3444 Government licensing officials" 
	 3449 "3449 Customs, tax and related government associate professionals not elsewhere classified" 
	 3450 "3450 Police inspectors and detectives" 
	 3451 "3451 [Police Inspectors-Detectives]" 
	 3452 "3452 [Armed Forces Low Officers]" 
	 3460 "3460 Social work associate professionals" 
	 3470 "3470 Artistic, entertainment and sports associate professionals" 
	 3471 "3471 Decorators and commercial designers" 
	 3472 "3472 Radio, television and other announcers" 
	 3473 "3473 Street, night-club and related musicians, singers and dancers" 
	 3474 "3474 Clowns, magicians, acrobats and related associate professionals" 
	 3475 "3475 Athletes, sportspersons and related associate professionals" 
	 3480 "3480 Religious associate professionals" 
	 4000 "4000 Clerks" 
	 4100 "4100 Office clerks" 
	 4110 "4110 Secretaries and keyboard-operating clerks" 
	 4111 "4111 Stenographers and typists" 
	 4112 "4112 Word-processor and related operators" 
	 4113 "4113 Data entry operators" 
	 4114 "4114 Calculating-machine operators" 
	 4115 "4115 Secretaries" 
	 4120 "4120 Numerical clerks" 
	 4121 "4121 Accounting and bookkeeping clerks" 
	 4122 "4122 Statistical and finance clerks" 
	 4130 "4130 Material-recording and transport clerks" 
	 4131 "4131 Stock clerks" 
	 4132 "4132 Production clerks" 
	 4133 "4133 Transport clerks" 
	 4140 "4140 Library, mail and related clerks" 
	 4141 "4141 Library and filing clerks" 
	 4142 "4142 Mail carriers and sorting clerks" 
	 4143 "4143 Coding, proof-reading and related clerks" 
	 4144 "4144 Scribes and related workers" 
	 4190 "4190 Other office clerks" 
	 4200 "4200 Customer service clerks" 
	 4210 "4210 Cashiers, tellers and related clerks" 
	 4211 "4211 Cashiers and ticket clerks" 
	 4212 "4212 Tellers and other counter clerks" 
	 4213 "4213 Bookmakers and croupiers" 
	 4214 "4214 Pawnbrokers and money-lenders" 
	 4215 "4215 Debt-collectors and related workers" 
	 4220 "4220 Client information clerks" 
	 4221 "4221 Travel agency and related clerks" 
	 4222 "4222 Receptionists and information clerks" 
	 4223 "4223 Telephone switchboard operators" 
	 5000 "5000 Service workers and shop and market sales workers" 
	 5100 "5100 Personal and protective services workers" 
	 5110 "5110 Travel attendants and related workers" 
	 5111 "5111 Travel attendants and travel stewards" 
	 5112 "5112 Transport conductors" 
	 5113 "5113 Travel guides" 
	 5120 "5120 Housekeeping and restaurant services workers" 
	 5121 "5121 Housekeepers and related workers" 
	 5122 "5122 Cooks" 
	 5123 "5123 Waiters, waitresses and bartenders" 
	 5130 "5130 Personal care and related workers" 
	 5131 "5131 Child-care workers" 
	 5132 "5132 Institution-based personal care workers" 
	 5133 "5133 Home-based personal care workers" 
	 5139 "5139 Personal care and related workers not elsewhere classified" 
	 5140 "5140 Other personal service workers" 
	 5141 "5141 Hairdressers, barbers, beauticians and related workers" 
	 5142 "5142 Companions and valets" 
	 5143 "5143 Undertakers and embalmers" 
	 5149 "5149 Other personal services workers not elsewhere classified" 
	 5150 "5150 Astrologers, fortune-tellers and related workers" 
	 5151 "5151 Astrologers and related workers" 
	 5152 "5152 Fortune-tellers, palmists and related workers" 
	 5160 "5160 Protective services workers" 
	 5161 "5161 Fire-Fighters" 
	 5162 "5162 Police officers" 
	 5163 "5163 Prison guards" 
	 5164 "5164 [Soldiers Low]" 
	 5169 "5169 Protective services workers not elsewhere classified" 
	 5200 "5200 Models, salespersons and demonstrators" 
	 5210 "5210 Fashion and other models" 
	 5220 "5220 Shop salespersons and demonstrators" 
	 5230 "5230 Stall and market salespersons" 
	 6000 "6000 Skilled agricultural and fishery workers" 
	 6100 "6100 Market-oriented skilled agricultural and fishery workers" 
	 6110 "6110 Market gardeners and crop growers" 
	 6111 "6111 Field crop and vegetable growers" 
	 6112 "6112 Tree and shrub crop growers" 
	 6113 "6113 Gardeners, horticultural and nursery growers" 
	 6114 "6114 Mixed-crop growers" 
	 6114 "6114 Mixed-Crop Growers" 
	 6120 "6120 Market-Oriented Animal Producers etc Workers" 
	 6121 "6121 Dairy and livestock producers" 
	 6122 "6122 Poultry producers" 
	 6123 "6123 Apiarists and sericulturists" 
	 6124 "6124 Mixed-animal producers" 
	 6129 "6129 Market-oriented animal producers and related workers not elsewhere classified" 
	 6130 "6130 Market-oriented crop and animal producers" 
	 6131 "6131 [Mixed Farmers]" 
	 6132 "6132 [Farm Foremen/Supervisors]" 
	 6133 "6133 [Undocumented Farm]" 
	 6140 "6140 Forestry and related workers" 
	 6141 "6141 Forestry workers and loggers" 
	 6142 "6142 Charcoal burners and related workers" 
	 6150 "6150 Fishery workers, hunters and trappers" 
	 6151 "6151 Aquatic-life cultivation workers" 
	 6152 "6152 Inland and coastal waters fishery workers" 
	 6153 "6153 Deep-sea fishery workers" 
	 6154 "6154 Hunters and trappers" 
	 6160 "6160 Farmer, not further specified" 
	 6200 "6200 Subsistence agricultural and fishery workers" 
	 6210 "6210 Subsistence agricultural and fishery workers" 
	 7000 "7000 Craft and related trades workers" 
	 7100 "7100 Extraction and building trade workers" 
	 7110 "7110 Miners, shot-firers, stonecutters and carvers" 
	 7111 "7111 Miners and quarry workers" 
	 7112 "7112 Shotfirers and blasters" 
	 7113 "7113 Stone splitters, cutters and carvers" 
	 7120 "7120 Building frame and related trades workers" 
	 7121 "7121 Builders, traditional materials" 
	 7122 "7122 Bricklayers and stonemasons" 
	 7123 "7123 Concrete placers, concrete finishers and related workers" 
	 7124 "7124 Carpenters and joiners" 
	 7129 "7129 Building frame and related trades workers not elsewhere classified" 
	 7130 "7130 Building finishers and related trades workers" 
	 7131 "7131 Roofers" 
	 7132 "7132 Floor layers and tile setters" 
	 7133 "7133 Plasterers" 
	 7134 "7134 Insulation workers" 
	 7135 "7135 Glaziers" 
	 7136 "7136 Plumbers and pipe fitters" 
	 7137 "7137 Building and related electricians" 
	 7140 "7140 Painters, building structure cleaners and related trade workers" 
	 7141 "7141 Painters and related workers" 
	 7142 "7142 Varnishers and related painters" 
	 7143 "7143 Building structure cleaners" 
	 7200 "7200 Metal, machinery and related trades workers" 
	 7210 "7210 Metal moulders, welders, sheet-metalworkers, structural-metal preparers and related trades workers" 
	 7211 "7211 Metal moulders and coremakers" 
	 7212 "7212 Welders and flamecutters" 
	 7213 "7213 Sheet metal workers" 
	 7214 "7214 Structural-metal preparers and erectors" 
	 7215 "7215 Riggers and cable splicers" 
	 7216 "7216 Underwater workers" 
	 7220 "7220 Blacksmiths, toolmakers and related trades workers" 
	 7221 "7221 Blacksmiths, hammer-smiths and forging-press workers" 
	 7222 "7222 Tool-makers and related workers" 
	 7223 "7223 Machine-tool setters and setter-operators" 
	 7224 "7224 Metal wheel-grinders, polishers and tool sharpeners" 
	 7230 "7230 Machinery mechanics and fitters" 
	 7231 "7231 Motor vehicle mechanics and fitters" 
	 7232 "7232 Aircraft engine mechanics and fitters" 
	 7233 "7233 Agricultural- or industrial-machinery mechanics and fitters" 
	 7234 "7234 Oilers and Greasers" 
	 7240 "7240 Electrical and electronic equipment mechanics and fitters" 
	 7241 "7241 Electrical mechanics and fitters" 
	 7242 "7242 Electronics fitters" 
	 7243 "7243 Electronics mechanics and servicers" 
	 7244 "7244 Telegraph and telephone installers and servicers" 
	 7245 "7245 Electrical line installers, repairers and cable jointers" 
	 7300 "7300 Precision, handicraft, printing and related trades workers" 
	 7310 "7310 Precision workers in metal and related materials" 
	 7311 "7311 Precision-instrument makers and repairers" 
	 7312 "7312 Musical instrument makers and tuners" 
	 7313 "7313 Jewellery and precious-metal workers" 
	 7320 "7320 Potters, glass-makers and related trades workers" 
	 7321 "7321 Abrasive wheel formers, potters and related workers" 
	 7322 "7322 Glass makers, cutters, grinders and finishers" 
	 7323 "7323 Glass engravers and etchers" 
	 7324 "7324 Glass, ceramics and related decorative painters" 
	 7330 "7330 Handicraft workers in wood, textile, leather and related materials" 
	 7331 "7331 Handicraft workers in wood and related materials" 
	 7332 "7332 Handicraft workers in textile, leather and related materials" 
	 7340 "7340 Printing and related trades workers" 
	 7341 "7341 Compositors, typesetters and related workers" 
	 7342 "7342 Stereotypers and electrotypers" 
	 7343 "7343 Printing engravers and etchers" 
	 7344 "7344 Photographic and related workers" 
	 7345 "7345 Bookbinders and related workers" 
	 7346 "7346 Silk-screen, block and textile printers" 
	 7400 "7400 Other craft and related trades workers" 
	 7410 "7410 Food processing and related trades workers" 
	 7411 "7411 Butchers, fishmongers and related food preparers" 
	 7412 "7412 Bakers, pastry-cooks and confectionery makers" 
	 7413 "7413 Dairy-products makers" 
	 7414 "7414 Fruit, vegetable and related preservers" 
	 7415 "7415 Food and beverage tasters and graders" 
	 7416 "7416 Tobacco preparers and tobacco products makers" 
	 7420 "7420 Wood treaters, cabinet-makers and related trades workers" 
	 7421 "7421 Wood treaters" 
	 7422 "7422 Cabinet makers and related workers" 
	 7423 "7423 Woodworking machine setters and setter-operators" 
	 7424 "7424 Basketry weavers, brush makers and related workers" 
	 7430 "7430 Textile, garment and related trades workers" 
	 7431 "7431 Fibre preparers" 
	 7432 "7432 Weavers, knitters and related workers" 
	 7433 "7433 Tailors, dressmakers and hatters" 
	 7434 "7434 Furriers and related workers" 
	 7435 "7435 Textile, leather and related pattern-makers and cutters" 
	 7436 "7436 Sewers, embroiderers and related workers" 
	 7437 "7437 Upholsterers and related workers" 
	 7440 "7440 Felt, leather and shoemaking trades workers" 
	 7441 "7441 Pelt dressers, tanners and fellmongers" 
	 7442 "7442 Shoe-makers and related workers" 
	 7500 "7500 [Generic Skilled Manual Worker]" 
	 7510 "7510 [Non Farm Foremen Nfs]" 
	 7520 "7520 [Skilled Manual]" 
	 7530 "7530 [Apprentice]" 
	 8000 "8000 Plant and machine operators and assemblers" 
	 8100 "8100 Stationary plant and related operators" 
	 8110 "8110 Mining and mineral-processing plant operators" 
	 8111 "8111 Mining-plant operators" 
	 8112 "8112 Mineral-ore- and stone-processing-plant operators" 
	 8113 "8113 Well drillers and borers and related workers" 
	 8120 "8120 Metal-processing plant operators" 
	 8121 "8121 Ore and metal furnace operators" 
	 8122 "8122 Metal melters, casters and rolling-mill operators" 
	 8123 "8123 Metal-heat-treating-plant operators" 
	 8124 "8124 Metal drawers and extruders" 
	 8130 "8130 Glass, ceramics and related plant operators" 
	 8131 "8131 Glass and ceramics kiln and related machine operators" 
	 8139 "8139 Glass, ceramics and related plant operators not elsewhere classified" 
	 8140 "8140 Wood processing and papermaking plant operators" 
	 8141 "8141 Wood-processing-plant operators" 
	 8142 "8142 Paper-pulp plant operators" 
	 8143 "8143 Papermaking-plant operators" 
	 8150 "8150 Chemical processing plant operators" 
	 8151 "8151 Crushing-, grinding- and chemical-mixing-machinery operators" 
	 8152 "8152 Chemical-heat-treating-plant operators" 
	 8153 "8153 Chemical-filtering- and separating-equipment operators" 
	 8154 "8154 Chemical-still and reactor operators (except petroleum and natural gas)" 
	 8155 "8155 Petroleum- and natural-gas-refining-plant operators" 
	 8159 "8159 Chemical-processing-plant operators not elsewhere classified" 
	 8160 "8160 Power production and related plant operators" 
	 8160 "8160 Power-Production etc Plant Operators" 
	 8161 "8161 Power-Production Plant Operators" 
	 8162 "8162 Steam-engine and boiler operators" 
	 8163 "8163 Incinerator, water-treatment and related plant operators" 
	 8170 "8170 Automated assembly-line and industrial robot operators" 
	 8171 "8171 Automated-assembly-line operators" 
	 8172 "8172 Industrial-robot operators" 
	 8200 "8200 Machine operators and assemblers" 
	 8210 "8210 Metal and mineral products machine operators" 
	 8211 "8211 Machine-tool operators" 
	 8212 "8212 Cement and other mineral products machine operators" 
	 8220 "8220 Chemical products machine operators" 
	 8221 "8221 Pharmaceutical- and toiletry-products machine operators" 
	 8222 "8222 Ammunition- and explosive-products machine operators" 
	 8223 "8223 Metal finishing-, plating- and coating-machine operators" 
	 8224 "8224 Photographic-products machine operators" 
	 8229 "8229 Chemical-products machine operators not elsewhere classified" 
	 8230 "8230 Rubber and plastic products machine operators" 
	 8231 "8231 Rubber-products machine operators" 
	 8232 "8232 Plastic-products machine operators" 
	 8240 "8240 Wood products machine operators" 
	 8250 "8250 Printing, binding and paper products machine operators" 
	 8251 "8251 Printing-machine operators" 
	 8252 "8252 Bookbinding-machine operators" 
	 8253 "8253 Paper-products machine operators" 
	 8260 "8260 Textile, fur and leather products machine operators" 
	 8261 "8261 Fibre-preparing-, spinning- and winding-machine operators" 
	 8262 "8262 Weaving- and knitting-machine operators" 
	 8263 "8263 Sewing-machine operators" 
	 8264 "8264 Bleaching-, dyeing- and cleaning-machine operators" 
	 8265 "8265 Fur- and leather-preparing-machine operators" 
	 8266 "8266 Shoemaking- and related machine operators" 
	 8269 "8269 Textile-, fur- and leather-products machine operators not elsewhere classified" 
	 8270 "8270 Food and related products machine operators" 
	 8271 "8271 Meat- and fish-processing-machine operators" 
	 8272 "8272 Dairy-products machine operators" 
	 8273 "8273 Grain- and spice-milling-machine operators" 
	 8274 "8274 Baked-goods, cereal and chocolate-products machine operators" 
	 8275 "8275 Fruit-, vegetable- and nut-processing-machine operators" 
	 8276 "8276 Sugar production machine operators" 
	 8277 "8277 Tea-, coffee-, and cocoa-processing-machine operators" 
	 8278 "8278 Brewers, wine and other beverage machine operators" 
	 8279 "8279 Tobacco production machine operators" 
	 8280 "8280 Assemblers" 
	 8281 "8281 Mechanical-machinery assemblers" 
	 8282 "8282 Electrical-equipment assemblers" 
	 8283 "8283 Electronic-equipment assemblers" 
	 8284 "8284 Metal-, rubber- and plastic-products assemblers" 
	 8285 "8285 Wood and related products assemblers" 
	 8286 "8286 Paperboard, textile and related products assemblers" 
	 8290 "8290 Other machine operators and assemblers" 
	 8300 "8300 Drivers and mobile plant operators" 
	 8310 "8310 Locomotive engine-drivers and related workers" 
	 8311 "8311 Locomotive-engine drivers" 
	 8312 "8312 Railway brakers, signallers and shunters" 
	 8320 "8320 Motor vehicle drivers" 
	 8321 "8321 Motor-cycle drivers" 
	 8322 "8322 Car, taxi and van drivers" 
	 8323 "8323 Bus and tram drivers" 
	 8324 "8324 Heavy-truck and lorry drivers" 
	 8330 "8330 Agricultural and other mobile plant operators" 
	 8331 "8331 Motorised farm and forestry plant operators" 
	 8332 "8332 Earth-moving- and related plant operators" 
	 8333 "8333 Crane, hoist and related plant operators" 
	 8334 "8334 Lifting-truck operators" 
	 8340 "8340 Ships' deck crews and related workers" 
	 8400 "8400 [Semi-skilled Worker]" 
	 9000 "9000 Elementary occupations" 
	 9100 "9100 Sales and services elementary occupations" 
	 9110 "9110 Street vendors and related workers" 
	 9111 "9111 Street food vendors" 
	 9112 "9112 Street vendors, non-food products" 
	 9113 "9113 Door-to-door and telephone salespersons" 
	 9120 "9120 Shoe cleaning and other street services' elementary occupations" 
	 9130 "9130 Domestic and related helpers, cleaners and launderers" 
	 9131 "9131 Domestic helpers and cleaners" 
	 9132 "9132 Helpers and cleaners in offices, hotels and other establishments" 
	 9133 "9133 Hand-launderers and pressers" 
	 9140 "9140 Building caretakers, window and related cleaners" 
	 9141 "9141 Building caretakers" 
	 9142 "9142 Vehicle, window and related cleaners" 
	 9150 "9150 Messengers, porters, doorkeepers and related workers" 
	 9151 "9151 Messengers, package and luggage porters and deliverers" 
	 9152 "9152 Doorkeepers, watchpersons and related workers" 
	 9153 "9153 Vending-machine money collectors, meter readers and related workers" 
	 9160 "9160 Garbage collectors and related labourers" 
	 9161 "9161 Garbage collectors" 
	 9162 "9162 Sweepers and related labourers" 
	 9200 "9200 Agricultural, fishery and related labourers" 
	 9210 "9210 Agricultural, fishery and related labourers" 
	 9211 "9211 Farm-hands and labourers" 
	 9212 "9212 Forestry labourers" 
	 9213 "9213 Fishery, hunting and trapping labourers" 
	 9300 "9300 Labourers in mining, construction, manufacturing and transport" 
	 9310 "9310 Mining and construction labourers" 
	 9311 "9311 Mining and quarrying labourers" 
	 9312 "9312 Construction and maintenance labourers: roads, dams and similar constructions" 
	 9313 "9313 Building construction labourers" 
	 9320 "9320 Manufacturing labourers" 
	 9321 "9321 Assembling labourers" 
	 9322 "9322 Hand packers and other manufacturing labourers" 
	 9330 "9330 Transport labourers and freight handlers" 
	 9331 "9331 Hand or pedal vehicle drivers" 
	 9332 "9332 Drivers of animal-drawn vehicles and machinery" 
	 9333 "9333 Freight handlers"
	 9999	"NOT STATED";
 #delimit cr
	la val occup_orig lbloccup_orig
	replace occup_orig=. if lstatus!=1
	la var occup_orig "Original occupation code"
*</_occup_orig_>

** OCCUPATION CLASSIFICATION
*<_occup_>
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
	gen whours=hrsworked1
	replace whours=. if lstatus==2 | lstatus==3
	label var whours "Hours of work in last week"
*</_whours_>


** WAGES
*<_wage_>
	gen double wage=.
	replace wage=. if lstatus==2 | lstatus==3
	replace wage=0 if empstat==2
	label var wage "Last wage payment"
*</_wage_>


** WAGES TIME UNIT
*<_unitwage_>
	gen byte unitwage=.
	label var unitwage "Last wages time unit"
	replace unitwage=. if lstatus==2 | lstatus==3
	la de lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Quarterly" 7 "Biannual" 8 "Annually" 9 "Hourly" 10 "Other"
	label values unitwage lblunitwage
*</_wageunit_>


** EMPLOYMENT STATUS - SECOND JOB
*<_empstat_2_>
	recode empstatus2 (1=3) (2=1) (3=4) (5 = 2) (4= 2), gen(empstat_2)
	replace empstat_2=. if njobs==0 | njobs==.
	label var empstat_2 "Employment status - second job"
	la de lblempstat_2 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat_2 lblempstat_2
*</_empstat_2_>

** EMPLOYMENT STATUS - SECOND JOB LAST YEAR
*<_empstat_2_year_>
	gen byte empstat_2_year=.
	replace empstat_2_year=. if njobs_year==0 | njobs_year==.
	label var empstat_2_year "Employment status - second job"
	la de lblempstat_2_year 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat_2 lblempstat_2
*</_empstat_2_>

** INDUSTRY CLASSIFICATION - SECOND JOB
*<_industry_2_>
	gen byte industry_2=int(industry2/100)
	recode industry_2  (1/5=1) (10/14=2) (15/37=3) (40/41=4) (45=5) (50/55=6) (60/64=7) (65/74=8) (75=9) (80/99=10)
	replace industry_2=. if njobs==0 | njobs==.
	label var industry_2 "1 digit industry classification - second job"
	la de lblindustry_2 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Comnunications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industry_2 lblindustry
*<_industry_2_>


**SURVEY SPECIFIC INDUSTRY CLASSIFICATION - SECOND JOB
*<_industry_orig_2_>
	gen industry_orig_2=industry2
	replace industry_orig_2=. if njobs==0 | njobs==.
	label var industry_orig_2 "Original Industry Codes - Second job"
	la de lblindustry_orig_2 1""
	label values industry_orig_2 lblindustry_orig
*</_industry_orig_2>

** OCCUPATION CLASSIFICATION - SECOND JOB
*<_occup_2_>
	gen byte occup_2=int(occupation2/100)
	recode occup_2 (0/10=10) (11/19=1) (21/29=2) (31/39=3) (41/49=4) (51/59=5) (61/69=6) (71/79=7) (81/89=8) (91/99=9)
	replace occup_2=. if njobs==0 | njobs==.
	label var occup_2 "1 digit occupational classification - second job"
	la de lbloccup_2 1 "Senior officials" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup_2 lbloccup_2
*</_occup_2_>


** WAGES - SECOND JOB
*<_wage_2_>
	gen double wage_2=.
	replace wage_2=. if njobs==0 | njobs==.
	label var wage_2 "Last wage payment - Second job"
*</_wage_2_>


** WAGES TIME UNIT - SECOND JOB
*<_unitwage_2_>
	gen byte unitwage_2=.
	replace unitwage_2=. if njobs==0 | njobs==.
	label var unitwage_2 "Last wages time unit - Second job"
	la de lblunitwage_2 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Every two months"  5 "Monthly" 6 "Quarterly" 7 "Every six months" 8 "Annually" 9 "Hourly" 10 "Other"
	label values unitwage_2 lblunitwage_2
*</_unitwage_2_>

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
                                   MIGRATION MODULE
*                                                                                                    *
*****************************************************************************************************/


**REGION OF BIRTH JURISDICTION
*<_rbirth_juris_>
	gen byte rbirth_juris=4 if nationality==2
	label var rbirth_juris "Region of birth jurisdiction"
	la de lblrbirth_juris 1 "subnatid1" 2 "subnatid2" 3 "subnatid3" 4 "Other country"  9 "Other code"
	label values rbirth_juris lblrbirth_juris
*</_rbirth_juris_>

**REGION OF BIRTH
*<_rbirth_>
	gen  rbirth=999 if nationality==2
	label var rbirth "Region of Birth"
*</_rbirth_>

** REGION OF PREVIOUS RESIDENCE JURISDICTION
*<_rprevious_juris_>
	gen byte rprevious_juris=.
	label var rprevious_juris "Region of previous residence jurisdiction"
	la de lblrprevious_juris 1 "reg01" 2 "reg02" 3 "reg03" 4 "Other country"  9 "Other code"
	label values rprevious_juris lblrprevious_juris
*</_rprevious_juris_>

**REGION OF PREVIOUS RESIDENCE
*<_rprevious_>
	gen byte rprevious=.
	label var rprevious "Region of previous residence"
*</_rprevious_>

** YEAR OF MOST RECENT MOVE
*<_yrmove_>
	gen int yrmove=.
	label var yrmove "Year of most recent move"
*</_yrmove_>

/*****************************************************************************************************
*                                                                                                    *
                                            ASSETS 
*                                                                                                    *
*****************************************************************************************************/

** LAND PHONE
*<_landphone_>
	gen byte landphone= numitemsTELEPHONE>0 & numitemsTELEPHONE<.
	label var landphone "Household has landphone"
	la de lbllandphone 0 "No" 1 "Yes"
	label values landphone lbllandphone
*</_landphone_>


** CEL PHONE
*<_cellphone_>

	gen cellphone=numitemsMOBILE_PHONE & numitemsMOBILE_PHONE<.  
	label var cellphone "Household has Cell phone"
	la de lblcellphone 0 "No" 1 "Yes"
	label values cellphone lblcellphone
*</_cellphone_>


** COMPUTER
*<_computer_>
	gen byte computer=numitemsCOMPUTER>0 & numitemsCOMPUTER<.
	label var computer "Household has computer"
	la de lblcomputer 0 "No" 1 "Yes"
	label values computer lblcomputer
*</_computer_>

** RADIO
*<_radio_>
	gen radio= numitemsRADIO>0 &  numitemsRADIO<.
	label var radio "Household has radio"
	la de lblradio 0 "No" 1 "Yes"
	label val radio lblradio
*</_radio_>

** TELEVISION
*<_television_>
	gen television= numitemsTV>0 &  numitemsTV<.
	label var television "Household has Television"
	la de lbltelevision 0 "No" 1 "Yes"
	label val television lbltelevision
*</_television>

** FAN
*<_fan_>
	gen fan= numitemsFAN>0 &  numitemsFAN<.
	label var fan "Household has Fan"
	la de lblfan 0 "No" 1 "Yes"
	label val fan lblfan
*</_fan>

** SEWING MACHINE
*<_sewingmachine_>
	gen sewingmachine=numitemsSEWING_MACHINE>0 & numitemsSEWING_MACHINE<.
	label var sewingmachine "Household has Sewing machine"
	la de lblsewingmachine 0 "No" 1 "Yes"
	label val sewingmachine lblsewingmachine
*</_sewingmachine>

** WASHING MACHINE
*<_washingmachine_>
	gen washingmachine=numitemsWASHING_MACHINE>0 & numitemsWASHING_MACHINE<.
	label var washingmachine "Household has Washing machine"
	la de lblwashingmachine 0 "No" 1 "Yes"
	label val washingmachine lblwashingmachine
*</_washingmachine>

** REFRIGERATOR
*<_refrigerator_>
	gen refrigerator=numitemsREFRIGERATOR___FRIDGE>0 & numitemsREFRIGERATOR___FRIDGE<.
	label var refrigerator "Household has Refrigerator"
	la de lblrefrigerator 0 "No" 1 "Yes"
	label val refrigerator lblrefrigerator
*</_refrigerator>

** LAMP
*<_lamp_>
	gen lamp=.
	label var lamp "Household has Lamp"
	la de lbllamp 0 "No" 1 "Yes"
	label val lamp lbllamp
*</_lamp>

** BYCICLE
*<_bycicle_>
	gen bicycle= numitemsBICYCLE>0 &  numitemsBICYCLE<.
	label var bicycle "Household has Bicycle"
	la de lblbycicle 0 "No" 1 "Yes"
	label val bicycle lblbycicle
*</_bycicle>

** MOTORCYCLE
*<_motorcycle_>
	gen motorcycle=.
	label var motorcycle "Household has Motorcycle"
	la de lblmotorcycle 0 "No" 1 "Yes"
	label val motorcycle lblmotorcycle
*</_motorcycle>

** MOTOR CAR
*<_motorcar_>
	gen motorcar= numitemsCAR>0 &  numitemsCAR<.
	label var motorcar "Household has Motor car"
	la de lblmotorcar 0 "No" 1 "Yes"
	label val motorcar lblmotorcar
*</_motorcar>

** COW
*<_cow_>
	gen cow=.
	label var cow "Household has Cow"
	la de lblcow 0 "No" 1 "Yes"
	label val cow lblcow
*</_cow>

** BUFFALO
*<_buffalo_>
	gen buffalo=.
	label var buffalo "Household has Buffalo"
	la de lblbuffalo 0 "No" 1 "Yes"
	label val buffalo lblbuffalo
*</_buffalo>

** CHICKEN
*<_chicken_>
	gen chicken=.
	label var chicken "Household has Chicken"
	la de lblchicken 0 "No" 1 "Yes"
	label val chicken lblchicken
*</_chicken>
	

/*****************************************************************************************************
*                                                                                                    *
*                                   WELFARE MODULE
*                                                                                                    *
*****************************************************************************************************/

/*
local i=1
foreach x in pce pcer{
foreach y in ztot zt zfood{

gen p`i'=`x'<`y' if `x'!=.
tab p`i' [aw=wgt]
local i=`i'+1
}
}
*/

** SPATIAL DEFLATOR
*<_spdef_>
	gen spdef=spi6 /*This is a regional food index. spi2 is the total spatial index*/ 
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
	gen welfarenat=pcerr_2009/cpi2009
	la var welfarenat "Welfare aggregate for national poverty"
*</_welfarenat_>	


*QUINTILE, DECILE AND FOOD/NON-FOOD SHARES OF CONSUMPTION AGGREGATE
	levelsof year, loc(y)
	merge m:1 idh using "$shares\\MDV_fnf_`y'", keepusing (food_share nfood_share quintile_cons_aggregate decile_cons_aggregate)
	drop _merge


/*****************************************************************************************************
*                                                                                                    *
                                   NATIONAL POVERTY
*                                                                                                    *
*****************************************************************************************************/

** POVERTY LINE (NATIONAL)
*<_pline_nat_>
	gen pline_nat=787.44189/cpi2009
	label variable pline_nat "Poverty Line (National)"
*</_pline_nat_>


** HEADCOUNT RATIO (NATIONAL)
*<_poor_nat_>
	gen poor_nat=welfarenat<pline_nat & welfaredef!=.
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
	do "$fixlabels\fixlabels", nostop

	keep countrycode year survey idh idp wgt pop_wgt strata psu vermast veralt urban int_month int_year  ///
		subnatid1 subnatid2 subnatid3 ownhouse landholding tenure water electricity toilet landphone cellphone ///
	     computer internet hsize relationharm relationcs male age soc marital ed_mod_age everattend ///
	     atschool electricity literacy educy educat4 educat5 educat7 lb_mod_age lstatus lstatus_year empstat empstat_year njobs njobs_year ///
	     ocusec nlfreason unempldur_l unempldur_u industry_orig industry occup_orig occup firmsize_l firmsize_u whours wage ///
		  unitwage empstat_2 empstat_2_year industry_2 industry_orig_2 occup_2 wage_2 unitwage_2 contract healthins socialsec union rbirth_juris rbirth rprevious_juris rprevious yrmove ///
		 landphone cellphone computer radio television fan sewingmachine washingmachine refrigerator lamp bicycle motorcycle motorcar cow buffalo chicken  ///
		 pline_nat pline_int poor_nat poor_int spdef cpi ppp cpiperiod welfare welfshprosperity welfarenom welfaredef welfarenat food_share nfood_share quintile_cons_aggregate decile_cons_aggregate welfareother welfaretype welfareothertype  
		 

** ORDER VARIABLES

	order countrycode year survey idh idp wgt pop_wgt strata psu vermast veralt urban int_month int_year  ///
		subnatid1 subnatid2 subnatid3 ownhouse landholding tenure water electricity toilet landphone cellphone ///
	     computer internet hsize relationharm relationcs male age soc marital ed_mod_age everattend ///
	     atschool electricity literacy educy educat4 educat5 educat7 lb_mod_age lstatus lstatus_year empstat empstat_year njobs njobs_year ///
	     ocusec nlfreason unempldur_l unempldur_u industry_orig industry occup_orig occup firmsize_l firmsize_u whours wage ///
		  unitwage empstat_2 empstat_2_year industry_2 industry_orig_2 occup_2 wage_2 unitwage_2 contract healthins socialsec union rbirth_juris rbirth rprevious_juris rprevious yrmove ///
		 landphone cellphone computer radio television fan sewingmachine washingmachine refrigerator lamp bicycle motorcycle motorcar cow buffalo chicken  ///
		 pline_nat pline_int poor_nat poor_int spdef cpi ppp cpiperiod welfare welfshprosperity welfarenom welfaredef welfarenat food_share nfood_share quintile_cons_aggregate decile_cons_aggregate welfareother welfaretype welfareothertype  

	
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
	keep countrycode year survey idh idp wgt pop_wgt strata psu vermast veralt `keep' *type

	compress


	saveold "`output'\Data\Harmonized\MDV_2002_HIES_v01_M_v03_A_SARMD-FULL_IND.dta", replace version(12)
	saveold "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\__REGIONAL\Individual Files\MDV_2002_HIES_v01_M_v03_A_SARMD-FULL_IND.dta", replace version(12)
	
	notes

	log close

*********************************************************************************************************************************	
******RENAME COMPARABLE VARIABLES AND SAVE THEM IN _SARMD. UNCOMPARABLE VARIALBES ACROSS TIME SHOULD BE FOUND IN _SARMD-FULL*****
*********************************************************************************************************************************

loc var lb_mod_age industry njobs  relationharm lstatus lstatus_year empstat empstat_year ocusec nlfreason unempldur_l unempldur_u industry_orig ///
occup whours wage unitwage empstat_2 empstat_2_year industry_2 occup_2 wage_2 unitwage_2 contract healthins socialsec union
foreach i of loc var{

cap sum `i'

	if _rc==0{
	loc a: var label `i'
	la var `i' "`a'-old non-comparable version"
	cap rename `i' `i'_v2
	}
	else if _rc==111{
	dis as error "Variable `i' does not exist in data-base"
	}
	
}
note _dta: "MDV 2002" Variables NAMED with "v2" are those not compatible with latest round (2009). ///
note _dta: "MDV 2002" Due to changes in questionnaire and screening process, labor variables are not comparable with latest round.	
note _dta: "MDV 2002" Due to changes in questionnaire variable 'relationharm' is not comparable with latest round

saveold "`output'\Data\Harmonized\MDV_2002_HIES_v01_M_v03_A_SARMD_IND.dta", replace version(12)
saveold "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\__REGIONAL\Individual Files\MDV_2002_HIES_v01_M_v03_A_SARMD_IND.dta", replace version(12)
	
	
******************************  END OF DO-FILE  *****************************************************/
