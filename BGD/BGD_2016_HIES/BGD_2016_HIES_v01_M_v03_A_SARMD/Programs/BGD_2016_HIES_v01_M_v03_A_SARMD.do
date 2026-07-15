******************************************************************************************************
/*****************************************************************************************************
**                                                                                                  **
**                                   SOUTH ASIA MICRO DATABASE                                      **
**                                                                                                  **
** COUNTRY			 Bangladesh
** COUNTRY ISO CODE	 BGD
** YEAR				 2016
** SURVEY NAME		 HOUSEHOLD INCOME AND EXPENDITURE SURVEY-2016
** SURVEY AGENCY	 BANGLADESH BUREAU OF STATISTICS
** RESPONSIBLE		 Fernando Enrique Morales Velandia
** CREATION DATE	 1/23/2018
** MODIFICATION DATA 03/29/2018
**
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
	set more off, perm

** DIRECTORY
	glo input "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\BGD\BGD_2016_HIES\BGD_2016_HIES_v01_M"
	glo output "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\BGD\BGD_2016_HIES\BGD_2016_HIES_v01_M_v03_A_SARMD"
	glo pricedata "D:\SOUTH ASIA MICRO DATABASE\CPI\cpi_ppp_sarmd_weighted.dta"
	glo shares "D:\SOUTH ASIA MICRO DATABASE\APPS\DATA CHECK\Food and non-food shares\BGD"
	glo fixlabels "D:\SOUTH ASIA MICRO DATABASE\APPS\DATA CHECK\Label fixing"

** LOG FILE
	log using "${output}\Doc\Technical\BGD_2016_HIES_v01_M_v03_A_SARMD.log", replace


/*****************************************************************************************************
*                                                                                                    *
                                   * ASSEMBLE DATABASE
*                                                                                                    *
*****************************************************************************************************/

	**** ROASTER
	use "${input}\Data\Stata\HH_SEC_1A", clear
	tempfile roster
	ren indid idp
	sort hhid idp
	duplicates report idp hhid s1aq01 s1aq03 s1aq02 s1aq05 
	duplicates drop idp hhid s1aq01 s1aq03 s1aq02 s1aq05, force
	egen member1= count(idp), by(hhid)
	drop if member1==0
	drop if idp==.
	save `roster', replace
	
	
	**** EMPLOYMENT 
	use "${input}\Data\Stata\HH_SEC_1B", clear
	tempfile employment
	ren indid idp
	sort hhid idp
	drop if idp==.
	duplicates report idp hhid
	save `employment', replace
	
	
	**** WAGE EMPLOYMENT
	use "${input}\Data\Stata\HH_SEC_4",clear
	tempfile wage_employment
	ren indid idp
	sort idp hhid
	keep psu hhid hhwgt idp s4aq01b s4aq01c s4aq02 s4aq03 s4aq04 s4aq07 s4aq08 ///
	s4bq01 s4bq02a s4bq02b s4bq02c s4bq03 s4bq04 s4bq05a s4bq05b s4bq06 s4bq07 ///
	s4bq08 s4bq09 activity
	drop if idp==.
	* Drop people without reported time in the survey
	drop if s4aq02==. & s4aq03==. & s4aq04==.
	  
	** KEEP MAIN ACTIVITY AND SECOND ACTIVITY
	keep if inlist(activity,1,2)
	* Number of jobs
	gen one=1
	bys psu hhid idp: egen njobs=total(one)
	drop one
	duplicates report psu hhid idp
	ren (s4aq01b s4aq01c s4aq02 s4aq03 s4aq04 s4aq07 s4aq08 s4bq01 s4bq02a ///
	s4bq02b s4bq02c s4bq03 s4bq04 s4bq05a s4bq05b s4bq06 s4bq07 s4bq08 s4bq09) ///
	(s4aq01b_ s4aq01c_ s4aq02_ s4aq03_ s4aq04_ s4aq07_ s4aq08_ s4bq01_ ///
	s4bq02a_ s4bq02b_ s4bq02c_ s4bq03_ s4bq04_ s4bq05a_ s4bq05b_ s4bq06_ ///
	s4bq07_ s4bq08_ s4bq09_)
	* Keep only one observation per person (reshape the database)
	reshape wide s4aq01b_ s4aq01c_ s4aq02_ s4aq03_ s4aq04_ s4aq07_ s4aq08_ ///
	s4bq01_ s4bq02a_ s4bq02b_ s4bq02c_ s4bq03_ s4bq04_ s4bq05a_ s4bq05b_ ///
	s4bq06_ s4bq07_ s4bq08_ s4bq09_, i(psu hhid idp) j(activity)
	save `wage_employment', replace
	  
	  
	** EDUCATION (LITERACY AND ATTAINMENT)
	use "${input}\Data\Stata\HH_SEC_2A", clear
	tempfile education_all
	ren indid idp
	sort hhid idp
	drop if idp==.
	duplicates report idp hhid s2aq01 s2aq02 s2aq04 s2aq03
	duplicates drop idp hhid s2aq01 s2aq02 s2aq04 s2aq03, force
	save `education_all', replace
	
	
	** EDUCATION (CURRENT ENROLLMENT)
	use "${input}\Data\Stata\HH_SEC_2B",clear
	tempfile education_current
	ren indid idp	
	sort hhid idp
	drop if idp==.
	duplicates report hhid idp s2bq01 s2bq03 s2bq02
	duplicates drop hhid idp s2bq01 s2bq03 s2bq02, force
	save `education_current', replace
	
	
	** ASSESTS (MATERIAL)
	use "${input}\Data\Stata\HH_SEC_9E.dta", clear
	tempfile assets
	drop if s9eq00==.
	gen assets=1 if s9eq01b=="X"
	replace assets=0 if s9eq01a=="X"
	replace assets=1 if s9eq02!=.
	*Some cases of mismatch data (the data doesn't allows us to classify if the person has the asset)
	replace assets=. if s9eq01b=="X" & s9eq01a=="X"  // Mark both Yes and No
	replace assets=. if s9eq01a=="X" & s9eq02!=.	 // Mark No but have number of items
	replace assets=. if assets==1 & s9eq02==.		 // Mark Yes but doesn't have the number
	
	keep hhid assets s9eq00
	* Clasification of assets according to the rawdata
	/*	
	tab s9eq00



							 Item Code |      Freq.     Percent        Cum.
	-----------------------------------+-----------------------------------
								 Radio |     45,888        3.57        3.57
		   Two-in-one, Cassette player |     45,874        3.57        7.14
					 Camera/ camcorder |     45,874        3.57       10.72
							   Bicycle |     45,874        3.57       14.29
				   Motorcycle/ scooter |     45,874        3.57       17.86
						Motor car etc. |     45,873        3.57       21.43
			   Refrigerator or freezer |     45,873        3.57       25.00
					   Washing machine |     45,873        3.57       28.57
								  Fans |     45,873        3.57       32.14
							   Heaters |     45,873        3.57       35.72
							Television |     45,873        3.57       39.29
						  VCR/ VCP/DVD |     45,873        3.57       42.86
				  Dish antena/ decoder |     45,873        3.57       46.43
			  Pressure lamps/ petromax |     45,873        3.57       50.00
						Sewing machine |     45,873        3.57       53.57
					 Bedroom Furniture |     45,873        3.57       57.14
				Drawing room Furniture |     45,872        3.57       60.72
				 Dining room Furniture |     45,872        3.57       64.29
								Carpet |     45,872        3.57       67.86
			   Kitchen Items - Cutlery |     45,872        3.57       71.43
			  Kitchen Items - Crockery |     45,872        3.57       75.00
	 Mocrooven/Kitchen Items - Cooking |     45,872        3.57       78.57
	Tubewell (for drinking water only) |     45,872        3.57       82.14
				Wrist watch/Wall clock |     45,872        3.57       85.72
								Mobile |     45,872        3.57       89.29
					  Computer/TV Card |     45,871        3.57       92.86
						   Boat/Others |     45,868        3.57       96.43
								 Total |     45,868        3.57      100.00
	-----------------------------------+-----------------------------------
								 Total |  1,284,442      100.00


	. tab s9eq00, nol

	  Item Code |      Freq.     Percent        Cum.
	------------+-----------------------------------
			571 |     45,888        3.57        3.57
			572 |     45,874        3.57        7.14
			573 |     45,874        3.57       10.72
			574 |     45,874        3.57       14.29
			575 |     45,874        3.57       17.86
			576 |     45,873        3.57       21.43
			577 |     45,873        3.57       25.00
			578 |     45,873        3.57       28.57
			579 |     45,873        3.57       32.14
			581 |     45,873        3.57       35.72
			582 |     45,873        3.57       39.29
			583 |     45,873        3.57       42.86
			584 |     45,873        3.57       46.43
			585 |     45,873        3.57       50.00
			586 |     45,873        3.57       53.57
			587 |     45,873        3.57       57.14
			588 |     45,872        3.57       60.72
			589 |     45,872        3.57       64.29
			591 |     45,872        3.57       67.86
			592 |     45,872        3.57       71.43
			593 |     45,872        3.57       75.00
			594 |     45,872        3.57       78.57
			595 |     45,872        3.57       82.14
			596 |     45,872        3.57       85.72
			597 |     45,872        3.57       89.29
			598 |     45,871        3.57       92.86
			599 |     45,868        3.57       96.43
			600 |     45,868        3.57      100.00
	------------+-----------------------------------
		  Total |  1,284,442      100.00
	*/

	* Keep assets that are used in the harmonized variables
	keep if s9eq00==571 | s9eq00==598 | s9eq00==582 | s9eq00==579 | s9eq00==586 ///
	 | s9eq00==578  | s9eq00==585  | s9eq00==574 | s9eq00==575 | s9eq00==576 | s9eq00==577
	 	 
	reshape wide assets, i(hhid) j(s9eq00)
	duplicates report hhid
	save `assets', replace 
	
	
	** ASSETS (ANIMALS)
	use "${input}\Data\Stata\HH_SEC_7C1", clear	
	tempfile assets_animal
	sort hhid
	* Keep assets that are used in the harmonized variables (cow, buffalo and chicken)
	keep if (s7c1q00==201 | s7c1q00==204 | s7c1q00==205)
	keep hhid s7c1q02a s7c1q00   
	replace s7c1q02a=1 if s7c1q02a>=1 & s7c1q02a!=.
	replace s7c1q02a=0 if s7c1q02a==.
	ren (s7c1q02a) (s7c1q02a_)
	reshape wide s7c1q02a_, i(hhid) j(s7c1q00)
	duplicates report hhid
	save `assets_animal', replace
	
	
	** CONSUMPTION
	use "${input}\Data\Stata\poverty_indicators2016", clear
	tempfile consumption
	sort hhid
	duplicates report hhid
	save `consumption', replace
	
	
	** HOUSING
	use "${input}\Data\Stata\HH_SEC_6A", clear
	tempfile housing
	sort hhid
	duplicates report hhid
	save `housing', replace
	
	
	** LAND
	use "${input}\Data\Stata\HH_SEC_7A", clear
	tempfile land
	sort hhid
	duplicates report hhid
	save `land', replace
	
	
	** MERGE DATASETS
	* Individual-level datasets
	
	use `roster', clear
	foreach i in employment education_all education_current wage_employment {
	
		merge 1:1 hhid idp using  ``i'', keep(1 3) nogen
		
	}
	
	*Household-level datasets
	foreach j in housing consumption assets assets_animal land {
	
		merge m:1 hhid using ``j'', keep(1 3) nogen
		
	}
	
	order hhid idp psu hhwgt
	sort hhid idp
	ren idp idp1
	
/*******************************************************************************
*                                                                              *
                           STANDARD SURVEY MODULE
*                                                                              *
*******************************************************************************/
	
	
	** COUNTRY
	*<_countrycode_>
		gen str4 countrycode="BGD"
		la var countrycode "Country code"
	*</_countrycode_>


	** YEAR
	*<_year_>
		cap drop year
		gen int year=2016
		la var year "Year of survey"
	*</_year_>


	** SURVEY NAME 
	*<_survey_>
		gen str survey="HIES"
		la var survey "Survey Acronym"
	*</_survey_>


	** INTERVIEW YEAR
	*<_int_year_>
		gen byte int_year=.
		la var int_year "Year of the interview"
	*</_int_year_>
		
		
	** INTERVIEW MONTH
	*<_int_month_>
		gen byte int_month=.
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
		egen idh=concat(psu hhid), punct(-)
		la var idh "Household id"
	*</_idh_>


	** INDIVIDUAL IDENTIFICATION NUMBER
	*<_idp_>
		egen idp=concat(idh idp1), punct(-)
		label var idp "Individual id"
	*</_idp_>


	** HOUSEHOLD WEIGHTS
	*<_wgt_>
		gen double wgt=hhwgt
		la var wgt "Household sampling weight"
	*</_wgt_>

		
	** STRATA
	*<_strata_>.
		egen strata=concat(year stratum) 
		destring strata, replace
		la var strata "Strata"
		note strata: Stratum in HIES 2016 is different to previous years and has 132 strata. ///
		To compute means with standard errors and confidence intervals for all the ///
		available years we create a harmonized stratum variable. Since stratum in ///
		2016 has 2 equal numbers (11,12) to stratum16 (2000, 2005, and 2010) we ///
		create a variable with 2016 before the stratum variable 2016. 
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
		gen veralt="03"
		la var veralt "Alteration Version"
	*</_veralt_>	
	
	
/*******************************************************************************
*                                                                              *
                      HOUSEHOLD CHARACTERISTICS MODULE
*                                                                              *
*******************************************************************************/


	** LOCATION (URBAN/RURAL)
	*<_urban_>
		gen byte urban=urbrural
		recode urban (1 = 0) (2 = 1)
		la def lblurban 1 "Urban" 0 "Rural", replace
		la val urban lblurban
		la var urban "Urban/Rural"
	*</_urban_>
	

	** REGIONAL AREAS

	** REGIONAL AREA 1 DIGIT ADMN LEVEL
	*<_subnatid1_>
		gen byte subnatid1=.
		replace subnatid1=division_code
		replace subnatid1=30 if (subnatid1==45 & year==2016)
		la def lblsubnatid1 10 "Barisal" 20 "Chittagong" 30 "Dhaka" 40 "Khulna" 50 "Rajshahi" 55 "Rangpur" 60 "Sylhet"
		la val subnatid1 lblsubnatid1
		la var subnatid1 "Region at 1 digit (ADMN1)"
		note subnatid1: Mymensingh Division was created in 2015 from districts ///
		previously comprising the northern part of Dhaka Division. We combine ///
		Mymensingh with Dhaka in this database.
	*</_subnatid1_>
		
			
	** REGIONAL AREA 2 DIGIT ADMN LEVEL
	*<_subnatid2_>
		gen byte subnatid2=zila_code
		la def lblsubnatid2 1 "Bagerhat", add
		la def lblsubnatid2 3 "Bandarban", add
		la def lblsubnatid2 4 "Barguna", add
		la def lblsubnatid2 6 "Barisal", add
		la def lblsubnatid2 9 "Bhola", add
		la def lblsubnatid2 10 "Bogra", add
		la def lblsubnatid2 12 "Brahmanbaria", add
		la def lblsubnatid2 13 "Chandpur", add
		la def lblsubnatid2 15 "Chittagong", add
		la def lblsubnatid2 18 "Chuadanga", add
		la def lblsubnatid2 19 "Comilla", add
		la def lblsubnatid2 22 "Cox's bazar", add
		la def lblsubnatid2 26 "Dhaka", add
		la def lblsubnatid2 27 "Dinajpur", add
		la def lblsubnatid2 29 "Faridpur", add
		la def lblsubnatid2 30 "Feni", add
		la def lblsubnatid2 32 "Gaibandha", add
		la def lblsubnatid2 33 "Gazipur", add
		la def lblsubnatid2 34 "Rajbari", add
		la def lblsubnatid2 35 "Gopalganj", add
		la def lblsubnatid2 36 "Habiganj", add
		la def lblsubnatid2 38 "Jaipurhat", add
		la def lblsubnatid2 39 "Jamalpur", add
		la def lblsubnatid2 41 "Jessore", add
		la def lblsubnatid2 42 "Jhalokati", add
		la def lblsubnatid2 44 "Jhenaidah", add
		la def lblsubnatid2 46 "Khagrachari", add
		la def lblsubnatid2 47 "Khulna", add
		la def lblsubnatid2 48 "Kishoreganj", add
		la def lblsubnatid2 49 "Kurigram", add
		la def lblsubnatid2 50 "Kushtia", add
		la def lblsubnatid2 51 "Lakshmipur", add
		la def lblsubnatid2 52 "Lalmonirhat", add
		la def lblsubnatid2 54 "Madaripur", add
		la def lblsubnatid2 55 "Magura", add
		la def lblsubnatid2 56 "Manikganj", add
		la def lblsubnatid2 57 "Meherpur", add
		la def lblsubnatid2 58 "Maulvibazar", add
		la def lblsubnatid2 59 "Munshigan", add
		la def lblsubnatid2 61 "Mymensingh", add
		la def lblsubnatid2 64 "Naogaon", add
		la def lblsubnatid2 65 "Narail", add
		la def lblsubnatid2 67 "Narayanganj", add
		la def lblsubnatid2 68 "Narsingdi", add
		la def lblsubnatid2 69 "Natore", add
		la def lblsubnatid2 70 "Nawabganj", add
		la def lblsubnatid2 72 "Netrokona", add
		la def lblsubnatid2 73 "Nilphamari", add
		la def lblsubnatid2 75 "Noakhali", add
		la def lblsubnatid2 76 "Pabna", add
		la def lblsubnatid2 77 "Panchagar", add
		la def lblsubnatid2 78 "Patuakhali", add
		la def lblsubnatid2 79 "Pirojpur", add
		la def lblsubnatid2 81 "Rajshahi", add
		la def lblsubnatid2 82 "Rajbari", add
		la def lblsubnatid2 84 "Rangamati", add
		la def lblsubnatid2 85 "Rangpur", add
		la def lblsubnatid2 86 "Shariatpur", add
		la def lblsubnatid2 87 "Satkhira", add
		la def lblsubnatid2 88 "Sirajganj", add
		la def lblsubnatid2 89 "Sherpur", add
		la def lblsubnatid2 90 "Sunamganj", add
		la def lblsubnatid2 91 "Sylhet", add
		la def lblsubnatid2 93 "Tangail", add
		la def lblsubnatid2 94 "Thakurgaon", add
		la val subnatid2 lblsubnatid2
		la var subnatid2 "Region at 2 digit (ADMN2)"
	*</_subnatid2_>
		
		
	** REGIONAL AREA 3 DIGIT ADMN LEVEL
	*<_subnatid3_>
		gen byte subnatid3=.
		la val subnatid3 lblsubnatid3
		la var subnatid3 "Region at 3 digit (ADMN3)"
	*</_subnatid3_>
		
		
	** REGIONAL AREA 4 DIGIT ADMN LEVEL
	*<_subnatid4_>
		gen byte subnatid4=.
		la val subnatid4 lblsubnatid4
		la var subnatid4 "Region at 4 digit (ADMN3)"
	*</_subnatid4_>
	
	
	** SUBNATLEV
	*<_subnatlev_>
		gen subnatlev=2
		la var subnatlev "Lowest level of representativity"
	*<_subnatlev_>
	
	
	** PREVIOUS ** 
		gen subnatid1_prev=.
		gen subnatid2_prev=.
		gen subnatid3_prev=.
		gen subnatid4_prev=.

			
	** HOUSE OWNERSHIP
	*<_ownhouse_>
		gen byte ownhouse=.
		replace ownhouse=1 if s6aq23==1
		replace ownhouse=0 if (s6aq23!=1 & s6aq23!=.)
		replace ownhouse=. if s6aq23==5 
		la def lblownhouse 0 "No" 1 "Yes"
		la val ownhouse lblownhouse
		la var ownhouse "House ownership"
		note ownhouse: "BGD 2016" There is an extra categorie and it is ///
		classified as missing.
	*</_ownhouse_>


	** TENURE OF DWELLING
	*<_tenure_>
		gen tenure=.
		replace tenure=1 if s6aq23==1
		replace tenure=2 if s6aq23==2 
		replace tenure=3 if s6aq23==3 
		la def lbltenure 1 "Owner" 2"Renter" 3"Other"
		la val tenure lbltenure
		la var tenure "Tenure of Dwelling"
	*</_tenure_>	


	** LANDHOLDING
	*<_landholding_>
	   gen landholding= (s7aq01>0 | s7aq02>0 | s7aq03>0) if !mi(s7aq01,s7aq02,s7aq03)
	   la def lbllandholding 0 "No" 1 "Yes"
	   la val landholding lbllandholding
	   la var landholding "Household owns any land"
	   note landholding: "BGD 2016" dummy activated if hh owns at least more ///
	   than 0 decimals of any type of land (aggricultural, dwelling, ///
	   non-productive).
	*</_landholding_>	


	** ORIGINAL WATER CATEGORIES
	*<_water_original_>
		clonevar j=s6aq12
		#delimit
		la def lblwater_orig 1 "Supply water"
							 2 "Tubewell"
							 3 "Pond/river"
							 4 "Well"
							 5 "Waterfall/string"
							 6 "Other";
		#delimit cr
		la val j lblwater_orig
		decode j, gen(water_original)
		drop j
		la var water_original "Source of Drinking Water-Original from raw file"
	*</_water_original_>


	** INTERNATIONAL WATER COMPARISON (Joint Monitoring Program)
	*<_water_jmp_>
		gen water_jmp=.
		replace water_jmp=1 if s6aq12==1
		replace water_jmp=4 if s6aq12==2
		replace water_jmp=12 if s6aq12==3
		replace water_jmp=14 if s6aq12==4
		replace water_jmp=14 if s6aq12==5
		replace water_jmp=14 if s6aq12==6
		#delimit
		la def lblwater_jmp 1 "Piped into dwelling" 	
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
		la val  water_jmp lblwater_jmp
		la var water_jmp "Source of drinking water-using Joint Monitoring Program categories"
		note water_jmp: "BGD 2016" Categories "Well" and "Waterfall / Spring" ///
		are classified as other according to JMP definitions, given that this ///
		are ambigous categories. 
		note water_jmp: "BGD 2016" note that "Piped into dwelling" category does ///
		not necessarily cover water supplied into dwelling. It may be tap water ///
		into compound or from public tap. See technical documentation from Water ///
		GP for further detail.
	*</_water_jmp_>


	** WATER SOURCE
	*<_water_source_>
		gen water_source=.
		replace water_source=1 if s6aq12==1
		replace water_source=4 if s6aq12==2
		replace water_source=13 if s6aq12==3
		replace water_source=14 if s6aq12==4
		replace water_source=14 if s6aq12==5
		replace water_source=14 if s6aq12==6
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

		
	** PIPED SOURCE OF WATER
	*<_piped_water_>
		gen piped_water= s6aq12==1 if s6aq12!=.
		la def lblpiped_water 1 "Yes" 0 "No"
		la val piped_water lblpiped_water
		la var piped_water "Household has access to piped water"
		note piped_water: "BGD 2016" note that "Supply water" category does not ///
		necessarily cover water supplied into dwelling. It may be tap water ///
		into compound or from public tap. ///
		See technical documentation from Water GP for further detail.
	*</_piped_water_>


	** PIPED SOURCE OF WATER ACCESS
	*<_pipedwater_acc_>
		gen pipedwater_acc=0 if inlist(s6aq12,2,3,4,5,6) // Asuming other is not piped water
		replace pipedwater_acc=3 if inlist(s6aq12,1)
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
		gen watertype_quest=3
		#delimit
		la def lblwaterquest_type	1 "Drinking water"
									2 "General water"
									3 "Both"
									4 "Others";
		#delimit cr
		la val watertype_quest lblwaterquest_type
		la var watertype_quest "Type of water questions used in the survey"
	*</_watertype_quest_>

	
	** ORIGINAL SANITATION CATEGORIES 
	*<_sanitation_original_>
		clonevar j=s6aq10
		#delimit
		la def lbltoilet_orig 1 "Sanitary"
							  2 "Pacca latrine (Water seal)"
							  3 "Pacca latrine (Pit)"
							  4 "Kacha latrine (perm)"
							  5 "Kacha latrine (temp)"
							  6 "Other";
		#delimit cr
		la val j lbltoilet_orig
		decode j, gen(sanitation_original)
		drop j
		la var sanitation_original "Access to sanitation facility-Original from raw file"
	*</_sanitation_original_>


	** SEWAGE TOILET
	*<_sewage_toilet_>
		gen sewage_toilet=s6aq10
		recode sewage_toilet (2/6 = 0)
		la def lblsewage_toilet 1 "Yes" 0 "No"
		la val sewage_toilet lblsewage_toilet
		la var sewage_toilet "Household has access to sewage toilet"
	*</_sewage_toilet_>


	** INTERNATIONAL SANITATION COMPARISON (Joint Monitoring Program)
	*<_toilet_jmp_>
		gen toilet_jmp=.
		#delimit 
		la def lbltoilet_jmp 1 "Flush to piped sewer system"
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
		la var toilet_jmp "Access to sanitation facility-using Joint Monitoring Program categories"
	*</_toilet_jmp_>


	** SANITATION SOURCE
	*<_sanitation_source_>
		gen sanitation_source=.
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
		replace improved_sanitation=1 if inlist(s6aq10,1,2,3)
		replace improved_sanitation=0 if inlist(s6aq10,4,5,6)
		la def lblsar_improved_toilet 1 "Improved" 0 "Unimproved"
		la val improved_sanitation lblsar_improved_toilet
		la var improved_sanitation "Improved type of sanitation facility-using country-specific definitions"
	/* WASH team: Replace shared facilities as unimproved */
		replace improved_sanitation=0 if s6aq11==1
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
		recode s6aq17 (2 = 0) (3 = .), gen (electricity)
		la def lblelectricity 0 "No" 1 "Yes", replace
		la val electricity lblelectricity
		la var electricity "Electricity main source"
	*</_electricity_>


	** LAND PHONE
	*<_landphone_>
		recode s6aq19 (2 = 0) (3 = .), gen(landphone)
		la def lbllandphone 0 "No" 1 "Yes"
		la val landphone lbllandphone
		la var landphone "Phone availability"
	*</_landphone_>


	** CELLPHONE
	*<_cellphone_>
		recode s1aq10 (2 = 0), gen(cellphone) 
		* fix: 
		bysort hhid: egen cellphone_total=sum(cellphone)
		replace cellphone=1 if cellphone_total>1
		la def lblcellphone 0 "No" 1 "Yes"
		la val cellphone lblcellphone
		la var cellphone "Cell phone"
	*</_cellphone_>
		
		
	** COMPUTER
	*<_computer_>
		recode s6aq20 (2 = 0) (0 = .), gen(computer)
		la def lblcomputer 0 "No" 1 "Yes"
		la val computer lblcomputer
		la var computer "Computer availability"
	*</_computer_>


	** INTERNET
	*<_internet_>
		recode s6aq21 (2 = 0) (0 = .), gen(internet)
		la def lblinternet 0 "No" 1 "Yes"
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
		ren member hsize
		la var hsize "Household size"
	*</_hsize_>

	**POPULATION WEIGHT
	*<_pop_wgt_>
		gen pop_wgt=wgt*hsize
		la var pop_wgt "Population weight"
	*</_pop_wgt_>


	** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
	*<_relationharm_>

	*Head of household corrected variable provided by the Bangladesh team
	
	**********************Correction to household head variable*********************

	*Members of household
	bys hhid: egen member=count(idp1)

	*Household heads
	replace s1aq02=. if s1aq02==0
	replace s1aq02=14 if s1aq02==. & hhid==387041 & idp1==2

	gen head=(s1aq02==1) if s1aq02!=.
	bys hhid: egen heads=total(head) 
	replace heads=. if head==.

	egen hh=tag(hhid)
	tab heads if hh==1

	*Maximum age inside the household
	bys hhid: egen maxage=max(s1aq03)
	gen oldest=(s1aq03==maxage)

	*Highest age of males in the household
	bys hhid: egen maxageman=max(s1aq03) if s1aq01==1
	gen oldestman=(s1aq03==maxageman)

	*Household head is male married
	gen menmarriedhh= (s1aq01==1 & s1aq02==1 & s1aq05==1) 
	bys hhid: egen menmarriedhht=total(menmarriedhh)

	*Male married
	gen malemarried=(s1aq05==1 & s1aq01==1)
	bys hhid: egen malemarriedt=total(malemarried) if s1aq01!=.

	*Household head is female
	gen femalehh=(s1aq01==2 & s1aq02==1)
	bys hhid: egen femalehht=total(femalehh)

	*Are there any households in our sample that have a male in the household that is older than the married male household head? 
	gen aux=1 if oldestman==1 & head==0 & menmarriedhht==1 & femalehht==0
	bys hhid: egen auxt=total(aux) 
	tab auxt if hh==1
	tab s1aq02 if inlist(auxt,1) & oldest==1

	*Count number of males in the household
	gen men= (s1aq01==1) if s1aq01!=.
	bys hhid: egen ment=total(men) if s1aq01!=.

	*Female is the oldest member in the household
	gen oldestisfemale=(s1aq03==maxage & s1aq01==2)
	bys hhid: egen oldestisfemalet=total(oldestisfemale)

	*Males aged 16 years and above
	gen young=(s1aq03>15 & s1aq01==1)
	bys hhid: egen youngt=total(young)

	****************Apply rules to correct household head***************************

	*Create the new household head variable
	gen p=.
	gen headnew=.
	replace headnew=1 if head==1 & heads==1

	*1. Households with only one member and they have zero household head 
	replace p=1 if heads==0 & member==1 
	bys hhid: egen heads2=total(p)
	tab heads2 if hh==1
	replace headnew=p if heads2==1
	replace heads=heads2 if heads2==1
	tab heads if hh==1

	*2. Highest age and male married
	cap drop heads2
	replace p=.
	replace p=1 if inlist(heads,0,2,3,4,6) & oldest==1  &  malemarried==1  
	bys hhid: egen heads2=total(p)
	tab heads2 if hh==1
	replace headnew=p if heads2==1
	replace heads=heads2 if heads2==1
	tab heads if hh==1

	*3. Male married
	cap drop heads2
	replace p=.
	replace p=1 if inlist(heads,0,2,3,4,6) & malemarried==1 
	bys hhid: egen heads2=total(p)
	tab heads2 if hh==1
	replace headnew=p if heads2==1
	replace heads=heads2 if heads2==1
	tab heads if hh==1

	*4. Among males in the household the one with highest age if a female is not the oldest member in the household
	cap drop heads2
	replace p=.
	replace p=1 if inlist(heads,0,2,3,4,6) & oldestman==1 & oldestisfemalet==0
	bys hhid: egen heads2=total(p)
	tab heads2 if hh==1
	replace headnew=p if heads2==1
	replace heads=heads2 if heads2==1
	tab heads if hh==1

	*5. Female with highest age and zero males aged 16 years and above in the household
	cap drop heads2
	replace p=.
	replace p=1 if inlist(heads,0,2,3,4,6) & oldest==1 & s1aq01==2 & youngt==0
	bys hhid: egen heads2=total(p)
	tab heads2 if hh==1
	replace headnew=p if heads2==1
	replace heads=heads2 if heads2==1
	tab heads if hh==1

	*6. Male with highest age
	cap drop heads2
	replace p=.
	replace p=1 if inlist(heads,0,2,3,4,6) & oldestman==1
	bys hhid: egen heads2=total(p)
	tab heads2 if hh==1
	replace headnew=p if heads2==1
	replace heads=heads2 if heads2==1
	tab heads if hh==1

	*1 household without information to indentify the household head
	replace headnew=. if heads==0

	*Correct relationship of members with the head of household variable
	replace headnew=0 if headnew==. & s1aq02!=.
	replace  s1aq02=14 if headnew==0 & s1aq02==1
	replace s1aq02=1 if headnew==1

	gen byte relationharm=s1aq02
	recode relationharm  (6 = 4) (4 5 7 8 9 10 11 = 5) (12 13 14 = 6) (0 = .)
	#delimit
	la def lblrelationharm  1 "Head of household" 
							2 "Spouse" 
							3 "Children" 
							4 "Parents" 
							5 "Other relatives" 
							6 "Non-relatives";
	#delimit cr
	la val relationharm  lblrelationharm
	la var relationharm "Relationship to the head of household"
	*</_relationharm_>


	** RELATIONSHIP TO THE HEAD OF HOUSEHOLD (ORIGINAL SURVEY VARIABLE)
	*<_relationcs_>
		gen byte relationcs=s1aq02
		replace relationcs=. if s1aq02==0
		#delimit
		la def lblrelationcs  1 "Head" 
									2 "Husband/Wife" 
									3 "Son/Daughter" 
									4 "Spouse of Son/Daughter" 
									5 "Grandchild" 
									6 "Father/Mother" 
									7 "Brother/Sister" 
									8 "Niece/Nephew" 
									9 "Father/Mother-in-law" 
									10 "Brother/Sister-in-law" 
									11 "Other relative" 
									12 "Servant" 
									13 "Employee" 
									14 "Other";
		#delimit cr
		la val relationcs lblrelationcs
		la var relationcs "Relationship to the head of household country/region specific"
	*</_relationcs_>


	** GENDER
	*<_male_>
		gen byte male= s1aq01
		recode male (2=0)
		la def lblmale 1 "Male" 0 "Female"
		la val male lblmale
		la var male "Sex of household member"
	*</_male_>


	** AGE
	*<_age_>
		gen byte age= s1aq03
		replace age=98 if age>98 & s1aq03!=.
		la var age "Age of individual"
	*</_age_>


	** SOCIAL GROUP
	*<_soc_>
		gen byte soc=s1aq04
		#delimit 
		la def lblsoc   1 "Islam" 
						2 "Hinduism" 
						3 "Buddhism" 
						4 "Christianity" 
						5 "Other";
		#delimit cr				
		la val soc lblsoc
		la var soc "Social group"
	*</_soc_>


	** MARITAL STATUS
	*<_marital_>
		gen byte marital=.
		replace marital=1 if s1aq05==1
		replace marital=4 if s1aq05==5 | s1aq05==4
		replace marital=5 if s1aq05==3
		replace marital=2 if s1aq05==2
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
                                   DISABILITY MODULE
*                                                                                                    *
*****************************************************************************************************/

label define eye_disability_label 1 "No – no difficulty"  2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all"
label define hear_disability_label 1 "No – no difficulty"  2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all"
label define walk_disability_label 1 "No – no difficulty"  2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all"
label define conc_disability_label 1 "No – no difficulty"  2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all"
label define slfcre_disability_label 1 "No – no difficulty"  2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all"
label define comm_disability_label 1 "No – no difficulty"  2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all"

** 1. Do you have difficulty seeing, even if wearing glasses?	
	gen eye_dsablty = s1aq12
	label values eye_dsablty eye_disability_label
	label var eye_dsablty "eye_dsablty is a numerical variable that indicates whether an individual has any difficulty in seeing, even when wearing glasses."

** 2. Do you have difficulty hearing, even if using a hearing aid?	
	gen hear_dsablty = s1aq13
	label values hear_dsablty hear_disability_label
	label var hear_dsablty "hear_dsablty is a numerical variable that indicates whether an individual has any difficulty in hearing even when using a hearing aid."

** 3. Do you have difficulty walking or climbing steps?	
	gen walk_dsablty = s1aq14
	label values walk_dsablty walk_disability_label
	label var walk_dsablty "walk_dsablty is a numerical variable that indicates whether an individual has any difficulty in walking or climbing steps."

** 4. Do you have difficulty remembering or concentrating?	
	gen conc_dsord = s1aq15
	label values conc_dsord conc_disability_label
	label var conc_dsord "conc_dsord is a numerical variable that indicates whether an individual has any difficulty concentrating or remembering."

** 5. Do you have difficulty (with self-care such as) washing all over or dressing?	
	gen slfcre_dsablty = s1aq16 
	label values slfcre_dsablty slfcre_disability_label
	label var slfcre_dsablty "slfcre_dsablty is a numerical variable that indicates whether an individual has any difficulty with self-care such as washing all over or dressing."

** 6. Using your usual (customary) language, do you have difficulty communicating, for example understanding or being understood?
	gen comm_dsablty = s1aq17
	label values comm_dsablty comm_disability_label
	label var comm_dsablty "comm_dsablty is a numerical variable that indicates whether an individual has any difficulty communicating or understanding usual (customary) language."

replace eye_dsablty=. if eye_dsablty != 1 & eye_dsablty != 2 & eye_dsablty != 3 & eye_dsablty != 4
replace hear_dsablty=. if hear_dsablty != 1 & hear_dsablty != 2 & hear_dsablty != 3 & hear_dsablty != 4
replace walk_dsablty=. if walk_dsablty != 1 & walk_dsablty != 2 & walk_dsablty != 3 & walk_dsablty != 4
replace conc_dsord=. if conc_dsord != 1 & conc_dsord != 2 & conc_dsord != 3 & conc_dsord != 4
replace slfcre_dsablty=. if slfcre_dsablty != 1 & slfcre_dsablty != 2 & slfcre_dsablty != 3 & slfcre_dsablty != 4
replace comm_dsablty=. if comm_dsablty != 1 & comm_dsablty != 2 & comm_dsablty != 3 & comm_dsablty != 4
	

/*******************************************************************************
*                                                                              *
                               EDUCATION MODULE
*                                                                              *
*******************************************************************************/


	** EDUCATION MODULE AGE
	*<_ed_mod_age_>
		gen byte ed_mod_age=5
		la var ed_mod_age "Education module application age"
	*</_ed_mod_age_>


	** CURRENTLY AT SCHOOL
	*<_atschool_>
		gen byte atschool=s2bq01
		replace atschool=0 if s2bq01==2
		replace atschool=. if s2bq01>2
		replace atschool=. if age<5
		la def lblatschool 0 "No" 1 "Yes"
		la val atschool  lblatschool
		la var atschool "Attending school"
	*</_atschool_>


	** CAN READ AND WRITE
	*<_literacy_>
		gen byte literacy=.
		replace literacy=1 if (s2aq01==1 & s2aq02==1)
		replace literacy=0 if (s2aq01==2 | s2aq02==2) & literacy!=1 // A person with different response is reported as missing
		replace literacy=. if age<ed_mod_age
		* Values that don't correspond to the survey options are send to missing
		replace literacy=. if (s2aq01!=1 & s2aq01!=2) | (s2aq02!=2 & s2aq02!=1)
		la def lblliteracy 0 "No" 1 "Yes", replace
		la val literacy lblliteracy
		la var literacy "Can read & write"
	*</_literacy_>


	** YEARS OF EDUCATION COMPLETED
	*<_educy_>
		gen educy=s2aq04
		recode educy (11 = 12) (15 = 16) (18 = 18) (16 = 19) (17 = 17) (12 = 14) ///
		(14 = 14) (13 = 16) (19 = .) (21 = .)
		replace educy=s2bq03 if (educy==. & s2bq03!=.)
		*Substract one year of education to those currently studying before secondary
		replace educy=educy-1 if (s2aq04==. & s2bq03<=11 & s2bq03!=.)
		*Substract one year of education to those currently studying after secondary
		recode educy (10 = 11) (15 = 15) (18 = 17) (16 = 18) (17 = 16) (12 = 13) ///
		(14 = 13) (13 = 15) (19 = .) (21 = .) if (s2aq04==. & s2bq03!=.)
		replace educy=0 if educy==-1
		replace educy=. if educy==50
		replace educy=. if age<5
		replace educy=. if (educy>age & educy!=. & age!=.)
		la var educy "Years of education"
		/*check: https://www.winona.edu/socialwork/Media/Prodhan%20The%20Educational%20System%20in%20Bangladesh%20and%20Scope%20for%20Improvement.pdf*/
	*</_educy_>


	** EDUCATION LEVEL 7 CATEGORIES
	*<_educat7_>
		gen byte educat7=.
		replace educat7=1 if educy==0
		replace educat7=2 if (educy>0 & educy<5)
		replace educat7=3 if (educy==5)
		replace educat7=4 if (educy>5 & educy<12)
		replace educat7=5 if (educy==12)
		replace educat7=7 if (educy>12 & educy<23)
		replace educat7=6 if inlist(educy,13,14)
		replace educat7=8 if s2aq04==19 | s2bq03==19
		replace educat7=. if age<5
		#delimit
		la def lbleducat7   1 "No education" 
							2 "Primary incomplete" 
							3 "Primary complete" 
							4 "Secondary incomplete" 
							5 "Secondary complete" 
							6 "Higher than secondary but not university" 
							7 "University incomplete or complete" 
							8 "Other" 
							9 "Not classified";
		#delimit cr
		la val educat7 lbleducat7
		la var educat7 "Level of education 7 categories"
	*</_educat7_>


	** EDUCATION LEVEL 4 CATEGORIES
	*<_educat4_>
		gen byte educat4=.
		replace educat4=1 if educat7==1 
		replace educat4=2 if educat7==2 |educat7==3
		replace educat4=3 if educat7==4 |educat7==5
		replace educat4=4 if educat7==6 |educat7==7
		la def lbleducat4 1 "No education" 2 "Primary (complete or incomplete)" ///
		3 "Secondary (complete or incomplete)" 4 "Tertiary (complete or incomplete)"
		la val educat4 lbleducat4
		la var educat4 "Level of education 4 categories"
	*</_educat4_>

	
	** EDUCATION LEVEL 5 CATEGORIES
	*<_educat5_>
		gen educat5=.
		replace educat5=1 if educat7==1
		replace educat5=2 if educat7==2
		replace educat5=3 if educat7==3 | educat7==4
		replace educat5=4 if educat7==5
		replace educat5=5 if educat7==6 |educat7==7
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


	** EVER ATTENDED SCHOOL
	*<_everattend_>
		gen byte everattend=.
		replace everattend=0 if educat7==1 
		replace everattend=1 if (educat7>=2 & educat7!=.) | atschool==1
		replace everattend=. if age<5
		la def lbleverattend 0 "No" 1 "Yes"
		la val everattend lbleverattend
		la var everattend "Ever attended school"
	*</_everattend_>

	
	replace educy=0 if everattend==0
	replace educat7=1 if everattend==0
	replace educat4=1 if everattend==0
	replace educat5=1 if everattend==0
	
	foreach var in atschool literacy educy everattend educat4 educat5 educat7 {

		replace `var'=. if age<ed_mod_age

	}

