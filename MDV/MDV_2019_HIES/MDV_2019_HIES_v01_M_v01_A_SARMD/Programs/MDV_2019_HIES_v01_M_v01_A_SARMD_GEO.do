/*------------------------------------------------------------------------------
					GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   MDV_2019_HIES_v01_M_v01_A_GMD_GEO.do	</_Program name_>
<_Application_>    STATA 16.0	<_Application_>
<_Author(s)_>      Juan Segnana <jsegnana@worldbank.org>	</_Author(s)_>
<_Date created_>   05-03-2020	</_Date created_>
<_Date modified>    3 May 2021	</_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        MDV	</_Country_>
<_Survey Title_>   HIES	</_Survey Title_>
<_Survey Year_>    2019	</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:	05-03-2020
File:	MDV_2019_HIES_v01_M_v01_A_GMD_GEO.do
- First version
</_Version Control_>
------------------------------------------------------------------------------*/

*<_Program setup_>;
#delimit ;
clear all;
set more off;

local code         "MDV";
local year         "2019";
local survey       "HIES";
local vm           "01";
local va           "01";
local type         "SARMD";
local yearfolder   "MDV_2019_HIES";
local gmdfolder    "MDV_2019_HIES_v01_M_v01_A_SARMD";
local filename     "MDV_2019_HIES_v01_M_v01_A_SARMD_GEO";
*</_Program setup_>;

*<_Folder creation_>;
cap mkdir "$rootdatalib";
cap mkdir "$rootdatalib\\`code'";
cap mkdir "$rootdatalib\\`code'\\`yearfolder'";
cap mkdir "$rootdatalib\\`code'\\`yearfolder'\\`gmdfolder'";
cap mkdir "$rootdatalib\\`code'\\`yearfolder'\\`gmdfolder'\Data";
cap mkdir "$rootdatalib\\`code'\\`yearfolder'\\`gmdfolder'\Data\Harmonized";
*</_Folder creation_>;

** DIRECTORY;
*<_Datalibweb request_>;
#delimit cr
*datalibweb, country(`code') year(`year') type(`type') survey(`survey') vermast(`vm') veralt(`va') mod(IND) clear 
#delimit ;
use "$rootdatalib\MDV\MDV_2019_HIES\MDV_2019_HIES_v01_M\Data\Stata\MDV_2019_HIES_v01_M.dta", clear;
drop countrycode year hhid pid;
*</_Datalibweb request_>;

*<_countrycode_>;
*<_countrycode_note_> country code *</_countrycode_note_>;
*<_countrycode_note_> countrycode brought in from rawdata *</_countrycode_note_>;
gen countrycode="MDV";
note countrycode: countrycode=MDV;
*</_countrycode_>;

*<_year_>;
*<_year_note_> Year *</_year_note_>;
*<_year_note_> year brought in from rawdata *</_year_note_>;
gen year=2019;
note year: year=2019;
*</_year_>;

*<_hhid_>;
*<_hhid_note_> Household identifier  *</_hhid_note_>;
*<_hhid_note_> hhid brought in from rawdata *</_hhid_note_>;
gen hhid=uqhhid;
tostring hhid, replace;
label var hhid "Household id";
note hhid: hhid=uqhhid  4,910 values;
*</_hhid_>;

*<_pid_>;
*<_pid_note_> Personal identifier  *</_pid_note_>;
*<_pid_note_> pid brought in from rawdata *</_pid_note_>;
egen pid=concat(uqhhid person_no), punct(-);
label var pid "Individual id";
note pid: pid=uqhhid - person_no  24,776 values;
*</_pid_>;

*<_weight_>;
*<_weight_note_> Household weight *</_weight_note_>;
*<_weight_note_> weight brought in from rawdata *</_weight_note_>;
gen double weight=wgt;
note weight: weight=wgt;
*</_weight_>;

*<_weighttype_>;
*<_weighttype_note_> Weight type (frequency, probability, analytical, importance) *</_weighttype_note_>;
*<_weighttype_note_> weighttype brought in from rawdata *</_weighttype_note_>;
gen weighttype="PW";
note weighttype: "Probability weight";
*</_weighttype_>;

