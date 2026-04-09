/*****************************************************************************************************
******************************************************************************************************
**                                                                                                  **
**                                   SOUTH ASIA MICRO DATABASE                                      **
**                                                                                                  **
** COUNTRY			NEPAL
** COUNTRY ISO CODE	NPL
** YEAR	2010
** SURVEY NAME		Nepal Living Standards Survey – III 2010
** SURVEY AGENCY	Central Bureau of Statistics
** RESPONSIBLE		Triana Yentzen
** MODIFIED BY		Fernando Enrique Morales Velandia
** Date				02/18/2018
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
	local output "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\NPL\NPL_2010_LSS-III\NPL_2010_LSS-III_v01_M_v04_A_SARMD"
	glo pricedata "D:\SOUTH ASIA MICRO DATABASE\CPI\cpi_ppp_sarmd_weighted.dta"
	glo shares "D:\SOUTH ASIA MICRO DATABASE\APPS\DATA CHECK\Food and non-food shares\NPL"
	glo fixlabels "D:\SOUTH ASIA MICRO DATABASE\APPS\DATA CHECK\Label fixing"

** LOG FILE
	log using "`output'\Doc\Technical\NPL_2010_LSS-III_v01_M_v04_A_SARMD.log",replace

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
	notes _dta: "NPL 2010" Unlike NPL 2003, this round has an specific question relating the classification of jobs
	 
	merge 1:1 xhpsu xhnum idc idj using `employment2'
	drop _merge
	sort xhpsu xhnum idc idj
	gen njobs=idj
	keep if	njobs<=2
	tempfile aux
	keep xhpsu xhnum idc njobs  v10_03_txt v10_03 v10_04a v10_04b v10_04c v10_04d v10_04e v10_04f v10_04g v10_04h v10_04i v10_04j v10_04k v10_04l v10_05a v10_05b v10_06a v10_06b v10_06c v10_06d v10_06e v10_06f v10_06g v10_06h v10_07 v12_ln1 v12_02_txt v12_02 v12_03 v12_04 v12_05a v12_05b v12_06a v12_06b v12_ln2 v12_07 v12_08 v12_09a v12_09b v12_10a v12_10b v12_11 v12_12 v12_13 v12_14 v12_ln3 v12_15a v12_15b v12_15c v12_15d v12_15e v12_16 v12_17 v12_18 v12_19 v12_20 v12_21 idj 
	reshape wide njobs  v10_03_txt v10_03 v10_04a v10_04b v10_04c v10_04d v10_04e v10_04f v10_04g v10_04h v10_04i v10_04j v10_04k v10_04l v10_05a v10_05b v10_06a v10_06b v10_06c v10_06d v10_06e v10_06f v10_06g v10_06h v10_07 v12_ln1 v12_02_txt v12_02 v12_03 v12_04 v12_05a v12_05b v12_06a v12_06b v12_ln2 v12_07 v12_08 v12_09a v12_09b v12_10a v12_10b v12_11 v12_12 v12_13 v12_14 v12_ln3 v12_15a v12_15b v12_15c v12_15d v12_15e v12_16 v12_17 v12_18 v12_19 v12_20 v12_21, i( xhpsu xhnum idc) j( idj )	
	gen njobs=.
	replace njobs=njobs1
	replace njobs=njobs2 if njobs2!=.
	replace njobs=njobs-1
	qui compress
	tempfile employment3
	save `employment3'
	
	
	
	use "`input'\Data\Stata\S10A.dta", clear
	ren *idc idc
	sort xhpsu xhnum idc
	qui compress
	tempfile employment4
	save `employment4'
	
	use "`input'\Data\Stata\S06C.dta", clear
	egen itc2=concat( v06c_itm v06c_idc )
	replace itc2=strtoname(itc2)
	replace itc2=substr(itc2, 1,20)
	keep xhpsu xhnum itc2 v06_05
	*replace v06_06=1 if v06_06==.
	reshape wide v06_05, i( xhpsu xhnum ) j( itc2 ) string
	tempfile durables
	save `durables'
	
		
	use "`input'\Data\Stata\S13E1.dta", clear
	keep xhpsu xhnum v13_66yn v13e1_lc
	reshape wide v13_66yn, i( xhpsu xhnum ) j( v13e1_lc )
	tempfile livestock
	save `livestock'
	
	
	* MERGE DATASETS
	
	use `roster', clear
	
	foreach p in housing durables livestock{
	merge m:1 xhpsu xhnum using ``p''
	drop _merge
	}
	
	
	foreach x in education employment employment3 employment4{
	merge 1:1 xhpsu xhnum idc using ``x''
	drop _merge
	}
	
	sort xhpsu xhnum
	tempfile raw
	save `raw'
	
	merge m:1 xhpsu xhnum using "`input'\Data\Stata\FINAL_PREF.dta"
	
	drop _merge
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
 gen ye=year(Date)
 rename ye int_year
 label var int_year "Year of the interview"
*</_int_year_>
	
	
** INTERVIEW MONTH
	gen int_month=month(Date)
	la de lblint_month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
	label value int_month lblint_month
	label var int_month "Month of the interview"
*</_int_month_>
	
**FIELD WORKD***
*<_fieldwork_> 
gen fieldwork=ym(int_year, int_month)
format %tm fieldwork
la var fieldwork "Date of fieldwork"
*<_/fieldwork_> 


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

	gen veralt="04"
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


** MACRO REGIONS
*<_subnatid1_>
	gen byte subnatid1=region
	la de lblsubnatid1 1 "Eastern" 2 "Central" 3 "Western" 4 "Mid-west" 5 "Far-west"
	label var subnatid1 "Macro regional areas"
	label values subnatid1 lblsubnatid1
		numlabel lblsubnatid1, remove
		numlabel lblsubnatid1, add mask("# - ")
		decode subnatid1, gen(subnatid1_temp)
		drop subnatid1
		rename subnatid1_temp subnatid1
*</_subnatid1_>

*<_gaul_adm1_code_>
	gen gaul_adm1_code=.
	label var gaul_adm1_code "GAUL code for admin1 level"
	replace gaul_adm1_code=2011 if subnatid1=="1 - Eastern"
	replace gaul_adm1_code=2010 if subnatid1=="2 - Central"
	replace gaul_adm1_code=2014 if subnatid1=="3 - Western"
	replace gaul_adm1_code=2013 if subnatid1=="4 - Mid-west"
	replace gaul_adm1_code=2012 if subnatid1=="5 - Far-west"
*<_gaul_adm1_code_>

		

** REGIONAL AREA 2 DIGIT ADMN LEVEL
*<_subnatid2_>
	gen byte subnatid2=district
	la de lblsubnatid2 1 "Taplejung" 2 "Panchthar" 3 "Ilam" 4 "Jhapa" 5 "Morang" 6 "Sunsari" 7 "Dhankuta" 8 "Tehrathum" 9 "Sankhuwasabha" 10 "Bhojpur" 11 "Solukhumbu" 12 "Okhaldhunga" 13 "Khotang" 14 "Udayapur" 15 "Saptari" 16 "Siraha" 17 "Dhanusha" 18 "Mahottari" 19 "Sarlahi" 20 "Sindhuli" 21 "Ramechhap" 22 "Dolakha" 23 "Sindhupalchok" 24 "Kabhrepalanchok" 25 "Lalitpur" 26 "Bhaktapur" 27 "Kathmandu" 28 "Nuwakot" 29 "Rasuwa" 30 "Dhading" 31 "Makwanpur" 32 "Rautahat"  33 "Bara" 34 "Parsa" 35 "Chitwan" 36 "Gorkha" 37 "Lamjung" 38 "Tanahun" 39 "Syangja" 40 "Kaski" 41 "Manang" 42 "Mustang" 43 "Myagdi"44 "Parbat" 45 "Baglung" 46 "Gulmi" 47 "Palpa" 48 "Nawalparasi" 49 "Rupandehi" 50 "Kapilbastu" 51 "Arghakhanchi" 52 "Pyuthan" 53 "Rolpa" 54 "Rukum" 55 "Salyan" 56 "Dang" 57 "Banke" 58 "Bardiya" 59 "Surkhet" 60 "Dailekh" 61 "Jajarkot" 62 "Dolpa" 63 "Jumla" 64 "Kalikot" 65 "Mugu" 66 "Humla" 67 "Bajura" 68 "Bajhang" 69 "Achham"  70 "Doti" 71 "Kailali" 72 "Kanchanpur" 73 "Dandheldhura" 74 "Baitadi" 75 "Darchula"
	label var subnatid2 "Region at 2 digit (ADMN2)"
	label values subnatid2 lblsubnatid2
		numlabel lblsubnatid2, remove
		numlabel lblsubnatid2, add mask("# - ")
		decode subnatid2, gen(subnatid2_temp)
		drop subnatid2
		rename subnatid2_temp subnatid2
*</_subnatid2_>


** REGIONAL AREA 3 DIGIT ADMN LEVEL
*<_subnatid3_>
	gen byte subnatid3=.
	label var subnatid3 "Region at 2 digit (ADMN2)"
	label values subnatid3 lblsubnatid3
*</_subnatid3_>


** REGIONAL AREA 4 DIGIT ADMN LEVEL
*<_subnatid4_>
	gen byte subnatid4=.
	label var subnatid4 "Region at 3 digit (ADMN3)"
	label values subnatid4 lblsubnatid4
*</_subnatid4_>


** HOUSE OWNERSHIP
*<_ownhouse_>
	recode v02_11 2=0
	gen byte ownhouse=v02_11
	label var ownhouse "House ownership"
	la de lblownhouse 0 "No" 1 "Yes"
	label values ownhouse lblownhouse
*</_ownhouse_>

** TENURE OF DWELLING
*<_tenure_>
   gen tenure=.
   replace tenure=1 if v02_11==1
   replace tenure=2 if  v02_16==1
   replace tenure=3 if v02_16!=1 & v02_16<.
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


*ORIGINAL WATER CATEGORIES
*<_water_orig_>
gen water_orig=v02_19
la var water_orig "Source of Drinking Water-Original from raw file"
#delimit
la def lblwater_orig 1 "Piped water supply"
					 2 "Covered well"
					 3 "Hand pump/tubewell"
					 4 "Open well"
					 5 "Spring water"
					 6 "River"
					 7 "Other source";
#delimit cr
la val water_orig lblwater_orig
*</_water_orig_>

*PIPED SOURCE OF WATER
*<_piped_water_>
gen piped_water=.
replace piped_water=1 if  v02_19==1
replace piped_water=0 if piped_water==.
la var piped_water "Household has access to piped water"
la def lblpiped_water 1 "Yes" 0 "No"
la val piped_water lblpiped_water
*</_piped_water_>


	
**INTERNATIONAL WATER COMPARISON (Joint Monitoring Program)
*<_water_jmp_>
gen water_jmp=.
label var water_jmp "Source of drinking water-using Joint Monitoring Program categories"
#delimit
la de lblwater_jmp 1 "Piped into dwelling" 	
				   2 "Piped into compound, yard or plot" 
				   3 "Public tap / standpipe" 
				   4 "Tubewell, Borehole" 
				   5 "Protected well"
				   6 "Unprotected well"
				   7 "Protected spring"
				   8 "Unprotected spring"
				   9 "Rain water"
				   10 "Tanker-truck or other vendor"
				   11 "Cart with small tank / drum"
				   12 "Surface water (river, stream, dam, lake, pond)"
				   13 "Bottled water"
				   14 "Other";
#delimit cr
la values  water_jmp lblwater_jmp
*</_water_jmp_>

*SAR improved source of drinking water
*<_sar_improved_water_>
gen sar_improved_water=.
replace sar_improved_water=1 if inlist(v02_19,1,2,3)
replace sar_improved_water=0 if inlist(v02_19,4,5,6,7 )
la def lblsar_improved_water 1 "Improved" 0 "Unimproved"
la var sar_improved_water "Improved source of drinking water-using country-specific definitions"
la val sar_improved_water lblsar_improved_water
*</_sar_improved_water_>


*ORIGINAL WATER CATEGORIES
*<_water_original_>
clonevar j=v02_19
#delimit
la def lblwater_original 1 "Piped water supply"
						 2 "Covered well"
						 3 "Hand pump/tubewell"
						 4 "Open well"
						 5 "Spring water"
						 6 "River"
						 7 "Other source";
#delimit cr
la val j lblwater_original		
decode j, gen(water_original)
drop j
la var water_original "Source of Drinking Water-Original from raw file"
*</_water_original_>

	** WATER SOURCE
	*<_water_source_>
		gen water_source=.
		replace water_source=1 if v02_19==1
		replace water_source=5 if v02_19==2
		replace water_source=4 if v02_19==3
		replace water_source=10 if v02_19==4
		replace water_source=5 if v02_19==5
		replace water_source=9 if v02_19==6
		replace water_source=14 if v02_19==7
		#delimit
			la de lblwater_source 1 "Piped water into dwelling" 	
								  2 "Piped water to yard/plot" 
								  3 "Public tap or standpipe" 
								  4 "Tubewell or borehole" 
								  5 "Protected dug well"
								  6 "Protected spring"
								  7 "Bottled water"
								  8 "Rainwater"
								  9 "Unprotected spring"
								  10 "Unprotected dug well"
								  11 "Cart with small tank/drum"
								  12 "Tanker-truck"
								  13 "Surface water"
								  14 "Other";
		#delimit cr
		la val water_source lblwater_source
		la var water_source "Sources of drinking water"
	*</_water_source_>

	
	** SAR IMPROVED SOURCE OF DRINKING WATER
	*<_improved_water_>
		gen improved_water=.
		replace improved_water=1 if inrange(water_source,1,8)
		replace improved_water=0 if inrange(water_source,9,14) // Asuming other is not improved water source
		la def lblimproved_water 1 "Improved" 0 "Unimproved"
		la val improved_water lblimproved_water
		la var improved_water "Improved access to drinking water"
	*</_improved_water_>



	** PIPED SOURCE OF WATER ACCESS
	*<_pipedwater_acc_>
		gen pipedwater_acc=0 if inrange(v02_19,2,11) // Asuming other is not piped water
		replace pipedwater_acc=3 if inlist(v02_19,1)
		#delimit 
		la def lblpipedwater_acc	0 "No"
									1 "Yes, in premise"
									2 "Yes, but not in premise"
									3 "Yes, unstated whether in or outside premise";
		#delimit cr
		la val pipedwater_acc lblpipedwater_acc
		la var pipedwater_acc "Household has access to piped water"
	*</_pipedwater_acc_>

	
	** WATER TYPE VARIABLE USED IN THE SURVEY
	*<_watertype_quest_>
		gen watertype_quest=1
		#delimit
		la def lblwaterquest_type	1 "Drinking water"
									2 "General water"
									3 "Both"
									4 "Others";
		#delimit cr
		la val watertype_quest lblwaterquest_type
		la var watertype_quest "Type of water questions used in the survey"
	*</_watertype_quest_>
	
	
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
	notes electricity: "NPL 2010" The definition used was if household's main source of lighting is electricity
*</_electricity_>


*ORIGINAL TOILET CATEGORIES
*<_toilet_orig_>
gen toilet_orig=v02_26
la var toilet_orig "Access to sanitation facility-Original from raw file"
#delimit
la def lbltoilet_orig 1 "Household flush (connected to municipal sewer)"
					  2 "Household flush (connected to septic tank)"
					  3 "Household non-flush"
					  4 "Communal latrine"
					  5 "No toilet";
#delimit cr
la val toilet_orig lbltoilet_orig
*</_toilet_orig_>

*SEWAGE TOILET
*<_sewage_toilet_>
gen sewage_toilet=v02_26
replace sewage_toilet=0 if sewage_toilet!=1
la var sewage_toilet "Household has access to sewage toilet"
la def lblsewage_toilet 1 "Yes" 0 "No"
la val sewage_toilet lblsewage_toilet
*</_sewage_toilet_>


**INTERNATIONAL SANITATION COMPARISON (Joint Monitoring Program)
*<_toilet_jmp_>
gen toilet_jmp=.
label var toilet_jmp "Access to sanitation facility-using Joint Monitoring Program categories"
#delimit 
la def lbltoilet_jmp 1 "Flush to piped sewer  system"
					2 "Flush to septic tank"
					3 "Flush to pit latrine"
					4 "Flush to somewhere else"
					5 "Flush, don't know where"
					6 "Ventilated improved pit latrine"
					7 "Pit latrine with slab"
					8 "Pit latrine without slab/open pit"
					9 "Composting toilet"
					10 "Bucket toilet"
					11 "Hanging toilet/hanging latrine"
					12 "No facility/bush/field"
					13 "Other";
#delimit cr
la val toilet_jmp lbltoilet_jmp
*</_toilet_jmp_>


*SAR improved type of toilet
*<_sar_improved_toilet_>
gen sar_improved_toilet=.
replace sar_improved_toilet=1 if inlist(v02_26,1,2)
replace sar_improved_toilet=0 if inlist(v02_26,3,4,5)
la def lblsar_improved_toilet 1 "Improved" 0 "Unimproved"
la var sar_improved_toilet "Improved type of sanitation facility-using country-specific definitions"
la val sar_improved_toilet lblsar_improved_toilet
*</_sar_improved_toilet_>


	** ORIGINAL SANITATION CATEGORIES 
	*<_sanitation_original_>
		clonevar j=v02_26
		#delimit
		la def lblsanitation_original   1 "Household flush (connected to municipal sewer)"
										2 "Household flush (connected to septic tank)"
										3 "Household non-flush"
										4 "Communal latrine"
										5 "No toilet";
		#delimit cr
		la val j lblsanitation_original
		decode j, gen(sanitation_original)
		drop j
		la var sanitation_original "Access to sanitation facility-Original from raw file"
	*</_sanitation_original_>


	** SANITATION SOURCE
	*<_sanitation_source_>
		gen sanitation_source=.
		replace sanitation_source=2 if v02_26==1
		replace sanitation_source=3 if v02_26==2
		replace sanitation_source=14 if v02_26==3
		replace sanitation_source=14 if v02_26==4
		replace sanitation_source=13 if v02_26==5
		#delimit
		la def lblsanitation_source	1	"A flush toilet"
									2	"A piped sewer system"
									3	"A septic tank"
									4	"Pit latrine"
									5	"Ventilated improved pit latrine (VIP)"
									6	"Pit latrine with slab"
									7	"Composting toilet"
									8	"Special case"
									9	"A flush/pour flush to elsewhere"
									10	"A pit latrine without slab"
									11	"Bucket"
									12	"Hanging toilet or hanging latrine"
									13	"No facilities or bush or field"
									14	"Other";
		#delimit cr
		la val sanitation_source lblsanitation_source
		la var sanitation_source "Sources of sanitation facilities"
	*</_sanitation_source_>

	
	** SAR IMPROVED SANITATION 
	*<_improved_sanitation_>
		gen improved_sanitation=.
		replace improved_sanitation=1 if inlist(sanitation_source,1,2,3,4,5,6,7,8)
		replace improved_sanitation=0 if inlist(sanitation_source,9,10,11,12,13,14)
		la def lblimproved_sanitation 1 "Improved" 0 "Unimproved"
		la val improved_sanitation lblimproved_sanitation
		la var improved_sanitation "Improved type of sanitation facility-using country-specific definitions"
	*</_improved_sanitation_>
	

	** ACCESS TO FLUSH TOILET
	*<_toilet_acc_>
		gen toilet_acc=3 if improved_sanitation==1
		replace toilet_acc=0 if improved_sanitation==0 
		#delimit 
		la def lbltoilet_acc		0 "No"
									1 "Yes, in premise"
									2 "Yes, but not in premise"
									3 "Yes, unstated whether in or outside premise";
		#delimit cr
		la val toilet_acc lbltoilet_acc
		la var toilet_acc "Household has access to flushed toilet"
	*</_toilet_acc_>

	
** INTERNET
*<_internet_>
	recode v02_31d 2=0
	gen byte internet=v02_31d
	label var internet "Internet connection"
	la de lblinternet 0 "No" 1 "Yes"
	label values internet lblinternet
*</_internet_>

/*****************************************************************************************************
*                                                                                                    *
                                   DEMOGRAPHIC MODULE
*                                                                                                    *
*****************************************************************************************************/


