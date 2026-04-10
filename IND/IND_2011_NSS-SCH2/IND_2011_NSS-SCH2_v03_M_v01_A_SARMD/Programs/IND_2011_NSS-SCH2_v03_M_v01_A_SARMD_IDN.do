/*----------------------------------------------------------------------------------
  SARMD Harmonization
------------------------------------------------------------------------------------
<_Program name_>   		IND_2011_NSS-SCH2_v03_M_v01_SARMD_IDN.do	   </_Program name_>
<_Application_>    		STATA 17.0									 <_Application_>
<_Author(s)_>      		Leo Tornarolli <tornarolli@gmail.com>		  </_Author(s)_>
<_Date created_>   		02-2026									   </_Date created_>
<_Date modified>    	February 2026						 	  </_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        		IND											    </_Country_>
<_Survey Title_>   		NSS-SCH2								   </_Survey Title_>
<_Survey Year_>    		2011										</_Survey Year_>
------------------------------------------------------------------------------------
<_Version Control_>
Date:					02-2026
File:					IND_2011_NSS-SCH2_v03_M_v01_SARMD_IDN.do
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
global module       	"IDN"
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
use "${input}\\`yearfolder'_v`vm'_M.dta", clear
*</_Datalibweb request_>


*<_countrycode_> 
*<_countrycode_note_> Country code according to ISO-3166 Alpha-3 *</_countrycode_note_>
gen countrycode = "`code'"
gen code = countrycode
*</_countrycode_>

*<_year_>
*<_year_note_> 4-digit year of survey based on IHSN standards *</_year_note_>
capture drop year 
gen year = 2011
*</_year_>

*<_int_year_>
*<_int_year_note_> Interview Year *</_int_year_note_>
gen str6 date_of_survey_str = string(date_of_survey, "%06.0f")
gen str2 aux1 = substr(date_of_survey_str,5,2)
gen 	int_year = 2011		if  aux1=="11"
replace int_year = 2012		if  aux1=="12"
*</_int_year_>

*<_int_month_>
*<_int_month_note_> Interview Month *</_int_month_note_>
*<_int_month_note_> 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December" *</_int_month_note_>
gen str2 aux2 = substr(date_of_survey_str,3,2)   
gen 	int_month = 1		if  aux2=="01"
replace int_month = 2		if  aux2=="02"
replace int_month = 3		if  aux2=="03"
replace int_month = 4		if  aux2=="04"
replace int_month = 5		if  aux2=="05"
replace int_month = 6		if  aux2=="06"
replace int_month = 7		if  aux2=="07"
replace int_month = 8		if  aux2=="08"
replace int_month = 9		if  aux2=="09"
replace int_month = 10		if  aux2=="10"
replace int_month = 11		if  aux2=="11"
replace int_month = 12		if  aux2=="12"
label define int_month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
label values int_month int_month
clonevar month = int_month
*</_int_month_>

*<_hhid_>
*<_hhid_note_> Household identifier  *</_hhid_note_>
/*<_hhid_note_> . *</_hhid_note_>*/
*<_hhid_note_> hhid brought in from SARMD *</_hhid_note_>
*</_hhid_>

*<_hhid_orig_>
*<_hhid_orig_note_> Household identifier variables in the raw data is HHID *</_hhid_org_note_>
gen hhid_orig = "HHID"
*</_hhid_orig_>

*<_pid_>
*<_pid_note_> Personal identifier  *</_pid_note_>
/*<_pid_note_> country specific *</_pid_note_>*/
*<_pid_note_> pid brought in from SARMD *</_pid_note_>
*</_pid_>

*<_pid_orig_>
*<_pid_orig_note_> Personal identifier variables in the raw data is INDID *</_pid_org_note_>
gen pid_orig = "INDID"
*</_pid_orig_>

*<_weight_>
*<_weight_note_> Household weight  *</_weight_note_>
/*<_weight_note_> Survey specific information *</_weight_note_>*/
clonevar weight = hhwt
clonevar weight_p = weight
*</_weight_>

*<_weighttype_>
*<_weighttype_note_> Weight type (frequency, probability, analytical, importance) *</_weighttype_note_>
*<_weighttype_note_> weighttype brought in from rawdata *</_weighttype_note_>
gen weighttype = "PW"
*</_weighttype_>


*<_Keep variables_>
order countrycode year hhid pid weight weighttype
sort  hhid pid 
*</_Keep variables_>


*<_Save data file_>
compress
quietly do 	"$rootdofiles\_aux\Labels_GMD3.0.do"
save 		"$output\\`filename'.dta", replace
*</_Save data file_>
	
	