*<_subnatid1_>;
*<_subnatid1_note_> Subnational ID - highest level *</_subnatid1_note_>;
*<_subnatid1_note_> subnatid1 brought in from SARMD *</_subnatid1_note_>;
clonevar subnatid1=atoll_str;
label var subnatid1 "Region at 1 digit (ADMN1)";
note subnatid1: subnatid1 = Male + 20 Atolls;
replace subnatid1="1 - Alif Alif" 	 if atoll_str=="AA";
replace subnatid1="1 - Alif Alif" 	 if atoll_str=="AA";
replace subnatid1="2 - Alif Dhaal" 	 if atoll_str=="ADh";
replace subnatid1="3 - Baa" 		 if atoll_str=="B";
replace subnatid1="4 - Dhaalu" 		 if atoll_str=="Dh";
replace subnatid1="5 - Faafu" 		 if atoll_str=="F";
replace subnatid1="6 - Gaafu Alif" 	 if atoll_str=="GA";
replace subnatid1="7 - Gaafu Dhaalu" if atoll_str=="GDh";
replace subnatid1="8 - Gnaviyani" 	 if atoll_str=="Gn";
replace subnatid1="9 - Haa Alif" 	 if atoll_str=="HA";
replace subnatid1="10 - Haa Dhaalu"  if atoll_str=="HDh";
replace subnatid1="11 - Kaafu" 		 if atoll_str=="K";
replace subnatid1="12 - Laamu" 		 if atoll_str=="L";
replace subnatid1="13 - Lhaviyani" 	 if atoll_str=="Lh";
replace subnatid1="14 - Male '" 	 if atoll_str=="Male'";
replace subnatid1="15 - Meemu" 		 if atoll_str=="M";
replace subnatid1="16 - Noonu" 		 if atoll_str=="N";
replace subnatid1="17 - Raa" 		 if atoll_str=="R";
replace subnatid1="18 - Seenu/Addu"  if atoll_str=="S";
replace subnatid1="19 - Shaviyani" 	 if atoll_str=="Sh";
replace subnatid1="20 - Thaa" 		 if atoll_str=="Th";
replace subnatid1="21 - Vaavu" 		 if atoll_str=="V";
note subnatid1: Subnational identifier at the highest level within the country’s administrative structure;
*</_subnatid1_>;