** HOUSEHOLD SIZE
*<_hsize_>
	gen hsize=hhsize
	*replace hsize=. if v01_10==2
	la var hsize "Household size"
*</_hsize_>

**POPULATION WEIGHT
*<_pop_wgt_>
	gen pop_wgt=wgt*hsize
	la var pop_wgt "Population weight"
*</_pop_wgt_>



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
	replace age=98 if age>=98
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

*Generate adjuntment on ownhouse variable
 replace ownhouse=. if ownhouse==1 & hsize==. & relationharm==6

/*****************************************************************************************************
*                                                                                                    *
                                   EDUCATION MODULE
*                                                                                                    *
*****************************************************************************************************/


** EDUCATION MODULE AGE
*<_ed_mod_age_>
	gen byte ed_mod_age=3
	label var ed_mod_age "Education module application age"
	note ed_mod_age: "NPL 2010" The minimum age of application for the education module is not comparable with previous rounds (5 years old)
*</_ed_mod_age_>


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
	gen byte educy= inter_edlevel
	recode educy (-1 = 0) (13 = 15) (14 15 = 17)
	label var educy "Years of education"
	notes educy: "NPL 2010" There is a substraction of 1 year in the computation of years of schooling for those currently attending
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
	la var educat5 "Level of education 5 categories"
