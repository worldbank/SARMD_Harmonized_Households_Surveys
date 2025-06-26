/*------------------------------------------------------------------------------
  SARMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   	BGD_2016_HIES_v01_M_v08_A_SAMRD_IND.do	   </_Program name_>
<_Application_>    	STATA 17.0									 <_Application_>
<_Author(s)_>      	Leo Tornarolli <tornarolli@gmail.com>		  </_Author(s)_>
<_Date created_>   	10-2023								       </_Date created_>
<_Date modified>   	September 2024						      </_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        	BGD											    </_Country_>
<_Survey Title_>   	HIES								       </_Survey Title_>
<_Survey Year_>    	2016										</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:				092024
File:				BGD_2016_HIES_v01_M_v08_A_SAMRD_IND.do
First version
</_Version Control_>
------------------------------------------------------------------------------*/

*<_Program setup_>
clear all
set more off

local code         		"BGD"
local year         		"2016"
local survey       		"HIES"
local vm           		"01"
local va          		"08"
local type         		"SARMD"
global module       	"IND"
local yearfolder    	"`code'_`year'_`survey'"
local SARMDfolder    	"`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'"
local filename      	"`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'_${module}"
global output       	"${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'\\Data\Harmonized" 
global shares    		"$rootdofiles\_aux\"
global pricedata 		"$rootdofiles\_aux\cpi_ppp_sarmd_weighted.dta"
*</_Program setup_>


*<_Datalibweb request_>
use   "${rootdatalib}\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M\Data\Stata\\`yearfolder'_v`vm'_M.dta", clear
sort  hhid idp1
merge 1:1 hhid idp1 using "${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'\Data\Harmonized\\`yearfolder'_v`vm'_M_v`va'_A_`type'_INC.dta"
*</_Datalibweb request_>
	
	
*<_countrycode_> 
*<_countrycode_note_> Country code according to ISO-3166 Alpha-3 *</_countrycode_note_>
*gen countrycode = "`code'" 
*</_countrycode_>

*<_code_> 
gen code = "`code'"  
*</_code_>

*<_year_>
*<_year_note_> 4-digit year of survey based on IHSN standards *</_year_note_>
*gen year = `year' 
*</_year_>

*<_survey_>
*<_survey_note_> Survey acronym *</_survey_note_>
gen str survey = "`survey'"
label var survey "Household Income and Expenditure Survey"
*</_survey_>

*<_veralt_>
*<_veralt_note_> Harmonization version *</_veralt_note_>
gen veralt = "`va'"
*</_veralt_>

*<_vermast_>
*<_vermast_note_> Master version *</_vermast_note_>
gen vermast = "`vm'"
*</_vermast_>

*<_int_year_>
*<_int_year_note_> Interview Year *</_int_year_note_>
gen int_year = "`year'"
*</_int_year_>

*<_int_month_>
*<_int_month_note_> Interview Month *</_int_month_note_>
*<_int_month_note_> 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December" *</_int_month_note_>
gen byte int_month = .
label define int_month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
label values int_month int_month
clonevar month = int_month 
*</_int_month_>
	
*<_idh_>
*<_idh_note_> Household identifier  *</_idh_note_>
notes idh: household identifier in raw data is variable hhid
*</_idh_>

*<_idh_orig_>
*<_idh_orig_note_> Household identifier variables in the raw data is HHID *</_idh_org_note_>
gen idh_orig = "hhid"
clonevar idh_org = idh_orig
*</_idh_orig_>

*<_idp_>
*<_idp_note_> Personal identifier  *</_idp_note_>
notes idp: individual identifier (within household) in raw data is variable idp1
capture clonevar pid = idp
notes pid: individual identifier (within household) in raw data is variable idp1
*</_idp_>

*<_idp_orig_>
*<_idp_orig_note_> Personal identifier variables in the raw data depends on the module *</_idp_org_note_>
gen idp_orig = "hhid idp1"
clonevar idp_org = idp_orig
*</_idp_orig_

*<_wgt_>
*<_wgt_note_> Household weight  *</_wgt_note_>
/*<_wgt_note_> Survey specific information *</_wgt_note_>*/
capture clonevar wgt = hhwgt 
capture clonevar weight = hhwgt 
capture clonevar finalweight = hhwgt 
*</_wgt_>

*<_psu_>
*<_psu_note_> Primary sampling units *</_psu_note_>
cap gen psu = psu
*</_psu_>

*<_strata_>
*<_strata_note_> Strata *</_strata_note_>
/*<_strata_note_> Survey specific information *</_strata_note_>*/
*<_strata_note_>  *</_strata_note_>
egen strata = concat(year stratum) 
destring strata, replace
note strata: Stratum in HIES 2016 is different to previous years and has 132 strata. 	///
To compute means with standard errors and confidence intervals for all the 			///
available years we create a harmonized stratum variable. Since stratum in 				///
2016 has 2 equal numbers (11,12) to stratum16 (2000, 2005, and 2010) we 			///
create a variable with 2016 before the stratum variable 2016. 
*</_strata_>

*<_weighttype_>
*<_weighttype_note_> Weight type (frequency, probability, analytical, importance) *</_weighttype_note_>
*<_weighttype_note_> weighttype brought in from rawdata *</_weighttype_note_>
*gen weighttype = "PW"
*</_weighttype_>
	

****************************************************************
**** GEOGRAPHICAL VARIABLES
****************************************************************

*<_subnatid1_>
*<_subnatid1_note_> Subnational ID - highest level *</_subnatid1_note_>
/*<_subnatid1_note_> Subnational id - subnational regional identifiers at which survey is representative - highest level *</_subnatid1_note_>*/
*<_subnatid1_note_>  *</_subnatid1_note_>
gen 	subnatid1 = "."
replace subnatid1 = "10-Barisal"		if  division_code==10
replace subnatid1 = "20-Chittagong"		if  division_code==20
replace subnatid1 = "30-Dhaka"			if  division_code==30
replace subnatid1 = "40-Khulna"			if  division_code==40
replace subnatid1 = "45-Mymensingh"		if  division_code==45
replace subnatid1 = "50-Rajshahi"		if  division_code==50
replace subnatid1 = "55-Rangpur"		if  division_code==55
replace subnatid1 = "60-Sylhet"			if  division_code==60
notes subnatid1: Division level
notes subnatid1: Mymensingh Division was created in 2015 from districts previously comprising the northern part of Dhaka Division.  
*</_subnatid1_>

*<_subnatid1_sar_>
*<_subnatid1_sar_note_> Subnational ID - highest level *</_subnatid1_sar_note_>
/*<_subnatid1_sar_note_> Subnational id - subnational regional identifiers at which survey is representative - highest level *</_subnatid1_sar_note_>*/
*<_subnatid1_sar_note_>  *</_subnatid1_sar_note_>
gen   subnatid1_sar = subnatid1
notes subnatid1_sar: Division level
notes subnatid1_sar: Representative
*</_subnatid1_sar_>

*<_gaul_adm1_code_>
*<_gaul_adm1_code_note_> Gaul Code *</_gaul_adm1_code_note_>
/*<_gaul_adm1_code_note_> . *</_gaul_adm1_code_note_>*/
*<_gaul_adm1_code_note_> gaul_adm1_code brought in from rawdata *</_gaul_adm1_code_note_>
gen 	gaul_adm1_code = .
replace gaul_adm1_code = 2125 			if  subnatid1=="10-Barisal"
replace gaul_adm1_code = 2126 			if  subnatid1=="20-Chittagong"
replace gaul_adm1_code = 2127 			if  subnatid1=="30-Dhaka" | subnatid1=="45-Mymensingh"
replace gaul_adm1_code = 2128 			if  subnatid1=="40-Khulna"
replace gaul_adm1_code = 2130 			if  subnatid1=="50-Rajshahi"
replace gaul_adm1_code = 2131 			if  subnatid1=="55-Rangpur"
replace gaul_adm1_code = 2129 			if  subnatid1=="60-Sylhet"
*<_gaul_adm1_code_>		

*<_subnatid2_>
*<_subnatid2_note_> Subnational ID - second highest level *</_subnatid2_note_>
/*<_subnatid2_note_> Subnational id - subnational regional identifiers at which survey is representative - second highest level *</_subnatid2_note_>*/
*<_subnatid2_note_>  *</_subnatid2_note_>
gen 	subnatid2 = "."
replace subnatid2 = "1-Bagerhat"		if  zila_code==1
replace subnatid2 = "3-Bandarban"		if  zila_code==3
replace subnatid2 = "4-Barguna"			if  zila_code==4
replace subnatid2 = "6-Barisal"			if  zila_code==6
replace subnatid2 = "9-Bhola"			if  zila_code==9
replace subnatid2 = "10-Bogra"			if  zila_code==10
replace subnatid2 = "12-Brahmanbaria"	if  zila_code==12
replace subnatid2 = "13-Chandpur"		if  zila_code==13
replace subnatid2 = "15-Chittagong"		if  zila_code==15
replace subnatid2 = "18-Chuadanga"		if  zila_code==18
replace subnatid2 = "19-Comilla"		if  zila_code==19
replace subnatid2 = "22-Cox's bazar"	if  zila_code==22
replace subnatid2 = "26-Dhaka"			if  zila_code==26
replace subnatid2 = "27-Dinajpur"		if  zila_code==27
replace subnatid2 = "29-Faridpur"		if  zila_code==29
replace subnatid2 = "30-Feni"			if  zila_code==30
replace subnatid2 = "32-Gaibandha"		if  zila_code==32
replace subnatid2 = "33-Gazipur"		if  zila_code==33
replace subnatid2 = "35-Gopalganj"		if  zila_code==35
replace subnatid2 = "36-Habiganj"		if  zila_code==36
replace subnatid2 = "39-Jamalpur"		if  zila_code==39
replace subnatid2 = "41-Jessore"		if  zila_code==41
replace subnatid2 = "42-Jhalokati"		if  zila_code==42
replace subnatid2 = "44-Jhenaidah"		if  zila_code==44
replace subnatid2 = "38-Jaipurhat"		if  zila_code==38
replace subnatid2 = "46-Khagrachari"	if  zila_code==46
replace subnatid2 = "47-Khulna"			if  zila_code==47
replace subnatid2 = "48-Kishoreganj"	if  zila_code==48
replace subnatid2 = "49-Kurigram"		if  zila_code==49
replace subnatid2 = "50-Kushtia"		if  zila_code==50
replace subnatid2 = "51-Lakshmipur"		if  zila_code==51
replace subnatid2 = "52-Lalmonirhat"	if  zila_code==52
replace subnatid2 = "54-Madaripur"		if  zila_code==54
replace subnatid2 = "55-Magura"			if  zila_code==55
replace subnatid2 = "56-Manikganj"		if  zila_code==56
replace subnatid2 = "58-Maulvibazar"	if  zila_code==58
replace subnatid2 = "57-Meherpur"		if  zila_code==57
replace subnatid2 = "59-Munshigan"		if  zila_code==59
replace subnatid2 = "61-Mymensingh"		if  zila_code==61
replace subnatid2 = "64-Naogaon"		if  zila_code==64
replace subnatid2 = "65-Narail"			if  zila_code==65
replace subnatid2 = "67-Narayanganj"	if  zila_code==67
replace subnatid2 = "68-Narsingdi"		if  zila_code==68
replace subnatid2 = "69-Natore"			if  zila_code==69
replace subnatid2 = "70-Nawabganj"		if  zila_code==70
replace subnatid2 = "72-Netrokona"		if  zila_code==72
replace subnatid2 = "73-Nilphamari"		if  zila_code==73
replace subnatid2 = "75-Noakhali"		if  zila_code==75
replace subnatid2 = "76-Pabna"			if  zila_code==76
replace subnatid2 = "77-Panchagar"		if  zila_code==77
replace subnatid2 = "78-Patuakhali"		if  zila_code==78
replace subnatid2 = "79-Pirojpur"		if  zila_code==79
replace subnatid2 = "82-Rajbari"		if  zila_code==82
replace subnatid2 = "81-Rajshahi"		if  zila_code==81
replace subnatid2 = "84-Rangamati"		if  zila_code==84
replace subnatid2 = "85-Rangpur"		if  zila_code==85
replace subnatid2 = "87-Satkhira"		if  zila_code==87
replace subnatid2 = "86-Shariatpur"		if  zila_code==86
replace subnatid2 = "89-Sherpur"		if  zila_code==89
replace subnatid2 = "88-Sirajganj"		if  zila_code==88
replace subnatid2 = "90-Sunamganj"		if  zila_code==90
replace subnatid2 = "91-Sylhet"			if  zila_code==91
replace subnatid2 = "93-Tangail"		if  zila_code==93
replace subnatid2 = "94-Thakurgaon"		if  zila_code==94
notes subnatid2: Zila level
notes subnatid2: Representative
*</_subnatid2_>

*<_subnatid2_sar_>
*<_subnatid2_sar_note_> Subnational ID - highest level *</_subnatid2_sar_note_>
/*<_subnatid2_sar_note_> Subnational id - subnational regional identifiers at which survey is representative - highest level *</_subnatid2_sar_note_>*/
*<_subnatid2_sar_note_>  *</_subnatid2_sar_note_>
gen   subnatid2_sar = subnatid2
notes subnatid2_sar: Zila level
notes subnatid2_sar: Representative
*</_subnatid1_sar_>

