/*------------------------------------------------------------------------------
					GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   		NPL_2010_LSS-III_v01_M.do				   </_Program name_>
<_Application_>    		STATA 17.0							     <_Application_>
<_Author(s)_>      		luciarleira@gmail.com	          		  </_Author(s)_>
<_Date created_>   		26-05-2025	                           </_Date created_>
<_Date modified>   		25-06-2025	                          </_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        		NPL											</_Country_>
<_Survey Title_>   		LSS								   </_Survey Title_>
<_Survey Year_>    		2010									</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
- First version
</_Version Control_>
------------------------------------------------------------------------------*/

*<_Program setup_>
clear all
set more off

*global rootdatalib "C:\Users\47860207\Dropbox\A-Work\A-Cedlas\2024\Asia\datalib\SARMD\WORKINGDATA\bases"
global rootdatalib "C:\Users\lucia\Dropbox\A-Work\A-Cedlas\2024\Asia\datalib\SARMD\WORKINGDATA\bases"

*global rootdofiles "C:\Users\47860207\Dropbox\A-Work\A-Cedlas\2024\Asia\datalib\SARMD\SARMDdofiles"
global rootdofiles "C:\Users\lucia\Dropbox\A-Work\A-Cedlas\2024\Asia\datalib\SARMD\SARMDdofiles"

*global cpiver       "10"
global cpiver		"v12"
local code         	"NPL"
local year         	"2010"
local survey       	"LSS-III"
local vm           	"01"
local yearfolder   	"`code'_`year'_`survey'"
global input       	"${rootdatalib}\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M\Data\Stata"
global output      	"${rootdatalib}\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M\Data\Stata"


*</_Program setup_>

*<_Datalibweb request_>

* ------------------------------------------------------------
*Section 1: household roster (individual level)
* ------------------------------------------------------------
use "${input}\S01.dta"
/*ta v01_10
1.10 member |
    or not? |      Freq.     Percent        Cum.
------------+-----------------------------------
        Yes |     34,581       99.33       99.33
         No |        234        0.67      100.00
------------+-----------------------------------
      Total |     34,815      100.00
			   */
keep if v01_10==1 // household member
tempfile roster
egen hhid = concat(xhpsu xhnum), punct(-)
gen com = v01_idc
sort hhid com
save  `roster', replace

egen tag = tag(hhid)
keep if tag==1
keep hhid
tempfile hhid
save `hhid', replace

*S00: language variable
use "${input}\S00.dta" 
tempfile language
egen hhid = concat(xhpsu xhnum), punct(-)
keep hhid v00_f
save  `language', replace

* ------------------------------------------------------------
*Section 2: housing : S020.dta includes all subsections (hh level)
* ------------------------------------------------------------
* Secion 2.1 type of dwelling
* Section 2.2 housing expenses and utilities
* Secion 2.3: utilities and ammenities
/*Implicit rent: 
(2,11)	Is this dwelling yours?	
*For owners:
(2,13)	If someone wanted to rent this dwelling today, how much money would they have to pay each month?							
(2.16)	What is your present occupancy status?							
	RENTER					1	►	(2.18)
	PROVIDED FREE OF CHARGE					2		
	SQUATTING					3		
	OTHER						4		
*For those not owner but not paying rent:
(2.17)	If someone wanted to rent this dwelling (only the unit occupied by the household) today, how much money would they have to pay each month?							
	a.	In Words:						
	► 	(2.19)						
(2.18)	What is the rent per month? INCLUDE CASH PLUS VALUE OF IN-KIND PAYMENTS							
*/
use "${input}\S02.dta", clear
tempfile housing
egen hhid = concat(xhpsu xhnum), punct(-)
sort hhid
gen implicit_rent = v02_13 if v02_11==1
replace implicit_rent = v02_17 if v02_16==2 | v02_16==3 | v02_16==4
*income from renting: (2.15)	How much rent do you receive per month?	RUPEES		
gen inc_renting_housing = v02_15
save  `housing', replace


* ------------------------------------------------------------
*Section 3: access to facilities (not used) S030.dta -- hh/code level
* ------------------------------------------------------------

* ------------------------------------------------------------
*Section 4: Migration -- individual level
* ------------------------------------------------------------
use "${input}\S04.dta", clear
tempfile migration
egen hhid = concat(xhpsu xhnum), punct(-)
gen com = v04_idc
sort hhid com 
save  `migration', replace

* --------------------------------------------------------------------------------------------------------
*Section 5: Food Expenses and Home Production (hh/code level): only own production and received in kind
* --------------------------------------------------------------------------------------------------------
/*
v05_04 HOME PRODUCTION: How much would your household have to spend in the market to buy this quantity of ..[FOOD].. (i.e. the amount consumed in a typical month)?
v05_08 IN KIND: What is the total value of  ..[FOOD].. consumed that you received in-kind over the past 12 months (wages for work, etc.)?
*/
use "${input}\S05.dta", clear
tempfile food
egen hhid = concat(xhpsu xhnum), punct(-)
rename v05_04 food_own_prod
rename v05_08 food_inkind
egen food_own_noncrop = rsum(food_own_prod) if inlist(v05_idc,031,032,035,036,041,071,072,074,075), m
replace food_own_noncrop = . if food_own_noncrop==0
gcollapse (sum) food_own_noncrop food_inkind, by(hhid)
replace food_inkind = food_inkind/12
sort hhid 
*food consumption from in KIND --> other non labor income 
keep hhid food_inkind food_own_noncrop
save  `food', replace

* -----------------------------------------------------------------------------
*Section 6: Non-Food Expenditures & Inventory of Durable Goods (hh/code level)
* -----------------------------------------------------------------------------
***************
* Section 6D: 
***************
*Were any of the following items produced and consumed by your household over the past 12 months?
use "${input}\S06D.dta", clear
* v06_12b What is the monetary value of the items produced and consumed yourself? a) 30 days (7,422); b) during the past 12 months (16,249) --> recall period 12 months
tempfile nonfood_own
egen hhid = concat(xhpsu xhnum), punct(-)
drop if v06d_idc==600
gcollapse (sum) v06_12b, by(hhid)
rename v06_12b nonfood_own
replace nonfood_own = nonfood_own/12
sort hhid 
keep hhid nonfood_own
save  `nonfood_own', replace

* -----------------------------------------------------------------------------
* Education: s7: includes section 7, section 7.2 and 7.3 (individual level)
* -----------------------------------------------------------------------------
use "${input}\S07.dta", clear
tempfile education
egen hhid = concat(xhpsu xhnum), punct(-)
gen com = v07_idc
sort hhid com
*v07_27 Did ..[NAME].. receive a scholarship to help pay for your educational expenses?
*v07_28 How much did ..[NAME].. receive over the past 12 months?
gen scholarship = v07_28/12 if v07_27==1
save  `education', replace

* -----------------------------------------------------------------------------
* S10: JOBS 
* -----------------------------------------------------------------------------
use "${input}\S10B.dta", clear
*tempfile labor
egen hhid = concat(xhpsu xhnum), punct(-)
gen com = v10_02
gen id_job = v10_02_job
sort hhid com id_job
/* Employment Categories: 
1 = empleador/patrón
2 = empleado/asalariado
3 = cuentapropista/independiente
4 = trabajador no remunerado
5 = desocupado
*v10_07 What was the type of work? (past 7 days) 						
    wage employment in agri.
wage employment in non-agri.
    self-employment in agri.
self-employment in non-agri.
*/

