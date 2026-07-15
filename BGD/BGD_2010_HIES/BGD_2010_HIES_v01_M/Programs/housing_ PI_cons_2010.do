* housing_pi_cons_2010.do
set more off
cd g:\hies_dat_1_18
cap log using housing_pi_cons_2010,replace
use rt001.dta, clear
gen hhcode=psu+hhold
destring hhcode,replace
gen lnroom=log( s06a_q02)
gen dining= s06a_q03
replace dining=0 if dining==2
gen kitchen=  s06a_q04
replace kitchen=0 if kitchen==2
gen brickwall= s06a_q05
replace brickwall=0 if brickwall~=1
gen tapwater=  s06a_q09
replace tapwater=0 if  tapwater~=1 &  tapwater~=.
gen electricity= s06a_q14
replace electricity=0 if  electricity==2
gen telephone= s06a_q17
replace telephone=0 if telephone==2
gen lndwsize=log(s06a_q07)
gen rental= s06a_q21
replace rental=0 if rental~=2 &  rental~=.
keep psu hhold hhcode lnroom - rental
sort hhcode
save temp1, replace


use rt019.dta, clear
keep if item>=381 & item<=382
gen str6 hh=psu+hhold
gen double hhcode=real(hh)
keep psu hhold  hhcode s09d2_q0 item
reshape wide  s09d2_q0, i( hhcode) j(item)
rename s09d2_q0381 rent
rename s09d2_q0382 imprent
sort hhcode
save temp2, replace

use rt001,clear
gen str6 hh=psu+hhold
gen double hhcode=real(hh)
keep psu hhold hhcode stratum urbanrur wgt_new s06a_q21
sort hhcode
merge hhcode using temp2
tab _m
drop _m
save housing_rent_hies2010,replace

use housing_rent_hies2010.dta,clear
gen urbrural=1 if urbanrur==1 | urbanrur==3
replace urbrural=2 if urbrural==.
keep hhcode urbrural rent imprent s06a_q21
sort hhcode
save temp3,replace

use expn_hies2010.dta, clear
gen hhcode=real(hhid)
keep hhcode  stratum wgt_new  member cons_exp p_cons food_expnd income p_income
gen nf_exp=cons_exp-food_expnd
rename food_expnd f_exp
gen popwgt=member*wgt_new
label var popwgt "population wgt_new"
label var wgt_new "hhold wgt_new"
tab stratum, gen(st)
sort hhcode
save temp4, replace
use temp4,clear

merge hhcode using temp3
tab _m
drop _m
sort hhcode

merge hhcode using temp2
tab _m
drop _m
sort hhcode

merge hhcode using temp1
tab _m
drop _m
gen lnrent=log(rent)
gen lnimprent=log(imprent)
gen lnincome=log(p_income)


* Distribution of rent by stratum *
* all strata have at least 8 observations *
reg lnrent st1-st15  lnroom -  lndwsize [aw=wgt_new]
reg lnimprent st1-st15  lnroom -  lndwsize [aw=wgt_new]

* constructing data sets for chow test *
gen dum1=(rent>0 & rent~=.)
gen dum2=(imprent>0 & imprent~=.)

foreach x of varlist st1-st15 lnroom-lndwsize {
	gen `x'_1=`x'*dum1
	replace `x'_1=. if dum1==1 & dum2==1
	gen `x'_2=`x'*dum2
	replace `x'_2=. if dum1==1 & dum2==1
}


gen lnrent_imprent=lnrent if dum1==1
replace lnrent_imprent=lnimprent if dum2==1
replace lnrent_imprent=. if dum1==1 & dum2==1
reg lnrent_imprent st1_1 - lndwsize_2 dum1 dum2 [aw=wgt_new], noconstant

test _b[dum1]=_b[dum2]
local varname "st1 st2 st3 st4 st5 st6 st7 st8 st9 st10 st11 st12 st13 st14 st15 lnroom dining kitchen brickwall tapwater electricity telephone lndwsize" 
foreach x of local varname {
test _b[`x'_1]=_b[`x'_2], accum
}
* both models are very different *


* use both rent and imprent and estimate regressions by stratum *

egen trent=rsum(rent imprent) if rent~=. | imprent~=.
gen lntrent=log(trent)
gen lntrenthat=.

