/*------------------------------------------------------------------------------
					GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   MDV_2019_HIES_v01_M_v01.do	</_Program name_>
<_Application_>    STATA 16.0	<_Application_>
<_Author(s)_>      Juan Segnana <jsegnana@worldbank.org>	</_Author(s)_>
<_Date created_>   05-03-2021	</_Date created_>
<_Date modified>    06-10-2021	</_Date modified_>
<_Date modified>    12-22-2021	by Laura Moreno, "2019_Ind_level.dta" updated </_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        MDV	</_Country_>
<_Survey Title_>   HIES	</_Survey Title_>
<_Survey Year_>    2019	</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:	06-10-2021
File:	MDV_2019_HIES_v01_M_v01.do
- First version
</_Version Control_>
------------------------------------------------------------------------------*/
glo rootdatalib "P:\SARMD\SARDATABANK\SAR_DATABANK"
*<_Program setup_>;
#delimit ;
clear all;
set more off;

local code         "MDV";
local year         "2019";
local survey       "HIES";
local vm           "01";
local type         "SARMDRAW";
local yearfolder   "MDV_2019_HIES";
local filename     "MDV_2019_HIES_v01_M";
*</_Program setup_>;

*<_Folder creation_>;
cap mkdir "${rootdatalib}";
cap mkdir "${rootdatalib}\\`code'";
cap mkdir "${rootdatalib}\\`code'\\`yearfolder'";
cap mkdir "${rootdatalib}\\`code'\\`yearfolder'\\`filename'";
cap mkdir "${rootdatalib}\\`code'\\`yearfolder'\\`filename'\Data";
cap mkdir "${rootdatalib}\\`code'\\`yearfolder'\\`filename'\Data\Stata";
glo rawstata "${rootdatalib}\\`code'\\`yearfolder'\\`filename'\Data\Stata_pre";
glo original "${rootdatalib}\\`code'\\`yearfolder'\\`filename'\Data\Original_pre";
glo rawstatadlw "${rootdatalib}\\`code'\\`yearfolder'\\`filename'\Data\Stata";
glo originaldlw "${rootdatalib}\\`code'\\`yearfolder'\\`filename'\Data\Original";
*</_Folder creation_>;

/*****************************************************************************************************;
*                                                                                                    *;
                                   * ASSEMBLE DATABASE;
*                                                                                                    *;
*****************************************************************************************************/;

/** DATABASE ASSEMBLENT */;
	* Merge data;
	use "${rawstatadlw}\2019 HH Level.dta", clear;
	rename uqhhid uqhh__id;
	rename atoll atoll_1;
	merge 1:1 uqhh__id using "${rawstatadlw}\_hhlevel.dta", gen(merge_1);  drop if merge_1==2;
	*use "${originalnso}\_hhlevel.dta", clear;
	merge 1:1 uqhh__id using "${rawstatadlw}\exp_harm_GMD", gen(merge_2); drop if merge_2==2;
	*281 obs unmatched from the exp_harm_GMD.dta.  279 are part of the incomplete households;
	rename uqhh__id uqhhid;
	merge 1:1 uqhhid using "${rawstata}\hh_rep_tot", gen(merge_3); drop if merge_3==2;
	rename amount tot_hh_rep;

	* poverty19.dta former file of cons19.dta;
	tab atoll atoll_1; rename atoll atoll_str;
	merge 1:1 uqhhid using "${rawstata}\cons19.dta", gen(merge_4) keepusing(pce); drop year;
	
	merge m:1 psu using "${rawstata}\paasche_psu.dta", keepusing(paasche) gen(merge_6);
	
	cap rename atoll atoll_3;
	merge 1:m uqhhid using "${rawstata}\2019 Ind Level.dta", gen(merge_7); drop if merge_7==2;
	
	gen UsualMembers__id=person_no;
	rename uqhhid uqhh__id;
	merge 1:1 uqhh__id UsualMembers__id using "${rawstata}\occupation_1.dta", gen(merge_9); drop if merge_9==2;
	merge 1:1 uqhh__id UsualMembers__id using "${rawstata}\occupation_2.dta", gen(merge_10); drop if merge_10==2;
	rename uqhh__id uqhhid;
	cap drop hhid;
	rename male Male;

/** DATABASE ASSEMBLENT */;
*<_countrycode_>;
*<_countrycode_note_> country code *</_countrycode_note_>;
*<_countrycode_note_> countrycode brought in from rawdata *</_countrycode_note_>;
gen countrycode="MDV";
label var countrycode "Country code";
note countrycode: countrycode=MDV;
*</_countrycode_>;

*<_year_>;
*<_year_note_> Year *</_year_note_>;
*<_year_note_> year brought in from rawdata *</_year_note_>;
cap drop year;
gen int year=2019;
label var year "Year of survey";
note year: year=2019;
*</_year_>;

*<_hhid_>;
*<_hhid_note_> Household identifier  *</_hhid_note_>;
*<_hhid_note_> hhid brought in from rawdata *</_hhid_note_>;
cap drop hhid;
gen hhid=uqhhid;
tostring hhid, replace;
label var hhid "Household id";
note hhid: hhid=uqhhid  4,721 values;
*</_hhid_>;

*<_pid_>;
*<_pid_note_> Personal identifier  *</_pid_note_>;
*<_pid_note_> pid brought in from rawdata *</_pid_note_>;
egen pid=concat(hhid person_no), punct(-);
label var pid "Individual id";
note pid: pid=uqhh_id - person_nod  24,845 values;
*</_pid_>;

*<_Keep variables_>;
order countrycode year hhid pid;
sort hhid pid;
*</_Keep variables_>;
do "${rootdatalib}\\`code'\\`yearfolder'\\`filename'\Programs\MDV_2019_HIES_v01_M_labels.do"
*<_Save data file_>;
save "${rootdatalib}\\`code'\\`yearfolder'\\`filename'\Data\Stata\\`filename'.dta" , replace;
*</_Save data file_>;

exit