/*******************************************************************************
*                                                                              *
                                   LABOR MODULE
*                                                                              *
*******************************************************************************/


	** LABOR MODULE AGE
	*<_lb_mod_age_>
		gen byte lb_mod_age=5
		la var lb_mod_age "Labor module application age"
	*</_lb_mod_age_>


	** LABOR STATUS
	*<_lstatus_>
		gen byte lstatus=.
		replace lstatus=1 if s1bq01==1
		replace lstatus=2 if s1bq01==2 & s1bq03==1 
		replace lstatus=3 if s1bq01==2 & (s1bq02==2 | s1bq03==2)
		replace lstatus=2 if s1bq04==8 | s1bq04==10 // Waiting to start new job /and/ On leave/looking for job/business
		replace lstatus=3 if s1bq04!=. & s1bq01==2 & lstatus==.
		replace lstatus=. if age<5
		#delimit 
		la def lbllstatus   1 "Employed" 
							2 "Unemployed" 
							3 "Non-LF";
		#delimit cr
		la val lstatus lbllstatus
		la var lstatus "Labor status"
		notes lstatus: "BGD 2016" a person is considered "unemployed" if not working but waiting to start a new job.
		notes lstatus: "BGD 2016" question related to available to accept a job is not taken into account in the definition of unemployed.
	*</_lstatus_>


	** LABOR STATUS LAST YEAR
	*<_lstatus_year_>
		gen byte lstatus_year=1 if (s4aq02_1>0 & s4aq02_1<=12) | (s4aq02_2>0 & s4aq02_2<=12)
		replace lstatus_year=0 if s4aq01b_1==. 
		replace lstatus_year=. if age<lb_mod_age & age!=.
		la def lbllstatus_year 1 "Employed" 0 "Not employed" 
		la val lstatus_year lbllstatus_year
		la var lstatus_year "Labor status during last year"
	*</_lstatus_year_>


	** EMPLOYMENT STATUS
	*<_empstat_>
		gen byte empstat=.
		replace empstat=1 if (s4aq07_1==1 | s4aq08_1==1 | s4aq07_1==4 | s4aq08_1==4)
		replace empstat=3 if (s4aq07_1==3 | s4aq08_1==3)
		replace empstat=4 if (s4aq07_1==2 | s4aq08_1==2)
		replace empstat=. if lstatus!=1
		#delimit
		la de lblempstat 1 "Paid employee" 
						 2 "Non-paid employee" 
						 3 "Employer" 
						 4 "Self-employed" 
						 5 "Other";
		#delimit cr
		la val empstat lblempstat
		la var empstat "Employment status"
	*</_empstat_>


	** EMPLOYMENT STATUS LAST YEAR
	*<_empstat_year_>
		gen byte empstat_year=empstat
		replace empstat_year=. if lstatus_year!=1
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
		replace njobs=. if lstatus!=1
		la var njobs "Number of additional jobs"
	*</_njobs_>


	** NUMBER OF ADDITIONAL JOBS LAST YEAR
	*<_njobs_year_>
		gen byte njobs_year=njobs
		replace njobs_year=. if lstatus_year!=1
		la var njobs_year "Number of additional jobs during last year"
	*</_njobs_year_>


	** SECTOR OF ACTIVITY: PUBLIC - PRIVATE
	*<_ocusec_>
		gen byte ocusec=.
		replace ocusec= 1 if (s4bq06_1==1 | s4bq06_1==2 | s4bq06_1==4 | s4bq06_1==6)
		replace ocusec= 1 if (s4bq06_1==7)
		replace ocusec= 2 if (s4bq06_1==3 | s4bq06_1==5 | s4bq06_1==8)
		replace ocusec=. if lstatus!=1
		la var ocusec "Sector of activity"
		la def lblocusec 1 "Public, state owned, government, army, NGO" 2 "Private", replace
		la val ocusec lblocusec
	*</_ocusec_>


	** REASONS NOT IN THE LABOR FORCE
	*<_nlfreason_>
		gen byte nlfreason=. 
		replace nlfreason=1 if s1bq04==3
		replace nlfreason=2 if (s1bq04==2 | s1bq04==1)
		replace nlfreason=3 if s1bq04==4
		replace nlfreason=4 if s1bq04==7
		replace nlfreason=5 if (s1bq04==5 | s1bq04==6 | s1bq04>=9) & s1bq04<=11
		replace nlfreason=. if (s1bq04==0 | s1bq04==14 | lstatus!=3)
		#delimit
		la def lblnlfreason 1 "Student" 
							2 "Housewife" 
							3 "Retired" 
							4 "Disable" 
							5 "Other";
		#delimit cr
		la val nlfreason lblnlfreason
		la var nlfreason "Reason not in the labor force"
	*</_nlfreason_>


	** UNEMPLOYMENT DURATION: MONTHS LOOKING FOR A JOB
	*<_unempldur_l_>
		gen byte unempldur_l=.
		la var unempldur_l "Unemployment duration (months) lower bracket"
	*</_unempldur_l_>


	*<_unempldur_u_>
		gen byte unempldur_u=.
		la var unempldur_u "Unemployment duration (months) upper bracket"
	*</_unempldur_u_>


	** ORIGINAL INDUSTRY CLASSIFICATION
	*<_industry_orig_>
		gen industry_orig=s4aq01c_1
		#delimit
		la def lblindustry_orig
			1	"Agriculture, hunting and relating activities"
			2	"Forestry and forest-related activities"
			5	"Fishing and fish-related activities"
			10	"Minerals (coal)"
			11	"Gas and oil exploration"
			14	"Other Mineral Exploration"
			15	"Food and water production"
			16	"Production of tobacco products"
			17	"Clothing Manufacturing"
			18	"Garment production, bleached and dyed"
			19	"production of leather and leather related Goods"
			20	"Manufacture of Wood and wood products, except furniture"
			21	"Manufacture of paper and paper products"
			22	"Publishing, Printing and Recording"
			23	"Petroleum refining"
			24	"Production of chemicals"
			25	"Rubber and plastic products"
			26	"Production of other non-metallic mineral products"
			27	"Metal Manufacturing"
			28	"Production of metal products, except machinery"
			29	"Other unclassified Electronics Manufacturing"
			30	"Production of Machinery used in office and accounting"
			31	"Production of electrical equipment"
			32	"Production of Radio, television and media equipment"
			33	"Watch, glasses and medical equipment manufacturing"
			34	"Car production"
			35	"Machinery used in the production of other vehicles"
			36	"Production of furniture and unclassified"
			37	"Re-Processing"
			40	"Gas, hot water and electricity supply"
			41	"Water collection, purification and supply"
			45	"Construction"
			50	"Car and motorcycle sales, maintenance, repair and fuel sales"
			51	"Other than the business of car and motorcycle"
			52	"Car and motorcycle business and personal home use goods other than retail"
			55	"Hotel and Restaurant"
			60	"Road vehicles"
			61	"Shipping Vehicle"
			62	"Aircraft"
			63	"Travel assistance (Transport and Travel Agencies)"
			64	"Post and Telecommunications"
			65	"Financial intermediation, except insurance and pension"
			66	"Insurance and pension"
			67	"Helping financial mediation"
			70	"Real State"
			71	"Personal and home used to hire equipment"
			72	"Computer and Computer related working"
			73	"Research and development"
			74	"Other business"
			75	"Public administration, defense and compulsory social security"
			80	"Education"
			81	"Health & Social Services"
			90	"Drainage and sewerage type of work"
			92	"Entertainment, cultural and sports-related work"
			99	"Foreign Agencies";

		destring industry_orig, replace;
		replace industry_orig=. if lstatus!=1;
		la val industry_orig lblindustry_orig;

		recode industry_orig (0 3 4 6 7 8 9 12 13 39 42 43
		 44 46 47 49 53 54 56 57 58 59 76 77 78 79 82 83 84
		 85 86 87 91 94 96=.); //Incorrect codes are send to missing
		 
		#delimit cr
		la var industry_orig "Original industry code"
	*</_industry_orig_>


	** INDUSTRY CLASSIFICATION
	*<_industry_>
		gen industry=industry_orig
		destring industry,replace
		recode industry (0=.) (1/5=1) (10/14=2) (15/39=3) (40/43=4) (45/49=5) (50/59=6) (60/64=7) (65/74=8) (75=9) (76/99=10) (nonmis=.)
		replace industry=. if lstatus==2| lstatus==3
		replace industry=. if lstatus!=1
		#delimit
		la def lblindustry  1 "Agriculture" 
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
		la val industry lblindustry
		la var industry "1 digit industry classification"
	*</_industry_>


	**ORIGINAL OCCUPATION CLASSIFICATION
	*<_occup_orig_>
		gen occup_orig=s4aq01b_1
		#delimit
			la def lbloccup_orig
			1	"Physical Scientists and Related Technician"
			2	"Architects and Engineers"
			3	"Architects, Engineers and Related Technicians"
			4	"Air craft and ships officers"
			5	"Life Scientists and Related Technicians"
			6	"Medical, Dental and Veterinary surgeons"
			7	"Professional Nurse and Related Workers"
			8	"Statistician, Mathematicians, Systems Analyst and Related Workers"
			9	"Economist"
			10	"Accountants"
			12	"Jurists"
			13	"Teachers"
			14	"Workers and Religion"
			15	"Authors, Journalists and Related Writers"
			16	"Fine and Commercial Artists, Photographers and Related Creative Artists"
			17	"Actor, Singer and Dancers"
			18	"Sportsman and Related Workers"
			19	"Professional, Technical and Related Workers and Not Elsewhere Classified"
			20	"Lower"
			21	"Manager"
			30	"Government Executive Officer"
			31	"Clerical"
			32	"Typist, Stenographers"
			33	"Book-Keepers, Cashier and Related Workers"
			34	"Computer and Related Workers"
			35	"Transport and Communication Supervisor"
			36	"Driver, Conductors"
			37	"Mail Distribution Clerks"
			38	"Telephone and Telegraph Operators"
			39	"Clerical and Related Workers N.E.C"
			40	"Manager (Wholesale and Retail Trade)"
			42	"Sales Supervisors and Buyer"
			43	"Travelers and Related Workers"
			44	"Insurance, Real Estate, Business and Related Services Sales-man"
			45	"Street Vendors"
			49	"Salesmen Not Elsewhere Classified"
			50	"Residential Hotel Manager"
			51	"Working Proprietors (Catering and Lodging Services)"
			52	"Supervisor Catering and Lodging Services"
			53	"Cooks, Waiters and Related Workers"
			54	"Maids and Related Housekeeping Services Workers Not Elsewhere Classified"
			55	"Building Caretakers, Cleaners and Related Workers"
			56	"Launderers, Dry-Cleaners and Pressers"
			58	"Protective Service Workers"
			59	"Service Workers Not Elsewhere Classified"
			60	"Farm Manager and Supervisors"
			61	"Farmers"
			63	"Forestry Workers"
			64	"Fisherman, Hunts and Related Workers"
			70	"Production Supervisors and General Foreman"
			71	"Miners, Quarrymen, Well Drillers and Related Workers"
			72	"Metal Processors"
			74	"Chemical Processors and Related Workers"
			75	"Spinners, Weavers, Knitters, Dyers and Related Textile Workers"
			76	"Tanners, Fellmongers and Pelt Dressers"
			77	"Food and Beverage Processors"
			78	"Tobacco Preparers and Cigarette Makers"
			79	"Tailors, Dressmakers, Sewers, Upholsterers and Related Workers"
			80	"Shoemakers and Leather Goods Makers"
			81	"Cabinetmakers and Related Wood Workers"
			82	"Stone Cutter and Finishers"
			83	"Forging Workers, Toolmakers and Metalworking Machine Operator"
			84	"Machinery Fitters, Machinery Mechanics and Precision Instrument Makers"
			85	"Electric Worker"
			86	"Broadcast and Sound Equipment Operators and Motion Picture Projectionist"
			87	"Plumbers, Welders and Sheet Metal and Structural Metal Workers"
			88	"Jewellery and Precious Metal Workers"
			89	"Glass Foreman, Potters and Related Workers"
			90	"Rubber and Plastics Product Makers"
			91	"Paper and Paperboard Products Makers"
			92	"Printing";

		destring occup_orig, replace;
		replace occup_orig=. if lstatus!=1;
		la val occup_orig lbloccup_orig;

		recode occup_orig (11 22 25 26 41 46 47 48 57 62 65 67 69 93 96 99
		 0=.); // Incorrect codes are send to missing
		#delimit cr
		la var occup_orig "Original occupation code"
	*</_occup_orig_>


	** OCCUPATION CLASSIFICATION
	*<_occup_>
		#delimit
		recode s4aq01b_1 (1 = 3) (2 = 2) (3 = 3) (4 = 2) (5 = 3) (6 = 2) (40 = 1) 
		(8 = 2) (9 = 2) (10 = 2) (12 = 2) (13 = 2) (14 = 3) (15 = 2) (16 = 2) 
		(17 = 2) (18 = 2) (19 = 2) (20 = 1) (21 = 1) (30 = 1) (31 = 4) (32 = 4) 
		(33 = 4) (34 = 8) (35 = 8) (50 = 1) (7 = 2) (42 = 3) (39 = 4) (43 = 3) 
		(44 = 3) (86 = 3) (37 = 4) (38 = 4) (36 = 5) (45 = 5) (51 = 5) (52 = 5) 
		(53 = 5) (54 = 5) (49 = 5) (70 = 6) (58 = 5) (59 = 5) (60 = 6) (61 = 6) 
		(63 = 6) (64 = 6) (71 = 7) (72 = 7) (75 = 7) (74 = 8) (76 = 7) (77 = 7) 
		(78 = 7) (79 = 7) (80 = 7) (81 = 7) (82 = 7) (83 = 7) (84 = 7) (85 = 7) 
		(87 = 7) (88 = 7) (89 = 7) (92 = 7) (90 = 8) (91 = 8) (55 = 9) (56 = 9) 
		(11 22 25 26 41 46 47 48 57 62 65 67 69 93 96 99 0 68 73 = .) (nonmis = .), 
		gen(occup);
		replace occup=. if lstatus!=1;
		la def lbloccup 1 "Senior officials" 
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
		la val occup lbloccup
		la var occup "1 digit occupational classification"
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
		/*There are some cases of people working more than 24 hours per day. They are classified as missing*/
		replace s4aq04_1=. if s4aq04_1>24
		gen whours=int(s4aq03_1* s4aq04_1)/4.25
		replace whours=. if lstatus!=1
		la var whours "Hours of work in last week"
	*</_whours_>


	** WAGES
	*<_wage_>
		gen double wage=.
		replace wage=s4bq07_1 if s4bq01_1==2
		replace wage=s4bq02c_1 if s4bq01_1==1
		replace empstat=. if lstatus!=1	
		replace wage=0 if empstat==2
		replace wage=. if lstatus!=1
		la var wage "Last wage payment"
	*</_wage_>


	** WAGES TIME UNIT
	*<_unitwage_>
		gen byte unitwage=.
		replace unitwage=1 if s4bq01_1==1 & wage!=.
		replace unitwage=5 if s4bq01_1==2 & wage!=.
		replace unitwage=. if lstatus!=1 
		replace unitwage=0 if empstat==2
		#delimit
		la de lblunitwage   1 "Daily" 
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
	*</_wageunit_>


	** EMPLOYMENT STATUS - SECOND JOB
	*<_empstat_2_>
		gen byte empstat_2=.
		replace empstat_2=1 if (s4bq07_2==1 | s4bq08_2==1 | s4bq08_2==4 | s4bq07_2==4)
		replace empstat_2=3 if (s4bq07_2==3 | s4bq08_2==3)
		replace empstat_2=4 if (s4bq07_2==2 | s4bq08_2==2)
		replace empstat_2=. if (njobs==0 | njobs==. | lstatus!=1)
		#delimit
		la de lblempstat_2  1 "Paid employee" 
							2 "Non-paid employee" 
							3 "Employer" 
							4 "Self-employed" 
							5 "Other, workers not classifiable by status";
		#delimit cr
		la val empstat_2 lblempstat_2
		la var empstat_2 "Employment status - Second Job"
	*</_empstat_2_>


	** EMPLOYMENT STATUS - SECOND JOB LAST YEAR
	*<_empstat_2_year_>
		gen empstat_2_year=.
		replace empstat_2_year=empstat_2
		replace empstat_2_year=. if (njobs_year==0 | njobs_year==. | lstatus_year!=1)
		#delimit 
		la def lblempstat_2_year 1 "Paid employee" 
								2 "Non-paid employee" 
								3 "Employer" 
								4 "Self-employed" 
								5 "Other, workers not classifiable by status";
		#delimit cr
		la val empstat_2_year lblempstat_2
		la var empstat_2_year "Employment status - Second Job"
	*</_empstat_2_year_>


	** ORIGINAL INDUSTRY CLASSIFICATION
	*<_industry_orig_2_>
		gen industry_orig_2=s4aq01c_2
		#delimit
		la def lblindustry_orig2
			1	"Agriculture, hunting and relating activities"
			2	"Forestry and forest-related activities"
			5	"Fishing and fish-related activities"
			10	"Minerals (coal)"
			11	"Gas and oil exploration"
			14	"Other Mineral Exploration"
			15	"Food and water production"
			16	"Production of tobacco products"
			17	"Clothing Manufacturing"
			18	"Garment production, bleached and dyed"
			19	"production of leather and leather related Goods"
			20	"Manufacture of Wood and wood products, except furniture"
			21	"Manufacture of paper and paper products"
			22	"Publishing, Printing and Recording"
			23	"Petroleum refining"
			24	"Production of chemicals"
			25	"Rubber and plastic products"
			26	"Production of other non-metallic mineral products"
			27	"Metal Manufacturing"
			28	"Production of metal products, except machinery"
			29	"Other unclassified Electronics Manufacturing"
			30	"Production of Machinery used in office and accounting"
			31	"Production of electrical equipment"
			32	"Production of Radio, television and media equipment"
			33	"Watch, glasses and medical equipment manufacturing"
			34	"Car production"
			35	"Machinery used in the production of other vehicles"
			36	"Production of furniture and unclassified"
			37	"Re-Processing"
			40	"Gas, hot water and electricity supply"
			41	"Water collection, purification and supply"
			45	"Construction"
			50	"Car and motorcycle sales, maintenance, repair and fuel sales"
			51	"Other than the business of car and motorcycle"
			52	"Car and motorcycle business and personal home use goods other than retail"
			55	"Hotel and Restaurant"
			60	"Road vehicles"
			61	"Shipping Vehicle"
			62	"Aircraft"
			63	"Travel assistance (Transport and Travel Agencies)"
			64	"Post and Telecommunications"
			65	"Financial intermediation, except insurance and pension"
			66	"Insurance and pension"
			67	"Helping financial mediation"
			70	"Real State"
			71	"Personal and home used to hire equipment"
			72	"Computer and Computer related working"
			73	"Research and development"
			74	"Other business"
			75	"Public administration, defense and compulsory social security"
			80	"Education"
			81	"Health & Social Services"
			90	"Drainage and sewerage type of work"
			92	"Entertainment, cultural and sports-related work"
			99	"Foreign Agencies";

		destring industry_orig_2, replace;
		replace industry_orig_2=. if lstatus!=1;
		la val industry_orig_2 lblindustry_orig2;

		recode industry_orig_2 (0 3 4 6 7 8 9 12 13 39 42 43
		 44 46 47 49 53 54 56 57 58 59 76 77 78 79 82 83 84
		 85 86 87 91 94 96=.); //Incorrect codes are send to missing
		 
		#delimit cr
		la var industry_orig_2 "Original industry - Second Job"
	*</_industry_orig_2_>

	
	** INDUSTRY CLASSIFICATION - SECOND JOB
	*<_industry_2_>
		gen industry_2=industry_orig_2
		destring industry_2,replace
		recode industry_2 (0=.) (1/5=1) (10/14=2) (15/39=3) (40/43=4) (45/49=5) (50/59=6) (60/64=7) (65/74=8) (75=9) (76/99=10) (nonmis=.)
		replace industry_2=. if lstatus==2| lstatus==3
		replace industry_2=. if lstatus!=1
		#delimit
		la def lblindustry_2  1 "Agriculture" 
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
		la var industry_2 "1 digit industry classification - Second Job"
	*<_industry_2_>


	** OCCUPATION CLASSIFICATION - SECOND JOB
	*<_occup_2_>
		#delimit
		recode s4aq01b_2 (1 = 3) (2 = 2) (3 = 3) (4 = 2) (5 = 3) (6 = 2) (40 = 1) 
		(8 = 2) (9 = 2) (10 = 2) (12 = 2) (13 = 2) (14 = 3) (15 = 2) (16 = 2) 
		(17 = 2) (18 = 2) (19 = 2) (20 = 1) (21 = 1) (30 = 1) (31 = 4) (32 = 4) 
		(33 = 4) (34 = 8) (35 = 8) (50 = 1) (7 = 2) (42 = 3) (39 = 4) (43 = 3) 
		(44 = 3) (86 = 3) (37 = 4) (38 = 4) (36 = 5) (45 = 5) (51 = 5) (52 = 5) 
		(53 = 5) (54 = 5) (49 = 5) (70 = 6) (58 = 5) (59 = 5) (60 = 6) (61 = 6) 
		(63 = 6) (64 = 6) (71 = 7) (72 = 7) (75 = 7) (74 = 8) (76 = 7) (77 = 7) 
		(78 = 7) (79 = 7) (80 = 7) (81 = 7) (82 = 7) (83 = 7) (84 = 7) (85 = 7) 
		(87 = 7) (88 = 7) (89 = 7) (92 = 7) (90 = 8) (91 = 8) (55 = 9) (56 = 9) 
		(11 22 25 26 41 46 47 48 57 62 65 67 69 93 96 99 0 68 73 = .) (nonmis = .), 
		gen(occup_2);
		replace occup_2=. if lstatus!=1;
		la def lbloccup_2 1 "Senior officials" 
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
		la var occup_2 "1 digit occupational classification - Second Job"
	*</_occup_2_>


	** WAGES - SECOND JOB
	*<_wage_2_>
		gen double wage_2=.
		replace wage_2=s4bq07_2 if s4bq01_2==2
		replace wage_2=s4bq02c_2 if s4bq01_2==1
		replace wage_2=0 if empstat_2==2
		la var wage_2 "Last wage payment - Second Job"
	*</_wage_2_>


	** WAGES TIME UNIT - SECOND JOB
	*<_unitwage_2_>
		gen byte unitwage_2=.
		replace unitwage_2=1 if s4bq01_2==1 & wage_2!=.
		replace unitwage_2=5 if s4bq01_2==2 & wage_2!=.
		replace unitwage_2=0 if empstat_2==2
		#delimit
		la de lblunitwage_2   1 "Daily" 
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
		la val unitwage_2 lblunitwage_2
		la var unitwage_2 "Last wages time unit - Second Job"
	*</_unitwage_2_>


	** CONTRACT
	*<_contract_>
		gen byte contract=.
		la def lblcontract 0 "Without contract" 1 "With contract"
		la val contract lblcontract
		la var contract "Contract"
	*</_contract_>


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
	*</_socialsec_>


	** UNION MEMBERSHIP
	*<_union_>
		gen byte union=.
		la def lblunion 0 "No member" 1 "Member"
		la val union lblunion
		la var union "Union membership"
	*</_union_>

	#delimit

	foreach var in lstatus lstatus_year empstat empstat_year njobs_year ocusec 
	 nlfreason unempldur_l unempldur_u industry_orig industry occup_orig occup 
	 firmsize_l firmsize_u whours wage unitwage empstat_2 empstat_2_year industry_2 
	 industry_orig_2 occup_2 wage_2 unitwage_2 contract healthins socialsec union {;
	 
		replace `var'=. if age<lb_mod_age;
		
	};

	#delimit cr

/*****************************************************************************************************
*                                                                                                    *
                                   MIGRATION MODULE
*                                                                                                    *
*****************************************************************************************************/


	** REGION OF BIRTH JURISDICTION
	*<_rbirth_juris_>
		gen byte rbirth_juris=.
		#delimit
		la def lblrbirth_juris  1 "subnatid1" 
								2 "subnatid2" 
								3 "subnatid3" 
								4 "Other country"  
								9 "Other code";
		#delimit cr
		la val rbirth_juris lblrbirth_juris
		la var rbirth_juris "Region of birth jurisdiction"
	*</_rbirth_juris_>


	** REGION OF BIRTH
	*<_rbirth_>
		gen byte rbirth=.
		la var rbirth "Region of Birth"
	*</_rbirth_>


	** REGION OF PREVIOUS RESIDENCE JURISDICTION
	*<_rprevious_juris_>
		gen byte rprevious_juris=.
		#delimit
		la def lblrprevious_juris   1 "reg01" 
									2 "reg02" 
									3 "reg03" 
									4 "Other country"  
									9 "Other code";
		#delimit cr
		la val rprevious_juris lblrprevious_juris
		la var rprevious_juris "Region of previous residence jurisdiction"
	*</_rprevious_juris_>


	** REGION OF PREVIOUS RESIDENCE
	*<_rprevious_>
		gen byte rprevious=.
		la var rprevious "Region of previous residence"
	*</_rprevious_>


	** YEAR OF MOST RECENT MOVE
	*<_yrmove_>
		gen int yrmove=.
		la var yrmove "Year of most recent move"
	*</_yrmove_>


/*******************************************************************************
*                                                                              *
                                  ASSETS 
*                                                                              *
*******************************************************************************/


	** RADIO
	*<_radio_>
		gen radio=assets571
		la def lblradio 0 "No" 1 "Yes"
		la val radio lblradio
		la var radio "Household has radio"
	*</_radio_>


	** TELEVISION
	*<_television_>
		gen television= assets582
		la def lbltelevision 0 "No" 1 "Yes"
		la val television lbltelevision
		la var television "Household has Television"
	*</_television>


	** FAN
	*<_fan_>
		gen fan=  assets579
		la def lblfan 0 "No" 1 "Yes"
		la val fan lblfan
		la var fan "Household has Fan"
	*</_fan>


	** SEWING MACHINE
	*<_sewingmachine_>
		gen sewingmachine= assets586
		la def lblsewingmachine 0 "No" 1 "Yes"
		la val sewingmachine lblsewingmachine
		la var sewingmachine "Household has Sewing machine"
	*</_sewingmachine>


	** WASHING MACHINE
	*<_washingmachine_>
		gen washingmachine= assets578
		la def lblwashingmachine 0 "No" 1 "Yes"
		la val washingmachine lblwashingmachine
		la var washingmachine "Household has Washing machine"
	*</_washingmachine>


	** REFRIGERATOR
	*<_refrigerator_>
		gen refrigerator= assets577
		la def lblrefrigerator 0 "No" 1 "Yes"
		la val refrigerator lblrefrigerator
		la var refrigerator "Household has Refrigerator"
	*</_refrigerator>


	** LAMP
	*<_lamp_>
		gen lamp= assets585
		la def lbllamp 0 "No" 1 "Yes"
		la val lamp lbllamp
		la var lamp "Household has Lamp"
	*</_lamp>


	** BICYCLE
	*<_bicycle_>
		gen bicycle= assets574
		la def lblbycicle 0 "No" 1 "Yes"
		la val bicycle lblbycicle
		la var bicycle "Household has Bicycle"
	*</_bicycle>


	** MOTORCYCLE
	*<_motorcycle_>
		gen motorcycle= assets575
		la def lblmotorcycle 0 "No" 1 "Yes"
		la val motorcycle lblmotorcycle
		la var motorcycle "Household has Motorcycle"
	*</_motorcycle>


	** MOTOR CAR
	*<_motorcar_>
		gen motorcar= assets576
		la def lblmotorcar 0 "No" 1 "Yes"
		la val motorcar lblmotorcar
		la var motorcar "Household has Motor car"
	*</_motorcar>


	** COW
	*<_cow_>
		gen cow=s7c1q02a_201
		la def lblcow 0 "No" 1 "Yes"
		la val cow lblcow
		la var cow "Household has Cow"
	*</_cow>


	** BUFFALO
	*<_buffalo_>
		gen buffalo= s7c1q02a_204
		la def lblbuffalo 0 "No" 1 "Yes"
		la val buffalo lblbuffalo
		la var buffalo "Household has Buffalo"
	*</_buffalo>


	** CHICKEN
	*<_chicken_>
		gen chicken= s7c1q02a_205
		la def lblchicken 0 "No" 1 "Yes"
		la val chicken lblchicken
		la var chicken "Household has Chicken"
	*</_chicken>

/*******************************************************************************
*                                                                              *
                                 WELFARE MODULE
*                                                                              *
*******************************************************************************/

	** SPATIAL DEFLATOR
	*<_spdef_>
		gen spdef=. 
		la var spdef "Spatial deflator"
	*</_spdef_>


	** WELFARE
	*<_welfare_>
		gen welfare=pcexp
		la var welfare "Welfare aggregate"
	*</_welfare_>


	** WELFARE IN NOMINAL TERMS
	*<_welfarenom_>
		gen welfarenom=pcexp
		la var welfarenom "Welfare aggregate in nominal terms"
	*</_welfarenom_>


	** WELFARE SPATIALLY DEFLACTED
	*<_welfaredef_>
		gen welfaredef=rpcexp
		la var welfaredef "Welfare aggregate spatially deflated"
	*</_welfaredef_>


	** WELFARE FOR SHARED PROSPERITY
	*<_welfshprosperity_>
		gen welfshprosperity=pcexp
		la var welfshprosperity "Welfare aggregate for shared prosperity"
	*</_welfshprosperity_>


	** WELFARE MEASURE (TYPE)
	*<_welfaretype_>
		gen welfaretype="EXP"
		la var welfaretype "Type of welfare measure (income, consumption or expenditure) for welfare, welfarenom, welfaredef"
	*</_welfaretype_>


	** WELFARE IF DIFFERENT WELFARE TYPE IS USED FROM WELFARE
	*<_welfareother_>
		gen welfareother=.
		la var welfareother "Welfare Aggregate if different welfare type is used from welfare, welfarenom, welfaredef"
	*</_welfareother_>


	** WELFARE TYPOE FOR WELFAREOTHER
	*<_welfareothertype_>
		gen welfareothertype=" "
		la var welfareothertype "Type of welfare measure (income, consumption or expenditure) for welfareother"
	*</_welfareothertype_>


	** WELFARE FOR NATIONAL POVERTY
	*<_welfarenat_>
		gen welfarenat=welfare
		la var welfarenat "Welfare aggregate for national poverty"
	*</_welfarenat_>	


	*QUINTILE AND DECILE OF CONSUMPTION AGGREGATE
		levelsof year, loc(y)
		merge m:1 idh using "${shares}\BGD_fnf_`y'", keepusing (quintile_cons_aggregate decile_cons_aggregate) nogen
		note _dta: "BGD 2016" Food/non-food shares are not included because there is not enough information to replicate their composition. 


/*******************************************************************************
*                                                                              *
                               NATIONAL POVERTY
*                                                                              *
*******************************************************************************/


	** POVERTY LINE (NATIONAL)
	*<_pline_nat_>
		drop pline_nat
		gen pline_nat=zu16
		la var pline_nat "Poverty Line (National)"
	*</_pline_nat_>


	** HEADCOUNT RATIO (NATIONAL)
	*<_poor_nat_>
		gen poor_nat=welfarenat<pline_nat if welfare!=.
		la def poor_nat 0 "Not-Poor" 1 "Poor"
		la val poor_nat poor_nat
		la var poor_nat "People below Poverty Line (National)"
	*</_poor_nat_>

/*****************************************************************************************************
*                                                                                                    *
                                   INTERNATIONAL POVERTY
*                                                                                                    *
*****************************************************************************************************/


	glo year=2011
	
	** USE SARMD CPI AND PPP
	*<_cpi_>
		capture drop _merge
		gen urb=.
		merge m:1 countrycode year urb using "$pricedata", nogen ///
		keepusing(countrycode year urb syear cpi${year}_w ppp${year}) keep(3)
		drop urb
	*</_cpi_>	
	
	
	** CPI VARIABLE
		ren cpi${year}_w cpi
		la var cpi "CPI (Base ${year}=1)"
	*</_cpi_>
		
		
	** PPP VARIABLE
	*<_ppp_>
		ren ppp${year}	ppp
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
		gen poor_int=welfare<pline_int if welfare!=.
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
	do "${fixlabels}\fixlabels", nostop

	keep countrycode year survey int_year int_month idh idp wgt pop_wgt strata psu vermast veralt ///
	urban subnatid1	subnatid2 subnatid3 subnatid4 subnatlev ownhouse tenure landholding water_original ///
	water_jmp water_source improved_water piped_water pipedwater_acc watertype_quest ///
	sanitation_original sewage_toilet toilet_jmp sanitation_source toilet_acc ///
	improved_sanitation electricity landphone cellphone computer internet hsize ///
	relationharm relationcs male age soc marital eye_dsablty hear_dsablty walk_dsablty conc_dsord slfcre_dsablty comm_dsablty ///
	ed_mod_age atschool literacy ///
	educy educat7 educat4 educat5 everattend lb_mod_age lstatus lstatus_year ///
	empstat empstat_year njobs njobs_year ocusec nlfreason unempldur_l unempldur_u ///
	industry_orig industry occup_orig occup firmsize_l firmsize_u whours wage ///
	unitwage empstat_2 empstat_2_year industry_orig_2 industry_2 occup_2 wage_2 ///
	unitwage_2 contract healthins socialsec union rbirth_juris rbirth rprevious_juris ///
	rprevious yrmove radio television fan sewingmachine washingmachine refrigerator ///
	lamp bicycle motorcycle motorcar cow buffalo chicken spdef welfare welfarenom ///
	welfaredef welfshprosperity welfaretype welfareother welfareothertype welfarenat ///
    quintile_cons_aggregate decile_cons_aggregate pline_nat poor_nat cpi ppp cpiperiod ///
	pline_int poor_int
	
** ORDER VARIABLES

	order countrycode year survey int_year int_month idh idp wgt pop_wgt strata psu vermast veralt ///
	urban subnatid1	subnatid2 subnatid3 subnatid4 subnatlev ownhouse tenure landholding water_original ///
	water_jmp water_source improved_water piped_water pipedwater_acc watertype_quest ///
	sanitation_original sewage_toilet toilet_jmp sanitation_source toilet_acc ///
	improved_sanitation electricity landphone cellphone computer internet hsize ///
	relationharm relationcs male age soc marital eye_dsablty hear_dsablty walk_dsablty conc_dsord slfcre_dsablty comm_dsablty ///
	ed_mod_age atschool literacy ///
	educy educat7 educat4 educat5 everattend lb_mod_age lstatus lstatus_year ///
	empstat empstat_year njobs njobs_year ocusec nlfreason unempldur_l unempldur_u ///
	industry_orig industry occup_orig occup firmsize_l firmsize_u whours wage ///
	unitwage empstat_2 empstat_2_year industry_orig_2 industry_2 occup_2 wage_2 ///
	unitwage_2 contract healthins socialsec union rbirth_juris rbirth rprevious_juris ///
	rprevious yrmove radio television fan sewingmachine washingmachine refrigerator ///
	lamp bicycle motorcycle motorcar cow buffalo chicken spdef welfare welfarenom ///
	welfaredef welfshprosperity welfaretype welfareother welfareothertype welfarenat ///
    quintile_cons_aggregate decile_cons_aggregate pline_nat poor_nat cpi ppp cpiperiod ///
	pline_int poor_int
	
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
	

	keep countrycode year idh idp wgt strata psu vermast veralt ${keep} 
	compress

	saveold "${output}\Data\Harmonized\BGD_2016_HIES_v01_M_v03_A_SARMD_IND.dta", replace version(12)
	saveold "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\__REGIONAL\Individual Files\BGD_2016_HIES_v01_M_v03_A_SARMD_IND.dta", replace version(12)

	log close




******************************  END OF DO-FILE  *****************************************************/