*<_gaul_adm2_code_>
gen 	gaul_adm2_code = .
replace gaul_adm2_code = 29566 	if  subnatid2=="1-Bagerhat"
replace gaul_adm2_code = 29538 	if  subnatid2=="3-Bandarban"
replace gaul_adm2_code = 29532 	if  subnatid2=="4-Barguna"
replace gaul_adm2_code = 29533 	if  subnatid2=="6-Barisal"
replace gaul_adm2_code = 29534 	if  subnatid2=="9-Bhola"
replace gaul_adm2_code = 29580 	if  subnatid2=="10-Bogra"
replace gaul_adm2_code = 29539 	if  subnatid2=="12-Brahmanbaria"
replace gaul_adm2_code = 29540 	if  subnatid2=="13-Chandpur"
replace gaul_adm2_code = 29541 	if  subnatid2=="15-Chittagong"
replace gaul_adm2_code = 29567 	if  subnatid2=="18-Chuadanga"
replace gaul_adm2_code = 29542 	if  subnatid2=="19-Comilla"
replace gaul_adm2_code = 29543 	if  subnatid2=="22-Cox's bazar"
replace gaul_adm2_code = 29549 	if  subnatid2=="26-Dhaka"
replace gaul_adm2_code = 29588 	if  subnatid2=="27-Dinajpur"
replace gaul_adm2_code = 29550 	if  subnatid2=="29-Faridpur"
replace gaul_adm2_code = 29544 	if  subnatid2=="30-Feni"
replace gaul_adm2_code = 29589 	if  subnatid2=="32-Gaibandha"
replace gaul_adm2_code = 29551 	if  subnatid2=="33-Gazipur"
replace gaul_adm2_code = 29552 	if  subnatid2=="35-Gopalganj"
replace gaul_adm2_code = 29576 	if  subnatid2=="36-Habiganj"
replace gaul_adm2_code = 29553 	if  subnatid2=="39-Jamalpur"
replace gaul_adm2_code = 29568 	if  subnatid2=="41-Jessore"
replace gaul_adm2_code = 29535 	if  subnatid2=="42-Jhalokati"
replace gaul_adm2_code = 29569 	if  subnatid2=="44-Jhenaidah"
replace gaul_adm2_code = 29581 	if  subnatid2=="38-Jaipurhat"
replace gaul_adm2_code = 29545 	if  subnatid2=="46-Khagrachari"
replace gaul_adm2_code = 29570 	if  subnatid2=="47-Khulna"
replace gaul_adm2_code = 29554 	if  subnatid2=="48-Kishoreganj"
replace gaul_adm2_code = 29590 	if  subnatid2=="49-Kurigram"
replace gaul_adm2_code = 29571 	if  subnatid2=="50-Kushtia"
replace gaul_adm2_code = 29546 	if  subnatid2=="51-Lakshmipur"
replace gaul_adm2_code = 29591 	if  subnatid2=="52-Lalmonirhat"
replace gaul_adm2_code = 29555 	if  subnatid2=="54-Madaripur"
replace gaul_adm2_code = 29572 	if  subnatid2=="55-Magura"
replace gaul_adm2_code = 29556 	if  subnatid2=="56-Manikganj"
replace gaul_adm2_code = 29577 	if  subnatid2=="58-Maulvibazar"
replace gaul_adm2_code = 29573 	if  subnatid2=="57-Meherpur"
replace gaul_adm2_code = 29557 	if  subnatid2=="59-Munshigan"
replace gaul_adm2_code = 29558 	if  subnatid2=="61-Mymensingh"
replace gaul_adm2_code = 29582 	if  subnatid2=="64-Naogaon"
replace gaul_adm2_code = 29574 	if  subnatid2=="65-Narail"
replace gaul_adm2_code = 29559 	if  subnatid2=="67-Narayanganj"
replace gaul_adm2_code = 29560 	if  subnatid2=="68-Narsingdi"
replace gaul_adm2_code = 29583 	if  subnatid2=="69-Natore"
replace gaul_adm2_code = 29584 	if  subnatid2=="70-Nawabganj"
replace gaul_adm2_code = 29561 	if  subnatid2=="72-Netrokona"
replace gaul_adm2_code = 29592 	if  subnatid2=="73-Nilphamari"
replace gaul_adm2_code = 29547 	if  subnatid2=="75-Noakhali"
replace gaul_adm2_code = 29585 	if  subnatid2=="76-Pabna"
replace gaul_adm2_code = 29593 	if  subnatid2=="77-Panchagar"
replace gaul_adm2_code = 29536 	if  subnatid2=="78-Patuakhali"
replace gaul_adm2_code = 29537 	if  subnatid2=="79-Pirojpur"
replace gaul_adm2_code = 29562 	if  subnatid2=="82-Rajbari"
replace gaul_adm2_code = 29586 	if  subnatid2=="81-Rajshahi"
replace gaul_adm2_code = 29548 	if  subnatid2=="84-Rangamati"
replace gaul_adm2_code = 29594 	if  subnatid2=="85-Rangpur"
replace gaul_adm2_code = 29575 	if  subnatid2=="87-Satkhira"
replace gaul_adm2_code = 29563 	if  subnatid2=="86-Shariatpur"
replace gaul_adm2_code = 29564 	if  subnatid2=="89-Sherpur"
replace gaul_adm2_code = 29587 	if  subnatid2=="88-Sirajganj"
replace gaul_adm2_code = 29578 	if  subnatid2=="90-Sunamganj"
replace gaul_adm2_code = 29579 	if  subnatid2=="91-Sylhet"
replace gaul_adm2_code = 29565 	if  subnatid2=="93-Tangail"
replace gaul_adm2_code = 29595 	if  subnatid2=="94-Thakurgaon"
*<_gaul_adm2_code_>

*<_subnatid3_>
*<_subnatid3_note_>  Subnational ID - third highest level *</_subnatid3_note_>
/*<_subnatid3_note_> Subnational id - subnational regional identifiers at which survey is representative - third highest level *</_subnatid3_note_>*/
*<_subnatid3_note_>  *</_subnatid3_note_>
gen   subnatid3 = ""
notes subnatid3: the survey does not have a smaller level of representativeness than zila (subnatid2_sar)
*</_subnatid3_>

*<_subnatid3_sar_>
*<_subnatid3_sar_note_>  Subnational ID - third highest level *</_subnatid3_sar_note_>
/*<_subnatid3_sar_note_> Subnational id - subnational regional identifiers at which survey is representative - third highest level *</_subnatid3_sar_note_>*/
*<_subnatid3_sar_note_>  *</_subnatid3_sar_note_>
replace id_03_name = proper(id_03_name)
gen upazila_code = (100*zila_code+id_03_code)
egen  subnatid3_sar = concat(upazila_code id_03_name), punct(-)
notes subnatid3_sar: Thana/Upazila level
notes subnatid3_sar: Non-Representative
*</_subnatid3_sar_>

*<_subnatid4_>
*<_subnatid4_note_>  Subnational ID - third highest level *</_subnatid4_note_>
/*<_subnatid4_note_> Subnational id - subnational regional identifiers at which survey is representative - third highest level *</_subnatid4_note_>*/
*<_subnatid4_note_>  *</_subnatid4_note_>
gen	  subnatid4 = ""
notes subnatid4: the survey does not have a smaller level of representativeness than zila (subnatid2_sar)
*</_subnatid4_>

*<_subnatid4_sar_>
*<_subnatid4_sar_note_>  Subnational ID - third highest level *</_subnatid4_sar_note_>
/*<_subnatid4_sar_note_> Subnational id - subnational regional identifiers at which survey is representative - third highest level *</_subnatid4_sar_note_>*/
*<_subnatid4_sar_note_>  *</_subnatid4_sar_note_>
replace id_04_name = proper(id_04_name)
gen ward_code = (100*upazila_code+id_04_code)

egen  subnatid4_sar = concat(ward_code id_04_name), punct(-)
notes subnatid4_sar: Unior/Ward level
notes subnatid4_sar: Non-Representative
*</_subnatid4_sar_>

*<_gaul_adm3_code_>
gen gaul_adm3_code = . 
*<_gaul_adm3_code_>	
	
*<_subnatlev_>
gen subnatlev = 2
*<_subnatlev_>

** PREVIOUS ** 
gen 	subnatid1_prev = ""
replace subnatid1_prev = "10-Barisal"    	if  subnatid1=="10-Barisal"
replace subnatid1_prev = "20-Chittagong" 	if  subnatid1=="20-Chittagong"
replace subnatid1_prev = "30-Dhaka"      	if  subnatid1=="30-Dhaka" | subnatid1 =="45-Mymensingh"
replace subnatid1_prev = "40-Khulna"     	if  subnatid1=="40-Khulna" 
replace subnatid1_prev = "50-Rajshahi"   	if  subnatid1=="50-Rajshahi"
replace subnatid1_prev = "55-Rangpur"    	if  subnatid1=="55-Rangpur"
replace subnatid1_prev = "60-Sylhet"     	if  subnatid1=="60-Sylhet"
gen subnatid2_prev = .
gen subnatid3_prev = .
gen subnatid4_prev = .

*<_urban_>
*<_urban_note_> uban/rural *</_urban_note_>
/*<_urban_note_> Urban or rural location of households *</_urban_note_>*/
*<_urban_note_> 0 "Rural"  1 "Urban"  *</_urban_note_>
gen 	urban = .
replace urban = 0	if  urbrural==1
replace urban = 1	if  urbrural==2
*</_urban_>


****************************************************************
**** DWELLING CHARACTERISTICS
****************************************************************
	
*<_ownhouse_>
*<_ownhouse_note_> SARMD ownhouse variable *</_ownhouse_note_>
/*<_ownhouse_note_> Refers to ownership status of the dwelling unit by the household residing in it. *</_ownhouse_note_>*/
*<_ownhouse_note_>  1 "Ownership/secure rights" 2 "Renting" 3 "Provided for free" 4 "Without permission" *</_ownhouse_note_>
gen byte ownhouse = .
replace ownhouse = 1 		if  s6aq23==1
replace ownhouse = 2 		if  s6aq23==2
replace ownhouse = 3 		if  s6aq23==3
note ownhouse: "BGD 2016" There is an extra categorie and it is classified as missing.
*</_ownhouse_>

*<_typehouse_>
*<_typehouse_note_> GMD ownhouse variable *</_typehouse_note_>
*<_typehouse_note_> typehouse brought in from GMD *</_typehouse_note_>
clonevar typehouse = ownhouse
*</_typehouse_>

*<_tenure_>
gen 	tenure = .
replace tenure = 1 			if  s6aq23==1
replace tenure = 2 			if  s6aq23==2 
replace tenure = 3 			if  s6aq23==3 
*</_tenure_>	

*<_landholding_>
gen landholding = (s7aq01>0 | s7aq02>0 | s7aq03>0) 		if !mi(s7aq01,s7aq02,s7aq03)
note landholding: "BGD 2016" dummy activated if hh owns at least more than 0 decimals of any type of land (aggricultural, dwelling, non-productive).
*</_landholding_>	

*<_water_orig_>
*<_water_orig_note_> Source of Drinking Water-Original from raw file *</_water_orig_note_>
/*<_water_orig_note_> Original categories from source of drinking water *</_water_orig_note_>*/
*<_water_orig_note_>  *</_water_orig_note_>
gen 	water_orig = "."
replace water_orig = "1 - Supply water"			if  s6aq12==1
replace water_orig = "2 - Tubewell"				if  s6aq12==2
replace water_orig = "3 - Pond/river"			if  s6aq12==3
replace water_orig = "4 - Well"					if  s6aq12==4
replace water_orig = "5 - Waterfall/string"		if  s6aq12==5
replace water_orig = "6 - Other"				if  s6aq12==6
*</_water_orig_>

*<_water_source_>
*<_water_source_note_> Sources of drinking water *</_water_source_note_>
/*<_water_source_note_> 1 "Piped water into dwelling" 2 "Piped water to yard/plot" 3 "Public tap or standpipe" 4 "Tube well or borehole" 5 "Protected dug well" 6 "Protected spring" 7 "Bottled water" 8 "Rainwater" 9 "Unprotected spring" 10 "Unprotected dug well" 11 "Cart with small tank/drum" 12 "Tanker-truck" 13 "Surface water" 14 "Other" *</_water_source_note_>*/
*<_water_source_note_> water_source brought in from rawdata *</_water_source_note_>
gen 	water_source = .
replace water_source = 1 		if  s6aq12==1
replace water_source = 4 		if  s6aq12==2
replace water_source = 13 		if  s6aq12==3
replace water_source = 4 		if  s6aq12==4
replace water_source = 14 		if  s6aq12==5
replace water_source = 14 		if  s6aq12==6
*</_water_source_>