*<_subnatid2_>;
*<_subnatid2_note_> Subnational ID - second highest level *</_subnatid2_note_>;
*<_subnatid2_note_> subnatid2 brought in from SARMD *</_subnatid2_note_>;
gen aux = atllIslnd;
gen subnatid2="";
label var subnatid2 "Region at 2 digit (ADMN2)";
replace subnatid2="1 - Henvei" if atllIslnd==1001;
replace subnatid2="2 - Galolh" if atllIslnd==1002;
replace subnatid2="3 - Machch" if atllIslnd==1003;
replace subnatid2="4 - Maafan" if atllIslnd==1004;
replace subnatid2="5 - Villig" if atllIslnd==1005;
replace subnatid2="6 - HulhuM" if atllIslnd==1009;
replace subnatid2="7 - HA Thu" if atllIslnd==2001;
replace subnatid2="8 - HA Uli" if atllIslnd==2002;
replace subnatid2="9 - HA Hoa" if atllIslnd==2006;
replace subnatid2="10 - HA Iha" if atllIslnd==2007;
replace subnatid2="11 - HA Kel" if atllIslnd==2008;
replace subnatid2="12 - HA Vas" if atllIslnd==2009;
replace subnatid2="13 - HA Dhi" if atllIslnd==2010;
replace subnatid2="14 - HA Fil" if atllIslnd==2011;
replace subnatid2="15 - HA Tha" if atllIslnd==2013;
replace subnatid2="16 - HA Uth" if atllIslnd==2014;
replace subnatid2="17 - HA Mur" if atllIslnd==2015;
replace subnatid2="18 - HA Baa" if atllIslnd==2016;
replace subnatid2="19 - HDh Ha" if atllIslnd==2103;
replace subnatid2="20 - HDh Fi" if atllIslnd==2104;
replace subnatid2="21 - HDh Na" if atllIslnd==2105;
replace subnatid2="22 - HDh Hi" if atllIslnd==2106;
replace subnatid2="23 - HDh No" if atllIslnd==2107;
replace subnatid2="24 - HDh Ne" if atllIslnd==2108;
replace subnatid2="25 - HDh No" if atllIslnd==2109;
replace subnatid2="26 - HDh Ku" if atllIslnd==2110;
replace subnatid2="27 - HDh Ku" if atllIslnd==2112;
replace subnatid2="28 - HDh Ku" if atllIslnd==2113;
replace subnatid2="29 - HDh Va" if atllIslnd==2115;
replace subnatid2="30 - HDh Ma" if atllIslnd==2117;
replace subnatid2="31 - Sh Kad" if atllIslnd==2201;
replace subnatid2="32 - Sh Noo" if atllIslnd==2202;
replace subnatid2="33 - Sh Fey" if atllIslnd==2204;
replace subnatid2="34 - Sh Fee" if atllIslnd==2205;
replace subnatid2="35 - Sh Bil" if atllIslnd==2206;
replace subnatid2="36 - Sh Foa" if atllIslnd==2207;
replace subnatid2="37 - Sh Mar" if atllIslnd==2210;
replace subnatid2="38 - Sh Kom" if atllIslnd==2213;
replace subnatid2="39 - Sh Maa" if atllIslnd==2214;
replace subnatid2="40 - Sh Fun" if atllIslnd==2215;
replace subnatid2="41 - Sh Mil" if atllIslnd==2216;
replace subnatid2="42 - R Alif" if atllIslnd==2401;
replace subnatid2="43 - R Vaad" if atllIslnd==2402;
replace subnatid2="44 - R Rasg" if atllIslnd==2403;
replace subnatid2="45 - R Agol" if atllIslnd==2404;
replace subnatid2="46 - R Ugoo" if atllIslnd==2407;
replace subnatid2="47 - R Maak" if atllIslnd==2409;
replace subnatid2="48 - R Rasm" if atllIslnd==2410;
replace subnatid2="49 - R Madu" if atllIslnd==2412;
replace subnatid2="50 - R Igur" if atllIslnd==2413;
replace subnatid2="51 - R Fain" if atllIslnd==2414;
replace subnatid2="52 - R Meed" if atllIslnd==2416;
replace subnatid2="53 - R Kino" if atllIslnd==2417;
replace subnatid2="54 - R Hulh" if atllIslnd==2418;
replace subnatid2="55 - R Dhuv" if atllIslnd==2419;
replace subnatid2="56 - B Kuda" if atllIslnd==2501;
replace subnatid2="57 - B Kama" if atllIslnd==2502;
replace subnatid2="58 - B Kend" if atllIslnd==2503;
replace subnatid2="59 - B Dhon" if atllIslnd==2507;
replace subnatid2="60 - B Dhar" if atllIslnd==2508;
replace subnatid2="61 - B Maal" if atllIslnd==2509;
replace subnatid2="62 - B Eydh" if atllIslnd==2510;
replace subnatid2="63 - B Thul" if atllIslnd==2512;
replace subnatid2="64 - B Hith" if atllIslnd==2513;
replace subnatid2="65 - B Fulh" if atllIslnd==2514;
replace subnatid2="66 - B Goid" if atllIslnd==2516;
replace subnatid2="67 - Lh Hin" if atllIslnd==2601;
replace subnatid2="68 - LhNaif" if atllIslnd==2602;
replace subnatid2="69 - Lh Kur" if atllIslnd==2603;
replace subnatid2="70 - K Kaas" if atllIslnd==2701;
replace subnatid2="71 - K Gaaf" if atllIslnd==2702;
replace subnatid2="72 - K Dhif" if atllIslnd==2703;
replace subnatid2="73 - K Thul" if atllIslnd==2704;
replace subnatid2="74 - K Hura" if atllIslnd==2705;
replace subnatid2="75 - K Himm" if atllIslnd==2706;
replace subnatid2="76 - K Maaf" if atllIslnd==2712;
replace subnatid2="77 - K Gura" if atllIslnd==2713;
replace subnatid2="78 - AA Tho" if atllIslnd==2801;
replace subnatid2="79 - AA Ras" if atllIslnd==2802;
replace subnatid2="80 - AA Uku" if atllIslnd==2804;
replace subnatid2="81 - AA Mat" if atllIslnd==2805;
replace subnatid2="82 - AA Bod" if atllIslnd==2806;
replace subnatid2="83 - AA Fer" if atllIslnd==2807;
replace subnatid2="84 - AA Maa" if atllIslnd==2808;
replace subnatid2="85 - AA Him" if atllIslnd==2809;
replace subnatid2="86 - ADh Ha" if atllIslnd==2901;
replace subnatid2="87 - ADh Om" if atllIslnd==2902;
replace subnatid2="88 - ADh Ku" if atllIslnd==2903;
replace subnatid2="89 - ADh Ma" if atllIslnd==2904;
replace subnatid2="90 - ADh Ma" if atllIslnd==2905;
replace subnatid2="91 - ADh Dh" if atllIslnd==2906;
replace subnatid2="92 - ADh Dh" if atllIslnd==2907;
replace subnatid2="93 - ADh Fe" if atllIslnd==2908;
replace subnatid2="94 - ADh Dh" if atllIslnd==2909;
replace subnatid2="95 - ADh Ma" if atllIslnd==2910;
replace subnatid2="96 - V Fuli" if atllIslnd==3001;
replace subnatid2="97 - V Thin" if atllIslnd==3002;
replace subnatid2="98 - V Feli" if atllIslnd==3003;
replace subnatid2="99 - V Keyo" if atllIslnd==3004;
replace subnatid2="100 - V Rake" if atllIslnd==3005;
replace subnatid2="101 - F Feea" if atllIslnd==3201;
replace subnatid2="102 - F Bile" if atllIslnd==3203;
replace subnatid2="103 - F Mago" if atllIslnd==3204;
replace subnatid2="104 - F Dhar" if atllIslnd==3205;
replace subnatid2="105 - F Nila" if atllIslnd==3206;
replace subnatid2="106 - Dh Mee" if atllIslnd==3301;
replace subnatid2="107 - Dh Bad" if atllIslnd==3302;
replace subnatid2="108 - Dh Rib" if atllIslnd==3303;
replace subnatid2="109 - Dh Hul" if atllIslnd==3304;
replace subnatid2="110 - Dh Maa" if atllIslnd==3307;
replace subnatid2="111 - Dh Kud" if atllIslnd==3308;
replace subnatid2="112 - Th Bur" if atllIslnd==3401;
replace subnatid2="113 - Th Vil" if atllIslnd==3402;
replace subnatid2="114 - Th Mad" if atllIslnd==3403;
replace subnatid2="115 - Th Gur" if atllIslnd==3405;
replace subnatid2="116 - Th Kad" if atllIslnd==3406;
replace subnatid2="117 - Th Hir" if atllIslnd==3408;
replace subnatid2="118 - Th Thi" if atllIslnd==3410;
replace subnatid2="119 - Th Vey" if atllIslnd==3411;
replace subnatid2="120 - Th Kib" if atllIslnd==3412;
replace subnatid2="121 - Th Oma" if atllIslnd==3413;
replace subnatid2="122 - L Isdh" if atllIslnd==3501;
replace subnatid2="123 - L Dhab" if atllIslnd==3502;
replace subnatid2="124 - L Maab" if atllIslnd==3503;
replace subnatid2="125 - L Mund" if atllIslnd==3504;
replace subnatid2="126 - L Gamu" if atllIslnd==3506;
replace subnatid2="127 - L Maav" if atllIslnd==3507;
replace subnatid2="128 - L Fona" if atllIslnd==3508;
replace subnatid2="129 - L Maam" if atllIslnd==3510;
replace subnatid2="130 - L Hith" if atllIslnd==3511;
replace subnatid2="131 - L Kuna" if atllIslnd==3512;
replace subnatid2="132 - L Kala" if atllIslnd==3513;
replace subnatid2="133 - GA Kol" if atllIslnd==3601;
replace subnatid2="134 - GA Vil" if atllIslnd==3602;
replace subnatid2="135 - GA Maa" if atllIslnd==3603;
replace subnatid2="136 - GA Dha" if atllIslnd==3605;
replace subnatid2="137 - GA Dhe" if atllIslnd==3606;
replace subnatid2="138 - GA Kod" if atllIslnd==3607;
replace subnatid2="139 - GA Gem" if atllIslnd==3609;
replace subnatid2="140 - GA Kan" if atllIslnd==3610;
replace subnatid2="141 - GDh Ma" if atllIslnd==3701;
replace subnatid2="142 - GDh Ho" if atllIslnd==3702;
replace subnatid2="143 - GDh Na" if atllIslnd==3703;
replace subnatid2="144 - GDh Ga" if atllIslnd==3704;
replace subnatid2="145 - GDh Ra" if atllIslnd==3705;
replace subnatid2="146 - GDh Va" if atllIslnd==3706;
replace subnatid2="147 - GDh Fi" if atllIslnd==3707;
replace subnatid2="148 - GDh Th" if atllIslnd==3710;
replace subnatid2="149 - GDh Fa" if atllIslnd==3711;
replace subnatid2="150 - S Meed" if atllIslnd==3901;
replace subnatid2="151 - S Hith" if atllIslnd==3902;
replace subnatid2="152 - S Mara" if atllIslnd==3903;
replace subnatid2="153 - S Feyd" if atllIslnd==3904;
replace subnatid2="154 - S Mara" if atllIslnd==3905;
replace subnatid2="155 - S Hulh" if atllIslnd==3906;
note subnatid2: Subnational identifier at which survey is representative at the second highest level within the country’s administrative structure;
*</_subnatid2_>;

