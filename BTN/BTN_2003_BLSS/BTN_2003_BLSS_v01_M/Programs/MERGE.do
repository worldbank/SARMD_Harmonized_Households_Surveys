clear 

set mem 400m

*******************************************

use "W:\Ernest\BLSS2007\block8.dta", clear

sort houseid

save "W:\Ernest\BLSS2007\bhutan8.dta"




use "W:\Ernest\BLSS2007\block9.dta", clear

sort houseid

save "W:\Ernest\BLSS2007\bhutan9.dta"



merge houseid using "W:\Ernest\BLSS2007\bhutan8.dta"

sort houseid

gen merge89=_merge

drop _merge

save "W:\Ernest\BLSS2007\bhutan_mer.dta"



use "W:\Ernest\BLSS2007\block10.dta", clear

sort houseid

save "W:\Ernest\BLSS2007\bhutan10.dta"




use "W:\Ernest\BLSS2007\bhutan_mer.dta", clear

merge houseid using "W:\Ernest\BLSS2007\bhutan10.dta"

sort houseid

gen merge10mer=_merge

drop _merge

save "W:\Ernest\BLSS2007\bhutan_mer.dta", replace


**********************************************************************
 

use "C:\Users\WB364179\Documents\BLSS03\Data\block1.dta", clear

sort houseid


save "C:\Users\WB364179\Documents\BLSS03\Data\bhutan1.dta"

use "C:\Users\WB364179\Documents\BLSS03\Data\block2.dta", clear

sort houseid


save "C:\Users\WB364179\Documents\BLSS03\Data\bhutan2.dta"


use "C:\Users\WB364179\Documents\BLSS03\Data\bhutan1.dta", clear

merge houseid using "C:\Users\WB364179\Documents\BLSS03\Data\bhutan2.dta"

gen merge2=_merge
drop _merge

save "C:\Users\WB364179\Documents\BLSS03\Data\bhutan_mer.dta", replace

********************************************
foreach i of numlist  3 5 6 7 {

use "C:\Users\WB364179\Documents\BLSS03\Data\block`i'.dta", clear

sort houseid

save "C:\Users\WB364179\Documents\BLSS03\Data\bhutan`i'.dta"
use "C:\Users\WB364179\Documents\BLSS03\Data\bhutan_mer.dta", clear

sort houseid
merge houseid using "C:\Users\WB364179\Documents\BLSS03\Data\bhutan`i'.dta"
sort houseid

gen merge`i'=_merge
drop _merge

save "C:\Users\WB364179\Documents\BLSS03\Data\bhutan_mer.dta", replace

}

forvalues i = 5/7 {

use "C:\Users\WB364179\Documents\BLSS03\Data\block`i'.dta", clear

sort houseid

save "C:\Users\WB364179\Documents\BLSS03\Data\bhutan`i'.dta"
use "C:\Users\WB364179\Documents\BLSS03\Data\bhutan_mer.dta", clear

sort houseid
merge houseid using "C:\Users\WB364179\Documents\BLSS03\Data\bhutan`i'.dta"
sort houseid

gen merge`i'=_merge
drop _merge

save "C:\Users\WB364179\Documents\BLSS03\Data\bhutan_mer.dta", replace

}

forvalues i = 1/7 {

use "C:\Users\WB364179\Documents\BLSS03\Data\bhutan`i'.dta", clear

summ houseid

}




/*

use "W:\Ernest\BLSS2007\block3.dta", clear

sort houseid

save "W:\Ernest\BLSS2007\bhutan3.dta"




use "W:\Ernest\BLSS2007\bhutan_mer_12.dta", clear

merge houseid using "W:\Ernest\BLSS2007\bhutan3.dta"

sort houseid

gen merge123=_merge

drop _merge

save "W:\Ernest\BLSS2007\bhutan_mer_123.dta"



********************************************

use "W:\Ernest\BLSS2007\block4.dta", clear

sort houseid

save "W:\Ernest\BLSS2007\bhutan4.dta"




use "W:\Ernest\BLSS2007\bhutan_mer_123.dta", clear

merge houseid using "W:\Ernest\BLSS2007\bhutan4.dta"

sort houseid

gen merge1234=_merge

drop _merge

save "W:\Ernest\BLSS2007\bhutan_mer_1234.dta"

*********************************************


use "W:\Ernest\BLSS2007\block5.dta", clear

sort houseid

save "W:\Ernest\BLSS2007\bhutan5.dta"




use "W:\Ernest\BLSS2007\bhutan_mer_1234.dta", clear

merge houseid using "W:\Ernest\BLSS2007\bhutan5.dta"

sort houseid

gen merge12345=_merge

drop _merge

save "W:\Ernest\BLSS2007\bhutan_mer_12345.dta"

************************************************

use "W:\Ernest\BLSS2007\block6.dta", clear

sort houseid

save "W:\Ernest\BLSS2007\bhutan6.dta"




use "W:\Ernest\BLSS2007\bhutan_mer_12345.dta", clear

merge houseid using "W:\Ernest\BLSS2007\bhutan6.dta"

sort houseid

gen merge123456=_merge

drop _merge

save "W:\Ernest\BLSS2007\bhutan_mer_123456.dta"

************************************************


use "W:\Ernest\BLSS2007\block7.dta", clear

sort houseid

save "W:\Ernest\BLSS2007\bhutan7.dta"




use "W:\Ernest\BLSS2007\bhutan_mer_123456.dta", clear

merge houseid using "W:\Ernest\BLSS2007\bhutan7.dta"

sort houseid

gen merge1234567=_merge

drop _merge

save "W:\Ernest\BLSS2007\bhutan_mer_1234567.dta"

**************************************************


use "W:\Ernest\BLSS2007\block8.dta", clear

sort houseid

save "W:\Ernest\BLSS2007\bhutan8.dta"




use "W:\Ernest\BLSS2007\bhutan_mer_1234567.dta", clear

merge houseid using "W:\Ernest\BLSS2007\bhutan8.dta"

sort houseid

gen merge12345678=_merge

drop _merge

save "W:\Ernest\BLSS2007\bhutan_mer_12345678.dta"


*******************************************************
clear 

set mem 400m

use "W:\Ernest\BLSS2007\block9.dta", clear

sort houseid

save "W:\Ernest\BLSS2007\bhutan9.dta"




use "W:\Ernest\BLSS2007\bhutan_mer_12345678.dta", clear

merge houseid using "W:\Ernest\BLSS2007\bhutan9.dta"

sort houseid

gen merge123456789=_merge

drop _merge

save "W:\Ernest\BLSS2007\bhutan_mer_123456789.dta"

*******************************************************

use "W:\Ernest\BLSS2007\block10.dta", clear

sort houseid

save "W:\Ernest\BLSS2007\bhutan10.dta"




use "W:\Ernest\BLSS2007\bhutan_mer_123456789.dta", clear

merge houseid using "W:\Ernest\BLSS2007\bhutan10.dta"

sort houseid

gen merge12345678910=_merge

drop _merge

save "W:\Ernest\BLSS2007\bhutan_mer_12345678910.dta"



*/