*<_water_jmp_>
*<_water_jmp_note_> Source of drinking water, using Joint Monitoring Program categories *</_water_jmp_note_>
/*
/*<_water_jmp_note_> Variable taking categories based on JMP guidelines. This variable is created from question asking about main source of drinking water. Ambigous categories are classified as missing/other *</_water_jmp_note_>*/
*<_wate_jmp_note_> 1 "Piped into dwelling" 2 "Piped into compound, yard or plot" 3 "Public tap/standpipe" 4 "Tubewell, Borehole" 5 "Protected well" 6 "Unprotected well" 7 "Protected spring" 8 "Unprotected spring" 9 "Rain water" 10 "Tanker-truck or other vendor" 11 "Cart with small tank/drum" 12 "Surface water (river, stream, dam, lake, pond) 13 "Bottled water" 14 "Other" *</_wate_jmp_note_>
*/
gen 	water_jmp = .
replace water_jmp = 1 			if  s6aq12==1
replace water_jmp = 4 			if  s6aq12==2
replace water_jmp = 12 			if  s6aq12==3
replace water_jmp = 14 			if  s6aq12==4
replace water_jmp = 14 			if  s6aq12==5
replace water_jmp = 14 			if  s6aq12==6
note water_jmp: "BGD 2016" Categories "Well" and "Waterfall / Spring" are classified as other according to JMP definitions, 	///
given that this are ambigous categories. 
note water_jmp: "BGD 2016" note that "Piped into dwelling" category does not necessarily cover water supplied into dwelling. 	///
It may be tap water into compound or from public tap. See technical documentation from Water GP for further detail.
*</_water_jmp_>

*<_piped_water_>
*<_piped_water_note_> Household has access to piped water *</_piped_water_note_>
/*<_piped_water_note_> Variable takes the value of 1 if household has access to piped water. *</_piped_water_note_>*/
*<_piped_water_note_>  1 "Yes" 0 "No" *</_piped_water_note_>
gen piped_water = s6aq12==1 		if  s6aq12!=.
note piped_water: "BGD 2016" note that "Supply water" category does not necessarily cover water supplied into dwelling. ///
It may be tap water into compound or from public tap. See technical documentation from Water GP for further detail.
*</_piped_water_>

*<_pipedwater_acc_>
*<_pipedwater_acc_note_> Access to piped water *</_pipedwater_acc_note_>
/*<_pipedwater_acc_note_>  *</_pipedwater_acc_note_>*/
*<_pipedwater_acc_note_> piped  brought in from rawdata *</_pipedwater_acc_note_>
gen 	pipedwater_acc = 0 	if  inlist(s6aq12,2,3,4,5,6) // Asuming other is not piped water
replace pipedwater_acc = 3 	if  inlist(s6aq12,1)
*</_pipedwater_acc_>
	
*<_sar_improved_water_>
*<_sar_improved_water_note_> Improved source of drinking water-using country-specific definitions *</_sar_improved_water_note_>
/*<_sar_improved_water_note_> Dummy variable: 1=improved, 0=unimproved source following JMP guidelines *</_sar_improved_water_note_>*/
*<_sar_improved_water_note_>  1 "Yes" 0 "No" *</_sar_improved_water_note_>
gen     sar_improved_water = .
replace sar_improved_water = 1 if (water_source>=1 & water_source<=8) | (water_source>=11 & water_source<=12)
replace sar_improved_water = 0 if (water_source>=9 & water_source<=10) | (water_source>=13 & water_source<=14)
*</_sar_improved_water_>

*<_improved_water_>
*<_improved_water_note_> Improved source of drinking water-using country-specific definitions *</_improved_water_note_>
/*<_improved_water_note_> Dummy variable: 1=improved, 0=unimproved source following JMP guidelines *</_improved_water_note_>*/
*<_improved_water_note_>  1 "Yes" 0 "No" *</_improved_water_note_>
gen improved_water = sar_improved_water
*</_improved_water_>

*<_watertype_quest_>
gen watertype_quest = 1
*</_watertype_quest_>

*<_toilet_orig_>
*<_toilet_orig_note_> sanitation facility original *</_toilet_orig_note_>
/*<_toilet_orig_note_> Original categories from access to toilet *</_toilet_orig_note_>*/
*<_toilet_orig_note_>  *</_toilet_orig_note_>
gen     toilet_orig = "."
replace toilet_orig = "1 - Sanitary"						if  s6aq10==1
replace toilet_orig = "2 - Pacca latrine (Water seal)"		if  s6aq10==2
replace toilet_orig = "3 - Pacca latrine (Pit)"				if  s6aq10==3
replace toilet_orig = "4 - Kacha latrine (Perm)"			if  s6aq10==4
replace toilet_orig = "5 - Kacha latrine (temp)"			if  s6aq10==5
replace toilet_orig = "6 - Open space/No latrine"			if  s6aq10==6
*</_toilet_original_>

*<_sanitation_source_>
*<_sanitation_source_note_> Sources of sanitation facilities *</_sanitation_source_note_>
/*<_sanitation_source_note_> 1 "A flush toilet" 2 "A piped sewer system" 3 "A septic tank" 4 "Pit latrine" 5 "Ventilated improved pit latrine (VIP)" 6 "Pit latrine with slab" 7 "Composting toilet" 8 "Special case" 9 "A flush/pour flush to elsewhere" 10 "A pit latrine without slab" 11 "Bucket" 12 "Hanging toilet or hanging latrine" 13 "No facilities or bush or field" 14 "Other" *</_sanitation_source_note_>*/
*<_sanitation_source_note_> sanitation_source brought in from rawdata *</_sanitation_source_note_>
gen sanitation_source = .
*</_sanitation_source_>

*<_sewage_toilet_>
*<_sewage_toilet_note_> Household has access to sewage toilet *</_sewage_toilet_note_>
/*<_sewage_toilet_note_> Variable takes the value of 1 if household has access to sewage toilet. *</_sewage_toilet_note_>*/
*<_sewage_toilet_note_>  1 "Yes" 0 "No" *</_sewage_toilet_note_>
gen    sewage_toilet = s6aq10
recode sewage_toilet (2/6 = 0)
*</_sewage_toilet_>

*<_toilet_jmp_>
*<_toilet_jmp_note_> Access to sanitation facility-using Joint Monitoring Program categories *</_toilet_jmp_note_>
/*<_toilet_jmp_note_> Variable taking categories based on JMP guidelines. This variable is created from question asking about toilet type. Ambigous categories are classified as missing/other *</_toilet_jmp_note_>*/
*<_toilet_jmp_note_> 1 "Flush to piped sewer system" 2 "Flush to septic tank" 3 "Flush to pit latrine" 4 "Flush to somewhere else" 5 "Flush, don't know where" 6 "Ventilated improved pit latrine" 7 "Pit latrine with slab" 8 "Pit latrine without slab/open pit" 9 "Composting toilet" 10 "Bucket toilet" 11 "Hanging toilet/Hanging latrine" 12 "No facility/bush/field" 13 "Other" *</_toilet_jmp_note_>
gen 	toilet_jmp = .
*</_toilet_jmp_>

*<_sar_improved_toilet_>
*<_sar_improved_toilet_note_> Improved type of sanitation facility-using country-specific definitions *</_sar_improved_toilet_note_>
/*<_sar_improved_toilet_note_> Dummy variable: 1=improved, 0=unimproved source following JMP guidelines *</_sar_improved_toilet_note_>*/
*<_sar_improved_toilet_note_>  1 "Yes" 0 "No" *</_sar_improved_toilet_note_>
gen 	sar_improved_toilet = .
replace sar_improved_toilet = 1 	if  inlist(s6aq10,1,2,3)
replace sar_improved_toilet = 0 	if  inlist(s6aq10,4,5,6)
/* WASH team: Replace shared facilities as unimproved */
replace sar_improved_toilet = 0 	if  s6aq11==1
*</_sar_improved_toilet_>

*<_improved_sanitation_>
*<_improved_sanitation_note_> Improved type of sanitation facility-using country-specific definitions *</_improved_sanitation_note_>
/*<_improved_sanitation_note_> Dummy variable: 1=improved, 0=unimproved source following JMP guidelines *</_improved_sanitation_note_>*/
*<_improved_sanitation_note_>  1 "Yes" 0 "No" *</_improved_sanitation_note_>
clonevar improved_sanitation = sar_improved_toilet
*</_improved_sanitation_>

*<_toilet_acc_>
gen 	toilet_acc = 3 				if  improved_sanitation==1
replace toilet_acc = 0 				if  improved_sanitation==0 
*</_toilet_acc_>

*<_shared_toilet_>
gen 	shared_toilet = 0	 			if  s6aq11==2
replace shared_toilet = 1				if  s6aq11==1
replace shared_toilet = .				if  s6aq10==6		/* open space or no latrine */ 
*</_shared_toilet_>

*<_electricity_>
*<_electricity_note_> Access to electricity *</_electricity_note_>
/*<_electricity_note_> Refers to Public or quasi public service availability of electricity from mains. 
Note that having an electrical connection says nothing about the actual electrical service received by the household in a given country or area.
This variable must have the same value for all members of the household *</_electricity_note_>*/
*<_electricity_note_> 1 "Yes" 0 "No" *</_electricity_note_>
recode s6aq17 (2 = 0) (3 = .), gen (electricity)
*</_electricity_>

*<_lphone_>
*<_lphone_note_> Household has landphone *</_lphone_note_>
/*<_lphone_note_> Availability of landphones in household. Question on quantity or specific availability should be present *</_lphone_note_>*/
*<_lphone_note_>  1 "Yes" 0 "No" *</_lphone_note_>
recode   s6aq19 (2 = 0) (3 = .), gen(landphone)
clonevar lphone = landphone
*</_landphone_>

*<_cellphone_>
*<_cellphone_note_> Own mobile phone (at least one) *</_cellphone_note_>
/*<_cellphone_note_> Refers to cell phone availability in the household.
This variable is only constructed if there is an explicit question about cell phones availability.
This variable must have the same value for all members of the household. *</_cellphone_note_>*/
*<_cellphone_note_>  1 "Yes" 0 "No" *</_cellphone_note_>
recode s1aq10 (2 = 0), gen(cellphone) 
bysort hhid: egen cellphone_total = sum(cellphone)
replace cellphone = 1 	if  cellphone_total>1
*</_cellphone_>
	
*<_computer_>
*<_computer_note_> Own Computer *</_computer_note_>
/*<_computer_note_> Presence of a computer. Refers to actual ownership of the asset irrespective of who owns it within the household and regardless of what condition the asset is in. 
This variable is only constructed if there is an explicit question about computer *</_computer_note_>*/
*<_computer_note_>  1 "Yes" 0 "No" *</_computer_note_>
recode s6aq20 (2 = 0) (0 = .), gen(computer)
*</_computer_>

*<_internet_>
*<_internet_note_>  Internet connection *</_internet_note_>
/*<_internet_note_> Availability of internet connection. Refers to internet connection availability at home irrespective of who owns it within the household. 
This variable is only constructed if there is an explicit question about internet connection. 
This variab *</_internet_note_>*/
*<_internet_note_>  1 "Yes" 0 "No" *</_internet_note_>
recode s6aq21 (2 = 0) (0 = .), gen(internet)
*<_internet_>


****************************************************************
**** DEMOGRAPHIC CHARACTERISTICS
****************************************************************

*<_hsize_>
*<_hsize_note_> Household size *</_hsize_note_>
/*<_hsize_note_> specifies varname for the household size number in the data file. It has to be compatible with the numbers of national and international poverty at household size when weights are used in any computation *</_hsize_note_>*/
*<_hsize_note_>  *</_hsize_note_>
ren member hsize
*</_hsize_>

*<_pop_wgt_>
*<_pop_wgt_note_> Population weight *</_pop_wgt_note_>
/*<_pop_wgt_note_> Survey specific information *</_pop_wgt_note_>*/
*<_pop_wgt_note_>  *</_pop_wgt_note_>
gen pop_wgt = wgt*hsize
*</_pop_wgt_>

*<_relationcs_>
*<_relationcs_note_> Relationship to head of household country/region specific *</_relationcs_note_>
/*<_relationcs_note_> country or regionally specific categories *</_relationcs_note_>*/
*<_relationcs_note_>  1 "Head of the household" 2 "Wife/Husband" 3 "Son/Daughter" 4 "Parents of head of the household/spouse" 5 "Other Relative" 6 "Domestic Servant/Driver/Watcher" 7 "Boarder" 9 "Other" *</_relationcs_note_>
gen		relationcs = "."
replace relationcs = "1 - Head"										if  s1aq02==1 
replace relationcs = "2 - Wife/Husband"								if  s1aq02==2 
replace relationcs = "3 - Son/Daughter"								if  s1aq02==3 
replace relationcs = "4 - Parents of the head of household/spouse"	if  s1aq02==6 | s1aq02==9
replace relationcs = "5 - Other relative"							if  s1aq02==4 | s1aq02==5 | s1aq02==7 | s1aq02==8 | s1aq02==10 | s1aq02==11
replace relationcs = "6 - Domestic servant/Driver/Watcher"			if  s1aq02==12 | s1aq02==13
replace relationcs = "9 - Other"									if  s1aq02==14
*</_relationcs_>

*<_relationharm_>
* Members of household
bys hhid: egen member = count(idp1)

* Household heads
replace s1aq02 =. 			if  s1aq02==0
replace s1aq02 = 14 		if  s1aq02==. & hhid==387041 & idp1==2

