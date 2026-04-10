set more off

*===============================================================================
* PROJECT: SRI LANKA SCD
* Data: HIES 2006-07
* Date: 4th November 2014
* Author: 
* Lidia Ceriani (lceriani@worldbank.org)

* on previous dofiles, by 
* Shiva (shiva18@gmail.com)
* Susan Razzaz (srazzaz@worldbank.org)
* Giovanni Vecchi

* This dofile: Create Consumption Aggregate, using 2002 as model
*===============================================================================
global dir  "C:\Users\wb436991\Box Sync\WB\SAR_Sri_Lanka\Data\HIES\HIES_2006_07\"
global data "${dir}\Data_processed"
global out	"${dir}\Data_processed\poverty"

* Create temporary filenames for later use
*-------------------------------------------------------------------------------
tempfile 200607_sec_1_all_demographic 200607_sec_1_demographic 200607_hh_master 200607_food ///
	     200607_food_hh 200607_hh_mastercon 200607_monthly_nf 200607_hh_nfood 200607_sbexp 200607_sbexp_hh ///
	     200607_hh_pcexp 200607_f_major 200607_nf_major ashare0 pricefdb0 pricep0 priced0 pricen0 priceshare0 ///
		 200607_inflation 

*===============================================================================
* Slected variables from the HOUSEHOLD ROSTER
*===============================================================================
use "${data}\sec_1_demographic.dta", clear

* result = 1 if questionnaire fully completed
*-------------------------------------------------------------------------------
drop if result!=1

* Drop members not in the households
*-------------------------------------------------------------------------------
drop if person_serial_no >=40

*Province (1 digit District code)
*-------------------------------------------------------------------------------
gen province=int(district/10)
label var province "Province"

collapse (mean) province district sector psu month (count) person_serial_no, by(hhid)
rename  person_serial_no hhsize

label var district "District"
label values district districtlabel

label var sector "Setor"
label values sector sectorlabel

label var month "month of enumeration"

save `200607_hh_master', replace

* Add weighting factors
*-------------------------------------------------------------------------------
use `200607_hh_master', clear

merge m:1 district psu using "${data}/hies2006_inflation"
assert _m == 3
drop _m

rename  inflationfactor weight
save `200607_hh_master', replace

*===============================================================================
* FOOD Expenditure
*===============================================================================
use "${data}/sec_4_1_food_exp", clear

* Rename some variables to use old dofile
*-------------------------------------------------------------------------------
rename quantity qty
rename code itc

* result = 1 if questionnaire fully completed
*-------------------------------------------------------------------------------
keep if result==1

mvencode qty value inkind_value, mv(0) override

* Group items in broader categories
*-------------------------------------------------------------------------------
#delimit ; 
recode itc 	(101/129=1 cereals)
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
gen mfkind 		= (inkind_value/7) 	* 30
gen mlt_val		= (val/7)			* 30 if (itc>=1901 & itc<=1924)
gen mlt_qty		= (qty/7)			* 30 if (itc>=1901 & itc<=1924)
gen mlt_kind	= (inkind_value/7)	* 30 if (itc>=1901 & itc<=1924)

gen mfkind_trim = mfkind if (mf_code !=1 & mf_code !=3)

lab var mfval 	 "Monthly Food Value"
lab var mfquant  "Monthly Food Quantity"
lab var mfkind 	 "Monthly Imputed Value"
lab var mlt_val  "Monthly Liquor Tobacco Value"
lab var mlt_qty	 "Monthly Liquor Tabacco Quantity"
lab var mlt_kind "Monthly Liquor Tobacco Imputed Value"

mvencode mlt_val mlt_qty mlt_kind mfkind_trim mfkind* , mv(0) override

keep  hhid  district mfval mfquant mfkind* mlt_val mlt_qty mlt_kind itc mf_code 
sort hhid
save `200607_food', replace

