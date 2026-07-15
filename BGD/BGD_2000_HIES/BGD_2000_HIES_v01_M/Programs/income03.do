clear
set mem 75m
set more off

cap log using income\income03.log, replace

** Program to calculate the annual income of the household. Income
** is calcuated with four main components: (i) wage income (salaries
**  and daily wage employment), (ii) non-agri business, (iii) farm income
** and (iv) other income (assets, housing, transfers etc.)

** PROGRAM MODIFIED ON DEC 13 -- COMBINES INCOME01 AND INCOME02 PROGRAMS
** SAVES INCOME03.DTA FILE, WHICH INCLUDES HOUSEHOLD INCOME BY SOURCE

***************************************************************************
**                 (i) Salaries and daily wage employment                **
***************************************************************************

use activity.dta, clear

**** wage sector
**** the classification is as follows:
**** 1 ====> if the worker is in the Agriculture industry
**** 2 ====> if the worker is in the Manufacture industry
**** 3 ====> if the worker is neither in 1 nor 2 and is a "White collar"
**** 4 ====> otherwise, here more than 50% is Fishing and Construction

**** White collar was defined as having one of the following occupations:
   *** Professional, technical and related workers 
   *** Administrative and managerial workers
   *** Clerical and related workers and government and executive officials
   *** Sales workers
   *** Service workers

gen flag1=1 if (s5a01c==1 | (s5a01c>=15 & s5a01c<=37))
gen profe=1 if s5a01b>=1 & s5a01b<=59

gen      wagesec=1 if s5a06==1 & s5a01c==1
replace  wagesec=2 if s5a06==1 & (s5a01c>=15 & s5a01c<=37)
replace  wagesec=3 if s5a06==1 & profe==1 & flag1==.
recode wagesec .=4 if s5a06==1
drop flag1 profe
label var wagesec "Activity for wage workers"
label define wagesec 1 "Agriculture" 2 "Manufacturing" 3 "White collar" 4 "Others"
label values wagesec wagesec

*** daily basis (cash) ***
gen double cash1=s5b02*s5a03*s5a02 if s5b01==1
* impute in-kind payments for daily basis
gen double paddy1=s5b05*s5a03*s5a02*6.68 if s5b01==1 & s5b03==1 & s5b04==1
gen double  rice1=s5b05*s5a03*s5a02*12   if s5b01==1 & s5b03==1 & s5b04==2
gen double wheat1=s5b05*s5a03*s5a02*12   if s5b01==1 & s5b03==1 & s5b04==3
egen double wage1=rsum(cash1 paddy1 rice1 wheat1)

*** non-daily basis (cash+in-kind) ***
gen double   cash2=s5b08*s5a02 if s5b01==2
gen double inkind2=s5b10
egen double  wage2=rsum(cash2 inkind2)

egen wage = rsum(wage1 wage2)
drop wage1 wage2

gen wage1 = wage if wagesec==1
gen wage2 = wage if wagesec==2
gen wage3 = wage if wagesec==3
gen wage4 = wage if wagesec==4

collapse (sum) wage1 wage2 wage3 wage4, by(hhcode)
compress

label var wage1 "agri wage"
label var wage2 "manuf wage"
label var wage3 "white collar wage"
label var wage4 "other wage"

sort hhcode
save income\inc01.dta, replace


***************************************************************************
**                   (ii) Non-agriculture self-employment                **
***************************************************************************

use business.dta, clear

count if s613==. /*11 cases with missing gross revenues*/

*Two estimates of net revenues:
*1. calculate revenues - expenses
	egen expenses=rsum(s614-s619)
	gen netrev1=s613-expenses
*2. directly reported in s620 ==> use larger of the two estimates of net rev
	replace netrev1=s620 if s620>netrev1 & s620~=. 

replace s607=100 if s607==0 | s607==.

gen nonagri=s607*netrev1/100

gen nonagri1 = nonagri if s601b==1
gen nonagri2 = nonagri if (s601b>=15 & s601b<=37)
gen nonagri3 = nonagri if nonagri1==. & nonagri2==.

collapse (sum) nonagri1 nonagri2 nonagri3, by (hhcode)
compress