gen head = (s1aq02==1) 		if  s1aq02!=.
bys hhid: egen heads = total(head) 
replace heads = . 			if  head==.

egen hh = tag(hhid)
tab heads 					if  hh==1

* Maximum age inside the household
bys hhid: egen maxage=max(s1aq03)
gen oldest = (s1aq03==maxage)

* Highest age of males in the household
bys hhid: egen maxageman=max(s1aq03) if s1aq01==1
gen oldestman = (s1aq03==maxageman)

* Household head is male married
gen menmarriedhh = (s1aq01==1 & s1aq02==1 & s1aq05==1) 
bys hhid: egen menmarriedhht = total(menmarriedhh)

* Male married
gen malemarried = (s1aq05==1 & s1aq01==1)
bys hhid: egen malemarriedt = total(malemarried) if s1aq01!=.

* Household head is female
gen femalehh=(s1aq01==2 & s1aq02==1)
bys hhid: egen femalehht=total(femalehh)

* Are there any households in our sample that have a male in the household that is older than the married male household head? 
gen aux=1 if oldestman==1 & head==0 & menmarriedhht==1 & femalehht==0
bys hhid: egen auxt=total(aux) 
tab auxt if hh==1
tab s1aq02 if inlist(auxt,1) & oldest==1

* Count number of males in the household
gen men= (s1aq01==1) if s1aq01!=.
bys hhid: egen ment=total(men) if s1aq01!=.

* Female is the oldest member in the household
gen oldestisfemale=(s1aq03==maxage & s1aq01==2)
bys hhid: egen oldestisfemalet=total(oldestisfemale)

* Males aged 16 years and above
gen young=(s1aq03>15 & s1aq01==1)
bys hhid: egen youngt=total(young)

* Create the new household head variable
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
*</_relationharm_>

*<_age_>
*<_age_note_> Age of individual (continuous) *</_age_note_>
/*<_age_note_> Age is an important variable for most socio-economic analysis and must be established as accurately as possible. Especially for children aged less than 5 years, this is used to interpret Anthropometrics data. Ages >= 98 must be coded as 98.  (N *</_age_note_>*/
*<_age_note_>  *</_age_note_>
gen byte age =  s1aq03
replace  age = 98 				if  age>98 & s1aq03!=.
*</_age_>

*<_male_>
*<_male_note_> Sex of household member (male=1) *</_male_note_>
/*<_male_note_> specifies varname for sex of household member (head), where 1 = Male and 0 = Female. *</_male_note_>*/
*<_male_note_>  1 " Male" 0 "Female" *</_male_note_>
gen byte male = s1aq01
recode male (2=0)
*</_male_>

*<_soc_>
*<_soc_note_> Social group *</_soc_note_>
/*<_soc_note_> Classification by religion.
The classification is country specific.
It not needs to be present for every country/year. *</_soc_note_>*/
*<_soc_note_>  1 "Islam" 2 "Hindu" 3 "Buddhist" 4 "Christian" *</_soc_note_>
gen 	soc = "."
replace soc = "1 - Islam"		if  s1aq04==1
replace soc = "2 - Hindu"		if  s1aq04==2
replace soc = "3 - Buddhist"	if  s1aq04==3
replace soc = "4 - Christian"	if  s1aq04==4
replace soc = "5 - Other"		if  s1aq04==5
*</_soc_>

*<_marital_>
*<_marital_note_> Marital status *</_marital_note_>
/*<_marital_note_> Do not impute.  Calculate only for those to whom the question was asked (in other words, the youngest age at which information is collected may differ depending on the survey). Living together includes common-law marriages, union coutumiere, uni *</_marital_note_>*/
*<_marital_note_>  1 "Married" 2 "Never married" 3 "Living together" 4 "Divorced/Separated" 5 "Widowed" *</_marital_note_>
gen		marital = .
replace marital = 1 				if  s1aq05==1
replace marital = 4 				if  s1aq05==5 | s1aq05==4
replace marital = 5 				if  s1aq05==3
replace marital = 2 				if  s1aq05==2
*</_marital_>
 
*<_rbirth_juris_>
*<_rbirth_juris_note_>  Region of Birth Jurisdiction *</_rbirth_juris_note_>
/*<_rbirth_juris_note_> Variable is constructed for all persons administered this module in each questionnaire.  It identifies the level at which region of birth is coded in the survey  *</_rbirth_juris_note_>*/
*<_rbirth_juris_note_>  *</_rbirth_juris_note_>
gen   rbirth_juris = .
notes rbirth_juris: HIES does not collect the information needed to define this variable
*</_rbirth_juris_>

*<_rbirth_>
*<_rbirth_note_>  Region of Birth *</_rbirth_note_>
/*<_rbirth_note_> Corresponds to reg01 if rbirth_juris=1, reg02 if rbirth_juris=2, reg03 if rbirth_juris=3, ISO 3166-1 if rbirth_juris=5, and original code if rbirth_juris=9 *</_rbirth_note_>*/
*<_rbirth_note_>  *</_rbirth_note_>
gen   rbirth = .
notes rbirth: HIES does not collect the information needed to define this variable
*</_rbirth_>

*<_rprevious_juris_>
*<_rprevious_juris_note_>  Region of previous residence *</_rprevious_juris_note_>
/*<_rprevious_juris_note_> Variable is constructed for all persons administered this module in each questionnaire.  It identifies the level at which previous region is coded in the survey  *</_rprevious_juris_note_>*/
*<_rprevious_juris_note_>  *</_rprevious_juris_note_>
gen   rprevious_juris = .
notes rprevious_juris: HIES does not collect the information needed to define this variable
*</_rprevious_juris_>

*<_rprevious_>
*<_rprevious_note_>  Region Previous Residence *</_rprevious_note_>
/*<_rprevious_note_> Corresponds to reg01 if rprevious_juris=1, reg02 if rprevious_juris=2, reg03 if rprevious_juris=3, ISO 3166-1 if rprevious_juris=5, and original code if rbitrh_juris=9 *</_rprevious_note_>*/
*<_rprevious_note_>  *</_rprevious_note_>
gen   rprevious = .
notes rprevious: HIES does not collect the information needed to define this variable
*</_rprevious_>

*<_yrmove_>
*<_yrmove_note_>  Year of most recent move *</_yrmove_note_>
/*<_yrmove_note_> Indicates year of most recent move from rprevious *</_yrmove_note_>*/
*<_yrmove_note_>  *</_yrmove_note_>
gen   yrmove = .
notes yrmove: HIES does not collect the information needed to define this variable
*</_yrmove_> 


****************************************************************
**** EDUCATION VARIABLES
****************************************************************

*<_ed_mod_age_>
*<_ed_mod_age_note_> Education module application age *</_ed_mod_age_note_>
/*<_ed_mod_age_note_> Age at which the education module starts being applied *</_ed_mod_age_note_>*/
*<_ed_mod_age_note_>  *</_ed_mod_age_note_>
gen ed_mod_age = 5
notes ed_mod_age: the education module is applied to all persons 5 years and above
*</_ed_mod_age_>

*<_literacy_>
*<_literacy_note_> Individual can read and write *</_literacy_note_>
/*<_literacy_note_> Variable is constructed for all persons administered this module in each questionnaire.  For this reason the lower age cutoff at which information is collected will vary from country to country. Value must be missing for all others. No imputatio *</_literacy_note_>*/
*<_literacy_note_>  1 "Yes" 0 "No" *</_literacy_note_>
gen 	literacy = .
replace literacy = 1 	if (s2aq01==1 & s2aq02==1)
replace literacy = 0 	if (s2aq01==2 | s2aq02==2) & literacy!=1  // A person with different response is reported as missing
replace literacy = . 	if  age<ed_mod_age
* Values that don't correspond to the survey options are send to missing
replace literacy = . 	if (s2aq01!=1 & s2aq01!=2) | (s2aq02!=2 & s2aq02!=1)
*</_literacy_>

*<_atschool_>
*<_atschool_note_> Attending school *</_atschool_note_>
/*<_atschool_note_> Variable is constructed for all persons administered this module in each questionnaire, typically of primary age and older. For this reason the lower age cutoff will vary from country to country. 
If person on short school holiday when intervie *</_atschool_note_>*/
*<_atschool_note_>  1 "Yes" 0 "No" *</_atschool_note_>
gen     atschool = s2bq01
replace atschool = 0 		if 	s2bq01==2
replace atschool = . 		if 	s2bq01>2
replace atschool = . 		if	age<5
*</_atschool_>

*<_educy_>
*<_educy_note_> Years of education *</_educy_note_>
/*<_educy_note_> Variable is constructed for all persons administered this module in each questionnaire. For this reason the lower age cutoff at which information is collected will vary from country to country. 
This is a continuous variable of the number of years of formal schooling completed *</_educy_note_>*/
*<_educy_note_>  *</_educy_note_>
gen 	educy = .  
replace educy = 0 			if  s2aq01==2   
replace educy = 0 			if  s2aq03==2   
replace educy = s2aq04 		if  s2aq04<.
recode 	educy (11 = 12) (15 = 16) (18 = 18) (16 = 19) (17 = 17) (12 = 14) (14 = 14) (13 = 16) (19 = .) (21 = .)
replace educy = s2bq03 		if  educy==. & s2bq03!=.
* Substract one year of education to those currently studying before secondary
replace educy = educy-1 		if (s2aq04==. & s2bq03<=11 & s2bq03!=.)
* Substract one year of education to those currently studying after secondary
recode 	educy (10 = 11) (15 = 15) (18 = 17) (16 = 18) (17 = 16) (12 = 13) (14 = 13) (13 = 15) (19 = .) (21 = .) if (s2aq04==. & s2bq03!=.)
replace educy = 0 			if  educy==-1
replace educy = . 			if  educy==50
replace educy = . 			if  age<ed_mod_age
replace educy = . 			if (educy>age & educy!=. & age!=.)
*</_educy_>

*<_educat7_>
*<_educat7_note_> Level of education 7 categories *</_educat7_note_>
/*<_educat7_note_> Secondary is everything from the end of primary to before tertiary (for example, grade 7 through 12). Vocational training is country-specific and will be defined by each region.  *</_educat7_note_>*/
*<_educat7_note_>  1 "No education" 2 "Primary incomplete" 3 "Primary complete" 4 "Secondary incomplete" 5 "Secondary complete" 6 "Post secondary but not university" 7 "University" *</_educat7_note_>
gen 	educat7 = .
replace educat7 = 1 		if  educy==0
replace educat7 = 2 		if  educy>0 & educy<5
replace educat7 = 3 		if  educy==5
replace educat7 = 4 		if  educy>5 & educy<12
replace educat7 = 5 		if  educy==12
replace educat7 = 7 		if  educy>12 & educy<23
replace educat7 = 6 		if  inlist(educy,13,14)
replace educat7 = 8 		if  s2aq04==19 | s2bq03==19
replace educat7 = . 		if  age<5
*</_educat7_>

*<_educat5_>
*<_educat5_note_> Level of education 5 categories *</_educat5_note_>
/*<_educat5_note_> At least educat4 will have to be included (if it is unclear whether primary or secondary is completed or not). If educat5 is available, educat4 can be created. Secondary is everything from the end of primary to before tertiary (for example, grad *</_educat5_note_>*/
*<_educat5_note_>  1 "No education" 2 "Primary incomplete" 3 "Primary complete but Secondary incomplete" 4 "Secondary complete" 5 "Tertiary (completed or incomplete)" *</_educat5_note_>
recode educat7 (1=1) (2=2) (3 4=3) (5=4) (6 7=5), gen(educat5)
*</_educat5_>

*<_educat4_>
*<_educat4_note_> Level of education 4 categories *</_educat4_note_>
/*<_educat4_note_> At least educat4 will have to be included (if it is unclear whether primary or secondary is completed or not). If educat5 is available, educat4 can be created. Secondary is everything from the end of primary to before tertiary (for example, grad *</_educat4_note_>*/
*<_educat4_note_>  1 "No education" 2 "Primary (complete or incomplete)" 3 "Secondary (complete or incomplete)" 4 "Tertiary (complete or incomplete)" *</_educat4_note_>
recode educat7 (1=1) (2 3=2) (4 5=3) (6 7=4), gen(educat4)
*</_educat4_>

*<_everattend_>
*<_everattend_note_> Ever attended school *</_everattend_note_>
/*<_everattend_note_> All persons of primary school age or above. `Primary school age’ will vary by country. 
This is country-specific and depends on how school attendance is defined. Pre-school is not included here. Also, in some countries, ever attended is yes  *</_everattend_note_>*/
*<_everattend_note_>  1 "Yes" 0 "No" *</_everattend_note_>
gen 	everattend = .
replace everattend = 0 	if  educat7==1 
replace everattend = 1 	if (educat7>=2 & educat7!=.) | atschool==1
replace everattend = . 	if  age<5
*</_everattend_>

replace educy = 0 		if  everattend==0
replace educat7 = 1 		if  everattend==0
replace educat4 = 1 		if  everattend==0
replace educat5 = 1 		if  everattend==0
	