*</_educat5_>


	
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
	replace everattend=0 if  v07_08==1
	replace everattend=1 if  v07_08==2 |  v07_08==3
	label var everattend "Ever attended school"
	la de lbleverattend 0 "No" 1 "Yes"
	label values everattend lbleverattend
*</_everattend_>


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
*<_lb_mod_age_>
	gen byte lb_mod_age=5
	label var lb_mod_age "Labor module application age"
*</_lb_mod_age_>


	* Survey includes agricultural activities not considered 'employment' for the purpose of this data set. Hence, the sizable number of missing values for 'lstatus'.

** LABOR STATUS
*<_lstatus_>
	gen byte lstatus=.
	replace lstatus=1 if v10_031<996 & v10_06h1>0
	replace lstatus=3 if (v10_06h1==0 & (v11_02==2 | v11_03==2)) | v10_031==997 | (v10_031==998 & (v11_02==2 | v11_03==2))| (v10_031==996 & (v11_02==2 | v11_03==2))
	replace lstatus=2 if (v10_06h1==0 & v10_01g==0) & lstatus!=3
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus
*</_lstatus_>

** LABOR STATUS 2
*<_lstatus_>
	gen byte lstatus2=.
	replace lstatus2=1 if v10_032<996 & v10_06h2>0
	replace lstatus2=3 if (v10_06h2==0 & (v11_02==2 | v11_03==2)) | v10_032==997 | (v10_032==998 & (v11_02==2 | v11_03==2))| (v10_032==996 & (v11_02==2 | v11_03==2))
	replace lstatus2=2 if (v10_06h2==0 & v10_01g==0) & lstatus2!=3
	replace lstatus2=. if njobs==0 | njobs==.
	label var lstatus2 "Labor status"
	la de lbllstatus2 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus2 lbllstatus2
*</_lstatus_>

** LABOR STATUS LAST YEAR
*<_lstatus_year_>
	gen byte lstatus_year=.
	replace lstatus_year=lstatus
	replace lstatus_year=0 if lstatus>1 & lstatus!=.
	replace lstatus_year=. if age<lb_mod_age & age!=.
	label var lstatus_year "Labor status during last year"
	la de lbllstatus_year 1 "Employed" 0 "Not employed" 
	label values lstatus_year lbllstatus_year
	notes lstatus_year: "NPL 2010" the same reference period is used for lstatus and lstatus_year
*</_lstatus_year_>


