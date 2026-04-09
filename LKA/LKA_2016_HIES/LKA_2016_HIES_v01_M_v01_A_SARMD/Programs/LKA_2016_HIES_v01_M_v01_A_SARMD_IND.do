/*****************************************************************************************************
******************************************************************************************************
**                                                                                                  **
**                                   SOUTH ASIA MICRO DATABASE                                      **
**                                                                                                  **
** COUNTRY			SRI LANKA																		**
** COUNTRY ISO CODE	LKA																				**	
** YEAR				2016																			**
** SURVEY NAME	HOUSEHOLD INCOME AND EXPENDITURE SURVEY - 2016										**
** SURVEY AGENCY	DEPARTMENT OF CENSUS AND STATISTICS - MINISTRY OF FINANCE AND PLANNING			**	
** RESPONSIBLE		FERNANDO ENRIQUE MORALES VELANDIA												**
**                                                                                                  **
******************************************************************************************************
*****************************************************************************************************/

/*****************************************************************************************************
*                                                                                                    *
*                                  INITIAL COMMANDS													 *	
*                                                                                                    *
*****************************************************************************************************/


** INITIAL COMMANDS
	cap log close 
	clear
	set more off
	set mem 800m


** DIRECTORY
	glo input "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\LKA\LKA_2016_HIES\LKA_2016_HIES_v01_M"
	glo output "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\LKA\LKA_2016_HIES\LKA_2016_HIES_v01_M_v01_A_SARMD\"
	glo pricedata "D:\SOUTH ASIA MICRO DATABASE\CPI\cpi_ppp_sarmd_weighted.dta"
	glo shares "D:\SOUTH ASIA MICRO DATABASE\APPS\DATA CHECK\Food and non-food shares\LKA"

** LOG FILE
	log using "${output}\Doc\Technical\LKA_2016_HIES_v01_M_v01_A_SARMD.log",replace


/*****************************************************************************************************
*                                                                                                    *
                                   * ASSEMBLE DATABASE
*                                                                                                    *
*****************************************************************************************************/


