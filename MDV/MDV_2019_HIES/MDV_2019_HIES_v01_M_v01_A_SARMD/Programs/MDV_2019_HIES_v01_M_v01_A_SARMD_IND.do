/*------------------------------------------------------------------------------
					GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   MDV_2019_HIES_v01_M_v01_A_GMD_SARMD.do	</_Program name_>
<_Application_>    STATA 16.0	<_Application_>
<_Author(s)_>      Juan Segnana <jsegnana@worldbank.org>	</_Author(s)_>
<_Date created_>   05-03-2021	</_Date created_>
<_Date modified>   05-03-2021	</_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        MDV	</_Country_>
<_Survey Title_>   HIES	</_Survey Title_>
<_Survey Year_>    2019	</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:	05-03-2020
File:	MDV_2019_HIES_v01_M_v01_A_GMD_SARMD.do
- First version
</_Version Control_>
------------------------------------------------------------------------------*/

*<_Program setup_>
clear all
set more off

glo   cpiver       "v08"
local code         "MDV"
local year         "2019"
local survey       "HIES"
local vm           "01"
local va           "01"
local type         "SARMD"
glo   module       "IND"
local yearfolder   "`code'_`year'_`survey'"
local gmdfolder    "`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD"
local filename     "`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD_${module}"
*</_Program setup_>

*<_Folder creation_>
cap mkdir "$rootdatalib"
cap mkdir "$rootdatalib\\`code'"
cap mkdir "$rootdatalib\\`code'\\`yearfolder'"
cap mkdir "$rootdatalib\\`code'\\`yearfolder'\\`gmdfolder'"
cap mkdir "$rootdatalib\\`code'\\`yearfolder'\\`gmdfolder'\Data"
cap mkdir "$rootdatalib\\`code'\\`yearfolder'\\`gmdfolder'\Data\Harmonized"
*</_Folder creation_>

/*------------------------------------------------------------------------------*
/*------------------------------------------------------------------------------*
1. INPUT DATA 
*------------------------------------------------------------------------------*/
*------------------------------------------------------------------------------*/

	*--------------------------------------------------------------------------*
	* CPI and PPP
	*--------------------------------------------------------------------------*
	datalibweb, country(Support) year(2005) type(GMDRAW) surveyid(Support_2005_CPI_${cpiver}_M) filename(Final_CPI_PPP_to_be_used.dta)
	keep if code=="`code'" & year==`year'
	keep code year cpi2011 icp2011 cpi2017 icp2017 comparability
		rename icp2011 ppp_2011
		rename icp2017 ppp_2017
		*gen cpiperiod=. 
	tempfile cpidata
	save `cpidata', replace
	
	*--------------------------------------------------------------------------*
	* Additional data
	*--------------------------------------------------------------------------*
	use "$rootdatalib\\`code'\\`code'_`year'_HIES\\`code'_2019_HIES_v01_M\Data\Stata\auxaux\\`code'_`year'_HIES_v01_M.dta", clear
	merge 1:1 hhid pid using "$rootdatalib\\`code'\\`yearfolder'\\`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD\Data\Harmonized\\`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD_ALL.dta" //This is the same as the SARMD_GMD for the MDV_2019 case 
	gen code = countrycode
	
	*--------------------------------------------------------------------------*
	* Final database 
	*--------------------------------------------------------------------------*
	merge m:1 code year using `cpidata', nogen 

	
 

/*******************************************************************************
*                                                                              *
                           STANDARD SURVEY MODULE
*                                                                              *
*******************************************************************************/

*<_idh_>
*<_idh_note_> Household identifier  *</_idh_note_>
*<_idh_note_> idh brought in from GMD *</_idh_note_>
gen idh=hhid
*</_idh_>

*<_idh_org_>
*<_idh_org_note_> Household identifier in the raw data  *</_idh_org_note_>
*<_idh_org_note_> idh_org brought in from GMD *</_idh_org_note_>
gen idh_org=hhid_orig
*</_idh_org_>

*<_idp_>
*<_idp_note_> Personal identifier  *</_idp_note_>
*<_idp_note_> idp brought in from GMD *</_idp_note_>
gen idp=pid
*</_idp_>

*<_idp_org_>
*<_idp_org_note_> Personal identifier in the raw data  *</_idp_org_note_>
*<_idp_org_note_> idp_org brought in from GMD *</_idp_org_note_>
gen idp_org=pid_orig
*</_idp_org_>

*<_int_year_>
*<_int_year_note_> interview year *</_int_year_note_>
*<_int_year_note_> int_year brought in from rawdata *</_int_year_note_>
cap gen int_year=2019
*</_int_year_>

*<_survey_>
*<_survey_note_> Type of survey *</_survey_note_>
*<_survey_note_> survey brought in from rawdata *</_survey_note_>
cap gen survey="`survey'"
*</_survey_>