foreach v of varlist educat7 educat5 educat4 educy atschool literacy everattend { 
	replace `v'=. if age<ed_mod_age 
}


****************************************************************
**** LABOR VARIABLES
****************************************************************

*<_lb_mod_age_>
*<_lb_mod_age_note_> Labor module application age *</_lb_mod_age_note_>
/*<_lb_mod_age_note_> Age at which the labor module starts being applied (working age: people at which can start legally working) *</_lb_mod_age_note_>*/
*<_lb_mod_age_note_>  *</_lb_mod_age_note_>
gen   lb_mod_age = 5
notes lb_mod_age: the employment module is applied to all persons 5 years and above
*</_lb_mod_age_>

*<_lstatus_>
*<_lstatus_note_> Labor Force Status *</_lstatus_note_>
/*<_lstatus_note_> Variable is constructed for all persons administered this module in each questionnaire.  For this reason the lower age cutoff (and perhaps upper age cutoff) at which information is collected will vary from country to country. 
All persons are co *</_lstatus_note_>*/
*<_lstatus_note_>  1 "Employed" 2 "Unemployed" 3 "Not in labor force" *</_lstatus_note_>
gen 	lstatus = .
replace lstatus = 1 		if  s1bq01==1
replace lstatus = 2 		if  s1bq01==2 & s1bq03==1 
replace lstatus = 3 		if  s1bq01==2 & (s1bq02==2 | s1bq03==2)
replace lstatus = 2 		if  s1bq04==8 | s1bq04==10 				// Waiting to start new job/on leave/looking for job/business
replace lstatus = 3 		if  s1bq04!=. & s1bq01==2 & lstatus==.
replace lstatus = 1			if  ila!=0 & ila!=.
replace lstatus = . 		if  age<5
notes lstatus: "BGD 2016" a person is considered "unemployed" if not working but waiting to start a new job.
notes lstatus: "BGD 2016" question related to available to accept a job is not taken into account in the definition of unemployed.
*</_lstatus_>

*<_nlfreason_>
*<_nlfreason_note_> Reason not in the labor force *</_nlfreason_note_>
/*<_nlfreason_note_> This variable is constructed for all those who are not presently employed and are not looking for work (lstatus=3) and missing otherwise.
Student, the person is studying. 
Housekeeping is the person takes care of the house, older people, or chil *</_nlfreason_note_>*/
*<_nlfreason_note_> 1 "Student" 2 "Housewife" 3 "Retired" 4 "Disabled" 5 "Others" *</_nlfreason_note_>
gen byte nlfreason = . 
replace nlfreason = 1 		if  s1bq04==3
replace nlfreason = 2 		if  s1bq04==2 | s1bq04==1
replace nlfreason = 3 		if  s1bq04==4
replace nlfreason = 4 		if  s1bq04==7
replace nlfreason = 5 		if (s1bq04==5 | s1bq04==6 | s1bq04>=9) & s1bq04<=11
replace nlfreason = . 		if  s1bq04==0 | s1bq04==14 | lstatus!=3
*</_nlfreason_>

*<_njobs_>
*<_njobs_note_>  Number of total jobs *</_njobs_note_>
/*<_njobs_note_> Number of jobs besides the main one coming from main occupation *</_njobs_note_>*/
*<_njobs_note_>  *</_njobs_note_>
egen aux1 = rsum(daylab_cash_1 daylab_kind_1 employee_cash_1 employee_kind_1 month_nonagri_1 agri_net_1), missing
egen aux2 = rsum(daylab_cash_2 daylab_kind_2 employee_cash_2 employee_kind_2 month_nonagri_2 agri_net_2), missing
egen aux3 = rsum(daylab_cash_3 daylab_kind_3 employee_cash_3 employee_kind_3 month_nonagri_3 agri_net_3), missing
egen aux4 = rsum(daylab_cash_4 daylab_kind_4 employee_cash_4 employee_kind_4 month_nonagri_4 agri_net_4), missing
egen aux5 = rsum(daylab_cash_5 daylab_kind_5), missing
egen aux6 = rsum(daylab_cash_6 daylab_kind_6), missing
egen aux7 = rsum(daylab_cash_7 daylab_kind_7), missing
egen aux8 = rsum(daylab_cash_8 daylab_kind_8), missing

gen 	njobs = .
replace njobs = 1	if  aux1!=. | w_cat_1!=.
replace njobs = 2	if  aux2!=. | w_cat_2!=.
replace njobs = 3	if  aux3!=. | w_cat_3!=.
replace njobs = 4	if  aux4!=. | w_cat_4!=.
replace njobs = 5	if  aux5!=. | w_cat_5!=.
replace njobs = 6	if  aux6!=. | w_cat_6!=.
replace njobs = 7	if  aux7!=. | w_cat_7!=.
replace njobs = 8	if  aux8!=. | w_cat_8!=.
notes   njobs: period of reference is the last 12 months
drop aux*
*</_njobs_>

*<_unempldur_l_>
*<_unempldur_l_note_> Unemployment duration (months) lower bracket *</_unempldur_l_note_>
/*<_unempldur_l_note_> Variable is constructed for all persons who are unemployed (lstatus=2, otherwise missing). If continuous records the numbers of months in unemployment. If the variable is categorical it records the lower boundary of the bracket. *</_unempldur_l_note_>*/
*<_unempldur_l_note_>  *</_unempldur_l_note_>
gen   unempldur_l = .
notes unempldur_l: the HIES does not contain the information needed to define this variable
*</_unempldur_l_>

*<_unempldur_u_>
*<_unempldur_u_note_> Unemployment duration (months) upper bracket *</_unempldur_u_note_>
/*<_unempldur_u_note_> Variable is constructed for all persons who are unemployed (lstatus=2, otherwise missing). If continuous records the numbers of months in unemployment. If the variable is categorical it records the upper boundary of the bracket. If the right bra *</_unempldur_u_note_>*/
*<_unempldur_u_note_>  *</_unempldur_u_note_>
gen   unempldur_u = .
notes unempldur_u: the HIES does not contain the information needed to define this variable
*</_unempldur_u_>

*<_industry_orig_>
*<_industry_orig_note_> Original industry codes - main job - last 7 days *</_industry_orig_note_>
/*<_industry_orig_note_>  *</_industry_orig_note_>*/
*<_industry_orig_note_>   *</_industry_orig_note_>
gen   industry_orig = .
notes industry_orig: HIES does not collect information on sector of employment (industry) in the last 7 days
*</_industry_orig_>

*<_industry_>
*<_industry_note_> 1 digit industry classification - main job - last 7 days *</_industry_note_>
/*<_industry_note_> Variable is constructed for all persons administered this module in each questionnaire. For this reason the lower age cutoff (and perhaps upper age cutoff) at which information is collected will vary from country to country. Classifies the main job of any individual with a job (lstatus=1) and is missing otherwise. The codes for the main job are given here based on the UN-ISIC (Rev. 3.1). The main categories subsume the following codes: 1 = Agriculture, Hunting, Fishing and Forestry 2 = Mining 3 = Manufacturing 4 = Electricity and Utilities 5 = Construction 6 = Commerce 7 = Transportation, Storage and Communication 8 = Financial, Insurance and Real Estate 9 = Public Administration 10 = Other Services. In the case of different classifications, recoding has been done to best match the ISIC-31 codes. Code 10 is also assigned for unspecified categories or items. *</_industry_note_>*/
*<_industry_note_>  *</_industry_note_>
gen 	industry = .
notes   industry: HIES does not collect information on sector of employment (industry) in the last 7 days
*</_industry_>

*<_industry_orig_year_>
*<_industry_orig_year_note_> Original industry codes - main job - last 12 months *</_industry_orig_year_note_>
/*<_industry_orig_year_note_>  *</_industry_orig_year_note_>*/
*<_industry_orig_year_note_>   *</_industry_orig_year_note_>
gen   industry_orig_year = s4aq01c_1
notes industry_orig_year: Original variable for sector of employment is s4aq01c. It is converted to s4aq01c_1 when defining main job (based on income)
*</_industry_orig_year_>

*<_industry_year_>
*<_industry_year_note_> 1 digit industry classification - main job - last 12 months *</_industry_year_note_>
/*<_industry_year_note_> Variable is constructed for all persons administered this module in each questionnaire. For this reason the lower age cutoff (and perhaps upper age cutoff) at which information is collected will vary from country to country. Classifies the main job of any individual with a job (lstatus=1) and is missing otherwise. The codes for the main job are given here based on the UN-ISIC (Rev. 3.1). The main categories subsume the following codes: 1 = Agriculture, Hunting, Fishing and Forestry 2 = Mining 3 = Manufacturing 4 = Electricity and Utilities 5 = Construction 6 = Commerce 7 = Transportation, Storage and Communication 8 = Financial, Insurance and Real Estate 9 = Public Administration 10 = Other Services. In the case of different classifications, recoding has been done to best match the ISIC-31 codes. Code 10 is also assigned for unspecified categories or items. *</_industry_year_note_>*/
*<_industry_year_note_>  *</_industry_year_note_>
gen 	industry_year = .
replace industry_year = 1		if  s4aq01c_1==1  | s4aq01c_1==2 | s4aq01c_1==5
replace industry_year = 2		if  s4aq01c_1>=10 & s4aq01c_1<=14
replace industry_year = 3  		if  s4aq01c_1>=15 & s4aq01c_1<=37
replace industry_year = 4		if  s4aq01c_1==40 | s4aq01c_1==41
replace industry_year = 5		if  s4aq01c_1==45
replace industry_year = 6  		if  s4aq01c_1>=50 & s4aq01c_1<=55
replace industry_year = 7 		if  s4aq01c_1>=60 & s4aq01c_1<=64
replace industry_year = 8 		if  s4aq01c_1>=65 & s4aq01c_1<=74
replace industry_year = 9		if  s4aq01c_1==75
replace industry_year = 10		if  s4aq01c_1>=80 & s4aq01c_1<=99
*</_industry_year_>

*<_industry_orig_2_>
*<_industry_orig_2_note_> Original industry codes - second job - last 7 days *</_industry_orig_2_note_>
/*<_industry_orig_2_note_> This variable correspond to whatever is in the original file with no recoding *</_industry_orig_2_note_>*/
*<_industry_orig_2_note_>  *</_industry_orig_2_note_>
gen   industry_orig_2 = .
notes industry_orig_2: HIES does not collect information on sector of employment (industry) in the last 7 days
*</_industry_orig_2_>

*<_industry_2_>
*<_industry_2_note_>  1 digit industry classification - second job - last 7 days *</_industry_2_note_>
/*<_industry_2_note_> Variable is constructed for all persons administered this module in each questionnaire. For this reason the lower age cutoff (and perhaps upper age cutoff) at which information is collected will vary from country to country.
Classifies the seco *</_industry_2_note_>*/
*<_industry_2_note_>  *</_industry_2_note_>
gen 	industry_2 = .
notes   industry_2: HIES does not collect information on sector of employment (industry) in the last 7 days
*</_industry_2_>

*<_industry_orig_2_year_>
*<_industry_orig_2_year_note_> Original industry codes - second job - last 12 months *</_industry_orig_2_year_note_>
/*<_industry_orig_2_year_note_> This variable correspond to whatever is in the original file with no recoding *</_industry_orig_2_year_note_>*/
*<_industry_orig_2_year_note_>  *</_industry_orig_2_year_note_>
gen   industry_orig_2_year = s4aq01c_2
notes industry_orig_2_year: Original variable for sector of employment is s4aq01c. It is converted to s4aq01c_2 when defining main job (based on income)
*</_industry_orig_2_year_>

*<_industry_2_year_>
*<_industry_2_year_note_>  1 digit industry classification - second job - last 12 months *</_industry_2_year_note_>
/*<_industry_2_year_note_> Variable is constructed for all persons administered this module in each questionnaire. For this reason the lower age cutoff (and perhaps upper age cutoff) at which information is collected will vary from country to country.
Classifies the seco *</_industry_2_year_note_>*/
*<_industry_2_year_note_>  *</_industry_2_year_note_>
gen 	industry_2_year = .
replace industry_2_year = 1		if  s4aq01c_2==1  | s4aq01c_2==2 | s4aq01c_2==5
replace industry_2_year = 2		if  s4aq01c_2>=10 & s4aq01c_2<=14
replace industry_2_year = 3  	if  s4aq01c_2>=15 & s4aq01c_2<=37
replace industry_2_year = 4		if  s4aq01c_2==40 | s4aq01c_2==41
replace industry_2_year = 5		if  s4aq01c_2==45
replace industry_2_year = 6  	if  s4aq01c_2>=50 & s4aq01c_2<=55
replace industry_2_year = 7 	if  s4aq01c_2>=60 & s4aq01c_2<=64
replace industry_2_year = 8 	if  s4aq01c_2>=65 & s4aq01c_2<=74
replace industry_2_year = 9		if  s4aq01c_2==75
replace industry_2_year = 10	if  s4aq01c_2>=80 & s4aq01c_2<=99
*</_industry_2_year_>

*<_occup_>
*<_occup_note_> 1 digit occupational classification - main job - last 7 days *</_occup_note_>
/*<_occup_note_> Variable is constructed for all persons administered this module in each questionnaire. For this reason the lower age cutoff (and perhaps upper age cutoff) at which information is collected will vary from country to country. Classifies the main job of any indiviudal with a job (lstatus=1) and is missing otherwise. The classification is based on the International Standard Classification of Occupations (ISCO) 88. In the case of different classifications re-coding has been done to best match the ISCO-88. *</_occup_note_>*/
*<_occup_note_> 1 "Managers" 2 "Professionals" 3 "Technicians and associate professionals" 4 "Clerical support workers" 5 "Service and sales workers" 6 "Skilled agricultural, forestry and fishery workers" 7 "Craft and related trades workers" 8 "Plant and machine operators, and assemblers" 9 "Elementary occupations" 10 "Armed forces occupations" 99 "Other/unspecified" *</_occup_note_>
gen   occup = .a
notes occup: HIES does not collect information on occupational status for the main job in the last 7 days
*</_occup_>

*<_occup_2_>
*<_occup_2_note_> 1 digit occupational classification - main job - last 7 days *</_occup_2_note_>
/*<_occup_2_note_> Variable is constructed for all persons administered this module in each questionnaire. For this reason the lower age cutoff (and perhaps upper age cutoff) at which information is collected will vary from country to country. Classifies the main job of any indiviudal with a job (lstatus=1) and is missing otherwise. The classification is based on the International Standard Classification of Occupations (ISCO) 88. In the case of different classifications re-coding has been done to best match the ISCO-88. *</_occup_2_note_>*/
*<_occup_2_note_> 1 "Managers" 2 "Professionals" 3 "Technicians and associate professionals" 4 "Clerical support workers" 5 "Service and sales workers" 6 "Skilled agricultural, forestry and fishery workers" 7 "Craft and related trades workers" 8 "Plant and machine operators, and assemblers" 9 "Elementary occupations" 10 "Armed forces occupations" 99 "Other/unspecified" *</_occup_2_note_>
gen   occup_2 = .
notes occup_2: HIES does not collect information on occupational status for the secondary job in the last 7 days
*</_occup_2_>

*<_occup_year_>
*<_occup_year_note_> 1 digit occupational classification *</_occup_year_note_>
/*<_occup_year_note_> Variable is constructed for all persons administered this module in each questionnaire. For this reason the lower age cutoff (and perhaps upper age cutoff) at which information is collected will vary from country to country. Classifies the main job of any indiviudal with a job (lstatus=1) and is missing otherwise. The classification is based on the International Standard Classification of Occupations (ISCO) 88. In the case of different classifications re-coding has been done to best match the ISCO-88. *</_occup_year_note_>*/
*<_occup_year_note_> 1 "Managers" 2 "Professionals" 3 "Technicians and associate professionals" 4 "Clerical support workers" 5 "Service and sales workers" 6 "Skilled agricultural, forestry and fishery workers" 7 "Craft and related trades workers" 8 "Plant and machine operators, and assemblers" 9 "Elementary occupations" 10 "Armed forces occupations" 99 "Other/unspecified" *</_occup_year_note_>
gen     occup_year = .
replace occup_year = 1		if  s4aq01b_1==20 | s4aq01b_1==21  | s4aq01b_1==30  | s4aq01b_1==40  | s4aq01b_1==50  
replace occup_year = 2		if  s4aq01b_1==2  | s4aq01b_1==4   | (s4aq01b_1>=6  & s4aq01b_1<=13) | (s4aq01b_1>=15 & s4aq01b_1<=19)
replace occup_year = 3		if  s4aq01b_1==1  | s4aq01b_1==3   | s4aq01b_1==5   | s4aq01b_1==14  | s4aq01b_1==42  | s4aq01b_1==43  | s4aq01b_1==44 | s4aq01b_1==86
replace occup_year = 4		if (s4aq01b_1>=31 & s4aq01b_1<=33) | (s4aq01b_1>=37 & s4aq01b_1<=39)
replace occup_year = 5		if  s4aq01b_1==36 | s4aq01b_1==45  | (s4aq01b_1>=51 & s4aq01b_1<=54) | s4aq01b_1==49  | s4aq01b_1==58  | s4aq01b_1==59 
replace occup_year = 6		if  s4aq01b_1==70 | s4aq01b_1==60  | s4aq01b_1==61  | s4aq01b_1==63  | s4aq01b_1==64
replace occup_year = 7		if  s4aq01b_1==71 | s4aq01b_1==72  | (s4aq01b_1>=75 & s4aq01b_1<=85) | (s4aq01b_1>=87 & s4aq01b_1<=89) | s4aq01b_1==92 
replace occup_year = 8		if  s4aq01b_1==34 | s4aq01b_1==35  | s4aq01b_1==74  | s4aq01b_1==90  | s4aq01b_1==91
replace occup_year = 9		if  s4aq01b_1==55 | s4aq01b_1==56  
*</_occup_year_>

*<_empstat_>
*<_empstat_note_>  Employment status - main job - last 7 days *</_empstat_note_>
/*<_empstat_note_> Variable is constructed for all persons administered this module in each questionnaire. For this reason the lower age cutoff (and perhaps upper age cutoff) at which information is collected will vary from country to country. Definitions taken from the ILO’s Classification of Status in Employment with some revisions to take into account the data available. Classifies the main job employment status of any individual with a job (lstatus=1) and is missing otherwise.  
Paid employee includes anyone whose basic remuneration is not directly dependent on the revenue of the unit they work for, typically remunerated by wages and salaries but may be paid for piece work or in-kind. The ‘continuous’ criteria used in the ILO definition is not used here as data are often absent and due to country specificity. 
Non paid employee includes contributing family workers are those workers who hold a self-employment job in a market-oriented establishment operated by a related person living in the same households who cannot be regarded as a partner because of their degree of commitment to the operation of the establishment, in terms of working time or other factors, is not at a level comparable to that of the head of the establishment. 
Employer is a business owner (whether alone or in partnership) with employees. If the only people working in the business are the owner and ‘contributing family workers, the person is not considered an employer (as has no employees) and is, instead classified as own account. 
Own account or self-employment includes jobs are those where remuneration is directly dependent from the goods and service produced (where home consumption is considered to be part of the profits) and have not engaged any permanent employees to work for them on a continuous basis during the reference period. 
Members of producers’ cooperatives are workers who hold a self-employment job in a cooperative producing goods and services in which each member takes part on an equal footing with other members in determining the organization of production, sales and/or other work of the establishment, the investments and the distribution of the proceeds of the establishment amongst the members. 
Other, workers not classifiable by status include those for whom insufficient relevant information is available and/or who cannot be included in any of the preceding categories. *</_empstat_note_>*/
*<_empstat_note_> 1 "Paid Employee" 2 "Non-Paid Employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status" *</_empstat_note_>
gen   empstat = .
notes empstat: HIES does not collect information on employment status for the main job in the last 7 days
*</_empstat_>

*<_empstat_year_>
*<_empstat_year_note_>  Employment status - main job - last 12 months *</_empstat_year_note_>
/*<_empstat_year_note_> Variable is constructed for all persons administered this module in each questionnaire. For this reason the lower age cutoff (and perhaps upper age cutoff) at which information is collected will vary from country to country. Definitions taken from the ILO’s Classification of Status in Employment with some revisions to take into account the data available. Classifies the main job employment status of any individual with a job (lstatus=1) and is missing otherwise.  
Paid employee includes anyone whose basic remuneration is not directly dependent on the revenue of the unit they work for, typically remunerated by wages and salaries but may be paid for piece work or in-kind. The ‘continuous’ criteria used in the ILO definition is not used here as data are often absent and due to country specificity. 
Non paid employee includes contributing family workers are those workers who hold a self-employment job in a market-oriented establishment operated by a related person living in the same households who cannot be regarded as a partner because of their degree of commitment to the operation of the establishment, in terms of working time or other factors, is not at a level comparable to that of the head of the establishment. 
Employer is a business owner (whether alone or in partnership) with employees. If the only people working in the business are the owner and ‘contributing family workers, the person is not considered an employer (as has no employees) and is, instead classified as own account. 
Own account or self-employment includes jobs are those where remuneration is directly dependent from the goods and service produced (where home consumption is considered to be part of the profits) and have not engaged any permanent employees to work for them on a continuous basis during the reference period. 
Members of producers’ cooperatives are workers who hold a self-employment job in a cooperative producing goods and services in which each member takes part on an equal footing with other members in determining the organization of production, sales and/or other work of the establishment, the investments and the distribution of the proceeds of the establishment amongst the members. 
Other, workers not classifiable by status include those for whom insufficient relevant information is available and/or who cannot be included in any of the preceding categories. *</_empstat_year_note_>*/
*<_empstat_year_note_> 1 "Paid Employee" 2 "Non-Paid Employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status" *</_empstat_year_note_>
egen aux1 = rsum(month_nonagri_1 agri_net_1), missing
gen 	empstat_year = .
replace empstat_year = 1			if  w_cat_1==1 | w_cat_1==4
replace empstat_year = 3			if  w_cat_1==3
replace empstat_year = 4 			if  w_cat_1==2
replace empstat_year = 4 			if  empstat_year==. & aux1!=.
notes   empstat_year: we include as self-employed to all those with information on agricultural or non-agricultural income, but without employment information
drop aux*
*</_empstat_year_>

*<_empstat_2_>
*<_empstat_2_note_>  Employment status - second job - last 7 days *</_empstat_2_note_>
/*<_empstat_2_note_> Variable is constructed for all persons administered this module in each questionnaire. For this reason the lower age cutoff (and perhaps upper age cutoff) at which information is collected will vary from country to country. Definitions taken from the ILO’s Classification of Status in Employment with some revisions to take into account the data available. Classifies the main job employment status of any individual with a job (lstatus=1) and is missing otherwise.  
Paid employee includes anyone whose basic remuneration is not directly dependent on the revenue of the unit they work for, typically remunerated by wages and salaries but may be paid for piece work or in-kind. The ‘continuous’ criteria used in the ILO definition is not used here as data are often absent and due to country specificity. 
Non paid employee includes contributing family workers are those workers who hold a self-employment job in a market-oriented establishment operated by a related person living in the same households who cannot be regarded as a partner because of their degree of commitment to the operation of the establishment, in terms of working time or other factors, is not at a level comparable to that of the head of the establishment. 
Employer is a business owner (whether alone or in partnership) with employees. If the only people working in the business are the owner and ‘contributing family workers, the person is not considered an employer (as has no employees) and is, instead classified as own account. 
Own account or self-employment includes jobs are those where remuneration is directly dependent from the goods and service produced (where home consumption is considered to be part of the profits) and have not engaged any permanent employees to work for them on a continuous basis during the reference period. 
Members of producers’ cooperatives are workers who hold a self-employment job in a cooperative producing goods and services in which each member takes part on an equal footing with other members in determining the organization of production, sales and/or other work of the establishment, the investments and the distribution of the proceeds of the establishment amongst the members. 
Other, workers not classifiable by status include those for whom insufficient relevant information is available and/or who cannot be included in any of the preceding categories. *</_empstat_2_note_>*/
*<_empstat_2_note_> 1 "Paid Employee" 2 "Non-Paid Employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status" *</_empstat_2_note_>
gen   empstat_2 = .
notes empstat_2: HIES does not collect information on employment status for the secondary job in the last 7 days
*</_empstat_2_>

*<_empstat_2_year_>
*<_empstat_2_year_note_>  Employment status - second job - last 12 months *</_empstat_2_year_note_>
/*<_empstat_2_year_note_> Variable is constructed for all persons administered this module in each questionnaire. For this reason the lower age cutoff (and perhaps upper age cutoff) at which information is collected will vary from country to country. Definitions taken from the ILO’s Classification of Status in Employment with some revisions to take into account the data available. Classifies the main job employment status of any individual with a job (lstatus=1) and is missing otherwise.  
Paid employee includes anyone whose basic remuneration is not directly dependent on the revenue of the unit they work for, typically remunerated by wages and salaries but may be paid for piece work or in-kind. The ‘continuous’ criteria used in the ILO definition is not used here as data are often absent and due to country specificity. 
Non paid employee includes contributing family workers are those workers who hold a self-employment job in a market-oriented establishment operated by a related person living in the same households who cannot be regarded as a partner because of their degree of commitment to the operation of the establishment, in terms of working time or other factors, is not at a level comparable to that of the head of the establishment. 
Employer is a business owner (whether alone or in partnership) with employees. If the only people working in the business are the owner and ‘contributing family workers, the person is not considered an employer (as has no employees) and is, instead classified as own account. 
Own account or self-employment includes jobs are those where remuneration is directly dependent from the goods and service produced (where home consumption is considered to be part of the profits) and have not engaged any permanent employees to work for them on a continuous basis during the reference period. 
Members of producers’ cooperatives are workers who hold a self-employment job in a cooperative producing goods and services in which each member takes part on an equal footing with other members in determining the organization of production, sales and/or other work of the establishment, the investments and the distribution of the proceeds of the establishment amongst the members. 
Other, workers not classifiable by status include those for whom insufficient relevant information is available and/or who cannot be included in any of the preceding categories. *</_empstat_2_year_note_>*/
*<_empstat_2_year_note_> 1 "Paid Employee" 2 "Non-Paid Employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status" *</_empstat_2_year_note_>
egen aux2 = rsum(month_nonagri_2 agri_net_2), missing

gen 	empstat_2_year = .
replace empstat_2_year = 1		if  w_cat_2==1 | w_cat_2==4
replace empstat_2_year = 3		if  w_cat_2==3
replace empstat_2_year = 4 		if  w_cat_2==2
replace empstat_2_year = 4 		if  empstat_2_year==. & aux2!=.
notes   empstat_2_year: we include as self-employed to all those with information on agricultural or non-agricultural income, but without employment information
drop aux*
*</_empstat_2_year_>

*<_ocusec_>
*<_ocusec_note_>  Sector of activity - main job - last 7 days *</_ocusec_note_>
/*<_ocusec_note_> Variable is constructed for all persons administered this module in each questionnaire. Classifies the main job's sector of activity of any individual with a job (lstatus=1) and is missing otherwise. Public sector includes non-governmental organizations and armed forces. Private sector is that part of the economy which is both run for private profit and is not controlled by the state. State owned includes para-statal firms and all others in which the government has control (participation over 50%). *</_ocusec_note_>*/
*<_ocusec_note_> 1 "Public sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish" *</_ocusec_note_>
gen   ocusec = .
notes ocusec: HIES does not collect information on sector of activity for the main job in the last 7 days
*</_ocusec_>

*<_ocusec_year_>
*<_ocusec_year_note_> Sector of activity, primary job (12-mon ref period) *</_ocusec_year_note_>
/*<_ocusec_year_note_> 1 "Public sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish" *</_ocusec_year_note_>*/
*<_ocusec_year_note_> ocusec_year brought in from rawdata *</_ocusec_year_note_>
gen     ocusec_year = .
replace ocusec_year = 1 		if  s4bq06_1==1 | s4bq06_1==2 | s4bq06_1==4 | s4bq06_1==6 
replace ocusec_year = 2 		if  s4bq06_1==3 | s4bq06_1==5 | s4bq06_1==8 | s4bq06_1==7
notes   ocusec_year: variable defined only for workers working as paid employees
*</_ocusec_year_>

*<_firmsize_l_>
*<_firmsize_l_note_>  Firm size (lower bracket) *</_firmsize_l_note_>
/*<_firmsize_l_note_> Variable is constructed for all persons who are employed. If continuous records the number of people working for the same employer. If the variable is categorical it records the lower boundary of the bracket. *</_firmsize_l_note_>*/
*<_firmsize_l_note_>  *</_firmsize_l_note_>
gen   firmsize_l = .
notes firmsize_l: the HIES does not collect information on firm size
*</_firmsize_l_>

*<_firmsize_u_>
*<_firmsize_u_note_>  Firm size (upper bracket) *</_firmsize_u_note_>
/*<_firmsize_u_note_> Variable is constructed for all persons who are employed. If continuous records the number of people working for the same employer. If the variable is categorical it records the upper boundary of the bracket. *</_firmsize_u_note_>*/
*<_firmsize_u_note_>  *</_firmsize_u_note_>
gen   firmsize_u = .
notes firmsize_u: the HIES does not collect information on firm size
*</_firmsize_u_>

*<_contract_>
*<_contract_note_>  Contract *</_contract_note_>
/*<_contract_note_> Variable is constructed for all persons administered this module in each questionnaire.  Indicates if a person has a signed (formal) contract, regardless of duration. For this reason the lower age cutoff (and perhaps upper age cutoff) at which information is collected will vary from country to country. Classifies the contract status of any individual with a job (lstatus=1) and is missing otherwise. This variable is only constructed if there is an explicit question about contracts. *</_contract_note_>*/
*<_contract_note_>  1 "Yes" 0 "No" *</_contract_note_>
gen   contract = .
notes contract: HIES does not collect information on labour contract for the main job in the last 7 days
*</_contract_>

*<_healthins_>
*<_healthins_note_>  Health insurance *</_healthins_note_>
/*<_healthins_note_> Variable is constructed for all persons administered this module in each questionnaire. For this reason the lower age cutoff (and perhaps upper age cutoff) at which information is collected will vary from country to country. Classifies the social security status of any individual with a job (lstatus=1) and is missing otherwise. This variable is only constructed if there is an explicit question about health security. *</_healthins_note_>*/
*<_healthins_note_>  1 "Yes" 0 "No" *</_healthins_note_>
gen   healthins = .
notes healthins: HIES does not collect information on health insurance from employment for the main job in the last 7 days
*</_healthins_>

*<_socialsec_>
*<_socialsec_note_>  Social security *</_socialsec_note_>
/*<_socialsec_note_> Variable is constructed for all persons administered this module in each questionnaire.  For this reason the lower age cutoff (and perhaps upper age cutoff) at which information is collected will vary from country to country. Classifies the social security status of any individual with a job (lstatus=1) and is missing otherwise. This variable is only constructed if there is an explicit question about pension plans or social security. *</_socialsec_note_>*/
*<_socialsec_note_>  1 "Yes" 0 "No" *</_socialsec_note_>
gen   socialsec = .
notes socialsec: HIES does not collect information on social security rights from employment for the main job in the last 7 days
*</_socialsec_>

*<_union_>
*<_union_note_> Union membership *</_union_note_>
/*<_union_note_> Variable is constructed for all persons administered this module in each questionnaire.  For this reason the lower age cutoff (and perhaps upper age cutoff) at which information is collected will vary from country to country. Classifies the union membership status of any individual with a job (lstatus=1) and is missing otherwise. This variable is only constructed if there is an explicit question about trade unions. *</_union_note_>*/
*<_union_note_> 1 "Yes" 0 "No" *</_union_note_>
gen   union = .
notes union: HIES does not collect information on union membership for the main job in the last 7 days
*</_union_>

*<_wage_>
*<_wage_note_>  Last wage payment *</_wage_note_>
/*<_wage_note_> Variable is constructed for all persons administered this module in each questionnaire. For this reason the lower age cutoff (and perhaps upper age cutoff) will vary from country to country. States the main job's wage earner of any individual (lstatus=1 & empstat<=4) and is missing otherwise. Wage from main job. This excludes tips, bonuses, and other payments. For all those with self-employment or owners of own businesses, this should be net revenues (net of all costs EXCEPT for tax payments) or the amount of salary taken from the business. Due to the almost complete lack of information on taxes, the wage from main job is NOT net of taxes. By definition non-paid employees (empstat=2) should have wage=0. *</_wage_note_>*/
*<_wage_note_> *</_wage_note_>
egen  wage = rsum(daylab_cash_1 employee_cash_1 daylab_kind_1 employee_kind_1 agri_net_1 month_nonagri_1), missing
notes wage: average monthly labour income in the last 12 months in the main job
*</_wage_>

*<_wage_2_>
*<_wage_2_note_>  Last wage payment second job *</_wage_2_note_>
/*<_wage_2_note_> Variable is constructed for all persons administered this module in each questionnaire. For this reason the lower age cutoff (and perhaps upper age cutoff) will vary from country to country. States the second job's wage earner of any individual (lstatus=1 & empstat_2<=4) and is missing otherwise. Wage from second job. This excludes tips, bonuses, and other payments. For all those with self-employment or owners of own businesses, this should be net revenues (net of all costs EXCEPT for tax payments) or the amount of salary taken from the business.  Due to the almost complete lack of information on taxes, the wage from second job is NOT net of taxes. By definition non-paid employees (empstat_2=2) should have wage=0. *</_wage_2_note_>*/
*<_wage_2_note_> *</_wage_2_note_>
egen  wage_2 = rsum(daylab_cash_2 employee_cash_2 daylab_kind_2 employee_kind_2 agri_net_2 month_nonagri_2), missing
notes wage_2: average monthly labour income in the last 12 months in the second job
*</_wage_2_>

*<_unitwage_>
*<_unitwage_note_>  Last wages time unit - main job *</_unitwage_note_>
/*<_unitwage_note_> Type of reference for the wage variable. States the main job's wage earner time unit measurement of any individual (lstatus=1 & empstat<=4) and is missing otherwise. *</_unitwage_note_>*/
*<_unitwage_note_> 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Every two months" 5 "Monthly" 6 "Quarterly" 7 "Every six months" 8 "Annually" 9 "Hourly" 10 "Other" *</_unitwage_note_>
gen   unitwage = 5			if  wage!=.
notes unitwage: variable WAGE was defined using a monthly basis
*</_unitwage_>

*<_unitwage_2_>
*<_unitwage_2_note_>  Last wages time unit - second job *</_unitwage_2_note_>
/*<_unitwage_2_note_> Type of reference for the wage variable. States the second job's wage earner time unit measurement of any individual (lstatus=1 & empstat_2<=4) and is missing otherwise. *</_unitwage_2_note_>*/
*<_unitwage_2_note_> 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Every two months" 5 "Monthly" 6 "Quarterly" 7 "Every six months" 8 "Annually" 9 "Hourly" 10 "Other" *</_unitwage_2_note_>
gen   unitwage_2 = 5			if  wage_2!=.
notes unitwage_2: variable WAGE_2 was defined using a monthly basis
*</_unitwage_2_>

*<_whours_>
*<_whours_note_>  Hours of work in last week *</_whours_note_>
/*<_whours_note_> Variable is constructed for all persons administered this module in each questionnaire. For this reason the lower age cutoff (and perhaps upper age cutoff) at which information is collected will vary from country to country. Classifies the main job of any individual with a job (lstatus=1) and is missing otherwise. This is the number of hours worked in the last 7 days or the reference week in the person’s main job. Main job defined as that occupation to which the person dedicated more time. For persons absent from their job in the week preceding the survey due to holidays, vacation or sick leave, the time worked in the last week the person worked is recorded. For individuals who only give information on how many hours they work per day and no information on number of days worked a week, multiply the hours by 5 days. In the case of a question that has hours worked per month, divide by 4.2 to get weekly hours. *</_whours_note_>*/
*<_whours_note_>  *</_whours_note_>
gen     whours = hours_1/(12*4.2)
replace whours = .		if  whours>150
*</_whours_>

foreach var in lstatus nlfreason unempldur_l unempldur_u njobs industry industry_orig industry_2 industry_orig_2 industry_year industry_orig_year industry_2_year industry_orig_2_year occup occup_2 occup_year empstat empstat_year empstat_2 empstat_2_year ocusec ocusec_year firmsize_l firmsize_u contract healthins socialsec union wage wage_2 unitwage unitwage_2 whours {
	replace `var'=. if age<lb_mod_age
	}
	