*<_subnatid3_>;
*<_subnatid3_note_> Subnational ID - third highest level *</_subnatid3_note_>;
*<_subnatid3_note_> subnatid3 brought in from SARMD *</_subnatid3_note_>;
gen subnatid3="";
note subnatid3: N/A;
*</_subnatid3_>;

*<_subnatid4_>;
*<_subnatid4_note_> Subnational ID - lowest level *</_subnatid4_note_>;
*<_subnatid4_note_> subnatid4 brought in from SARMD *</_subnatid4_note_>;
gen subnatid4 = "";
note subnatid4: N/A;
*</_subnatid4_>;

*<_subnatidsurvey_>;
*<_subnatidsurvey_note_> Survey representation of geographical units *</_subnatidsurvey_note_>;
*<_subnatidsurvey_note_> subnatidsurvey brought in from SARMD *</_subnatidsurvey_note_>;
gen subnatidsurvey="";
note subnatidsurvey: N/A;
*</_subnatidsurvey_>;

*<_strata_>;
*<_strata_note_> Strata *</_strata_note_>;
*<_strata_note_> strata brought in from SARMD *</_strata_note_>;
gen strata=atoll;
label var strata "Strata";
note strata: strata=Male and 20 administrative atolls;
*</_strata_>;

*<_psu_>;
*<_psu_note_> PSU *</_psu_note_>;
*<_psu_note_> psu brought in from SARMD *</_psu_note_>;
*gen psu=psu;
note psu: Primary sampling unit;
*</_psu_>;

