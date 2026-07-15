*<_Program setup_>
clear all
set more off
glo rootdatalib "P:\SARMD\SARDATABANK\WORKINGDATA"
glo rootdatalib "P:\SARMD\SARDATABANK\SAR_DATABANK"
local code         "AFG"
local year         "2019"
local survey       "LCS"
local vm           "01"
local va           "01"
local type         "SARMD"
local yearfolder   "`code'_`year'_`survey'"
local harmonized    "`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'"
*</_Program setup_>
glo dodatalib "P:\SARMD\SARDATABANK\SAR_DATABANK\"
local programs "${dodatalib}\\`code'\\`yearfolder'\\`harmonized'\Programs"
*--------Run modules
do "`programs'\\`harmonized'_COR.do"
do "`programs'\\`harmonized'_GEO.do"
do "`programs'\\`harmonized'_DEM.do"
do "`programs'\\`harmonized'_DWL.do"
do "`programs'\\`harmonized'_LBR.do"
do "`programs'\\`harmonized'_UTL.do"
do "`programs'\\`harmonized'_IDN.do"
do "`programs'\\`harmonized'_GMD.do"
*
do "`programs'\\`harmonized'_IND.do"

*