gen relab_s10 = 2 				if  v10_07==1 | v10_07==2
replace relab_s10 = 3 			if  v10_07==3 | v10_07==4

gen agric_sector_s10 = 1 if v10_07==1 | v10_07==3
replace agric_sector_s10 = 0 if v10_07==2 | v10_07==4.

gen occup_self = v10_03
gen hs_self = v10_06h
egen nmonths_self = rsum(v10_04*)

preserve
tempfile labor_noagric_main
keep if (relab_s10==1 | relab_s10==3) & agric_sector_s10==0 
keep relab hhid com agric_sector_s10 id_job occup_self hs_self nmonths_self
sort hhid com 
save  `labor_noagric_main', replace
restore

* -------------------------*
*   Ingresos de salarios
* -------------------------*

keep if relab == 2

*Tengo que definir main para después procesar las otras variables: en función de cuántos dias al año haya trabajado
*v10_04 In which month did you work on this job during the past 12 months ?
*v10_05a  on average no.of days/month work
foreach var of varlist v10_04* {
replace `var' = 0 if `var'==2
}
egen nmonths = rsum(v10_04*)
gen ndays = v10_05a*nmonths
egen aux1 = max(ndays), by(hhid com)
gen main_day = 1 if ndays == aux1
replace main_day = 0 if ndays < aux1

egen aux2 = sum(main_day) if main_day!=., by(hhid com)
ta aux2
* a los que tienen un unico main por persona, les asigno el main_day y con eso es suficiente
gen main_s10 = main_day if aux2==1

*quedan algunos que tienen igual nro de días, asi que elijo por horas
*v10_05b ..how many hours per day did you work on this?
gen nhours = v10_05b
egen aux3 = max(nhours), by(hhid com)
gen main_hs = 1 if nhours == aux3 & (aux2==2 | aux2 ==3)
replace main_hs = 0 if nhours < aux3 & (aux2==2 | aux2 ==3)
egen aux4 = sum(main_hs) if main_hs!=., by(hhid com)

replace main_s10 = main_hs if main_s10==. & aux4 == 1

/*quedan en missings los que siguen empate en todos: elijo el relab = 2
egen aux6 = min(relab_s10) if main_s10==., by(hhid com)
egen aux7 = max(relab_s10) if main_s10==., by(hhid com)
gen tag = 1 if aux6 != aux7 & aux6!=.
replace main_s10 = 1 if tag==1 & relab_s10 == 2
*/

*en empate, elijo el de menor línea:
egen aux6 = min(id_job) if main_s10==., by(hhid com)
replace main_s10 = 1 if main_s10==. & id_job==aux6
replace main_s10 = 0 if main_s10==. & id_job!=aux6

*njobs (wage jobs)
egen njobs_wages = sum(1) if id_job!=. & relab_s10==2, by(hhid com)

*si hay más de 2 trabajos: me quedo con el de mayor línea para definir el secundario
egen aux7 = min(id_job) if main_s10==0 & njobs_wages>=2 & njobs_wages!=., by(hhid com)
gen secondary = 1 if id_job == aux7 & main_s10==0 & njobs_wages>=2 & njobs_wages!=.
replace secondary = 0 if id_job > aux7 & id_job!=. & main_s10==0 & njobs_wages>=2 & njobs_wages!=.

gen past_7days = 1 if v10_06h>0 & v10_06h!=.
replace past_7days = 0 if v10_06h==0

tempfile wages_info
sort hhid com id_job
gen order = 1 if main_s10 == 1
replace order = 2 if main_s10 == 0 & secondary == 1
replace order = 3 if main_s10 == 0 & secondary == 0 & njobs == 3
bysort hhid com: gen rank = sum(1) if order==.
replace order = 4 if rank == 1
replace order = 5 if rank == 2
replace order = 6 if rank == 3
drop rank

gen occup = v10_03
gen hs_wage = v10_06h

*keep hhid com id_job order main_s10 secondary agric_sector_s10 n* occup* past_7days
keep hhid com id_job order main_s10 secondary agric_sector_s10 n* past_7days occup hs_wage
save  `wages_info', replace


use "${input}\S12.dta", clear
egen hhid = concat(xhpsu xhnum), punct(-)
gen com = v12_01
gen id_job = v12_01_job

merge 1:1 hhid com id_job using `wages_info'
drop if _merge!=3
drop _merge 

*Contract/piece rate: v12_21 During the past 12 months, having worked on a contract how much did you receive in-kind and cash? 
gen contract_cash = v12_21 / 12	
gen contract_kind = .

/*Longer basis in agriculture: 
v12_08 How much did you get in cash for this job over the past 12 months?
v12_10a What was the value of what you received in kind? rupees per day (habría que ver si uno descuenta el inkind de food)
*/
gen longbasis_cash_agric = v12_08/12		
gen aux1 = v12_10a*ndays/365*12
gen aux2 = v12_10b/12
egen longbasis_kind_agric = rsum(aux1 aux2)
drop aux*

* LONGER BASIS not in agriculture
/* v12_15 How much did you get paid for this job
A	Take-home pay per month?	MONTH
B	Transport per month?  MONTH
C	Bonuses, tips, allowances (include. Dasain)? 12 MONTHS
D	Uniform / clothing ? 12 MONTHS
E	Other allowance	 12 MONTHS	*/
egen aux1 =rsum(v12_15c v12_15d v12_15e), m		
replace aux1 = aux1/12 
egen aux2 = rsum(aux1 v12_15b), m
gen longbasis_cash_noagric = v12_15a		
gen longbasis_kind_noagric = aux2
drop aux*

gen wage_base = v12_15a

egen longbasis_cash = rsum(longbasis_cash_agric longbasis_cash_noagric), missing
egen longbasis_kind = rsum(longbasis_kind_agric longbasis_kind_noagric), missing
drop longbasis_cash_agric longbasis_cash_noagric longbasis_kind_agric longbasis_kind_noagric

/* Monthly Income of those working as day labourers
v12_04 How much did you get in cash per day for this job?
v12_06a What was the value of what you received in kind? per day
*/
gen daylab_cash = v12_04*ndays/12
gen aux1 = v12_06a*ndays/12
gen aux2 = v12_06b/12
egen daylab_kind = rsum(aux1 aux2)
drop aux*
*keep hhid com order main_s10 secondary agric_sector_s10 n* occup* past_7days daylab* longbasis* contract* wage_base
keep hhid com order main_s10 secondary agric_sector_s10 n* past_7days daylab* longbasis* contract* wage_base occup v12* hs_wage
reshape wide main_s10 secondary agric_sector_s10 n* past_7days daylab* longbasis* contract* wage_base occup v12* hs_wage , i(hhid com) j(order)	
save  `wages_info', replace

* ----------------------------------------------
* S11: Unemployment /Underemployment
* ----------------------------------------------	
use "$input\S11.dta", clear
egen hhid = concat(xhpsu xhnum), punct(-)
ren v11_idc com
qui compress
tempfile unemployment
save `unemployment'

