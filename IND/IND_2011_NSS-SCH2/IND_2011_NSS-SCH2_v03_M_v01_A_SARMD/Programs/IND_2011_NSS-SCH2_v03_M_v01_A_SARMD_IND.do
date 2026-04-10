/*----------------------------------------------------------------------------------
  SARMD Harmonization
------------------------------------------------------------------------------------
<_Program name_>   		IND_2011_NSS-SCH2_v03_M_v01_SARMD_IND.do   </_Program name_>
<_Application_>    		STATA 17.0									 <_Application_>
<_Author(s)_>      		Leo Tornarolli <tornarolli@gmail.com>		  </_Author(s)_>
<_Date created_>   		02-2026									   </_Date created_>
<_Date modified>    	February 2026						 	  </_Date modified_>
------------------------------------------------------------------------------------
<_Country_>        		IND											    </_Country_>
<_Survey Title_>   		NSS-SCH2								   </_Survey Title_>
<_Survey Year_>    		2011										</_Survey Year_>
------------------------------------------------------------------------------------
<_Version Control_>
Date:					02-2026
File:					IND_2011_NSS-SCH2_v03_M_v01_SARMD_IND.do
First version
</_Version Control_>
----------------------------------------------------------------------------------*/

*<_Program setup_>
clear all
set more off

local code         		"IND"
local year         		"2011"
local survey       		"NSS-SCH2"
local vm           		"03"
local va           		"01"
local type         		"SARMD"
global module       	"IND"
local yearfolder    	"`code'_`year'_`survey'"
local SARMDfolder    	"`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'"
local filename      	"`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'_${module}"
cap mkdir				"${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'" 
cap mkdir				"${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'\\Data" 
cap mkdir				"${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'\\Data\Harmonized" 
global input      		"${rootdatalib}\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M\Data\Stata"
glo output          	"${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'\\Data\Harmonized" 
*</_Program setup_>


*<_Datalibweb request_>
use "${input}\IND_PRIMUS_2011-12.dta", clear
destring hhid stratum, replace 
rename hhid hhid_nss 
gen long hhid = hhid_nss
tempfile primus 
save `primus'
use "${input}\\`yearfolder'_v`vm'_M.dta", clear
merge 1:1 hhid pid using "${output}\\`yearfolder'_v`vm'_M_v`va'_A_`type'_IDN.dta", nogen
merge 1:1 hhid pid using "${output}\\`yearfolder'_v`vm'_M_v`va'_A_`type'_GEO.dta", nogen
destring age, replace
merge 1:1 hhid pid using "${output}\\`yearfolder'_v`vm'_M_v`va'_A_`type'_DEM.dta", nogen
merge 1:1 hhid pid using "${output}\\`yearfolder'_v`vm'_M_v`va'_A_`type'_LBR.dta", nogen
merge 1:1 hhid pid using "${output}\\`yearfolder'_v`vm'_M_v`va'_A_`type'_UTL.dta", nogen
merge 1:1 hhid pid using "${output}\\`yearfolder'_v`vm'_M_v`va'_A_`type'_DWL.dta", nogen
merge 1:1 hhid pid using "${output}\\`yearfolder'_v`vm'_M_v`va'_A_`type'_CONS.dta", nogen
merge m:1 hhid using "`primus'", keepusing(pwt welfarenom_final welfaredef_final cpi_* hhsize)
*</_Datalibweb request_>


gen wgt = weight 
gen weight_h = weight 
gen pop_wgt = pwt
gen code = "`code'"
gen month = int_month 
gen subnatid1_sar = subnatid1 
gen subnatid2_sar = subnatid2 
gen subnatid3_sar = subnatid3 
gen subnatid4_sar = subnatid4  
gen rbirth = .
gen rbirth_juris = . 
gen rprevious = .
gen rprevious_juris = .
gen yrmove = .
gen buffalo = .
gen chicken = .
gen cow = .
gen cpiperiod = . 
gen food_share = .
gen nfood_share = .
gen spdef = .
gen wage = wage_total
gen wage_2 = wage_total_2

