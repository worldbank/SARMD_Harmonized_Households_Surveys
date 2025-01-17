/*------------------------------------------------------------------------------
					GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   BGD_2022_HIES_v01_M.do	</_Program name_>
<_Application_>    STATA 16.0	<_Application_>
<_Author(s)_>      Leo Tornarolli <tornarolli@gmail.com>	</_Author(s)_>
<_Date created_>   04-2023	</_Date created_>
<_Date modified>    4 Apr 2023	</_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        BGD	</_Country_>
<_Survey Title_>   HIES	</_Survey Title_>
<_Survey Year_>    2022	</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:	04-2023
File:	BGD_2022_HIES_v01_M_v01_A_SARMD_IDN.do
- First version
</_Version Control_>
------------------------------------------------------------------------------*/

*<_Program setup_>;
#delimit ;
clear all;
set more off;

local code         "BGD";
local year         "2022";
local survey       "HIES";
local vm           "01";
local va           "01";
local type         "SARMD";
local yearfolder   "BGD_2022_HIES";
local gmdfolder    "BGD_2022_HIES_v01_M";
local filename     "BGD_2022_HIES_v01_M_base";
*</_Program setup_>;

*<_Folder creation_>;
cap mkdir "$rootdatalib";
cap mkdir "$rootdatalib\\`code'";
cap mkdir "$rootdatalib\\`code'\\`yearfolder'";
cap mkdir "$rootdatalib\\`code'\\`yearfolder'\\`gmdfolder'";
cap mkdir "$rootdatalib\\`code'\\`yearfolder'\\`gmdfolder'\Data";
cap mkdir "$rootdatalib\\`code'\\`yearfolder'\\`gmdfolder'\Data\Stata";
*</_Folder creation_>;

*<_Datalibweb request_>;
#delimit cr
datalibweb, country(`code') year(`year') type(`type') survey(`survey') vermast(`vm') veralt(`va') mod(IND) clear 
#delimit ;
*</_Datalibweb request_>;

*<_Save data file_>;

save "$rootdatalib\\`code'\\`yearfolder'\\`gmdfolder'\Data\Stata\\`filename'.dta" , replace;
*</_Save data file_>;
