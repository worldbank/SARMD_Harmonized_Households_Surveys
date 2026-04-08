clear all
****************************************************************************************************
								******IMPORTING ALL THE FILES******************
***************************************************************************************************
global comp "C:\Users\wb357339\Dropbox" 
*global comp "C:\Users\FF\Dropbox" 
global pricework "$comp\Shared Pak Poverty Work"
global data2011 "$pricework\PSLM 11-12\data"
global i2d2 "$pricework\I2D2"
global input1112 "$pricework\PSLM 11-12\data\raw data"
global output1112 "$pricework\Price Indices Work\Data Prep for Juan\2011-12"
global consump1112 "$pricework\PSLM 11-12\data\consumption"



*---Getting the hh identifiers and weights from plist----*
	use "$data2011\raw data\plist.dta", clear
	bys hhcode province region psu weight: keep if _n==1
	keep hhcode province region psu weight
	tempfile `plist'
	save plist, replace

*---Consumption Data is all in one file----*	
	use "$data2011\raw data\sec_6abcde.dta", clear
	drop if itc<1000
	isid hhcode itc
	merge m:1 hhcode province region psu using plist
	drop _m
	
	/*Very conservatively changing some outliers manually
	*firewood-3 exterme values	
		replace q1=1 if q1==.1 & itc==2701 & hhcode==1262010112
		replace q3=8 if q1==.8 & itc==2701 & hhcode==2152040113
		replace q1=1 if q1==.1 & itc==2701 & hhcode==3252040113

		*vegetable ghee-1 exterme value
		replace q1=5 if q1==.5 & itc==2302 & hhcode==1372010102
			
		*dal mash-1 exterme value-low end
		replace q1=5 if q1==50 & itc==2203 & hhcode==1011010312

		*dal chana-1 very low and 1 very high value
		replace q1=5 if q1==500 & itc==2202 & hhcode==1362010210
		replace v1=400 if v1==40 & itc==2202 & hhcode==1362010210
		*---the value is entered as q1 = 0.3, but in stata it is read as 0.30000001
		replace q1=3 if itc==2202 & hhcode==1131140102

		*chillies, one extreme value	
		replace q1=5 if q1==.5 & itc==1603 & hhcode==1061040212

		*salt, one extreme value
		replace q1=7 if q1==700 & itc==1601 & hhcode==1061040212
		replace v1=70 if v1==7 & itc==1601 & hhcode==1061040212

		*---vegetables have extreme values, dont know what to replace them with----*

		*cabbage as one extremely low value, dont know what to replace it with
			replace q1=2.5 if q1==25 & itc==1504 & hhcode==3051010307
			*replace v1= if v1==48 & itc==1504 & hhcode==3051010307

		*tomato has one really low value, 3 kgs of tomato for 10 rupees
			*replace q1= if q1==3 & itc==1503 & hhcode==1132010208
			replace v1=100 if v1==10 & itc==1503 & hhcode==1132010208
*/
	tempfile `sec6'
	save sec6, replace

