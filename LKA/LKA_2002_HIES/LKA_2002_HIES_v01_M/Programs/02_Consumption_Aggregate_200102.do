set more off
*===============================================================================
* PROJECT: SRI LANKA SCD
* Data: HIES 2001/02
* Date: 7th November 2014
* Author: 
* Lidia Ceriani (lceriani@worldbank.org)

* on previous dofiles, by 
* Shiva (shiva18@gmail.com)
* Susan Razzaz (srazzaz@worldbank.org)
* Giovanni Vecchi

* This dofile: Create Consumption Aggregate
*===============================================================================
global dir  "C:\Users\wb436991\Box Sync\WB\SAR_Sri_Lanka\Data\HIES\HIES_2001_02\"
global data "${dir}\Data_processed"
global out	"${dir}\Data_processed\poverty"

* Create temporary filenames for later use
*-------------------------------------------------------------------------------
tempfile 2002_sec_1_all_demographic 2002_sec_1_demographic 2002_hh_master 2002_food ///
	     2002_food_hh 2002_hh_mastercon 2002_monthly_nf 2002_hh_nfood 2002_sbexp 2002_sbexp_hh ///
	     2002_hh_pcexp 2002_f_major 2002_nf_major ashare0 pricefdb0 pricep0 priced0 pricen0 priceshare0 ///
		 2002_inflation 

*===============================================================================
* Slected variables from the HOUSEHOLD ROSTER
*===============================================================================
use "${data}\Section_1.dta", clear

* rcode = 1 if questionnaire fully completed
*-------------------------------------------------------------------------------
drop if rcode!=1

* Drop members not in the households
*-------------------------------------------------------------------------------
drop if pno >=40

*Province (1 digit District code)
*-------------------------------------------------------------------------------
gen province=int(district/10)
label var province "Province"

collapse (mean) prov district sector psun month hweight (first) psuid (count) pno, by(hhid)
rename  pno hhsize
rename hweight weight
rename prov province
rename psun psu

label var province "Province"
label values province prov

label var district "District"
label values district districtlabel

label var sector "Sector"
label values sector sectorlabel

label var month "month of enumeration"

save `2002_hh_master', replace

*===============================================================================
* FOOD Expenditure
*===============================================================================
use "${data}/Section_21", clear

* rcode = 1 if questionnaire fully completed
*-------------------------------------------------------------------------------
keep if rcode==1

mvencode qty value, mv(0) override

* Group items in broader categories
*-------------------------------------------------------------------------------
#delimit ; 
recode item 	(101/129=1 cereals)
			(201/219=2 prepared_food)
			(301/319=3 pulses)
			(401/459=4 vegetable)
			(501/509=5 yams_and_other)
			(601/609=6 meat)
			(701/723=7 fish)
			(801/819=8 dried_fish)
			(901/909=9 eggs)
			(1001/1003=10 coconuts)
			(1101/1129=11 condiments)
			(1201/1209=12 other_food)
			(1301/1319=13 milk_diary)
			(1401/1409=14 fats_oils)
			(1501/1509=15 sugar__juggery_treacle)
			(1601/1659=16 fruits_fresh_dried)
			(1701/1719=17 confectionery_short_eats)
			(1801/1819=18 beverages_no_alcoholic)
			(1901/1924=19 liquor_drug_tobacco)
			, 
			gen(mf_code) ;
#delimit cr

* transform in PER MONTH
*-------------------------------------------------------------------------------
gen mfval 		= (val/7) 			* 30
gen mfquant 	= (qty/7) 			* 30
gen mlt_val		= (val/7)			* 30 if (item>=1901 & item<=1924)
gen mlt_qty		= (qty/7)			* 30 if (item>=1901 & item<=1924)

lab var mfval 	 "Monthly Food Value"
lab var mfquant  "Monthly Food Quantity"
lab var mlt_val  "Monthly Liquor Tobacco Value"
lab var mlt_qty	 "Monthly Liquor Tabacco Quantity"

mvencode mlt_val mlt_qty, mv(0) override

keep  hhid district mfval mfquant  mlt_val mlt_qty item mf_code
sort hhid
save `2002_food', replace