* ----------------------------------------------
* S13: Farming and livestock (hh level)
* ----------------------------------------------
*la dinámica es esta: los que son long (requieren pasar a wide) porque tienen info de varios plots o parcels están separados en sus minibases
* Después está la base S110.dta que tiene la info que ya estaba en wide (las preguntas que tienen solamente una fila por hogar)

*********************************
use "${input}\S13A1.dta", clear
egen hhid = concat(xhpsu xhnum), punct(-)
*v13_03 Does your household own any agricultural land? no está la pregunta entonces lo deduzco de la base de preguntas sobre plots
gen ownagriland = 1
*keep hhid ownagriland
gcollapse ownagriland, by(hhid)
tempfile ownagriland_aux
save `ownagriland_aux'

use "${input}\S13A2.dta", clear
tempfile notownland
egen hhid = concat(xhpsu xhnum), punct(-)
*v13_18 Over the past AGRICULTURE YEAR did your household cultivate land owned by someone else or that was mortgaged in? no está la pregunta entonces lo deduzco de la base de preguntas sobre plots
gen notownland = 1
gcollapse notownland, by(hhid)
tempfile notownland_aux
save `notownland_aux'

use `hhid', clear
merge 1:1 hhid using  `ownagriland_aux', nogen
merge 1:1 hhid using `notownland_aux', nogen
replace notownland = 0 if notownland==.
replace ownagriland = 0 if ownagriland==.
tempfile agriland
save `agriland', replace

*********************************
* Rent received from parcel (hh/parcel level)
*********************************
use "${input}\S13A1.dta", clear
tempfile rent_land_inc
*For the plots which you did not crop yourself during the last dry season, what net rent did you receive from the tenant? v13_12c
*v13_12k in kind
*v13_15c v13_15k --> same but wet season
egen aux  = rsum(v13_12c v13_12k v13_15c v13_15k), missing
gen rent_land_inc= aux/12
egen hhid = concat(xhpsu xhnum), punct(-)
gcollapse (sum) rent_land_inc, by(hhid)
keep hhid rent_land_inc 
save  `rent_land_inc', replace

*********************************
* Rent payed for parcel
********************************
use "${input}\S13A2.dta", clear
tempfile rent_land_exp
*v13_21 How much “rent” did you pay for this plot to the landlord?
gen rent_land_exp = v13_21/12
replace rent_land_exp = rent_land_exp*(-1)
egen hhid = concat(xhpsu xhnum), punct(-)
gcollapse (sum) rent_land_exp, by(hhid)
sort hhid
save  `rent_land_exp', replace

****************
* Own land uses
****************
use "${input}\S13A1.dta", clear
tempfile area_ownland
egen hhid = concat(xhpsu xhnum), punct(-)
/*En el sistema Ropani (usado en las regiones montañosas):
1 Ropani = 16 Ana
1 Ana = 4 Paisa
1 Ropani ≈ 508.72 m²
Por lo tanto:
1 Ana ≈ 31.80 m²
1 Paisa ≈ 7.95 m²
En el sistema Bigha (usado en las regiones del Terai):
1 Bigha = 20 Kattha
1 Kattha = 20 Dhur
1 Bigha ≈ 6,772.63 m²
Por lo tanto:
1 Kattha ≈ 338.63 m²
1 Dhur ≈ 16.93 m²
*/
*Ropani:
gen aux1r = v13_04rb*508.72 if v13_04u==1
gen aux2r = v13_04ak*31.80 if v13_04u==1
gen aux3r = v13_04pd*7.95 if v13_04u==1
*Bigha:
gen aux1b = v13_04rb*6772.63 if v13_04u==2
gen aux2b = v13_04ak*338.63 if v13_04u==2
gen aux3b = v13_04pd*6.935 if v13_04u==2
egen auxr = rsum(aux1r aux2r aux3r), missing
egen auxb = rsum(aux1b aux2b aux3b), missing
gen area_ownagriland = auxr if v13_04u==1
replace area_ownagriland = auxb if v13_04u==2
drop aux*
/*v13_11 Over the past DRY SEASON what did you do with the .[PLOT].?
v13_14 Over the past WET SEASON what did you do with the .[PLOT].?
1 CROPPED YOURSELF	
2 SHARECROPPED OUT	
3 FIXED RENT OUT	
4 MORTGAGED OUT	
5 LEFT FALLOW	
6 OTHER	*/
gen aux = 1 if v13_11==2 | v13_11==3 | v13_14==2 | v13_14==3
replace aux = 0 if inlist(v13_11,1,4,5,6) | inlist(v13_14,1,4,5,6)
egen rentout_agriland = max(aux), by(hhid)
gen arearentout_agriland = area_ownagriland if aux == 1
gcollapse (sum) area_ownagriland arearentout_agriland (mean) rentout_agriland, by(hhid)
replace area_ownagriland = area_ownagriland/10000
replace arearentout_agriland = arearentout_agriland/10000
keep hhid area_ownagriland arearentout_agriland rentout_agriland
save  `area_ownland', replace

********************
*Not own land uses
********************
use "${input}\S13A2.dta", clear
tempfile area_notownland
egen hhid = concat(xhpsu xhnum), punct(-)
/*v13_20 What is the contractual arrangement on this .[PARCEL].?
SHARECROPPED
RENTED-IN
MORTGAGED-IN
OTHER*/
gen aux = 1 if v13_20==1 | v13_20==2
replace aux = 0 if inlist(v13_20,3,4)
egen rentin_agriland = max(aux), by(hhid)
/*En el sistema Ropani (usado en las regiones montañosas):
1 Ropani = 16 Ana
1 Ana = 4 Paisa
1 Ropani ≈ 508.72 m²
Por lo tanto:
1 Ana ≈ 31.80 m²
1 Paisa ≈ 7.95 m²
En el sistema Bigha (usado en las regiones del Terai):
1 Bigha = 20 Kattha
1 Kattha = 20 Dhur
1 Bigha ≈ 6,772.63 m²
Por lo tanto:
1 Kattha ≈ 338.63 m²
1 Dhur ≈ 16.93 m²
*/
*Ropani:
gen aux1r = v13_22rb*508.72 if  v13_22u==1
gen aux2r = v13_22ak*31.80 if  v13_22u==1
gen aux3r = v13_22pd*7.95 if  v13_22u==1
*Bigha:
gen aux1b = v13_22rb*6772.63 if  v13_22u==2
gen aux2b = v13_22ak*338.63 if  v13_22u==2
gen aux3b = v13_22pd*6.935 if  v13_22u==2
egen auxr = rsum(aux1r aux2r aux3r), missing
egen auxb = rsum(aux1b aux2b aux3b), missing
gen area_notownland = auxr if v13_22u==1
replace area_notownland = auxb if v13_22u==2
drop aux*
gen arearentin_agriland = area_notownland if v13_20==1 | v13_20==2
gcollapse (sum) area_notownland arearentin_agriland (mean) rentin_agriland, by(hhid)
replace area_notownland = area_notownland/10000
replace arearentin_agriland = arearentin_agriland/10000
keep hhid area_notownland arearentin_agriland rentin_agriland
save  `area_notownland', replace