****************************************************************
**** ASSETS
****************************************************************

*<_television_>
*<_television_note_> Household has television *</_television_note_>
/*<_television_note_> Availability of televisions in household. Question on quantity or specific availability should be present *</_television_note_>*/
*<_television_note_>  1 "Yes" 0 "No" *</_television_note_>
gen television = assets582
*</_television>

*<_radio_>
*<_radio_note_> Household has radio *</_radio_note_>
/*<_radio_note_> Availability of radios in household. Question on quantity or specific availability should be present *</_radio_note_>*/
*<_radio_note_>  1 "Yes" 0 "No" *</_radio_note_>
gen radio = assets571
*</_radio_>

*<_fan_>
*<_fan_note_> Household has fan *</_fan_note_>
/*<_fan_note_> Availability of fans in household. Question on quantity or specific availability should be present *</_fan_note_>*/
*<_fan_note_>  1 "Yes" 0 "No" *</_fan_note_>
gen fan = assets579
*</_fan>

*<_sewingmachine_>
*<_sewingmachine_note_> Household has sewing machine *</_sewingmachine_note_>
/*<_sewingmachine_note_> Availability of sewing machines  in household. Question on quantity or specific availability should be present *</_sewingmachine_note_>*/
*<_sewingmachine_note_>  1 "Yes" 0 "No" *</_sewingmachine_note_>
gen sewingmachine = assets586
*</_sewingmachine>