*<_wgt_>
*<_wgt_note_> Variables used to construct Household identifier  *</_wgt_note_>
*<_wgt_note_> wgt brought in from GMD *</_wgt_note_>
*gen wgt=weight
cap gen finalweight=weight
*</_wgt_>


/*****************************************************************************************************
*                                                                                                    *
                                   HOUSEHOLD CHARACTERISTICS MODULE
*                                                                                                    *
*****************************************************************************************************/
*<_urban_>
*<_urban_note_> Urban (1) or rural (0) *</_urban_note_>
*<_urban_note_> urban brought in from rawdata *</_urban_note_>
cap gen urban = urban
*</_urban_>

*<_subnatid_>
foreach v of varlist subnatid3 subnatid4 subnatidsurvey subnatid1_prev subnatid2_prev subnatid3_prev subnatid4_prev {
    tostring `v', replace 
	replace `v'="" if `v'=="."
}
*</_subnatid_>


*<_typehouse_>
*<_typehouse_note_> rawdata ownhouse variable *</_typehouse_note_>
*<_typehouse_note_> typehouse brought in from rawdata *</_typehouse_note_>
rename dweltyp typehouse
*</_typehouse_>

*<_ownhouse_>
*<_ownhouse_note_> SARMD ownhouse variable *</_ownhouse_note_>
*<_ownhouse_note_> ownhouse brought in from GMD *</_ownhouse_note_>
la def ownhouse 1 "Yes" 0 "No"
la val ownhouse ownhouse
*</_ownhouse_>

*<_water_orig_>
*<_water_orig_note_> Source of Drinking Water-Original from raw file *</_water_orig_note_>
*<_water_orig_note_> water_orig brought in from rawdata *</_water_orig_note_>
gen water_orig=hh_drkwater
note water_orig: Source of Drinking Water-Original from raw file
*</_water_orig_>


*<_improved_water_>
gen sar_improved_water=.
replace imp_wat_rec=1 if inlist(hh_drkwater,1,2,3,5,6,7)
replace imp_wat_rec=0 if inlist(hh_drkwater,4)
*</_improved_water_>

*<_improved_water_>
gen improved_water=sar_improved_water
*</_improved_water_>

*<_water_source_>
*<_water_source_note_> Sources of drinking water *</_water_source_note_>
*<_water_source_note_> water_source brought in from rawdata *</_water_source_note_>
/*
gen water_source=.
replace water_source=1  if hh_drkwater==1
replace water_source=3  if hh_drkwater==2
replace water_source=5  if hh_drkwater==3
replace water_source=10 if hh_drkwater==4
replace water_source=8  if hh_drkwater==5 | hh_drkwater==6
replace water_source=7  if hh_drkwater==7
replace water_source=14 if hh_drkwater==-96
note water_source: Sources of drinking water
*/
*</_water_source_>

*<_piped_water_>
*<_piped_water_note_> Household has access to piped water *</_piped_water_note_>
*<_piped_water_note_> piped_water brought in from rawdata *</_piped_water_note_>
gen piped_water = 1 if inlist(water_source,1,2,3)
replace piped_water = 0 if water_source != . & piped_water == .
*</_piped_water_>

*<_water_jmp_>
*<_water_jmp_note_> Source of drinking water-using Joint Monitoring Program categories *</_water_jmp_note_>
*<_water_jmp_note_> water_jmp brought in from rawdata *</_water_jmp_note_>
gen water_jmp=hh_drkwater
note water_jmp: Source of drinking water-using Joint Monitoring Program categories
*</_water_jmp_>

*<_sewage_toilet_>
*<_sewage_toilet_note_> Household has access to sewage toilet *</_sewage_toilet_note_>
*<_sewage_toilet_note_> sewage_toilet brought in from rawdata *</_sewage_toilet_note_>
gen sewage_toilet=(hh_sewer_typ==1)
note sewage_toilet: Household has access to sewage toilet
*</_sewage_toilet_>

*<_toilet_orig_>
*<_toilet_orig_note_> sanitation facility original *</_toilet_orig_note_>
*<_toilet_orig_note_> toilet_orig brought in from rawdata *</_toilet_orig_note_>
gen toilet_orig=hh_sewer_typ
note toilet_orig: sanitation facility original
*</_toilet_orig_>

*<_sar_improved_toilet_>
*<_sar_improved_toilet_note_> Improved type of sanitation facility-using country-specific definitions *</_sar_improved_toilet_note_>
*<_sar_improved_toilet_note_> sar_improved_toilet brought in from rawdata *</_sar_improved_toilet_note_>
gen sar_improved_toilet=.
replace sar_improved_toilet=1 if inlist(hh_sewer_typ,1,3)
replace sar_improved_toilet=0 if inlist(hh_sewer_typ,2,4)
replace sar_improved_toilet=1 if Male==1
*</_sar_improved_toilet_>

*<_improved_sanitation_>
gen improved_sanitation=sar_improved_toilet
*</_improved_sanitation_>