collapse (sum) mfval  mlt_val, by(hhid)
sort hhid
save `2002_food_hh', replace

* Note: includes food, beverages, liqor, drugs, tobacco.  
* Quantity excludes items for which quantity not included, but these are included in values.

* add variables from household roster
*-------------------------------------------------------------------------------
use `2002_hh_master', clear
merge 1:1 hhid using `2002_food_hh'
assert _m == 3
drop _m

save `2002_hh_master', replace

*===============================================================================
* create file with NONFOOD expenditures
*===============================================================================
use "${data}/Section_22", clear

keep if rcode==1

* Generate Monthly factor
*-------------------------------------------------------------------------------
gen 	mfact = 1 	if 	(item < 3000)|(item > 3400 & item < 3500)
replace mfact = 6 	if 	 item > 3000 & item < 3300 
replace mfact = 12 	if 	(item > 3300 & item < 3400)|(item > 3500 & item < 3510)
lab var mfact "month factor"

replace value 	= 0 if missing(value)

gen mnf_val 		= value / mfact
lab var mnf_val 	"Monthly non food value"

gen mnf_qty 		= qty/ mfact
lab var mnf_qty	 	"Monthly non food quantity"

* Group items in broader categories
*-------------------------------------------------------------------------------
#delimit ; 
recode item (2001/2004=1 housing)
			(2101/2119=2 fuel)
			(2201/2219=3 personal_care)
			(2301/2319=4 health)
			(2401/2419=5 transport)
			(2501/2509=6 communication)
			(2601/2619=7 education)
			(2701/2719=8 recreation)
			(2801/2809=9 household_goods)
			(2901/2909=10 household_service)
			(3001/3062=11 clothing)
			(3101/3109=12 footwear)
			(3201/3219=13 durable_6m)
			(3301/3329=14 durable_12m)
			(3401/3419=15 savings_plus_rare)
			, 
			gen(mnf_code) ;
#delimit cr

/*
* exclude items that are usually excluded (Deaton & Zaidi 2002)
* ------------------------------------------------------------------------------
drop if item == 2003
drop if item >= 3301 &  item <= 3419
*/

*===============================================================================
* Create a sub-aggregate which contains all items to be dropped for comparability
* with respect to previous years
*===============================================================================
gen drop_for_comparability = ((item >= 3301 &   item <= 3419) | item == 2003) 

gen 	mnf_val_drop 	= mnf_val if drop_for_comparability==1
*===============================================================================

keep 	hhid mnf_qty mnf_val* item mnf_code
save 	`2002_monthly_nf', replace


collapse (sum) mnf_val* , by(hhid)
save `2002_hh_nfood', replace


* add variables from household roster and food
*-------------------------------------------------------------------------------
use `2002_hh_master', clear
merge 1:1 hhid using `2002_hh_nfood'
assert _m == 3
drop _m 
save `2002_hh_master', replace

*===============================================================================
* SERVANT BOARDERS
*===============================================================================

use "${data}/Section_23", clear

drop if rcode ~= 1

mvencode r6c3 r6c4 r6c5 r6c6 r6c7 r6c8 r6c9 ///
 r6c10 r6c11 r6c12 r6c13 r6c14 r6c15, mv(0) override


gen mfood = (r6c3/7) * 30
lab var mfood "sb monthly food"

gen mfuel = r6c4
lab var mfuel "sb monthly fuel"

gen mcloth =  r6c5/ 6
lab var mcloth "sb monthly cloth"

gen mndur = r6c6
lab var mndur "sb monthly non durable"

gen mserv = r6c7
lab var mserv "sb monthly hh service"

gen mperson = r6c8
lab var mperson "sb monthly personal"

gen mtrans = r6c9
lab var mtrans " sb monthly transport"

gen mentert = r6c10
lab var mentert "sb monthly entertain"

gen mdurab = r6c12 / 12
lab var mdurab "sb monthly durable"

gen mboard = r6c13
lab var mboard "sb monthly boarding fees"

gen mtfamily = r6c14
lab var mtfamily "sb monthly transfer to family"

gen msaving = r6c15
lab var msaving "sb monthly savings"

gen mmisc = r6c11
lab var mmisc "sb monthly other exp"

keep hhid mfood mfuel mcloth mndur ///
 mserv mperson mtrans mentert mdurab mboard mtfamily msaving mmisc

gen sb_food = mfood
gen sb_nfood= mfuel + mcloth + mndur + mserv + mperson + mtrans + mentert + mdurab + mboard + mtfamily + msaving + mmisc
gen sb_exp = mfood + sb_nfood


save `2002_sbexp', replace