label var nonagri1 "enterprise income:ag"
label var nonagri2 "enterprise income:manuf"
label var nonagri3 "enterprise income:other"

sort hhcode
save income\inc02.dta, replace


***************************************************************************
**                           (iii) Farm incomes                          **
***************************************************************************

* A. CROP REVENUES AND IN-KIND PAYMENTS FOR CROP PRODUCTION
use agri02.dta, clear

* drop records with no info at all
gen ok1=1 if s7b02a==. & s7b02b==. & s7b03a==. & s7b03b==. & s7b03c==. & s7b03d==. & /*
		*/ s7b03e==. & s7b03f==. & s7b04==. & s7b05==.

gen ok2=1 if s7b02a==0 & s7b02b==0 & s7b03a==0 & s7b03b==0 & s7b03c==0 & s7b03d==0 & /*
		*/ s7b03e==0 & s7b03f==0 & s7b04==0 & s7b05==0

drop if ok1==1
drop if ok2==1
drop ok*

*Fix quantities when uses<<production (fix only those that are off by exactly a factor of 10)
	egen uses=rsum(s7b03a-s7b03f s7b04 s7b05)
	replace s7b02a=uses if (s7b02a/10)==uses 

*Quantity of sales and consumption
	egen csmsale= rsum(s7b04 s7b05)

*Fixing unit values (large outliers)
	replace s7b02b=(s7b02b/10) if s7b02b>=40 & (cropcode==1|cropcode==5|cropcode==17| /*
		*/ cropcode==68|cropcode==77|cropcode==85|cropcode==101) 