*<_toilet_jmp_>
*<_toilet_jmp_note_> Access to sanitation facility-using Joint Monitoring Program categories *</_toilet_jmp_note_>
*<_toilet_jmp_note_> toilet_jmp brought in from rawdata *</_toilet_jmp_note_>
gen toilet_jmp=.
*</_toilet_jmp_>

*<_sewage_toilet_>
*<_sewage_toilet_note_> Household has access to sewage toilet *</_sewage_toilet_note_>
*<_sewage_toilet_note_> sewage_toilet brought in from rawdata *</_sewage_toilet_note_>
cap gen sewage_toilet=.
*</_sewage_toilet_>

*<_electricity_>
*<_electricity_note_> Access to electricity in dwelling *</_electricity_note_>
*<_electricity_note_> electricity brought in from rawdata *</_electricity_note_>
cap gen byte electricity=.
*</_electricity_>

*<_lphone_>
*<_lphone_note_> Household has landphone *</_lphone_note_>
*<_lphone_note_> lphone brought in from rawdata *</_lphone_note_>
rename landphone lphone
*</_lphone_>

*<_cellphone_>;
*<_cellphone_note_> Ownership of a cell phone (household) *</_cellphone_note_>
*<_cellphone_note_> cellphone brought in from rawdata *</_cellphone_note_>
cap gen cellphone=Mobile
replace cellphone=0 if Mobile==2
replace cellphone=. if cellphone==.a
note cellphone: Ownership of a cell phone (household)
*</_cellphone_>


*<_computer_>
*<_computer_note_> Ownership of a computer *</_computer_note_>
*<_computer_note_> computer brought in from rawdata *</_computer_note_>
cap gen computer=LaptopComp
replace computer=0 if LaptopComp==2
replace computer=. if computer==.a
note computer: Ownership of a computer, either desktop or laptop
*</_computer_>

*<_etablet_>
*<_etablet_note_> Ownership of a electronic tablet *</_etablet_note_>
*<_etablet_note_> etablet brought in from rawdata *</_etablet_note_>
cap gen etablet=Tabletipad
replace etablet=0 if Tabletipad==2
note etablet: Ownership of an electronic tablet
*</_etablet_>

*<_internet_>
*<_internet_note_> Ownership of a  internet *</_internet_note_>
*<_internet_note_> internet brought in from rawdata *</_internet_note_>
cap gen internet=.
replace internet=3 if other_bills_exp__8310001==1
*</_internet_>

*<_internet_mobile_>
*<_internet_mobile_note_> Ownership of a  internet (mobile 2G 3G LTE 4G 5G ) *</_internet_mobile_note_>
*<_internet_mobile_note_> internet_mobile brought in from rawdata *</_internet_mobile_note_>
cap gen internet_mobile=.
note internet_mobile: N/A
*</_internet_mobile_>

*<_internet_mobile4G_>
*<_internet_mobile4G_note_> Ownership of a  internet (mobile LTE 4G 5G ) *</_internet_mobile4G_note_>
*<_internet_mobile4G_note_> internet_mobile4G brought in from rawdata *</_internet_mobile4G_note_>
cap gen internet_mobile4G=.
note internet_mobile4G: N/A
*</_internet_mobile4G_>

*<_elec_acc_>
*<_elec_acc_note_> Connection to electricity in dwelling *</_elec_acc_note_>
*<_elec_acc_note_> elec_acc brought in from rawdata *</_elec_acc_note_>
cap gen elec_acc=.
note elec_acc: N/A
*</_elec_acc_>

/*****************************************************************************************************
*                                                                                                    *
                                   DEMOGRAPHIC MODULE
*                                                                                                    *
*****************************************************************************************************/
**POPULATION WEIGHT
*<_pop_wgt_>
gen pop_wgt=wgt*hsize
*</_pop_wgt_>

*<_age_>
*<_age_note_> Age of individual (continuous) *</_age_note_>
*<_age_note_> age brought in from GMD *</_age_note_>
sum age
*</_age_>

*<_soc_>
*<_soc_note_> Social group *</_soc_note_>
*<_soc_note_> soc brought in from rawdata *</_soc_note_>
gen soc=.
note soc: N/A
*</_soc_>

*<_marital_>
*<_marital_note_> Marital status *</_marital_note_>
*<_marital_note_> marital brought in from rawdata *</_marital_note_>
cap gen byte marital=marital_status
		recode marital (1=2) (2=1) (3=5) (4/5=4)
*</_marital_>