*<_survey_>
*<_survey_note_> Survey acronym *</_survey_note_>
capture drop survey
gen str survey = "`survey' `year'"
label var survey "National Sample Survey - Schedule 2: 2011-2012"
*</_survey_>

*<_veralt_>
*<_veralt_note_> Harmonization version *</_veralt_note_>
gen veralt = "`va'"
*</_veralt_>

*<_vermast_>
*<_vermast_note_> Master version *</_vermast_note_>
gen vermast = "`vm'"
*</_vermast_>

*<_hsize_>
*<_hsize_note_> Household size *</_hsize_note_>
/*<_hsize_note_> specifies varname for the household size number in the data file. It has to be compatible with the numbers of national and international poverty at household size when weights are used in any computation *</_hsize_note_>*/
*<_hsize_note_>  *</_hsize_note_>
gen hsize = hhsize
*</_hsize_>

*<_soc_>
*<_soc_note_> Social group *</_soc_note_>
/*<_soc_note_> The classification is country specific.
It not needs to be present for every country/year. *</_soc_note_>*/
*<_soc_note_>  *</_soc_note_>
gen 	soc = "."
replace soc = "1 - Scheduled Tribe"			if  sgroup==1
replace soc = "2 - Scheduled Caste"			if  sgroup==2
replace soc = "3 - Other Backward Caste"	if  sgroup==3
replace soc = "9 - Other"					if  sgroup==9 | sgroup==.
notes   soc: missing values are cases where caste is not reported

gen social_group = soc 
*</_soc_>

*<_religion_>
*<_religion_note_> Religion *</_religion_note_>
/*<_religion_note_> The classification is country specific.
 It not needs to be present for every country/year. *</_religion_note_>*/
*<_religion_note_>  *</_religion_note_>
rename religion religion_nss
gen 	religion = "."
replace religion = "1 - Hinduism"		if  religion_nss==1
replace religion = "2 - Islam"			if  religion_nss==2
replace religion = "3 - Christianity"	if  religion_nss==3
replace religion = "4 - Sikhism"		if  religion_nss==4
replace religion = "5 - Jainism"		if  religion_nss==5
replace religion = "6 - Buddhism"		if  religion_nss==6
replace religion = "7 - Zoroastrianism"	if  religion_nss==7
replace religion = "9 - Other"			if  religion_nss==9 
*</_religion_>

*<_typehouse_>
*<_typehouse_note_> GMD ownhouse variable *</_typehouse_note_>
*<_typehouse_note_> typehouse brought in from GMD *</_typehouse_note_>
clonevar typehouse = ownhouse
*</_typehouse_>

*<_water_jmp_>
*<_water_jmp_note_> Source of drinking water, using Joint Monitoring Program categories *</_water_jmp_note_>
*<_wate_jmp_note_> 1 "Piped into dwelling" 2 "Piped into compound, yard or plot" 3 "Public tap/standpipe" 4 "Tubewell, Borehole" 5 "Protected well" 6 "Unprotected well" 7 "Protected spring" 8 "Unprotected spring" 9 "Rain water" 10 "Tanker-truck or other vendor" 11 "Cart with small tank/drum" 12 "Surface water (river, stream, dam, lake, pond) 13 "Bottled water" 14 "Other" *</_wate_jmp_note_>
gen water_jmp = .
*</_water_jmp_>

*<_sar_improved_water_>
*<_sar_improved_water_note_> Improved source of drinking water-using country-specific definitions *</_sar_improved_water_note_>
/*<_sar_improved_water_note_> Dummy variable: 1=improved, 0=unimproved source following JMP guidelines *</_sar_improved_water_note_>*/
*<_sar_improved_water_note_>  1 "Yes" 0 "No" *</_sar_improved_water_note_>
gen sar_improved_water = .
gen improved_water = sar_improved_water
*</_sar_improved_water_>

*<_piped_water_>
*<_piped_water_note_> Household has access to piped water *</_piped_water_note_>
/*<_piped_water_note_> Variable takes the value of 1 if household has access to piped water. *</_piped_water_note_>*/
*<_piped_water_note_>  1 "Yes" 0 "No" *</_piped_water_note_>
gen piped_water = .		
*</_piped_water_>

