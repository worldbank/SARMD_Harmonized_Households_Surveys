cap log using consumption\program1.log, replace
set more off
clear
set mem 64m

* This program computes total consumption expenditures from various files,  
* and then aggregates the results into the file hhexp

* FOOD CONSUMPTION
* ----------------------------------------------------------------------
use food02, clear
	collapse (sum) fexpday=value, by(hhcode day)
	drop if fexpday==0
* (so as to remove those days for which no consumption is reported)
	collapse (sum) fexptot=fexpday (count) ndays=day, by(hhcode)
	sort hhcode
	gen fexp1 = (30.42*fexptot/ndays)
save temp1, replace

use food03, clear
	collapse (sum) fexpwk=value, by(hhcode week)
	drop if fexpwk==0
* (so as to remove those weeks for which no consumption is reported)
	collapse (sum) fexptot=fexpwk (count) nweeks=week, by(hhcode)
	sort hhcode
	gen fexp2 = (30.42/7)*(fexptot/nweeks)
save temp2, replace

use temp1, clear
	merge hhcode using temp2
	egen fexp = rsum(fexp1 fexp2)
	label var fexp "Monthly food consumption"
	label var ndays "# days of food csm recorded"
	label var nweeks "# weeks of food csm recorded"
	summarize
	tab _merge
	drop fexp1 fexp2 _merge fexptot
	sort hhcode
save  consumption\fexp, replace
erase temp1.dta
erase temp2.dta


* ----------------------------------------------------------------------
* NON-FOOD EXPENDITURES
* ----------------------------------------------------------------------
* Section 9, Part C
use nfood01, clear
	collapse (sum) nfood1=totvalue, by(hhcode)
	sort hhcode
save temp1, replace

* Section 9, Part D (items 291 - 342)
use nfood02, clear
	collapse (sum) nfood2=value, by(hhcode)
	sort hhcode
	replace nfood2=nfood2/12
save temp2, replace

* Section 9, Part D (items 351 - 533)
use nfood03, clear
* drop lumpy life-cycle expenditures
	drop if itemcode >=447 & itemcode <= 452
* drop income tax
	drop if itemcode==481
* drop interest charges
	drop if itemcode==482

	collapse (sum) nfood3=value, by(hhcode)
	replace nfood3=nfood3/12
	sort hhcode
save temp3, replace

* To get the household size and PSU variable
use plist, clear
	collapse (count) hhsize=idcode (mean) psu, by(hhcode)
	sort hhcode
save temp4, replace

use temp1, clear
	merge hhcode using temp2
	tab  _merge
	drop _merge
	sort hhcode
merge hhcode using temp3
	tab  _merge
	drop _merge
	sort hhcode
merge hhcode using temp4
	tab  _merge
	drop _merge
	sort hhcode
	mvencode _all, mv(0) override
gen nfexp = nfood1+nfood2+nfood3
	summarize
	drop nfood1 nfood2 nfood3
label var hhsize "Household size"
label var nfexp  "Monthly non-food consumption"
save consumption\nfexp, replace
erase temp1.dta
erase temp2.dta
erase temp3.dta
erase temp4.dta

* ----------------------------------------------------------------------
* AGGREGATING TOGETHER THE VARIOUS TOTALS
* ----------------------------------------------------------------------
use consumption\fexp, clear
	merge hhcode using consumption\nfexp
	tab  _merge
	drop _merge

egen hhexp = rsum(fexp nfexp)
gen  pcexp = hhexp / hhsize

label var hhexp "Monthly hhold consumption"
label var pcexp "Monthly per capita hhold csm"

sort psu
merge psu using psulist
	tab  _merge
	drop _merge
	sort hhcode
gen weight = hhwght*hhsize
label var weight "Individual weight"

summarize

summarize  fexp [weight=weight], detail
summarize nfexp [weight=weight], detail
summarize hhexp [weight=weight], detail

drop wght95

sort hhcode
save consumption\hhexp, replace


* ----------------------------------------------------------------------
cap log close