** DATABASE ASSEMBLENT

	local household=1
	local individual=1

	#delimit ;
	foreach file in 

					sec_1_demographic_information 		// Demographic Characteristics for every HH member 
					sec_2_school_education 				// School education for people between (5-20 yrs old)
					sec_3a_health		 				// Health for every HH member
					sec_3_b_is_child_death	 			// Children death by HH
					sec_5_1_emp_income		 			// Income from paid employements
					sec_5_1_is_emp_income	 			// Person worked as employee during last 4 weeks 
					sec_5_5_1_other_income	 			// Income from cash receipt during last 12 months
					sec_5_5_1_is_other_income	 		// Person received cash during last 12 months
					sec_6a_durable_goods	 			// Durable goods for HH
					sec_7_basic_facilities	 			// Access to primary facilities for HH 
					sec_8_housing { ;					// Housing Information
					
	#delimit cr

		use "${input}\Data\Stata\\`file'.dta", clear

		qui {

			**** Generate Household ID
			*-------------------------------------------------------------------------------
			* Household ID is obtained by concatenating:
			* Month, Sector, District, PSU, SSU, Household Number
			* Lines 10 and 11, p.1, questionnaire
			* The household ID contains 10 digits: "1 2" "3" "4 5" "6 7 8" "9 10"
			* "1 2"   			district
			* "3"               sector
			* "4 5"   			month
			* "6 7 8"           psu
			* "9 10"            snumber
			*-------------------------------------------------------------------------------
			*sum district sector month psu snumber hhno
			
			tostring district sector month psu snumber hhno, replace

			gen zero="0"
			egen temp_month		= concat(zero month)
			replace month		= substr(temp_month,-2,.)
			egen temp_psu		= concat(zero zero psu)
			replace psu			= substr(temp_psu,-3,.)
			egen temp_snumber	= concat(zero snumber)
			replace snumber		= substr(temp_snumber,-2,.)
			drop temp* zero

			egen hhid=concat(district sector month psu snumber hhno)

			
			**** Rename serial number from database
			cap ren r2_person_serial 	person_serial_no		// For Education dataset
			cap ren s3a_2_person_sno	person_serial_no		// For Health dataset
			cap ren serial_no_sec_1 	person_serial_no		// For Employment income
			cap ren serial_5_5_1 		person_serial_no		// For Other income source

			capture gen person_serial_no=0
			drop district
		
		}

		**** Keep employment history, register if individual has more than 1 job

		if "`file'"=="sec_5_1_emp_income" {
	
			qui {
			
				drop if pri_sec==. & wages_salaries==. & allowences==. & bonus==.  // Erase people without information in this section
				bys hhid person_serial_no: egen n=max(pri_sec) if pri_sec!=. 		// Check the number of jobs by HH member
				gen njobs=1 if n>1 & n!=.
				drop n
				reshape wide wages_salaries allowences bonus, i(hhid person_serial_no) j(pri_sec)
			
			}
	
		}
		

		**** Drop Duplicate in "Other Income" Database
		
		if "`file'"=="sec_5_5_1_other_income" {
		
			qui {
			
			duplicates tag hhid, gen(TAG)
			drop if TAG!=0 & samurdhi==200
			drop TAG
			
			}
		
		}
		
		**** Check to identify individual or household level data
		qui su person_serial_no

		
		**** Household Level Databases
		
		if r(mean)==0 {
		
			qui sort hhid 
			qui drop person_serial_no

			di as error "`file' household `hi'"

			tempfile h_`household'
			save `h_`household''
			local household=`household'+1

		}
	
		**** Individual Level Databases
		else {
		
			qui sort hhid person_serial_no

			di as error "`file' individual `ii'"

			tempfile i_`individual'
			save `i_`individual''
			local individual=`individual'+1

		}
		
	}
		
		
	**** Merge Datasets
	
	clear 
	
	**** Consumption file
	use "${input}\Data\Stata\wfile2016.dta", clear

	drop sector month

	tostring district psu, replace

	gen zero="0"
	egen temp_psu		= concat(zero zero psu)
	replace psu			= substr(temp_psu,-3,.)
	drop temp* zero

	
	**** Local household and individual we must substract 1 to get the maximum number of HH and IND datsets
	
	local household=`household'-1
	local individual=`individual'-1

	**** Household Datasets
	
	forvalues i=1(1)`household' {
	
		di as error "household dataset `i'"
		merge m:1 hhid using `h_`i'', gen(merge_h_`i')
		tab merge_h_`i', m
	
	}
	
	**** Individual Datasets
	
	forvalues i=1(1)`individual' {

		di as error "individual dataset `i'"
		if `i'==1 {
		
			merge 1:m hhid using `i_`i'', gen(merge_i_`i')
		
		}
		
		else {
		
			merge 1:1 hhid person_serial_no using `i_`i'', gen(merge_i_`i')

		}
		
		tab merge_i_`i', m

	}
	
	**** Clean unwanted observations

	**** Households not available in the Consumption File
	
	drop if merge_i_1!=3  // If the household doesn't exist in the consumption file it won't merge with the first file
	drop merge_h_* merge_i_*

	**** Individuals who are not living in the house (code higher than 40 are people that don't live in the HH)
	
	drop if person_serial_no>=40


/*******************************************************************************
*                                                                              *
                           STANDARD SURVEY MODULE
*                                                                              *
*******************************************************************************/

	
	** COUNTRY
	*<_countrycode_>
		gen str4 countrycode="LKA"
		la var countrycode "Country code"
	*</_countrycode_>


	** YEAR
	*<_year_>
		gen int year=2016
		la var year "Year of survey"
	*</_year_>

	
	** SURVEY NAME 
	*<_survey_>
		gen str survey="HIES"
		label var survey "Survey Acronym"
	*</_survey_>
	
	
	** INTERVIEW YEAR
	*<_int_year_>
		gen int_year=2016
		la var int_year "Year of the interview"
	*</_int_year_>	
		
		
	** INTERVIEW MONTH
	*<_int_month_>
		destring month, gen(int_month)
		#delimit 
		la de lblint_month  1 "January" 
							2 "February" 
							3 "March" 
							4 "April" 
							5 "May" 
							6 "June" 
							7 "July" 
							8 "August" 
							9 "September" 
							10 "October" 
							11 "November" 
							12 "December";
		#delimit cr					
		la val int_month lblint_month
		la var int_month "Month of the interview"
	*</_int_month_>


	** HOUSEHOLD IDENTIFICATION NUMBER
	*<_idh_>
		gen idh=hhid
		la var idh "Household id"
	*</_idh_>


	** INDIVIDUAL IDENTIFICATION NUMBER
	*<_idp_>
		egen idp=concat(idh person_serial_no), punct(-)
		la var idp "Individual id"
	*</_idp_>

		
	** HOUSEHOLD WEIGHTS
	*<_wgt_>
		gen double wgt=weight
		la var wgt "Household sampling weight"
		la var weight "Household sampling weight"
	*</_wgt_>


	** STRATA
	*<_strata_>
		gen strata=district
		la var strata "Strata"
	*</_strata_>


	** PSU
	*<_psu_>
		la var psu "Primary sampling units"
	*</_psu_>


	** MASTER VERSION
	*<_vermast_>
		gen vermast="01"
		la var vermast "Master Version"
	*</_vermast_>
		
		
	** ALTERATION VERSION
	*<_veralt_>
		gen veralt="01"
		la var veralt "Alteration Version"
	*</_veralt_>

	
	
/*****************************************************************************************************
*                                                                                                    *
                                   HOUSEHOLD CHARACTERISTICS MODULE
*                                                                                                    *
*****************************************************************************************************/


	** LOCATION (URBAN/RURAL)
	*<_urban_>
		destring sector, gen(urban)
		recode urban (2 3 = 0)
		la de lblurban 1 "Urban" 0 "Rural"
		la val urban lblurban
		la var urban "Urban/Rural"
	*</_urban_>


	** REGIONAL AREA 1 DIGIT ADMN LEVEL
	*<_subnatid1_>
		gen byte subnatid1=district
		recode subnatid1 (11/13 = 1) (21/23 = 2) (31/33 = 3) (41/45 = 4) ///
		(51/53 = 5) (61/62 = 6) (71/72 = 7) (81/82 = 8) (91/92 = 9)
		#delimit
		la de lblsubnatid1  1 "Western" 
							2 "Central" 
							3 "Southern" 
							4 "Northern" 
							5 "Eastern" 
							6 "North-western" 
							7 "North-central" 
							8 "Uva" 
							9 "Sabaragamuwa";
		#delimit cr	
		la val subnatid1 lblsubnatid1
		la var subnatid1 "Region at 1 digit (ADMN1)"
		numlabel lblsubnatid1, remove
		numlabel lblsubnatid1, add mask("# - ")
		decode subnatid1, gen(subnatid1_temp)
		drop subnatid1
		rename subnatid1_temp subnatid1
	*</_subnatid1_>
	
	*<_gaul_adm1_code_>
		gen gaul_adm1_code=.
		label var gaul_adm1_code "GAUL code for admin1 level"
		replace gaul_adm1_code=2096 if subnatid1=="2 - Central"
		replace gaul_adm1_code=2097 if subnatid1=="5 - Eastern"
		replace gaul_adm1_code=2098 if subnatid1=="7 - North-central"
		replace gaul_adm1_code=2099 if subnatid1=="6 - North-western"
		replace gaul_adm1_code=2100 if subnatid1=="4 - Northern"
		replace gaul_adm1_code=2101 if subnatid1=="9 - Sabaragamuwa"
		replace gaul_adm1_code=2102 if subnatid1=="3 - Southern"
		replace gaul_adm1_code=2103 if subnatid1=="8 - Uva"
		replace gaul_adm1_code=2104 if subnatid1=="1 - Western"
	*<_gaul_adm1_code_>


	** REGIONAL AREA 2 DIGIT ADMN LEVEL
	*<_subnatid2_>
		gen byte subnatid2=district
		#delimit
		la de lblsubnatid2  11 "Colombo" 
							12 "Gampaha" 
							13 "Kalutara" 
							21 "Kandy" 
							22 "Matale" 
							23 "Nuwara-eliya" 
							31 "Galle" 
							32 "Matara" 
							33 "Hambantota" 
							41 "Jaffna" 
							42 "Mannar" 
							43 "Vavuniya" 
							44 "Mullaitivu" 
							45 "Kilinochchi" 
							51 "Batticaloa" 
							52 "Ampara" 
							53 "Tricomalee" 
							61 "Kurunegala" 
							62 "Puttlam" 
							71 "Anuradhapura" 
							72 "Polonnaruwa" 
							81 "Badulla" 
							82 "Moneragala" 
							91 "Ratnapura" 
							92 "Kegalle";
		#delimit cr;
		la val subnatid2 lblsubnatid2
		la var subnatid2 "Region at 2 digit (ADMN2)"
		numlabel lblsubnatid2, remove
		numlabel lblsubnatid2, add mask("# - ")
		decode subnatid2, gen(subnatid2_temp)
		drop subnatid2
		rename subnatid2_temp subnatid2
	*</_subnatid2_>

	*<_gaul_adm2_code_>
		gen gaul_adm2_code=.
		label var gaul_adm2_code "GAUL code for admin2 level"
		replace gaul_adm2_code=30896 if subnatid2=="13 - Kalutara"
		replace gaul_adm2_code=30895 if subnatid2=="12 - Gampaha"
		replace gaul_adm2_code=30894 if subnatid2=="11 - Colombo"
		replace gaul_adm2_code=30893 if subnatid2=="82 - Moneragala"
		replace gaul_adm2_code=30892 if subnatid2=="81 - Badulla"
		replace gaul_adm2_code=30891 if subnatid2=="32 - Matara"
		replace gaul_adm2_code=30890 if subnatid2=="33 - Hambantota"
		replace gaul_adm2_code=30889 if subnatid2=="31 - Galle"
		replace gaul_adm2_code=30888 if subnatid2=="91 - Ratnapura"
		replace gaul_adm2_code=30887 if subnatid2=="92 - Kegalle"
		replace gaul_adm2_code=30886 if subnatid2=="43 - Vavuniya"
		replace gaul_adm2_code=30885 if subnatid2=="44 - Mullaitivu"
		replace gaul_adm2_code=30884 if subnatid2=="42 - Mannar"
		replace gaul_adm2_code=30883 if subnatid2=="45 - Kilinochchi"
		replace gaul_adm2_code=30882 if subnatid2=="41 - Jaffna"
		replace gaul_adm2_code=30881 if subnatid2=="62 - Puttlam"
		replace gaul_adm2_code=30880 if subnatid2=="61 - Kurunegala"
		replace gaul_adm2_code=30879 if subnatid2=="72 - Polonnaruwa"
		replace gaul_adm2_code=30878 if subnatid2=="71 - Anuradhapura"
		replace gaul_adm2_code=30877 if subnatid2=="53 - Tricomalee"
		replace gaul_adm2_code=30876 if subnatid2=="51 - Batticaloa"
		replace gaul_adm2_code=30875 if subnatid2=="52 - Ampara"
		replace gaul_adm2_code=30874 if subnatid2=="23 - Nuwara-eliya"
		replace gaul_adm2_code=30873 if subnatid2=="21 - Kandy"
		replace gaul_adm2_code=30872 if subnatid2=="22 - Matale"
	*<_gaul_adm2_code_>
	
	
	** REGIONAL AREA 3 DIGIT ADMN LEVEL
	*<_subnatid3_>
		gen byte subnatid3=.
		la var subnatid3 "Region at 3 digit (ADMN3)"
	*</_subnatid3_>

	
	** HOUSE OWNERSHIP
	*<_ownhouse_>
		gen byte ownhouse=ownership
		recode ownhouse (1/4 = 1) (5/9 99 = 0)  // Other is consider as not owning the house
		la de lblownhouse 0 "No" 1 "Yes"
		la val ownhouse lblownhouse
		la var ownhouse "House ownership"
	*</_ownhouse_>

	
	** WATER PUBLIC CONNECTION (TAP WATER)
	*<_water_>
		gen byte water=drinking_water
		recode water (4 5 6 = 1) (1 2 3 7 8 9 10 11 12 99 = 0)
		la de lblwater 0 "No" 1 "Yes"
		la val water lblwater
		la var water "Water main source"
	*</_water_>


	** ORIGINAL WATER CATEGORIES
	*<_water_original_>
		gen water_original=drinking_water
		tostring water_original, replace
		replace water_original="1-Protected well within premises" if water_original=="1"
		replace water_original="2-Protected well outside premises" if water_original=="2"
		replace water_original="3-Unprotected well" if water_original=="3"
		replace water_original="4-Tap inside home" if water_original=="4"
		replace water_original="5-Tap with in unit/premise (main line)" if water_original=="5"
		replace water_original="6-Tap outside premises (main line)" if water_original=="6"
		replace water_original="7-Project in village" if water_original=="7"
		replace water_original="8-Tube well" if water_original=="8"
		replace water_original="9-Bowser" if water_original=="9"
		replace water_original="10-River/Tank/Streams" if water_original=="10"
		replace water_original="11-Rainy water" if water_original=="11"
		replace water_original="12-Bottled water" if water_original=="12"
		replace water_original="99-Other (Specify)" if water_original=="99"
		la var water_original "Original survey response in string for water source variable"
	*</_water_original_>


	** WATER SOURCE
	*<_water_source_>
		gen water_source=.
		replace water_source=1 if drinking_water==4
		replace water_source=2 if drinking_water==5
		replace water_source=3 if drinking_water==6
		replace water_source=4 if drinking_water==8
		replace water_source=5 if inrange(drinking_water,1,2)
		replace water_source=7 if drinking_water==12
		replace water_source=8 if drinking_water==11
		replace water_source=10 if drinking_water==3
		replace water_source=11 if drinking_water==9
		replace water_source=13 if drinking_water==10
		replace water_source=14 if drinking_water==99
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
		gen pipedwater_acc=0 if inlist(drinking_water,1,2,3,7,8,9,10,11,12,99) // Asuming other is not piped water
		replace pipedwater_acc=1 if inlist(drinking_water,4,5)
		replace pipedwater_acc=2 if inlist(drinking_water,6)
		#delimit 
		la def lblpiped_water		0 "No"
									1 "Yes, in premise"
									2 "Yes, but not in premise"
									3 "Yes, unstated whether in or outside premise";
		#delimit cr
		la val pipedwater_acc lblpiped_water
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


	** TOILET PUBLIC CONNECTION (CONNECTED TO SEWERAGE)
	*<_toilet_>
		gen byte toilet=toilet_type
		recode toilet (1 2 3 = 1) (4 9 = 0) // Asuming other is not connected to sewerage
		label var toilet "Toilet facility"
		la de lbltoilet 0 "No" 1 "Yes"
		label values toilet lbltoilet
	*</_toilet_>

	
	** ORIGINAL SANITATION CATEGORIES 
	*<_sanitation_original_>
		gen sanitation_original=toilet_type
		tostring sanitation_original, replace
		replace sanitation_original="1-Water seal with connected to pit/tank" if sanitation_original=="1"
		replace sanitation_original="2-Water seal with connected to drainage system/a piped sewer" if sanitation_original=="2"
		replace sanitation_original="3-Not water seal" if sanitation_original=="3"
		replace sanitation_original="4-Direct pit" if sanitation_original=="4"
		replace sanitation_original="5-Other (specify)" if sanitation_original=="5"
		la var sanitation_original "Original survey response in string for sanitation source variable"
		note sanitation_original: "LKA 2016" Original categories definitions changed from the previuos survey. 
	*</_sanitation_original_>


	** SANITATION SOURCE
	*<_sanitation_source_>
		gen sanitation_source=.
		replace sanitation_source=1 if toilet_type==1
		replace sanitation_source=2 if toilet_type==2
		replace sanitation_source=8 if toilet_type==3
		replace sanitation_source=10 if toilet_type==4
		replace sanitation_source=14 if toilet_type==9
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

	
	** SAR IMPROVED TYPE OF TOILET 
	*<_improved_sanitation_>
		gen improved_sanitation=.
		replace improved_sanitation=1 if inrange(sanitation_source,1,8)
		replace improved_sanitation=0 if inrange(sanitation_source,9,14) // Asuming other is not an improved toilet source
		la def lblimproved_sanitation 1 "Improved" 0 "Unimproved"
		la val improved_sanitation lblimproved_sanitation
		la var improved_sanitation "Improved access to sanitation facilities"
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
	
	
	** ELECTRICITY PUBLIC CONNECTION
	*<_electricity_>
		gen byte electricity=lite_source
		recode electricity (2 = 1) (1 3 4 5 9 = 0) // Asuming other is not electricity light source
		la de lblelectricity 0 "No" 1 "Yes"
		la val electricity lblelectricity
		la var electricity "Electricity main source"
	*</_electricity_>


	** LANDPHONE
	*<_landphone_>
		gen byte landphone=telephone
		recode landphone (2=0)
		la de lbllandphone 0 "No" 1 "Yes"
		la val landphone lbllandphone
		la var landphone "Phone availability"
	*</_landphone_>


	** CELLPHONE
	*<_cellphone_>
		gen byte cellphone=telephone_mobile
		recode cellphone (2=0)
		la de lblcellphone 0 "No" 1 "Yes"
		la val cellphone lblcellphone
		la var cellphone "Cell phone"
	*</_cellphone_>


	** COMPUTER
	*<_computer_>
		gen byte computer=.
		la de lblcomputer 0 "No" 1 "Yes"
		la val computer lblcomputer
		la var computer "Computer availability"
	*</_computer_>


	** INTERNET
	*<_internet_>
		gen byte internet=.
		la de lblinternet 0 "No" 1 "Yes"
		la val internet lblinternet
		la var internet "Internet connection"
	*<_internet_>

	
/*****************************************************************************************************
*                                                                                                    *
                                   DEMOGRAPHIC MODULE
*                                                                                                    *
*****************************************************************************************************/


	** HOUSEHOLD SIZE
	*<_hsize_>
		gen uno=1
		bys hhid: egen hsize=count(uno)
		la var hsize "Household size"
		drop uno
	*</_hsize_>
	
	**POPULATION WEIGHT
	*<_pop_wgt_>
	gen pop_wgt=wgt*hsize
	la var pop_wgt "Population weight"
	*</_pop_wgt_>
	
	
	
	** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
	*<_relationharm_>
		gen byte relationharm=relationship
		recode relationharm (6/9=6)
		#delimit 
		la de lblrelationharm   1 "Head of household" 
								2 "Spouse" 
								3 "Children" 
								4 "Parents" 
								5 "Other relatives" 
								6 "Non-relatives";
		#delimit cr
		la val relationharm lblrelationharm
		la var relationharm "Relationship to the head of household"

		* Check to see if there are more than 1 HH head per HH
		gen hdind=(relationharm==1)
		recode hdind (0=.)
		bysort idh : egen count=count(hdind)
		drop if count!=1
	*</_relationharm_>

	
	** RELATIONSHIP TO THE HEAD OF HOUSEHOLD COUNTRY SPECIFIC
	*<_relationcs_>
		gen byte relationcs=relationship
		#delimit
		la def lblrelationcs  1 "Head" 
							  2 "Wife/Husband" 
							  3 "Son/Daughter" 
							  4 "Parents" 
							  5 "Other relative" 
							  6 "Domestic servants" 
							  7 "Boarder" 
							  9 "Other";
		#delimit cr				  
		la val relationcs lblrelationcs
		la var relationcs "Relationship to the head of household country/region specific"
	*</_relationcs_>
	
		
	** GENDER
	*<_gender_>
		gen byte male=sex
		recode male (2=0)
		la def lblmale 1 "Male" 0 "Female"
		la val male lblmale
		la var male "Sex of household member"
	*</_gender_>
	
	
	** AGE
	*<_age_>
	la var age "Individual age"
	*</_age_>
	
	
	** SOCIAL GROUP (ETHNICITY)
	*<_soc_>
		gen byte soc=ethnicity
		recode soc (9=7)
		#delimit
		la def lblsoc   1 "Sinhala" 
						2 "Sri Lanka Tamil" 
						3 "Indian Tamil" 
						4 "Sri Lanka Moors" 
						5 "Malay" 
						6 "Burgher" 
						7 "Other";
		#delimit cr				
		la val soc lblsoc
		la var soc "Social group"
	*</_soc_>

	
	** MARITAL STATUS
	*<_marital_>
		gen byte marital=marital_status
		recode marital (1=2) (2=1) (3=5) (4/5=4)
		#delimit 
		la def lblmarital   1 "Married" 
							2 "Never Married" 
							3 "Living Together" 
							4 "Divorced/separated" 
							5 "Widowed";
		#delimit cr
		la val marital lblmarital
		la var marital "Marital status"
	*</_marital_>


/*****************************************************************************************************
*                                                                                                    *
                                   EDUCATION MODULE
*                                                                                                    *
*****************************************************************************************************/


	** EDUCATION MODULE AGE
	*<_ed_mod_age_>
		gen byte ed_mod_age=5
		la var ed_mod_age "Education module application age"
	*</_ed_mod_age_>

	
	** CURRENTLY AT SCHOOL
	*<_atschool_>
		gen byte atschool=1 if r2_school_edu==1
		replace atschool=0 if (r2_school_edu==2 | r2_school_edu==3)
		la de lblatschool 0 "No" 1 "Yes"
		la val atschool  lblatschool
		la var atschool "Attending school"
	*</_atschool_>


	** CAN READ AND WRITE
	*<_literacy_>
		gen byte literacy=.
		la def lblliteracy 0 "No" 1 "Yes"
		la val literacy lblliteracy
		la var literacy "Can read & write"
 	*</_literacy_>


	** YEARS OF EDUCATION COMPLETED
	*<_educy_>
		replace education=. if education==18
		gen byte educy=education
		la var educy "Years of education"
		replace educy=0 if education==19
	*</_educy_>

								
	** EDUCATIONAL LEVEL 7 CATEGORIES
	*<_educat7_>
		gen byte educat7=education
		recode educat7 (19 = 1) (0/5 = 2) (6 = 3) (7/10 = 4) (11/14 = 5) (18 = 6) (15/17 = 7)
		replace educat7=. if age<5
		#delimit
		la def lbleducat7   1 "No education" 
							2 "Primary incomplete" 
							3 "Primary complete" 
							4 "Secondary incomplete" 
							5 "Secondary complete" 
							6 "Higher than secondary but not university" 
							7 "University incomplete or complete"; 
		#delimit cr
		la val educat7 lbleducat7
		la var educat7 "Level of education 7 categories"
	*</_educat7_>


	** EDUCATION LEVEL 5 CATEGORIES
	*<_educat_>
		gen educat5=.
		replace educat5=1 if educat7==1
		replace educat5=2 if educat7==2
		replace educat5=3 if educat7==3 | educat7==4
		replace educat5=4 if educat7==5
		replace educat5=5 if educat7==6 | educat7==7
		#delimit
		la def lbleducat5   1 "No education" 
							2 "Primary incomplete" 
							3 "Primary complete but secondary incomplete" 
							4 "Secondary complete" 
							5 "Some tertiary/post-secondary";
		#delimit cr
		la val educat5 lbleducat5
		la var educat5 "Level of education 5 categories"
	*</_educat5_>

	
	** EDUCATION LEVEL 4 CATEGORIES
	*<_educat4_>
		gen byte educat4=.
		replace educat4=1 if educat7==1 
		replace educat4=2 if educat7==2 | educat7==3
		replace educat4=3 if educat7==4 | educat7==5
		replace educat4=4 if educat7==6 | educat7==7
		#delimit 
		label define lbleducat4 1 "No education" 
								2 "Primary (complete or incomplete)" 
								3 "Secondary (complete or incomplete)" 
								4 "Tertiary (complete or incomplete)";
		#delimit cr
		la val educat4 lbleducat4
		la var educat4 "Level of education 4 categories"
	*</_educat4_>

	
	** EVER ATTENDED SCHOOL
	*<_everattend_>
		gen byte everattend=0 if r2_school_edu==2
		replace everattend=1 if (atschool==1 | r2_school_edu==3)
		la de lbleverattend 0 "No" 1 "Yes"
		la val everattend lbleverattend
		la var everattend "Ever attended school"
	*</_everattend_>

/*****************************************************************************************************
*                                                                                                    *
                                   LABOR MODULE
*                                                                                                    *
*****************************************************************************************************/


	** LABOR MODULE AGE
	*<_lb_mod_age_>
		gen byte lb_mod_age=15
		la var lb_mod_age "Labor module application age"
	*</_lb_mod_age_>


	** LABOR STATUS
	*<_lstatus_>
		gen byte lstatus=is_active
		recode lstatus (2 = 3) 			// Not being economic active is Non-LF
		replace lstatus=2 if main_activity==2 // Seeking for job is unemployed
		replace lstatus=3 if (main_activity==3 | main_activity==4 | main_activity==5 | main_activity==6) // Student, retired, household activities, unable to work are Non-LF
		replace lstatus=. if age<lb_mod_age
		la def lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
		la val lstatus lbllstatus
		la var lstatus "Labor status"
	*</_lstatus_>

	
	* LABOR STATUS LAST YEAR
	*<_lstatus_year_>
		gen byte lstatus_year=.
		la def lbllstatus_year 1 "Employed" 0 "Not employed" 
		la val lstatus_year lbllstatus_year
		la var lstatus_year "Labor status during last year"
	*</_lstatus_year_>

	
	** EMPLOYMENT STATUS
	*<_empstat_>
		gen byte empstat=employment_st
		recode empstat (1/3 = 1) (6 = 2) (4 = 3) (5 = 4) 
		#delimit 
		la de lblempstat 1 "Paid employee" 
						 2 "Non-paid employee" 
						 3 "Employer" 
						 4 "Self-employed";
		#delimit cr				 
		la val empstat lblempstat
		la var empstat "Employment status"
		replace empstat=. if lstatus!=1
	*</_empstat_>

	
	* EMPLOYMENT STATUS LAST YEAR
	*<_empstat_year_>
		gen byte empstat_year=.
		#delimit
		la def lblempstat_year  1 "Paid employee" 
								2 "Non-paid employee" 
								3 "Employer" 
								4 "Self-employed" 
								5 "Other, workers not classifiable by status";
		#delimit cr						
		la val empstat_year lblempstat_year
		la var empstat_year "Employment status during last year"
	*</_empstat_year_>


	** NUMBER OF ADDITIONAL JOBS
	*<_njobs_>
		la var njobs "Number of additional jobs"
	*</_njobs_>


	* NUMBER OF ADDITIONAL JOBS LAST YEAR
	*<_njobs_year_>
		gen byte njobs_year=.
		la var njobs_year "Number of additional jobs during last year"
	*</_njobs_year_>


	** SECTOR OF ACTIVITY: PUBLIC - PRIVATE
	*<_ocusec_>
		gen byte ocusec=employment_st
		recode ocusec (2 = 1) (3/6 = 2)
		la def lblocusec 1 "Public, state owned, government, army, NGO" 2 "Private"
		la val ocusec lblocusec
		la var ocusec "Sector of activity"
		replace ocusec=. if lstatus!=1
	*</_ocusec_>


	** REASONS NOT IN THE LABOR FORCE
	*<_nlfreason_>
		gen byte nlfreason=.
		replace nlfreason=1 if main_activity==3
		replace nlfreason=2 if main_activity==4
		replace nlfreason=3 if main_activity==5
		replace nlfreason=4 if main_activity==6
		replace nlfreason=5 if main_activity==9
		#delimit
		la de lblnlfreason  1 "Student" 
							2 "Housewife" 
							3 "Retired" 
							4 "Disable" 
							5 "Other";
		#delimit cr
		la val nlfreason lblnlfreason
		la var nlfreason "Reason not in the labor force"
		replace nlfreason=. if lstatus!=3
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


	** INDUSTRY CLASSIFICATION
	*<_industry_>
		gen ind=int(industry/1000)
		drop industry
		recode ind (1/3 = 1) (5/9 = 2) (10/33 = 3) (35/39 = 4) (41/43 = 5) ///
		(45/47 = 6) (49/63 = 7) (64/82 = 8) (84 = 9) (85/99 = 10), gen(industry)
		#delimit 
		la de lblindustry 
		1 "Agriculture" 
		2 "Mining" 
		3 "Manufacturing" 
		4 "Public utilities" 
		5 "Construction"  
		6 "Commerce" 
		7 "Transports and comnunications" 
		8 "Financial and business-oriented services" 
		9 "Public Administration" 
		10 "Other services, Unspecified";
		#delimit cr
		la val industry lblindustry
		la var industry "1 digit industry classification"
		replace industry=. if lstatus!=1
		drop ind
	*</_industry_>	

	
	** OCCUPATION CLASSIFICATION
	*<_occup_>
		gen byte occup=.
		tostring main_occupation, gen(stringmain)
		gen numoccup=real(substr(stringmain,1,2)) if main_occup>=1000
		replace occup=1 if numoccup>=10 & numoccup<=13
		replace occup=2 if numoccup>=20 & numoccup<=24 
		replace occup=3 if numoccup>=30 & numoccup<=34
		replace occup=4 if numoccup==41 | numoccup==42
		replace occup=5 if numoccup==51 | numoccup==52
		replace occup=6 if numoccup==61
		replace occup=7 if numoccup>=71 & numoccup<=74
		replace occup=8 if numoccup>=80 & numoccup<=83
		replace occup=9 if numoccup>=90 & numoccup<=93
		replace occup=10 if main_occup==110
		#delimit 
		la def lbloccup 1 "Managers" 
						2 "Professionals" 
						3 "Technicians and associate professionals" 
						4 "Clerical support workers" 
						5 "Service and sales workers" 
						6 "Skilled agricultural, forestry and fishery workers" 
						7 "Craft and related trades workers" 
						8 "Plant and machine operators, and assemblers" 
						9 "Elementary occupations" 
						10 "Armed forces occupations"  
						99 "Others/unspecified";
		#delimit cr				
		la val occup lbloccup
		la var occup "1 digit occupational classification"
		replace occup=. if lstatus!=1
		drop stringmain
	*</_occup_>


	** FIRM SIZE
	*<_firmsize_l_>
		gen byte firmsize_l=.
		la var firmsize_l "Firm size (lower bracket)"
	*</_firmsize_l_>

	*<_firmsize_u_>
		gen byte firmsize_u=.
		la var firmsize_u "Firm size (upper bracket)"
	*</_firmsize_u_>


	** HOURS WORKED LAST WEEK
	*<_whours_>
		gen whours=.
		label var whours "Hours of work in last week"
	*</_whours_>


	** WAGES
	*<_wage_>
		gen double wage=wages_salaries1 // LAST MONTH
		replace wage=. if wage==1 | wage==0 // It does not make sense that we have people with wage equal to 1 or 0. 
		la var wage "Last wage payment"
		replace wage=. if lstatus!=1
	*</_wage_>


	** WAGES TIME UNIT
	*<_unitwage_>
		gen byte unitwage=5
		#delimit
		la def lblunitwage  1 "Daily" 
							2 "Weekly" 
							3 "Every two weeks" 
							4 "Bimonthly"  
							5 "Monthly" 
							6 "Quarterly" 
							7 "Biannual" 
							8 "Annually" 
							9 "Hourly" 
							10 "Other";
		#delimit cr					
		la val unitwage lblunitwage
		la var unitwage "Last wages time unit"
		replace unitwage=. if lstatus!=1
	*</_unitwage_>
	
		
	* EMPLOYMENT STATUS - SECOND JOB
	*<_empstat_2_>
		gen byte empstat_2=.
		#delimit 
		la def lblempstat_2 1 "Paid employee" 
							2 "Non-paid employee" 
							3 "Employer" 
							4 "Self-employed" 
							5 "Other, workers not classifiable by status";
		#delimit cr
		la val empstat_2 lblempstat_2
		la var empstat_2 "Employment status - second job"
	*</_empstat_2_>


	** EMPLOYMENT STATUS - SECOND JOB LAST YEAR
	*<_empstat_2_year_>
		gen empstat_2_year=.
		#delimit
		la def lblempstat_2_year 1 "Paid employee" 
								 2 "Non-paid employee" 
								 3 "Employer" 
								 4 "Self-employed" 
								 5 "Other, workers not classifiable by status";
		#delimit cr
		la val empstat_2_year lblempstat_2
		la var empstat_2_year "Employment status - second job last year"
	*</_empstat_2_>


	** INDUSTRY CLASSIFICATION - SECOND JOB
	*<_industry_2_>
		gen industry_2=.
		#delimit
		la def lblindustry_2 1 "Agriculture" 
							 2 "Mining" 
							 3 "Manufacturing" 
							 4 "Public utilities" 
							 5 "Construction"  
							 6 "Commerce" 
							 7 "Transport and Comnunications" 
							 8 "Financial and Business Services" 
							 9 "Public Administration" 
							 10 "Other Services, Unspecified";
		#delimit cr					 
		la val industry_2 lblindustry_2
		la var industry_2 "1 digit industry classification - second job"
	*<_industry_2_>


	**SURVEY SPECIFIC INDUSTRY CLASSIFICATION - SECOND JOB
	*<_industry_orig_2_>
		gen industry_orig_2=.
		la var industry_orig_2 "Original Industry Codes - Second job"
	*</_industry_orig_2>


	** OCCUPATION CLASSIFICATION - SECOND JOB
	*<_occup_2_>
		gen occup_2=.
		la var occup_2 "1 digit occupational classification - second job"
		#delimit 
		la def lbloccup_2   1 "Senior officials" 
							2 "Professionals" 
							3 "Technicians" 
							4 "Clerks" 
							5 "Service and market sales workers" 
							6 "Skilled agricultural" 
							7 "Craft workers" 
							8 "Machine operators" 
							9 "Elementary occupations" 
							10 "Armed forces"  
							99 "Others";
		#delimit cr					
		la val occup_2 lbloccup_2
	*</_occup_2_>


	** WAGES - SECOND JOB
	*<_wage_2_>
		gen double wage_2=wages_salaries2
		replace wage_2=. if (njobs==0 | njobs==. | lstatus!=1)
		la var wage_2 "Last wage payment - Second job"
	*</_wage_2_>


	** WAGES TIME UNIT - SECOND JOB
	*<_unitwage_2_>
		gen byte unitwage_2=5
		replace unitwage_2=. if (njobs==0 | njobs==. | lstatus!=1)
		#delimit
		la def lblunitwage_2 	1 "Daily" 
								2 "Weekly" 
								3 "Every two weeks" 
								4 "Every two months"  
								5 "Monthly" 
								6 "Quarterly" 
								7 "Every six months" 
								8 "Annually" 
								9 "Hourly" 
								10 "Other";
		#delimit cr						
		la val unitwage_2 lblunitwage_2
		la var unitwage_2 "Last wages time unit - Second job"
	*</_unitwage_2_>


	** CONTRACT
	*<_contract_>
		gen byte contract=.
		la def lblcontract 0 "Without contract" 1 "With contract"
		la val contract lblcontract
		la var contract "Contract"
	*<_contract_>


	** HEALTH INSURANCE
	*<_healthins_>
		gen byte healthins=.
		la def lblhealthins 0 "Without health insurance" 1 "With health insurance"
		la val healthins lblhealthins
		la var healthins "Health insurance"
	*</_healthins_>


	** SOCIAL SECURITY
	*<_socialsec_>
		gen byte socialsec=.
		la def lblsocialsec 1 "With" 0 "Without"
		la val socialsec lblsocialsec
		la var socialsec "Social security"
	*</socialsec_>

	
	** UNION MEMBERSHIP
	*<_union_>
		gen byte union=.
		la def lblunion 0 "No member" 1 "Member"
		la val union lblunion
		la var union "Union membership"
	*</_union_>

	/*****************************************************************************************************
*                                                                                                    *
                                            ASSETS 
*                                                                                                    *
*****************************************************************************************************/










** TELEVISION
*<_television_>
	ren  tv television
	recode television (2=0) (3=.)
	label var television "Household has a television"
	la de lbltelevision 0 "No" 1 "Yes"
	label val television lbltelevision
*</_television>

** FAN
*<_fan_>
	ren electric_fans fan
	recode fan (2=0)
	label var fan "Household has a fan"
	la de lblfan 0 "No" 1 "Yes"
	label val fan lblfan
*</_fan>

** SEWING MACHINE
*<_sewingmachine_>
	ren sewingmechine sewingmachine
	recode sewingmachine (2=0) (4=.)
	label var sewingmachine "Household has a sewing machine"
	la de lblsewingmachine 0 "No" 1 "Yes"
	label val sewingmachine lblsewingmachine
*</_sewingmachine>

** WASHING MACHINE
*<_washingmachine_>
	ren washing_mechine washingmachine
	replace washingmachine=. if washingmachine==0
	recode washingmachine (2=0)
	label var washingmachine "Household has a washing machine"
	la de lblwashingmachine 0 "No" 1 "Yes"
	label val washingmachine lblwashingmachine
*</_washingmachine>

** REFRIGERATOR
*<_refrigerator_>
	ren fridge refrigerator
	replace refrigerator=. if refrigerator==0
	recode refrigerator (2=0) 
	label var refrigerator "Household has a refrigerator"
	la de lblrefrigerator 0 "No" 1 "Yes"
	label val refrigerator lblrefrigerator
*</_refrigerator>

** LAMP
*<_lamp_>
	gen lamp=.
	label var lamp "Household has a lamp"
	la de lbllamp 0 "No" 1 "Yes"
	label val lamp lbllamp
*</_lamp>

** BYCICLE
*<_bycicle_>
	replace bicycle=. if bicycle==0
	recode bicycle  (2=0) 
	label var bicycle "Household has a bycicle"
	la de lblbycicle 0 "No" 1 "Yes"
	label val bicycle lblbycicle
*</_bycicle>

** MOTORCYCLE
*<_motorcycle_>
	ren motor_bicycle  motorcycle
	replace motorcycle=. if motorcycle==0
	recode motorcycle (2=0) 
	label var motorcycle "Household has a motorcycle"
	la de lblmotorcycle 0 "No" 1 "Yes"
	label val motorcycle lblmotorcycle
*</_motorcycle>

** MOTOR CAR
*<_motorcar_>
	ren  motor_car_van motorcar
	recode motorcar (2=0)
	label var motorcar "household has a motor car"
	la de lblmotorcar 0 "No" 1 "Yes"
	label val motorcar lblmotorcar
*</_motorcar>

** COW
*<_cow_>
	gen cow=.
	label var cow "Household has a cow"
	la de lblcow 0 "No" 1 "Yes"
	label val cow lblcow
*</_cow>

** BUFFALO
*<_buffalo_>
	gen buffalo=.
	label var buffalo "Household has a buffalo"
	la de lblbuffalo 0 "No" 1 "Yes"
	label val buffalo lblbuffalo
*</_buffalo>


	
	
/*****************************************************************************************************
*                                                                                                    *
                                   WELFARE MODULE
*                                                                                                    *
*****************************************************************************************************/


	** SPATIAL DEFLATOR
	*<_cpi_dcs_>
		gen spdef=cpi_dcs
		la var spdef "Spatial deflator"
	*</_cpi_dcs_>


	** WELFARE
	*<_welfare_>
		gen welfare=npccons
		la var welfare "Welfare aggregate"
	*<_welfare_>

	*<_welfarenom_>
		gen welfarenom=npccons
		la var welfarenom "Welfare aggregate in nominal terms"
	*</_welfarenom_>

	*<_welfaredef_>
		gen welfaredef=rpccons
		la var welfaredef "Welfare aggregate spatially deflated"
	*</_welfaredef_>

	*<_welfaretype_>
		gen welfaretype="CONS"
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

	
	*QUINTILE AND DECILE OF CONSUMPTION AGGREGATE

	levelsof year, loc(y)
	merge m:1 idh using "${shares}\LKA_fnf_`y'", keepusing (quintile_cons_aggregate decile_cons_aggregate) nogen

/*****************************************************************************************************
*                                                                                                    *
                                   NATIONAL POVERTY
*                                                                                                    *
*****************************************************************************************************/

	
	** POVERTY LINE (NATIONAL)
	*<_pline_nat_>
		gen pline_nat=pov_line
		la var pline_nat "Poverty Line (National)"
	*</_pline_nat_>
	
	
	** HEADCOUNT RATIO (NATIONAL)
	*<_poor_nat_>
		gen poor_nat=(welfaredef<pline_nat) if welfaredef!=.
		la var poor_nat "People below Poverty Line (National)"
		la def poor_nat 0 "Not-Poor" 1 "Poor"
		la val poor_nat poor_nat
	*</_poor_nat_>


/*****************************************************************************************************
*                                                                                                    *
                                   INTERNATIONAL POVERTY
*                                                                                                    *
*****************************************************************************************************/


	glo year=2011
	
	** USE SARMD CPI AND PPP
		capture drop _merge
		gen urb=.
		merge m:1 countrycode year urb using "${pricedata}", ///
		keepusing(countrycode year urb syear cpi${year}_w ppp${year})
		drop urb
		drop if _merge!=3
		drop _merge
		
		
	** CPI VARIABLE
	*<_cpi_>
		ren cpi${year}_w cpi
		la var cpi "CPI (Base ${year}=1)"
	*</_cpi_>

		
	** PPP VARIABLE
	*<_ppp_>
		ren ppp${year} 	ppp
		la var ppp "PPP ${year}"
	*</_ppp_>

		
	** CPI PERIOD
	*<_cpiperiod_>
		gen cpiperiod=syear
		la var cpiperiod "Periodicity of CPI (year, year&month, year&quarter, weighted)"
	*</_cpiperiod_>
		
		
	** POVERTY LINE (POVCALNET)
	*<_pline_int_>
		gen pline_int=1.90*cpi*ppp*365/12
		la var pline_int "Poverty Line (Povcalnet)"
	*</_pline_int_>
		
		
	** HEADCOUNT RATIO (POVCALNET)
	*<_poor_int_>
		gen poor_int=welfare<pline_int & welfare!=.
		la def poor_int 0 "Not Poor" 1 "Poor"
		la val poor_int poor_int
		la var poor_int "People below Poverty Line (Povcalnet)"
	*</_poor_int_>


/*****************************************************************************************************
*                                                                                                    *
                                   FINAL STEPS
*                                                                                                    *
*****************************************************************************************************/




** KEEP VARIABLES - ALL

	keep countrycode year int_year survey int_month idh idp wgt pop_wgt strata psu vermast veralt urban subnatid1 subnatid2 gaul_adm1_code gaul_adm2_code ///
		subnatid3 ownhouse water water_original water_source improved_water pipedwater_acc watertype_quest ///
		toilet sanitation_original sanitation_source improved_sanitation toilet_acc electricity landphone ///
		television fan sewingmachine washingmachine refrigerator lamp bicycle motorcycle motorcar cow buffalo /// 
		cellphone computer internet hsize relationharm relationcs male age soc marital ed_mod_age atschool ///
		literacy educy educat7 educat5 educat4 everattend lb_mod_age lstatus lstatus_year empstat empstat_year ///
		njobs njobs_year ocusec nlfreason unempldur_l unempldur_u industry occup numoccup firmsize_l firmsize_u ///
		whours wage unitwage empstat_2 empstat_2_year industry_2 industry_orig_2 occup_2 wage_2 unitwage_2 contract ///
		healthins socialsec union spdef welfare welfarenom welfaredef welfaretype welfareother welfareothertype ///
		pline_nat poor_nat cpi ppp cpiperiod pline_int poor_int quintile_cons_aggregate decile_cons_aggregate

** ORDER VARIABLES

	order countrycode year int_year survey int_month idh idp wgt pop_wgt strata psu vermast veralt urban subnatid1 subnatid2 gaul_adm1_code gaul_adm2_code ///
		subnatid3 ownhouse water water_original water_source improved_water pipedwater_acc watertype_quest ///
		toilet sanitation_original sanitation_source improved_sanitation toilet_acc electricity landphone ///
		television fan sewingmachine washingmachine refrigerator lamp bicycle motorcycle motorcar cow buffalo ///
		cellphone computer internet hsize relationharm relationcs male age soc marital ed_mod_age atschool ///
		literacy educy educat7 educat5 educat4 everattend lb_mod_age lstatus lstatus_year empstat empstat_year ///
		njobs njobs_year ocusec nlfreason unempldur_l unempldur_u industry occup numoccup firmsize_l firmsize_u ///
		whours wage unitwage empstat_2 empstat_2_year industry_2 industry_orig_2 occup_2 wage_2 unitwage_2 contract ///
		healthins socialsec union spdef welfare welfarenom welfaredef welfaretype welfareother welfareothertype ///
		quintile_cons_aggregate decile_cons_aggregate pline_nat poor_nat cpi ppp cpiperiod pline_int poor_int
	
	compress

** DELETE MISSING VARIABLES


	foreach w in welfare welfareother {
	
		qui su `w'
		if r(N)==0 {
		
			drop `w'type
		
		}
	}

	glo keep=""
	qui levelsof countrycode, local(cty)
	foreach var of varlist countrycode - poor_int {
		capture assert mi(`var')
		if !_rc {
		
			 display as txt "Variable " as result "`var'" as txt " for countrycode " as result `cty' as txt " contains all missing values -" as error " Variable Deleted"
			 
		}
		else {
		
			 glo keep = "$keep"+" "+"`var'"
			 
		}
	}
	


	keep countrycode year idh idp wgt strata psu vermast veralt int_year ${keep} 
	
	compress

	saveold "${output}\Data\Harmonized\LKA_2016_HIES_v01_M_v01_A_SARMD_IND.dta", replace version(13)
	saveold "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\__REGIONAL\Individual Files\LKA_2016_HIES_v01_M_v01_A_SARMD_IND.dta", replace version(13)

	log close



******************************  END OF DO-FILE  *****************************************************/