collapse (sum) 	mfood mfuel mcloth mndur mserv mperson ///
				mtrans mentert mdurab mboard mtfamily  ///
				msaving mmisc sb_food sb_nfood sb_exp, by(hhid)
sort hhid

save `2002_sbexp_hh', replace

* add variables from household roster, food and nonfood
*-------------------------------------------------------------------------------
use `2002_hh_master', clear

merge 1:1 hhid using `2002_sbexp_hh'
drop if _m==2
drop _m

keep  	hhid province district sector psu* month hhsize ///
		mfval   		///
		mlt_val 	///
		mnf_val* 	///
		sb_food sb_nfood sb_exp  /// 
		weight

mvencode mfval  mnf_val*  sb_food sb_nfood sb_exp mlt_val , mv(0) override

gen  tm_food= mfval-mlt_val+ sb_food
lab var tm_food "Total monthly food expenditure, excl liq Tob"

gen  tm_nfood= mlt_val+ mnf_val+ sb_nfood
lab var tm_nfood "Total monthly non food expenditure, incl liq Tob"

save `2002_hh_master', replace

gen ncons = mfval + mnf_val + sb_exp
label var ncons "nominal consumption expenditure (Rupees/month/household)"

gen popwt =  hhsize * weight
label var popwt "population weights"

gen npccons = ncons / hhsize
label var npccons "nominal consumption expenditure (Rupees/month/person)"

xtile npcexpd = npccons [aw=popwt], nq(10)
lab var npcexpd "Nominal Per capita decile"

save `2002_hh_master', replace

*-------------------------------------------------------------------------------
* create a consumption file with nominal deciles for price index reference group
*-------------------------------------------------------------------------------
keep hhid weight popwt npccons npcexpd
save `2002_hh_pcexp', replace



*===============================================================================
* Construct Spatial Deflators (plutocratic, democratic) + official one from DCS
*===============================================================================

* Construct various CPI for the analysis
*-------------------------------------------------------------------------------
* constuct national basket for spatial price index
* nominal pcexp deciles 2-4 as reference population
* use items with quantity info, but delete residual items
* average per capita consumption at national level as basket
* selection of items spent more at national level, at least budget share>=0.001
*-------------------------------------------------------------------------------

use `2002_food', clear
merge m:1 hhid using `2002_hh_pcexp'
keep if _m==3
drop _m

keep if npcexpd >=2 & npcexpd<=4
keep if item <1900  /*do not use liquor,drugs,tobocco for food baskets*/
keep if mfquant~=. & mfquant~=0  

