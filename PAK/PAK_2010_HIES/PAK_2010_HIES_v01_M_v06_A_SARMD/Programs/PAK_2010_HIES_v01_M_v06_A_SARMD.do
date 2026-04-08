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
** RESPONSIBLE		Adriana Castillo Castillo
** Modified by		Adriana Castillo Castillo
** Date:			12/20/2021

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
    
	global rootdatalib "P:\SARMD\SARDATABANK\SAR_DATABANK"
	local v "6"


** DIRECTORY
    local input      "$rootdatalib\PAK\PAK_2010_HIES\PAK_2010_HIES_v01_M"
	local output     "$rootdatalib\PAK\PAK_2010_HIES\PAK_2010_HIES_v01_M_v0`v'_A_SARMD"
	*glo pricedata   "D:\SOUTH ASIA MICRO DATABASE\CPI\cpi_ppp_sarmd_weighted.dta"
	global shares    "P:\SARMD\SARDATABANK\APPS\DATA CHECK\Food and non-food shares\PAK"
	global fixlabels "P:\SARMD\SARDATABANK\APPS\DATA CHECK\Label fixing"
	
** LOG FILE
	log using "`output'\Doc\Technical\PAK_2010_PSLM_v01_M_v0`v'_A.log",replace


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

	drop if _merge==1
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
	tempfile ref
	save `ref'
	
**Add durables
	use "`input'\Data\Stata\sec 7_m", clear
	keep hhcode code S7mq02
	decode code, gen(itc)
	egen itc2=concat( itc code )
	replace itc2=strtoname(itc2)
	replace itc2=substr(itc2, 1,20)
	keep hhcode itc2 S7mq02
	ren S7mq02 numdur
	reshape wide numdur, i(hhcode) j( itc2 ) string
	tempfile durables
	save `durables'

/***Add livestock assets
	use "`input'\Data\Stata\sec 10b_qb", clear
	duplicates report hhcode codes
	keep hhcode codes s10bA
	decode codes, gen(itc)
	egen itc2=concat( itc codes )
	replace itc2=strtoname(itc2)
	replace itc2=substr(itc2, 1,20)
	rename s10bA numlivestock
	keep hhcode numlivestock itc2
	reshape wide numlivestock, i( hhcode ) j( itc2 ) string
	tempfile agri
	save `agri'*/

*Add landholding info	

/*	use "`input'\Data\Stata\Sec F1", clear
	keep if q1to10==1
	keep if sf1col1==1
	ren sf1col1 landholding
	duplicates report hhcode
	keep hhcode landholding
	tempfile landholding 
	save `landholding'*/

tempfile weights
use "`input'\Data\Stata\hhweights", clear
save `weights'

	use `ref', clear
	foreach s in  durables weights{
	merge m:1 hhcode using ``s''
	ta _merge
	drop if _merge==2
	drop _merge
	}
	
	*Merge with spatial deflator
	*rename psu psu_old
	*gen psu = real(substr(string(hhcode, "%20.0g"), 1, 7))
	*format psu %20.0g
	merge m:1 psu using "$rootdatalib\PAK\PAK_2010_HIES\PAK_2010_HIES_v01_M\Data\Stata\psu_paasche_2010_pdef1.dta", nogen 

	
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


	
**FIELD WORKD***
*<_fieldwork_> 
gen fieldwork=ym(int_year, int_month)
format %tm fieldwork
la var fieldwork "Date of fieldwork"
*<_/fieldwork_> 


	
** HOUSEHOLD IDENTIFICATION NUMBER
*<_idh_>
	clonevar hhcode1=hhcode
	tostring hhcode1, replace u
	gen idh=hhcode1
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
	*egen wgt=max(weight), by(idh countrycode year)
	gen wgt=weight
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

	gen veralt="0`v'"
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


** REGIONAL AREA 2 DIGIT ADMN LEVEL
*<_subnatid1_>
	gen byte subnatid2=.
	label var subnatid2 "Region at 2 digit (ADMN2)"


** REGIONAL AREA 1 DIGIT ADMN LEVEL
*<_subnatid2_>
	gen byte subnatid1=province
	la de lblsubnatid1 1 "Punjab" 2 "Sindh" 3 "Khyber Pakhtunkhwa" 4 "Balochistan"
	label var subnatid1 "Region at 1 digit (ADMN1)"
	label values subnatid1 lblsubnatid1
		numlabel lblsubnatid1, remove
		numlabel lblsubnatid1, add mask("# - ")
		decode subnatid1, gen(subnatid1_temp)
		drop subnatid1
		rename subnatid1_temp subnatid1
*</_subnatid2_>

*<_gaul_adm1_code_>
	gen gaul_adm1_code=.
	label var gaul_adm1_code "GAUL code for admin1 level"
	replace gaul_adm1_code=2019 if subnatid1=="1 - Punjab"
	replace gaul_adm1_code=2020 if subnatid1=="2 - Sindh"
	replace gaul_adm1_code=2016 if subnatid1=="3 - Khyber Pakhtunkhwa"
	replace gaul_adm1_code=2015 if subnatid1=="4 - Balochistan"
*<_gaul_adm1_code_>

	
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

** TENURE OF DWELLING
*<_tenure_>
   gen tenure=.
   replace tenure=1 if sgq01==1 | sgq01==2
   replace tenure=2 if sgq01==3
   replace tenure=3 if sgq01==4 | sgq01==5 
   label var tenure "Tenure of Dwelling"
   la de lbltenure 1 "Owner" 2"Renter" 3"Other"
   la val tenure lbltenure
*</_tenure_>	


