/*------------------------------------------------------------------------------
					GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   `code'_`year'_`survey'_v01_M_v01_A_GMD_GEO.do	</_Program name_>
<_Application_>    STATA 16.0	<_Application_>
<_Author(s)_>      jogreen@worldbank.org	</_Author(s)_>
<_Date created_>   05-25-2020	</_Date created_>
<_Date modified>   08-08-2021	</_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        AFG	</_Country_>
<_Survey Title_>   LCS	</_Survey Title_>
<_Survey Year_>    2019	</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:	08-08-2021
File:	AFG_2019_LCS_v01_M_v01_A_GMD_GEO.do
- First version
</_Version Control_>
------------------------------------------------------------------------------*/

*<_Program setup_>
clear all
set more off

local code         "AFG"
local year         "2019"
local survey       "LCS"
local vm           "01"
local va           "03"
local type         "SARMD"
global module       	"GEO"
local yearfolder    "`code'_`year'_`survey'"
local SARMDfolder    "`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'"
local filename      "`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'_${module}"
glo output          "${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'\\Data\Harmonized" 
*</_Program setup_>


* global path on Joe's computer
if ("`c(username)'"=="sunquat") {
	glo basepath "/Users/`c(username)'/Projects/WORLD BANK/2023 SAR QCHECK/SARDATABANK/WORKINGDATA/`code'/`yearfolder'"
	glo input "${basepath}/`yearfolder'_v`vm'_M"
	glo output "${basepath}/`yearfolder'_v`vm'_M_v`va'_A_SARMD/Data/Harmonized"
	
	* load and merge relevant data
	cd "${input}/Data/Stata"
	* IND data
	use "$output/`yearfolder'_v`vm'_M_v`va'_A_`type'_IND", clear
	clonevar hhid_orig=idh_org
	clonevar Mem_ID   =pid 
	* individual-level assebled data
	merge 1:m hhid_orig Mem_ID using "AFG_2019_LCS_M", nogen assert(match)
}
* global paths on WB computer
else {
	*<_Folder creation_>
	
	*</_Folder creation_>

	*<_Datalibweb request_>
	use "${rootdatalib}\\`code'\\`code'_`year'_`survey'\\`code'_`year'_`survey'_v`vm'_M\Data\Stata\\`code'_`year'_`survey'_M.dta", clear 
	
	preserve
	use "${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'\Data\Harmonized\\`yearfolder'_v`vm'_M_v`va'_A_`type'_IND.dta", clear
	clonevar hhid_orig=idh_org
	clonevar Mem_ID   =pid 
	tempfile SARMDIND
	save     `SARMDIND'	
	restore 
	merge m:1 hhid_orig Mem_ID using `SARMDIND', gen(m_IND)
	
}

*<_countrycode_>
*<_countrycode_note_> country code *</_countrycode_note_>
*<_countrycode_note_> countrycode brought in from rawdata *</_countrycode_note_>
*clonevar countrycode = "`code'"
*clonevar code = "`code'"
*</_countrycode_>