** LABOR STATUS LAST YEAR 2 
*<_lstatus_year_>
	gen byte lstatus_year2=.
	replace lstatus_year2=lstatus2
	replace lstatus_year2=0 if lstatus2>1 & lstatus2!=.
	replace lstatus_year2=. if age<lb_mod_age & age!=.
	label var lstatus_year2 "Labor status during last year"
	la de lbllstatus_year2 1 "Employed" 0 "Not employed" 
	label values lstatus_year2 lbllstatus_year2
	notes lstatus_year: "NPL 2010" the same reference period is used for lstatus and lstatus_year
*</_lstatus_year_>


* Survey doesn not provide sufficient info to construct all categories.

** EMPLOYMENT STATUS
*<_empstat_>
	gen byte empstat=.
/*
non paid employee and employer are not available
*/
	replace empstat=1 if v10_071==1 | v10_071==2
	replace empstat=4 if v10_071==3 | v10_071==4
	replace empstat=. if lstatus!=1
	label var empstat "Employment status"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed"
	label values empstat lblempstat
*</_empstat_>


** EMPLOYMENT STATUS LAST YEAR
*<_empstat_year_>
	gen byte empstat_year=.
	replace empstat_year=empstat
	replace empstat_year=. if lstatus_year!=1
	label var empstat_year "Employment status during last year"
	la de lblempstat_year 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat_year lblempstat_year
*</_empstat_year_>


** NUMBER OF ADDITIONAL JOBS
*<_njobs_>
	label var njobs "Number of additional jobs"
*</_njobs_>


** NUMBER OF ADDITIONAL JOBS LAST YEAR
*<_njobs_year_>
	gen byte njobs_year=njobs
	*replace njobs_year=. if lstatus_year!=1
	label var njobs_year "Number of additional jobs during last year"
*</_njobs_year_>


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


**ORIGINAL INDUSTRY CLASSIFICATION
*<_industry_orig_>
	gen industry_orig=.
	label define lblindustry_orig 1 `"AGRICULTURE AND RELATED SERVICE ACTIVITIES"', modify
	label define lblindustry_orig 2 `"FORESTRY, LOGGING AND RELATED SERVICE ACTIVITIES"', modify
	label define lblindustry_orig 5 `"FISHING, OPERATION OF FISH HATCHERIES AND FISH FARMS; SERVICE ACTIVITIES INCIDENTAL TO FISHING"', modify
	label define lblindustry_orig 10 `"MINING OF COAL AND LIGNITE; EXTRACTION OF PEAT"', modify
	label define lblindustry_orig 11 `"EXTRACTION OF CRUDE PETROLIUM AND NATURAL GAS; SERVICE ACTIVITIES INCIDENTAL TO OIL AND GAS EXTRACTION EXCLUDING SURVEYING"', modify
	label define lblindustry_orig 12 `"MINING OF URANIUM AND THORIUM ORES"', modify
	label define lblindustry_orig 13 `"MINING OF METAL ORES"', modify
	label define lblindustry_orig 14 `"OTHER MINING AND QUARRYING"', modify
	label define lblindustry_orig 15 `"MANUFACTURE OF FOOD PRODUCTS AND BEVERAGES"', modify
	label define lblindustry_orig 16 `"MANUFACTURE OF TOBACCO PRODUCTS"', modify
	label define lblindustry_orig 17 `"MANUFACTURE OF TEXTILES"', modify
	label define lblindustry_orig 18 `"MANUFACTURE OF WEARING APPREL; DRESSING AND DYEING OF FUR"', modify
	label define lblindustry_orig 19 `"TANNING AND DRESSING OF LEATHER; MANUFACTURE OF LUGGAGE, HANDBAGS, SADDLERY AND HARNESS"', modify
	label define lblindustry_orig 20 `"MANUFACTURE OF WOOD AND OF PRODUCTS OF WOOD AND CORK, EXCEPT FURNITURE; MANUFACTURE OF ARTICLES OF STRAW AND PLAITING MATERIALS"', modify
	label define lblindustry_orig 21 `"MANUFACTURE OF PAPER AND PAPER PRODUCTS"', modify
	label define lblindustry_orig 22 `"PUBLISHING, PRINTING AND REPRODUCTION OF RECORDED MEDIA"', modify
	label define lblindustry_orig 23 `"MANUFACTURE OF COKE, REFINED PETROLIUM PRODUCTS AND NUCLEAR FUEL"', modify
	label define lblindustry_orig 24 `"MANUFACTURE OF CHEMICALS AND CHEMICAL PRODUCTS"', modify
	label define lblindustry_orig 25 `"MANUFACTURE OF RUBBER AND PLASICS PRODUCTS"', modify
	label define lblindustry_orig 26 `"MANUFACTURE OF OTHER NON-METALIC MINARAL PRODUCTS"', modify
	label define lblindustry_orig 27 `"MANUFACTURE OF BASIC METALS"', modify
	label define lblindustry_orig 28 `"MANUFACTURE OF FABRICATED METAL PRODUCTS, EXCEPT MACHINERY AND EQUIPMENT"', modify
	label define lblindustry_orig 29 `"MANUFACTURE OF MACHINERY AND EQUIPMENT N.E.C."', modify
	label define lblindustry_orig 30 `"MANUFACTURE OF OFFICE, ACCOUNTING AND COMPUTING MACHINERY"', modify
	label define lblindustry_orig 31 `"MANUFACTURE OF ELECTRICAL MACHINERY AND APPARATUS N.E.C."', modify
	label define lblindustry_orig 32 `"MANUFACTURE OF RADIO, TV AND COMMUNICATION EQUIPMENT AND APPARATUS"', modify
	label define lblindustry_orig 33 `"MANUFACTURE OF MEDICAL, PRECISION AND OPTICAL INSTRUMENTS, WATCHES AND CLOCKS"', modify
	label define lblindustry_orig 34 `"MANUFACTURE OF MOTOR VEHICLES; TRAILERS AND SEMI-TRAILERS"', modify
	label define lblindustry_orig 35 `"MANUFACTURE OF OTHER TRANSPORT EQUIPMENT"', modify
	label define lblindustry_orig 36 `"MANUFACTURE OF FURNITURE; MANUFACTURING N.E.C."', modify
	label define lblindustry_orig 37 `"RECYCLING"', modify
	label define lblindustry_orig 40 `"ELECTRICITY AND GAS SUPPLY"', modify
	label define lblindustry_orig 41 `"COLLECTIONS, PURIFICATION AND DISTRIBUTION OF WATER"', modify
	label define lblindustry_orig 45 `"CONSTRUCTION"', modify
	label define lblindustry_orig 50 `"SALE, MAINTENANCE AND REPAIR OF MOTOR VEHICLES AND MOTORCYCLES; RETAIL SALE OF AUTOMOTIVE FUEL"', modify
	label define lblindustry_orig 51 `"WHOLESALE TRADE AND COMMISSION TRADE, EXCEPT OF MOTOR VEHICLES AND MOTORCYCLES"', modify
	label define lblindustry_orig 52 `"RETAIL TRADE, EXCEPT OF MOTOR VEHICLES AND MOTORCYCLES; REPAIR OF PERSONAL AND HOUSEHOLD GOODS"', modify
	label define lblindustry_orig 55 `"HOTELS AND RESTAURANTS"', modify
	label define lblindustry_orig 60 `"LAND TRANSPORT"', modify
	label define lblindustry_orig 61 `"WATER TRANSPORT"', modify
	label define lblindustry_orig 62 `"AIR TRANSPORT"', modify
	label define lblindustry_orig 63 `"SUPPORTING AND AUXILIARY TRANSPORT ACTIVITIES; ACTIVITIES OF TRAVEL AGENCIES"', modify
	label define lblindustry_orig 64 `"POST AND TELECOMMUNICATIONS"', modify
	label define lblindustry_orig 65 `"FINANCIAL INTERMEDIATION, EXCEPT INSURANCE AND PENSION FUNDING"', modify
	label define lblindustry_orig 66 `"INSURANCE AND PENSION FUNDING, EXCEPT COMPULSORY SOCIAL SECURITY"', modify
	label define lblindustry_orig 67 `"ACTIVITIES AUXILIARY TO FINANCIAL INTERMEDIATION"', modify
	label define lblindustry_orig 70 `"REAL ESTATE ACTIVITIES"', modify
	label define lblindustry_orig 71 `"RENTING OF MACHINERY AND EQUIPMENT WITHOUT OPERATOR AND OF PERSONAL AND HOUSEHOLD GOODS"', modify
	label define lblindustry_orig 72 `"COMPUTER AND RELATED ACTIVITIES"', modify
	label define lblindustry_orig 73 `"RESEARCHES AND DEVELOPMENT"', modify
	label define lblindustry_orig 74 `"OTHER BUSINESS ACTIVITIES"', modify
	label define lblindustry_orig 75 `"PUBLIC ADMINISTRATION AND DEFENCE; COMPULSORY SOCIAL SECURITY"', modify
	label define lblindustry_orig 80 `"EDUCATION"', modify
	label define lblindustry_orig 85 `"HEALTHS AND SOCIAL WORK"', modify
	label define lblindustry_orig 90 `"SEWAGE AND REFUSE DISPOSAL, SANITATION AND SIMILAR ACTIVITIES"', modify
	label define lblindustry_orig 91 `"ACTIVITIES OF MEMBERSHIP ORGANIZATIONS N.E.C."', modify
	label define lblindustry_orig 92 `"RECREATIONAL, CULTURAL AND SPORTING ACTIVITIES"', modify
	label define lblindustry_orig 93 `"OTHER SERVICE ACTIVITIES"', modify
	label define lblindustry_orig 95 `"PRIVATE HOUSEHOLDS WITH EMPLOYED PERSONS"', modify
	label define lblindustry_orig 99 `"EXTRA-TERRITORIAL ORGANIZATION AND BODIES"', modify
	la val industry_orig lblindustry_orig
	replace industry_orig=. if lstatus!=1
	la var industry_orig "Original industry code"