*----To find the equivalent adults in each household-----*

	use "$data2011\raw data\plist.dta", clear
	*everyone is a hh memeber, so we do not need two hh sizes by members and non-members
	keep hhcode idc age
	gen adult=0.8 if age<18
	recode adult .=1
	collapse (sum) eqadults=adult (count) hhsize=idc, by(hhcode)
	label var eqadults "Number of equivalent adults counting members & nonmembers"
	label var hhsize "Number of people in hh counting members & nonmembers"
	sort hhcode
	compress
	tempfile `eqadults'
	saveold "eqadults.dta", replace

	use "$data2011\raw data\plist.dta", clear
	rename s1aq10 member
	keep hhcode idc age member
	drop if member==2
	drop member
	gen adult=0.8 if age<18
	recode adult .=1
	collapse (sum) eqadultM=adult (count) hhsizeM=idc, by(hhcode)
	label var eqadultM "Number of equivalent adults counting only members"
	label var hhsizeM "Number of people in hh counting only members"
			******************************************************
			* Since all household member chooses member=1,      **
			* there is no difference between hhsizeM and hhsize  *
			******************************************************
	sort hhcode
	compress
	merge hhcode using "eqadults.dta"
	tab _merge
	drop _merge
	sort hhcode
	save "$consump1112\eqadults.dta", replace
	
	
*====================================hirokis way of doing consumption=============================================*

use sec6, clear
	*total expenditure and quantity
	egen expend  =rsum(v1 v2 v3 v4)
	egen quantity=rsum(q1 q2 q3 q4)	

	*section A (2 week recall)
	drop if inlist(itc, 1000, 1001, 1002)
	drop if itc==1580
	* as a check I always drop the totals rows
	drop if inlist(itc, 1100, 1200, 1300, 1400, 1500, 1600, 1700, 1800, 1900)

	replace expend=expend*2.17 if itc>=1101 & itc<=1901		/*items with 2-week recall*/
		
	*section L-B (1 month recall)
	drop if inlist(itc, 2000, 2001, 2002, 2900)
	* as a check I always drop the totals rows
	drop if inlist(itc, 2100, 2200, 2300, 2400, 2500, 2600, 2700, 2800, 2900, 3000)

	*section L-C (1 month recall)
	drop if itc==4000
	* as a check I always drop the totals rows
	drop if inlist(itc, 4100, 4200, 4300, 4400)

	*section L-D (1 month recall)
	drop if inlist(itc, 5000, 5001, 5002)
	drop if inlist(itc, 5407, 5702, 5703, 5704, 5901, 5902)
	* as a check I always drop the totals rows
	drop if inlist(itc, 5100, 5200, 5300, 5400, 5500, 5600, 5700, 5800, 5900)
	
	drop if itc>=6000	/*dropping all durables*/

	replace expend=expend/12 if itc>=5100 & itc<=5904		/*items with 1-year recall*/
	
	*verifying that rent is not reported more than once
	gen byte flag1=(itc>=5401 & itc<=5404)
	sort hhcode flag1 itc
	quietly by hhcode flag1: gen dup = cond(_N==1,0,_n)
	tab dup if flag1==1

	drop if hhcode==1011040107 & itc==5402
	drop if hhcode==1091040103 & itc==5401
		drop flag1 dup
	gen byte flag1=(itc>=5401 & itc<=5404)
	sort hhcode flag1 itc
	quietly by hhcode flag1: gen dup = cond(_N==1,0,_n)
	drop if flag1==1 & dup>1
	drop flag1 dup

	
	*check that the same household (with different items) have the same PSU province weight and region
	local var psu province region weight
	foreach v of local var{
		bys hhcode: egen `v'_min = min(`v')
		bys hhcode: egen `v'_max = max(`v')
		assert `v'_min == `v'_max
		drop `v'_min `v'_max
	}
	
	collapse (mean) province region psu weight (sum) expend, by (hhcode)
	sort psu
	rename expend nomexpend
	label var nomexpend "Nominal Total Monthly Household Expenditure per Month-From Hiroki's File"
	save "$consump1112\cons_agg_hiroki", replace


*===================================NOBUO'S WAY OF DOING CONSUMPTION===================================================*


*****************************************
			* Food Expenditures
*****************************************
	
	
*----Fortnightly expenditures----*

	use sec6, clear
	keep if itc>=1000 & itc<2000
	*dropping page and Part A totals, we will compute our own totals
	drop if itc==1001|itc==1002| itc==1000
	*---date entry error, there is no other non-missing variable in there---*
	drop if itc==1580
	* as a check I always drop the totals rows
	drop if inlist(itc, 1100, 1200, 1300, 1400, 1500, 1600, 1700, 1800, 1900)

	collapse (sum) v1 v2 v3 v4, by (hhcode)

	egen double food=rsum(v1 v2 v3 v4)
	label var v1 "Total food expend (paid and consumed)"
	label var v2 "Total food expend (unpaid and consumed: wages in kind)"
	label var v3 "Total food expend (unpaid and consumed: own produced)"
	label var v4 "Total food expend (unpaid and consumed: assistance, gifts, dowry)"
	label var food "Total food expend"
		
	gen fort=1
	label var fort "=1 if fortnightly, 0 monthly"
	compress
	sort hhcode
	tempfile `exp-foodF_1112'
	save "exp-foodF_1112.dta", replace

*----Monthly expenditures----*

	use sec6, clear
	keep if itc>=2000 & itc<4000
	*drop all the non-food items
	drop if itc>=2700
	*dropping page and Part B totals, we will compute our own totals
	drop if itc==2001|itc==2002|itc==2000
	* as a check I always drop the totals rows
	drop if inlist(itc, 2100, 2200, 2300, 2400, 2500, 2600)

	collapse (sum) v1 v2 v3 v4, by (hhcode)
	egen double food=rsum(v1 v2 v3 v4)

	gen fort=0
	label var fort "=1 if fortnightly, 0 monthly"
	compress
	append using exp-foodF_1112.dta
	replace v1=2*v1 if fort==1
	replace v2=2*v2 if fort==1
	replace v3=2*v3 if fort==1
	replace v4=2*v4 if fort==1
	replace food=2*food if fort==1

	sort hhcode fort
	collapse (sum) v1 v2 v3 v4 food, by (hhcode)
	label var v1 "Total food expend (paid and consumed)"
	label var v2 "Total food expend (unpaid and consumed: wages in kind)"
	label var v3 "Total food expend (unpaid and consumed: own produced)"
	label var v4 "Total food expend (unpaid and consumed: assistance, gifts, dowry)"
	label var food "Total food expend: Monthly"

	*variables v1...v4 and food are aggregates of monthly food expend (from sect6 partb)
	*and fortnightly food expend (from sect6 parta)-converted into monthly figures

	keep food hhcode
	* keep only total food expend (food) *
	sort hhcode
	tempfile `exp-foodM_1112'
	save exp-foodM_1112.dta, replace
	
	