*<_rbirth_juris_>
*<_rbirth_juris_note_> Region of Birth Jurisdiction *</_rbirth_juris_note_>
*<_rbirth_juris_note_> rbirth_juris brought in from rawdata *</_rbirth_juris_note_>
rename placebirth_at*d rbirth_juris
replace rbirth_juris=placebirth_OtherCountry if placeofbirth==3  
label copy placebirth_atlIsd rbirth_juris
label define rbirth_juris 100 `"Africa"', modify
label define rbirth_juris 101 `"Algeria"', modify
label define rbirth_juris 102 `"Angola"', modify
label define rbirth_juris 103 `"Benin"', modify
label define rbirth_juris 104 `"Botswana"', modify
label define rbirth_juris 105 `"Burkina Faso"', modify
label define rbirth_juris 106 `"Burundi"', modify
label define rbirth_juris 107 `"Cameroon"', modify
label define rbirth_juris 108 `"Cape Verde"', modify
label define rbirth_juris 109 `"Central African Republic"', modify
label define rbirth_juris 110 `"Chad"', modify
label define rbirth_juris 111 `"Comoros"', modify
label define rbirth_juris 112 `"Congo"', modify
label define rbirth_juris 113 `"Cote d' Ivoire"', modify
label define rbirth_juris 114 `"Democratic Republic of the Congo"', modify
label define rbirth_juris 115 `"Djibouti"', modify
label define rbirth_juris 116 `"Egypt"', modify
label define rbirth_juris 117 `"Equatorial Guinea"', modify
label define rbirth_juris 118 `"Eritrea"', modify
label define rbirth_juris 119 `"Ethiopia"', modify
label define rbirth_juris 120 `"Gabon"', modify
label define rbirth_juris 121 `"Gambia"', modify
label define rbirth_juris 122 `"Ghana"', modify
label define rbirth_juris 123 `"Guinea"', modify
label define rbirth_juris 124 `"Guinea-Bissau"', modify
label define rbirth_juris 125 `"Kenya"', modify
label define rbirth_juris 126 `"Lesotho"', modify
label define rbirth_juris 127 `"Liberia"', modify
label define rbirth_juris 128 `"Libyan Arab Jamahiriya"', modify
label define rbirth_juris 129 `"Madagascar"', modify
label define rbirth_juris 130 `"Malawi"', modify
label define rbirth_juris 131 `"Mali"', modify
label define rbirth_juris 132 `"Mauritania"', modify
label define rbirth_juris 133 `"Mauritius"', modify
label define rbirth_juris 134 `"Morocco"', modify
label define rbirth_juris 135 `"Mozambiqui"', modify
label define rbirth_juris 136 `"Nambia"', modify
label define rbirth_juris 137 `"Niger"', modify
label define rbirth_juris 138 `"Nigeria"', modify
label define rbirth_juris 139 `"Reuinon"', modify
label define rbirth_juris 140 `"Rwanda"', modify
label define rbirth_juris 141 `"Saint Helena"', modify
label define rbirth_juris 142 `"Sao Tome and Principe"', modify
label define rbirth_juris 143 `"Senegal"', modify
label define rbirth_juris 144 `"Seychelles"', modify
label define rbirth_juris 145 `"Sierra Leone"', modify
label define rbirth_juris 146 `"Somalia"', modify
label define rbirth_juris 147 `"South Africa"', modify
label define rbirth_juris 148 `"Sudan"', modify
label define rbirth_juris 149 `"Swaziland"', modify
label define rbirth_juris 150 `"Togo"', modify
label define rbirth_juris 151 `"Tunisia"', modify
label define rbirth_juris 152 `"Uganda"', modify
label define rbirth_juris 153 `"United Republic of Tanzania"', modify
label define rbirth_juris 154 `"Westernm Sahara"', modify
label define rbirth_juris 155 `"Zambia"', modify
label define rbirth_juris 156 `"Zimbabwe"', modify
label define rbirth_juris 200 `"Asia"', modify
label define rbirth_juris 201 `"Afghanistan"', modify
label define rbirth_juris 202 `"Armenia"', modify
label define rbirth_juris 203 `"Azerbaijan"', modify
label define rbirth_juris 204 `"Bahrain"', modify
label define rbirth_juris 205 `"Bangladhesh"', modify
label define rbirth_juris 206 `"Bhutan"', modify
label define rbirth_juris 207 `"Brunei Darussalam"', modify
label define rbirth_juris 208 `"Cambodia"', modify
label define rbirth_juris 209 `"China"', modify
label define rbirth_juris 210 `"China, Hong Kong SAR"', modify
label define rbirth_juris 211 `"Cyprus"', modify
label define rbirth_juris 212 `"Dem. People's Rep. Of Korea"', modify
label define rbirth_juris 213 `"East Timor"', modify
label define rbirth_juris 214 `"Gaza Strip"', modify
label define rbirth_juris 215 `"Georgia"', modify
label define rbirth_juris 216 `"India"', modify
label define rbirth_juris 217 `"Indonesia"', modify
label define rbirth_juris 218 `"Iran(Islamic Rep. Of )"', modify
label define rbirth_juris 219 `"Iraq"', modify
label define rbirth_juris 220 `"Israel"', modify
label define rbirth_juris 221 `"Japan"', modify
label define rbirth_juris 222 `"Jordon"', modify
label define rbirth_juris 223 `"Kazakhstan"', modify
label define rbirth_juris 224 `"Kuwait"', modify
label define rbirth_juris 225 `"Kyrgyzstan"', modify
label define rbirth_juris 226 `"Lao People's Democratic Republic"', modify
label define rbirth_juris 227 `"Lebonan"', modify
label define rbirth_juris 228 `"Macau"', modify
label define rbirth_juris 229 `"Malaysia"', modify
label define rbirth_juris 230 `"Mongolia"', modify
label define rbirth_juris 231 `"Myanmar"', modify
label define rbirth_juris 232 `"Nepal"', modify
label define rbirth_juris 233 `"Oman"', modify
label define rbirth_juris 234 `"Pakistan"', modify
label define rbirth_juris 235 `"Philippines"', modify
label define rbirth_juris 236 `"Qatar"', modify
label define rbirth_juris 237 `"Republic of Korea"', modify
label define rbirth_juris 238 `"Saudi Arabia"', modify
label define rbirth_juris 239 `"Singapore"', modify
label define rbirth_juris 240 `"Sri Lanka"', modify
label define rbirth_juris 241 `"Syrian Arab Republic"', modify
label define rbirth_juris 242 `"Tajikistan"', modify
label define rbirth_juris 243 `"Thailand"', modify
label define rbirth_juris 244 `"Trukmenistan"', modify
label define rbirth_juris 245 `"Turkey"', modify
label define rbirth_juris 246 `"United Arab Emirates"', modify
label define rbirth_juris 247 `"Uzbekistan"', modify
label define rbirth_juris 248 `"Viet Nam"', modify
label define rbirth_juris 249 `"Yemen"', modify
label define rbirth_juris 300 `"Europe"', modify
label define rbirth_juris 301 `"Albania"', modify
label define rbirth_juris 302 `"Andorra"', modify
label define rbirth_juris 303 `"Austria"', modify
label define rbirth_juris 304 `"Belarus"', modify
label define rbirth_juris 305 `"Belgium"', modify
label define rbirth_juris 306 `"Bosnia and Herzegovina"', modify
label define rbirth_juris 307 `"Bulgaria"', modify
label define rbirth_juris 308 `"Channel Islands"', modify
label define rbirth_juris 309 `"Croatia"', modify
label define rbirth_juris 310 `"Czech Republic"', modify
label define rbirth_juris 311 `"Denmark"', modify
label define rbirth_juris 312 `"Estonia"', modify
label define rbirth_juris 313 `"Faeroe Islands"', modify
label define rbirth_juris 314 `"Finland"', modify
label define rbirth_juris 315 `"France"', modify
label define rbirth_juris 316 `"Germany"', modify
label define rbirth_juris 317 `"Gibraltar"', modify
label define rbirth_juris 318 `"Greece"', modify
label define rbirth_juris 319 `"Holy See"', modify
label define rbirth_juris 320 `"Hungary"', modify
label define rbirth_juris 321 `"Iceland"', modify
label define rbirth_juris 322 `"Ireland"', modify
label define rbirth_juris 323 `"Isle of Man"', modify
label define rbirth_juris 324 `"Italy"', modify
label define rbirth_juris 325 `"Latvia"', modify
label define rbirth_juris 326 `"Liechtenstein"', modify
label define rbirth_juris 327 `"Lithuania"', modify
label define rbirth_juris 328 `"Luxembourg"', modify
label define rbirth_juris 329 `"Malta"', modify
label define rbirth_juris 330 `"Monaco"', modify
label define rbirth_juris 331 `"Netherland"', modify
label define rbirth_juris 332 `"Norway"', modify
label define rbirth_juris 333 `"Poland"', modify
label define rbirth_juris 334 `"Portugal"', modify
label define rbirth_juris 335 `"Republic of Moldova"', modify
label define rbirth_juris 336 `"Rumania"', modify
label define rbirth_juris 337 `"Russian Federation"', modify
label define rbirth_juris 338 `"San Marino"', modify
label define rbirth_juris 339 `"Slovakia"', modify
label define rbirth_juris 340 `"Slovena"', modify
label define rbirth_juris 341 `"Spain"', modify
label define rbirth_juris 342 `"Sweden"', modify
label define rbirth_juris 343 `"Switzerland"', modify
label define rbirth_juris 344 `"TFYR Macedonia"', modify
label define rbirth_juris 345 `"Ukraine"', modify
label define rbirth_juris 346 `"United Kingdom"', modify
label define rbirth_juris 347 `"Yugoslavia"', modify
label define rbirth_juris 400 `"America"', modify
label define rbirth_juris 401 `"Anguilla"', modify
label define rbirth_juris 402 `"Antigua and Barbuda"', modify
label define rbirth_juris 403 `"Argentina"', modify
label define rbirth_juris 404 `"Aruba"', modify
label define rbirth_juris 405 `"Bahamas"', modify
label define rbirth_juris 406 `"Barbados"', modify
label define rbirth_juris 407 `"Belize"', modify
label define rbirth_juris 408 `"Bermuda"', modify
label define rbirth_juris 409 `"Bolivia"', modify
label define rbirth_juris 410 `"Brazil"', modify
label define rbirth_juris 411 `"British Virgin Islands"', modify
label define rbirth_juris 412 `"Canada"', modify
label define rbirth_juris 413 `"Cayman Islands"', modify
label define rbirth_juris 414 `"Chile"', modify
label define rbirth_juris 415 `"Colombia"', modify
label define rbirth_juris 416 `"Cost Rica"', modify
label define rbirth_juris 417 `"Cuba"', modify
label define rbirth_juris 418 `"Dominica"', modify
label define rbirth_juris 419 `"Dominican Republic"', modify
label define rbirth_juris 420 `"Ecuador"', modify
label define rbirth_juris 421 `"El Salvador"', modify
label define rbirth_juris 422 `"Falkland Islands"', modify
label define rbirth_juris 423 `"French Guiana"', modify
label define rbirth_juris 424 `"Greenland"', modify
label define rbirth_juris 425 `"Grenada"', modify
label define rbirth_juris 426 `"Guadeloupe"', modify
label define rbirth_juris 427 `"Guatemala"', modify
label define rbirth_juris 428 `"Guyana"', modify
label define rbirth_juris 429 `"Haiti"', modify
label define rbirth_juris 430 `"Honduras"', modify
label define rbirth_juris 431 `"Jamaica"', modify
label define rbirth_juris 432 `"Martinique"', modify
label define rbirth_juris 433 `"Mexico"', modify
label define rbirth_juris 434 `"Montserrat"', modify
label define rbirth_juris 435 `"Netherland and Antilles"', modify
label define rbirth_juris 436 `"Nicaragua"', modify
label define rbirth_juris 437 `"Paraguay"', modify
label define rbirth_juris 438 `"Penema"', modify
label define rbirth_juris 439 `"Peru"', modify
label define rbirth_juris 440 `"Puerto Rico"', modify
label define rbirth_juris 441 `"Saint Kitts and Nevis"', modify
label define rbirth_juris 442 `"Saint Lucia"', modify
label define rbirth_juris 443 `"St. Pierre and Miquelon"', modify
label define rbirth_juris 444 `"St. Vicent and the Greanadines"', modify
label define rbirth_juris 445 `"Suriname"', modify
label define rbirth_juris 446 `"Trinidad and Tobago"', modify
label define rbirth_juris 447 `"Turks and Caicos Islands"', modify
label define rbirth_juris 448 `"United States of America"', modify
label define rbirth_juris 449 `"United States Virgin Islands"', modify
label define rbirth_juris 450 `"Uruguay"', modify
label define rbirth_juris 451 `"Venezuela"', modify
label define rbirth_juris 500 `"Oceania"', modify
label define rbirth_juris 501 `"American Samoa"', modify
label define rbirth_juris 502 `"Australia"', modify
label define rbirth_juris 503 `"Cook Lands"', modify
label define rbirth_juris 504 `"Fiji"', modify
label define rbirth_juris 505 `"French Polynesia"', modify
label define rbirth_juris 506 `"Guam"', modify
label define rbirth_juris 507 `"Kiribati"', modify
label define rbirth_juris 508 `"Marshall Islands"', modify
label define rbirth_juris 509 `"Micronesia (Federated State of )"', modify
label define rbirth_juris 510 `"Nauru"', modify
label define rbirth_juris 511 `"New Caledonia"', modify
label define rbirth_juris 512 `"New Zealand"', modify
label define rbirth_juris 513 `"Niue"', modify
label define rbirth_juris 514 `"Northern Mariana Islands"', modify
label define rbirth_juris 515 `"Palau"', modify
label define rbirth_juris 516 `"Papua New Guinea"', modify
label define rbirth_juris 517 `"Pitcairn"', modify
label define rbirth_juris 518 `"Samoa"', modify
label define rbirth_juris 519 `"Solomon Islands"', modify
label define rbirth_juris 520 `"Tokelau"', modify
label define rbirth_juris 521 `"Tonga"', modify
label define rbirth_juris 522 `"Tuvalu"', modify
label define rbirth_juris 523 `"Vanuatu"', modify
label define rbirth_juris 524 `"Wallis and Funtuna Islands"', modify
label define rbirth_juris 9999 `"Not Stated"', modify
la val rbirth_juris rbirth_juris
*</_rbirth_juris_>

*<_rbirth_>
*<_rbirth_note_> Region of Birth *</_rbirth_note_>
*<_rbirth_note_> rbirth brought in from rawdata *</_rbirth_note_>
rename placeofbirth rbirth
*</_rbirth_>

*<_rprevious_juris_>
*<_rprevious_juris_note_> Region of previous residence *</_rprevious_juris_note_>
*<_rprevious_juris_note_> rprevious_juris brought in from rawdata *</_rprevious_juris_note_>
rename prevresidence*l rprevious_juris
note rprevious_juris: previous atoll of residence
*</_rprevious_juris_>

*<_rprevious_>
*<_rprevious_note_> Region Previous Residence *</_rprevious_note_>
*<_rprevious_note_> rprevious brought in from rawdata *</_rprevious_note_>
rename prevresidence*d rprevious
note rprevious: previous island of residence
*</_rprevious_>

*<_yrmove_>
*<_yrmove_note_> Year of most recent move *</_yrmove_note_>
*<_yrmove_note_> yrmove brought in from rawdata *</_yrmove_note_>
rename YrMoveFrmPrev*s yrmove
*</_yrmove_>

/*****************************************************************************************************
*                                                                                                    *
                                   EDUCATION MODULE
*                                                                                                    *
*****************************************************************************************************/

*<_atschool_>
*<_atschool_note_> Attending school *</_atschool_note_>
*<_atschool_note_> atschool brought in from rawdata *</_atschool_note_>
rename school atschool
*</_atschool_>

*<_ed_mod_age_>
*<_ed_mod_age_note_> Education module application age *</_ed_mod_age_note_>
*<_ed_mod_age_note_> ed_mod_age brought in from rawdata *</_ed_mod_age_note_>
gen ed_mod_age=5
*</_ed_mod_age_>

*<_everattend_>
*<_everattend_note_> Ever attended school *</_everattend_note_>
*<_everattend_note_> everattend brought in from rawdata *</_everattend_note_>
rename edu_everattend everattend
*</_everattend_>


/*****************************************************************************************************
*                                                                                                    *
                                   LABOR MODULE
*                                                                                                    *
*****************************************************************************************************/


*<_industry_>
*<_industry_note_> 1 digit industry classification *</_industry_note_>
*<_industry_note_> industry brought in from GMD *</_industry_note_>
rename industrycat10 industry
*</_industry_>

*<_industry_orig_>
*<_industry_orig_note_> original industry codes second job *</_industry_orig_note_>
*<_industry_orig_note_> industry_orig brought in from GMD *</_industry_orig_note_>
tab industry_orig 
*</_industry_orig_>

*<_lb_mod_age_>
*<_lb_mod_age_note_> Labor module application age *</_lb_mod_age_note_>
*<_lb_mod_age_note_> lb_mod_age brought in from rawdata *</_lb_mod_age_note_>
gen lb_mod_age=15
*</_lb_mod_age_>

*<_wage_>
*<_wage_note_> Last wage payment *</_wage_note_>
*<_wage_note_> wage brought in from rawdata *</_wage_note_>
gen wage=wage_nc
*</_wage_>

*<_industry_2_>
*<_industry_2_note_> 1 digit industry classification - second job *</_industry_2_note_>
*<_industry_2_note_> industry_2 brought in from GMD *</_industry_2_note_>
rename industrycat10_2 industry_2
*</_industry_2_>

*<_industry_orig_2_>
*<_industry_orig_2_note_> original industry codes second job *</_industry_orig_2_note_>
*<_industry_orig_2_note_> industry_orig_2 brought in from GMD *</_industry_orig_2_note_>
tab industry_orig_2
*</_industry_orig_2_>

*<_wage_2_>
*<_wage_2_note_> Last wage payment second job *</_wage_2_note_>
*<_wage_2_note_> wage_2 brought in from rawdata *</_wage_2_note_>
gen wage_2=wage_nc_2
*</_wage_2_>


/*****************************************************************************************************
*                                                                                                    *
                                            ASSETS 
*                                                                                                    *
*****************************************************************************************************/
*<_buffalo_>
*<_buffalo_note_> Household has buffalo *</_buffalo_note_>
*<_buffalo_note_> buffalo brought in from rawdata *</_buffalo_note_>
gen buffalo=.
*</_buffalo_>

*<_bicycle_>
*<_bicycle_note_> Household has bicycle *</_bicycle_note_>
*<_bicycle_note_> bicycle brought in from GMD *</_bicycle_note_>
rename bcycle bicycle
*</_bicycle_>

*<_chicken_>
*<_chicken_note_> Household has chicken *</_chicken_note_>
*<_chicken_note_> chicken brought in from rawdata *</_chicken_note_>
gen chicken=.
*</_chicken_>

*<_cow_>
*<_cow_note_> Household has cow *</_cow_note_>
*<_cow_note_> cow brought in from rawdata *</_cow_note_>
gen cow=.
*</_cow_>

*<_lamp_>
*<_lamp_note_> Household has lamp *</_lamp_note_>
*<_lamp_note_> lamp brought in from rawdata *</_lamp_note_>
gen lamp=.
*</_lamp_>

*<_motorcar_>
*<_motorcar_note_> Household has motorcar *</_motorcar_note_>
*<_motorcar_note_> motorcar brought in from GMD *</_motorcar_note_>
rename car motorcar
*</_motorcar_>

*<_motorcycle_>
*<_motorcycle_note_> Household has motorcycle *</_motorcycle_note_>
*<_motorcycle_note_> motorcycle brought in from GMD *</_motorcycle_note_>
rename mcycle motorcycle
*</_motorcycle_>

*<_refrigerator_>
*<_refrigerator_note_> Household has refrigerator *</_refrigerator_note_>
*<_refrigerator_note_> refrigerator brought in from GMD *</_refrigerator_note_>
rename fridge refrigerator
*</_refrigerator_>

*<_sewingmachine_>
*<_sewingmachine_note_> Household has sewing machine *</_sewingmachine_note_>
*<_sewingmachine_note_> sewingmachine brought in from GMD *</_sewingmachine_note_>
rename sewmach sewingmachine
*</_sewingmachine_>

*<_television_>
*<_television_note_> Household has television *</_television_note_>
*<_television_note_> television brought in from GMD *</_television_note_>
rename tv television
*</_television_>

*<_washingmachine_>
*<_washingmachine_note_> Household has washing machine *</_washingmachine_note_>
*<_washingmachine_note_> washingmachine brought in from GMD *</_washingmachine_note_>
rename washmach  washingmachine
*</_washingmachine_>


/*****************************************************************************************************
*                                                                                                    *
                                   WELFARE MODULE
*                                                                                                    *
*****************************************************************************************************/
*<_welfarenat_>
*<_welfarenat_note_> Welfare aggregate for national poverty *</_welfarenat_note_>
*<_welfarenat_note_> welfarenat brought in from rawdata *</_welfarenat_note_>
gen welfarenat=pcer
note welfarenat: Real per capita expenditure, outliers imputed by components (MVR/person/year)
*</_welfarenat_>

*<_poor_int_>
*<_poor_int_note_> People below Poverty Line (International) *</_poor_int_note_>
*<_poor_int_note_> poor_int brought in from rawdata *</_poor_int_note_>
gen poor_int=.
*</_poor_int_>

*<_pline_int_>
*<_pline_int_note_> Poverty line Povcalnet *</_pline_int_note_>
*<_pline_int_note_> pline_int brought in from rawdata *</_pline_int_note_>
gen pline_int=.
*</_pline_int_>

gen food_share=(pcer_foodhome/pcer)*100

gen nfood_share=(pcer_nfnd/pcer)*100

*<_quintile_cons_aggregate_>
_ebin welfare [aw=weight], gen(quintile_cons_aggregate) nq(5)
*</_quintile_cons_aggregate_>

/*****************************************************************************************************
*                                                                                                    *
                                   NATIONAL POVERTY
*                                                                                                    *
*****************************************************************************************************/
*<_pline_nat_>
*<_pline_nat_note_> Poverty line naPoverty Line (National) *</_pline_nat_note_>
*<_pline_nat_note_> pline_nat brought in from rawdata *</_pline_nat_note_>
gen pline_nat=umicpl
note pline_nat: Poverty line base on Upper Middle Income Poverty Line
*</_pline_nat_>

*<_poor_nat_>
*<_poor_nat_note_> People below Poverty Line (National) *</_poor_nat_note_>
*<_poor_nat_note_> poor_nat brought in from rawdata *</_poor_nat_note_>
gen poor_nat=(pcer<umicpl)
note poor_nat: 1="Poor" 0="Not Poor"
*</_poor_nat_>

*<_Save data file_>
do "${rootdatalib}/`code'/`yearfolder'/`yearfolder'_v`vm'_M_v`va'_A_SARMD/Programs/Labels_SARMD.do"
save "$rootdatalib\\`code'\\`yearfolder'\\`gmdfolder'\Data\Harmonized\\`filename'.dta" , replace
*</_Save data file_>