collapse (sum) mfval mfkind* mlt_val mlt_kind, by(hhid)
sort hhid
save `200607_food_hh', replace

* Note: includes food, beverages, liqor, drugs, tobacco.  
* Quantity excludes items for which quantity not included, but these are included in values.

* add variables from household roster
*-------------------------------------------------------------------------------
use `200607_hh_master', clear
merge 1:1 hhid using `200607_food_hh'
assert _m == 3
drop _m

save `200607_hh_master', replace

*===============================================================================
* create file with NONFOOD expenditures
*===============================================================================
use "${data}/sec_4_2_nonfood", clear

keep if result==1

* Rename some variables to use old dofile
*-------------------------------------------------------------------------------
rename  nf_inkind_value nf_inkind

gen 	mfact = 1 	if 	(nf_code < 3000)|(nf_code > 3400 & nf_code < 3500)
replace mfact = 6 	if 	 nf_code > 3000 & nf_code < 3300 
replace mfact = 12 	if 	(nf_code > 3300 & nf_code < 3400)|(nf_code > 3500 & nf_code < 3510)
lab var mfact "month factor"

replace nf_value 	= 0 if missing(nf_value)
replace nf_inkind 	= 0 if missing(nf_inkind)

gen mnf_val 		= nf_value / mfact
lab var mnf_val 	"Monthly non food value"

gen mnf_kval 		= nf_inkind / mfact
lab var mnf_kval 	"Monthly non food imputed value"

gen mnf_qty 		= nf_quantity/ mfact
lab var mnf_qty	 	"Monthly non food quantity"

* Group items in broader categories
*-------------------------------------------------------------------------------
#delimit ; 
recode nf_code 	(2001/2003=1 housing)
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
			(3301/3339=14 durable_12m)
			(3401/3509=15 savings_plus_rare)
			, 
			gen(mnf_code) ;
#delimit cr

/*
* exclude items that are usually excluded (Deaton & Zaidi 2002
* ------------------------------------------------------------------------------
drop if nf_code >= 3301 &  nf_code <= 3509

* exclude items that were included in 2009 (but not in 2002)
* ------------------------------------------------------------------------------
drop if nf_code == 3506 // purchased properties houses
drop if nf_code == 3507 // loans given

* exclude items for which recall period has changed between 2002 and 2009
* ------------------------------------------------------------------------------ 
drop if nf_code == 3501 // wedding and funerals
drop if nf_code == 3502 // social acctivities/cerimonies
drop if nf_code == 3503 // litigation
*/

*===============================================================================
* Create a sub-aggregate which contains all items to be dropped for comparability
* with respect to previous years
*===============================================================================
gen itc=nf_code
 
#delimit ;
gen drop_for_comparability = (itc >= 3301 &   itc <= 3509) 
							| itc==3506 
							| itc==3507
							| itc==3501
							| itc==3502
							| itc==3503 ;
#delimit cr

gen 	mnf_val_drop 	= mnf_val if drop_for_comparability==1
gen 	mnf_kval_trim 	= mnf_kval if itc <3300

*===============================================================================

keep 	hhid mnf_qty mnf_val* mnf_kval* nf_code mnf_code
save 	`200607_monthly_nf', replace


collapse (sum) mnf_val* mnf_kval*, by(hhid)
save `200607_hh_nfood', replace