*****************************************
* Now, the Non-food Monthly expenditures
*****************************************
* Monthly Non-Durable expenditures in a female file *

	use sec6, clear
	*Keep only non-food expenditures
	keep if itc>=2701 & itc<4000
	
	* as a check I always drop the totals rows
	drop if inlist(itc, 2700, 2800, 2900, 3000)

	*page and Part B totals automatically eliminated

	gen byte categ=1 if itc>=2701 & itc<=2709
	replace categ=2 if itc>=2801 & itc<=2805
	replace categ=3 if itc>=2901 & itc<=2903
	replace categ=4 if itc>=3001 & itc<=3003
	sort hhcode categ

	local i = 1
	while `i' < 5 {
	egen double v`i'1 = sum(v1) if categ==`i', by(hhcode)
	egen double v`i'2 = sum(v2) if categ==`i', by(hhcode)
	egen double v`i'3 = sum(v3) if categ==`i', by(hhcode)
	egen double v`i'4 = sum(v4) if categ==`i', by(hhcode)
	compress
	local i = `i' + 1
	}
	
	drop v1 v2 v3 v4
	sort hhcode categ
	quietly for var v11 - v44: recode X 0=.
	collapse (mean) v*, by(hhcode)

	egen double fuelM=rsum(v1*)
	egen double pcarartM=rsum(v2*)
	egen double pcarserM=rsum(v3*)
	egen double laundryM=rsum(v4*)

	quietly for var v11 - v44: recode X 0=.

	label var fuelM "Total value of Fuel and lighting"
	label var pcarartM "Total value of Personal care articles"
	label var pcarserM "Total value of Personal care services"
	label var laundryM "Total value of Household laundry, cleaning and paper articles"

	keep fuelM pcarartM pcarserM laundryM hhcode
	* keep only total values *

	tempfile `exp-nonfoodM_f_1112'
	save exp-nonfoodM_f_1112.dta, replace