** LANDHOLDING
*<_lanholding_>
	gen landholding=.
	la val landholding a
	label var landholding "Household owns any land"
   *la de lbllandholding 0 "No" 1 "Yes"
   *la val landholding lbllandholding
   notes landholding: "PAK 2010" the structure of relevant question changed for this round, compared with other rounds. 
*</_landholding_>	


*ORIGINAL WATER CATEGORIES
*<_water_orig_>
gen water_orig=sgq05
la var water_orig "Source of Drinking Water-Original from raw file"
#delimit
la def lblwater_orig 1 "Tap (in home, courtyard)"
					 2 "Tap (outiside the home)"
					 3 "Hand pump" 
					 4 "Water motor"
					 5 "Covered well" 
				     6 "Open well"
					 7 "River, Stream, Pond, etc"
					 8 "Tanker truck, water" 
			         9 "Mineral water fetcher"
					 10 "Others (specify)";
#delimit cr
la val water_orig lblwater_orig
*</_water_orig_>

*PIPED SOURCE OF WATER
*<_piped_water_>
gen piped_water=.
replace piped_water=1 if sgq05==1 | sgq05==2 
replace piped_water=0 if inlist(sgq05,3,4,5,6,7,8,9,10)
la var piped_water "Household has access to piped water"
la def lblpiped_water 1 "Yes" 0 "No"
la val piped_water lblpiped_water
note piped_water: "PAK 2010" This variable is created if water is piped in hh or through a tab.
*</_piped_water_>



**INTERNATIONAL WATER COMPARISON (Joint Monitoring Program)
*<_water_jmp_>
gen water_jmp=.
replace water_jmp=1 if inlist(sgq05,1)
replace water_jmp=2 if inlist(sgq05,2)
replace water_jmp=4 if inlist(sgq05,3,4)
replace water_jmp=5 if inlist(sgq05,5)
replace water_jmp=6 if inlist(sgq05,6)
replace water_jmp=12 if inlist(sgq05,7)
replace water_jmp=10 if inlist(sgq05,8)
replace water_jmp=14 if inlist(sgq05,9,10)

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
note water_jmp: "PAK 2010" Category 'Spring' and mineral water from raw data is coded as missing, given that it is an ambigous category to 'protected spring' 'unprotected spring'
 *</_water_jmp_>

 *SAR improved source of drinking water
*<_sar_improved_water_>
gen sar_improved_water=.
replace sar_improved_water=1 if inlist(water_jmp,1,2,3,4,5,7,9,13)
replace sar_improved_water=0 if inlist(water_jmp, 6,8,10,11,12,14)
la def lblsar_improved_water 1 "Improved" 0 "Unimproved"
la var sar_improved_water "Improved source of drinking water-using country-specific definitions"
la val sar_improved_water lblsar_improved_water
*</_sar_improved_water_>


*ORIGINAL WATER CATEGORIES
*<_water_original_>
clonevar j=sgq05
#delimit
la def lblwater_original 1 "Tap (in home, courtyard)"
						 2 "Tap (outiside the home)"
						 3 "Hand pump" 
						 4 "Water motor"
						 5 "Covered well" 
						 6 "Open well"
						 7 "River, Stream, Pond, etc"
						 8 "Tanker truck, water" 
						 9 "Mineral water fetcher"
						 10 "Others (specify)";
#delimit cr
la val j lblwater_original		
decode j, gen(water_original)
drop j
la var water_original "Source of Drinking Water-Original from raw file"
*</_water_original_>


	** WATER SOURCE
	*<_water_source_>
		gen water_source=.
		replace water_source=1 if sgq05==1
		replace water_source=2 if sgq05==2
		replace water_source=4 if sgq05==3
		replace water_source=4 if sgq05==4
		replace water_source=5 if sgq05==5
		replace water_source=10 if sgq05==6
		replace water_source=13 if sgq05==7
		replace water_source=12 if sgq05==8
		replace water_source=13 if sgq05==9
		replace water_source=14 if sgq05==10
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
		gen pipedwater_acc=0 if inrange(sgq05,3,10) // Asuming other is not piped water
		replace pipedwater_acc=1 if inlist(sgq05,1)
		replace pipedwater_acc=2 if inlist(sgq05,2)
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
	recode sgq08 (1=1) (2 3 4 5 6 = 0), gen(electricity)
	label var electricity "Electricity main source"
	la de lblelectricity 0 "No" 1 "Yes"
	label values electricity lblelectricity
	note electricity: "PAK 2010" this variable is generated if hh main source of lighting is electricity. Take into account for comparability purposes with other rounds.
*</_electricity_>


*ORIGINAL TOILET CATEGORIES
*<_toilet_orig_>
gen toilet_orig=sgq06
la var toilet_orig "Access to sanitation facility-Original from raw file"
#delimit
la def lbltoilet_orig 1 "Facility not available"
					  2 "Flush system (linked with sewerage)"
					  3 "Flush (Linked with septic tank)"
					  4 "Flush (connected with open drain)"
					  5 "Privy seat"
					  6 "Digged ditch"
					  7 "Others";
#delimit cr
la val toilet_orig lbltoilet_orig
*</_toilet_orig_>


*SEWAGE TOILET
*<_sewage_toilet_>
gen sewage_toilet=.
replace sewage_toilet=1 if sgq06==2
replace sewage_toilet=0 if inlist(sgq06,1,3,4,5,6,7)
la var sewage_toilet "Household has access to sewage toilet"
la def lblsewage_toilet 1 "Yes" 0 "No"
la val sewage_toilet lblsewage_toilet
*</_sewage_toilet_>