*<_subnatid1_prev_>;
*<_subnatid1_prev_note_> Subnatid *</_subnatid1_prev_note_>;
*<_subnatid1_prev_note_> subnatid1_prev brought in from SARMD *</_subnatid1_prev_note_>;
gen subnatid1_prev=.;
note subnatid1_prev: N/A;
*</_subnatid1_prev_>;

*<_subnatid2_prev_>;
*<_subnatid2_prev_note_> Subnatid *</_subnatid2_prev_note_>;
*<_subnatid2_prev_note_> subnatid2_prev brought in from SARMD *</_subnatid2_prev_note_>;
gen subnatid2_prev=.;
note subnatid2_prev: N/A;
*</_subnatid2_prev_>;

*<_subnatid3_prev_>;
*<_subnatid3_prev_note_> Subnatid *</_subnatid3_prev_note_>;
*<_subnatid3_prev_note_> subnatid3_prev brought in from SARMD *</_subnatid3_prev_note_>;
gen subnatid3_prev=.;
note subnatid3_prev: N/A;
*</_subnatid3_prev_>;

*<_subnatid4_prev_>;
*<_subnatid4_prev_note_> Subnatid *</_subnatid4_prev_note_>;
*<_subnatid4_prev_note_> subnatid4_prev brought in from SARMD *</_subnatid4_prev_note_>;
gen subnatid4_prev=.;
note subnatid4_prev: N/A;
*</_subnatid4_prev_>;

