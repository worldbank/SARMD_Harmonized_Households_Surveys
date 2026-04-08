clear all
****************************************************************************************************
								******IMPORTING ALL THE FILES******************
***************************************************************************************************
global comp "C:\Users\wb357339\Dropbox" 
*global comp "C:\Users\FF\Dropbox" 
global pricework "$comp\Shared Pak Poverty Work"
global data2013 "$pricework\PSLM 13-14\raw data"
global i2d2 "$pricework\I2D2"
global consump1314 "$pricework\PSLM 13-14\Consumption Checks\data files"



*---Getting the hh identifiers and weights from plist----*
	use "$data2013\plist.dta", clear
	rename weights weight
	collapse province region psu weight, by(hhcode)
	tempfile `plist13'
	save plist13, replace

*---Consumption Data is all in one file----*	
	use "$data2013\sec_6abcde.dta", clear
	isid hhcode itc
	merge m:1 hhcode province region psu using plist13
	drop _m
	tempfile `sec6_13'
	save sec6_13, replace

	
*****************************************
			* Food Expenditures
*****************************************
	
	
*----Fortnightly expenditures----*

	use sec6_13, clear
	
	keep if itc>=1000 & itc<2000
	drop if inlist(itc, 1000, 1001, 1002, 1003)
	* as a check I always drop the totals rows
	drop if inlist(itc, 1100, 1200, 1300, 1400, 1500, 1600, 1700, 1800, 1900)

	*	The dropping of items does not have to be held consistent across years unless it is an intertemporal
	*	price index exercise. We should not drop it unless it is necesary because otherwise we assume that the
	*	expenditure on the dropped items is similar to the ones that are included
	*	Any item that is considered others or is lumped together is dropped. *

	drop if itc==1108 | itc==1109 | itc==1205 | itc==1309 | itc==1310 | itc==1402  
	drop if itc==1509 | itc==1510 | itc==1608 
	* 1706 (glucose, energile etc could be included for the same reason that baked and fried products are. Not included for now)
	drop if itc>=1704 & itc<=1706
	drop if itc>=1803 & itc<=1804
	drop if itc>=1901 & itc<=1903

	*only keep quantities and vales that are both non-missing
	replace v1=. if v1!=. & q1==.
	replace v2=. if v2!=. & q2==.
	replace v3=. if v3!=. & q3==.
	replace v4=. if v4!=. & q4==.
	
	replace q1=. if q1!=. & v1==.
	replace q2=. if q2!=. & v2==.
	replace q3=. if q3!=. & v3==.
	replace q4=. if q4!=. & v4==.

	
	egen quant=rsum(q1 q2 q3 q4)
	egen value=rsum(v1 v2 v3 v4)
	keep if (quant>0 &  quant~=.) & (value>0 & value~=.)
	keep hhcode itc quant value

	* to calculate the implicit price
	* first check if any food item is repeated for a single household

	sort hhcode itc
	quietly by hhcode itc: gen dup=cond(_N==1,0,_n)
	tab dup
	*tabulating dup shows that dup=0 always for this file, thus no repetition
	drop dup

	gen double ph=value/quant
	label var value "Expenditure per item"
	label var quant "Quantity consumed per item" 
	label var ph "Implicit price per item per household"
	gen fort=1
	label var fort "=1 if fortnightly, 0 monthly"
	compress
	tempfile `uvfoodF_1314'
	save "uvfoodF_1314.dta", replace

*----Monthly expenditures----*

	use sec6_13, clear
	
	keep if itc>=2000 & itc<4000
	*drop all the non-food items
	drop if itc>=2700
	*dropping page and Part B totals
	drop if itc==2001|itc==2002|itc==2000
	* as a check I always drop the totals rows
	drop if inlist(itc, 2100, 2200, 2300, 2400, 2500, 2600, 2700, 2800, 2900, 3000)
	*get rid of items for which we do not have quantities
	drop if itc==2506 | itc==2605 | itc==2606 
	*eliminate items for which variability of unit value is due to grouping of different items
	*2501 to 2505 are also lumped (included for now)
	drop if itc==2105 | itc==2206 | itc==2304 | itc==2403 | itc==2601 | itc==2602 | itc==2603 | itc==2604

	*only keep quantities and vales that are both non-missing
	replace v1=. if v1!=. & q1==.
	replace v2=. if v2!=. & q2==.
	replace v3=. if v3!=. & q3==.
	replace v4=. if v4!=. & q4==.
	
	replace q1=. if q1!=. & v1==.
	replace q2=. if q2!=. & v2==.
	replace q3=. if q3!=. & v3==.
	replace q4=. if q4!=. & v4==.

	egen quant=rsum(q1 q2 q3 q4)
	egen value=rsum(v1 v2 v3 v4)
	keep if (quant>0 &  quant~=.) & (value>0 & value~=.)
	keep hhcode itc quant value

	* to calculate the implicit price
	* first check if any food item is repeated for a single household

	sort hhcode itc
	quietly by hhcode itc: gen dup=cond(_N==1,0,_n)
	tab dup
	*tabulating dup shows that dup=0 always for this file, thus no repetition
	drop dup

	gen double ph=value/quant
	label var value "Expenditure per item"
	label var quant "Quantity consumed per item" 
	label var ph "Implicit price per item per household"
	gen fort=0
	label var fort "=1 if fortnightly, 0 monthly"
	compress
	tempfile `uvfoodM_1314'
	save "uvfoodM_1314.dta", replace
	
	