**INTERNATIONAL SANITATION COMPARISON (Joint Monitoring Program)
*<_toilet_jmp_>
gen toilet_jmp=.
replace toilet_jmp=12 if toilet_orig==1
replace toilet_jmp=1 if toilet_orig==2
replace toilet_jmp=3 if toilet_orig==3
replace toilet_jmp=13 if inlist(toilet_orig, 4,5,6,7)
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
replace sar_improved_toilet=1 if inlist(toilet_jmp,1,2,3,6,7,9)
replace sar_improved_toilet=0 if inlist(toilet_jmp,4,5,8,10,11,12,13)

la def lblsar_improved_toilet 1 "Improved" 0 "Unimproved"
la var sar_improved_toilet "Improved type of sanitation facility-using country-specific definitions"
la val sar_improved_toilet lblsar_improved_toilet
*</_sar_improved_toilet_>


	** ORIGINAL SANITATION CATEGORIES 
	*<_sanitation_original_>
		clonevar j=sgq06
		#delimit
		la def lblsanitation_original   1 "Facility not available"
										2 "Flush system (linked with sewerage)"
										3 "Flush (Linked with septic tank)"
										4 "Flush (connected with open drain)"
										5 "Privy seat"
										6 "Digged ditch"
										7 "Others";
		#delimit cr
		la val j lblsanitation_original
		decode j, gen(sanitation_original)
		drop j
		la var sanitation_original "Access to sanitation facility-Original from raw file"
	*</_sanitation_original_>


	** SANITATION SOURCE
	*<_sanitation_source_>
		gen sanitation_source=.
		replace sanitation_source=13 if sgq06==1
		replace sanitation_source=2 if sgq06==2
		replace sanitation_source=3 if sgq06==3
		replace sanitation_source=14 if sgq06==4
		replace sanitation_source=14 if sgq06==5
		replace sanitation_source=14 if sgq06==6
		replace sanitation_source=14 if sgq06==7
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



**POPULATION WEIGHT
*<_pop_wgt_>
	gen pop_wgt=wgt*hsize
	la var pop_wgt "Population weight"
*</_pop_wgt_>


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
	replace age=98 if age>=98 & age!=.
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
	notes literacy: "PAK 2010" literacy questions are only asked to individuals 10 years or older
	replace literacy=. if age<10
*</_literacy_>



** YEARS OF EDUCATION COMPLETED
*<_educy_>

			/*
			===========================================
			code	level						years
			===========================================
			1		class 1						1
			2		class 2						2
			3		class 3						3
			4		class 4						4
			5		class 5						5
			6		class 6						6
			7		class 7						7
			8		class 8						8
			9		class 9						9
			10		class 10					10
			11		class 11					11
			12		class 12					12
			13		class 13					13
			17		diploma						13
			14		b.a/b.sc.					14
			15		class 15					15
			16		post graduate (m.a/m.sc.)	16
			18		degree in engineering		16
			20		degree in agriculture		16
			21		degree in law				16
			19		degree in medicine			17
			22		m. phil, ph.d				19
			23		other						NA
			=============================================
			*/	

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
	replace educy=. if age<educy & age!=. & educy!=.
*</_educy_>

/*
** EDUCATION LEVEL 7 CATEGORIES
*<_educat7_>
	gen byte educat7=1 if Scq04==0
	replace educat7=2 if Scq04 >0 & Scq04<8
	replace educat7=3 if Scq04==8
	replace educat7=4 if Scq04>8 &  Scq04<12
	replace educat7=5 if Scq04==12
	replace educat7=7 if Scq04>12 & Scq04<=22
*	replace educat7=6 if Scq04==17
	replace educat7=. if Scq04==23
	replace educat7=. if age<ed_mod_age & age!=.
	label define lbleducat7 1 "No education" 2 "Primary incomplete" 3 "Primary complete" ///
	4 "Secondary incomplete" 5 "Secondary complete" 6 "Higher than secondary but not university" /// 
	7 "University incomplete or complete" 8 "Other" 9 "Not classified"
	label values educat7 lbleducat7
	la var educat7 "Level of education 7 categories"
*</_educat7_>
*/