*</_industry_orig_>



** INDUSTRY CLASSIFICATION
*<_industry_>
	gen byte industry=.
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


**ORIGINAL OCCUPATION CLASSIFICATION
*<_occup_orig_>
	gen occup_orig=v10_031
	label define lbloccup_orig 11 `"ARMED FORCES"', modify
	label define lbloccup_orig 111 `"LEGISLATORS"', modify
	label define lbloccup_orig 112 `"GOVERNMENT OFFICIALS"', modify
	label define lbloccup_orig 114 `"OFFICIALS OF SPECIAL INTEREST ORGANIZATIONS"', modify
	label define lbloccup_orig 121 `"DIRECTORS AND CHIEF EXECUTIVES"', modify
	label define lbloccup_orig 122 `"PRODUCTION AND OPERATIONS DEPARTMENT MANAGERS"', modify
	label define lbloccup_orig 123 `"OTHER DEPARTMENT MANAGERS"', modify
	label define lbloccup_orig 131 `"GENERAL MANAGERS/MANAGING PROPRIETORS"', modify
	label define lbloccup_orig 211 `"PHYSICISTS, CHEMISTS AND RELATED PROFESSIONALS"', modify
	label define lbloccup_orig 212 `"MATHEMATICIANS, STATISTICIANS AND RELATED PROFESSIONALS"', modify
	label define lbloccup_orig 213 `"COMPUTING PROFESSIONALS"', modify
	label define lbloccup_orig 214 `"ARCHITECTS, ENGINEERS AND RELATED PROFESSIONALS"', modify
	label define lbloccup_orig 221 `"LIFE SCIENCE PROFESSIONALS"', modify
	label define lbloccup_orig 222 `"HEALTH PROFESSIONALS, EXCEPT NURSING"', modify
	label define lbloccup_orig 223 `"NURSING AND MIDWIFERY PROFESSIONALS"', modify
	label define lbloccup_orig 231 `"COLLEGE, UNIVERSITY AND HIGHER EDUCATION TEACHING PROFESSIONALS"', modify
	label define lbloccup_orig 232 `"SECONDARY EDUCATION TEACHING PROFESSIONALS"', modify
	label define lbloccup_orig 233 `"PRIMARY AND PRE-PRIMARY EDUCATION TEACHING PROFESSIONALS"', modify
	label define lbloccup_orig 234 `"SPECIAL EDUCATION TEACHING PROFESSIONALS"', modify
	label define lbloccup_orig 235 `"OTHER TEACHING PROFESSIONALS"', modify
	label define lbloccup_orig 241 `"BUSINESS PROFESSIONALS"', modify
	label define lbloccup_orig 242 `"LEGAL PROFESSIONALS"', modify
	label define lbloccup_orig 243 `"ARCHIVISTS, LIBRARIANS AND RELATED INFORMATION PROFESSIONALS"', modify
	label define lbloccup_orig 244 `"SOCIAL SCIENCE AND RELATED PROFESSIONALS"', modify
	label define lbloccup_orig 245 `"WRITERS AND CREATIVE OR PERFORMING ARTISTS"', modify
	label define lbloccup_orig 246 `"RELIGIOUS PROFESSIONALS"', modify
	label define lbloccup_orig 311 `"PHYSICAL AND ENGINEERING SCIENCE TECHNICIANS"', modify
	label define lbloccup_orig 312 `"COMPUTER ASSOCIATE PROFESSIONALS"', modify
	label define lbloccup_orig 313 `"OPTICAL AND ELECTRONIC EQUIPMENT OPERATORS"', modify
	label define lbloccup_orig 314 `"AIRCRAFT CONTROLLERS AND TECHNICIANS"', modify
	label define lbloccup_orig 315 `"SAFETY AND QUALITY INSPECTORS"', modify
	label define lbloccup_orig 321 `"LIFE SCIENCE TECHNICIANS AND RELATED ASSOCIATE PROFESSIONALS"', modify
	label define lbloccup_orig 322 `"MODERN HEALTH ASSOCIATE PROFESSIONAL, EXCEPT NURSING"', modify
	label define lbloccup_orig 323 `"NURSING AND MIDWIFERY ASSOCIATE PROFESSIONALS"', modify
	label define lbloccup_orig 324 `"TRADITIONAL MEDICINE PRACTITIONERS AND FAITH HEALERS"', modify
	label define lbloccup_orig 331 `"PRIMARY EDUCATION TEACHING ASSOCIATE PROFESSIONALS"', modify
	label define lbloccup_orig 332 `"PRE-PRIMARY EDUCATION TEACHING ASSOCIATE PROFESSIONALS"', modify
	label define lbloccup_orig 333 `"SPECIAL EDUCATION TEACHING ASSOCIATE PROFESSIONALS"', modify
	label define lbloccup_orig 334 `"OTHER TEACHING ASSOCIATE PROFESSIONALS"', modify
	label define lbloccup_orig 341 `"FINANCE AND SALES ASSOCIATE PROFESSIONALS"', modify
	label define lbloccup_orig 342 `"BUSINESS SERVICES AGENT AND TRADE BROKERS"', modify
	label define lbloccup_orig 343 `"ADMINISTRATIVE ASSOCIATE PROFESSIONALS"', modify
	label define lbloccup_orig 344 `"CUSTOMS, TAX AND RELATED GOVERNMENT ASSOCIATE PROFESSIONALS"', modify
	label define lbloccup_orig 345 `"POLICE INSPECTORS AND DETECTIVES"', modify
	label define lbloccup_orig 346 `"SOCIAL WORK ASSOCIATE PROFESSIONALS"', modify
	label define lbloccup_orig 347 `"ARTISTIC, ENTERTAINMENT AND SOPRTS ASSOCIATE PROFESSIONALS"', modify
	label define lbloccup_orig 348 `"RELIGIOUS ASSOCIATE PROFESSIONALS"', modify
	label define lbloccup_orig 411 `"SECRETARIES AND KEYBOARD-OPERATING CLERKS/ASSISTANTS"', modify
	label define lbloccup_orig 412 `"NUMERICAL CLERKS/OFFICE ASSISTANTS"', modify
	label define lbloccup_orig 413 `"MATERIAL-RECORDING AND TRANSPORT CLERKS/OFFICE ASSISTANTS"', modify
	label define lbloccup_orig 414 `"LIBRARY, MAIL AND RELATED CLERKS/OFFICE ASSISTANTS"', modify
	label define lbloccup_orig 419 `"OTHER OFFICE CLERKS/ASSISTANTS"', modify
	label define lbloccup_orig 421 `"CASHIERS, TELLERS AND RELATED CLERKS/OFFICE ASSISTANTS"', modify
	label define lbloccup_orig 422 `"CLIENT INFORMATION CLERKS/OFFICE ASSISTANTS"', modify
	label define lbloccup_orig 511 `"TRAVEL ATTENDANTS AND RELATED WORKERS"', modify
	label define lbloccup_orig 512 `"HOUSEKEEPING AND RESTAURANT SERVICES WORKERS"', modify
	label define lbloccup_orig 513 `"PERSONAL CARE AND RELATED WORKERS"', modify
	label define lbloccup_orig 514 `"OTHER PROFESSIONAL SERVICES WORKERS"', modify
	label define lbloccup_orig 515 `"ASTROLOGERS, FORTUNE-TELLERS AND RELATED WORKERS"', modify
	label define lbloccup_orig 516 `"PROTECTIVE SERVICE WORKERS"', modify
	label define lbloccup_orig 521 `"FASHION AND OTHER MODELS"', modify
	label define lbloccup_orig 522 `"SHOP SALESPERSONS AND DEMONSTRATOTRS"', modify
	label define lbloccup_orig 523 `"STALL AND MARKET SALESPERSONS"', modify
	label define lbloccup_orig 611 `"MARKET-ORIENTED GARDENERS AND CROP GROWERS"', modify
	label define lbloccup_orig 612 `"MARKET-ORIENTED ANIMAL PRODUCERS AND RELATED WORKERS"', modify
	label define lbloccup_orig 613 `"MARKET-ORIENTED CROP AND ANIMAL PRODUCERS"', modify
	label define lbloccup_orig 614 `"FORESTRY AND RELATED WORKERS"', modify
	label define lbloccup_orig 615 `"FISHERY WORKERS"', modify
	label define lbloccup_orig 621 `"SUBSISTENCE AGRICULTURAL AND FISHERY WORKERS"', modify
	label define lbloccup_orig 711 `"MINERS, SHOFTIRERS, STONE CUTTERS AND CARVERS"', modify
	label define lbloccup_orig 712 `"BUILDING FRAME AND RELATED TRADES WORKERS"', modify
	label define lbloccup_orig 713 `"BUILDING FINISHERS AND RELATED TRADES WORKERS"', modify
	label define lbloccup_orig 714 `"PAINTERS, BUILDING STRUCTURE CLEANERS AND RELATED TRADES WORKERS"', modify
	label define lbloccup_orig 721 `"METAL MOULDERS, WELDERS, SHEET-METAL WORKERS, STRUCTURAL-METAL PREPARER"', modify
	label define lbloccup_orig 722 `"BLACKSMITHS, TOOL-MAKERS AND RELATED TRADES WORKERS"', modify
	label define lbloccup_orig 723 `"MACHINERY MECHANICS AND FITTERS"', modify
	label define lbloccup_orig 724 `"ELECTRICAL AND ELECTRONIC EQUIPMENT MECHANICS AND FITTERS"', modify
	label define lbloccup_orig 731 `"PRECISION WORKERS IN METAL AND RELATED MATERIALS"', modify
	label define lbloccup_orig 732 `"POTTERS, GLASS-MAKERS AND RELATED TRADES WORKERS"', modify
	label define lbloccup_orig 733 `"HANDICRAFT WORKERS IN WOOD, TEXTILE, LEATHER AND RELATED MATERIALS"', modify
	label define lbloccup_orig 734 `"PRINTING AND RELATED TRADES WORKERS"', modify
	label define lbloccup_orig 741 `"FOOD PROCESSING AND RELATED TRADES WORKERS"', modify
	label define lbloccup_orig 742 `"WOOD TREATERS, CABINET-MAKERS AND RELATED TRADERS WORKERS"', modify
	label define lbloccup_orig 743 `"TEXTILE, GARMENT AND RELATED TRADES WORKERS"', modify
	label define lbloccup_orig 744 `"PELT, LEATHER AND SHOE MAKING TRADES WORKERS"', modify
	label define lbloccup_orig 811 `"MINING AND MINERAL-PROCESSING PLANT OPERATORS"', modify
	label define lbloccup_orig 812 `"METAL-PROCESSING-PLANT OPERATORS"', modify
	label define lbloccup_orig 813 `"GLASS, CERAMICS AND RELATIVE PLANT OPERATORS"', modify
	label define lbloccup_orig 814 `"WOOD-PROCESSING AND PAPERMAKING-PLANT OPERATORS"', modify
	label define lbloccup_orig 815 `"CHEMICAL-PROCESSING-PLANT OPERATORS"', modify
	label define lbloccup_orig 816 `"POWER-PRODUCTION AND RELATED PLANT OPERATORS"', modify
	label define lbloccup_orig 817 `"AUTOMATED-ASSEMBLY-LINE AND INDUSTRIAL-ROBOT OPERATORS"', modify
	label define lbloccup_orig 821 `"METAL AND MINERAL PRODUCTS MACHINE OPERATORS"', modify
	label define lbloccup_orig 822 `"CHEMICAL-PRODUCTS MACHINE OPERATORS"', modify
	label define lbloccup_orig 823 `"RUBBER AND PLASTIC PRODUCTS MACHINE OPERATORS"', modify
	label define lbloccup_orig 824 `"WOOD-PRODUCTS MACHINE OPERATORS"', modify
	label define lbloccup_orig 825 `"PRINTING, BINDING AND PAPER PRODUCTS MACHINE OPERATORS"', modify
	label define lbloccup_orig 826 `"TEXTILE, FUR AND LEATHER-PRODUCTS MACHINE OPERATORS"', modify
	label define lbloccup_orig 827 `"FOOD AND RELATED PRODUCTS MACHINE OPERATORS"', modify
	label define lbloccup_orig 828 `"ASSEMBLERS"', modify
	label define lbloccup_orig 829 `"OTHER MACHINE OPERATORS AND ASSEMBLERS"', modify
	label define lbloccup_orig 831 `"LOCOMOTIVE-ENGINE DRIVERS AND RELATED WORKERS"', modify
	label define lbloccup_orig 832 `"MOTOR VEHICLE DRIVERS"', modify
	label define lbloccup_orig 833 `"AGRICULTURAL AND OTHER MOBILE-PLANT OPERATORS"', modify
	label define lbloccup_orig 911 `"STREET VENDORS AND RELATED WORKERS"', modify
	label define lbloccup_orig 912 `"SHOE CLEANING AND OTHER STREET SERVICES ELEMENTARY OCCUPATIONS"', modify
	label define lbloccup_orig 913 `"DOMESTIC AND RELATED HELPERS, CLEANERS AND LAUNDERERS"', modify
	label define lbloccup_orig 914 `"BUILDING CARETAKERS, WINDOWS AND RELATED CLEANERS"', modify
	label define lbloccup_orig 915 `"MESSENGERS, PORTERS, DOORKEEPERS AND RELATED WORKERS"', modify
	label define lbloccup_orig 916 `"GARBAGE COLLECTORS AND RELATED LABOURERS"', modify
	label define lbloccup_orig 921 `"AGRICULTURAL, FISHERY AND RELATED LABOURERS"', modify
	label define lbloccup_orig 931 `"MINING AND CONSTRUCTION LABOURERS"', modify
	label define lbloccup_orig 932 `"MANUFACTURING LABOURERS"', modify
	label define lbloccup_orig 933 `"TRANSPORT LABOURERS AND FREIGHT HANDLERS"', modify
	label define lbloccup_orig 996 `"HOUSEHOLD WORK"', modify
	label define lbloccup_orig 997 `"STUDENT"', modify
	label define lbloccup_orig 998 `"NOT WORKING"', modify
	label define lbloccup_orig 999 `"NOT REPORTED"', modify
	la val occup_orig lbloccup_orig
	replace occup_orig=. if lstatus!=1
	la var occup_orig "Original occupation code"