* ----------------------------------------------------------------------
* Crops: part B and part c 
* S11: Part D: agriculture earnings and expenditures (hh level - long)
* ----------------------------------------------------------------------
* CROPS - OWN CONSUMPTION
tempfile food_own_monet
*===============================================================================
* 2. Crop income Section 11B: Production and uses
*=============================================================================== 
*-------------------------------------------------------------------------------
*2.1. Merge basic data with Section 11B
*-------------------------------------------------------------------------------
use "$input/S13B", clear

*-------------------------------------------------------------------------------
*2.5. Total sales
*-------------------------------------------------------------------------------
gen value_sale = v13_38b * v13_38c

*-------------------------------------------------------------------------------
*2.3. Drop if crop_code is missing
*-------------------------------------------------------------------------------
ren v13_35cc crop_code
drop if inlist(crop_code,0,.)

*-------------------------------------------------------------------------------
*2.4. Convert the units of reported total quantity sold(kilogram, maund, muri, quintal, gota(pieces)) to three standard units: kg, manna and piece
*-------------------------------------------------------------------------------
clonevar price = v13_38c
clonevar unit = v13_38a

recode unit (0=.)
recode price (0 =.)

/*==============================================================================
Conversion rule; 
a. kg, maund and quintal -> kg; b. muri -> manna; c. gota(pieces)-> pieces
	1 MAUND = 37.324 KILOGRAMS
	1 MURI = 160 MANNA
	1 QUINTAL = 100 KILOGRAMS
==============================================================================*/
*-------------------------------------------------------------------------------
*2.4.1. Convert price
*-------------------------------------------------------------------------------
gen double price_2 = .  

tokenize "1 37.324 160 100 1"

forval i = 1/5{
	replace price_2= price / ``i'' if unit==`i' 
}

*-------------------------------------------------------------------------------
*2.4.2. Correct converted units
*-------------------------------------------------------------------------------
recode unit (1 2 4 = 1) (3 = 2) (5 = 3) (nonmiss = .), gen(unit_2)
label define unit_la 1 "kg" 2 "manna" 3 "piece"
label values unit_2 unit_la

drop price unit
ren price_2 price
ren unit_2 unit

*-------------------------------------------------------------------------------
*2.5. Merge Region variables
*-------------------------------------------------------------------------------
*merge m:1 psu_number hh_number using "$data_cons/00_sample.dta", keep(1 3) keepusing(season rural_2022 domain rural_2022 base_hh_wt_adj ind_wt) nogen
merge m:1 xhpsu xhnum using "$input/sample.dta", keep(1 3) keepusing(season urbrur AD wt_hh wt_ind) nogen
rename AD domain

*-------------------------------------------------------------------------------	
*2.6. Save till this point in temporary file
*-------------------------------------------------------------------------------
preserve
	//v13_38_c_corr and v13_38_a_corr are the price and unit that is converted to one of the three standard units
	ren price v13_38c_corr
	ren unit v13_38a_corr
	tempfile orig
	save `orig'
restore

*-------------------------------------------------------------------------------	
*2.7. Create conversion factors based on the reported prices of items that are sold
*-------------------------------------------------------------------------------
/*==============================================================================
1. Create conversion factors at the domain level
2. Take average of the conversion rate weighted by the number of obs present to get the national conversion rate for entire country
==============================================================================*/

*-------------------------------------------------------------------------------
*2.7.1. Keep only relevant variables
*-------------------------------------------------------------------------------
*keep psu_number hh_number season rural_2022 domain rural_2022 base_hh_wt_adj ind_wt prov* s11b_ln q11_32 crop_code unit price

*-------------------------------------------------------------------------------
*2.7.2. Keep if price and unit variables are not missing
*-------------------------------------------------------------------------------
keep if !mi(price) & !mi(unit)

preserve
	tempfile conv conv2
	
	*---------------------------------------------------------------------------
	*2.7.3. Get median price and number of observations at domain level. This data is unique at unit level for each crop code
	*---------------------------------------------------------------------------
	//Andrea: weighted median aw? will get back
	collapse (median)price (count)count=price, by(domain crop_code unit)
	
	*---------------------------------------------------------------------------
	*2.7.4. Reshape the data to get unique at crop code level
	*---------------------------------------------------------------------------
	reshape wide price count, i(domain crop_code) j(unit)
	save `conv2'
	
	*---------------------------------------------------------------------------
	*2.7.5. Calculate weighted conversion rate
	*---------------------------------------------------------------------------
	//price1=>kg; price2=>manna; price3=>piece
	gen mpg = price1/price2
	gen npg = price1/price3 
	gen npm = price2/price3
	
	gen count_mpg = count1 + count2
	gen count_npg = count1 + count3
	gen count_npm = count2 + count3
	
	foreach v in mpg npg npm{ 
		egen sum_`v' = sum(count_`v'), by(crop_code)
		gen wt_`v' = count_`v'/sum_`v' 
		gen `v'_weighted = `v'*wt_`v' 
	}
	
	collapse (sum) manna_per_kg = mpg_weighted num_per_kg = npg_weighted num_per_manna=npm_weighted, by(crop_code)
	
	recode manna num* (0 =.)
	save `conv' 
restore

*-------------------------------------------------------------------------------
*2.8. Impute price in domain, urban/rural and national level
*-------------------------------------------------------------------------------
*Nishtha: use rural_2022 instead of ad_4
foreach v in domain urbrur "" {
	preserve
		tempfile m_`v'
		
		*-----------------------------------------------------------------------
		*2.8.1. Get median of price and number of observation per unit in crop level within the imputation level
		*-----------------------------------------------------------------------
		collapse (median) price_`v' = price (count) count_`v' = price, by(`v' crop_code unit)
		
		*-----------------------------------------------------------------------
		*2.8.2. Reshape: make it unique in crop level within the imputation level
		*-----------------------------------------------------------------------
		reshape wide price_`v' count_`v', i(`v' crop_code) j(unit)
		
		*-----------------------------------------------------------------------
		*2.8.3. Calculate price per unit for all units. Convert price and unit to most used unit i.e. unit with most observation if conversion factors not missing
		*-----------------------------------------------------------------------
		
		* Get the count of unit that has most number of observation per crop
		egen max_count = rowmax(count_`v'*)
		
		* Merge conversion factor
		merge m:1 crop_code using `conv', keep(1 3) nogen		

		* Replace prices according to rule:
		/*======================================================================
		Ruchi note: Tried to follow the same logic as in Round 3 but without dropping the already existing prices
		1. If unit kg has most number of observation keep price of kg as it is
		2. If manna/piece has most number of observation and conversion factor is not missing; replace the price of kg with converted price from manna/price
		3. If kg and manna/piece has same number of observation as kg then keep price of kg as it is
		
		final imputed price will have prices in all units that the crop originally had in each level; no dropping but the price per unit is corrected according to price that is most used
		======================================================================*/
		
		replace price_`v'1 = price_`v'2 * manna_per_kg if max_count==count_`v'2 & max_count!=count_`v'1 & !mi(manna_per_kg)
		replace price_`v'1 = price_`v'3 * num_per_kg if max_count==count_`v'3 & max_count!=count_`v'1 & !mi(num_per_kg)

		label var price_`v'1 "Unit price for `v': per kg"
		cap label var price_`v'2 "Unit price for `v': per manna"
		cap label var price_`v'3 "Unit price for `v': per num"
		
		save `m_`v''
		
	restore 
}

