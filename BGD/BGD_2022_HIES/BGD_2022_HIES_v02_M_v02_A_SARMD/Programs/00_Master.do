glo rootdofiles "P:\SARMD\SARDATABANK\SARMDdofiles"
*glo rootdatalib "P:\SARMD\SARDATABANK\SAR_DATABANK"
glo rootdatalib "P:\SARMD\SARDATABANK\WORKINGDATA"


clear all
set more off
set trace off 

global code         "BGD"
global year         "2022"
global survey       "HIES"
global vm           "02"
global va           "02"
global yearfolder   ="${code}"+"_"+"${year}"+"_"+"${survey}"

notes: possible answers for the following local: Y and N.
local includes_INCmodule "Y" //Y if INC module was created for this version//

*==============================================================================================================================================================*
** No need to modify anything from here **
*==============================================================================================================================================================*
notes: lines from 21 to 26 are run when a database is created as a data preparation for the harmonization. This SHOULD BE ALWAYS THE CASE. 

*Run master
local dopath1  "${rootdofiles}\\${code}\\${yearfolder}\\${yearfolder}_M"
local dopath2  "${rootdatalib}\\${code}\\${yearfolder}\\${yearfolder}_v${vm}_M\Programs"
shell robocopy "${rootdofiles}\\${code}\\${yearfolder}\\${yearfolder}_v${vm}_M" "${rootdatalib}\\${code}\\${yearfolder}\\${yearfolder}_v${vm}_M\Programs" /e
do "`dopath2'//${yearfolder}_v${vm}_M.do"
 
* Copy do-files from repo to datalibweb
local dopath1  "${rootdofiles}\\${code}\\${yearfolder}\\${yearfolder}_SARMD"
local dopath2  "${rootdatalib}\\${code}\\${yearfolder}\\${yearfolder}_v${vm}_M_v${va}_A_SARMD\Programs"
shell robocopy "${rootdofiles}\\${code}\\${yearfolder}\\${yearfolder}_SARMD" "${rootdatalib}\\${code}\\${yearfolder}\\${yearfolder}_v${vm}_M_v${va}_A_SARMD\Programs" /e

* Copy global labels do-file from repo to datalibweb
local doaux    "${rootdofiles}/_aux"
shell robocopy "${rootdofiles}\_aux" "${rootdatalib}\\${code}\\${yearfolder}\\${yearfolder}_v${vm}_M_v${va}_A_SARMD\Programs" /e

if "`includes_INCmodule'"=="N" {
	if ${year}<2016 { 
		foreach mod in  "IND" { 
			glo module "`mod'"
			local filename     "${yearfolder}_v${vm}_M_v${va}_A_SARMD_`mod'"
			do "`dopath2'\\`filename'.do"
		}	
	}
	else if ${year}>=2016 {
		foreach mod in   "IND" "COR" "DEM" "IDN"  "LBR" "GEO" "UTL" "DWL"  { 
			glo module "`mod'"
			local filename     "${yearfolder}_v${vm}_M_v${va}_A_SARMD_`mod'"
			do "`dopath2'\\`filename'.do"
		}	
		do "`doaux'\Database_GMD2.0.do"
	}
}

if "`includes_INCmodule'"=="Y" {
	if ${year}<2016 {
		foreach mod in "INC" "IND" "LBR" { 
			glo module "`mod'"
			local filename     "${yearfolder}_v${vm}_M_v${va}_A_SARMD_`mod'"
			do "`dopath2'\\`filename'.do"
		}	
	}
	else if ${year}>=2016 {
		foreach mod in  "INC" "IND" "COR" "DEM" "IDN"  "LBR" "GEO" "UTL" "DWL"  { 
			glo module "`mod'"
			local filename     "${yearfolder}_v${vm}_M_v${va}_A_SARMD_`mod'"
			do "`dopath2'\\`filename'.do"
		}	
		do "`doaux'\Database_GMD2.0.do"
	}
}

exit