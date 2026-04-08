clear all
****************************************************************************************************
								******IMPORTING ALL THE FILES******************
***************************************************************************************************
global comp "C:\Users\wb357339\Dropbox" 
*global comp "C:\Users\FF\Dropbox" 
global pricework "$comp\Shared Pak Poverty Work"
global data2011 "$pricework\PSLM 11-12\data"
global i2d2 "$pricework\I2D2"
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
	
	/*onservative- changing some outliers manually-adjustments are based sort of around the
	reasonable values or median
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

*****************************************
			* Food Expenditures
*****************************************
	
	
*----Fortnightly expenditures----*

	use sec6, clear
	keep if itc>=1000 & itc<2000
	*dropping totals
	drop if itc==1001|itc==1002| itc==1000
	* get rid of items for which we do not have quantities
	drop if itc==1106  
	* eliminate items for which variability of unit value is due to grouping of different items
	drop if itc==1307|itc==1308|itc==1401|itc==1509|itc==1510|itc==1607|itc==1704|itc==1705|itc==1803 |itc==1901
	*---date entry error, there is no other non-missing variable in there---*
	drop if itc==1580
	* as a check I always drop the totals rows
	drop if inlist(itc, 1100, 1200, 1300, 1400, 1500, 1600, 1700, 1800, 1900)
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
	tempfile `uvfoodF'
	save "uvfoodF.dta", replace

*----Monthly expenditures----*

	use sec6, clear
	keep if itc>=2000 & itc<4000
	*drop all the non-food items
	drop if itc>=2700
	*dropping page and Part B totals
	drop if itc==2001|itc==2002|itc==2000
	*get rid of items for which we do not have quantities
	drop if itc==2504 | itc==2601 | itc==2602 
	*eliminate items for which variability of unit value is due to grouping of different items
	drop if itc==2105 | itc==2206 | itc==2402 
	* as a check I always drop the totals rows
	drop if inlist(itc, 2100, 2200, 2300, 2400, 2500, 2600, 2700, 2800, 2900, 3000)

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
	tempfile `uvfoodM'
	save "uvfoodM.dta", replace

	
	
*****************************************
* Now, the Non-food Monthly expenditures
*****************************************
* Monthly Non-food expenditures in the female file *

	use sec6, clear
	*Keep only non-food expenditures
	keep if itc>=2701 & itc<=2705
	*page and Part B totals automatically eliminated, items without units also eliminated, and things lumped together eliminated

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
	tempfile `uvnonfoodM_f'
	save "uvnonfoodM_f.dta", replace

* Monthly Non-food expenditures in the male file *

	use sec6, clear
	keep if itc>=4101 & itc<=4103
	*4101 and 4102 are both lumped commodities*
	keep if itc==4103
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
	tempfile `uvnonfoodM_m'
	save "uvnonfoodM_m.dta", replace
	
*----append the files together-----*	
*    15795 households    *
	use "uvfoodF.dta", clear
	append using "uvfoodM.dta"
	append using "uvnonfoodM_f.dta"
	append using "uvnonfoodM_m.dta"
	save "$consump1112\unitvalues.dta", replace


*-----psu index with food and non-food unit values---paasche_fbs---which is actualy plutocratic weight----*	
	use "uvfoodF.dta", clear
	append using "uvfoodM.dta"
	append using "uvnonfoodM_f.dta"
	append using "uvnonfoodM_m.dta"

	sort hhcode itc
	gen valuadj=value
	replace valuadj=2*value if fort==1
	label var valuadj "value if fort 0, 2*value if fort 1"
	compress
	egen double valuet=sum(valuadj), by(hhcode)
	label var valuet "Total (monthly) expend per household"

	tempfile `paasche1I_fbs'
	save "paasche1I_fbs.dta", replace

	
	use "paasche1I_fbs.dta", clear
	merge m:1 hhcode using plist
	drop if _m==2
	drop _m
	
/*This gives you the plutocratic budget shares that are not weighted*/	
	***************************************************************
	* Need to compute 
	*   1. total (monthly) expenditure per PSU *
	*   2. expenditure for item j per PSU *
	*   3. compute psu median prices for each PSU
	**************************************************************
	egen double valuet2=sum(valuadj), by(psu)
	egen double valuadj2=sum(valuadj), by(psu itc)
	egen double ppsu=median(ph), by(psu itc)
	egen tag=tag(psu itc)
	keep if tag==1 /* keep 1 obs for each item and psu */

	gen double wi2=valuadj2/valuet2

	summ
	drop hhcode tag valuadj valuet
	rename valuet2 valuet
	label var valuet "Total (monthly) expend per psu"

	rename valuadj2 valuadj
	label var valuadj "(monthly) expend for item j per psu"

	rename wi2 wi
	label var wi "Share of item in PSU-total expenditure"

	label var ppsu "psu median price for item i"
	compress
	sort itc

	drop fort
	
	tempfile `paasche1_fbs'
	save "paasche1_fbs.dta", replace

**************************************************************
* to calculate the price of each food item at a national level
**************************************************************

	use "paasche1I_fbs.dta", clear
	merge m:1 hhcode using plist
	drop if _m==2
	drop _m
	drop quant value valuadj fort
	egen double p0=median(ph), by(itc)
	label var p0 "Price of each food item (national/median)"
	egen tag=tag(itc)
	keep if tag==1
	compress
	keep itc p0
	sort itc
	tempfile `paasche2_fbs'
	save "paasche2_fbs.dta", replace


	use "paasche1_fbs.dta", clear
	merge m:1 itc using "paasche2_fbs.dta"
	drop _m

	gen double lnindex= wi*(p0/ppsu)
	collapse (sum) lnindex, by(psu)

	gen psuindex=1/lnindex
	label var lnindex "sum (over items) wi*(p0/ppsu)"
	label var psuindex "Paasche Index by psu"
	sort psu 
	summ
	tempfile `paasche_fbs'
	save "paasche_fbs.dta", replace

*---for missing psu-----*
	use paasche_fbs.dta, clear
	merge 1:m psu using plist
	drop _m
	egen double ok1=mean(psuindex), by (psu)
	replace psuindex=ok1 if  psuindex==.
	keep  hhcode psuindex
	sort hhcode
	tempfile `PIndex_fbs'
	save "PIndex_fbs.dta", replace

	use plist, clear
	collapse (mean) province region psu weight, by (hhcode)
	merge 1:1 hhcode using PIndex_fbs.dta
	drop _m

	* normalized by weighted country average psuindex *

	summ psuindex [weight=weight] 
	gen norm=_result(3)
	replace psuindex=psuindex/norm
	label var psuindex "Paasche-Ind by psu (normalized by country avg using 'hh weight')"
	drop norm
	save "$consump1112\PIndex_fbs_nobou.dta", replace

	
	
	