*<_toilet_jmp_>
*<_toilet_jmp_note_> Access to sanitation facility-using Joint Monitoring Program categories *</_toilet_jmp_note_>
*<_toilet_jmp_note_> 1 "Flush to piped sewer system" 2 "Flush to septic tank" 3 "Flush to pit latrine" 4 "Flush to somewhere else" 5 "Flush, don't know where" 6 "Ventilated improved pit latrine" 7 "Pit latrine with slab" 8 "Pit latrine without slab/open pit" 9 "Composting toilet" 10 "Bucket toilet" 11 "Hanging toilet/Hanging latrine" 12 "No facility/bush/field" 13 "Other" *</_toilet_jmp_note_>
gen toilet_jmp = .
*</_toilet_jmp_>

*<_sar_improved_toilet_>
*<_sar_improved_toilet_note_> Improved type of sanitation facility-using country-specific definitions *</_sar_improved_toilet_note_>
/*<_sar_improved_toilet_note_> Dummy variable: 1=improved, 0=unimproved source following JMP guidelines *</_sar_improved_toilet_note_>*/
*<_sar_improved_toilet_note_>  1 "Yes" 0 "No" *</_sar_improved_toilet_note_>
gen sar_improved_toilet = .
gen improved_sanitation = sar_improved_toilet
gen shared_toilet = .
*</_sar_improved_toilet_>

*<_sewage_toilet_>
*<_sewage_toilet_note_> Household has access to sewage toilet *</_sewage_toilet_note_>
/*<_sewage_toilet_note_> Variable takes the value of 1 if household has access to sewage toilet. *</_sewage_toilet_note_>*/
*<_sewage_toilet_note_>  1 "Yes" 0 "No" *</_sewage_toilet_note_>
gen sewage_toilet = .
*</_sewage_toilet_>

*<_lamp_>
*<_lamp_note_> Ownership of a lamp *</_lamp_note_>
/*<_lamp_note_> 1 "Yes" 0 "No" *</_lamp_note_>*/
*<_lamp_note_> lamp brought in from raw data *</_lamp_note_>
gen   lamp = .
notes lamp: the NSS-SCH2 only collects information on expendidure for the purchase of electric fans in the last 365 days
*</_fan_>

*<_welfare_>
*<_welfare_note_>  Welfare aggregate used for estimating international poverty (provided to PovcalNet). *</_welfare_note_>
/*<_welfare_note_> Specifies varname for the welfare aggregate (e.g. per capita consumption) in the data file that is provided to Povcalnet as input into the estimation of international poverty. This variable should be annual and in LCU at current prices. The variables welfare, welfarenom, and welfaredef have to be in the same welfare type (either income, consumption or expenditure) and two of these three welfare aggregates will be the same. *</_welfare_note_>*/
*<_welfare_note_>  *</_welfare_note_>
gen welfare = welfaredef_final*12
*</_welfare_>

*<_welfarenom_>
*<_welfarenom_note_>  Welfare aggregate in nominal terms. *</_welfarenom_note_>
/*<_welfarenom_note_> Specifies varname for the welfare aggregate (e.g. per capita consumption) in the data file in nominal terms. This variable should be annual and in LCU at current prices. The variables welfare, welfarenom, and welfaredef have to be in the same welfare type (either income, consumption or expenditure) and two of thes three welfare aggregates will be the same. *</_welfarenom_note_>*/
*<_welfarenom_note_>  *</_welfarenom_note_>
gen welfarenom = welfarenom_final*12
*</_welfarenom_>

*<_welfaredef_>
*<_welfaredef_note_>  Welfare aggregate spatially deflated. *</_welfaredef_note_>
/*<_welfaredef_note_> Specifies varname for the welfare aggregate (e.g. per capita consumption) in the data file spatially deflated (spatial or within year inflaction adjustment).  This variable should be annual and in LCU at current prices. The variables welfare, welfarenom, and welfaredef have to be in the same welfare type (either income, consumption or expenditure) and two of thes three welfare aggregates will be the same. *</_welfaredef_note_>*/
*<_welfaredef_note_>  *</_welfaredef_note_>
gen welfaredef = welfaredef_final*12
*</_welfaredef_>

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
gen welfareother = .
*</_welfareother_>