*-------------------------------------------------------------------------------
*2.9. Value the farmer's share of harvested quantity using imputed prices
*-------------------------------------------------------------------------------
use `orig', clear

*-------------------------------------------------------------------------------
*2.9.1. Check if total quantity sold is reported when total quantity harvested is 0
*-------------------------------------------------------------------------------
count if v13_37b==0 & v13_38b!=0 & !mi(v13_38b) //0

*-------------------------------------------------------------------------------
*2.9.2. Drop if total harvested quantity is 0
*-------------------------------------------------------------------------------
drop if v13_37b==0

*-------------------------------------------------------------------------------
*2.9.3. Harvested quantity remaining after giving portion to landlord
*-------------------------------------------------------------------------------
gen quant = v13_37b - v13_37c
replace quant = v13_37b if mi(v13_37c)
clonevar unit = v13_37a

*-------------------------------------------------------------------------------
*2.9.4. Convert the harvested quantity to one of the three standard units: kg, manna and piece
*-------------------------------------------------------------------------------
/*==============================================================================
Conversion rule; 
a. kg, maund and quintal -> kg; b. muri -> manna; c. gota(pieces)-> pieces
	1 MAUND = 37.324 KILOGRAMS
	1 MURI = 160 MANNA
	1 QUINTAL = 100 KILOGRAMS
==============================================================================*/
gen double quant_2 = . 

tokenize "1 37.324 160 100 1"

forval i = 1/5{
	replace quant_2= quant*``i'' if unit==`i'
}

*-------------------------------------------------------------------------------
*2.9.5. Correct converted units
*-------------------------------------------------------------------------------
recode unit (1 2 4 = 1) (3 = 2) (5 = 3) (nonmiss = .), gen(unit_2)
label values unit_2 unit_la

*-------------------------------------------------------------------------------
*2.9.6. Convert the corrected units to a single unit if conversion factor is not missing
*-------------------------------------------------------------------------------
* Get weighted conversion factor
merge m:1 crop_code using `conv', keep(1 3) nogen

gen quant_3 = quant_2
gen unit_3 = unit_2

replace quant_3 = quant_2/manna_per_kg if unit_2==2 & !mi(manna_per_kg)
replace unit_3 = 1 if unit_2==2 & !mi(manna_per_kg)

replace quant_3 = quant_2/num_per_kg if unit_2==3 & !mi(num_per_kg)
replace unit_3 = 1 if unit_2==3 & !mi(num_per_kg)

label values unit_3 unit_la

drop quant unit quant_2 unit_2

ren quant_3 quant
ren unit_3 unit

recode quant (0=.)

*-------------------------------------------------------------------------------
*2.9.7. start imputing prices at increasing level of aggregation
*-------------------------------------------------------------------------------
gen double value = .

*-------------------------------------------------------------------------------
*2.9.7.1. Use the household price if available. Convert the units to single unit if possible
*-------------------------------------------------------------------------------
// Ruchi note: 2 observation: q11_36_c not missing but quant is missing	
* harvested unit = sold unit 
replace value = v13_38c_corr * quant if v13_38a_corr==unit

* harvested unit = kg and sold unit = manna => Convert the harvested quantity to 
replace value = v13_38c_corr * manna_per_kg  * quant if v13_38a_corr==2 & unit==1
replace value = v13_38c_corr * num_per_kg 	* quant if v13_38a_corr==3 & unit==1

gen count_missing = missing(value)

*-------------------------------------------------------------------------------
*2.9.7.2. Get the imputed price in different imputation levels
*-------------------------------------------------------------------------------
* Domain Level
merge m:1 domain crop_code using `m_domain'
drop _m

* Urban/Rural Level
merge m:1 urbrur crop_code using `m_urbrur'
drop _m

* National Level
merge m:1 crop_code using `m_'
drop _m

*-------------------------------------------------------------------------------
*2.9.7.3. After calculating the harvested quantity value in household levels, replace the value with imputed price in increasing level
*-------------------------------------------------------------------------------
* Domain Level
di "Replacing by domain"
forval i = 1/3{
	cap replace value = quant*price_domain`i' if mi(value) & unit==`i'
}
gen n_ad = !mi(value) if !mi(quant)
	
* Urban/Rural Level
di "Replacing by urban/rural"
forval i = 1/3{
	cap replace value = quant*price_urbrur`i' if mi(value) & unit==`i'
}
gen n_urbru = !mi(value) if !mi(quant)

* National Level
di "Replacing by nation"
forval i = 1/3{
	cap replace value = quant*price_`i' if mi(value) & unit==`i'
}
gen n_nat = !mi(value) if !mi(quant)

*-------------------------------------------------------------------------------
*2.10. Check the number of missing till this point
*-------------------------------------------------------------------------------
gen check = mi(value)
replace check = . if mi(quant)
tab check

*Note: Price still missing for 0.43% observations till this point

*-------------------------------------------------------------------------------
*2.11. Collapse total in household level
*-------------------------------------------------------------------------------
// collapse (sum) cropinc = value cropinc_consump = value_consump cropinc_sale = value_sale, by(psu_number hh_number)
collapse (sum) cropinc = value cropinc_sale = value_sale, by(xhpsu xhnum)
gen food_own_monet = cropinc - cropinc_sale
egen hhid = concat(xhpsu xhnum), punct(-)
sort hhid
gcollapse (sum) food_own_monet, by(hhid)
replace food_own_monet = food_own_monet/12
save `food_own_monet', replace

* -----------------------------------
* FARMING: Total Revenues:
* -----------------------------------
use "${input}\S13D1.dta", clear
tempfile inc_agric
egen hhid = concat(xhpsu xhnum), punct(-)
/*v13_63 is "TOTAL REVENUE OVER AGRICULTURE YEAR"
1	Total crop sales							
	(Copy from Part B, Row 98)							
2	Sale of crop by-products (hay, straw, husk, etc.)							
7	Other income							
*/						
*v13d1_sn = 8 is TOTAL INCOME pero no está
replace v13_63 = v13_63/12
gen inc_tot_sectionD = v13_63 if v13d1_sn!=8
gen inc_agric = v13_63 if inlist(v13d1_sn,1,2,7)
*gen inc_crop = q11_62 if s11d1_code==1
gen rent_asset_inc = v13_63 if inlist(v13d1_sn,3,4,5,6)
gcollapse (sum) inc_agric rent_asset_inc inc_tot_sectionD, by(hhid)
*compare inc_tot inc_alt /*muy similares (211 con valores más altos en el inc_tot con promedio de 147 de diferencia y el mean gral es 1361*/ 
sort hhid
save  `inc_agric', replace