foreach mcode of numlist 119 202 213 214 215 219 309 430 439 459 501 509 609 819 909 ///
	1113 1114 1115 1116 1117 1118 1119 1120 1121 1122 1123 1124 1129 1207 1208 1209 1210 1219 ///
	1303 1304 1319 1409 1504 1509 1612 1613 1614 1615 1616 1617 1618 1619 1620 1621 1622 1629 ///
	1659 1679 1702 1719 1804 1805 1812 1819 {
 qui drop if item == `mcode' 
}
 
*step to include all selected items to each household by reshape wide and then reshape long
*-------------------------------------------------------------------------------
keep hhid mfval item
rename mfval v
reshape wide v, i(hhid) j(item)

recode v* (missing = 0)
keep v* hhid
reshape long v, i(hhid) j(item)

*recode v* (missing = 0)
*-------------------------------------------------------------------------------
mvencode v, mv(0) override 

* generate average share of each selected items 
* and keep only items having share greater than 0.001
*------------------------------------------------------------------------------- 
egen fdexp=sum(v), by(hhid)
gen ashare=v/fdexp

merge m:1 hhid using `2002_hh_pcexp'
keep if _m==3  
drop _m

collapse (mean) ashare [aw=popwt], by(item)
sort ashare
keep if ashare>=0.001 
sort item
save `ashare0', replace 

* Note: 
* ashare0 is average share of item in monthly PURCHASED consumption for each item 
* amongst households in the 20-40th percentiles

*Create national avg quantity consumed by 20-40th percentile for food items
*-------------------------------------------------------------------------------
use `2002_food', clear
merge m:1 hhid using `2002_hh_pcexp'

keep if _m==3
drop _m
keep if npcexpd >=2 & npcexpd<=4
keep if item<1900  /*do not use liquor,drugs,tobocco for food baskets*/
keep if mfquant~=. & mfquant~=0  
foreach mcode of numlist 119 202 213 214 215 219 309 430 439 459 501 509 609 819 909 ///
	1113 1114 1115 1116 1117 1118 1119 1120 1121 1122 1123 1124 1129 1207 1208 1209 1210 1219 ///
	1303 1304 1319 1409 1504 1509 1612 1613 1614 1615 1616 1617 1618 1619 1620 1621 1622 1629 ///
	1659 1679 1702 1719 1804 1805 1812 1819 {
 	qui drop if item == `mcode' 
}

merge m:1 item using `ashare0'
keep if _m==3  /*drops residual items or items with minimal budget share*/
drop _m

keep hhid mfquant item
rename mfquant q
reshape wide q, i(hhid) j(item)

mvencode q*, mv(0) override

merge m:1 hhid using `2002_hh_pcexp'
keep if _m==3
drop _m

collapse (mean) q* [aw=popwt]
gen id=1
reshape long q, i(id) j(item)
drop id
sort item
save `pricefdb0', replace

*Note: q's are national avg quantity consumed by 20-40th percentile for food items

* Create district median price by replacing province level median prices where 
* there is no district prices
*-------------------------------------------------------------------------------

* PROVINCE level median unit value
*-------------------------------------------------------------------------------
use `2002_food', clear

*sort hhid
*merge hhid using `2002_hh_pcexp'
merge m:1 hhid using `2002_hh_pcexp'

keep if _m==3
drop _m