*<_welfareothertype_>
*<_welfareothertype_note_>  Type of welfare measure (income, consumption or expenditure) for welfareother. *</_welfareothertype_note_>
/*<_welfareothertype_note_> Specifies the type of welfare measure for the variable welfareother. Accepted values are: INC for income, CONS for consumption, or EXP for expenditure. This variable is only entered if the type of welfare is different from what is provided in welfare, welfarenom, and welfaredef. For example, if consumption is used for welfare, welfarenom and welfaredef but income also exists, it could be included here. Welfaretype is case-sensitive and upper case has to be used. *</_welfareothertype_note_>*/
*<_welfareothertype_note_>  *</_welfareothertype_note_>
gen welfareothertype = ""
*</_welfareothertype_>

*<_quintile_cons_aggregate_>
*<_quintile_cons_aggregate_note_> Quintile of welfarenat *</_quintile_cons_aggregate_note_>
/*<_quintile_cons_aggregate_note_>  *</_quintile_cons_aggregate_note_>*/
*<_quintile_cons_aggregate_note_>  *</_quintile_cons_aggregate_note_>
_ebin welfare [aw=weight], gen(quintile_cons_aggregate) nq(5) 
*</_quintile_cons_aggregate_>

*<_welfarenat_>
*<_welfarenat_note_>  Welfare aggregate for national poverty. *</_welfarenat_note_>
/*<_welfarenat_note_> Welfare aggregate for national poverty. *</_welfarenat_note_>*/
*<_welfarenat_note_>  1 "Yes" 0 "No" *</_welfarenat_note_>
gen welfarenat = welfare
*</_welfarenat_>

*<_pline_nat_>
*<_pline_nat_note_>  Poverty line (National). *</_pline_nat_note_>
/*<_pline_nat_note_> Poverty line based on the national methodology. *</_pline_nat_note_>*/
*<_pline_nat_note_>  *</_pline_nat_note_>
gen pline_nat = .
gen poor_nat = .
gen pline_int = .
gen poor_int = .
*</_pline_nat_>

gen welfshprosperity = welfare


*<_Keep variables_>
order countrycode year hhid pid weight weighttype
sort  hhid pid
*</_Keep variables_>

*<_Save data file_>
compress
quietly do 	"$rootdofiles\_aux\Labels_GMD3.0.do"
save 		"$output\\`filename'.dta", replace
*</_Save data file_>

/*
preserve
use "${rootdatalib}\\Final_CPI_PPP_to_be_used.dta", clear
keep if code=="IND"
tempfile CPIs
gen 	urban = 0	if  datalevel==0
replace urban = 1	if  datalevel==1
save `CPIs'
restore

preserve
merge m:1 code year urban using `CPIs'
drop if _merge==2


gen pline_int_300 = 3.00*cpi2021*icp2021*365
gen 	poor_int_300 = welfare<pline_int_300
replace poor_int_300 = .				if  welfare==.
sum 	poor_int_300 [aw=wgt] 		if  !mi(poor_int_300)

gen pline_int_420 = 4.20*cpi2021*icp2021*365
gen 	poor_int_420 = welfare<pline_int_420 
replace poor_int_420 = .				if  welfare==.
sum 	poor_int_420 [aw=wgt] 		if  !mi(poor_int_420)

gen pline_int_830 = 8.30*cpi2021*icp2021*365
gen 	poor_int_830 = welfare<pline_int_830
replace poor_int_830 = .				if  welfare==.
sum 	poor_int_830 [aw=wgt] 		if  !mi(poor_int_830)	
restore

preserve 
use `CPIs', clear 
keep code year urban cpi2011 cpi2017 cpi2021
rename cpi2011 cpi_2011
rename cpi2017 cpi_2017
rename cpi2021 cpi_2021  
save, replace 
restore 

merge m:1 code year urban using `CPIs'
drop if _merge!=3
drop _merge
save, replace

 