*<_gaul_adm1_code_>;
*<_gaul_adm1_code_note_> Gaul Code *</_gaul_adm1_code_note_>;
*<_gaul_adm1_code_note_> gaul_adm1_code brought in from SARMD *</_gaul_adm1_code_note_>;
gen gaul_adm1_code=.;
label var gaul_adm1_code "GAUL code for admin1 level";
replace gaul_adm1_code=1990 if subnatid1=="1 - Alif Alif";
replace gaul_adm1_code=1991 if subnatid1=="2 - Alif Dhaal";
replace gaul_adm1_code=1992 if subnatid1=="3 - Baa";
replace gaul_adm1_code=1993 if subnatid1=="4 - Dhaalu";
replace gaul_adm1_code=1994 if subnatid1=="5 - Faafu";
replace gaul_adm1_code=1995 if subnatid1=="6 - Gaafu Alif";
replace gaul_adm1_code=1996 if subnatid1=="7 - Gaafu Dhaalu";
replace gaul_adm1_code=. 	if subnatid1=="8 - Gnaviyani";
replace gaul_adm1_code=1997 if subnatid1=="9 - Haa Alif";
replace gaul_adm1_code=1998 if subnatid1=="10 - Haa Dhaalu";
replace gaul_adm1_code=1999 if subnatid1=="11 - Kaafu";
replace gaul_adm1_code=2000 if subnatid1=="12 - Laamu";
replace gaul_adm1_code=2001 if subnatid1=="13 - Lhaviyani";
replace gaul_adm1_code=2002 if subnatid1=="14 - Malé";
replace gaul_adm1_code=2003 if subnatid1=="15 - Meemu";
replace gaul_adm1_code=2004 if subnatid1=="16 - Noonu";
replace gaul_adm1_code=2005 if subnatid1=="17 - Raa";
replace gaul_adm1_code=2006 if subnatid1=="18 - Seenu/Addu";
replace gaul_adm1_code=2007 if subnatid1=="19 - Shaviyani";
replace gaul_adm1_code=2008 if subnatid1=="20 - Thaa";
replace gaul_adm1_code=2009 if subnatid1=="21 - Vaavu";
note gaul_adm1_code: Numeric and country-specific based on the GAUL database;
*</_gaul_adm1_code_>;

*<_gaul_adm2_code_>;
*<_gaul_adm2_code_note_> Gaul Code *</_gaul_adm2_code_note_>;
*<_gaul_adm2_code_note_> gaul_adm2_code brought in from SARMD *</_gaul_adm2_code_note_>;
gen gaul_adm2_code=.;
note gaul_adm2_code: N/A;
*</_gaul_adm2_code_>;

*<_gaul_adm3_code_>;
*<_gaul_adm3_code_note_> Gaul Code *</_gaul_adm3_code_note_>;
*<_gaul_adm3_code_note_> gaul_adm3_code brought in from SARMD *</_gaul_adm3_code_note_>;
gen gaul_adm3_code=.;
note gaul_adm3_code: N/A;
*</_gaul_adm3_code_>;

*<_urban_>;
*<_urban_note_> Urban (1) or rural (0) *</_urban_note_>;
*<_urban_note_> urban brought in from SARMD *</_urban_note_>;
gen urban=0;
replace urban=1 if atoll_str=="Male'"; 
label var urban "Male/Rest";
la de lblurban 1 "Male" 0 "Rest";
label values urban lblurban;
note urban: urban = Male although urban/rural does not exist in the Maldives;
*</_urban_>;

*<_Keep variables_>;
keep countrycode year hhid pid weight weighttype subnatid1 subnatid2 subnatid3 subnatid4 subnatidsurvey strata psu subnatid1_prev subnatid2_prev subnatid3_prev subnatid4_prev gaul_adm1_code gaul_adm2_code gaul_adm3_code urban;
order countrycode year hhid pid weight weighttype;
sort hhid pid ;
*</_Keep variables_>;

*<_Save data file_>;
glo module="GEO";
include "${rootdatalib}\_aux\GMD2.0labels.do";
save "$rootdatalib\\`code'\\`yearfolder'\\`gmdfolder'\Data\Harmonized\\`filename'.dta" , replace;
*</_Save data file_>;