*<_washingmachine_>
*<_washingmachine_note_> Household has washing machine *</_washingmachine_note_>
/*<_washingmachine_note_> Availability of washing machines in household. Question on quantity or specific availability should be present *</_washingmachine_note_>*/
*<_washingmachine_note_>  1 "Yes" 0 "No" *</_washingmachine_note_>
gen washingmachine = assets578
*</_washingmachine>

*<_refrigerator_>
*<_refrigerator_note_> Household has refrigerator *</_refrigerator_note_>
/*<_refrigerator_note_> Availability of refrigerator  in household. Question on quantity or specific availability should be present *</_refrigerator_note_>*/
*<_refrigerator_note_>  1 "Yes" 0 "No" *</_refrigerator_note_>
gen refrigerator = assets577
*</_refrigerator>

*<_lamp_>
*<_lamp_note_> Household has lamp *</_lamp_note_>
/*<_lamp_note_> Availability of lamp in household. Question on quantity or specific availability should be present *</_lamp_note_>*/
*<_lamp_note_>  1 "Yes" 0 "No" *</_lamp_note_>
gen lamp = assets585
*</_lamp>

*<_bicycle_>
*<_bicycle_note_> Household has bicycle *</_bicycle_note_>
/*<_bicycle_note_> Availability of bicycle in household. Question on quantity or specific availability should be present *</_bicycle_note_>*/
*<_bicycle_note_>  1 "Yes" 0 "No" *</_bicycle_note_>
gen bicycle = assets574
*</_bicycle>