*-----Monthly Non-Durable expenditures in the male file-----*

	use sec6, clear
	*Keep only non-food expenditures
	keep if itc>4000 & itc<5000

	* as a check I always drop the totals rows
	drop if inlist(itc, 4100, 4200, 4300, 4400)

	*page total automatically eliminated
	gen byte categ=1 if itc>=4101 & itc<=4104
	replace categ=2 if itc>=4201 & itc<=4203
	replace categ=3 if itc>=4301 & itc<=4304
	replace categ=4 if itc>=4401 & itc<=4406
	sort hhcode categ

	local i = 1
	while `i' < 5 {
	egen double v`i'1 = sum(v1) if categ==`i', by(hhcode)
	egen double v`i'2 = sum(v2) if categ==`i', by(hhcode)
	egen double v`i'3 = sum(v3) if categ==`i', by(hhcode)
	egen double v`i'4 = sum(v4) if categ==`i', by(hhcode)
	compress
	local i = `i' + 1
	}
	
	drop v1 v2 v3 v4
	sort hhcode categ
	quietly for var v11 - v44: recode X 0=.
	collapse (mean) v*, by(hhcode)

	egen double tobaccoM=rsum(v1*)
	egen double recreatM=rsum(v2*)
	egen double ptranspM=rsum(v3*)
	egen double othmissM=rsum(v4*)

	quietly for var v11 - v44: recode X 0=.

	label var tobaccoM "Total value of tobacco and chewing products"
	label var recreatM "Total value of Recreation & reading"
	label var ptranspM "Total value of Personal Transport and travelling"
	label var othmissM "Total value of Other Miscellaneous Household expenses"

	keep tobaccoM recreatM ptranspM othmissM hhcode
* keep only total values of each item *
	compress
	
	tempfile `exp-nonfoodM_m_1112'
	save "exp-nonfoodM_m_1112.dta", replace
	
	merge 1:1 hhcode using exp-nonfoodM_f_1112
	drop _m
	
	tempfile `exp-nonfoodM_1112'
	save exp-nonfoodM_1112.dta, replace

******************************************
*Now, the Yearly Non-Durable expenditures
******************************************
*---Page 2 of yearly expenditures----*
	use sec6, clear
	keep if itc>=5600 & itc<6000
	
	* as a check I always drop the totals rows
	drop if inlist(itc, 5600, 5700, 5800, 5900)
* Focus on items in the second page of Section 6 M Household Expenditures Part D *
* automatically drops page and part C totals, since we will compute our own totals

	sort hhcode itc

	gen byte categ=6  if itc>5600 & itc<5700
	replace categ=7  if itc>5700 & itc<5800
	replace categ=8  if itc>5800 & itc<5900
	replace categ=9  if itc==5901
	replace categ=10 if itc>5901 & itc<=5904
	replace categ=11 if itc>=5702 & itc<=5704
	replace categ=12 if itc==5902


	drop itc
	sort hhcode categ

	local i = 6
	while `i' < 13 {
	egen double v`i'1 = sum(v1) if categ==`i', by(hhcode)
	egen double v`i'2 = sum(v2) if categ==`i', by(hhcode)
	egen double v`i'3 = sum(v3) if categ==`i', by(hhcode)
	egen double v`i'4 = sum(v4) if categ==`i', by(hhcode)
	compress
	local i = `i' + 1
	}
	
	drop v1 v2 v3 v4
	sort hhcode categ
	quietly for var v61 - v124: recode X 0=.
	collapse (mean) v*, by(hhcode)

	egen double medcareY=rsum(v6*)
	egen double recreatY=rsum(v7*)
	egen double eduprofY=rsum(v8*)
	egen double taxfineY=rsum(v9*)
	egen double othndurY=rsum(v10*)
	egen double licenfeeY=rsum(v11*)
	egen double lumpyY=rsum(v12*)
	keep medcareY recreatY eduprofY taxfineY othndurY licenfeeY lumpyY hhcode

	compress
	sort hhcode
	tempfile `exp-nondurabY_1112'
	save "exp-nondurabY_1112.dta", replace

*---Page 1 of yearly expenditures----*
	use sec6, clear
	keep if itc>=5000 & itc<5600
*---drop page and part C totals, since we will compute our own totals
	drop if itc==5001|itc==5002|itc==5000
	
	* as a check I always drop the totals rows
	drop if inlist(itc, 5100, 5200, 5300, 5400, 5500)
	
	* to check if some households have duplicate information on rent and imputed rent
	gen byte flag1=(itc>=5401 & itc<=5404)
	sort hhcode flag1 itc
	quietly by hhcode flag1: gen dup = cond(_N==1,0,_n)
	tab dup if flag1==1
	drop if hhcode==1011040107 & itc==5402
	drop if hhcode==1091040103 & itc==5401
		drop flag1 dup
	gen byte flag1=(itc>=5401 & itc<=5404)
	sort hhcode flag1 itc
	quietly by hhcode flag1: gen dup = cond(_N==1,0,_n)
	drop if flag1==1 & dup>1
	drop flag1 dup