* add variables from household roster and food
*-------------------------------------------------------------------------------
use `200607_hh_master', clear
merge 1:1 hhid using `200607_hh_nfood'
assert _m == 3
drop _m 
save `200607_hh_master', replace

*===============================================================================
* SERVANT BOARDERS
*===============================================================================

use "${data}/sec_4_3_boardersV2", clear

drop if result ~= 1

mvencode col_3 col_4 col_5 col_6 col_7 col_8 col_9 ///
 col_10 col_11 col_12 col_13 col_14 col_15, mv(0) override


gen mfood = (col_3/7) * 30
lab var mfood "sb monthly food"

gen mfuel = col_4
lab var mfuel "sb monthly fuel"

gen mcloth = col_5 / 6
lab var mcloth "sb monthly cloth"

gen mndur = col_6
lab var mndur "sb monthly non durable"

gen mserv = col_7
lab var mserv "sb monthly hh service"

gen mperson = col_8
lab var mperson "sb monthly personal"

gen mtrans = col_9
lab var mtrans " sb monthly transport"

gen mentert = col_10
lab var mentert "sb monthly entertain"

gen mdurab = col_11 / 12
lab var mdurab "sb monthly durable"

gen mboard = col_12
lab var mboard "sb monthly boarding fees"

gen mtfamily = col_13
lab var mtfamily "sb monthly transfer to family"

gen msaving = col_14
lab var msaving "sb monthly savings"

gen mmisc = col_15
lab var mmisc "sb monthly other exp"

keep hhid mfood mfuel mcloth mndur ///
 mserv mperson mtrans mentert mdurab mboard mtfamily msaving mmisc

gen sb_food = mfood
gen sb_nfood= mfuel + mcloth + mndur + mserv + mperson + mtrans + mentert + mdurab + mboard + mtfamily + msaving + mmisc
gen sb_exp = mfood + sb_nfood


save `200607_sbexp', replace

collapse (sum) 	mfood mfuel mcloth mndur mserv mperson ///
				mtrans mentert mdurab mboard mtfamily  ///
				msaving mmisc sb_food sb_nfood sb_exp, by(hhid)
sort hhid

save `200607_sbexp_hh', replace

* add variables from household roster, food and nonfood
*-------------------------------------------------------------------------------
use `200607_hh_master', clear

merge 1:1 hhid using `200607_sbexp_hh'
drop if _m==2
drop _m

keep  	hhid province district sector psu* month hhsize ///
		mfval mfkind*  		///
		mlt_val mlt_kind 	///
		mnf_val* mnf_kval* 	///
		sb_food sb_nfood sb_exp  /// 
		weight

mvencode mfval mfkind mnf_val* mnf_kval* sb_food sb_nfood sb_exp mlt_val mlt_kind, mv(0) override

gen  tm_food= mfval-mlt_val+ sb_food
lab var tm_food "Total monthly food expenditure, excl liq Tob"

gen  tm_nfood= mlt_val+ mnf_val+ sb_nfood
lab var tm_nfood "Total monthly non food expenditure, incl liq Tob"

gen  tm_kfood= mfkind-mlt_kind
lab var tm_kfood "Total monthly food expenditure in kind, excl liq Tob"

gen  tm_kfood_trim = mfkind_trim-mlt_kind
lab var tm_kfood_trim "Total monthly trimmed food expenditure in kind, excl liq Tob"

gen  tm_knfood= mlt_kind+ mnf_kval
lab var tm_knfood "Total monthly non food expenditure in kind, incl liq Tob"

gen  tm_knfood_trim= mlt_kind+ mnf_kval_trim
lab var tm_knfood_trim "Total monthly trimmed non food expenditure in kind, incl liq Tob"

save `200607_hh_master', replace

gen ncons = mfval + mnf_val + sb_exp
label var ncons "nominal consumption expenditure (Rupees/month/household)"

gen popwt =  hhsize * weight
label var popwt "population weights"

gen npccons = ncons / hhsize
label var npccons "nominal consumption expenditure (Rupees/month/person)"

xtile npcexpd = npccons [aw=popwt], nq(10)
lab var npcexpd " Nominal Per capita decile"

save `200607_hh_master', replace

*-------------------------------------------------------------------------------
* create a consumption file with nominal deciles for price index reference group
*-------------------------------------------------------------------------------
keep hhid weight popwt npccons npcexpd
save `200607_hh_pcexp', replace



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

use `200607_food', clear
merge m:1 hhid using `200607_hh_pcexp'
keep if _m==3
drop _m

keep if npcexpd >=2 & npcexpd<=4
keep if itc <1900  /*do not use liquor,drugs,tobocco for food baskets*/
keep if mfquant~=. & mfquant~=0  