*<_motorcycle_>
*<_motorcycle_note_> Household has motorcycle *</_motorcycle_note_>
/*<_motorcycle_note_> Availability of motor cycles (bikes) in household. Question on quantity or specific availability should be present *</_motorcycle_note_>*/
*<_motorcycle_note_>  1 "Yes" 0 "No" *</_motorcycle_note_>
gen motorcycle = assets575
*</_motorcycle>

*<_motorcar_>
*<_motorcar_note_> Household has motorcar *</_motorcar_note_>
/*<_motorcar_note_> Availability of motorcars in household. Question on quantity or specific availability should be present *</_motorcar_note_>*/
*<_motorcar_note_>  1 "Yes" 0 "No" *</_motorcar_note_>
gen motorcar = assets576
*</_motorcar>

*<_buffalo_>
*<_buffalo_note_> Household has buffalo *</_buffalo_note_>
/*<_buffalo_note_> Availability of buffalos in household. Question on quantity or specific availability should be present *</_buffalo_note_>*/
*<_buffalo_note_>  1 "Yes" 0 "No" *</_buffalo_note_>
gen buffalo = s7c1q02a_204
*</_buffalo>

*<_chicken_>
*<_chicken_note_> Household has chicken *</_chicken_note_>
/*<_chicken_note_> Availability of chicken in household. Question on quantity or specific availability should be present *</_chicken_note_>*/
*<_chicken_note_>  1 "Yes" 0 "No" *</_chicken_note_>
gen chicken = s7c1q02a_205
*</_chicken>

*<_cow_>
*<_cow_note_> Household has cow *</_cow_note_>
/*<_cow_note_> Availability of cows in household. Question on quantity or specific availability should be present *</_cow_note_>*/
*<_cow_note_>  1 "Yes" 0 "No" *</_cow_note_>
gen cow = s7c1q02a_201
*</_cow>


***************************************************************************
**** WELFARE MODULE 
***************************************************************************

*<_spdef_>
*<_spdef_note_>  Spatial deflator. *</_spdef_note_>
/*<_spdef_note_> Specifies varname for a spatial deflator if one is used. This variable can only be used in combination with a subnational ID. *</_spdef_note_>*/
*<_spdef_note_>  *</_spdef_note_>
gen spdef = .a
*</_spdef_>

*<_welfare_>
*<_welfare_note_>  Welfare aggregate used for estimating international poverty (provided to PovcalNet). *</_welfare_note_>
/*<_welfare_note_> Specifies varname for the welfare aggregate (e.g. per capita consumption) in the data file that is provided to Povcalnet as input into the estimation of international poverty. This variable should be annual and in LCU at current prices. The variables welfare, welfarenom, and welfaredef have to be in the same welfare type (either income, consumption or expenditure) and two of these three welfare aggregates will be the same. *</_welfare_note_>*/
*<_welfare_note_>  *</_welfare_note_>
capture drop welfare
gen welfare = pcexp
*</_welfare_>

sum zu16 [aw=wgt] 
local mean_nat = r(mean)
sum pcexp [aw=wgt] 
local avg = r(mean)
gen welfare_adj = pcexp*`mean_nat'/zu16
sum welfare_adj [aw=wgt] 
local avg2 = r(mean)
replace welfare_adj = welfare_adj*`avg'/`avg2'  
gen spatial_def = (`mean_nat'/zu16)*(`avg'/`avg2')

preserve
keep hhid pid welfare_adj spatial_def
tempfile spatial
save `spatial', replace
restore

*<_welfarenom_>
*<_welfarenom_note_>  Welfare aggregate in nominal terms. *</_welfarenom_note_>
/*<_welfarenom_note_> Specifies varname for the welfare aggregate (e.g. per capita consumption) in the data file in nominal terms. This variable should be annual and in LCU at current prices. The variables welfare, welfarenom, and welfaredef have to be in the same welfare type (either income, consumption or expenditure) and two of thes three welfare aggregates will be the same. *</_welfarenom_note_>*/
*<_welfarenom_note_>  *</_welfarenom_note_>
gen welfarenom = pcexp
*</_welfarenom_>

*<_welfaredef_>
*<_welfaredef_note_>  Welfare aggregate spatially deflated. *</_welfaredef_note_>
/*<_welfaredef_note_> Specifies varname for the welfare aggregate (e.g. per capita consumption) in the data file spatially deflated (spatial or within year inflaction adjustment).  This variable should be annual and in LCU at current prices. The variables welfare, welfarenom, and welfaredef have to be in the same welfare type (either income, consumption or expenditure) and two of thes three welfare aggregates will be the same. *</_welfaredef_note_>*/
*<_welfaredef_note_>  *</_welfaredef_note_>
gen welfaredef = rpcexp
*</_welfaredef_>

*<_welfshprosperity_>
*<_welfshprosperity_note_>  Welfare aggregate for shared prosperity (if different from poverty) *</_welfshprosperity_note_>
/*<_welfshprosperity_note_> specifies varname for the welfare variable used to compute the shared prosperity indicator (e.g. per capita consumption) in the data file. This variable should be annual and in LCU at current prices. This variable is either the same as welfare ( *</_welfshprosperity_note_>*/
*<_welfshprosperity_note_>  *</_welfshprosperity_note_>
gen welfshprosperity = pcexp
*</_welfshprosperity_>

*<_welfaretype_>
*<_welfaretype_note_>  Type of welfare measure (income, consumption or expenditure) for welfare, welfarenom, welfaredef. *</_welfaretype_note_>
/*<_welfaretype_note_> Specifies the type of welfare measure for the variables welfare, welfarenom and welfaredef. Accepted values are: INC for income, CONS for consumption, or EXP for expenditure. Welfaretype is case-sensitive and upper case has to be used. *</_welfaretype_note_>*/
*<_welfaretype_note_>  *</_welfaretype_note_>
gen welfaretype = "EXP"
*</_welfaretype_>

*<_welfareother_>
*<_welfareother_note_>  Welfare aggregate if different welfare type is used from welfare, welfarenom, welfaredef. *</_welfareother_note_>
/*<_welfareother_note_> Specifies varname for the welfare aggregate in the data file if a different welfare type is used from the variables welfare, welfarenom, welfaredef. For example, if consumption is used for welfare, welfarenom and welfaredef but income also exists, it could be included here. This variable should be annual and in LCU at current prices. *</_welfareother_note_>*/
*<_welfareother_note_>  *</_welfareother_note_>
gen   welfareother = ipcf*12
notes welfareother: variable is defined as household per capita income
*</_welfareother_>

*<_welfareothertype_>
*<_welfareothertype_note_>  Type of welfare measure (income, consumption or expenditure) for welfareother. *</_welfareothertype_note_>
/*<_welfareothertype_note_> Specifies the type of welfare measure for the variable welfareother. Accepted values are: INC for income, CONS for consumption, or EXP for expenditure. This variable is only entered if the type of welfare is different from what is provided in welfare, welfarenom, and welfaredef. For example, if consumption is used for welfare, welfarenom and welfaredef but income also exists, it could be included here. Welfaretype is case-sensitive and upper case has to be used. *</_welfareothertype_note_>*/
*<_welfareothertype_note_>  *</_welfareothertype_note_>
gen welfareothertype = "INC"
*</_welfareothertype_>

*<_welfarenat_>
*<_welfarenat_note_>  Welfare aggregate for national poverty. *</_welfarenat_note_>
/*<_welfarenat_note_> Welfare aggregate for national poverty. *</_welfarenat_note_>*/
*<_welfarenat_note_>  1 "Yes" 0 "No" *</_welfarenat_note_>
gen welfarenat = welfare
*</_welfarenat_>	


* QUINTILE AND DECILE OF CONSUMPTION AGGREGATE
levelsof year, loc(y)
/*rename idh idh_hies
egen   idh = concat(psu idh_hies), punct(-)
merge  m:1 idh using "${shares}\BGD_fnf_`y'", keepusing (quintile_cons_aggregate decile_cons_aggregate) nogen
drop   idh
rename idh_hies idh
note _dta: "BGD 2016" Food/non-food shares are not included because there is not enough information to replicate their composition. 
*/

*<_quintile_cons_aggregate_>
*<_quintile_cons_aggregate_note_> Quintile of welfarenat *</_quintile_cons_aggregate_note_>
/*<_quintile_cons_aggregate_note_>  *</_quintile_cons_aggregate_note_>*/
*<_quintile_cons_aggregate_note_>  *</_quintile_cons_aggregate_note_>
_ebin welfare [aw=weight], gen(quintile_cons_aggregate) nq(5) 
*</_quintile_cons_aggregate_>

*<_food_share_>
*<_food_share_note_> Food share *</_food_share_note_>
/*<_food_share_note_>  *</_food_share_note_>*/
*<_food_share_note_>  *</_food_share_note_>
gen food_share = (fexp/consexp2)*100
*</_food_share_>

*<_nfood_share_>
*<_nfood_share_note_> Non-food share *</_nfood_share_note_>
/*<_nfood_share_note_>  *</_nfood_share_note_>*/
*<_nfood_share_note_>  *</_nfood_share_note_>
*gen nfood_share = .a //change
gen nfood_share =  100-food_share  
*</_nfood_share_>


****************************************************************
**** NATIONAL POVERTY
****************************************************************

*<_pline_nat_>
*<_pline_nat_note_>  Poverty line (National). *</_pline_nat_note_>
/*<_pline_nat_note_> Poverty line based on the nationl methodology. *</_pline_nat_note_>*/
*<_pline_nat_note_>  *</_pline_nat_note_>
drop pline_nat
gen  pline_nat = zu16
*</_pline_nat_>
gen  iline_nat = zl16

*<_poor_nat_>
*<_poor_nat_note_>  People below Poverty Line (National). *</_poor_nat_note_>
/*<_poor_nat_note_> People below Poverty Line (National). *</_poor_nat_note_>*/
*<_poor_nat_note_>  *</_poor_nat_note_>
gen poor_nat = welfarenat<pline_nat if welfare!=.
*</_poor_nat_>
gen extr_nat = welfarenat<iline_nat 	if  welfarenat!=. 

preserve
keep hhid pid iline_nat extr_nat
tempfile poverty
save `poverty', replace
restore


****************************************************************
**** INTERNATIONAL POVERTY
****************************************************************
cap gen code = "`code'"
cap gen year = `year'

/*
preserve
datalibweb, country(Support) year(2005) type(GMDRAW) surveyid(Support_2005_CPI_v`cpiver'_M) filename(Final_CPI_PPP_to_be_used.dta)
keep if code=="`code'" & year==`year'
collapse (mean) icp2017 cpi2017, by(code year)
tempfile data
save `data', replace
restore 

merge m:1 code using `data', nogen keep(match)
rename icp2017 ppp 
*/
	
** CPI PERIOD  
*<_cpiperiod_>
gen cpiperiod = 2016
*</_cpiperiod_>	
	
** POVERTY LINE (POVCALNET)
*<_pline_int_>
*gen pline_int = 2.15*cpi2017*ppp*365/12
gen pline_int = .
*</_pline_int_>

** HEADCOUNT RATIO (POVCALNET)
*<_poor_int_>
gen poor_int = welfare<pline_int 	if  welfare!=.
*</_poor_int_>

******************************************************************
cap gen converfactor= .

gen ppp = .
 
gen 	agecat = ""
replace agecat = "15 years or younger" 	if  age<=15
replace agecat = "15-24 years old" 		if  age>15 & age<=24
replace agecat = "25-54 years old" 		if  age>24 & age<=54
replace agecat = "55-64 years old" 		if  age>54 & age<=64
replace agecat = "65 years or older" 	if  age>64

gen harmonization	= "`type'"
gen countryname	= "`code'"

clonevar minlaborage   	= lb_mod_age
clonevar industrycat10 	= industry
gen      industrycat4  	= industrycat10
recode   industrycat4  (2/5=2) (6/9=3) (10=4)
clonevar school        	= atschool
recode   educat7       (1 2=0) (3 4 5 6 7=1) (8=.) 	if everattend==1, gen(primarycomp)
clonevar imp_wat_rec   	= improved_water 
clonevar imp_san_rec   	= improved_sanitation 
gen      sector = .

*<_occup_orig_>
*<_occup_orig_note_> original occupation code *</_occup_orig_note_>
/*<_occup_orig_note_>  *</_occup_orig_note_>*/
*<_occup_orig_note_> occup_orig brought in from rawdata *</_occup_orig_note_>
gen   occup_orig = .
notes occup_orig: HIES does not collect information on occupational status for the main job in the last 7 days
*</_occup_orig_>

gen welfshprtype = "EXP"


*<_Keep variables_>
order countrycode year hhid pid weight weighttype
sort  hhid pid
*</_Keep variables_>

*<_Save data file_>
preserve
do   "$rootdofiles\_aux\Labels_GMD_All.do"
save "$output\\`filename'.dta", replace
restore
*</_Save data file_>

*<_Save data file_>
do   "$rootdofiles\_aux\Labels_SARMD.do"
merge 1:1 hhid pid using `poverty'
drop  _merge
merge 1:1 hhid pid using `spatial'
drop  _merge
save "$output\\BGD_2016_HIES_v01_M_v08_A_SARMD_IND_full.dta", replace
*</_Save data file_>