*</_occup_orig_>


** OCCUPATION CLASSIFICATION
*<_occup_>
	gen byte occup=.
	replace occup=1 if v10_031>=111 & v10_031<=131
	replace occup=2 if v10_031>=211 & v10_031<=246
	replace occup=3 if v10_031>=311 & v10_031<=348
	replace occup=4 if v10_031>=411 & v10_031<=422
	replace occup=5 if v10_031>=511 & v10_031<=523
	replace occup=6 if v10_031>=611 & v10_031<=621
	replace occup=7 if v10_031>=711 & v10_031<=744
	replace occup=8 if v10_031>=811 & v10_031<=833
	replace occup=9 if v10_031>=911 & v10_031<=933
	replace occup=10 if v10_031==11
	replace occup=99 if v10_031==999
	replace occup=. if lstatus!=1
	label var occup "1 digit occupational classification"
	la de lbloccup 1 "Senior officials" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup lbloccup
*</_occup_>


** FIRM SIZE
*<_firmsize_l_>
	gen byte firmsize_l=.
	replace firmsize_l= 1 if v12_201==1
	replace firmsize_l= 2 if v12_201==2
	replace firmsize_l=10 if v12_201==3
	replace firmsize_l=. if lstatus!=1
	label var firmsize_l "Firm size (lower bracket)"