* -----------------------------------------------
* FARMING: Total Expenditures:(hh level - long)
* -----------------------------------------------
*v13_64 TOTAL REVENUE OVER AGRICULTURE YEAR
use "${input}\S13D2.dta", clear 
tempfile exp_agric
egen hhid = concat(xhpsu xhnum), punct(-)
*v13d2_en = 16 is TOTAL EXPENDITURE 
replace v13_64 = (v13_64/12)*(-1)
gen exp_agric = v13_64 if inlist(v13d2_en,1,2,3,4,5,6,7,8,9,10,15)
gen rent_asset_exp = v13_64 if inlist(v13d2_en,11,12,13,14)
gen exp_tot_sectionD = v13_64 if v13d2_en==16 
gcollapse (sum) exp_agric rent_asset_exp exp_tot_sectionD, by(hhid)
sort hhid
save  `exp_agric', replace

* -----------------------------------------------
* FARMING s13: Livestock sold
* -----------------------------------------------
use "${input}\S13E1.dta", clear
tempfile livestock_sold
*v13_69b How many did you sell over the past 12 months? How much did you sell them for? Ruppees
*LIVESTOCK CODE (v13e1_lc) --> 10 pero no está
gen livestock_sold = v13_69b/12 if v13e1_lc!=10
egen hhid = concat(xhpsu xhnum), punct(-)
gcollapse (sum) livestock_sold, by(hhid)
sort hhid
save  `livestock_sold', replace

* ------------------------------------------------------
* FARMING S11: Livestock and related expenses: income
* ------------------------------------------------------
use "${input}\S13E2.dta", clear
*v13_71 TOTAL INCOME OVER PAST 12 MONTHS --> 08	TOTAL INCOME	
tempfile livestock_inc
gen livestock_inc = v13_71/12 if v13e2_id == 9
egen hhid = concat(xhpsu xhnum), punct(-)
gcollapse (sum) livestock_inc, by(hhid)
sort hhid
save  `livestock_inc', replace

* ------------------------------------------------------
* FARMING S11: Livestock and related expenses: expenses
* ------------------------------------------------------
use "${input}\S13E3.dta", clear
*v13_72 TOTAL EXPENDITURE OVER PAST 12 MONTHS (RUPEES) --> 8	TOTAL EXPENDITURES	pero no está
tempfile livestock_exp
gen livestock_exp = (v13_72/12)*(-1) if v13e3_id != 8
egen hhid = concat(xhpsu xhnum), punct(-)
gcollapse (sum) livestock_exp, by(hhid)
sort hhid
save  `livestock_exp', replace

* -------------------------
* TOTAL AGRICULTURE income
* -------------------------
use `rent_land_inc', clear
merge 1:1 hhid using `rent_land_exp', nogen
merge 1:1 hhid using `inc_agric', nogen
merge 1:1 hhid using `exp_agric', nogen
merge 1:1 hhid using `livestock_sold', nogen
merge 1:1 hhid using `livestock_inc', nogen
merge 1:1 hhid using `livestock_exp', nogen
merge 1:1 hhid using  `food_own_monet', keepusing(food_own_monet hhid) nogen
merge 1:1 hhid using  `food', keepusing(food_own_noncrop hhid) nogen

egen agri_income_tot = rsum(rent_land_inc rent_land_exp inc_tot_sectionD exp_tot_sectionD food_own_monet food_own_noncrop livestock_sold livestock_inc livestock_exp), missing
tempfile tot_agric
sort hhid
keep hhid agri_income_tot
save  `tot_agric', replace

* ------------------------------------------------------
*S14: Non-agricultural enterprises / activities (hh level)
* ------------------------------------------------------
use "${input}\S14.dta", clear 
keep if v14_ec1!=.
tempfile income_non_agric
egen hhid = concat(xhpsu xhnum), punct(-)
* Total Non-Agricultural Income by Activity
* v14_23: NET REVENUES OVER PAST 12 MONTHS
* v14_09: What share of the profits is kept by your household? --> tiene valores incorrectos: no se hace el ajuste (5.7%)
/*v14_08: Who owns the business?
OWNED BY HOUSEHOLD  ONLY 1
PARTNERSHIP/ SHARED WITH  OTHER OWNERS 2
*/

*gen share = v14_09 if v14_08==2
gen share = 100 if v14_08!=. 
gen inc_nonagric = (v14_23 * (share/100)) / 12

/*v14_03 Which people in the household work in this enterprise/activity?
v14_03a worker 1
v14_03b worker 2
v14_03c worker 3
v14_03d worker 4
v14_03e worker 5
*/
rename v14_ec1 line
rename v14_03a worker1
rename v14_03b worker2
rename v14_03c worker3
rename v14_03d worker4
rename v14_03e worker5
rename inc_nonagric inc_nonagric1
clonevar inc_nonagric2 = inc_nonagric1
keep hhid line inc_nonagric* worker* 
reshape long worker inc_nonagric, i(hhid line) j(com)
drop if inc_nonagric==0
replace com = worker
drop if com == .

*Cuento cuántos hay por hogar para dividir
gen uno = 1
egen aux = sum(uno), by(hhid line)
replace inc_nonagric = inc_nonagric/aux
drop uno aux

*Tengo que sumar la info de estos si es que están en s10
*veo cuantos se declara como self employment en la S10 not in agriculture (referencia 12 months)
merge m:m hhid com using `labor_noagric_main' // hay 155 casos que no tienen info en s10 (3.5%)
keep if inc_nonagric!=.
gen relab = relab_s10 
replace relab = 1 if _merge==1
gen aux = inc_nonagric*(-1)
sort hhid com aux
by hhid com: gen order = sum(1)
drop aux

**** defino en función de mayor ingresos ****
keep hhid com inc_nonagric order relab occup_self hs_self nmonths_self
reshape wide inc_nonagric relab occup_self hs_self nmonths_self, i(hhid com) j(order)	
save `income_non_agric', replace

merge 1:1 hhid com using `wages_info'
drop _merge 

egen irelab1 = rsum(daylab_cash1 daylab_kind1 longbasis_cash1 longbasis_kind1 contract_cash1 contract_kind1), missing
egen irelab2 = rsum(daylab_cash2 daylab_kind2 longbasis_cash2 longbasis_kind2 contract_cash2 contract_kind2), missing

/*egen max_main = rmax(inc_nonagric1 irelab1)
gen main_relab = 2 if max_main==irelab1
replace main_relab = 3 if max_main==inc_nonagric1

egen max1 = rmax(inc_nonagric1 inc_nonagric2 irelab2) if main_relab==2 // segundo más grande si ganó irelab1
egen max2 = rmax(inc_nonagric2 irelab1 irelab2) if main_relab==3  // segundo más grande si ganó inc_nonagric1
egen max_sec = rmax(max1 max2) // segundo más grande de todos

gen sec_relab = 2 if irelab1==max_sec & main_relab!=2 & max_sec!=. // si irelab1 coincide con el segundo y no fue el primero
replace sec_relab = 2 if irelab2==max_sec & main_relab==3 & max_sec!=. // si irelab2 coincide con el segundo y porque irelab1 fue el primero
replace sec_relab = 3 if inc_nonagric1==max_sec & main_relab!=3 & max_sec!=. // si inc_nonagric coincide con el segundo y no fue el primero
replace sec_relab = 3 if inc_nonagric2==max_sec & main_relab==3 & max_sec!=. // si inc_nonagric2 coincide con el segundo porque inc_nonagric1 fue el primero
drop max1 max2
*/

tempfile labor
save `labor', replace