*****************************************
* Now, the Non-food Monthly expenditures
*****************************************
* Monthly Non-food expenditures in the female file *

	use sec6_13, clear
	*Keep only non-food expenditures
	keep if itc>=2701 & itc<=2711
	*page and Part B totals automatically eliminated, items without units also eliminated, and things lumped together eliminated
	*get rid of items for which we do not have quantities
	drop if itc==2706
	drop if itc>=2708 & itc<=2710

	*only keep quantities and vales that are both non-missing
	replace v1=. if v1!=. & q1==.
	replace v2=. if v2!=. & q2==.
	replace v3=. if v3!=. & q3==.
	replace v4=. if v4!=. & q4==.
	
	replace q1=. if q1!=. & v1==.
	replace q2=. if q2!=. & v2==.
	replace q3=. if q3!=. & v3==.
	replace q4=. if q4!=. & v4==.

	egen quant=rsum(q1 q2 q3 q4)
	egen value=rsum(v1 v2 v3 v4)
	keep if (quant>0 &  quant~=.) & (value>0 & value~=.)
	keep hhcode itc quant value

	* to calculate the implicit price
	* first check if any food item is repeated for a single household

	sort hhcode itc
	quietly by hhcode itc: gen dup=cond(_N==1,0,_n)
	tab dup
	*tabulating dup shows that dup=0 always for this file, thus no repetition
	drop dup

	gen double ph=value/quant
	label var value "Expenditure per item"
	label var quant "Quantity consumed per item" 
	label var ph "Implicit price per item per household"
	gen fort=0
	label var fort "=1 if fortnightly, 0 monthly"
	compress
	tempfile `uvnonfoodM_f_1314'
	save "uvnonfoodM_f_1314.dta", replace

* Monthly Non-food expenditures in the male file *

	use sec6_13, clear
	keep if itc>=4101 & itc<=4108
	*only keep quantities and vales that are both non-missing
	replace v1=. if v1!=. & q1==.
	replace v2=. if v2!=. & q2==.
	replace v3=. if v3!=. & q3==.
	replace v4=. if v4!=. & q4==.
	
	replace q1=. if q1!=. & v1==.
	replace q2=. if q2!=. & v2==.
	replace q3=. if q3!=. & v3==.
	replace q4=. if q4!=. & v4==.

	egen quant=rsum(q1 q2 q3 q4)
	egen value=rsum(v1 v2 v3 v4)
	keep if (quant>0 &  quant~=.) & (value>0 & value~=.)
	keep hhcode itc quant value

	* to calculate the implicit price
	* first check if any food item is repeated for a single household

	sort hhcode itc
	quietly by hhcode itc: gen dup=cond(_N==1,0,_n)
	tab dup
	*tabulating dup shows that dup=0 always for this file, thus no repetition
	drop dup

	gen double ph=value/quant
	label var value "Expenditure per item"
	label var quant "Quantity consumed per item" 
	label var ph "Implicit price per item per household"
	gen fort=0
	label var fort "=1 if fortnightly, 0 monthly"
	compress
	tempfile `uvnonfoodM_m_1314'
	save "uvnonfoodM_m_1314.dta", replace
	
*----append the files together-----*	
*    17981 households    *
	use "uvfoodF_1314.dta", clear
	append using "uvfoodM_1314.dta"
	append using "uvnonfoodM_f_1314.dta"
	append using "uvnonfoodM_m_1314.dta"
	save "$consump1314\unitvalues_1314.dta", replace
	
	
	
/*Paasche Index by psu
*******************************************************************************************
*Step 0. To make sure that each household consumes at least 5 different food items
*Step 1. To obtain the budget share of each food item per psu
*Step 2. To obtain the implicit price paid for each food item per psu
*Step 3. To obtain the reference price (median price of each food item at national level)
*Step 4. To normalize and calculate the index: sum of (1*ln(2/3))
*******************************************************************************************/

		
	use "$consump1314\unitvalues_1314.dta", clear
*Step 0. To make sure that each household consumes at least 5 different food items
*data set-up	*drop households with less than 5 items consumed 

	bys hhcode: egen nobs = count(itc)
	
	count if nobs==.

	keep if nobs>=5		/*a total of 39 households dropped here 17981 hhs in unit values minus 39 = 17942 hhs left*/
	drop nobs

	sort hhcode
	tempfile `by_item_1314'
	save "by_item_1314.dta", replace

*Step 1. To obtain the budget share of each food item per psu
	*collapse to household level data
	
	use "$data2013\plist.dta", clear
	* 17989 hhs
	*everyone is a hh memeber, so we do not need two hh sizes by members and non-members
	collapse (count) hhsize=idc, by(hhcode)
	tempfile `hhsize13'
	saveold "hhsize13.dta", replace
	
	