*</_firmsize_l_>

*<_firmsize_u_>

	gen byte firmsize_u=.
	replace firmsize_u= 1 if v12_201==1
	replace firmsize_u= 9 if v12_201==2
	replace firmsize_u=. if v12_201==3
	replace firmsize_u=. if lstatus!=1
	label var firmsize_u "Firm size (upper bracket)"

*</_firmsize_u_>


** HOURS WORKED LAST WEEK
*<_whours_>
	gen whours=v10_06h1
	replace whours=. if lstatus!=1
	label var whours "Hours of work in last week"
*</_whours_>
 

** WAGES
*<_wage_>
	gen double wage=.
	replace wage= v12_15a1 if v12_15a1!=.
	replace wage=v12_081 if v12_081!=.
	replace wage=v12_211 if v12_211!=.
	replace wage=v12_041 if  v12_041!=.
	replace wage=0 if empstat==2
	replace wage=. if lstatus!=1
	label var wage "Last wage payment"
*</_wage_>


** WAGES TIME UNIT
*<_unitwage_>
	gen byte unitwage=.
	replace unitwage=1 if v12_041!=.
	replace unitwage=5 if v12_15a1!=.
	replace unitwage=8 if v12_081!=.
	replace unitwage=8 if v12_211!=.
	replace  unitwage=. if lstatus!=1
	label var unitwage "Last wages time unit"
	la de lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Quarterly" 7 "Biannual" 8 "Annually" 9 "Hourly" 10 "Other"
	label values unitwage lblunitwage
*</_wageunit_>



** EMPLOYMENT STATUS - SECOND JOB
*<_empstat_2_>
	gen byte empstat_2=.
	replace empstat_2=1 if v10_072==1 | v10_072==2
	replace empstat_2=4 if v10_072==3 | v10_072==4
	replace empstat_2=. if njobs==0 | njobs==. | lstatus2!=1
	label var empstat_2 "Employment status - second job"
	la de lblempstat_2 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat_2 lblempstat_2
*</_empstat_2_>

** EMPLOYMENT STATUS - SECOND JOB LAST YEAR
*<_empstat_2_year_>
	gen empstat_2_year=.
	replace empstat_2_year= empstat_2
	replace empstat_2_year=. if njobs_year==0 | njobs_year==. | lstatus_year2!=1
	label var empstat_2_year "Employment status - second job"
	la de lblempstat_2_year 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat_2_year lblempstat_2
*</_empstat_2_>