exit 

*<_Keep variables_>
keep buffalo bicycle chicken cow fan lamp motorcar motorcycle radio refrigerator sewingmachine television washingmachine age hsize male marital relationcs relationharm soc atschool ed_mod_age educat4 educat5 educat7 educy everattend literacy cellphone computer electricity internet lphone ownhouse subnatid1 subnatid2 subnatid3 urban water_orig water_jmp piped* imp* toilet* sewage_toilet toilet_orig idh idp wgt strata psu int_month int_year wgt contract empstat firmsize_l healthins industry lb_mod_age lstatus njobs nlfreason occup ocusec socialsec unempldur_l unempldur_u union unitwage wage whours empstat_2 empstat_2_year industry_2 industry_orig_2 wage_2 unitwage_2 rbirth_juris rbirth rprevious_juris rprevious yrmove pline_nat poor_nat spdef welfare welfaredef welfarenat welfarenom welfareother welfareothertype welfaretype welfshprosperity cpi cpiperiod poor_int pline_int countrycode year survey vermast veralt hhid pid weight* cpi* ppp*
clonevar code=countrycode
order countrycode code year hhid pid weight weighttype
sort hhid pid 
*</_Keep variables_>

*<_Save data file_>
save "${rootdatalib}\\`code'\\`yearfolder'\\`gmdfolder'\Data\Harmonized\\`filename'.dta" , replace
*</_Save data file_>