*Two alternative measures of net production
*1. output-uses (don't include animal feed in uses)
	egen exp1=rsum(s7b03a s7b03b s7b03c s7b03e s7b03f)
	gen netp1=s7b02a-exp1
*2. sales+consumption+animal feed
	egen netp2= rsum(csmsale s7b03d)

*Replace netp1 with netp2 if it is missing or smaller than netp2
	replace netp1=netp2 if netp1==.
	replace netp1=netp2 if netp2>netp1

*Now generate value of net production and animal feed
gen netcval=netp1*s7b02b  
gen animfeed=s7b03d*s7b02b

collapse (sum) netcval animfeed, by(hhcode)
label var netcval "Net crop prodn (value)"
label var animfeed "Crop prod for fodder (value)"
compress
sort hhcode
save income\inc03a.dta, replace


* B. REVENUES FROM LIVESTOCK PRODUCTS
use agri04.dta, clear

* drop records with no info at all
gen ok1=1 if s7c01a==. & s7c01b==. & s7c02a==. & s7c02b==. & s7c03a==. & s7c03b==.
gen ok2=1 if s7c01a==0 & s7c01b==0 & s7c02a==0 & s7c02b==0 & s7c03a==0 & s7c03b==0
gen ok3=1 if s7c01a==. & s7c01b==0 & s7c02a==0 & s7c02b==0 & s7c03a==0 & s7c03b==0
drop if ok1==1
drop if ok2==1
drop if ok3==1
drop ok*

*Fix outliers (error in s7c01b: in some cases, it is the unit value, and others the total value)
*convert to unit values
	replace s7c01b=s7c01b/s7c01a if s7c01b>100  & (prodcode==211|prodcode==212) 
	replace s7c01b=s7c01b/s7c01a if s7c01b>140  & (prodcode==213) 
	replace s7c01b=s7c01b/s7c01a if s7c01b>=100 & (prodcode==214) 
	replace s7c01b=s7c01b/s7c01a if s7c01b>12   & (prodcode==215) 
	replace s7c01b=s7c01b/s7c01a if s7c01b>5    & (prodcode==216|prodcode==217) 

*One big outlier on eggs (no quantity reported)
	replace s7c02b=. if prodcode==215 & s7c02b>700000
*fix cases (all cow dung) with quantities but no taka values (median price=1 tk)
	replace s7c01b=1 if (prodcode==217) & (s7c01b==0 & s7c01a~=0 & s7c01a~=.) 

*Generate two alternative measures of value of output
gen live1=s7c01b*s7c01a
	replace live1=s7c01b if prodcode==218  /*other livestock products*/
*Live1 is missing in 15 observations -- replace with sum of sales/csm
egen live2 = rsum(s7c02b s7c03b) 
	replace live2=3000 if hhid=="2583109011" & prodcode==215 /*s7c03b entered as unitvalue*/

replace live1=live2 if live1==.
replace live1=live2 if live2>live1 & live2~=.

collapse (sum) liveout=live1, by(hhcode)
label var liveout "Livestock products: Production"
compress
sort hhcode
save income\inc03b.dta, replace



* C. REVENUES FROM FISH FARMING AND FISH CAPTURE
use agri05.dta, clear

* drop records with no info at all
gen ok1=1 if  s7c01a==. & s7c01b==. & s7c02a==. & s7c02b==. & s7c03a==. & s7c03b==.
gen ok2=1 if  s7c01a==0 & s7c01b==0 & s7c02a==0 & s7c02b==0 & s7c03a==0 & s7c03b==0
drop if ok1==1
drop if ok2==1
drop ok*

* check out total
	egen check=rsum(s7c02b s7c03b)
	replace s7c01b=check if check>s7c01b
collapse (sum) s7c01b, by( hhcode)
rename s7c01b fish
label var fish "Fish farming: Production"
compress
sort hhcode
save income\inc03c.dta, replace


* D. FARM FORESTRY
use agri06.dta, clear

* drop records with no info at all
gen ok1=1 if s7c01a==. & s7c01b==. & s7c02==. & s7c03==.
gen ok2=1 if s7c01a==0 & s7c01b==0 & s7c02==0 & s7c03==0
drop if ok1==1
drop if ok2==1
drop ok*

collapse (sum) s7c02 s7c03, by (hhcode)
drop if s7c02==0 & s7c03==0
rename s7c02 forest1
rename s7c03 forest2
label var forest1 "Forestry: Sales"
label var forest2 "Forestry: Self-consumption"
compress
sort hhcode
save income\inc03d.dta, replace


* E. EXPENSES ON AGRICULTURAL INPUTS
use agri07.dta, clear
* to keep households with info on valuation of expenditures
drop if s7d01b==0 | s7d01b==.

keep hhcode expcode s7d01b
rename s7d01b expen
reshape wide expen, i(hhcode) j(expcode)

label var expen301 "Seed (crop seedling)"
label var expen302 "Seed (forest seedling)"
label var expen303 "Fertilizer (chemical)"
label var expen304 "Fertilizer (compose)"
label var expen305 "Food of livestock/draft animal"
label var expen306 "Tractor/tiller/power tiller (rental)"
label var expen307 "Irrigation expenses"
label var expen308 "Insecticides"
label var expen309 "Land revenue (agricultural land)"
label var expen311 "Rent (agricultural land)"
label var expen312 "Carriage charge of goods and communication"
label var expen313 "Salary wages of laborer employed in agriculture"
label var expen314 "Insurance expenses (agriculture related)"
label var expen315 "Power and fuel"
label var expen317 "Fish production expenses"
label var expen318 "Livestock rearing expenses"
label var expen319 "Poultry rearing expenses"
label var expen321 "Other expenses on agricultural inputs"
compress
sort hhcode
save income\inc03e.dta, replace


* F. AGRICULTURAL ASSETS
use agri08.dta, clear
drop if s7e04==0 | s7e04==.
collapse (sum) assets=s7e04, by(hhcode)
label var assets "Agr: Rents from assets"
compress
sort hhcode
save income\inc03f.dta, replace


** PUTTING TOGETHER ALL THE FARM INCOME COMPONENTS**
use income\inc03a, clear
merge hhcode using income\inc03b.dta
tab _merge
drop _merge
sort hhcode
merge hhcode using income\inc03c.dta
tab _merge
drop _merge
sort hhcode
merge hhcode using income\inc03d.dta
tab _merge
drop _merge
sort hhcode
merge hhcode using income\inc03e.dta
tab _merge
drop _merge
sort hhcode
merge hhcode using income\inc03f.dta
tab _merge
drop _merge
sort hhcode

desc
summ
for var netcval-assets: recode X .=0


** ADDING THEM UP **

* crop profit
egen double cropexp=rsum(expen301 expen303 expen304 expen306-expen315 expen321)
gen  double cropprod=netcval-cropexp

* livestock products
* Removing one outlier
replace expen319=. if expen319==540000
egen double liveexp=rsum(animfeed expen305 expen318 expen319)
gen double liveprod=liveout-liveexp

* fish farming and fish capture
* Removing two outliers
replace expen317=0 if expen317>=100000
gen double fishfarm=fish-expen317

* farm forestry
gen double forestry=forest1+forest2-expen302

* assets
* remains the same

* net income from agriculture
egen double agincome=rsum(cropprod liveprod fishfarm forestry assets)
compress

sort hhcode
save income\inc03.dta, replace


***************************************************************************
**                           (iv) Other income                           **
***************************************************************************

use hhlist.dta, clear
keep hhcode s8b01-s8b13er

* program transfers
* first we add up the quantities of grain transfers, and then multiply them by their prices
egen double wheat2=rsum(s8b13dw s8b13fw s8b13gw s8b13ew)
egen double  rice2=rsum(s8b13dr s8b13fr s8b13gr s8b13er)
replace wheat2=wheat2*12
replace  rice2= rice2*12
label var wheat2 "Wheat from programs"
label var  rice2 "Rice from programs"
drop s8b13dw s8b13fw s8b13gw s8b13ew s8b13dr s8b13fr s8b13gr s8b13er

* drop records with no info at all
gen ok1=1 if s8b01==0 &  s8b02==0 & s8b03==0 & s8b04==0 & s8b05==0 & s8b06==0 & /*
	*/ s8b07==0 &  s8b08==0 & s8b09==0 & s8b10==0 & s8b11==0 & s8b12==0 & wheat2==0 & rice2==0
drop if ok1==1
drop ok1

compress
sort hhcode
save income\inc04a.dta, replace

 
* female secondary stipend
use plist.dta, clear
keep if s3b05==1
keep hhcode s3b06
drop if s3b06==. | s3b06==2 | s3b06==0
collapse (sum) s3b06, by(hhcode)
compress
label var s3b06 "Female secondary stipend"

sort hhcode
save income\inc04b.dta, replace


* imputed house rent
use nfood03, clear
keep if itemcode==372
ren value housing
keep hhcode housing
drop if housing==0 | housing==.

sort hhcode
save income\inc04c.dta, replace


** Putting together the other income components **
use income\inc04a, clear

merge hhcode using income\inc04b.dta
tab _merge
drop _merge
sort hhcode
merge hhcode using income\inc04c.dta
tab _merge
drop _merge

sort hhcode
save income\inc04.dta, replace


***************************************************************************
**                   Pulling all sub-components together                 **
***************************************************************************

use income\inc01.dta, clear

merge hhcode using income\inc02.dta
tab _merge
drop _merge
sort hhcode
merge hhcode using income\inc03.dta
tab _merge
drop _merge
sort hhcode
merge hhcode using income\inc04.dta
tab _merge
drop _merge
sort hhcode

egen     agri = rsum(wage1 nonagri1 agincome)
gen   wsalary = wage3 
egen manufact = rsum(wage2 nonagri2)
egen otherinc = rsum(s8b01-s8b12 wheat2 rice2 s3b06 housing wage4 nonagri3)

egen   income=  rsum(agri wsalary manufact otherinc)

label var     agri "Ag.income:wage+enterprise+agincome"
label var  wsalary "salary wages"
label var manufact "manuf income:wage+enterprise"
label var otherinc "Other income: rents, etc"

label var  cropexp  "Agr: Crop expenses,cash"
label var  liveexp "Agr: Livestock/poultry expenses"
label var cropprod "Agr: Net crop income"
label var liveprod "Agr: Net livestock income"
label var fishfarm "Agr: Net fish farming income"
label var forestry "Agr: Net forestry income"
label var agincome "crop+livestock+fish+forestry+rental income"

label var   income "Total annual income"

keep hhcode wage1-wage4 agri wsalary manufact otherinc nonagri1-nonagri3 cropprod liveprod /*
*/ fishfarm forestry assets agincome income

sort hhcode
save income\income03.dta, replace

