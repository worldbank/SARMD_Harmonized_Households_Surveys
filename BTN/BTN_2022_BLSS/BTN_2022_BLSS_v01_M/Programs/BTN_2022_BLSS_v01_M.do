**==================================================================== drop clname EAname HH6 HH7
*project:       BTN_2022_BLSS
*Author:        
*Dependencies:  SAR stats team Poverty-World Bank 
*----------------------------------------------------------------------
*Creation Date:         11/28/2022 
*Modification Date:     11/28/2022 by Joe
*====================================================================

**survey information
local code="BTN"
local year=2022
local survey="BLSS"
local vm="01"
local stata "${rootdatalib}/`code'/`code'_`year'_`survey'/`code'_`year'_`survey'_v`vm'_M/Data/Stata"
local masterf "`code'_`year'_`survey'_v`vm'_M"

****BEGIN Data prep for the harmonization ****
	*<_Datalibweb request_>
	* load and merge relevant data
	tempfile individual_level_data
	* file 1
	datalibweb, country(`code') year(`year') type(SARRAW) filename(block1_demography_cleaned) local localpath(${rootdatalib})
	save `individual_level_data', replace
	duplicates report personid

	* file 2
	datalibweb, country(`code') year(`year') type(SARRAW) filename(block1_demo_edu_v1) local localpath(${rootdatalib})
	merge 1:1 personid using `individual_level_data', nogen assert(match)
	save `individual_level_data', replace

    * file 3
	datalibweb, country(`code') year(`year') type(SARRAW) filename(block2_housing_cleaned) local localpath(${rootdatalib})
	merge 1:m  interview__id using `individual_level_data', nogen assert(match)
	save `individual_level_data', replace

    * file 4
	datalibweb, country(`code') year(`year') type(SARRAW) filename(block3_asset_cleaned) local localpath(${rootdatalib})
	merge 1:m  interview__id using `individual_level_data', nogen assert(match)
	save `individual_level_data', replace

	*</_Datalibweb request_>
	* weights
	datalibweb, country(`code') year(`year') type(SARRAW) filename(weights) local localpath(${rootdatalib})
	merge 1:m interview__id using `individual_level_data', nogen assert(match)
	gen hhid=interview__id
	save `individual_level_data', replace
	
	* welfare
	datalibweb, country(`code') year(`year') type(SARRAW) filename(pcer_pl) local localpath(${rootdatalib})
	drop clcode
	merge 1:m hhid using `individual_level_data', nogen assert(match)
	save `individual_level_data', replace
	duplicates report personid
	cap drop year hhid

**********************************************
*<_countrycode_>
*<_countrycode_note_> country code *</_countrycode_note_>
*<_countrycode_note_> countrycode brought in from rawdata *</_countrycode_note_>
gen countrycode="`code'"
*</_countrycode_>

*<_year_>
*<_year_note_> Year *</_year_note_>
*<_year_note_> year brought in from rawdata *</_year_note_>
gen year=`year'
*</_year_>

*<_hhid_>
*<_hhid_note_> Household identifier  *</_hhid_note_>
*<_hhid_note_> hhid brought in from rawdata *</_hhid_note_>
gen hhid=interview__id
*</_hhid_>

*<_pid_>
*<_pid_note_> Personal identifier  *</_pid_note_>
*<_pid_note_> pid brought in from rawdata *</_pid_note_>
gen pid=slno
*</_pid_>

*<_weight_>
*<_weight_note_> Household weight *</_weight_note_>
*<_weight_note_> weight brought in from rawdata *</_weight_note_>
clonevar weight =weights
*</_weight_>

*<_weighttype_>
*<_weighttype_note_> Weight type (frequency, probability, analytical, importance) *</_weighttype_note_>
*<_weighttype_note_> weighttype brought in from rawdata *</_weighttype_note_>
gen weighttype = "PW"
*</_weighttype_>

*<_hsize_>
*<_hsize_note_> Household size *</_hsize_note_>
*<_hsize_note_> hsize brought in from rawdata *</_hsize_note_>
*g hsize = hhmem
*</_hsize_>

****ENDEND Data prep for the harmonization ****

save "`stata'/`masterf'.dta", replace


exit
*gracias totales*


***