*	plist has 17989 hhs
	use plist13, clear
	merge 1:1 hhcode using hhsize13
	drop _m
	gen pweight=weight*hhsize
	
*-----calculate total population at different levels of aggregation----*

*-----total population----*
	egen double totpop=sum(pweight)
	format totpop %12.0f
	
*----psu level total population----*
	egen double pop_psu=sum(pweight), by(psu)
	format pop_psu %12.0f
	
	tempfile `by_hhlds_1314'
	save "by_hhlds_1314.dta", replace

*----merge by_item with by_hhlds. resulting dataset is item-level----*
	use by_item_1314, clear
	merge m:1 hhcode using by_hhlds_1314
	
*----47 HOUSEHOLDS DO NOT MATCH---39 WERE DROPPED IN THE BY-ITEM CUZ OF LESS THAN 5 ITEMS
*----THE OTHER 8 ARE THE ONES NOT IN THE EXPENDITURE FILE     

	drop if _m==2
	drop _m

*----budget share of each item in total consumption-----*
	gen valuadj=value
	replace valuadj=2.17*value if fort==1
	label var valuadj "value if fort 0, 2.17*value if fort 1"
	
	egen double valuet=sum(valuadj), by(hhcode)
	label var valuet "Total (monthly) expend per household"

	gen double wi=valuadj/valuet
	label var wi "Share of item in HH-budget"

	gen pwgtwi=wi*pweight
	label var pwgtwi "Population weighted share of item in HH-budget"


*----collapse to psu-item level data----*
	collapse (sum) pwgtwi (mean) province region weight pop_psu, by(psu itc)
	/*weighted average budget share of item i at PSU level, where the weight is PSU population*/
	gen pwgtwipsu=pwgtwi/pop_psu							
	label var pwgtwipsu "Population weighted Budget share of item by psu"
	sum
	* just to check
	egen totsh=sum(pwgtwipsu), by(psu)
	summ totsh
	compress
	drop totsh pwgtwi
	
	sort psu itc
	tempfile `by_psu_item_1314'
	save "by_psu_item_1314.dta", replace

*Step 2. To obtain the implicit price paid for each food item per psu
	* calculate median prices by psu
	use "$consump1314\unitvalues_1314.dta", clear
	merge m:1 hhcode using plist13
	* 8 hhs not in unit value files *
	drop if _m==2
	drop _m
	collapse (median) ph_psu=ph [pweight=weight], by(psu itc)
	label var ph_psu "Median unit value at PSU level"
	sum
	compress
	sort psu itc
	tempfile `med_psu_uv_1314'
	save "med_psu_uv_1314.dta", replace		/*this dataset is at PSU-item level*/

*Step 3. To obtain the reference price (median price of each food item at national level)
	* calculate the median price of each food item at a national level
	use "$consump1314\unitvalues_1314.dta", clear
	merge m:1 hhcode using plist13
	* 8 hhs not in unit value files *
	drop if _m==2
	drop _m
	collapse (median) p0=ph [pweight=weight], by(itc)
	label var p0 "Price of each food item (national median)"
	sum
	compress
	sort itc
	tempfile `med_nat_uv_1314'
	save "med_nat_uv_1314.dta", replace		/*this dataset is at item level*/	
	
*Step 4. To normalize and calculate the index: sum of (1*ln(2/3))
	*data set-up
	*merge by_psu_item with 1) med_psu_uv and 2) med_nat_uv
	use by_psu_item_1314, clear
	merge m:1 psu itc using med_psu_uv_1314
	* 7 psu item combinations are in median price file and not in psu_item file which has budget shares
	* these are due to dropping hhs with less than 5 items consumed. otherwise it is a perfect merge
	
	keep if _m==3
	drop _m
	
	sort itc
	merge m:1 itc using med_nat_uv_1314
	drop _m
	
	*calculate PSU level paasche
	gen double lnindex= pwgtwipsu*log(ph_psu/p0)			/*Eq (4.6) in Deaton and Zaidi (p41)*/
	collapse (sum) lnindex (mean) region province, by(psu)
	gen psupind=exp(lnindex)
	label var psupind "Paasche Index by psu"
	drop lnindex
	sort region province psu
	tempfile `psu_paasche_temp_1314'
	saveold psu_paasche_temp_1314, replace

*==============================NORMALIZE THE SPATIAL INDEX TO 1================================*	
	use "$consump1314\cons_agg_withfoodandnonfoodexp_1314", clear
	merge m:1 region province psu using psu_paasche_temp_1314
	assert _m==3						/*check that all households are assigned a PUS-level paasche*/
	drop _m
	
	*normalize by its mean
	sum psupind [weight=weight]
	local mean = r(mean)
	
	replace psupind=psupind/`mean'
	
	qui sum psupind
	* to obtain the average Paasche Index by region (urban/rural) and prov
	table prov region [pweight=weight], c(mean psupind) row col
	table prov region [pweight=weight], c(med psupind) row col
	
	collapse psupind, by(psu)
	label var  psupind "Paasche Index by Household using democratic budget shares (normalized by the mean)"
	save "$consump1314\psu_paasche_1314.dta", replace
	
	