/*Paasche Index by psu
*******************************************************************************************
*Step 0. To make sure that each household consumes at least 5 different food items
*Step 1. To obtain the budget share of each food item per psu
*Step 2. To obtain the implicit price paid for each food item per psu
*Step 3. To obtain the reference price (median price of each food item at national level)
*Step 4. To normalize and calculate the index: sum of (1*ln(2/3))
*******************************************************************************************/

*Step 0. To make sure that each household consumes at least 5 different food items
*data set-up
	*drop households with less than 5 items consumed (coming from Nobuo's do-file 07/08)
	use "$consump1112\unitvalues.dta", clear
	bys hhcode: egen nobs = count(itc)
	
	count if nobs==.

	keep if nobs>=5		/*a total of 37 households dropped here15795 hhs in unit values minus 37 = 15758 hhs left*/
	drop nobs

	sort hhcode
	tempfile `by_item'
	save "by_item.dta", replace

*Step 1. To obtain the budget share of each food item per psu
	*collapse to household level data
	use "$data2011\raw data\plist.dta", clear
	gen a=1 if s1aq02<=12
	egen byte hhsize=count(a), by(hhcode)
	label var hhsize "Household size including servants/their relatives and others"
	collapse (mean) province region psu weight hhsize, by(hhcode)
	gen pweight=weight*hhsize
	
*-----calculate total population at different levels of aggregation----*

*-----total population----*
	egen double totpop=sum(pweight)
	format totpop %12.0f
	
*----psu level total population----*
	egen double pop_psu=sum(pweight), by(psu)
	format pop_psu %12.0f
	
	tempfile `by_hhlds'
	save "by_hhlds.dta", replace

*----merge by_item with by_hhlds. resulting dataset is item-level----*
	use by_item, clear
	merge m:1 hhcode using by_hhlds
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
	tempfile `by_psu_item'
	save "by_psu_item.dta", replace

*Step 2. To obtain the implicit price paid for each food item per psu
	* calculate median prices by psu
	use "$consump1112\unitvalues.dta", clear
	merge m:1 hhcode using plist
	drop if _m==2
	drop _m
	collapse (median) ph_psu=ph [pweight=weight], by(psu itc)
	label var ph_psu "Median unit value at PSU level"
	sum
	compress
	sort psu itc
	tempfile `med_psu_uv'
	save "med_psu_uv.dta", replace		/*this dataset is at PSU-item level*/

*Step 3. To obtain the reference price (median price of each food item at national level)
	* calculate the median price of each food item at a national level
	use "$consump1112\unitvalues.dta", clear
	merge m:1 hhcode using plist
	drop if _m==2
	drop _m
	collapse (median) p0=ph [pweight=weight], by(itc)
	label var p0 "Price of each food item (national median)"
	sum
	compress
	sort itc
	tempfile `med_nat_uv'
	save "med_nat_uv.dta", replace		/*this dataset is at item level*/	
	
*Step 4. To normalize and calculate the index: sum of (1*ln(2/3))
	*data set-up
	*merge by_psu_item with 1) med_psu_uv and 2) med_nat_uv
	use by_psu_item, clear
	merge m:1 psu itc using med_psu_uv
	
	keep if _m==3
	drop _m
	
	sort itc
	merge m:1 itc using med_nat_uv
	drop _m
	
	*calculate PSU level paasche
	gen double lnindex= pwgtwipsu*log(ph_psu/p0)			/*Eq (4.6) in Deaton and Zaidi (p41)*/
	collapse (sum) lnindex (mean) region province, by(psu)
	gen psupind=exp(lnindex)
	label var psupind "Paasche Index by psu"
	drop lnindex
	sort region province psu
	tempfile `psu_paasche_temp'
	saveold psu_paasche_temp, replace

	
	
	*merge with household-level data
	use "$consump1112\cons_agg_hiroki", clear
	merge m:1 region province psu using psu_paasche_temp
	assert _m==3						/*check that all households are assigned a PUS-level paasche*/
	drop _m
	
	*normalize by its mean
	sum psupind [weight=weight]
	local mean = r(mean)
	
	replace psupind=psupind/`mean'
	label var  psupind "Paasche Index by Household (normalized)"
	
	qui sum psupind
	* to obtain the average Paasche Index by region (urban/rural) and prov
	table prov region [pweight=weight], c(mean psupind) row col
	table prov region [pweight=weight], c(med psupind) row col
	
	keep psu psupind
	bys psu: keep if _n==1
	save "$consump1112\psu_paasche_hiroki.dta", replace
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	