*<_year_>
*<_year_note_> Year *</_year_note_>
*<_year_note_> year brought in from rawdata *</_year_note_>
*clonevar year = `year'
*</_year_>

*<_hhid_>
*<_hhid_note_> Household identifier  *</_hhid_note_>
*<_hhid_note_> hhid brought in from rawdata *</_hhid_note_>
*clonevar hhid = hhid_orig
*</_hhid_>

*<_weight_>
*<_weight_note_> Household weight *</_weight_note_>
*<_weight_note_> weight brought in from rawdata *</_weight_note_>
clonevar weight = wgt
*</_weight_>

*<_weighttype_>
*<_weighttype_note_> Weight type (frequency, probability, analytical, importance) *</_weighttype_note_>
*<_weighttype_note_> weighttype brought in from rawdata *</_weighttype_note_>
*clonevar weighttype = "PW"
*</_weighttype_>

*<_subnatid1_>
*<_subnatid1_note_> Subnational ID - highest level *</_subnatid1_note_>
*<_subnatid1_note_> subnatid1 brought in from rawdata *</_subnatid1_note_>
*clonevar subnatid1=subnatid1
*</_subnatid1_>

*<_subnatid2_>
*<_subnatid2_note_> Subnational ID - second highest level *</_subnatid2_note_>
*<_subnatid2_note_> subnatid2 brought in from rawdata *</_subnatid2_note_>
*clonevar subnatid2=subnatid2
*</_subnatid2_>

*<_subnatid3_>
*<_subnatid3_note_> Subnational ID - third highest level *</_subnatid3_note_>
*<_subnatid3_note_> subnatid3 brought in from rawdata *</_subnatid3_note_>
*clonevar subnatid3=subnatid3
*</_subnatid3_>

*<_subnatid4_>
*<_subnatid4_note_> Subnational ID - lowest level *</_subnatid4_note_>
*<_subnatid4_note_> subnatid4 brought in from rawdata *</_subnatid4_note_>
*gen subnatid4 = ""
note subnatid4: The data is not representative below the subnatid2 level.
*</_subnatid4_>

*<_subnatidsurvey_>
*<_subnatidsurvey_note_> Survey representation of geographical units *</_subnatidsurvey_note_>
*<_subnatidsurvey_note_> subnatidsurvey brought in from rawdata *</_subnatidsurvey_note_>
gen subnatidsurvey=.
*</_subnatidsurvey_>

*<_strata_>
*<_strata_note_> Strata *</_strata_note_>
*<_strata_note_> strata brought in from rawdata *</_strata_note_>
*clonevar strata = strata
*</_strata_>

*<_psu_>
*<_psu_note_> PSU *</_psu_note_>
*<_psu_note_> psu brought in from rawdata *</_psu_note_>
*clonevar psu = psu
*</_psu_>

*<_subnatid1_prev_>
*<_subnatid1_prev_note_> Subnatid *</_subnatid1_prev_note_>
*<_subnatid1_prev_note_> subnatid1_prev brought in from rawdata *</_subnatid1_prev_note_>
gen subnatid1_prev=subnatid1
note subnatid1_prev: survey uses the same classifications as 2016.
*</_subnatid1_prev_>

*<_subnatid2_prev_>
*<_subnatid2_prev_note_> Subnatid *</_subnatid2_prev_note_>
*<_subnatid2_prev_note_> subnatid2_prev brought in from rawdata *</_subnatid2_prev_note_>
gen subnatid2_prev=subnatid2
note subnatid2_prev: survey uses the same classifications as  2016.
*</_subnatid2_prev_>

*<_subnatid3_prev_>
*<_subnatid3_prev_note_> Subnatid *</_subnatid3_prev_note_>
*<_subnatid3_prev_note_> subnatid3_prev brought in from rawdata *</_subnatid3_prev_note_>
gen subnatid3_prev=subnatid3
note subnatid3_prev: survey uses the same classifications as  2016.
*</_subnatid3_prev_>

*<_subnatid4_prev_>
*<_subnatid4_prev_note_> Subnatid *</_subnatid4_prev_note_>
*<_subnatid4_prev_note_> subnatid4_prev brought in from rawdata *</_subnatid4_prev_note_>
gen subnatid4_prev=""
note subnatid4_prev: survey uses the same classifications as 2016.
*</_subnatid4_prev_>

*<_gaul_adm1_code_>
*<_gaul_adm1_code_note_> Gaul Code *</_gaul_adm1_code_note_>
*<_gaul_adm1_code_note_> gaul_adm1_code brought in from rawdata *</_gaul_adm1_code_note_>
gen		gaul_adm1_code=284 if subnatid1=="1 - Kabul"
replace gaul_adm1_code=286 if subnatid1=="2 - Kapisa"
replace gaul_adm1_code=297 if subnatid1=="3 - Parwan"
replace gaul_adm1_code=302 if subnatid1=="4 - Wardak"
replace gaul_adm1_code=291 if subnatid1=="5 - Logar"
replace gaul_adm1_code=279 if subnatid1=="6 - Ghazni"
replace gaul_adm1_code=295 if subnatid1=="7 - Paktika"
replace gaul_adm1_code=296 if subnatid1=="8 - Paktya"
replace gaul_adm1_code=287 if subnatid1=="9 - Khost"
replace gaul_adm1_code=292 if subnatid1=="10 - Nangarhar"
replace gaul_adm1_code=288 if subnatid1=="11 - Kunarha"
replace gaul_adm1_code=290 if subnatid1=="12 - Laghman"
replace gaul_adm1_code=294 if subnatid1=="13 - Nuristan"
replace gaul_adm1_code=272 if subnatid1=="14 - Badakhshan"
replace gaul_adm1_code=300 if subnatid1=="15 - Takhar"
replace gaul_adm1_code=274 if subnatid1=="16 - Baghlan"
replace gaul_adm1_code=289 if subnatid1=="17 - Kunduz"
replace gaul_adm1_code=298 if subnatid1=="18 - Samangan"
replace gaul_adm1_code=275 if subnatid1=="19 - Balkh"
replace gaul_adm1_code=283 if subnatid1=="20 - Jawzjan"
replace gaul_adm1_code=299 if subnatid1=="21 - Sar-I-Poul"
replace gaul_adm1_code=278 if subnatid1=="22 - Faryab"
replace gaul_adm1_code=273 if subnatid1=="23 - Badghis"
replace gaul_adm1_code=282 if subnatid1=="24 - Hirat"
replace gaul_adm1_code=277 if subnatid1=="25 - Farah"
replace gaul_adm1_code=293 if subnatid1=="26 - Nimroz"
replace gaul_adm1_code=281 if subnatid1=="27 - Helmand"
replace gaul_adm1_code=285 if subnatid1=="28 - Kandahar"
replace gaul_adm1_code=303 if subnatid1=="29 - Zabul"
replace gaul_adm1_code=301 if subnatid1=="30 - Uruzgan"
replace gaul_adm1_code=280 if subnatid1=="31 - Ghor"
replace gaul_adm1_code=276 if subnatid1=="32 - Bamyan"
replace gaul_adm1_code=. if subnatid1=="33 - Panjsher"
replace gaul_adm1_code=. if subnatid1=="34 - Daikindi"
note gaul_adm1_code: Cannot find the code for subnatid1=="33 - Panjsher": Wikipedia says Panjshir became an independent province from neighboring Parwan Province in 2004. Perhaps the gaul codes are outdated.
note gaul_adm1_code: Cannot find the code for subnatid1=="34 - Daikindi". Wikipedia says Daykundi was established on March 28, 2004, when it was created from the isolated Hazara-dominated northern districts of neighboring Oruzgan province. Perhaps the gaul codes are outdated.
*</_gaul_adm1_code_>

*<_gaul_adm2_code_>
*<_gaul_adm2_code_note_> Gaul Code *</_gaul_adm2_code_note_>
*<_gaul_adm2_code_note_> gaul_adm2_code brought in from rawdata *</_gaul_adm2_code_note_>
gen		gaul_adm2_code = 3585 if q12==101
replace gaul_adm2_code = 3590 if q12==102
replace gaul_adm2_code = 3581 if q12==103
replace gaul_adm2_code = 3580 if q12==104
replace gaul_adm2_code = 3582 if q12==105
replace gaul_adm2_code = 3592 if q12==106
replace gaul_adm2_code = 3588 if q12==108
replace gaul_adm2_code = 3586 if q12==110
replace gaul_adm2_code = 3583 if q12==111
replace gaul_adm2_code = . if q12==112
replace gaul_adm2_code = 3591 if q12==114
replace gaul_adm2_code = 3593 if q12==115
replace gaul_adm2_code = 3610 if q12==201
replace gaul_adm2_code = . if q12==202
replace gaul_adm2_code = 3608 if q12==203
replace gaul_adm2_code = . if q12==204
replace gaul_adm2_code = 3611 if q12==205
replace gaul_adm2_code = 3713 if q12==301
replace gaul_adm2_code = 3712 if q12==302
replace gaul_adm2_code = 3722 if q12==303
replace gaul_adm2_code = . if q12==304
replace gaul_adm2_code = 3717 if q12==305
replace gaul_adm2_code = 3720 if q12==306
replace gaul_adm2_code = 3714 if q12==307
replace gaul_adm2_code = 3718 if q12==308
replace gaul_adm2_code = 3723 if q12==309
replace gaul_adm2_code = 3721 if q12==310
replace gaul_adm2_code = 3762 if q12==401
replace gaul_adm2_code = 3763 if q12==402
replace gaul_adm2_code = 3760 if q12==403
replace gaul_adm2_code = 3757 if q12==404
replace gaul_adm2_code = 3764 if q12==405
replace gaul_adm2_code = 3758 if q12==406
replace gaul_adm2_code = 3759 if q12==407
replace gaul_adm2_code = 3527 if q12==408
replace gaul_adm2_code = 3761 if q12==409
replace gaul_adm2_code = 3653 if q12==501
replace gaul_adm2_code = 3649 if q12==502
replace gaul_adm2_code = 3650 if q12==503
replace gaul_adm2_code = 3651 if q12==504
replace gaul_adm2_code = 3652 if q12==505
replace gaul_adm2_code = . if q12==506
replace gaul_adm2_code = 3662 if q12==601
replace gaul_adm2_code = . if q12==602
replace gaul_adm2_code = 3673 if q12==603
replace gaul_adm2_code = 3656 if q12==604
replace gaul_adm2_code = 3663 if q12==605
replace gaul_adm2_code = 3665 if q12==606
replace gaul_adm2_code = 3670 if q12==607
replace gaul_adm2_code = 3664 if q12==608
replace gaul_adm2_code = 3655 if q12==609
replace gaul_adm2_code = 3658 if q12==610
replace gaul_adm2_code = 3669 if q12==611
replace gaul_adm2_code = 3657 if q12==612
replace gaul_adm2_code = . if q12==613
replace gaul_adm2_code = 3660 if q12==614
replace gaul_adm2_code = 3654 if q12==615
replace gaul_adm2_code = 3672 if q12==616
replace gaul_adm2_code = 3667 if q12==617
replace gaul_adm2_code = 3666 if q12==618
replace gaul_adm2_code = 3659 if q12==622
replace gaul_adm2_code = 3647 if q12==701
replace gaul_adm2_code = 3648 if q12==702
replace gaul_adm2_code = 3645 if q12==703
replace gaul_adm2_code = 3644 if q12==704
replace gaul_adm2_code = 3646 if q12==705
replace gaul_adm2_code = . if q12==801
replace gaul_adm2_code = . if q12==802
replace gaul_adm2_code = . if q12==803
replace gaul_adm2_code = . if q12==804
replace gaul_adm2_code = . if q12==805
replace gaul_adm2_code = . if q12==806
replace gaul_adm2_code = . if q12==807
replace gaul_adm2_code = 3475 if q12==901
replace gaul_adm2_code = 3469 if q12==902
replace gaul_adm2_code = 3470 if q12==903
replace gaul_adm2_code = 3474 if q12==904
replace gaul_adm2_code = 3467 if q12==905
replace gaul_adm2_code = 3472 if q12==906
replace gaul_adm2_code = 3465 if q12==907
replace gaul_adm2_code = . if q12==908
replace gaul_adm2_code = . if q12==909
replace gaul_adm2_code = 3468 if q12==910
replace gaul_adm2_code = . if q12==912
replace gaul_adm2_code = 3473 if q12==913
replace gaul_adm2_code = . if q12==915
replace gaul_adm2_code = 3491 if q12==1001
replace gaul_adm2_code = 3493 if q12==1002
replace gaul_adm2_code = . if q12==1003
replace gaul_adm2_code = 3471 if q12==1004
replace gaul_adm2_code = 3495 if q12==1005
replace gaul_adm2_code = 3492 if q12==1006
replace gaul_adm2_code = 3494 if q12==1007
replace gaul_adm2_code = 3525 if q12==1101
replace gaul_adm2_code = . if q12==1102
replace gaul_adm2_code = . if q12==1103
replace gaul_adm2_code = . if q12==1104
replace gaul_adm2_code = 3523 if q12==1105
replace gaul_adm2_code = 3527 if q12==1106
replace gaul_adm2_code = 3521 if q12==1107
replace gaul_adm2_code = 3532 if q12==1110
replace gaul_adm2_code = 3533 if q12==1111
replace gaul_adm2_code = 3526 if q12==1112
replace gaul_adm2_code = 3528 if q12==1114
replace gaul_adm2_code = 3530 if q12==1115
replace gaul_adm2_code = 3529 if q12==1116
replace gaul_adm2_code = 3694 if q12==1201
replace gaul_adm2_code = 3689 if q12==1202
replace gaul_adm2_code = . if q12==1203
replace gaul_adm2_code = . if q12==1204
replace gaul_adm2_code = 3692 if q12==1205
replace gaul_adm2_code = 3691 if q12==1206
replace gaul_adm2_code = 3698 if q12==1207
replace gaul_adm2_code = 3688 if q12==1208
replace gaul_adm2_code = 3706 if q12==1209
replace gaul_adm2_code = 3693 if q12==1210
replace gaul_adm2_code = 3695 if q12==1211
replace gaul_adm2_code = 3699 if q12==1212
replace gaul_adm2_code = 3690 if q12==1213
replace gaul_adm2_code = 3685 if q12==1214
replace gaul_adm2_code = 3686 if q12==1216
replace gaul_adm2_code = 3696 if q12==1217
replace gaul_adm2_code = 3703 if q12==1301
replace gaul_adm2_code = . if q12==1302
replace gaul_adm2_code = 3704 if q12==1305
replace gaul_adm2_code = 3708 if q12==1306
replace gaul_adm2_code = 3705 if q12==1307
replace gaul_adm2_code = . if q12==1308
replace gaul_adm2_code = 3706 if q12==1309
replace gaul_adm2_code = 3701 if q12==1310
replace gaul_adm2_code = 3702 if q12==1311
replace gaul_adm2_code = 3616 if q12==1401
replace gaul_adm2_code = . if q12==1402
replace gaul_adm2_code = 3614 if q12==1403
replace gaul_adm2_code = 3623 if q12==1404
replace gaul_adm2_code = 3618 if q12==1405
replace gaul_adm2_code = 3619 if q12==1406
replace gaul_adm2_code = 3621 if q12==1407
replace gaul_adm2_code = . if q12==1408
replace gaul_adm2_code = 3613 if q12==1409
replace gaul_adm2_code = 3622 if q12==1411
replace gaul_adm2_code = . if q12==1412
replace gaul_adm2_code = 3615 if q12==1413
replace gaul_adm2_code = 3625 if q12==1501
replace gaul_adm2_code = 3631 if q12==1502
replace gaul_adm2_code = . if q12==1503
replace gaul_adm2_code = 3632 if q12==1504
replace gaul_adm2_code = 3636 if q12==1505
replace gaul_adm2_code = . if q12==1506
replace gaul_adm2_code = 3635 if q12==1507
replace gaul_adm2_code = 3626 if q12==1508
replace gaul_adm2_code = 3628 if q12==1509
replace gaul_adm2_code = 3630 if q12==1510
replace gaul_adm2_code = . if q12==1511
replace gaul_adm2_code = 3629 if q12==1512
replace gaul_adm2_code = 3627 if q12==1513
replace gaul_adm2_code = 3634 if q12==1514
replace gaul_adm2_code = 3633 if q12==1515
replace gaul_adm2_code = 3682 if q12==1601
replace gaul_adm2_code = 3684 if q12==1602
replace gaul_adm2_code = 3683 if q12==1603
replace gaul_adm2_code = . if q12==1604
replace gaul_adm2_code = . if q12==1605
replace gaul_adm2_code = 3680 if q12==1606
replace gaul_adm2_code = 3681 if q12==1607
replace gaul_adm2_code = 3679 if q12==1608
replace gaul_adm2_code = 3447 if q12==1701
replace gaul_adm2_code = . if q12==1702
replace gaul_adm2_code = . if q12==1704
replace gaul_adm2_code = . if q12==1705
replace gaul_adm2_code = 3445 if q12==1706
replace gaul_adm2_code = . if q12==1707
replace gaul_adm2_code = . if q12==1709
replace gaul_adm2_code = 3449 if q12==1710
replace gaul_adm2_code = . if q12==1711
replace gaul_adm2_code = . if q12==1712
replace gaul_adm2_code = 3454 if q12==1713
replace gaul_adm2_code = 3451 if q12==1715
replace gaul_adm2_code = . if q12==1716
replace gaul_adm2_code = . if q12==1717
replace gaul_adm2_code = . if q12==1718
replace gaul_adm2_code = 3448 if q12==1723
replace gaul_adm2_code = 3456 if q12==1728
replace gaul_adm2_code = 3744 if q12==1801
replace gaul_adm2_code = . if q12==1802
replace gaul_adm2_code = . if q12==1803
replace gaul_adm2_code = 3735 if q12==1804
replace gaul_adm2_code = 3737 if q12==1805
replace gaul_adm2_code = . if q12==1806
replace gaul_adm2_code = 3741 if q12==1807
replace gaul_adm2_code = 3739 if q12==1808
replace gaul_adm2_code = 3742 if q12==1809
replace gaul_adm2_code = 3743 if q12==1810
replace gaul_adm2_code = 3740 if q12==1811
replace gaul_adm2_code = . if q12==1812
replace gaul_adm2_code = 3745 if q12==1813
replace gaul_adm2_code = . if q12==1814
replace gaul_adm2_code = 3736 if q12==1816
replace gaul_adm2_code = 3746 if q12==1817
replace gaul_adm2_code = 3642 if q12==1901
replace gaul_adm2_code = 3639 if q12==1902
replace gaul_adm2_code = 3637 if q12==1903
replace gaul_adm2_code = 3641 if q12==1904
replace gaul_adm2_code = 3640 if q12==1905
replace gaul_adm2_code = 3638 if q12==1906
replace gaul_adm2_code = 3643 if q12==1907
replace gaul_adm2_code = 3724 if q12==2001
replace gaul_adm2_code = 3726 if q12==2002
replace gaul_adm2_code = 3727 if q12==2003
replace gaul_adm2_code = . if q12==2004
replace gaul_adm2_code = 3728 if q12==2005
replace gaul_adm2_code = . if q12==2006
replace gaul_adm2_code = . if q12==2007
replace gaul_adm2_code = 3487 if q12==2101
replace gaul_adm2_code = 3488 if q12==2102
replace gaul_adm2_code = 3482 if q12==2103
replace gaul_adm2_code = 3479 if q12==2104
replace gaul_adm2_code = 3486 if q12==2105
replace gaul_adm2_code = 3477 if q12==2106
replace gaul_adm2_code = 3489 if q12==2107
replace gaul_adm2_code = 3480 if q12==2108
replace gaul_adm2_code = 3481 if q12==2109
replace gaul_adm2_code = 3484 if q12==2110
replace gaul_adm2_code = 3478 if q12==2111
replace gaul_adm2_code = 3490 if q12==2112
replace gaul_adm2_code = 3483 if q12==2113
replace gaul_adm2_code = 3485 if q12==2114
replace gaul_adm2_code = 3732 if q12==2201
replace gaul_adm2_code = 3733 if q12==2202
replace gaul_adm2_code = 3730 if q12==2203
replace gaul_adm2_code = 3734 if q12==2204
replace gaul_adm2_code = 3731 if q12==2205
replace gaul_adm2_code = . if q12==2206
replace gaul_adm2_code = 3729 if q12==2207
replace gaul_adm2_code = 3535 if q12==2301
replace gaul_adm2_code = . if q12==2302
replace gaul_adm2_code = . if q12==2303
replace gaul_adm2_code = 3537 if q12==2305
replace gaul_adm2_code = 3539 if q12==2306
replace gaul_adm2_code = 3536 if q12==2307
replace gaul_adm2_code = 3540 if q12==2308
replace gaul_adm2_code = 3541 if q12==2309
replace gaul_adm2_code = 3538 if q12==2310
replace gaul_adm2_code = . if q12==2401
replace gaul_adm2_code = . if q12==2402
replace gaul_adm2_code = . if q12==2404
replace gaul_adm2_code = . if q12==2405
replace gaul_adm2_code = . if q12==2406
replace gaul_adm2_code = . if q12==2407
replace gaul_adm2_code = . if q12==2408
replace gaul_adm2_code = . if q12==2409
replace gaul_adm2_code = 3756 if q12==2501
replace gaul_adm2_code = 3749 if q12==2502
replace gaul_adm2_code = 3747 if q12==2503
replace gaul_adm2_code = 3754 if q12==2504
replace gaul_adm2_code = 3751 if q12==2505
replace gaul_adm2_code = 3750 if q12==2506
replace gaul_adm2_code = 3769 if q12==2601
replace gaul_adm2_code = 3773 if q12==2602
replace gaul_adm2_code = 3772 if q12==2603
replace gaul_adm2_code = 3768 if q12==2604
replace gaul_adm2_code = 3765 if q12==2605
replace gaul_adm2_code = 3770 if q12==2606
replace gaul_adm2_code = 3767 if q12==2607
replace gaul_adm2_code = 3766 if q12==2608
replace gaul_adm2_code = 3771 if q12==2610
replace gaul_adm2_code = 3598 if q12==2701
replace gaul_adm2_code = 3594 if q12==2702
replace gaul_adm2_code = 3596 if q12==2703
replace gaul_adm2_code = 3602 if q12==2704
replace gaul_adm2_code = . if q12==2705
replace gaul_adm2_code = 3595 if q12==2708
replace gaul_adm2_code = 3601 if q12==2710
replace gaul_adm2_code = 3606 if q12==2711
replace gaul_adm2_code = 3579 if q12==2801
replace gaul_adm2_code = 3575 if q12==2802
replace gaul_adm2_code = . if q12==2803
replace gaul_adm2_code = 3577 if q12==2804
replace gaul_adm2_code = . if q12==2805
replace gaul_adm2_code = 3574 if q12==2806
replace gaul_adm2_code = . if q12==2807
replace gaul_adm2_code = 3573 if q12==2808
replace gaul_adm2_code = 3576 if q12==2809
replace gaul_adm2_code = 3578 if q12==2810
replace gaul_adm2_code = 3514 if q12==2901
replace gaul_adm2_code = 3515 if q12==2902
replace gaul_adm2_code = 3512 if q12==2903
replace gaul_adm2_code = 3509 if q12==2905
replace gaul_adm2_code = 3517 if q12==2907
replace gaul_adm2_code = 3508 if q12==2913
replace gaul_adm2_code = 3511 if q12==2914
replace gaul_adm2_code = 3546 if q12==3001
replace gaul_adm2_code = 3548 if q12==3002
replace gaul_adm2_code = 3551 if q12==3003
replace gaul_adm2_code = 3549 if q12==3004
replace gaul_adm2_code = 3544 if q12==3006
replace gaul_adm2_code = 3550 if q12==3007
replace gaul_adm2_code = 3464 if q12==3101
replace gaul_adm2_code = 3458 if q12==3102
replace gaul_adm2_code = 3461 if q12==3103
replace gaul_adm2_code = 3463 if q12==3104
replace gaul_adm2_code = 3462 if q12==3105
replace gaul_adm2_code = 3459 if q12==3107
replace gaul_adm2_code = 3561 if q12==3201
replace gaul_adm2_code = 3562 if q12==3202
replace gaul_adm2_code = 3560 if q12==3203
replace gaul_adm2_code = 3563 if q12==3204
replace gaul_adm2_code = 3570 if q12==3205
replace gaul_adm2_code = 3568 if q12==3206
replace gaul_adm2_code = 3565 if q12==3207
replace gaul_adm2_code = 3555 if q12==3209
replace gaul_adm2_code = 3566 if q12==3210
replace gaul_adm2_code = 3558 if q12==3211
replace gaul_adm2_code = 3567 if q12==3212
replace gaul_adm2_code = 3564 if q12==3213
replace gaul_adm2_code = 3499 if q12==3301
replace gaul_adm2_code = 3504 if q12==3302
replace gaul_adm2_code = 3501 if q12==3303
replace gaul_adm2_code = 3505 if q12==3304
replace gaul_adm2_code = 3506 if q12==3305
replace gaul_adm2_code = 3498 if q12==3306
replace gaul_adm2_code = 3496 if q12==3307
replace gaul_adm2_code = 3497 if q12==3308
replace gaul_adm2_code = 3502 if q12==3309
replace gaul_adm2_code = 3500 if q12==3310
replace gaul_adm2_code = 3503 if q12==3311
replace gaul_adm2_code = 3678 if q12==3401
replace gaul_adm2_code = 3676 if q12==3402
replace gaul_adm2_code = 3675 if q12==3403
replace gaul_adm2_code = 3674 if q12==3404
replace gaul_adm2_code = 3677 if q12==3405

note gaul_adm2_code: Cannot find code for q12 "District name" = 112 "FARZA". It is in the Kabul province, but there are no similar wb_adm2_na matches.
note gaul_adm2_code: Cannot find code for q12 "District name" = 202 "HISSA-E- DUWUMI KOHISTAN" or 204 "HISSA-E-AWALI KOHISTAN". They are in the Kapisa province, but there is only a single wb_adm2_na match (Kohistan, wb_adm2_co = 3609).
note gaul_adm2_code: Cannot find code for q12 "District name" = 304 "SAYID KHAIL". It is in the Parwan province, but there are no similar wb_adm2_na matches.
note gaul_adm2_code: Cannot find code for q12 "District name" = 506 "KHAR WAR". It is in the Logar province, but there are no similar wb_adm2_na matches.
note gaul_adm2_code: Cannot find codes for q12 "District name" = 602 "BEHSUD", or 613 "KOT". It is in the Nangarhar province, but there are no similar wb_adm2_na matches.
note gaul_adm2_code: Because we were not able to find the gaul_adm1_code for subnatid1 = "33 - Panjsher", we cannot match any of it's districts in q12: 801 "PROVINCIAL CAPITAL OF PANJSHER ( BAZARAK )", 802 "RUKHA", 803 "DARAH", 804 "HISSA-E-AWAL ( KHINJ )", 805 "UNABA", 806 "SHUTUL", or 807 "PARYAN".
note gaul_adm2_code: Cannot find codes for q12 "District name" = 908 "DEH SALAH", 909 "JALGA", 912 "PUL-E-HISAR", or 915 "FIRING WA GHARU". They are in the Baghlan province, but there are no similar wb_adm2_na matches.
note gaul_adm2_code: Cannot find code for q12 "District name" = 1003 "SAIGHAN". It is in the Logar province, but there are no similar wb_adm2_na matches.
note gaul_adm2_code: Cannot find codes for q12 "District name" = 1102 "WALI MOHAMMAD SHAHID KHUGYANI", 1103 "KHWAJA OMARI", or 1104 "WAGHAZ". They are in the Ghazni province, but there are no similar wb_adm2_na matches.
note gaul_adm2_code: Cannot find codes for q12 "District name" = 1203 "YOSUF KHEL", or 1204 "YAHYA KHEL". They are in the Ghazni province, but there are no similar wb_adm2_na matches.
note gaul_adm2_code: Cannot find codes for q12 "District name" = 1302 "AHMADABA", or 1308 "LAJA AHMAD KHEL". They are in the Paktya province, but there are no similar wb_adm2_na matches.
note gaul_adm2_code: Cannot find codes for q12 "District name" = 1402 "MANDUZAY (ESMAYEL KHEL)", 1408 "ALI SHER", or 1412 "SHAMUL". They are in the Khost province, but there are no similar wb_adm2_na matches.
note gaul_adm2_code: Cannot find codes for q12 "District name" = 1503 "WATAPOOR", 1506 "SHIGAL WA SHELTAN", or 1511 "GHAZI ABAD". They are in the Kunar province, but there are no similar wb_adm2_na matches.
note gaul_adm2_code: Cannot find codes for q12 "District name" = 1604 "NOOR GRAM", or 1605 "DUAB". They are in the Nuristan province, but there are no similar wb_adm2_na matches.
note gaul_adm2_code: Cannot find codes for q12 "District name" = 1702 "ARGO", 1704 "YAFTAL-E-SUFLA", 1705 "KHASH", 1707 "DARAYIM", 1709 "YAWAN", 1711 "TASHKAN", 1712 "SHUHADA", 1716 "WARDOOJ", 1717 "TAGAB", or 1718 "YAMGAN". They are in the Badakhshan province, but there are no similar wb_adm2_na matches.
note gaul_adm2_code: Cannot find codes for q12 "District name" = 1802 "HAZAR SUMUCH", 1803 "BAHARAK", 1806 "NAMAK AB", 1812 "DASHT-E-QALA", or 1814 "KHWAJA BAHAWUDDIN". They are in the Takhar province, but there are no similar wb_adm2_na matches.
note gaul_adm2_code: Cannot find codes for q12 "District name" = 2004 "FEROZ NAKHCHEER". It is in the Samangan province, but there are no similar wb_adm2_na matches.
note gaul_adm2_code: Cannot find codes for q12 "District name" = 2006 "DARA-E-SOOF-E-PAYIN", 2007 "DARA-E-SOOF-E-BALA". They are in the Samangan province, but there is only a single wb_adm2_na match (Dara-I- Suf, wb_adm2_co = 3725).
note gaul_adm2_code: Cannot find codes for q12 "District name" = 2206 "GOSFANDI". It is in the Sar-I-Poul province, but there are no similar wb_adm2_na matches.
note gaul_adm2_code: Cannot find codes for q12 "District name" = 2302 "DULEENA", or 2303 "DAWLATYAR". They are in the Ghor province, but there is only a single wb_adm2_na match (Dara-I- Suf, wb_adm2_co = 3725).
note gaul_adm2_code: Because we were not able to find the gaul_adm1_code for subnatid1 = "34 - Daikindi", we cannot match any of it's districts in q12: 2401 "PROVINCIAL CAPITAL OF DAYKUNDI ( NILI )", 2402 "SHAHRISTAN", 2404 "ISHTERLAI", 2405 "KHEDIR", 2406 "GETI", 2407 "MIRAMOR", 2408 "SANG-E-TAKHT", and 2409 "KEJRAN".
note gaul_adm2_code: Cannot find codes for q12 "District name" = 2705 "ZHIRE". It is in the Kandahar province, but there are no similar wb_adm2_na matches.
note gaul_adm2_code: Cannot find codes for q12 "District name" = 2803 "KHANAQA", 2805 "QUSH TEPA", or 2807 "KHANAQA". They are in the Jawzjan province, but there is only a single wb_adm2_na match (Dara-I- Suf, wb_adm2_co = 3725).
*</_gaul_adm2_code_>

*<_gaul_adm3_code_>
*<_gaul_adm3_code_note_> Gaul Code *</_gaul_adm3_code_note_>
*<_gaul_adm3_code_note_> gaul_adm3_code brought in from rawdata *</_gaul_adm3_code_note_>
gen gaul_adm3_code=.
*</_gaul_adm3_code_>

*<_urban_>
*<_urban_note_> Urban (1) or rural (0) *</_urban_note_>
*<_urban_note_> urban brought in from rawdata *</_urban_note_>
*clonevar urban = urban 
notes urban: `code' `year': Kuchi replaced as rural
*</_urban_>

*<_Keep variables_>
duplicates drop hhid, force
*keep countrycode year hhid weight weighttype subnatid1 subnatid2 subnatid3 subnatid4 subnatidsurvey strata psu subnatid1_prev subnatid2_prev subnatid3_prev subnatid4_prev gaul_adm1_code gaul_adm2_code gaul_adm3_code urban
order countrycode year hhid weight weighttype
sort hhid
*</_Keep variables_>

*<_Save data file_>
if ("`c(username)'"=="sunquat") global rootdofiles "/Users/`c(username)'/Projects/WORLD BANK/2023 SAR QCHECK/SARDATABANK/SARMDdofiles"
quietly do 	"$rootdofiles/_aux/Labels_GMD2.0.do"
save "$output/`filename'.dta", replace
*</_Save data file_>