keep if npcexpd >=2 & npcexpd<=4
keep if item<1900  /*do not use liquor,drugs,tobocco for food baskets*/
keep if mfquant~=. & mfquant~=0
foreach mcode of numlist 119 202 213 214 215 219 309 430 439 459 501 509 609 819 909 ///
	1113 1114 1115 1116 1117 1118 1119 1120 1121 1122 1123 1124 1129 1207 1208 1209 1210 1219 ///
	1303 1304 1319 1409 1504 1509 1612 1613 1614 1615 1616 1617 1618 1619 1620 1621 1622 1629 ///
	1659 1679 1702 1719 1804 1805 1812 1819 {
	qui drop if item == `mcode' 
}


*sort item
*merge item using `ashare0'
merge m:1 item using `ashare0'

keep if _m==3
drop _m

gen ph=mfval/mfquant  /*household level price*/
gen province=int(district/10)
collapse (median) php=ph [aw=weight], by(province item)
keep province php item
rename php pp
sort province item
save `pricep0', replace /*province level median price*/

* DISTRICT level median unit value
*-------------------------------------------------------------------------------
use `2002_food', clear

merge m:1 hhid using `2002_hh_pcexp'
keep if _m==3
drop _m

keep if npcexpd >=2 & npcexpd<=4
keep if item<1900  /*do not use liquor,drugs,tobocco for food baskets*/
keep if mfquant~=. & mfquant~=0
foreach mcode of numlist 119 202 213 214 215 219 309 430 439 459 501 509 609 819 909 ///
	1113 1114 1115 1116 1117 1118 1119 1120 1121 1122 1123 1124 1129 1207 1208 1209 1210 1219 ///
	1303 1304 1319 1409 1504 1509 1612 1613 1614 1615 1616 1617 1618 1619 1620 1621 1622 1629 ///
	1659 1679 1702 1719 1804 1805 1812 1819 {
	qui drop if item == `mcode' 
}


merge m:1 item using `ashare0'

keep if _m==3
drop _m

gen ph=mfval/mfquant  /*household level price*/

collapse (median) phd=ph [aw=weight], by(district item)
keep district phd item
rename phd p

/*reshape district wise item price to replace missing values by zero and then by province median price*/ 
reshape wide p, i(district) j(item)
qui mvencode p*, mv(0) override

reshape long p, i(district) j(item)
gen province=int(district/10)
merge m:1 province item using `pricep0'

keep if _m==3
drop _m

replace p=pp if p==0  /*replace district price with province price*/
rename p pd
drop pp province
sort district item
save `priced0', replace /*district level median price*/

* NATIONAL level median unit value
*-------------------------------------------------------------------------------
set more off
use `2002_food', clear

merge m:1 hhid using `2002_hh_pcexp'
keep if _m==3
drop _m

keep if npcexpd >=2 & npcexpd<=4
keep if item<1900  /*do not use liquor,drugs,tobocco for food baskets*/
keep if mfquant~=. & mfquant~=0
foreach mcode of numlist 119 202 213 214 215 219 309 430 439 459 501 509 609 819 909 ///
	1113 1114 1115 1116 1117 1118 1119 1120 1121 1122 1123 1124 1129 1207 1208 1209 1210 1219 ///
	1303 1304 1319 1409 1504 1509 1612 1613 1614 1615 1616 1617 1618 1619 1620 1621 1622 1629 ///
	1659 1679 1702 1719 1804 1805 1812 1819 {
	qui drop if item == `mcode' 
}

merge m:1 item using `ashare0'
keep if _m==3
drop _m

gen ph=mfval/mfquant  /*household level price*/
collapse (median) pn=ph [aw=weight], by(item) /*national median price for each item*/
sort item
save `pricen0', replace

*-------------------------------------------------------------------------------
* PLUTOCTATIC INDEX (cpi_plu)
* spatial price index cpi_plu relative to national cost of living
*-------------------------------------------------------------------------------

use `priced0'
merge m:1 item using `pricefdb0'
keep if _m==3
drop _m
merge m:1 item using `pricen0'
keep if _m==3  
drop _m

keep if q~=. & q~=0
gen qpd=q*pd
gen qpn=q*pn
collapse (sum) qpd qpn, by(district)
gen cpi_plu=qpd/qpn
list district cpi_plu
drop qpd qpn
merge m:1 district using "${out}/hies2002_dist_cpi"
keep if _m==3
drop _m
sort district
save "${out}/hies2002_dist_cpi_all", replace


*-------------------------------------------------------------------------------
* DEMOCRATIC INDEX (cpi_dem)
* average HH level expenditure share as weights for calculating spatial price 
* index2 democratic
*-------------------------------------------------------------------------------
set more off
use `2002_food', clear
merge m:1 hhid using `2002_hh_pcexp'
keep if _m==3
drop _m

keep if npcexpd >=2 & npcexpd<=4
keep if item<1900  /*do not use liquor,drugs,tobocco for food baskets*/
keep if mfquant~=.
/*residual items*/
foreach mcode of numlist 119 202 213 214 215 219 309 430 439 459 501 509 609 819 909 ///
	1113 1114 1115 1116 1117 1118 1119 1120 1121 1122 1123 1124 1129 1207 1208 1209 1210 1219 ///
	1303 1304 1319 1409 1504 1509 1612 1613 1614 1615 1616 1617 1618 1619 1620 1621 1622 1629 ///
	1659 1679 1702 1719 1804 1805 1812 1819 {
	qui drop if item == `mcode' 
}

merge m:1 item using `ashare0'

keep if _m==3
drop _m
keep hhid mfval item
rename mfval v
reshape wide v, i(hhid) j(item)
recode v* (missing = 0)
keep v* hhid
reshape long v, i(hhid) j(item)
mvencode v, mv(0) override

sort hhid
egen fdexp=sum(v), by(hhid)
gen share=v/fdexp 
merge m:1 hhid using `2002_hh_pcexp'

keep if _m==3
drop _m
collapse (mean) share [aw=popwt], by(item)
sort item
save `priceshare0', replace

* Note: variable share is the share in selected items and ashare is share in all items

clear
use `priced0'
*sort item
*merge item using `priceshare0'
merge m:1 item using `priceshare0'

keep if _m==3
drop _m
*sort item
*merge item using `pricen0'
merge m:1 item using `pricen0'

keep if _m==3 
drop _m
gen rprice=pd/pn
gen cpi_dem=share*rprice
collapse (sum) cpi_dem, by(district)
list district cpi_dem

merge m:1 district using "${out}/hies2002_dist_cpi_all"

keep if _m==3
drop _m
save "${out}/hies2002_dist_cpi_all", replace


*===============================================================================
* merge spatial price index with consumption dataset
*===============================================================================

use `2002_hh_master', clear
#delimit;
label define dis 		11"Colombo"
						12"Gampaha"
						13"Kalutara"
						21"Kandy"
						22"Matale"
						23"Nuwara Eliya"
						31"Galle"
						32"Matara"
						33"Hambantota"
						41"Jaffna"
						42"Mannar"
						43"Vavuniya"
						44"Mulaitivu"
						45"Kikinochchi"
						51"Batiacaloa"
						52"Ampara"
						53"Trincomalee"
						61"Kurunegala"
						62"Puttalam"
						71"Anuradhapura"
						72"Polonnaruwa"
						81"Badulla"
						82"Monaragala"
						91"Ratnapura"
						92"Kegalle";
#delimit cr
label values district dis

merge m:1 district using "${out}/hies2002_dist_cpi_all" 
assert _m == 3
drop _m

gen rcons = ncons / cpi_shiva
label var rcons "real consumption expenditure (Rupees/month/household)"

gen rpccons = rcons / hhsize
label var rpccons "real consumption expenditure (Rupees/month/person)"

replace mnf_val_drop = (mnf_val_drop / cpi_shiva)/ hhsize
label var mnf_val_drop 	"Real consumption expenditure, to be dropped for comparability (Rupees/month/person)"

xtile rpcexpd = rpccons [aw=popwt], nq(10)
lab var rpcexpd "Real Per capita decile"

label variable hhid "household key"
label variable province "Province"
label variable district "District"
label variable sector "Sector"
label variable psu "PSU Number"
label variable hhsize "Household size"
label variable weight "Household weight"
label variable popwt "Population weightt"
label variable cpi_shiva "Spatial price index (National=1)"
label variable mfval "Monthly food value incl liquor and tobacco"
label variable mnf_val "Monthly non food value as per schedule"
label variable mlt_val "Monthly liquor and tobacco expenditure"
label variable sb_food "Monthly food expenditure of servants and boarders"
label variable sb_nfood "Monthly non food expenditure of servants and boarders"
label variable sb_exp "Monthly food plus non food expenditure of servants and boarders"

save `2002_hh_master', replace

*===============================================================================
* Define poverty line as in DCS and save Consumption Aggregate
*===============================================================================
gen pov_line = 1423
label var pov_line "DCS poverty line (Rupees/month/person)"
gen poor = (rpccons < pov_line)
label var poor "=1 if poor, 0 otherwise"

sort hhid
save "${out}\wfile200102", replace

*===============================================================================
* Create EXPENDITURE CATEGORIES
*===============================================================================
* FOOD
*-------------------------------------------------------------------------------
use `2002_food', clear
rename  mf_code mc
rename mfval fval
collapse (sum) fval, by(hhid mc)
sort hhid
reshape wide fval, i( hhid ) j( mc )
mvencode fval1 - fval19, mv(0) override
save `2002_f_major', replace

* NON FOOD
*-------------------------------------------------------------------------------
use `2002_monthly_nf', clear
rename  mnf_code mc

rename mnf_val nfval
collapse (sum) nfval, by(hhid mc)
sort hhid
reshape wide nfval, i( hhid ) j( mc )
mvencode nfval1-nfval13, mv(0) override
save `2002_nf_major', replace


* Merge file with major categories with consumption aggregate file
*-------------------------------------------------------------------------------
use "${out}\wfile200102", clear

merge 1:1 hhid using `2002_nf_major'
assert _m == 3
drop _m
merge 1:1 hhid using `2002_f_major'
assert _m == 3
drop _m

gen nfval16=sb_nfood

forvalues v=1(1)19{
gen rpc_fval`v' = fval`v' / cpi_shiva / hhsize
}

forvalues v=1(1)16{
gen rpc_nfval`v' = nfval`v' / cpi_shiva / hhsize
}

lab var fval1	"Expenditure on Cereals (Rupee/month)"
lab var fval2	"Expenditure on Prepared Food (Rupee/month)" 
lab var fval3	"Expenditure on Pulses (Rupee/month)"
lab var fval4	"Expenditure on Vegetables (Rupee/month)"
lab var fval5	"Expenditure on Yams and Other (Rupee/month)"
lab var fval6	"Expenditure on Meat (Rupee/month)"
lab var fval7	"Expenditure on Fish (Rupee/month)"
lab var fval8	"Expenditure on Dried Fish (Rupee/month)"
lab var fval9	"Expenditure on Eggs (Rupee/month)"
lab var fval10	"Expenditure on Coconuts (Rupee/month)"
lab var fval11	"Expenditure on Condiments (Rupee/month)"
lab var fval12	"Expenditure on Other Foods (Rupee/month)"
lab var fval13	"Expenditure on Milk and Diary Product (Rupee/month)"
lab var fval14	"Expenditure on Fats and Oils (Rupee/month)"
lab var fval15	"Expenditure on Sugar, Juggery, Treacle (Rupee/month)"
lab var fval16	"Expenditure on Fruits (Rupee/month)"
lab var fval17	"Expenditure on Confectionery (Rupee/month)"
lab var fval18	"Expenditure on Bevereges (Rupee/month)"
lab var fval19	"Expenditure on Liquor, Drugs and Tobacco (Rupee/month)"

lab var rpc_fval1	"Expenditure on Cereals (Rupee/month/person, real)"
lab var rpc_fval2	"Expenditure on Prepared Food (Rupee/month/person, real)"
lab var rpc_fval3	"Expenditure on Pulses (Rupee/month/person, real)"
lab var rpc_fval4	"Expenditure on Vegetables (Rupee/month/person, real)"
lab var rpc_fval5	"Expenditure on Yams and Other (Rupee/month/person, real)"
lab var rpc_fval6	"Expenditure on Meat (Rupee/month/person, real)"
lab var rpc_fval7	"Expenditure on Fish (Rupee/month/person, real)"
lab var rpc_fval8	"Expenditure on Dried Fish (Rupee/month/person, real)"
lab var rpc_fval9	"Expenditure on Eggs (Rupee/month/person, real)"
lab var rpc_fval10	"Expenditure on Coconuts (Rupee/month/person, real)"
lab var rpc_fval11	"Expenditure on Condiments (Rupee/month/person, real)"
lab var rpc_fval12	"Expenditure on Other Foods (Rupee/month/person, real)"
lab var rpc_fval13	"Expenditure on Milk and Diary Product (Rupee/month/person, real)"
lab var rpc_fval14	"Expenditure on Fats and Oils (Rupee/month/person, real)"
lab var rpc_fval15	"Expenditure on Sugar, Juggery, Treacle (Rupee/month/person, real)"
lab var rpc_fval16	"Expenditure on Fruits (Rupee/month/person, real)"
lab var rpc_fval17	"Expenditure on Confectionery (Rupee/month/person, real)"
lab var rpc_fval18	"Expenditure on Bevereges (Rupee/month/person, real)"
lab var rpc_fval19	"Expenditure on Liquor, Drugs and Tobacco (Rupee/month/person, real)"

lab var nfval1  "Expenditure on housing (Rupee/month)"
lab var nfval2  "Expenditure on fuel (Rupee/month)"
lab var nfval3  "Expenditure on personal care (Rupee/month)"
lab var nfval4  "Expenditure on health (Rupee/month)"
lab var nfval5  "Expenditure on transport (Rupee/month)"
lab var nfval6  "Expenditure on communication (Rupee/month)"
lab var nfval7  "Expenditure on education (Rupee/month)"
lab var nfval8  "Expenditure on recreation (Rupee/month)"
lab var nfval9  "Expenditure on household goods (Rupee/month)"
lab var nfval10 "Expenditure on household service (Rupee/month)"
lab var nfval11 "Expenditure on clothing (Rupee/month)"
lab var nfval12 "Expenditure on footwear (Rupee/month)"
lab var nfval13 "Expenditure on durable category 6m (Rupee/month)"
lab var nfval14 "Expenditure on durable category 12m (Rupee/month)"
lab var nfval15 "Expenditure on savings and rare incidents (Rupee/month)" 
lab var nfval16 "Expenditure on non food by serv and board (Rupee/month)"

lab var rpc_nfval1  "Expenditure on housing (Rupee/month/person, real)"
lab var rpc_nfval2  "Expenditure on fuel (Rupee/month/person, real)"
lab var rpc_nfval3  "Expenditure on personal care (Rupee/month/person, real)"
lab var rpc_nfval4  "Expenditure on health (Rupee/month/person, real)"
lab var rpc_nfval5  "Expenditure on transport (Rupee/month/person, real)"
lab var rpc_nfval6  "Expenditure on communication (Rupee/month/person, real)"
lab var rpc_nfval7  "Expenditure on education (Rupee/month/person, real)"
lab var rpc_nfval8  "Expenditure on recreation (Rupee/month/person, real)"
lab var rpc_nfval9  "Expenditure on household goods (Rupee/month/person, real)"
lab var rpc_nfval10 "Expenditure on household service (Rupee/month/person, real)"
lab var rpc_nfval11 "Expenditure on clothing (Rupee/month/person, real)"
lab var rpc_nfval12 "Expenditure on footwear (Rupee/month/person, real)"
lab var rpc_nfval13 "Expenditure on durable category 6m (Rupee/month/person, real)"
lab var rpc_nfval14 "Expenditure on durable category 12m (Rupee/month/person, real)"
lab var rpc_nfval15 "Expenditure on savings and rare incidents (Rupee/month/person, real)" 
lab var rpc_nfval16 "Expenditure on non food by serv and board (Rupee/month/person, real)"

save "${out}\wfile200102", replace

exit