foreach mcode of numlist 119 202 213 214 215 219 309 430 439 459 501 509 609 819 909 ///
	1112 1113 1114 1115 1116 1117 1118 1119 1120 1121 1122 1123 1129 1201 1202 1203 ///	
	1204 1205 1206 1209 1304 1305 1319 1409 1504 1509 1619 1659 1702 1706 1719 1803 1804 1819 {
 qui drop if itc == `mcode' 
}
 
*step to include all selected items to each household by reshape wide and then reshape long
*-------------------------------------------------------------------------------
keep hhid mfval itc
rename mfval v
reshape wide v, i(hhid) j(itc)

recode v* (missing = 0)
keep v* hhid
reshape long v, i(hhid) j(itc)

*recode v* (missing = 0)
*-------------------------------------------------------------------------------
mvencode v, mv(0) override 

* generate average share of each selected items 
* and keep only items having share greater than 0.001
*------------------------------------------------------------------------------- 
egen fdexp=sum(v), by(hhid)
gen ashare=v/fdexp

merge m:1 hhid using `200607_hh_pcexp'
keep if _m==3  
drop _m

collapse (mean) ashare [aw=popwt], by(itc)
sort ashare
keep if ashare>=0.001 
sort itc
save `ashare0', replace 

* Note: 
* ashare0 is average share of item in monthly PURCHASED consumption for each item 
* amongst households in the 20-40th percentiles

*Create national avg quantity consumed by 20-40th percentile for food items
*-------------------------------------------------------------------------------
use `200607_food', clear
merge m:1 hhid using `200607_hh_pcexp'

keep if _m==3
drop _m
keep if npcexpd >=2 & npcexpd<=4
keep if itc<1900  /*do not use liquor,drugs,tobocco for food baskets*/
keep if mfquant~=. & mfquant~=0  
foreach mcode of numlist 119 202 213 214 215 219 309 430 439 459 501 509 609 819 909 ///
	1112 1113 1114 1115 1116 1117 1118 1119 1120 1121 1122 1123 1129 1201 1202 1203 ///
	1204 1205 1206 1209 1304 1305 1319 1409 1504 1509 1619 1659 1702 1706 1719 1803 1804 1819 {
 	qui drop if itc == `mcode' 
}

merge m:1 itc using `ashare0'
keep if _m==3  /*drops residual items or items with minimal budget share*/
drop _m

keep hhid mfquant itc
rename mfquant q
reshape wide q, i(hhid) j(itc)

mvencode q*, mv(0) override

merge m:1 hhid using `200607_hh_pcexp'
keep if _m==3
drop _m

collapse (mean) q* [aw=popwt]
gen id=1
reshape long q, i(id) j(itc)
drop id
sort itc
save `pricefdb0', replace

*Note: q's are national avg quantity consumed by 20-40th percentile for food items

* Create district median price by replacing province level median prices where 
* there is no district prices
*-------------------------------------------------------------------------------

* PROVINCE level median unit value
*-------------------------------------------------------------------------------
use `200607_food', clear

*sort hhid
*merge hhid using `200607_hh_pcexp'
merge m:1 hhid using `200607_hh_pcexp'

keep if _m==3
drop _m

