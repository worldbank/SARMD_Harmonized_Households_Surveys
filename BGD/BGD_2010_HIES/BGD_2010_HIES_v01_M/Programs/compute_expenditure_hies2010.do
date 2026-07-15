set more off
clear
set mem 200m
cd "g:\hies_dat_1_18"
* This program computes total expenditures from various files,  
* and then aggregates the results into the file hhexp

* FOOD CONSUMPTION
* ----------------------------------------------------------------------
** daily consumption**
use s9a2, clear
gen hhid=psu+hhold
gen hhcode=real(hhid)
destring item,replace
sort hhcode day
drop if mod(item,10)==0
replace value=value/100
collapse (sum) fexpday=value, by(hhcode day)
drop if fexpday==0
* (so as to remove those days for which no consumption is reported)
collapse (sum) fexptot1=fexpday (count) ndays=day, by(hhcode)
*To make it 14 days food consumption
replace fexptot1=fexptot1*14/ndays
sort hhcode
**To make it monthly food consumption
gen fexp1 = fexptot1*(365/(14*12))
save temp1, replace

** weekly consumption**
use s9b1, clear
gen hhid=psu+hhold
gen hhcode=real(hhid)
destring item,replace
sort hhcode week
drop if mod(item,10)==0
replace value=value/100
collapse (sum) fexpwk=value, by(hhcode week)
drop if fexpwk==0
* (so as to remove those weeks for which no consumption is reported)
collapse (sum) fexptot2=fexpwk (count) nweeks=week, by(hhcode)
*To make it 14 days(2 weeks) food consumption
replace fexptot2=fexptot2*2/nweeks
sort hhcode

**To make it monthly food consumption
gen fexp2 = fexptot2*(365/(14*12))
save temp2, replace

use temp1, clear
merge hhcode using temp2
egen fexp = rsum(fexp1 fexp2)
label var fexp "Monthly food consumption"
summarize
tab _merge
drop fexp1 fexp2 _merge
sort hhcode

save  fexp_hies2010, replace
erase temp1.dta
erase temp2.dta
* ----------------------------------------------------------------------

* NON-FOOD EXPENDITURES
* ----------------------------------------------------------------------
* Section 9, Part C
use rt017, clear
drop if mod(item,10)==0
gen hhid=psu+hhold
gen hhcode=real(hhid)
collapse (sum) nfood1=s09c1__2, by(hhcode)
sort hhcode
save temp1, replace

* Section 9, Part D (items 301 - 352)
use rt018, clear
drop if mod(item,10)==0
gen hhid=psu+hhold
gen hhcode=real(hhid)
collapse (sum) nfood2=s09d1__1, by(hhcode)
sort hhcode
replace nfood2=nfood2/12
save temp2, replace

* Section 9, Part D (items 361 - 553)
use rt019, clear
drop if mod(item,10)==0
gen hhid=psu+hhold
gen hhcode=real(hhid)
* drop lumpy life-cycle expenditures
drop if item >=457 & item <= 462
* drop income tax
drop if item==491
* drop interest charges
drop if item==492
*drop insurance
drop if item >=551 & item <= 553
collapse (sum) nfood3=s09d2_q0, by(hhcode)
replace nfood3=nfood3/12
sort hhcode
save temp3, replace

use temp1, clear
merge hhcode using temp2
tab  _merge
drop _merge
sort hhcode
merge hhcode using temp3
tab  _merge
drop _merge
sort hhcode
gen nfexp = nfood1+nfood2+nfood3
summarize
sort hhcode
save nfexp_hies2010, replace
erase temp1.dta
erase temp2.dta
erase temp3.dta
* ----------------------------------------------------------------------

* AGGREGATING TOGETHER THE VARIOUS TOTALS
* ----------------------------------------------------------------------
clear
use fexp_hies2010, clear
sort hhcode
merge hhcode using nfexp_hies2010
tab  _merge
drop _merge
egen hhexp = rsum(fexp nfexp)
save hhexp_hies2010, replace
cap log close
