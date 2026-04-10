*===============================================================================
* Project: Sri Lanka HIES 2016
* This do file converts raw data from DCS in .csv format into .dta format for subsequent analysis
* Date: November 21, 2017
* Author: Ani Rudra Silwal
*===============================================================================

* Convert HIES modules from csv format to dta format
	local myfilelist : dir "$root\Data\Original" files "sec_*"
	foreach file of local myfilelist{
	cd "$root\Data\Original"
	di "`file'"
	import delimited "`file'", clear
	cd "$output"
	local subfile = subinstr("`file'", ".csv", ".dta", 1)
	!rename "`file'" "`subfile'"
	compress
	save "`subfile'", replace
	}

* Convert HIES weights from csv format to dta format
* This file doesn't need to be processed further so is saved directly in the "Processed dta files" folder
	import delimited  "$root\Data\Original\weight2016.csv", clear
	ren finalweight weight
	save "$output\weights2016.dta", replace