keep if npcexpd >=2 & npcexpd<=4
keep if itc<1900  /*do not use liquor,drugs,tobocco for food baskets*/
keep if mfquant~=. & mfquant~=0
foreach mcode of numlist 119 202 213 214 215 219 309 430 439 459 501 509 609 819 909 ///
	1112 1113 1114 1115 1116 1117 1118 1119 1120 1121 1122 1123 1129 1201 1202 1203 ///
	1204 1205 1206 1209 1304 1305 1319 1409 1504 1509 1619 1659 1702 1706 1719 1803 1804 1819 {
	qui drop if itc == `mcode' 
}


merge m:1 itc using `ashare0'

keep if _m==3
drop _m

gen ph=mfval/mfquant  /*household level price*/
gen province=int(district/10)
collapse (median) php=ph [aw=weight], by(province itc)
keep province php itc
rename php pp
sort province itc
save `pricep0', replace /*province level median price*/

* DISTRICT level median unit value
*-------------------------------------------------------------------------------
use `200607_food', clear

merge m:1 hhid using `200607_hh_pcexp'
keep if _m==3
drop _m

keep if npcexpd >=2 & npcexpd<=4
keep if itc<1900  /*do not use liquor,drugs,tobocco for food baskets*/
keep if mfquant~=. & mfquant~=0
foreach mcode of numlist 119 202 213 214 215 219 309 430 439 459 501 509 609 819 909 ///
	1112 1113 1114 1115 1116 1117 1118 1119 1120 1121 1122 1123 1129 1201 1202 1203 ///
	1204 1205 1206 1209 1304 1305 1319 1409 1504 1509 1619 1659 1702 1706 1719 1803 1804 1819 {
	qui drop if itc == `mcode' 
}

*sort itc
*merge itc using `ashare0'
merge m:1 itc using `ashare0'

keep if _m==3
drop _m

gen ph=mfval/mfquant  /*household level price*/

collapse (median) phd=ph [aw=weight], by(district itc)
keep district phd itc
rename phd p

/*reshape district wise item price to replace missing values by zero and then by province median price*/ 
reshape wide p, i(district) j(itc)
*recode p* (missing = 0)
qui mvencode p*, mv(0) override

reshape long p, i(district) j(itc)
gen province=int(district/10)

*sort province itc
*merge province itc using `pricep0'
merge m:1 province itc using `pricep0'

keep if _m==3
drop _m

replace p=pp if p==0  /*replace district price with province price*/
rename p pd
drop pp province
sort district itc
save `priced0', replace /*district level median price*/

* NATIONAL level median unit value
*-------------------------------------------------------------------------------
set more off
use `200607_food', clear

merge m:1 hhid using `200607_hh_pcexp'
keep if _m==3
drop _m

keep if npcexpd >=2 & npcexpd<=4
keep if itc<1900  /*do not use liquor,drugs,tobocco for food baskets*/
keep if mfquant~=. & mfquant~=0
foreach mcode of numlist 119 202 213 214 215 219 309 430 439 459 501 509 609 819 909 ///
	1112 1113 1114 1115 1116 1117 1118 1119 1120 1121 1122 1123 1129 1201 1202 1203 ///
	1204 1205 1206 1209 1304 1305 1319 1409 1504 1509 1619 1659 1702 1706 1719 1803 1804 1819 {
	qui drop if itc == `mcode' 
}

merge m:1 itc using `ashare0'
keep if _m==3
drop _m

gen ph=mfval/mfquant  /*household level price*/
collapse (median) pn=ph [aw=weight], by(itc) /*national median price for each item*/
sort itc
save `pricen0', replace

*-------------------------------------------------------------------------------
* PLUTOCTATIC INDEX (cpi_plu)
* spatial price index cpi_plu relative to national cost of living
*-------------------------------------------------------------------------------

use `priced0'
merge m:1 itc using `pricefdb0'
keep if _m==3
drop _m
merge m:1 itc using `pricen0'
keep if _m==3  
drop _m

keep if q~=. & q~=0
gen qpd=q*pd
gen qpn=q*pn
collapse (sum) qpd qpn, by(district)
gen cpi_plu=qpd/qpn
list district cpi_plu
drop qpd qpn
merge m:1 district using "${out}/hies2006_dist_cpi"
keep if _m==3
drop _m
sort district
save "${out}/hies2006_dist_cpi_all", replace


*-------------------------------------------------------------------------------
* DEMOCRATIC INDEX (cpi_dem)
* average HH level expenditure share as weights for calculating spatial price 
* index2 democratic
*-------------------------------------------------------------------------------
set more off
use `200607_food', clear
merge m:1 hhid using `200607_hh_pcexp'
keep if _m==3
drop _m

keep if npcexpd >=2 & npcexpd<=4
keep if itc<1900  /*do not use liquor,drugs,tobocco for food baskets*/
keep if mfquant~=.
/*residual items*/
foreach mcode of numlist 119 202 213 214 215 219 309 430 439 459 501 509 609 819 909 ///
	1112 1113 1114 1115 1116 1117 1118 1119 1120 1121 1122 1123 1129 1201 1202 1203 ///
	1204 1205 1206 1209 1304 1305 1319 1409 1504 1509 1619 1659 1702 1706 1719 1803 1804 1819 {
	qui drop if itc == `mcode' 
}

