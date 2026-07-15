clear
set mem 75m
set more off

cd m:\bangladesh\poverty\bhes2000

log using assets\assets.log, replace

*********************************************************************
***      Program to calculate the assets of the household         ***
*********************************************************************

*********************************************************************
***      THE ONLY THING TO WRAP THIS UP IS TO KNOW HOW            ***
***        HOW MANY DECIMALS AN ACRE HAS? 10 OR 100?              ***
***            FOR KNOW IT WAS ASSUMED IT WAS 10                  ***    
*********************************************************************


/*
* imputed price for the dwelling pag 5
	Q. If you wanted to buy a dwelling like this today, how much would you have to pay?

* non-agricultural enterprises pag 20-21
	two things
		- imputed value of the company         ==> same as imputed price for dwelling
								 Q. if someone wanted tyo buy this today, how much
									he would have to pay?
* agriculture pag 22-28
	- land ==> there is no value for it ===> impute
	- livestock and poultry ==> total value of the animals currently owned
	- farm forestry  ==> total value of the trees currently owned
	- assets ==> total value

* other property and assets pag 29
	- imputed value for other land/property
	- any other assets: financial, jewelry

* other income pag 30
	Nothing, these are not assets: interests, rents, profits, charities, etc

* consumer durable goods pag 60
	Imputed value of them
	Problem with hhcode, should I correct the data set?

*/


***************************************************************************
***                      (v) Consumer durable goods                     ***
***************************************************************************

use durables.dta, clear

summ
collapse (sum) value, by(hhcode)
rename value durable
label var durable "Consumer durable goods"

sort hhcode
tempfile asset05
save `asset05', replace


***************************************************************************
***                  (iv) other property and assets                     ***
***************************************************************************

use hhlist.dta, clear

keep hhcode s8a*
summ s8a02 s8a04 s8a06 s8a08 s8a10 s8a12

gen otheland=s8a02
gen otheasse=s8a08
label var otheland "Other land/property not operated"
label var otheasse "Financial assets, jewelry"

keep hhcode othe*
compress
sort hhcode
tempfile asset04
save `asset04', replace


***************************************************************************
***                         (iii) Agriculture                           ***
***************************************************************************

* land
* we'll take the weighted average (irrigated and not) of the price per decimal
* (not sure yet if a decimal is 1/10 or 1/100 of an acre)
* (check this out in the second part)
* then, for urban farms we'll take the national median and for 
* rural farms the regional median (region defined by area, same
* variable used to set the poverty lines)

use hhlist.dta, clear
sort psu
quietly by psu: keep if _n==1
keep psu area urbrural
summ
tab area urbrural, miss nol
merge psu using section2.dta
tab _merge
drop _merge
sort psu
merge psu using section6.dta
tab _merge
drop _merge
sort psu
keep psu area urbrural s205 s604a s604b
summ

*** to fix outliers
* there is an outlier here, price of non-irrigated==8004000
gen x=s604a
recode x max=.

* for another psu, both prices are really high
* psu=103 ===>  non-irrigated=400000 and irrigated=320000
* if we check the prices in that area
* summ s604b x if area==7 & psu~=103

/*
    Variable |     Obs        Mean   Std. Dev.       Min        Max
-------------+-----------------------------------------------------
       s604b |      34    3432.118   4324.908        150      25000
           x |      35    2887.143   3453.245        200      20000

*/

* seems that for psu=103, both prices have been multiplied by 100
* so divided them by 100

replace x=x/100 if psu==103
gen y=s604b
replace y=y/100 if psu==103

*** to take the average
*** ==> simple for those with no info on %land irrigated
*** ==> weighted, otherwise

gen s205c=100-s205

egen    avprice=rmean(x y) if s205==.
replace avprice=(x*s205c + y*s205)/100 if s205~=.

* price for urban farms
summ avprice
gen avpriceu=r(p50) if urbrural==1

* price for rural farms
egen avpricer=median(avprice) if urbrural==2, by(area)

sort psu
tempfile avprice
save `avprice', replace


use agri01.dta, clear
sort psu
merge psu using `avprice', nokeep
tab _merge
drop _merge
sort hhcode

** assuming decimal is 1/10 of an acre 	CONFIRM THIS!!!!!!
gen     agland=s7a01*avpriceu*10 if urbrural==1
replace agland=s7a01*avpricer*10 if urbrural==2
label var agland "Agricultural land"

keep hhcode agland
sort hhcode
tempfile asset03a
save `asset03a', replace

* livestock and poultry

use agri03.dta, clear
drop if s7c01b==0 | s7c01b==.
collapse (sum) s7c01b, by(hhcode)
rename s7c01b livestoc
label var livestoc "Livestock, poultry"

sort hhcode
tempfile asset03b
save `asset03b', replace

* farm forestry

use agri06.dta, clear
drop if s7c01b==0 | s7c01b==.
collapse (sum) s7c01b, by(hhcode)
rename s7c01b forestry
label var forestry "Forestry"

sort hhcode
tempfile asset03c
save `asset03c', replace

* assets

use agri08.dta, clear
drop if s7e01b==0 | s7e01b==.
collapse (sum) s7e01b, by(hhcode)
rename s7e01b agasset
label var agasset "Agricultural assets: machinery, tools"

sort hhcode
tempfile asset03d
save `asset03d', replace


***************************************************************************
**                   (ii) Non-agriculture self-employment                **
***************************************************************************

use business.dta, clear

replace s607=100 if s607==0 | s607==.
drop if s623==0 | s623==.
gen x=s607*s623/100
collapse (sum) x, by (hhcode)
rename x nonagbus
label var nonagbus "Value of non-agricultural firms"

sort hhcode
tempfile asset02
save `asset02', replace


***************************************************************************
**                               (i) House                               **
***************************************************************************

use hhlist.dta, clear

keep hhcode s212
rename s212 house
label var house "Value of the dwelling"

sort hhcode
tempfile asset01
save `asset01', replace


***************************************************************************
**                   Pulling all sub-components together                 **
***************************************************************************

use `asset01', clear
sort hhcode
merge hhcode using `asset02'
tab _merge
drop _merge
sort hhcode
merge hhcode using `asset03a'
tab _merge
drop _merge
sort hhcode
merge hhcode using `asset03b'
tab _merge
drop _merge
sort hhcode
merge hhcode using `asset03c'
tab _merge
drop _merge
sort hhcode
merge hhcode using `asset03d'
tab _merge
drop _merge
sort hhcode
merge hhcode using `asset04'
tab _merge
drop _merge
sort hhcode
merge hhcode using `asset05'
tab _merge
drop _merge
sort hhcode

desc
summ

egen agricult=rsum(agland livestoc forestry agasset)
label var agricult "Total agricultural assets"

egen assets=rsum(house-durable)
label var assets "Total value of assets"

order hhcode-agasset agricult otheland otheasse durable assets

sort hhcode
compress
save assets\assets.dta, replace
log close