** EDUCATION LEVEL 7 CATEGORIES
*<_educat7_>
	gen educat7 = .
	*Attended in the past 
	replace educat7 = 1 if Scq03 == 2 //Never attended 
	replace educat7 = 2 if Scq04 < 5
	replace educat7 = 3 if Scq04 == 5
	replace educat7 = 4 if Scq04 >= 6  & Scq04 < 10  & Scq04 != . 
	replace educat7 = 5 if Scq04 == 10
	replace educat7 = 6 if Scq04 >= 11 & Scq04 <= 12  
	replace educat7 = 7 if inlist(Scq04,13,14,15,16,17,18,19,20,21,22)
	replace educat7 = 8 if Scq04 == 23
	*Currently attending
	sort idh idp 
	replace educat7 = 2 if (Scq06 >= 1   & Scq06 <= 5)  & Scq05==1
	replace educat7 = 3 if (Scq06 >= 6   & Scq06 <= 9)  & Scq05==1
	replace educat7 = 4 if (Scq06 == 10) & Scq05==1
	replace educat7 = 5 if (Scq06 >= 11  & Scq06 <= 12) & Scq05==1
	replace educat7 = 7 if inlist(Scq06,13,14,15,16,17,18,19,20,21,22)
	replace educat7 = 8 if (Scq06 == 23 ) & Scq05==1    & educat7==.
	replace educat7=.z if Scq07==3 | Scq07==6
	*Without the minimum age 
	replace educat7=. if age<ed_mod_age & age!=.
	*People with education years bigger than their age
	replace educat7=. if educy>age & age!=.  & educy!=.
	
	label define lbleducat7 					///
	1 "No education" 							///
	2 "Primary incomplete" 						///
	3 "Primary complete" 						///
	4 "Secondary incomplete" 					///
	5 "Secondary complete" 						 ///
	6 "Higher than secondary but not university" /// 
	7 "University incomplete or complete"  		 ///
	8 "Other" 9 "Not classified" 				 
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
	replace educat5=.z if  educat7==.z
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
	replace educat4=.z if  educat7==.z
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
	
	
	foreach var in atschool literacy educy everattend educat4 educat5 educat7{
replace `var'=. if age<ed_mod_age
}

	
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

** LABOR STATUS LAST YEAR
*<_lstatus_year_>
	gen byte lstatus_year=.
	replace lstatus_year=. if age<lb_mod_age & age!=.
	label var lstatus_year "Labor status during last year"
	la de lbllstatus_year 1 "Employed" 2 "Unemployed" 3 "Non-in-labor force"
	label values lstatus_year lbllstatus_year
*</_lstatus_year_>

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

** EMPLOYMENT STATUS LAST YEAR
*<_empstat_year_>
	gen byte empstat_year=.
	replace empstat_year=. if lstatus_year!=1
	label var empstat_year "Employment status during last year"
	la de lblempstat_year 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat_year lblempstat_year
*</_empstat_year_>


** NUMBER OF ADDITIONAL JOBS
*<_njobs_>
	gen byte njobs=.

	replace njobs=. if lstatus!=1
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


**ORIGINAL INDUSTRY CLASSIFICATION
*<_industry_orig_>
	gen industry_orig=Seq05
#delimit
la def 	lblindustry_orig
	1	"Agriculture, hunting and forestry"
	2	"Forestry, logging and related service activities"
	5	"Fishing, aquaculture and service activities incidental to fishing"
	10	"Mining of coal and lignite; extraction of peat"
	11	"Extraction of crude petroleum and natural gas; service activities incidental to oil and gas extraction, excluding surveying"
	13	"Mining of metal ores"
	12	"Mining of uranium and thorium ores"
	14	"Other mining and quarrying"
	15	"Manufacture of food products and beverages"
	16	"Manufacture of tobacco products"
	17	"Manufacture of textiles"
	18	"Manufacture of wearing apparel; dressing and dyeing of fur"
	19	"Tanning and dressing of leather; manufacture of luggage, handbags, saddlery, harness and footwear"
	20	"Manufacture of wood and of products of wood and cork, except furniture; manufacture of articles of straw and plaiting materials"
	21	"Manufacture of paper and paper products"
	22	"Publishing, printing and reproduction of recorded media"
	23	"Manufacture of coke, refined petroleum products and nuclear fuel"
	24	"Manufacture of chemicals and chemical products"
	25	"Manufacture of rubber and plastics products"
	26	"Manufacture of other non-metallic mineral products"
	27	"Manufacture of basic metals"
	28	"Manufacture of fabricated metal products, except machinery and equipment"
	29	"Manufacture of machinery and equipment n.e.c."
	30	"Manufacture of office, accounting and computing machinery"
	31	"Manufacture of electrical machinery and apparatus n.e.c."
	32	"Manufacture of radio, television and communication equipment and apparatus"
	33	"Manufacture of medical, precision and optical instruments, watches and clocks"
	34	"Manufacture of motor vehicles, trailers and semi-trailers"
	35	"Manufacture of other transport equipment"
	36	"Manufacture of furniture; manufacturing n.e.c."
	37	"Recycling"
	40	"Electricity, gas, steam and hot water supply"
	41	"Collection, purification and distribution of water"
	45	"Construction"
	51	"Wholesale trade and commission trade, except of motor vehicles and motorcycles"
	50	"Sale, maintenance and repair of motor vehicles and motorcycles; retail sale of automotive fuel"
	52	"Retail trade, except of motor vehicles and motorcycles; repair of personal and household goods"
	55	"Hotels and restaurants"
	60	"Land transport; transport via pipelines"
	61	"Water transport"
	62	"Air transport"
	63	"Supporting and auxiliary transport activities; activities of travel agencies"
	64	"Post and telecommunications"
	65	"Financial intermediation, except insurance and pension funding"
	67	"Activities auxiliary to financial intermediation"
	66	"Insurance and pension funding, except compulsory social security"
	70	"Real estate activities"
	71	"Renting of machinery and equipment without operator and of personal and household goods"
	72	"Computer and related activities"
	73	"Research and development"
	74	"Other business activities"
	75	"Public administration and defence; compulsory social security"
	90	"Sewage and refuse disposal, sanitation and similar activities"
	80	"Education"
	85	"Health and social work"
	91	"Activities of membership organizations n.e.c."
	92	"Recreational, cultural and sporting activities"
	93	"Other service activities"
	95	"Activities of private households as employers of domestic staff"
	96	"Undifferentiated goods-producing activities of private households for own use"
	97	"Undifferentiated service-producing activities of private households for own use"
	99	"Extraterritorial organizations and bodies"
	0	"Activities not adequately defined";
	#delimit cr
	la val industry_orig lblindustry_orig
	replace industry_orig=. if lstatus!=1
	la var industry_orig "Original industry code"
*</_industry_orig_>



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

**ORIGINAL OCCUPATION CLASSIFICATION
*<_occup_orig_>
	gen occup_orig=Seq04
	label define lbloccup_orig 1 `"armed forces"', modify
	label define lbloccup_orig 11 `"legislators and senior officials"', modify
	label define lbloccup_orig 12 `"cooperate managers"', modify
	label define lbloccup_orig 13 `"general managers"', modify
	label define lbloccup_orig 21 `"physical, mathematical"', modify
	label define lbloccup_orig 22 `"life science and health"', modify
	label define lbloccup_orig 23 `"teaching professionals"', modify
	label define lbloccup_orig 24 `"other professionals"', modify
	label define lbloccup_orig 31 `"physical and engineering science"', modify
	label define lbloccup_orig 32 `"life science and health associate"', modify
	label define lbloccup_orig 33 `"teaching associate professionals"', modify
	label define lbloccup_orig 34 `"other associate professionals"', modify
	label define lbloccup_orig 41 `"office clerks"', modify
	label define lbloccup_orig 42 `"customer services clerks"', modify
	label define lbloccup_orig 51 `"personal and protective"', modify
	label define lbloccup_orig 52 `"models, salespersons"', modify
	label define lbloccup_orig 61 `"market-oriented skilled agricultural"', modify
	label define lbloccup_orig 62 `"subsistence agricultural"', modify
	label define lbloccup_orig 71 `"extraction and building"', modify
	label define lbloccup_orig 72 `"Metal, Machinery And Related Trades Workers ( Metal Moulders, Welders, Sheet-Metal Workers,Structural-Metal, etc)"', modify 
	label define lbloccup_orig 73 `"precision, handicraft, printing"', modify
	label define lbloccup_orig 74 `"other craft and related trades workers"', modify
	label define lbloccup_orig 81 `"stationary-plant and related operators"', modify
	label define lbloccup_orig 82 `"machine operators and assemblers"', modify
	label define lbloccup_orig 83 `"drivers and mobile-plant operators"', modify
	label define lbloccup_orig 91 `"sales and services elementary"', modify
	label define lbloccup_orig 92 `"agricultural, fishery and related labourers"', modify
	label define lbloccup_orig 93 `"labourers in mining, construction,"', modify
	la val occup_orig lbloccup_orig
	replace occup_orig=. if lstatus!=1
	la var occup_orig "Original occupation code"
*</_occup_orig_>



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
	gen double wage=.
	replace wage=Seq08 if Seq08!=.
	replace wage=Seq10 if Seq10!=.
	replace wage=. if lstatus!=1
	label var wage "Last wage payment"
	notes wage: "PAK 2010" this variable is reported monthly and yearly
*</_wage_>


** WAGES TIME UNIT
*<_unitwage_>
	gen byte unitwage=.
	replace unitwage=5 if Seq08!=.
	replace unitwage=8 if Seq10!=.
	replace unitwage=. if lstatus!=1
	label var unitwage "Last wages time unit"
	la de lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Every two months"  5 "Monthly" 6 "Quarterly" 7 "Every six months" 8 "Annually" 9 "Hourly" 10 "Other"
	label values unitwage lblunitwage
	notes unitwage: "PAK 2010" this variable is reported monthly and yearly
*</_wageunit_>

** EMPLOYMENT STATUS - SECOND JOB
*<_empstat_2_>
	gen byte empstat_2=.
	replace empstat_2=. if njobs==0 | njobs==.
	label var empstat_2 "Employment status - second job"
	la de lblempstat_2 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat_2 lblempstat_2
*</_empstat_2_>

** EMPLOYMENT STATUS - SECOND JOB LAST YEAR
*<_empstat_2_year_>
	gen empstat_2_year=1 if Seq14==4
	replace empstat_2_year=2 if Seq14==5
	replace empstat_2_year=3 if Seq14==1 | Seq14==2
	replace empstat_2_year=4 if Seq14==3 | Seq14>=6 & Seq14<=9
	replace   empstat_2_year=. if Seq11!=1
	label var empstat_2_year "Employment status - second job"
	la de lblempstat_2_year 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat_2_year lblempstat_2_year
*</_empstat_2_>

** INDUSTRY CLASSIFICATION - SECOND JOB
*<_industry_2_>
	gen byte industry_2=1 if Seq13>=1 & Seq13<=5
	replace industry_2=2 if Seq13>=10 & Seq13<=14
	replace industry_2=3 if Seq13>=15 & Seq13<=37
	replace industry_2=4 if Seq13>=40 & Seq13<=41
	replace industry_2=5 if Seq13==45
	replace industry_2=6 if Seq13>=51 & Seq13<=55
	replace industry_2=7 if Seq13>=60 & Seq13<=64
	replace industry_2=8 if Seq13>=65 & Seq13<=74
	replace industry_2=9 if Seq13==75
	replace industry_2=10 if Seq13>=80 & Seq13<=99
	replace   industry_2=. if Seq11!=1
	label var industry_2 "1 digit industry classification - second job"
	la de lblindustry_2 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Comnunications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industry_2 lblindustry_2
*<_industry_2_>


**SURVEY SPECIFIC INDUSTRY CLASSIFICATION - SECOND JOB
*<_industry_orig_2_>
	gen industry_orig_2=Seq13
	label var industry_orig_2 "Original Industry Codes - Second job"
	la de lblindustry_orig_2 1""
	label values industry_orig_2 lblindustry_orig_2
*</_industry_orig_2>


** OCCUPATION CLASSIFICATION - SECOND JOB
*<_occup_2_>
	gen byte occup_2=.
	replace occup_2=10 if Seq12==1
	replace occup_2=1 if Seq12>=11 & Seq12<=13
	replace occup_2=2 if Seq12>=21 & Seq12<=24
	replace occup_2=3 if Seq12>=31 & Seq12<=34
	replace occup_2=4 if Seq12>=41 & Seq12<=42
	replace occup_2=5 if Seq12>=51 & Seq12<=52
	replace occup_2=6 if Seq12>=61 & Seq12<=62
	replace occup_2=7 if Seq12>=71 & Seq12<=74
	replace occup_2=8 if Seq12>=81 & Seq12<=83
	replace occup_2=9 if Seq12>=91 & Seq12<=93
	replace   occup_2=. if Seq11!=1
	label var occup_2 "1 digit occupational classification - second job"
	la de lbloccup_2 1 "Senior officials" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup_2 lbloccup_2
*</_occup_2_>


** WAGES - SECOND JOB
*<_wage_2_>
	gen  wage_2=Seq15
	replace   wage_2=. if Seq11!=1
	label var wage_2 "Last wage payment - Second job"
*</_wage_2_>


** WAGES TIME UNIT - SECOND JOB
*<_unitwage_2_>
	gen  unitwage_2=8 if wage_2!=.
	replace   unitwage_2=. if Seq11!=1
	label var unitwage_2 "Last wages time unit - Second job"
	la de lblunitwage_2 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Every two months"  5 "Monthly" 6 "Quarterly" 7 "Every six months" 8 "Annually" 9 "Hourly" 10 "Other"
	label values unitwage_2 lblunitwage_2
*</_unitwage_2_>

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

foreach var in lstatus lstatus_year empstat empstat_year njobs njobs_year ocusec nlfreason unempldur_l unempldur_u industry_orig industry occup_orig occup firmsize_l firmsize_u whours wage unitwage empstat_2 empstat_2_year industry_2 industry_orig_2 occup_2 wage_2 unitwage_2 contract healthins socialsec union{
replace `var'=. if age<lb_mod_age
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

notes _dta: "PAK 2010" information on assets comes from durables list, which states the number of items owned by hh at present
notes _dta: "PAK 2010" The relevant question from module 10B only provides information on exepected values from owned animals, not quantities. This would hinder comparability of measurement with other countries.  


** LAND PHONE
*<_landphone_>
	gen byte landphone=.
	*replace landphone=1 if sgq09==2 | sgq09==4
	*replace landphone=0 if sgq09==1 | sgq09==3 
	label var landphone "Household has landphone"
	la de lbllandphone 0 "No" 1 "Yes"
	label values landphone lbllandphone
	notes landphone: "PAK 2010" land and mobile phone connection is taken.
*</_landphone_>


** CEL PHONE
*<_cellphone_>
	gen byte cellphone=1 if sgq09==3 | sgq09==4
	replace cellphone=0 if sgq09==1 | sgq09==2
	label var cellphone "Household has Cell phone"
	la de lblcellphone 0 "No" 1 "Yes"
	label values cellphone lblcellphone
*</_cellphone_>


** COMPUTER
*<_computer_>
	gen byte computer=.
	label var computer "Household has computer"
	la de lblcomputer 0 "No" 1 "Yes"
	label values computer lblcomputer
*</_computer_>

** RADIO
*<_radio_>
	gen radio= numdurRadio___cassette_pla>0 & numdurRadio___cassette_pla<.
	label var radio "Household has radio"
	la de lblradio 0 "No" 1 "Yes"
	label val radio lblradio
*</_radio_>

** TELEVISION
*<_television_>
	gen television= numdurtv716>0 & numdurtv716<.
	label var television "Household has Television"
	la de lbltelevision 0 "No" 1 "Yes"
	label val television lbltelevision
*</_television>

** FAN
*<_fan_>
	gen fan= numdurFan__Ceiling__Table_>0 & numdurFan__Ceiling__Table_<.
	label var fan "Household has Fan"
	la de lblfan 0 "No" 1 "Yes"
	label val fan lblfan
*</_fan>

** SEWING MACHINE
*<_sewingmachine_>
	gen sewingmachine= numdurSewing_Knitting_Mach>0 & numdurSewing_Knitting_Mach<.
	label var sewingmachine "Household has Sewing machine"
	la de lblsewingmachine 0 "No" 1 "Yes"
	label val sewingmachine lblsewingmachine
*</_sewingmachine>

** WASHING MACHINE
*<_washingmachine_>
	gen washingmachine= numdurWashing_machine_drye>0 & numdurWashing_machine_drye<.
	label var washingmachine "Household has Washing machine"
	la de lblwashingmachine 0 "No" 1 "Yes"
	label val washingmachine lblwashingmachine
*</_washingmachine>

** REFRIGERATOR
*<_refrigerator_>
	gen refrigerator= numdurRefrigerator701>0 & numdurRefrigerator701<.
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
	gen bicycle=numdurBicycle713>0 & numdurBicycle713<.
	label var bicycle "Household has Bicycle"
	la de lblbycicle 0 "No" 1 "Yes"
	label val bicycle lblbycicle
*</_bycicle>

** MOTORCYCLE
*<_motorcycle_>
	gen motorcycle= numdurMotorcycle_scooter71>0 & numdurMotorcycle_scooter71<.
	label var motorcycle "Household has Motorcycle"
	la de lblmotorcycle 0 "No" 1 "Yes"
	label val motorcycle lblmotorcycle
*</_motorcycle>

** MOTOR CAR
*<_motorcar_>
	gen motorcar= numdurCar___Vehicle714>=0 & numdurCar___Vehicle714<.
	label var motorcar "Household has Motor car"
	la de lblmotorcar 0 "No" 1 "Yes"
	label val motorcar lblmotorcar
*</_motorcar>

** COW
*<_cow_>
	gen cow=.
	la val cow a
	label var cow "Household has Cow"
	*la de lblcow 0 "No" 1 "Yes"
	*label val cow lblcow
*</_cow>

** BUFFALO
*<_buffalo_>
	gen buffalo=.
	la val buffalo a
	label var buffalo "Household has Buffalo"
	*la de lblbuffalo 0 "No" 1 "Yes"
	*label val buffalo lblbuffalo
*</_buffalo>

** CHICKEN
*<_chicken_>
	gen chicken=.
	la val chicken a
	label var chicken "Household has Chicken"
	*la de lblchicken 0 "No" 1 "Yes"
	*label val chicken lblchicken
*</_chicken>


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
	*gen welfare=nomexpend/hsize
	gen welfare=(nomexpend/hsize)/psupindm_n 
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

*QUINTILE, DECILE AND FOOD/NON-FOOD SHARES OF CONSUMPTION AGGREGATE
	levelsof year, loc(y)
	merge m:1 hhcode using "$shares\\PAK_fnf_`y'", keepusing (food_share nfood_share quintile_cons_aggregate decile_cons_aggregate) gen(_merge2)
	drop _merge2



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
	/*
	capture drop _merge
	gen urb=.
	merge m:1 countrycode year urb using "$pricedata", ///
	keepusing(countrycode year urb syear cpi`year'_w ppp`year')
	drop urb
	drop if _merge!=3
	drop _merge
	*/
	
    preserve 
	datalibweb, country(Support) year(2005) type(GMDRAW) surveyid(Support_2005_CPI_v06_M) filename(Monthly_CPI.dta)
    keep if inlist(code,"PAK")
	keep code year month yearly_cpi monthly_cpi
    keep if month==1 // From 2004 we keep January from next year as the reference month 
    
    keep code year month yearly_cpi monthly_cpi
    gen jan_nextyear=monthly_cpi[_n+1] 
    foreach x of numlist 11 17 {
     egen yearly_cpi20`x'    =mean(yearly_cpi) if year==20`x' 
     egen m_yearly_cpi20`x'  =mean(yearly_cpi20`x')
     drop yearly_cpi20`x'
     rename m_yearly_cpi20`x' yearly_cpi20`x'
	 gen cpi20`x'_06=(jan_nextyear/yearly_cpi20`x') 
    }
    keep code year cpi20*
    tempfile cpibasedata_M_PAK_06
    save `cpibasedata_M_PAK_06'
	restore 
	merge m:1 year using `cpibasedata_M_PAK_06', nogen keep(match)
	
	*ren cpi`year'_w cpi
	label variable cpi2011_06 "CPI (CPI from January 2011 base 2011)"
	label variable cpi2017_06 "CPI (CPI from January 2011 base 2017)"
*</_cpi_>
	
	
** PPP VARIABLE
*<_ppp_>
	preserve
	datalibweb, country(Support) year(2005) type(GMDRAW) surveyid(Support_2005_CPI_v05_M) filename(Yearly_CPI_Final.dta)
    keep if inlist(code,"PAK") 
    collapse (mean) ppp_2011 ppp_2017, by(countryname code ppp_domain_value)
    *replace ppp_domain=0 if ppp_domain_value==2
    *rename ppp_domain_value datalevel
    *replace datalevel=2 if datalevel==1 & code!="IND"
    tempfile pppdata
    save `pppdata', replace
	restore 
	merge m:1 code using `pppdata', nogen keep(match)
	
	*ren ppp`year' 	ppp
	label variable cpi2011_06 "PPP (base 2011)"
	label variable cpi2017_06 "PPP (base 2017)"
*</_ppp_>

	
** CPI PERIOD
*<_cpiperiod_>
	gen cpiperiod="2011m1"
	label var cpiperiod "Periodicity of CPI (year, year&month, year&quarter, weighted)"
*</_cpiperiod_>	
	
** POVERTY LINE (POVCALNET) 1.9
*<_pline_int_>
	gen pline_int_19=1.90*cpi2011_06*ppp_2011*365/12
	label variable pline_int "Poverty Line 1.9 (Povcalnet)"
*</_pline_int_>
		
*<_poor_int_>
	gen poor_int_19=welfare<pline_int_19 & welfare!=.
	la var poor_int_19 "People below Poverty Line (Povcalnet)"
	la define poor_int_19 0 "Not Poor" 1 "Poor"
	la values poor_int_19 poor_int_19
	tab poor_int_19 [aw= weight] if !mi(poor_int_19)
*</_poor_int_>


** POVERTY LINE (POVCALNET) 3.2
*<_pline_int_>
	gen pline_int_32=3.20*cpi2011_06*ppp_2011*365/12
	label variable pline_int_32 "Poverty Line 1.9 (Povcalnet)"
*</_pline_int_>
		
*<_poor_int_>
	gen poor_int_32=welfare<pline_int_32 & welfare!=.
	la var poor_int_32 "People below Poverty Line (Povcalnet)"
	la define poor_int_32 0 "Not Poor" 1 "Poor"
	la values poor_int_32 poor_int_32 
	tab poor_int_32 [aw= weight] if !mi(poor_int_32)
*</_poor_int_>


** POVERTY LINE (POVCALNET) 5.5
*<_pline_int_>
	gen pline_int_55=5.50*cpi2011_06*ppp_2011*365/12
	label variable pline_int_55 "Poverty Line 1.9 (Povcalnet)"
*</_pline_int_>
		
*<_poor_int_>
	gen poor_int_55=welfare<pline_int_55 & welfare!=.
	la var poor_int_55 "People below Poverty Line (Povcalnet)"
	la define poor_int_55 0 "Not Poor" 1 "Poor"
	la values poor_int_55 poor_int_55
	tab poor_int_55 [aw= weight] if !mi(poor_int_55)
*</_poor_int_>


/*****************************************************************************************************
*                                                                                                    *
                                   FINAL STEPS
*                                                                                                    *
*****************************************************************************************************/
** KEEP VARIABLES - ALL
	do "$fixlabels\fixlabels", nostop

	keep countrycode code year survey idh idp wgt pop_wgt strata psu vermast veralt urban int_month int_year fieldwork  ///
		subnatid1 subnatid2 subnatid3 gaul_adm1_code ownhouse landholding tenure water_orig piped_water water_jmp sar_improved_water  electricity toilet_orig sewage_toilet toilet_jmp sar_improved_toilet  landphone cellphone ///
	     computer internet hsize relationharm relationcs male age soc marital ed_mod_age everattend ///
		water_original water_source improved_water pipedwater_acc watertype_quest sanitation_original sanitation_source improved_sanitation toilet_acc ///
	     atschool electricity literacy educy educat4 educat5 educat7 lb_mod_age lstatus lstatus_year empstat empstat_year njobs njobs_year ///
	     ocusec nlfreason unempldur_l unempldur_u industry_orig industry occup_orig occup firmsize_l firmsize_u whours wage ///
		  unitwage empstat_2 empstat_2_year industry_2 industry_orig_2 occup_2 wage_2 unitwage_2 contract healthins socialsec union rbirth_juris rbirth rprevious_juris rprevious yrmove ///
		 landphone cellphone computer radio television fan sewingmachine washingmachine refrigerator lamp bicycle motorcycle motorcar cow buffalo chicken  ///
		 pline_nat pline_int* poor_nat poor_int* spdef cpi* ppp* welfare welfshprosperity welfarenom welfaredef eqadult welfarenat food_share nfood_share quintile_cons_aggregate decile_cons_aggregate welfareother welfaretype welfareothertype  
		 
** ORDER VARIABLES

	order countrycode code year survey idh idp wgt pop_wgt strata psu vermast veralt urban int_month int_year fieldwork  ///
		subnatid1 subnatid2 subnatid3 gaul_adm1_code ownhouse landholding tenure water_orig piped_water water_jmp sar_improved_water ///
		water_original water_source improved_water pipedwater_acc watertype_quest electricity toilet_orig sewage_toilet ///
		toilet_jmp sar_improved_toilet sanitation_original sanitation_source improved_sanitation toilet_acc ///
		landphone cellphone computer internet hsize relationharm relationcs male age soc marital ed_mod_age everattend ///
	     atschool electricity literacy educy educat4 educat5 educat7 lb_mod_age lstatus lstatus_year empstat empstat_year njobs njobs_year ///
	     ocusec nlfreason unempldur_l unempldur_u industry_orig industry occup_orig occup firmsize_l firmsize_u whours wage ///
		  unitwage empstat_2 empstat_2_year industry_2 industry_orig_2 occup_2 wage_2 unitwage_2 contract healthins socialsec union rbirth_juris rbirth rprevious_juris rprevious yrmove ///
		 landphone cellphone computer radio television fan sewingmachine washingmachine refrigerator lamp bicycle motorcycle motorcar cow buffalo chicken  ///
		 pline_nat pline_int* poor_nat poor_int* spdef cpi* ppp* welfare welfshprosperity welfarenom welfaredef eqadult welfarenat food_share nfood_share quintile_cons_aggregate decile_cons_aggregate welfareother welfaretype welfareothertype  

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
	
	keep countrycode code year survey idh idp wgt pop_wgt strata psu vermast veralt subnatid* gaul_adm*_code ${keep} *type
	compress

	
	saveold "`output'\Data\Harmonized\PAK_2010_PSLM_v01_M_v0`v'_A_SARMD-FULL_IND.dta", replace version(13)
	*saveold "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\__REGIONAL\Individual Files\PAK_2010_PSLM_v01_M_v0`v'_A_SARMD-FULL_IND.dta", replace version(13)

*********************************************************************************************************************************	
******RENAME COMPARABLE VARIABLES AND SAVE THEM IN _SARMD. UNCOMPARABLE VARIALBES ACROSS TIME SHOULD BE FOUND IN _SARMD-FULL*****
*********************************************************************************************************************************
loc var water_jmp 
		  

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

	saveold "`output'\Data\Harmonized\PAK_2010_PSLM_v01_M_v0`v'_A_SARMD-FULL_IND.dta", replace version(13)
	*saveold "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\__REGIONAL\Individual Files\PAK_2010_PSLM_v01_M_v0`v'_A_SARMD-FULL_IND.dta", replace version(13)
	
	

	log close


*********************************************************************************************************************************	
******RENAME COMPARABLE VARIABLES AND SAVE THEM IN _SARMD. UNCOMPARABLE VARIALBES ACROSS TIME SHOULD BE FOUND IN _SARMD-FULL*****
*********************************************************************************************************************************
loc var  piped_water water_jmp sar_improved_water 


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

	note _dta: "PAK 2010" Variables NAMED with "v2" are those not compatible with latest round (2013). ///
 These include the existing information from the particular survey, but the iformation should be used for comparability purposes  

	saveold "`output'\Data\Harmonized\PAK_2010_PSLM_v01_M_v0`v'_A_SARMD_IND.dta", replace version(13)
	*saveold "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\__REGIONAL\Individual Files\PAK_2010_PSLM_v01_M_v0`v'_A_SARMD_IND.dta", replace version(13)
	
******************************  END OF DO-FILE  *****************************************************/