/*defino el de mayor ingreso:
egen aux1 = rsum(daylab1_cash1 daylab_kind1), missing
egen aux2 = rsum(contract_cash1 contract_kind1), missing
egen aux3 = rsum(longbasis_cash1 longbasis_kind1), missing
egen aux4 = inc_nonagric1, missing

egen aux5 = rmax(aux1 aux2 aux3 aux4 aux5)
*/

* --------------------------------------
* S15: Credits and savings ( hh level)
* --------------------------------------
*tener cuidado con el id code of respondent porque en cada parte puede ser distinto (y ese dato está en S130, no en las minibases)
*S13A: savings (long)
*S13B: loans (long)
use "${input}\S15C.dta", clear 
tempfile inc_renting
*v15_31 How much did your household receive in total over the past 12 months from renting this property to others?
*v15_37 How much did your household receive in total over the past 12 months from renting these assets to others?
egen hhid = concat(xhpsu xhnum), punct(-)
egen inc_renting_assets = rsum(v15_31 v15_37), missing
replace inc_renting_assets = inc_renting_assets/12
sort hhid
save `inc_renting', replace

* ---------------------------------------------
*Section 16 (absentees information) (hh level)
* --------------------------------------------
use "${input}\S16.dta", clear 
egen hhid = concat(xhpsu xhnum), punct(-)
*v16_16 How much money did the household members receive from ..[PERSON].. during the past 12 months?
*v16_17 What is the value of all goods received by  the household members from ..[PERSON].. during the past 12 months?
/*v16_08 Where does ..[PERSON].. live now?
district codes: from 101 to 709
country codes: 801 to 819
*/
gen abroad = 1 if v16_08a>=1 & v16_08a<=80
replace abroad = 0 if (v16_08a>=81 & v16_08a<=96)
tempfile inc_remit_absent
replace v16_16 = v16_16/12
replace v16_17 = v16_17/12
egen inc_remit_absent_abroad_m = rsum(v16_16) if abroad==1 , missing
egen inc_remit_absent_abroad_nm = rsum(v16_17) if abroad==1 , missing
egen inc_remit_absent_nat_m = rsum(v16_16) if abroad==0, missing
egen inc_remit_absent_nat_nm = rsum(v16_17) if abroad==0, missing
collapse (sum) inc_remit*, by(hhid)
sort hhid
keep hhid inc_remit*
save `inc_remit_absent', replace

* -----------------------------------------
* Section 15: Other Remittances (hh level)
* -----------------------------------------
* Remittances and Transfer Income Received 
*v17_20a How much in total did you receive from. ..[DONOR].. over the past 12 months? CASH
*v17_20b How much in total did you receive from. ..[DONOR].. over the past 12 months?  IN KIND
/*v17_18a Where does ..[PERSON].. live now?
district codes: from 1 to 80
country codes: 81 to 96
*/
use "${input}\S17B.dta", clear 
egen hhid = concat(xhpsu xhnum), punct(-)
tempfile inc_remit_other
replace v17_20a = v17_20a/12
replace v17_20b = v17_20b/12
gen abroad = 1 if v17_18a>=1 & v17_18a<=80
replace abroad = 0 if (v17_18a>=81 & v17_18a<=96)
egen inc_remit_other_abroad_m = rsum(v17_20a) if abroad==1 , missing
egen inc_remit_other_abroad_nm = rsum(v17_20b) if abroad==1 , missing
egen inc_remit_other_nat_m = rsum(v17_20a) if abroad==0, missing
egen inc_remit_other_nat_nm = rsum(v17_20b) if abroad==0, missing
*17.14 Who in your household is primarily responsible for receiving this assistan
rename v17_14 com
collapse (sum) inc_remit_other*, by(hhid com)
sort hhid com
keep hhid com inc_remit_other*
save `inc_remit_other', replace

* ----------------------------------------------------------------------------------
*Section 18: Transfers, Social Assistance and Other INCOME (hh level/source level)
* ----------------------------------------------------------------------------------
*Cash transfers programs:
use "${input}\S18A.dta", clear 
tempfile inc_transfer
egen hhid = concat(xhpsu xhnum), punct(-)

/*
v18_02 How many household members are receiving the payments
v18_06 How much  [SOURCE] was actually received last time?
v18_07 How many months was this payment for?

--------------------------------------
18.02 no. |
of person |
receiving | mean(v18_06)   mean(imens)
----------+---------------------------
        1 |  2200.200927      517.7053
        2 |  4060.629921      961.4859
        3 |         6000          1500
--------------------------------------
*/

gen inc_transfer = v18_06/v18_07 if v18_07 >0 & v18a_sn!=5
*Maternal Incentive Scheme is only once and has v18_07 == .
replace inc_transfer = v18_06 if v18a_sn==5

/*Cash Transfer Programs					
Old age pension NCCT
Widow pension NCCT
Disability Allowance NCCT
Endangered Ethnicities Pension NCCT
Maternal Incentive Scheme CCT
Martyr’s Family benefits NCCT
People’s movement victims Benefits  NCCT
*/

gen inc_transfer_ncct = inc_transfer if inlist(v18a_sn,1,2,3,4,6,7)
gen inc_transfer_cct = inc_transfer if v18a_sn == 5
gcollapse (sum) inc_transfer*, by(hhid)
save `inc_transfer', replace
*/

* --------------------------------
* S18: Other income: // hh level
* --------------------------------
use "${input}\S18C.dta", clear
tempfile inc_other
*v18_14 How much has the household received from ..[ITEM].. in the past 12 months? (interest, dividends, profit, payments, etc.)
egen hhid = concat(xhpsu xhnum), punct(-)
rename v18_14 inc_other_
replace inc_other = inc_other/12
*gcollapse (sum) inc_other, by(hhid)
keep hhid  v18c_ic  inc_other
reshape wide inc_other, i(hhid) j(  v18c_ic )
sort hhid
save  `inc_other', replace

* ------------------------------------
*Section 17: adequacy of consumption (hh level) - not used
*Section 18: Anthropometrics (individual level) - not used
* -------------------------------------

*************************************************************************
* 			ADDITIONAL GMD VARIABLES 					

*Section 2: household Expenses
use "${input}\S02.DTA", clear
tempfile s02_expenditure
egen hhid = concat(xhpsu xhnum), punct(-)
cap rename water water_orig
* {2.22} How much did you pay for water over the last 12 months? 
gen water_aux = v02_22
* v02_25 : {2.25} How much did your household pay for garbage disposal over the last month?
gen garbage_aux =  v02_25*12
*electricity: {2.29} How much did you spend on electricity over the past 12 months?
gen elect_aux = v02_29
gen firewood_aux = .
/*v02_32: How much did you pay for using those facilities listed in (2.31)  over the last 12 months?
telephone
mobile phone
cable tv
email internet
*no se puede distinguir entonces pongo missing
*/
gen landphone_aux = .
gen cable_aux = .
gen internet_aux = .
keep hhid water_aux garbage_aux elect_aux firewood_aux landphone_aux cable_aux internet_aux
sort hhid 
save `s02_expenditure', replace