** INDUSTRY CLASSIFICATION - SECOND JOB
*<_industry_2_>
	gen byte industry_2=.
	recode industry_2(1 2 5 =1) (10 11 12 13 14=2)
	forval i= 15/37 {
	recode industry_2 (`i'=3)
	}
	recode industry_2 (40 41 90 =4)(45=5)(50 51 52 55 =6)
	recode industry_2 (60 61 62 63 64 =7)
	recode industry_2 (65 66 67 70 71 72 73 74=8) (75 =9)
	recode industry_2 ( 80 85 90 91 92 93 95 99=10)
	label var industry_2 "1 digit industry classification- second job"
	la de lblindustry_2 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Communications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	replace industry_2=. if njobs==0 | njobs==. | lstatus2!=1
	label values industry_2 lblindustry_2
*<_industry_2_>


**SURVEY SPECIFIC INDUSTRY CLASSIFICATION - SECOND JOB
*<_industry_orig_2_>
	gen industry_orig_2=.
	replace industry_orig_2=. if njobs==0 | njobs==. | lstatus2!=1
	label var industry_orig_2 "Original Industry Codes - Second job"
	label values industry_orig_2 lblindustry_orig
*</_industry_orig_2>


** OCCUPATION CLASSIFICATION - SECOND JOB
*<_occup_2_>
	gen byte occup_2=.
	replace occup_2=1 if v10_032>=111 & v10_032<=131
	replace occup_2=2 if v10_032>=211 & v10_032<=246
	replace occup_2=3 if v10_032>=311 & v10_032<=348
	replace occup_2=4 if v10_032>=411 & v10_032<=422
	replace occup_2=5 if v10_032>=511 & v10_032<=523
	replace occup_2=6 if v10_032>=611 & v10_032<=621
	replace occup_2=7 if v10_032>=711 & v10_032<=744
	replace occup_2=8 if v10_032>=811 & v10_032<=833
	replace occup_2=9 if v10_032>=911 & v10_032<=933
	replace occup_2=10 if v10_032==11
	replace occup_2=99 if v10_032==999
	replace occup_2=. if njobs==0 | njobs==. | lstatus2!=1
	label var occup_2 "1 digit occupational classification - second job"
	la de lbloccup_2 1 "Senior officials" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup_2 lbloccup_2
*</_occup_2_>


** WAGES - SECOND JOB
*<_wage_2_>
	gen double wage_2=.
	replace wage_2= v12_15a2 if v12_15a2!=.
	replace wage_2=v12_082 if v12_082!=.
	replace wage_2=v12_212 if v12_212!=.
	replace wage_2=v12_042 if  v12_042!=.
	replace wage_2=0 if empstat==2
	replace wage_2=. if njobs==0 | njobs==. | lstatus2!=1
	label var wage_2 "Last wage payment - Second job"
*</_wage_2_>


** WAGES TIME UNIT - SECOND JOB
*<_unitwage_2_>
	gen byte unitwage_2=.
	replace unitwage_2=1 if v12_042!=.
	replace unitwage_2=5 if v12_15a2!=.
	replace unitwage_2=8 if v12_082!=.
	replace unitwage_2=8 if v12_212!=.
	replace  unitwage_2=. if lstatus2!=1
	label var unitwage_2 "Last wages time unit"
	la de lblunitwage_2 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Quarterly" 7 "Biannual" 8 "Annually" 9 "Hourly" 10 "Other"
	replace unitwage_2=. if njobs==0 | njobs==. | lstatus!=1
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

	local lb_var "lstatus lstatus_year empstat empstat_year njobs_year ocusec nlfreason unempldur_l unempldur_u industry_orig industry occup_orig occup firmsize_l firmsize_u whours wage unitwage empstat_2 empstat_2_year industry_2 industry_orig_2 occup_2 wage_2 unitwage_2"
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
	gen byte rbirth_juris=.
	label var rbirth_juris "Region of birth jurisdiction"
	la de lblrbirth_juris 1 "subnatid1" 2 "subnatid2" 3 "subnatid3" 4 "Other country"  9 "Other code"
	label values rbirth_juris lblrbirth_juris
*</_rbirth_juris_>

**REGION OF BIRTH
*<_rbirth_>
	gen byte rbirth=.
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

	gen byte landphone= v02_31a
	recode landphone (2=0)
	label var landphone "Household has landphone"
	la de lbllandphone 0 "No" 1 "Yes"
	label values landphone lbllandphone
*</_landphone_>


** CEL PHONE
*<_cellphone_>

	gen cellphone=  v02_31b
	recode cellphone (2=0)
	label var cellphone "Household has Cell phone"
	la de lblcellphone 0 "No" 1 "Yes"
	label values cellphone lblcellphone
*</_cellphone_>


** COMPUTER
*<_computer_>
	gen byte computer= v06_05Computer_Printer517==1 if  v06_05Computer_Printer517<.
	label var computer "Household has computer"
	la de lblcomputer 0 "No" 1 "Yes"
	label values computer lblcomputer
	note computer: "NPL 2010" Variable is defined as hh having computer and/printer	
	
*</_computer_>

** RADIO
*<_radio_>
	gen radio= v06_05Radio_cassette_CD_pl==1 if  v06_05Radio_cassette_CD_pl<.
	label var radio "Household has radio"
	la de lblradio 0 "No" 1 "Yes"
	label val radio lblradio
*</_radio_>

** TELEVISION
*<_television_>
	gen television= v06_05Television_VCR_VCD_P==1 if  v06_05Television_VCR_VCD_P<.
	label var television "Household has Television"
	la de lbltelevision 0 "No" 1 "Yes"
	label val television lbltelevision
*</_television>

** FAN
*<_fan_>
	gen fan= v06_05Fans508==1 if v06_05Fans508<.
	label var fan "Household has Fan"
	la de lblfan 0 "No" 1 "Yes"
	label val fan lblfan
*</_fan>

** SEWING MACHINE
*<_sewingmachine_>
	gen sewingmachine= v06_05Sewing_machine513==1 if  v06_05Sewing_machine513<.
	label var sewingmachine "Household has Sewing machine"
	la de lblsewingmachine 0 "No" 1 "Yes"
	label val sewingmachine lblsewingmachine
*</_sewingmachine>

** WASHING MACHINE
*<_washingmachine_>
	gen washingmachine= v06_05Washing_machine507==1 if  v06_05Washing_machine507<.
	label var washingmachine "Household has Washing machine"
	la de lblwashingmachine 0 "No" 1 "Yes"
	label val washingmachine lblwashingmachine
*</_washingmachine>

** REFRIGERATOR
*<_refrigerator_>
	gen refrigerator= v06_05Refrigerator_or_free==1 if  v06_05Refrigerator_or_free<.
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
	gen bicycle= v06_05Bicycle503==1 if v06_05Bicycle503<.
	label var bicycle "Household has Bicycle"
	la de lblbycicle 0 "No" 1 "Yes"
	label val bicycle lblbycicle
*</_bycicle>

** MOTORCYCLE
*<_motorcycle_>
	gen motorcycle= v06_05Motorcycle_scooter50==1 if  v06_05Motorcycle_scooter50<.
	label var motorcycle "Household has Motorcycle"
	la de lblmotorcycle 0 "No" 1 "Yes"
	label val motorcycle lblmotorcycle
*</_motorcycle>

** MOTOR CAR
*<_motorcar_>
	gen motorcar= v06_05Motor_car__etc_505==1 if  v06_05Motor_car__etc_505<.
	label var motorcar "Household has Motor car"
	la de lblmotorcar 0 "No" 1 "Yes"
	label val motorcar lblmotorcar
*</_motorcar>

** COW
*<_cow_>
	gen cow=v13_66yn1==1 if  v13_66yn1<.
	label var cow "Household has Cow"
	la de lblcow 0 "No" 1 "Yes"
	label val cow lblcow
*</_cow>

** BUFFALO
*<_buffalo_>
	gen buffalo= v13_66yn2==1 if  v13_66yn2<.
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
	
*QUINTILE, DECILE AND FOOD/NON-FOOD SHARES OF CONSUMPTION AGGREGATE
	levelsof year, loc(y)
	merge m:1 idh using "$shares\\NPL_fnf_`y'", keepusing (food_share nfood_share quintile_cons_aggregate decile_cons_aggregate)
	drop _merge

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

	keep countrycode year survey idh idp wgt pop_wgt strata psu vermast veralt urban int_month int_year fieldwork   ///
		subnatid1 subnatid2 subnatid3 subnatid4 gaul_adm1_code ownhouse landholding tenure water_orig piped_water water_jmp sar_improved_water  electricity toilet_orig sewage_toilet toilet_jmp sar_improved_toilet  landphone cellphone ///
		water_original water_source improved_water pipedwater_acc watertype_quest sanitation_original sanitation_source improved_sanitation toilet_acc ///
	     computer internet hsize relationharm relationcs male age soc marital ed_mod_age everattend ///
	     atschool electricity literacy educy educat4 educat5 educat7 lb_mod_age lstatus lstatus_year empstat empstat_year njobs njobs_year ///
	     ocusec nlfreason unempldur_l unempldur_u industry_orig industry occup_orig occup firmsize_l firmsize_u whours wage ///
		  unitwage empstat_2 empstat_2_year industry_2 industry_orig_2 occup_2 wage_2 unitwage_2 contract healthins socialsec union rbirth_juris rbirth rprevious_juris rprevious yrmove ///
		 landphone cellphone computer radio television fan sewingmachine washingmachine refrigerator lamp bicycle motorcycle motorcar cow buffalo chicken  ///
		 pline_nat pline_int poor_nat poor_int spdef cpi ppp cpiperiod welfare welfshprosperity welfarenom food_share nfood_share quintile_cons_aggregate decile_cons_aggregate welfaredef welfarenat welfareother welfaretype welfareothertype  
		 
** ORDER VARIABLES

	order countrycode year survey idh idp wgt pop_wgt strata psu vermast veralt urban int_month int_year fieldwork  ///
		subnatid1 subnatid2 subnatid3 subnatid4 gaul_adm1_code ownhouse landholding tenure water_orig piped_water water_jmp sar_improved_water water_original ///
		water_source improved_water pipedwater_acc watertype_quest electricity toilet_orig sewage_toilet toilet_jmp sar_improved_toilet ///
		sanitation_original sanitation_source improved_sanitation toilet_acc landphone cellphone ///
	     computer internet hsize relationharm relationcs male age soc marital ed_mod_age everattend ///
	     atschool electricity literacy educy educat4 educat5 educat7 lb_mod_age lstatus lstatus_year empstat empstat_year njobs njobs_year ///
	     ocusec nlfreason unempldur_l unempldur_u industry_orig industry occup_orig occup firmsize_l firmsize_u whours wage ///
		  unitwage empstat_2 empstat_2_year industry_2 industry_orig_2 occup_2 wage_2 unitwage_2 contract healthins socialsec union rbirth_juris rbirth rprevious_juris rprevious yrmove ///
		 landphone cellphone computer radio television fan sewingmachine washingmachine refrigerator lamp bicycle motorcycle motorcar cow buffalo chicken  ///
		 pline_nat pline_int poor_nat poor_int spdef cpi ppp cpiperiod welfare welfshprosperity welfarenom food_share nfood_share quintile_cons_aggregate decile_cons_aggregate welfaredef welfarenat welfareother welfaretype welfareothertype  

	
	
	compress

** DELETE MISSING VARIABLES

	glo keep=""
	qui levelsof countrycode, local(cty)
	foreach var of varlist countrycode - welfareothertype {
		capture assert mi(`var')
		if !_rc {
		
			 display as txt "Variable " as result "`var'" as txt " for countrycode " as result `cty' as txt " contains all missing values -" as error " Variable Deleted"
			 
		}
		else {
		
			 glo keep = "$keep"+" "+"`var'"
			 
		}
	}
	
	foreach w in welfare welfareother {
	
		qui su `w'
		if r(N)==0 {
		
		drop `w'type
		
		}
	}
	
	keep countrycode year survey idh idp wgt pop_wgt strata psu vermast veralt ${keep} *type

	compress

	saveold "`output'\Data\Harmonized\NPL_2010_LSS-III_v01_M_v04_A_SARMD_IND.dta", replace version(12)
	saveold "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\__REGIONAL\Individual Files\NPL_2010_LSS-III_v01_M_v04_A_SARMD_IND.dta", replace version(12)
	notes

	log close




******************************  END OF DO-FILE  *****************************************************/