merge m:1 itc using `ashare0'

keep if _m==3
drop _m
keep hhid mfval itc
rename mfval v
reshape wide v, i(hhid) j(itc)
recode v* (missing = 0)
keep v* hhid
reshape long v, i(hhid) j(itc)
mvencode v, mv(0) override

sort hhid
egen fdexp=sum(v), by(hhid)
gen share=v/fdexp 
merge m:1 hhid using `200607_hh_pcexp'

keep if _m==3
drop _m
collapse (mean) share [aw=popwt], by(itc)
sort itc
save `priceshare0', replace

* Note: variable share is the share in selected items and ashare is share in all items

clear
use `priced0'
*sort itc
*merge itc using `priceshare0'
merge m:1 itc using `priceshare0'

keep if _m==3
drop _m
*sort itc
*merge itc using `pricen0'
merge m:1 itc using `pricen0'

keep if _m==3 
drop _m
gen rprice=pd/pn
gen cpi_dem=share*rprice
collapse (sum) cpi_dem, by(district)
list district cpi_dem

merge m:1 district using "${out}/hies2006_dist_cpi_all"

keep if _m==3
drop _m
save "${out}/hies2006_dist_cpi_all", replace


*===============================================================================
* merge spatial price index with consumption dataset
*===============================================================================

use `200607_hh_master', clear
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

merge m:1 district using "${out}/hies2006_dist_cpi_all" 
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

save `200607_hh_master', replace

*===============================================================================
* Define poverty line as in DCS and save Consumption Aggregate
*===============================================================================
gen pov_line = 2233
label var pov_line "DCS poverty line (Rupees/month/person)"
gen poor = (rpccons < pov_line)
label var poor "=1 if poor, 0 otherwise"

sort hhid
save "${out}\wfile200607", replace

*===============================================================================
* Create EXPENDITURE CATEGORIES
*===============================================================================
* FOOD
*-------------------------------------------------------------------------------
use `200607_food', clear
rename  mf_code mc
rename mfval fval
collapse (sum) fval, by(hhid mc)
sort hhid
reshape wide fval, i( hhid ) j( mc )
mvencode fval1 - fval19, mv(0) override
save `200607_f_major', replace

* NON FOOD
*-------------------------------------------------------------------------------
use `200607_monthly_nf', clear
rename  mnf_code mc
rename mnf_val val
collapse (sum) val, by(hhid mc)
sort hhid
reshape wide val, i( hhid ) j( mc )
mvencode val1-val13, mv(0) override
save `200607_nf_major', replace


* Merge file with major categories with consumption aggregate file
*-------------------------------------------------------------------------------
use "${out}\wfile200607", clear

merge 1:1 hhid using `200607_nf_major'
assert _m == 3
drop _m
merge 1:1 hhid using `200607_f_major'
assert _m == 3
drop _m

gen val16=sb_nfood
gen val17=mlt_val
gen val18=tm_food

forvalues v=1(1)19{
gen rpc_fval`v' = fval`v' / cpi_dcs / hhsize
}

forvalues v=1(1)16{
gen rpc_nfval`v' = val`v' / cpi_dcs / hhsize
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

rename val* nfval*

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

save "${out}\wfile200607", replace

exit