*Nonfood expendituree
use "${input}\S06A.DTA", clear
tempfile s06_expenditure
egen hhid = concat(xhpsu xhnum), punct(-)
*v06_02b: Were any of the following items purchased or received in-kind by your household over the past 12 months? RUPEES
rename v06_02b exp_
rename v06a_idc code
keep hhid exp_ code
reshape wide exp_, i(hhid) j(code)
sort hhid 
keep hhid exp_211 exp_212 exp_213 exp_214 exp_215 exp_232 exp_239 
save `s06_expenditure', replace

*Weights (only hh):
use "${input}\sample.dta", clear
tempfile weights
cap drop hhid
egen hhid = concat(xhpsu xhnum), punct(-)
*keep hhid dist_code domain prov base_hh_wt_adj ind_wt
*keep hhid wt_ind wt_hh pindex Date region district urbrur
save `weights', replace

*Disabilities
*S8: disability and mortality (not used) (individual level)
use "${input}\S08.dta", clear
tempfile disability
egen hhid = concat(xhpsu xhnum), punct(-)
gen com = v08a_idc
save  `disability', replace

*Utilities and assets
use "${input}\S06C.DTA", clear
tempfile asset
egen hhid = concat(xhpsu xhnum), punct(-)
rename v06_05 own_
rename v06c_idc code
keep hhid own code
reshape wide own, i(hhid) j(code)
sort hhid
save `asset', replace

*Livestock property
use "${input}\S13E1.dta", clear
tempfile livestock_asset
egen hhid = concat(xhpsu xhnum), punct(-)
rename v13_66yn own_livestock_
rename v13e1_lc code
keep hhid own code
reshape wide own, i(hhid) j(code)
sort hhid
save  `livestock_asset', replace

*Livestock property
use "${input}\S13F.dta", clear
tempfile farming_asset
egen hhid = concat(xhpsu xhnum), punct(-)
rename v13_75yn own_farming_
rename v13f_ec code
keep hhid own code
reshape wide own, i(hhid) j(code)
sort hhid
save  `farming_asset', replace

*Labor info for agricultural self-employment from secion 10
use "$input/S10B.dta", clear
egen hhid = concat(xhpsu xhnum), punct(-)
gen com = v10_02
gen id_job = v10_02_job
keep if v10_07 == 3

gen occup_agric = v10_03
gen hs_agric = v10_06h
egen nmonths_agric = rsum(v10_04*)
gen relab_agric = 3

tempfile labor_agric_main
keep relab_agric hhid com id_job occup_agric hs_agric nmonths_agric
sort hhid com id_job
reshape wide relab_agric occup_agric hs_agric nmonths_agric, i(hhid com) j(id_job)	
save `labor_agric_main', replace

*******************************************************************
* -----------------------------------------------------------------
*** MERGE DATASETS
* -----------------------------------------------------------------
*******************************************************************

	use `roster', clear
	
	* Individual-level datasets
	foreach p in migration education disability labor unemployment income_non_agric labor_agric_main inc_remit_other  {
	merge 1:1 hhid com using ``p''
	keep if _merge!=2
	drop _merge
	}
	
	* Household-level datasets
	foreach x in language weights housing inc_transfer tot_agric inc_renting inc_remit_absent inc_other food asset livestock_asset farming_asset nonfood_own agriland area_ownland area_notownland s02_expenditure s06_expenditure{
	*foreach x in language weights housing tot_agric inc_renting inc_remit_absent inc_other food asset livestock_asset farming_asset nonfood_own agriland area_ownland area_notownland{
	merge m:1 hhid using ``x'', nogen force
	}

	*correction using information from FINAL_PREF since one hh remains without household head:
	gen v01_04_aux = v01_04
	replace v01_04_aux = 1 if hhid == "1092-5" & v01_idc==2

	*Los que se definen solo para el jefe de hogar porque es una a nivel de todo el hogar
		foreach var of varlist agri_income_tot food_inkind inc_renting_assets inc_renting_housing nonfood_own inc_remit_absent* inc_other* inc_transfer* {
		replace `var' = . 	if  v01_04_aux!=1
		}

*Filter only cross-section households
preserve
use "$input/FINAL_PREF.dta", clear
egen hhid = concat(xhpsu xhnum), punct(-)
keep hhid Date rpcexp totcons_pc_7 sh_food_7 sh_nfood_7 pline_7 rexpquint
tempfile final_pref
save `final_pref', replace
restore

merge m:1 hhid using `final_pref'
drop if _merge!=3
drop _merge

	sort hhid com
	egen pid = concat(hhid com), punct(-)
	drop if xhpsu == . | xhnum==.
	gen weight = wt_hh

* -----------------------------------------------------------
* Final adjustments 

foreach var of varlist inc_nonagric* irelab* agri_income_tot {
replace `var' = . if `var'==0
}

egen aux1 = rmax(inc_nonagric1 irelab1 agri_income_tot)
gen cat_main_income = 1 if aux1==irelab1 & irelab1!=.
replace cat_main_income = 2 if aux1== inc_nonagric1 & inc_nonagric1!=.
replace cat_main_income = 3 if aux1 == agri_income_tot & agri_income_tot!=.
drop aux1

egen aux1 = rmax(inc_nonagric1 irelab2 agri_income_tot) if cat_main_income == 1 // ganó el relab 2 en el anterior
egen aux2 = rmax(inc_nonagric2 irelab1 agri_income_tot) if cat_main_income == 2 // ganó el inc nonagric en el anterior
egen aux3 = rmax(inc_nonagric1 irelab1 agri_income_tot) if cat_main_income == 3 // ganó el inc agric en el anterior
egen aux4 = rmax(aux1 aux2 aux3)

gen cat_sec_income = 1 if aux4==irelab2 & irelab2!=. &  cat_main_income == 1 // si irelab2 coincide con el segundo y tmb fue el primero
replace cat_sec_income = 2 if aux4==irelab1 & irelab1!=. &  cat_main_income != 1 // si irelab1 coincide con el segundo y no fue el primero
replace cat_sec_income = 3 if aux4==inc_nonagric2 & inc_nonagric2!=. &  cat_main_income == 2 // si incnonagric coincide con el segundo y tmb fue el primero
replace cat_sec_income = 4 if aux4==inc_nonagric1 & inc_nonagric1!=. &  cat_main_income != 2 // si incnonagric coincide con el segundo y no fue el primero
replace cat_sec_income = 5 if aux4==agri_income_tot & agri_income_tot!=. &  cat_main_income != 3 // income agric hay uno solo asi que si fue el primero ya no va

gen main_relab = 2 if cat_main_income == 1
replace main_relab = 3 if cat_main_income == 2 | cat_main_income == 3

gen sec_relab = 2 if cat_sec_income == 1 | cat_sec_income == 2
replace sec_relab = 3 if inlist(cat_sec_income, 3, 4, 5)
drop aux*

gen wage_base_p = wage_base1 if cat_main_income == 1

gen wage_base_np = wage_base1 if cat_sec_income == 2
replace wage_base_np = wage_base2 if cat_sec_income == 1

cap drop hogarsec
gen     hogarsec = 0		if  v01_04_aux!=.
replace hogarsec = 1		if  inlist(v01_04_aux, 12, 13, 14)

* -----------------------------------------
*<_Save data file_>
compress
save "${output}/`yearfolder'_v`vm'_M.dta", replace
* -----------------------------------------