* The category House rent and housing expenses will exclude itc=5407 (House & Property Tax)
	drop if itc==5407
	sort hhcode itc

	gen byte categ=1 if itc>5100 & itc<5200
	replace categ=2  if itc>5200 & itc<5300
	replace categ=3  if itc>5300 & itc<5400
	replace categ=4  if itc>5400 & itc<5500
	replace categ=5  if itc>5500 & itc<5600

	drop itc
	sort hhcode categ

	local i = 1
	while `i' < 6 {
		egen double v`i'1 = sum(v1) if categ==`i', by(hhcode)
		egen double v`i'2 = sum(v2) if categ==`i', by(hhcode)
		egen double v`i'3 = sum(v3) if categ==`i', by(hhcode)
		egen double v`i'4 = sum(v4) if categ==`i', by(hhcode)
	compress
	local i = `i' + 1
	}
	drop v1 v2 v3 v4
	sort hhcode categ
	quietly for var v11-v54: recode X 0=.
	collapse (mean) v*, by(hhcode)

	egen double clothY=rsum(v1*)
	egen double footwY=rsum(v2*)
	egen double pereffY=rsum(v3*)
	egen double housingY=rsum(v4*)
	egen double chinawY=rsum(v5*)

	keep clothY footwY pereffY housingY chinawY hhcode
	compress
	sort hhcode

	append using exp-nondurabY_1112.dta
	sort hhcode

	quietly for var clothY - lumpyY: recode X .=0
	collapse (sum) clothY-lumpyY, by (hhcode)

	label var clothY "Total value of Clothing (nondurable)"
	label var footwY "Total value of Footwear and Repairs (nondurable)"
	label var pereffY "Total value of Personal Effects (nondurable)"
	label var housingY "Total value of Housing (nondurable)"
	label var chinawY "Total value of Chinaware, Earthenware, etc. (nondurable)"
	label var medcareY "Total value of Medical Care (nondurable)"
	label var recreatY "Total value of Recreational Activities(nondurable)"
	label var eduprofY "Total value of Edu and Professional expend(nondurable)"
	label var taxfineY "Total value of taxes and fines expend(nondurable)"
	label var othndurY "Total value of Other yearly expend on nondurables,excl.tax & fines"
	label var licenfeeY "Total value of Annual License fees in Recereation section"
	label var lumpyY "Total value of Lumpy Expenditures in other nondurables section"
	sort hhcode
	compress

	save "exp-nondurabY_1112.dta", replace


*------Now, the Yearly Durable Expenditures

	use sec6, clear
	drop if itc<6100

	gen byte categ=1 if itc>6100 & itc<6200
	replace categ=2  if itc>6200 & itc<6300
	replace categ=3  if itc>6300 & itc<6400
	replace categ=4 if itc>=6401 & itc<=6404
	replace categ=5 if itc==6405
	replace categ=6  if itc>6500 & itc<6600
	drop itc
	sort hhcode categ

	local i = 1
	while `i' < 7 {
		egen double v`i'1 = sum(v1) if categ==`i', by(hhcode)
		egen double v`i'2 = sum(v2) if categ==`i', by(hhcode)
		egen double v`i'3 = sum(v3) if categ==`i', by(hhcode)
		egen double v`i'4 = sum(v4) if categ==`i', by(hhcode)
	compress
	local i = `i' + 1
	}
	drop v1 v2 v3 v4
	sort hhcode categ
	quietly for var v11 - v64: recode X 0=.
	collapse (mean) v*, by(hhcode)

	egen double dghhtexY=rsum(v1*)
	egen double dgchinaY=rsum(v2*)
	egen double dgfurnY=rsum(v3*)
	egen double dgoheffY=rsum(v4*)
	egen double dgsheffY=rsum(v5*)
	egen double dgmiscY=rsum(v6*)

	label var dghhtexY "Total value of hh textiles & personal effects (durable)"
	label var dgchinaY "Total value of Chinaware, silverware, etc. (durable)"
	label var dgfurnY "Total value of Furniture, Fixture and Furnishing(durable)"
	label var dgoheffY "Total value of Other HH Effects(durable)excl.service & repair"
	label var dgsheffY "Total expend on service & repair of HH Effects(durable)"
	label var dgmiscY "Total value of miscell yearly expend on durables"

	keep dghhtexY dgchinaY dgfurnY dgoheffY dgsheffY dgmiscY hhcode
	compress
	sort hhcode
	
	tempfile `exp-durabY_1112'
	save "exp-durabY_1112.dta", replace


*---MERGE ALL THE EXPENDITURE FILES TOGETHER----*
	use exp-foodM_1112.dta, clear
	merge 1:1 hhcode using exp-nonfoodM_1112.dta
	drop _m
	merge 1:1 hhcode using exp-nondurabY_1112.dta
	tab _m
	drop _m
	merge 1:1 hhcode using exp-durabY_1112.dta
	drop _m
	
* Total households = 15807. 15806 households have food expenditures. we do not keep wht hh with no food exp
	drop if food==.