* average characteristics *
sum lnroom - lndwsize lnincome [aw=wgt_new]
foreach z of varlist lnroom - lndwsize lnincome {
	sum `z' [aw=wgt_new]
	gen a_`z'=r(mean)
}	

* run the housing rent regressions for each stratum *
* get predicted rents and replace missing rent/imputed rent by predicted rents: lntrenthat *
* evaluate predicted rents at a set of national average characteristics: avlnrent *
capture drop hat
gen avlnrent=.
forvalues x = 1/16 {
*	reg lntrent lnroom -  lndwsize lnincome [aw=wgt] if stratum05==`x' & lntrent<=11.6952
	reg lntrent lnroom -  lndwsize lnincome [aw=wgt_new] if stratum==`x' 
	predict hat if stratum==`x'
	replace avlnrent=_b[_cons]+a_lnroom*_b[lnroom]+a_dining*_b[dining]+a_kitchen*_b[kitchen]+a_brickwall*_b[brickwall]+a_tapwater*_b[tapwater]+a_electricity*_b[electricity]+a_telephone*_b[telephone]+a_lndwsize*_b[lndwsize]+a_lnincome*_b[lnincome] if stratum==`x'
	replace lntrenthat=hat if stratum==`x'
	drop hat 
}

gen pr_trent=exp(lntrenthat)
gen trent2=trent
replace trent2=pr_trent if rent==. & imprent==.
label var trent2 "use predicted rents if housing rents are not reported"
gen phouse=exp(avlnrent)
label var phouse "housing rent at average characteristics"

* housing price index *
* there is no variation below stratum *
* Stratum level *
sum phouse [aw=wgt_new]
gen PIhouse=phouse/r(mean)
label var PIhouse "PIhouse (at stratum)"

* comparison of all housing PIs *
table stratum [aw=wgt_new], c(m PIhouse)

*****************************************************************************************************
* adjustment for consumption expenditures for households who did not report rents nor imputed rents *
*****************************************************************************************************
gen cons_exp2=cons_exp
replace cons_exp2=cons_exp+pr_trent/12 if rent==. & imprent==.
gen nf_exp2=nf_exp
replace nf_exp2=nf_exp+pr_trent/12 if rent==. & imprent==. 

gen p_nfcons=nf_exp/member
gen p_fcons=f_exp/member
gen income2=income 
replace income2=income+pr_trent/12 if  (imprent==. | imprent==0) & s06a_q21==1 
gen p_income2=income2/member

label var p_nfcons "pc nfexp excl pr_rents"
label var p_fcons "pc fexp excl pr_rents"
gen p_cons2=cons_exp2/member
gen p_nfcons2=nf_exp2/member
gen p_fcons2=f_exp/member
label var cons_exp2 "cons_exp2=add predicted rents for hhlds who didn't report rents nor imrent"
label var p_cons2 "per capita cons exp including predicted rents"
label var p_nfcons2 "per capita nfexp including prediced rents"
label var p_fcons2 "per capita fexp including predicted rents"
label var p_income2 "per capita income including predicted rents"


* Monthly expenses for rents *
* hhlds *
gen hsvalhh=rent/12 
replace hsvalhh=imprent/12 if hsvalhh==.
replace hsvalhh=pr_trent/12 if hsvalhh==.
label var hsvalhh "monthly rents (rent, imprent, pr_rent) for hhld"
* psu *
*destring hhold, replace
*gen psu = floor(hhold/10000000)
egen hsvalpsu=median(hsvalhh), by(psu)
label var hsvalpsu "median monthly rents by PSU *
* stratum *
egen hsvalst=median(hsvalhh), by(stratum)
label var hsvalst "median monthly rents by Stratum"
sum hsvalhh hsvalpsu hsvalst p_cons2 [aw=wgt_new]

keep hhcode urbrural PIhouse wgt_new rent imprent cons_exp* income* p_income*  p_cons* p_nfcons* p_fcons* member stratum hsval* pr_trent

* To keep using the old programs *
gen hhpindhs=PIhouse 
gen psupindhs=PIhouse
gen stpindhs=PIhouse
sum [aw=wgt_new]
table stratum [aw=wgt_new], c(m hhpindhs m psupindhs m stpindhs)
sort hhcode
save PIhouse2010.dta, replace 
*log close
