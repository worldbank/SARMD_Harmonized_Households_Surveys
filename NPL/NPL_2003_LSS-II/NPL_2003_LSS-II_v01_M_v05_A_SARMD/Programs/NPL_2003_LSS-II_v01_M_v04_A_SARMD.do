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
** MODIFIED BY		Fernando Enrique Morales Velandia
** Date				02/26/2018
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
	local output "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\NPL\NPL_2003_LSS-II\NPL_2003_LSS-II_v01_M_v04_A_SARMD"
	glo pricedata "D:\SOUTH ASIA MICRO DATABASE\CPI\cpi_ppp_sarmd_weighted.dta"
	glo shares "D:\SOUTH ASIA MICRO DATABASE\APPS\DATA CHECK\Food and non-food shares\NPL"
	glo fixlabels "D:\SOUTH ASIA MICRO DATABASE\APPS\DATA CHECK\Label fixing"

	
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
	
	use "`input'\Data\Stata\R2_Z10B2_WgEmplmntNAgri2.dta", clear
	duplicates drop WWWHH WWW HH r2_activcode, force
	tempfile nagri2
	save `nagri2'
	
	use "`input'\Data\Stata\R2_Z10A2_WgEmplmntAgri2.dta", clear
	duplicates drop WWWHH WWW HH r2_activcode, force
	tempfile agri2
	save `agri2'
	
	
	use "`input'\Data\Stata\R2_Z01C_Activities.dta", clear
	sort WWWHH r2_IDC r2_activcode
	
	
	merge m:1 WWWHH  r2_activcode using `nagri2'
	drop if _merge==2
	drop _merge
	
	merge m:1 WWWHH  r2_activcode using `agri2'
	drop if _merge==2
	drop _merge

	
	merge 1:1 WWWHH r2_IDC r2_activcode using "`input'\Data\Stata\R2_Z10B1_WgEmplmntNAgri.dta"
	ren _merge mergenonag
	
	merge 1:1 WWWHH r2_IDC r2_activcode using "`input'\Data\Stata\R2_Z10A1_WgEmplmntAgri.dta"
	ren _merge mergeag
	*Sort according to importance in time to make difference between first and second job
	gsort WWWHH r2_IDC -r2_12moswrkt -r2_12daypmwr -r2_12hourdwr -r2_7dayswork -r2_7hrperday -r2_7hrperwek
	egen aux=seq(), by( WWWHH r2_IDC)
	egen njobs_aux=count( aux), by( WWWHH r2_IDC)
	ren njobs_aux njobs
	keep if njobs<=2
	reshape wide  r2_activcode r2_occupdesc r2_occupcode r2_12moswrkt r2_12daypmwr r2_12hourdwr r2_7dayswork r2_7hrperday r2_7hrperwek r2_workinVDC r2_wrkindstr r2_wrkinurru r2_wgemplagr r2_wgemplnag r2_slemplagr r2_slemplnag r2_extecnwrk r2_na30salar r2_na30trnsp r2_na12bonus r2_na12cloth r2_na12other r2_nataxdedc r2_naprovdfn r2_napension r2_namedcare r2_nanumbwrk r2_nacntrtpm r2_agpyycash r2_agpyyink1 r2_agpyyink2 r2_agpyinkvl r2_agpyinkvt r2_aglbloane r2_agothrmem r2_agsharecr r2_agtlivest r2_agcntrtpm r2_nagactvit r2_nagacnsco r2_nagindust r2_nagacnsic r2_nagactpym r2_napdycash r2_napdyink1 r2_napdyink2 r2_napdinkvl r2_napdinkvt mergenonag r2_agactivit r2_agactnsco r2_agactpaym r2_agpdycash r2_agpdyink1 r2_agpdyink2 r2_agpdinkvl r2_agpdinkvt mergeag, i(WWWHH r2_IDC) j(aux)
	
	replace njobs=njobs-1 /*Put njobs in terms of additional jobs*/
	/*
	gsort WWWHH r2_IDC -r2_12moswrkt -r2_12daypmwr -r2_12hourdwr -r2_7dayswork -r2_7hrperday -r2_7hrperwek
	bys WWWHH r2_IDC: keep if _n==1*/
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
	
	use "`input'\Data\Stata\R2_Z11A1A_LandOwned.dta", clear
	sort WWWHH
	tempfile landown
	save `landown'

	use "`input'\Data\Stata\R2_Z06C_Durables.dta", clear
	sort WWWHH
	drop  r2_durbl_yr r2_durbl_hw r2_durbl_vt r2_durbl_vn r2_durbl_nm
	decode r2_durcode, gen (itc1)
	egen itc2=concat( itc1 r2_durcode )
	replace itc2=strtoname(itc2)
	replace itc2=substr(itc2, 1,20)
	keep WWWHH itc2 r2_durbl_yn
	reshape wide r2_durbl_yn, i( WWWHH ) j( itc2 ) string
	tempfile durables
	save `durables'

	use "`input'\Data\Stata\R2_Z11E1B_OwnLivestock2.dta", clear
	sort WWWHH
	drop  r2_lvstownrs r2_lvstown12no r2_lvstown12rs r2_lvstsld12no r2_lvstsld12rs r2_lvstbgt12no r2_lvstbgt12rs r2_lvstownno
	reshape wide r2_lvstyesno, i( WWWHH ) j( r2_lvestcode )
	tempfile livestock
	save `livestock'
	
		use  "`input'\Data\Stata\R2_Z00_SurveyInfo.dta", clear
	tempfile inform
	save `inform'

	
	* MERGE DATASETS
	
	use "`input'\Data\Stata\SAS_NPL_2003_04_NLSS2.dta"
	ren c2_hhsize c2_hhsize_
	keep WWW WWWHH weight popwt pcexp c2_nompln c2_npcexp c2_hhsize_ c2_poor c2_pindex c2_ra_pcexp
	
	sort WWW
	merge m:1 WWW using "`input'\Data\Stata\sample.dta"
	drop _merge
	
	sort WWWHH
	
	foreach x in property amenities1 amenities2 landown durables livestock inform{
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
	gen int_month=R2_V00_DINTM
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
	gen urban=urbrural
	recode urban (2=0)
	label var urban "Urban/Rural"
	la de lblurban 1 "Urban" 0 "Rural"
	label values urban lblurban
*</_urban_>


**MACRO REGIONAL AREAS
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
	la de lblsubnatid2 1 "Taplejung" 2 "Panchthar" 3 "Ilam" 4 "Jhapa" 5 "Morang" 6 "Sunsari" 7 "Dhankuta" 8 "Tehrathum" 9 "Sankhuwasabha" 10 "Bhojpur" 11 "Solukhumbu" 12 "Okhaldhunga" 13 "Khotang" 14 "Udayapur" 15 "Saptari" 16 "Siraha" 17 "Dhanusha" 18 "Mahottari" 19 "Sarlahi" 20 "Sindhuli" 21 "Ramechhap" 22 "Dolakha" 23 "Sindhupalchok" 24 "Kavrepalanchok" 25 "Lalitpur" 26 "Bhaktapur" 27 "Kathmandu" 28 "Nuwakot" 29 "Rasuwa" 30 "Dhading" 31 "Makwanpur" 32 "Rautahat"  33 "Bara" 34 "Parsa" 35 "Chitwan" 36 "Gorkha" 37 "Lamjung" 38 "Tanahun" 39 "Syangja" 40 "Kaski" 41 "Manang" 42 "Mustang" 43 "Myagdi"44 "Parbat" 45 "Baglung" 46 "Gulmi" 47 "Palpa" 48 "Nawalparasi" 49 "Rupandehi" 50 "Kapilbastu" 51 "Arghakhanchi" 52 "Pyuthan" 53 "Rolpa" 54 "Rukum" 55 "Salyan" 56 "Dang" 57 "Banke" 58 "Bardiya" 59 "Surkhet" 60 "Dailekh" 61 "Jajarkot" 62 "Dolpa" 63 "Jumla" 64 "Kalikot" 65 "Mugu" 66 "Humla" 67 "Bajura" 68 "Bajhang" 69 "Achham"  70 "Doti" 71 "Kailali" 72 "Kanchanpur" 73 "Dandheldhura" 74 "Baitadi" 75 "Darchula"
	label var subnatid2 "Region at 2 digit (ADMN2)"
	label values subnatid2 lblsubnatid2
		numlabel lblsubnatid2, remove
		numlabel lblsubnatid2, add mask("# - ")
		decode subnatid2, gen(subnatid2_temp)
		drop subnatid2
		rename subnatid2_temp subnatid2
*</_subnatid2_>


** REGIONAL AREA 2 DIGIT ADMN LEVEL
*<_subnatid3_>
	gen byte subnatid3=.
	label var subnatid3 "Region at 2 digit (ADMN2)"
	label values subnatid3 lblsubnatid3
*</_subnatid3_>



** REGIONAL AREA 3 DIGIT ADMN LEVEL
*<_subnatid4_>
	gen byte subnatid4=.
	label var subnatid4 "Region at 3 digit (ADMN3)"
	label values subnatid4 lblsubnatid4
*</_subnatid4_>


** HOUSE OWNERSHIP
*<_ownhouse_>
	gen byte ownhouse=r2_dwelowned
	recode ownhous 2=0
	label var ownhouse "House ownership"
	la de lblownhouse 0 "No" 1 "Yes"
	label values ownhouse lblownhouse
*</_ownhouse_>


** TENURE OF DWELLING
*<_tenure_>
   gen tenure=.
   replace tenure=1 if r2_dwelowned==1
   replace tenure=2 if r2_dwelstats==1
   replace tenure=3 if r2_dwelstats!=1 & r2_dwelstats<.
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
gen water_orig=r2_watersour
la var water_orig "Source of Drinking Water-Original from raw file"
#delimit
la def lblwater_orig 1 "Piped water supply"
					 2 "Covered well/Hand pump"
					 3 "Open well"
					 4 "Other water source";
#delimit cr
la val water_orig lblwater_orig
*</_water_orig_>

*PIPED SOURCE OF WATER
*<_piped_water_>
gen piped_water=.
replace piped_water=1 if r2_watersour==1 & r2_watersour!=.
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
replace sar_improved_water=1 if inlist(r2_watersour,1,2)
replace sar_improved_water=0 if inlist(r2_watersour,3,4)
la def lblsar_improved_water 1 "Improved" 0 "Unimproved"
la var sar_improved_water "Improved source of drinking water-using country-specific definitions"
la val sar_improved_water lblsar_improved_water
*</_sar_improved_water_>
  
  
*ORIGINAL WATER CATEGORIES
*<_water_original_>
clonevar j=r2_watersour
#delimit
la def lblwater_original 1 "Piped water supply"
						 2 "Covered well/Hand pump"
						 3 "Open well"
						 4 "Other water source";
#delimit cr
la val j lblwater_original		
decode j, gen(water_original)
drop j
la var water_original "Source of Drinking Water-Original from raw file"
*</_water_original_>

	** WATER SOURCE
	*<_water_source_>
		gen water_source=.
		replace water_source=1 if r2_watersour==1
		replace water_source=5 if r2_watersour==2
		replace water_source=10 if r2_watersour==3
		replace water_source=14 if r2_watersour==4
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
		gen pipedwater_acc=0 if inrange(r2_watersour,2,4) // Asuming other is not piped water
		replace pipedwater_acc=3 if inlist(r2_watersour,1)
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
	replace electricity=1 if r2_lightsrs==1
	replace electricity=0 if r2_lightsrs==3
	replace electricity=0 if r2_lightsrs==2
	label var electricity "Electricity main source"
	la de lblelectricity 0 "No" 1 "Yes"
	label values electricity lblelectricity
	notes electricity: "NPL 2003" The definition used was if household's main source of lighting is electricity
*</_electricity_>

*ORIGINAL TOILET CATEGORIES
*<_toilet_orig_>
gen toilet_orig=r2_toilettyp
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
gen sewage_toilet=r2_toilettyp
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
replace sar_improved_toilet=1 if inlist(r2_toilettyp,1,2)
replace sar_improved_toilet=0 if inlist(r2_toilettyp,3,4,5)
la def lblsar_improved_toilet 1 "Improved" 0 "Unimproved"
la var sar_improved_toilet "Improved type of sanitation facility-using country-specific definitions"
la val sar_improved_toilet lblsar_improved_toilet
*</_sar_improved_toilet_>


	** ORIGINAL SANITATION CATEGORIES 
	*<_sanitation_original_>
		clonevar j=r2_toilettyp
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
		replace sanitation_source=2 if r2_toilettyp==1
		replace sanitation_source=3 if r2_toilettyp==2
		replace sanitation_source=14 if r2_toilettyp==3
		replace sanitation_source=14 if r2_toilettyp==4
		replace sanitation_source=13 if r2_toilettyp==5
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

**POPULATION WEIGHT
*<_pop_wgt_>
	gen pop_wgt=wgt*hsize
	la var pop_wgt "Population weight"
*</_pop_wgt_>

	
** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
*<_relationharm_>
	gen byte relationharm=r2_relation
	recode relationharm (5=4) (4 6 7 8 9 0 10 11=5) (12 13 14=6)
	label var relationharm "Relationship to the head of household"
	la de lblrelationharm  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Non-relatives"
	label values relationharm  lblrelationharm

* FIX HARMONIZED RELATIONSHIP TO HEAD OF HOUSEHOLDS FOR HOUSEHOLDS WITH MORE OR LESS THAN ONE HEAD
	
	gen head=relationharm==1
	bys idh: egen heads=total(head)
	
	replace relationharm=5 if r2_relation==1 & heads>1 & heads!=. & r2_IDC!=1

	drop head heads
*</_relationharm_>

** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
*<_relationcs_>

	gen byte relationcs=r2_relation
	la var relationcs "Relationship to the head of household country/region specific"
	la define lblrelationcs 1 "Head" 2 "Husband/Wife" 3 "Son/Daughter" 4 "Grandchild" 5 "Father/Mother" 6 "Brother/Sister" 7 "Nephew/Niece" 8 "Son/Daughter-in-law" 9 "Brother/Sister-in-law" 10 "Father/Mother-in-law" 11 "Other family relative" 12 "Servant/servant's relative" 13 "Tenant/tentant's relative" 14 "Other person not related"
	label values relationcs lblrelationcs
*</_relationcs_>



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
	replace age=98 if age>=98
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
	gen byte educy= inter_edlevel
	recode educy (-1 = 0) (13 = 15) (14 15 = 17)
	label var educy "Years of education"
	notes educy: "NPL 2003" There is a substraction of 1 year in the computation of years of schooling for those currently attending
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

** LABOR STATUS
*<_lstatus_>
	gen byte lstatus=.
	replace lstatus=1 if r2_occupcode1>=1 & r2_occupcode1<990
	replace lstatus=2 if r2_unm_lkwkr==1
	replace lstatus=3 if r2_unm_lkwkr==2 
	replace lstatus=3 if r2_occupcode1==998
	replace lstatus=3 if r2_occupcode1==997
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus
	notes lstatus: "NPL 2003" the present definition of unemployment does not take into account availability to work
*</_lstatus_>


** LABOR STATUS
*<_lstatus_>
	gen byte lstatus2=.
	replace lstatus2=1 if r2_occupcode2>=1 & r2_occupcode2<990
	replace lstatus2=2 if r2_unm_lkwkr==1
	replace lstatus2=3 if r2_unm_lkwkr==2 
	replace lstatus2=3 if r2_occupcode2==998
	replace lstatus2=3 if r2_occupcode2==997
	label var lstatus2 "Labor status"
	la de lbllstatus2 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus2 lbllstatus2
	notes lstatus2: "NPL 2003" the present definition of unemployment does not take into account availability to work
*</_lstatus_>



** LABOR STATUS LAST YEAR
*<_lstatus_year_>
	gen byte lstatus_year=.
	replace lstatus_year=lstatus
	replace lstatus_year=0 if lstatus>1 & !mi(lstatus)
	replace lstatus_year=. if age<lb_mod_age & age!=.
	label var lstatus_year "Labor status during last year"
	la de lbllstatus_year 1 "Employed" 0 "Not employed" 
	label values lstatus_year lbllstatus_year
	note lstatus_year: "NPL 2003" The period of reference of lstatus and lstatus_year is the same: yearly
*</_lstatus_year_>


** LABOR STATUS LAST YEAR
*<_lstatus_year_>
	gen byte lstatus_year2=.
	replace lstatus_year2=lstatus2
	replace lstatus_year2=0 if lstatus2>1 & !mi(lstatus2)
	replace lstatus_year2=. if age<lb_mod_age & age!=.
	label var lstatus_year2 "Labor status during last year"
	la de lbllstatus_year2 1 "Employed" 0 "Not employed" 
	label values lstatus_year2 lbllstatus_year2
	note lstatus_year: "NPL 2003" The period of reference of lstatus and lstatus_year is the same: yearly
*</_lstatus_year_>



** EMPLOYMENT STATUS
*<_empstat_>
	gen byte empstat=.
	replace empstat=1 if r2_wgemplagr1==1 | r2_wgemplnag1==1
	replace empstat=4 if r2_slemplagr1==1 | r2_slemplnag1==1
	replace empstat=. if lstatus==2 | lstatus==3 
	label var empstat "Employment status"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed"
	label values empstat lblempstat
*</_empstat_>


** EMPLOYMENT STATUS LAST YEAR
*<_empstat_year_>
	gen byte empstat_year=.
	replace empstat_year=empstat if empstat!=.
	replace empstat_year=. if lstatus_year!=1
	label var empstat_year "Employment status during last year"
	la de lblempstat_year 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat_year lblempstat_year
	note empstat_year: "NPL 2003" The period of reference of empstat and empstat_year is the same: yearly

*</_empstat_year_>



** SECTOR OF ACTIVITY: PUBLIC - PRIVATE
*<_njobs_>
	label var njobs "Number of additional jobs"
	*replace njobs=. if lstatus!=1
	
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
	replace nlfreason=1 if r2_unm_whynt==1
	replace nlfreason=2 if r2_unm_whynt==2
	replace nlfreason=3 if r2_unm_whynt==3
	replace nlfreason=5 if r2_unm_whynt==4 | r2_unm_whynt==12
	replace nlfreason=4 if r2_unm_whynt==5
	replace nlfreason=. if lstatus!=3
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
	*replace industry_orig=1 if mergeag1==3
#delimit 
la def lblindustry_orig
	1	" agri and related"
	2	"forestry, logging"
	5	"fishing, operation"
	10	"mining of coal"
	11	"extraction of crude"
	12	"mining of uranium"
	13	"mining os metal ores"
	14	"other mining/quarrying"
	15	"food products/beverages"
	16	"tobacco products"
	17	"textiles"
	18	"wearing apprel"
	19	"tanning/dressing of leather"
	20	"wood products"
	21	"paper products"
	22	"publishing/printing"
	23	"coke, refined petrolium"
	24	"chemicals products"
	25	"rubber/plasics products"
	26	"other non-metalic products"
	27	"basic metals"
	28	"fabricated metal products"
	29	"machinery & equipment n"
	30	"office/accounting/computing"
	31	"electrical machinery"
	32	"radio/tv/com"
	33	"medical, precision"
	34	"motor vehicles/trailers"
	35	"other transport equipment"
	36	"furniture"
	37	"recycling"
	40	"electricity and gas supply"
	41	"coll/dis of water"
	45	"construction"
	50	"sale/maint"
	51	"wholesale trade"
	52	"retail trade"
	55	"hotels and restaurants"
	60	"land transport"
	61	"water transport"
	62	"air transport"
	63	"support auxi"
	64	"post and telecommunications"
	65	"financial intermediation"
	66	"insurance and pension funding"
	67	"activities auxi"
	70	"real estate activities"
	71	"renting of machinery/equipment"
	72	"computer and related act"
	73	"research and development"
	74	"other business activities"
	75	"public administration/defence"
	80	"education"
	85	"health and social work"
	90	"sewage and refuse disposal"
	91	"activities of membership org"
	92	"recreational/sporting act"
	93	"other service activities"
	95	"private hhlds with emp"
	99	"extra-territorial organization";
	#delimit cr
	la val industry_orig lblindustry_orig
	replace industry_orig=. if lstatus!=1
	la var industry_orig "Original industry code"
*</_industry_orig_>

** INDUSTRY CLASSIFICATION
*<_industry_>
	*recode r2_nagacnsic1 (1/5=1) (10/14=2) (15/36=3) (37/41=4) (45=5) (50/55=6) (60/64=7) (65/74=8) (75=9) (80/99=10) , gen(industry)
	*replace industry=1 if mergeag1==3
	gen industry=.
	replace industry=. if lstatus==2| lstatus==3
	label var industry "1 digit industry classification"
	la de lblindustry 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Comnunications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industry lblindustry
	notes industry: "NPL 2003" This variable is coded only for waged workers. Self-employed ared excluded
*</_industry_>

**ORIGINAL OCCUPATION CLASSIFICATION
*<_occup_orig_>
	gen occup_orig=r2_occupcode1
	#delimit
	la def lbloccup_orig
	11	"ARMED FORCES"
	111	"LEGISLATORS"
	112	"GOVERNMENT OFFICIALS"
	114	"OFFICIALS OF SPECIAL INTEREST ORGANIZATIONS"
	121	"DIRECTORS AND CHIEF EXECUTIVES"
	122	"PRODUCTION AND OPERATIONS DEPARTMENT MANAGERS"
	123	"OTHER DEPARTMENT MANAGERS"
	131	"GENERAL MANAGERS/MANAGING PROPRIETORS"
	211	"PHYSICISTS, CHEMISTS AND RELATED"
	212	"MATHEMATICIANS, STATISTICIANS AND RELATED"
	213	"COMPUTING PROFESSIONALS"
	214	"ARCHITECTS, ENGINEERS AND RELATED"
	221	"LIFE SCIENCE PROFESSIONALS"
	222	"HEALTH PROFESSIONALS, EXCEPT NURSING"
	223	"NURSING AND MIDWIFERY PROFESSIONALS"
	231	"COLLEGE, UNIVERSITY AND HIGHER EDUCATION"
	232	"SECONDARY EDUCATION TEACHING PROFESSIONALS"
	233	"PRIMARY AND PRE-PRIMARY EDUCATION TEACHING"
	234	"SPECIAL EDUCATION TEACHING PROFESSIONALS"
	235	"OTHER TEACHING PROFESSIONALS"
	241	"BUSINESS PROFESSIONALS"
	242	"LEGAL PROFESSIONALS"
	243	"ARCHIVISTS, LIBRARIANS AND RELATED"
	244	"SOCIAL SCIENCE AND RELATED PROFESSIONALS"
	245	"WRITERS AND CREATIVE OR PERFORMING ARTISTS"
	246	"RELIGIOUS PROFESSIONALS"
	311	"PHYSICAL AND ENGINEERING SCIENCE TECHNICIANS"
	312	"COMPUTER ASSOCIATE PROFESSIONALS"
	313	"OPTICAL AND ELECTRONIC EQUIPMENT OPERATORS"
	314	"AIRCRAFT CONTROLLERS AND TECHNICIANS"
	315	"SAFETY AND QUALITY INSPECTORS"
	321	"LIFE SCIENCE TECHNICIANS AND RELATED"
	322	"MODERN HEALTH ASSOCIATE PROFESSIONAL, EXCEPT"
	323	"NURSING AND MIDWIFERY ASSOCIATE PROFESSIONALS"
	324	"TRADITIONAL MEDICINE PRACTITIONERS AND FAITH"
	331	"PRIMARY EDUCATION TEACHING ASSOCIATE"
	332	"PRE-PRIMARY EDUCATION TEACHING ASSOCIATE"
	333	"SPECIAL EDUCATION TEACHING ASSOCIATE"
	334	"OTHER TEACHING ASSOCIATE PROFESSIONALS"
	341	"FINANCE AND SALES ASSOCIATE PROFESSIONALS"
	342	"BUSINESS SERVICES AGENT AND TRADE BROKERS"
	343	"ADMINISTRATIVE ASSOCIATE PROFESSIONALS"
	344	"CUSTOMS, TAX AND RELATED GOVERNMENT ASSOCIATE"
	345	"POLICE INSPECTORS AND DETECTIVES"
	346	"SOCIAL WORK ASSOCIATE PROFESSIONALS"
	347	"ARTISTIC, ENTERTAINMENT AND SOPRTS ASSOCIATE"
	348	"RELIGIOUS ASSOCIATE PROFESSIONALS"
	411	"SECRETARIES AND KEYBOARD-OPERATING"
	412	"NUMERICAL CLERKS/OFFICE ASSISTANTS"
	413	"MATERIAL-RECORDING AND TRANSPORT"
	414	"LIBRARY, MAIL AND RELATED CLERKS/OFFICE"
	419	"OTHER OFFICE CLERKS/ASSISTANTS"
	421	"CASHIERS, TELLERS AND RELATED CLERKS/OFFICE"
	422	"CLIENT INFORMATION CLERKS/OFFICE ASSISTANTS"
	511	"TRAVEL ATTENDANTS AND RELATED WORKERS"
	512	"HOUSEKEEPING AND RESTAURANT SERVICES WORKERS"
	513	"PERSONAL CARE AND RELATED WORKERS"
	514	"OTHER PROFESSIONAL SERVICES WORKERS"
	515	"ASTROLOGERS, FORTUNE-TELLERS AND RELATED"
	516	"PROTECTIVE SERVICE WORKERS"
	521	"FASHION AND OTHER MODELS"
	522	"SHOP SALESPERSONS AND DEMONSTRATOTRS"
	523	"STALL AND MARKET SALESPERSONS"
	611	"MARKET-ORIENTED GARDENERS AND CROP GROWERS"
	612	"MARKET-ORIENTED ANIMAL PRODUCERS AND RELATED"
	613	"MARKET-ORIENTED CROP AND ANIMAL PRODUCERS"
	614	"FORESTRY AND RELATED WORKERS"
	615	"FISHERY WORKERS"
	621	"SUBSISTENCE AGRICULTURAL AND FISHERY WORKERS"
	711	"MINERS, SHOFTIRERS, STONE CUTTERS AND CARVERS"
	712	"BUILDING FRAME AND RELATED TRADES WORKERS"
	713	"BUILDING FINISHERS AND RELATED TRADES WORKERS"
	714	"PAINTERS, BUILDING STRUCTURE CLEANERS AND"
	721	"METAL MOULDERS, WELDERS, SHEET-METAL WORKERS,"
	722	"BLACKSMITHS, TOOL-MAKERS AND RELATED TRADES"
	723	"MACHINERY MECHANICS AND FITTERS"
	724	"ELECTRICAL AND ELECTRONIC EQUIPMENT MECHANICS"
	731	"PRECISION WORKERS IN METAL AND RELATED"
	732	"POTTERS, GLASS-MAKERS AND RELATED TRADES"
	733	"HANDICRAFT WORKERS IN WOOD, TEXTILE, LEATHER"
	734	"PRINTING AND RELATED TRADES WORKERS"
	741	"FOOD PROCESSING AND RELATED TRADES WORKERS"
	742	"WOOD TREATERS, CABINET-MAKERS AND RELATED"
	743	"TEXTILE, GARMENT AND RELATED TRADES WORKERS"
	744	"PELT, LEATHER AND SHOE MAKING TRADES WORKERS"
	811	"MINING AND MINERAL-PROCESSING PLANT OPERATORS"
	812	"METAL-PROCESSING-PLANT OPERATORS"
	813	"GLASS, CERAMICS AND RELATIVE PLANT OPERATORS"
	814	"WOOD-PROCESSING AND PAPERMAKING-PLANT"
	815	"CHEMICAL-PROCESSING-PLANT OPERATORS"
	816	"POWER-PRODUCTION AND RELATED PLANT OPERATORS"
	817	"AUTOMATED-ASSEMBLY-LINE AND INDUSTRIAL-ROBOT"
	821	"METAL AND MINERAL PRODUCTS MACHINE OPERATORS"
	822	"CHEMICAL-PRODUCTS MACHINE OPERATORS"
	823	"RUBBER AND PLASTIC PRODUCTS MACHINE OPERATORS"
	824	"WOOD-PRODUCTS MACHINE OPERATORS"
	825	"PRINTING, BINDING AND PAPER PRODUCTS MACHINE"
	826	"TEXTILE, FUR AND LEATHER-PRODUCTS MACHINE"
	827	"FOOD AND RELATED PRODUCTS MACHINE OPERATORS"
	828	"ASSEMBLERS"
	829	"OTHER MACHINE OPERATORS AND ASSEMBLERS"
	831	"LOCOMOTIVE-ENGINE DRIVERS AND RELATED WORKERS"
	832	"MOTOR VEHICLE DRIVERS"
	833	"AGRICULTURAL AND OTHER MOBILE-PLANT OPERATORS"
	911	"STREET VENDORS AND RELATED WORKERS"
	912	"SHOE CLEANING AND OTHER STREET SERVICES"
	913	"DOMESTIC AND RELATED HELPERS, CLEANERS AND"
	914	"BUILDING CARETAKERS, WINDOWS AND RELATED"
	915	"MESSENGERS, PORTERS, DOORKEEPERS AND RELATED"
	916	"GARBAGE COLLECTORS AND RELATED LABOURERS"
	921	"AGRICULTURAL, FISHERY AND RELATED LABOURERS"
	931	"MINING AND CONSTRUCTION LABOURERS"
	932	"MANUFACTURING LABOURERS"
	933	"TRANSPORT LABOURERS AND FREIGHT HANDLERS"
	997	"HOUSEHOLD WORK"
	998	"STUDENT"
	999	"NOT WORKING";
	#delimit cr
	la val occup_orig lbloccup_orig
	replace occup_orig=. if lstatus!=1
	la var occup_orig "Original occupation code"
*</_occup_orig_>

** OCCUPATION CLASSIFICATION
*<_occup_>
	gen occup=int(r2_occupcode1/100)
	replace occup=. if r2_occupcode1==997 | r2_occupcode1==998 | r2_occupcode1==999
	replace occup=10 if r2_occupcode1==11
	replace occup=. if lstatus==2| lstatus==3
	label var occup "1 digit occupational classification"
	la de lbloccup 1 "Senior officials" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup lbloccup
*</_occup_>

* Fix industry based on occupation
	*replace industry=1 if occup==6 & lstatus==1
	
	
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
	gen whours=r2_7hrperwek1
	replace whours=. if lstatus!=1
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

notes _dta: "NPL 2003" Not all sources of wage are included in the survey-specially for aggricultural employment-and variable is created as missing.

** WAGES TIME UNIT
*<_unitwage_>
	gen byte unitwage=.
	label var unitwage "Last wages time unit"
	la de lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Quarterly" 7 "Biannual" 8 "Annually" 9 "Hourly" 10 "Other"
	label values unitwage lblunitwage
*</_wageunit_>



** EMPLOYMENT STATUS - SECOND JOB
*<_empstat_2_>
	gen byte empstat_2=.
	replace empstat_2=1 if r2_wgemplagr2==1 | r2_wgemplnag2==1
	replace empstat_2=4 if r2_slemplagr2==1 | r2_slemplnag2==1
	replace empstat_2=. if njobs==0 | njobs==. | lstatus2!=1
	label var empstat_2 "Employment status - second job"
	la de lblempstat_2 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat_2 lblempstat_2
*</_empstat_2_>

** EMPLOYMENT STATUS - SECOND JOB LAST YEAR
*<_empstat_2_year_>
	gen byte empstat_2_year=.
	replace empstat_2_year=empstat_2
	replace empstat_2_year=. if njobs_year==0 | njobs_year==. | lstatus2!=1
	label var empstat_2_year "Employment status - second job"
	la de lblempstat_2_year 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat_2_year lblempstat_2
*</_empstat_2_>

** INDUSTRY CLASSIFICATION - SECOND JOB
*<_industry_2_>
	*recode r2_nagacnsic2 (1/5=1) (10/14=2) (15/36=3) (37/41=4) (45=5) (50/55=6) (60/64=7) (65/74=8) (75=9) (80/99=10) , gen(industry_2)
	gen industry_2=.
	*replace industry_2=1 if mergeag2==3
	replace industry_2=. if njobs==0 | njobs==. | lstatus2!=1
	label var industry_2 "1 digit industry classification - second job"
	la de lblindustry_2 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Comnunications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industry_2 lblindustry
*<_industry_2_>


**SURVEY SPECIFIC INDUSTRY CLASSIFICATION - SECOND JOB
*<_industry_orig_2_>
	*gen industry_orig_2=r2_nagacnsic2
	*replace industry_orig_2=1 if mergeag2==3
	gen industry_orig_2=.
	replace industry_orig_2=. if njobs==0 | njobs==. | lstatus2!=1
	label var industry_orig_2 "Original Industry Codes - Second job"
	la de lblindustry_orig_2 1""
	label values industry_orig_2 lblindustry_orig
*</_industry_orig_2>


** OCCUPATION CLASSIFICATION - SECOND JOB
*<_occup_2_>
	gen occup_2=int(r2_occupcode2/100)
	replace occup_2=. if r2_occupcode2==997 | r2_occupcode2==998 | r2_occupcode2==999
	replace occup_2=10 if r2_occupcode2==11
	replace occup_2=. if njobs==0 | njobs==. | lstatus2!=1
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

	gen byte landphone=r2_telephone
	recode landphone (2=0)
	label var landphone "Household has landphone"
	la de lbllandphone 0 "No" 1 "Yes"
	label values landphone lbllandphone
*</_landphone_>


** CEL PHONE
*<_cellphone_>

	gen cellphone=r2_teleph_mb
	recode cellphone (2=0)
	label var cellphone "Household has Cell phone"
	la de lblcellphone 0 "No" 1 "Yes"
	label values cellphone lblcellphone
*</_cellphone_>


** COMPUTER
*<_computer_>
	gen byte computer=r2_durbl_yncomputer_printer517==1 if r2_durbl_yncomputer_printer517!=.
	label var computer "Household has Computer"
	la de lblcomputer 0 "No" 1 "Yes"
	label values computer lblcomputer
	note computer: "NPL 2003" Variable is defined as hh having computer and/printer	
*</_computer_>

** RADIO
*<_radio_>
	gen radio=r2_durbl_ynradio_cassette_playe==1 if r2_durbl_ynradio_cassette_playe!=.
	label var radio "Household has radio"
	la de lblradio 0 "No" 1 "Yes"
	label val radio lblradio
*</_radio_>

** TELEVISION
*<_television_>
	gen television=r2_durbl_yntv_vcr_vcd510==1 if r2_durbl_yntv_vcr_vcd510!=.
	label var television "Household has Television"
	la de lbltelevision 0 "No" 1 "Yes"
	label val television lbltelevision
*</_television>

** FAN
*<_fan_>
	gen fan=r2_durbl_ynfans508==1 if r2_durbl_ynfans508!=.
	label var fan "Household has Fan"
	la de lblfan 0 "No" 1 "Yes"
	label val fan lblfan
*</_fan>

** SEWING MACHINE
*<_sewingmachine_>
	gen sewingmachine=r2_durbl_ynsewing_machine513==1 if r2_durbl_ynsewing_machine513!=.
	label var sewingmachine "Household has Sewing machine"
	la de lblsewingmachine 0 "No" 1 "Yes"
	label val sewingmachine lblsewingmachine
*</_sewingmachine>

** WASHING MACHINE
*<_washingmachine_>
	gen washingmachine=r2_durbl_ynwashing_machine507==1 if r2_durbl_ynwashing_machine507!=.
	label var washingmachine "Household has Washing machine"
	la de lblwashingmachine 0 "No" 1 "Yes"
	label val washingmachine lblwashingmachine
*</_washingmachine>

** REFRIGERATOR
*<_refrigerator_>
	gen refrigerator=r2_durbl_ynrefrigerator_freezer==1 if r2_durbl_ynrefrigerator_freezer!=.
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
	gen bicycle=r2_durbl_ynbicycle503==1 if r2_durbl_ynbicycle503!=.
	label var bicycle "Household has Bicycle"
	la de lblbycicle 0 "No" 1 "Yes"
	label val bicycle lblbycicle
*</_bycicle>

** MOTORCYCLE
*<_motorcycle_>
	gen motorcycle=r2_durbl_ynmotorcycle_scooter50==1 if r2_durbl_ynmotorcycle_scooter50!=.
	label var motorcycle "Household has Motorcycle"
	la de lblmotorcycle 0 "No" 1 "Yes"
	label val motorcycle lblmotorcycle
*</_motorcycle>

** MOTOR CAR
*<_motorcar_>
	gen motorcar=r2_durbl_ynmotor_car__etc_505==1 if r2_durbl_ynmotor_car__etc_505!=.
	label var motorcar "Household has Motor car"
	la de lblmotorcar 0 "No" 1 "Yes"
	label val motorcar lblmotorcar
*</_motorcar>

** COW
*<_cow_>
	gen cow=r2_lvstyesno1==1 if r2_lvstyesno1!=.
	label var cow "Household has Cow"
	la de lblcow 0 "No" 1 "Yes"
	label val cow lblcow
*</_cow>

** BUFFALO
*<_buffalo_>
	gen buffalo=r2_lvstyesno2==1 if r2_lvstyesno2!=.
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

	keep countrycode year survey idh idp wgt pop_wgt strata psu vermast veralt urban int_month int_year subnatid1  ///
		subnatid2 subnatid3 subnatid4 gaul_adm1_code ownhouse landholding tenure water_orig piped_water water_jmp sar_improved_water  electricity toilet_orig sewage_toilet toilet_jmp sar_improved_toilet  landphone cellphone ///
	    computer internet hsize relationharm relationcs male age soc marital ed_mod_age everattend ///
		water_original water_source improved_water pipedwater_acc watertype_quest sanitation_original sanitation_source improved_sanitation toilet_acc ///
	    atschool electricity literacy educy educat4 educat5 educat7 lb_mod_age lstatus lstatus_year empstat empstat_year njobs njobs_year ///
	    ocusec nlfreason unempldur_l unempldur_u industry_orig industry occup_orig occup firmsize_l firmsize_u whours wage ///
		unitwage empstat_2 empstat_2_year industry_2 industry_orig_2 occup_2 wage_2 unitwage_2 contract healthins socialsec union rbirth_juris rbirth rprevious_juris rprevious yrmove ///
		landphone cellphone computer radio television fan sewingmachine washingmachine refrigerator lamp bicycle motorcycle motorcar cow buffalo chicken  ///
		pline_nat pline_int poor_nat poor_int spdef cpi ppp cpiperiod welfare welfshprosperity welfarenom food_share nfood_share quintile_cons_aggregate decile_cons_aggregate welfaredef welfarenat welfareother welfaretype welfareothertype  
		 
** ORDER VARIABLES

	order countrycode year survey idh idp wgt pop_wgt strata psu vermast veralt urban int_month int_year subnatid1 ///
		subnatid2 subnatid3 subnatid4 gaul_adm1_code ownhouse landholding tenure water_orig piped_water water_jmp sar_improved_water ///
		water_original water_source improved_water pipedwater_acc watertype_quest electricity toilet_orig sewage_toilet ///
		toilet_jmp sar_improved_toilet sanitation_original sanitation_source improved_sanitation toilet_acc landphone cellphone ///
	    computer internet hsize relationharm relationcs male age soc marital ed_mod_age everattend ///
	    atschool electricity literacy educy educat4 educat5 educat7 lb_mod_age lstatus lstatus_year empstat empstat_year njobs njobs_year ///
	    ocusec nlfreason unempldur_l unempldur_u industry_orig industry occup_orig occup firmsize_l firmsize_u whours wage ///
		unitwage empstat_2 empstat_2_year industry_2 industry_orig_2 occup_2 wage_2 unitwage_2 contract healthins socialsec union rbirth_juris rbirth rprevious_juris rprevious yrmove ///
		landphone cellphone computer radio television fan sewingmachine washingmachine refrigerator lamp bicycle motorcycle motorcar cow buffalo chicken  ///
		pline_nat pline_int poor_nat poor_int spdef cpi ppp cpiperiod welfare welfshprosperity welfarenom food_share nfood_share ///
		quintile_cons_aggregate decile_cons_aggregate welfaredef welfarenat welfareother welfaretype welfareothertype  
		
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

	saveold "`output'\Data\Harmonized\NPL_2003_LSS-II_v01_M_v04_A_SARMD-FULL_IND.dta", replace version(12)
	saveold "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\__REGIONAL\Individual Files\NPL_2003_LSS-II_v01_M_v04_A_SARMD-FULL_IND.dta", replace version(12)
	
	notes

	log close

*********************************************************************************************************************************	
******RENAME COMPARABLE VARIABLES AND SAVE THEM IN _SARMD. UNCOMPARABLE VARIALBES ACROSS TIME SHOULD BE FOUND IN _SARMD-FULL*****
*********************************************************************************************************************************

loc var cellphone pline_nat pline_int poor_nat poor_int spdef cpi ppp cpiperiod welfare welfarenom welfaredef welfarenat welfareother welfshprosperity ///
 welfareothertype industry_orig industry industry_2 industry_orig_2 lb_mod_age lstatus lstatus_year empstat empstat_year njobs ///
 njobs_year nlfreason occup_orig occup whours empstat_2 empstat_2_year occup_2 piped_water water_jmp sar_improved_water food_share nfood_share quintile_cons_aggregate decile_cons_aggregate
 
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
	note _dta: "NPL 2003" Variables NAMED with "v2" are those not compatible with latest round (2010). ///
 These include the existing information from the particular survey, but the iformation should be used for comparability purposes  



	saveold "`output'\Data\Harmonized\NPL_2003_LSS-II_v01_M_v04_A_SARMD_IND.dta", replace version(12)
	saveold "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\__REGIONAL\Individual Files\NPL_2003_LSS-II_v01_M_v04_A_SARMD_IND.dta", replace version(12)
	

******************************  END OF DO-FILE  *****************************************************/