*---we recode all the expenditures missing to zero
	quietly for var dghhtexY - dgmiscY: recode X .=0
*---we change all the yearly expenditures to monthly 
	quietly for var clothY - dgmiscY: replace X=X/12
	
	*---Nominal Monthly Expenditure-Nobuo-----*
	egen double nomexp_n=rsum(food-eduprofY othndurY dgsheffY)
	label var nomexp_n "Total Nominal monthly expend of the hh-Nobuo"
	
	gen double nomexp_licenfeeY  =  nomexp_n - licenfeeY 
	label var nomexp_licenfeeY "Total Nominal monthly expend of the hh-Nobuo-excluding license fees"

	gen double nomexp_lumpyY =  nomexp_n - lumpyY 
	label var nomexp_lumpyY  "Total Nominal monthly expend of the hh-Nobuo-excluding lumpy exp"

	gen double nomexp_dgsheffY =  nomexp_n - dgsheffY 
	label var nomexp_dgsheffY"Total Nominal monthly expend of the hh-Nobuo-excl repairs to durables"

	gen double nomexp_h=nomexp_n - licenfeeY - lumpyY - dgsheffY
	label var nomexp_h "Total Nominal monthly expend of the hh-Hiroki"

*---MERGE WITH ADULT EQUIVALENT-----*
	merge 1:1 hhcode using "$consump1112\eqadults.dta"	
	*---the same hh that does not have food consumption will be dropped here----*
	keep if _m==3
	drop _m
	
*---MERGE WITH NOBUO'S HH PRICE INDEX----*
	merge 1:1 hhcode using "$consump1112\PIndex_fbs_nobou.dta"
	*---the same hh that does not have food consumption will be dropped here----*
	keep if _m==3
	drop _m
	rename psuindex psuindex_n	
	
*---MERGE WITH HIROKI'S HH PRICE INDEX----*
	merge m:1 psu using "$consump1112\psu_paasche_hiroki.dta"
	drop _m	
	rename psupind psuindex_h
	
*---Nominal Monthly Expenditure-Hiroki-----*
	merge 1:1 hhcode using "$consump1112\cons_agg_hiroki"
	keep if _m==3
	drop _m
	
	
*----Adjusting by psu index and dividing by adult equivalent---*	
	gen texpend_nn=nomexp_n/psuindex_n
	label var texpend_nn "Total monthly exp as Nobuo, adjusted by Nobuo psuindex"

	gen texpend_nh=nomexp_n/psuindex_h
	label var texpend_nh "Total monthly exp as Nobuo, adjusted by Hirko psuindex"
	
	gen texpend_hn=nomexpend/psuindex_n
	label var texpend_hn "Total monthly exp as Hiroki, adjusted by Nobuo psuindex"

	gen texpend_hh=nomexpend/psuindex_h
	label var texpend_hh "Total monthly exp as Hiroki, adjusted by Hirko psuindex"

	
gen peaexpM_nn=texpend_nn/eqadultM
label var peaexpM_nn "Per equiv adult expend of hh adjusted by psuindex, exp as Nobuo, adjusted by Nobuo psuindex "


gen peaexpM_nh=texpend_nh/eqadultM
label var peaexpM_nh "Per equiv adult expend of hh adjusted by psuindex, exp as Nobuo, adjusted by Hiroki psuindex "

gen peaexpM_hn=texpend_hn/eqadultM
label var peaexpM_hn "Per equiv adult expend of hh adjusted by psuindex, exp as Hiroki, adjusted by Nobuo psuindex "

gen peaexpM_hh=texpend_hh/eqadultM
label var peaexpM_hh "Per equiv adult expend of hh adjusted by psuindex, exp as Hiroki, adjusted by Hiroki psuindex "

save "$consump1112\Various consump aggregates.dta", replace



/*---------------File sent to Juan----------------------*/
	
use "$consump1112\cons_agg_hiroki", clear
merge m:1 psu using "$consump1112\psu_paasche_hiroki.dta"
drop _m
merge 1:1 hhcode using "$consump1112\eqadults.dta"
drop _m
	gen texpend=nomexpend/psupind
	label var texpend "Total monthly exp, adjusted by psu level spatial price index"

	gen peaexpM=texpend/eqadultM
	label var peaexpM "Per equiv adult expend of hh adjusted by psuindex"

save "$consump1112\Final file.dta", replace
