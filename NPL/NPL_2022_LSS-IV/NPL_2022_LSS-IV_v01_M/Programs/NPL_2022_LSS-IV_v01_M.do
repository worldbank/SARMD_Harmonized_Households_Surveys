/*------------------------------------------------------------------------------
					GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   		NPL_2022-2023_LSS-IV_v01_M.do				   </_Program name_>
<_Application_>    		STATA 17.0							     <_Application_>
<_Author(s)_>      		acastillocastill@worldbank.org	          </_Author(s)_>
<_Author(s)_>      		tornarolli@gmail.com	          		  </_Author(s)_>
<_Date created_>   		08-15-2024	                           </_Date created_>
<_Date modified>   		08-15-2024	                          </_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        		NPL											</_Country_>
<_Survey Title_>   		LSS								   </_Survey Title_>
<_Survey Year_>    		2022									</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:					19-03-2024
File:					NPL_2022-2023_LSS-IV_v01_M.do
- First version
</_Version Control_>
------------------------------------------------------------------------------*/

*<_Program setup_>
clear all
set more off

global cpiver       "10"
local code         	"NPL"
local year         	"2022"
local survey       	"LSS-IV"
local vm           	"01"
local yearfolder   	"`code'_`year'_`survey'"
global input       	"${rootdatalib}\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M\Data\Stata"
global output      	"${rootdatalib}\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M\Data\Stata"

*</_Program setup_>

*<_Datalibweb request_>

* ------------------------------------------------------------
*Section 1: household roster (individual level)
* ------------------------------------------------------------
use "${input}\S010.dta"
/*ta flap_a
A. Absentees Flap Column |
                       1 |      Freq.     Percent        Cum.
-------------------------+-----------------------------------
        Household Member |     38,101       81.29       81.29
Absentees within country |      4,499        9.60       90.89
        Absentees abroad |      4,270        9.11      100.00
-------------------------+-----------------------------------
                   Total |     46,870      100.00
				   */
keep if flap_a==1 // household member
tempfile roster
tostring psu_number, format(%04.0f) replace
tostring hh_number, format(%02.0f) replace
*egen hhid = concat(psu_number hh_number), punct(-)
egen hhid = concat(psu_number hh_number)
destring psu_number hh_number, replace
gen com = s01_idc
sort hhid com
save  `roster', replace

* ------------------------------------------------------------
*Section 2: housing : S020.dta includes all subsections (hh level)
* ------------------------------------------------------------
* Secion 2.1 type of dwelling
* Section 2.2 housing expenses and utilities
* Secion 2.3: utilities and ammenities
/*Implicit rent: 
(2,11)	Does this dwelling belong to your family?	
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
(2.18)	What is the rent per month?							
	INCLUDE CASH PLUS VALUE OF IN-KIND PAYMENTS							
*/
use "${input}\S020.dta", clear
tempfile housing
tostring psu_number, format(%04.0f) replace
tostring hh_number, format(%02.0f) replace
*egen hhid = concat(psu_number hh_number), punct(-)
egen hhid = concat(psu_number hh_number)
destring psu_number hh_number, replace
sort hhid
*gen renter = 0 if q02_11==1 | q02_16==2 | q02_16==3 | q02_16==4
*replace renter = 1 if q02_16 == 1
gen implicit_rent = q02_13 if q02_11==1
replace implicit_rent = q02_17 if q02_16==2 | q02_16==3 | q02_16==4
*income from renting: (2.15)	How much rent do you receive per month?	RUPEES		
gen inc_renting_housing = q02_15
save  `housing', replace


* ------------------------------------------------------------
*Section 3: access to facilities (not used) S030.dta -- hh/code level
* ------------------------------------------------------------

* ------------------------------------------------------------
*Section 4: Migration -- individual level
* ------------------------------------------------------------
use "${input}\S040.dta", clear
tempfile migration
tostring psu_number, format(%04.0f) replace
tostring hh_number, format(%02.0f) replace
*egen hhid = concat(psu_number hh_number), punct(-)
egen hhid = concat(psu_number hh_number)
destring psu_number hh_number, replace
gen com = s04_idc
sort hhid com 
save  `migration', replace

* --------------------------------------------------------------------------------------------------------
*Section 5: Food Expenses and Home Production (hh/code level): only own production and received in kind
* --------------------------------------------------------------------------------------------------------
/*
q05_03 How much ..[FOOD].. did your household consume during the past 7 days? :
q05_03_b Total Value of home production in RUPEES
q05_05_b IN-KIND Recieved: RUPEES
*/
use "${input}\S050.dta", clear
tempfile food
tostring psu_number, format(%04.0f) replace
tostring hh_number, format(%02.0f) replace
*egen hhid = concat(psu_number hh_number), punct(-)
egen hhid = concat(psu_number hh_number)
destring psu_number hh_number, replace
rename q05_03_b food_own_prod
rename q05_05_b food_inkind
egen food_own_noncrop = rsum(food_own_prod) if inlist(food_code,401,402,405,406,407,408,409,501,301,302,303,304,305,306,307,308,803), m
replace food_own_noncrop = . if food_own_noncrop==0
gcollapse (sum) food_own_noncrop food_inkind, by(hhid)
replace food_own_noncrop = food_own_noncrop/7*365/12
replace food_inkind = food_inkind/7*365/12
sort hhid 
*food consumption from in KIND --> other non labor income 
keep hhid food_inkind food_own_noncrop
save  `food', replace

* -----------------------------------------------------------------------------
*Section 6: Non-Food Expenditures & Inventory of Durable Goods (hh/code level)
* -----------------------------------------------------------------------------
**********************************
* Section B con travel expenses *
**********************************
*q06_03b_a What is the money value of the amount  received in-kind by your household 12 months
use "${input}\S06B.dta", clear
tempfile travel_inkind
tostring psu_number, format(%04.0f) replace
tostring hh_number, format(%02.0f) replace
*egen hhid = concat(psu_number hh_number), punct(-)
egen hhid = concat(psu_number hh_number)
destring psu_number hh_number, replace
count if q06_03b_a>0 & q06_03b_a!=. // 138
keep if s06b_code == 1280 // TOTAL
gen travel_inkind = q06_03b_a
replace travel_inkind = . if travel_inkind==0
keep hhid travel_inkind
replace travel_inkind = travel_inkind/12
save `travel_inkind', replace

***************
* Section 6D: 
***************
*Were any of the following items produced and consumed by your household over the past 12 months?
use "${input}\S06D.dta", clear
* q06_9 What is the monetary value of the items produced and consumed yourself? a) 12 months (28,588); b) during the past 30 days (12,785) --> recall period 12 months
tempfile nonfood_own
tostring psu_number, format(%04.0f) replace
tostring hh_number, format(%02.0f) replace
*egen hhid = concat(psu_number hh_number), punct(-)
egen hhid = concat(psu_number hh_number)
destring psu_number hh_number, replace
keep if s06d_code==600 // TOTAL
rename q06_9a nonfood_own
sort hhid 
keep hhid nonfood_own
save  `nonfood_own', replace


* -----------------------------------------------------------------------------
* Education: s7: includes section 7, section 7.2 and 7.3 (individual level)
* -----------------------------------------------------------------------------
use "${input}\S070.dta", clear
tempfile education
tostring psu_number, format(%04.0f) replace
tostring hh_number, format(%02.0f) replace
*egen hhid = concat(psu_number hh_number), punct(-)
egen hhid = concat(psu_number hh_number)
destring psu_number hh_number, replace
gen com = s07_idc
sort hhid com
*q07_18 Did you receive a scholarship to help pay for your educational expenses in the past 12 months?
*q07_19 How much did you receive over the past 12 months?
gen scholarship = q07_19/12 if q07_18==1
save  `education', replace

* -----------------------------------------------------------------------------
* S9: Labor: includes all question from q09_01 to q09_22 (individual 10 years and older)
* -----------------------------------------------------------------------------
use "${input}\S090.dta", clear
tempfile labor
tostring psu_number, format(%04.0f) replace
tostring hh_number, format(%02.0f) replace
*egen hhid = concat(psu_number hh_number), punct(-)
egen hhid = concat(psu_number hh_number)
destring psu_number hh_number, replace
gen com = s09_idc
sort hhid com
/* Employment Categories: 
1 = empleador/patrón
2 = empleado/asalariado
3 = cuentapropista/independiente
4 = trabajador no remunerado
5 = desocupado
q09_10 In this job (main job), what is the status of your involvement?
Employee      						1
Paid apprentice / intern              						2
Employer (with regular  employees)						3
Own-account worker (without regular employees) 						4
Contributing family worker (helping without pay)						5
Other						6
*/
gen 	relab_7days = 1 				if  q09_10==3
replace relab_7days = 2 				if  q09_10==1 | q09_10==2
replace relab_7days = 3 				if  q09_10==4 
replace relab_7days = 4 				if  q09_10==5

preserve
tempfile relab
keep hhid com relab_7days
drop if relab_7days==.
save  `relab', replace
restore

gen labor_info_7days = 1 if relab_7days!=.
gen agric_sector_7days = 1 if q09_14_a>=111 & q09_14_a<=322
replace agric_sector_7days = 0 if agric_sector!=1 & q09_14_a!=.
preserve
tempfile labor_noagric
keep if (relab_7days==1 | relab_7days==3) & agric_sector_7days==0
keep relab agric_sector hhid com
sort hhid com 
gen line = 1 
save  `labor_noagric', replace
restore
save `labor', replace

* ----------------------------------------------
* S10: wage jobs (individual level 10 and older)
* ----------------------------------------------
use "${input}\S100.dta", clear
tostring psu_number, format(%04.0f) replace
tostring hh_number, format(%02.0f) replace
*egen hhid = concat(psu_number hh_number), punct(-)
egen hhid = concat(psu_number hh_number)
destring psu_number hh_number, replace
gen com = q10_01
keep if q10_03==1
tempfile wage_info
gen wage_info = 1
save  `wage_info', replace

* Monthly Income of those working as day labourers
/* q10_05 On what basis are you working/worked in this job?			
DAILY BASIS			1
LONG TERM BASIS			2		►	(10,09)
CONTRACT/ PIECE-RATE			3		►	(10,11)
*/
*q10_06 How many days did you work for daily wages in the last 12 months?
*q10_07 How much did you get in cash per day for this job?
*q10_08 What was the value of what you received per day in-kind for this job?
gen daylab_cash = q10_07 * q10_06 / 12	if q10_05 == 1
gen daylab_kind = q10_08 * q10_06/ 12 	if q10_05 == 1

* Monthly Income of those working PAID ON A LONGER BASIS
/* q10_09 How much did you get paid for this job in the last 12 months?
A	Salary	
B	Transportation
C	Bonuses, tips, festival allowances
D	Uniform / clothing allowance
E	Other allowance		*/
*q10_10 What was the value of what you received in kind in the past 12 months?
egen aux =rsum(q10_09_a q10_09_b q10_09_c q10_09_d q10_09_e), m		
gen wage_base = q10_09_a
replace wage_base = wage_base/12	if  q10_05==2
gen longbasis_cash = aux/12			if  q10_05==2
gen longbasis_kind = q10_10/12		if  q10_05==2
drop aux*

*Contract/piece rate
* q10_11 During the past 12 months, having worked on a contract, how much did you receive in-kind (value) and cash? 
gen contract_cash = q10_11_a / 12	if q10_05 == 3
gen contract_kind = q10_11_b / 12 	if q10_05 == 3

*Main or other job:  primero elijo el más relevante dentro de los wage Info
* Si tienen line = 1, elijo ese; si no, el de mayor ingreso
gen main_S10 = 1 if s10_ln==1
egen aux = count(main_S10), by(hhid com)
replace main_S10 = 0 if main_S10==. & aux==1
drop aux
*Hay  9,461 personas pero solo 4519 line=1. Defino esos y los que no, defino el main en función de mayor remuneración anual:
egen longbasis_tot = rsum(longbasis_cash longbasis_kind), m
egen contract_tot = rsum(contract_cash contract_kind), m
egen daylab_tot = rsum(daylab_cash daylab_kind), m
gen id_job = s10_ln
egen aux = rmax(longbasis_tot contract_tot daylab_tot)
egen aux2 = max(aux), by(hhid com)
replace main_S10 = 1 if aux==aux2 & main_S10==.
replace main_S10 = 0 if aux!=aux2 & main_S10==.
*en algunos casos quedan duplicados (porque hay ingresos iguales), elijo el de menor numero de line
egen aux4 = sum(main_S10), by(hhid com)
egen aux5 = min(s10_ln) if aux4!=1, by(hhid com)
replace main_S10 = 0 if aux4!=1 & s10_ln!=aux5 & aux5!=.

*Segundo: elijo como main la main_S10=1 solo si en labor info tiene relab = 2
merge m:1 hhid com using `relab', nogen
replace main_S10 = 0 if relab !=2
keep hhid com daylab* longbasis* contract* main_S10 wage_base
local types "daylab longbasis contract"
foreach type of local types {
egen `type'_cash_p = total(`type'_cash) if main_S10==1, by(hhid com)
egen `type'_cash_np = total(`type'_cash) if main_S10==0, by(hhid com)
egen `type'_kind_p = total(`type'_kind) if main_S10==1, by(hhid com)
egen `type'_kind_np = total(`type'_kind) if main_S10==0, by(hhid com)
}
gen wage_base_np = wage_base if main_S10==0
gen wage_base_p = wage_base if main_S10==1
tempfile wage
gcollapse (mean) *_cash_p *_cash_np *_kind_p *_kind_np wage_base*, by(hhid com)
save  `wage', replace

* ----------------------------------------------
* S11: Farming and livestock (hh level)
* ----------------------------------------------
*la dinámica es esta: los que son long (requieren pasar a wide) porque tienen info de varios plots o parcels están separados en sus minibases
* Después está la base S110.dta que tiene la info que ya estaba en wide (las preguntas que tienen solamente una fila por hogar)

*********************************
use "${input}\S110.dta", clear
tempfile agriland
*q11_01 Does your household own any agricultural land?
gen ownagriland = 1 if  q11_01==1
replace ownagriland = 0 if  q11_01==2
*q11_16 Over the past AGRICULTURE YEAR did your household cultivate land owned by someone else or that was mortgaged in?
gen notownland = 1 if  q11_16==1
replace notownland = 0 if  q11_16==2
tostring psu_number, format(%04.0f) replace
tostring hh_number, format(%02.0f) replace
*egen hhid = concat(psu_number hh_number), punct(-)
egen hhid = concat(psu_number hh_number)
destring psu_number hh_number, replace
sort hhid
keep hhid ownagriland notownland
save `agriland', replace

*********************************
* Rent received from parcel (hh/parcel level)
*********************************
use "${input}\S11A1.dta", clear
tempfile rent_land_inc
*q11_14 For the [PARCEL]s which you did not crop yourself during the last agricultural year, what net rent did you receive from the tenant?
*q11_14_a in kind
egen aux  = rsum(q11_14 q11_14_a), missing
gen rent_land_inc= aux/12
tostring psu_number, format(%04.0f) replace
tostring hh_number, format(%02.0f) replace
*egen hhid = concat(psu_number hh_number), punct(-)
egen hhid = concat(psu_number hh_number)
destring psu_number hh_number, replace
gcollapse (sum) rent_land_inc, by(hhid)
keep hhid rent_land_inc 
save  `rent_land_inc', replace

*********************************
* Rent payed for parcel
********************************
use "${input}\S11A2.dta", clear
tempfile rent_land_exp
*q11_19 How much “rent” did you pay for this parcel to the landlord?
gen rent_land_exp = q11_19/12
replace rent_land_exp = rent_land_exp*(-1)
tostring psu_number, format(%04.0f) replace
tostring hh_number, format(%02.0f) replace
*egen hhid = concat(psu_number hh_number), punct(-)
egen hhid = concat(psu_number hh_number)
destring psu_number hh_number, replace
gcollapse (sum) rent_land_exp, by(hhid)
sort hhid
save  `rent_land_exp', replace

****************
* Own land uses
****************
use "${input}\S11A1.dta", clear
tempfile area_ownland
tostring psu_number, format(%04.0f) replace
tostring hh_number, format(%02.0f) replace
*egen hhid = concat(psu_number hh_number), punct(-)
egen hhid = concat(psu_number hh_number)
destring psu_number hh_number, replace
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
gen aux1r = q11_03_a*508.72 if q11_03==1
gen aux2r = q11_03_b*31.80 if q11_03==1
gen aux3r = q11_03_c*7.95 if q11_03==1
*Bigha:
gen aux1b = q11_03_a*6772.63 if q11_03==2
gen aux2b = q11_03_b*338.63 if q11_03==2
gen aux3b = q11_03_c*6.935 if q11_03==2
egen auxr = rsum(aux1r aux2r aux3r), missing
egen auxb = rsum(aux1b aux2b aux3b), missing
gen area_ownagriland = auxr if q11_03==1
replace area_ownagriland = auxb if q11_03==2
drop aux*
/*q11_13 Over the past agriculture year what did you do in the in the plot ?
1 CROPPED YOURSELF	
2 SHARECROPPED OUT	
3 FIXED RENT OUT	
4 MORTGAGED OUT	
5 LEFT FALLOW	
6 OTHER	*/
gen aux = 1 if q11_13==2 | q11_13==3
replace aux = 0 if inlist(q11_13,1,4,5,6)
egen rentout_agriland = max(aux), by(hhid)
gen arearentout_agriland = area_ownagriland if q11_13==2 | q11_13==3
gcollapse (sum) area_ownagriland arearentout_agriland (mean) rentout_agriland, by(hhid)
replace area_ownagriland = area_ownagriland/10000
replace arearentout_agriland = arearentout_agriland/10000
keep hhid area_ownagriland arearentout_agriland rentout_agriland
save  `area_ownland', replace

********************
*Not own land uses
********************
use "${input}\S11A2.dta", clear
tempfile area_notownland
tostring psu_number, format(%04.0f) replace
tostring hh_number, format(%02.0f) replace
*egen hhid = concat(psu_number hh_number), punct(-)
egen hhid = concat(psu_number hh_number)
destring psu_number hh_number, replace
/*q11_18 What is the contractual arrangement on this .[PARCEL].?
SHARECROPPED
RENTED-IN
MORTGAGED-IN
OTHER*/
gen aux = 1 if q11_18==1 | q11_18==2
replace aux = 0 if inlist(q11_18,3,4)
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
gen aux1r = q11_20_a*508.72 if q11_20==1
gen aux2r = q11_20_b*31.80 if q11_20==1
gen aux3r = q11_20_c*7.95 if q11_20==1
*Bigha:
gen aux1b = q11_20_a*6772.63 if q11_20==2
gen aux2b = q11_20_b*338.63 if q11_20==2
gen aux3b = q11_20_c*6.935 if q11_20==2
egen auxr = rsum(aux1r aux2r aux3r), missing
egen auxb = rsum(aux1b aux2b aux3b), missing
gen area_notownland = auxr if q11_20==1
replace area_notownland = auxb if q11_20==2
drop aux*
gen arearentin_agriland = area_notownland if q11_18==1 | q11_18==2
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
use "$input/S11B"

*-------------------------------------------------------------------------------
*2.5. Total sales
*-------------------------------------------------------------------------------
gen value_sale = q11_36_b * q11_36_c

*-------------------------------------------------------------------------------
*2.3. Drop if crop_code is missing
*-------------------------------------------------------------------------------
ren q11_32a crop_code
drop if inlist(crop_code,0,.)

*-------------------------------------------------------------------------------
*2.4. Convert the units of reported total quantity sold(kilogram, maund, muri, quintal, gota(pieces)) to three standard units: kg, manna and piece
*-------------------------------------------------------------------------------
clonevar price = q11_36_c
clonevar unit = q11_36_a

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
merge m:1 psu_number hh_number using "$input/99_NLSSIV_hhdata.dta", keep(1 3) keepusing(season rural_2022 domain rural_2022 base_hh_wt_adj ind_wt) nogen


*-------------------------------------------------------------------------------	
*2.6. Save till this point in temporary file
*-------------------------------------------------------------------------------
preserve
	//q11_36_c_corr and q11_36_a_corr are the price and unit that is converted to one of the three standard units
	ren price q11_36_c_corr
	ren unit q11_36_a_corr
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
foreach v in domain rural_2022 "" {
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
count if q11_35_b==0 & q11_36_b!=0 & !mi(q11_36_b) //0

*-------------------------------------------------------------------------------
*2.9.2. Drop if total harvested quantity is 0
*-------------------------------------------------------------------------------
drop if q11_35_b==0

*-------------------------------------------------------------------------------
*2.9.3. Harvested quantity remaining after giving portion to landlord
*-------------------------------------------------------------------------------
gen quant = q11_35_b - q11_35_c
replace quant = q11_35_b if mi(q11_35_c)

clonevar unit = q11_35_a

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
replace value = q11_36_c_corr * quant if q11_36_a_corr==unit

* harvested unit = kg and sold unit = manna => Convert the harvested quantity to 
replace value = q11_36_c_corr * manna_per_kg  * quant if q11_36_a_corr==2 & unit==1
replace value = q11_36_c_corr * num_per_kg 	* quant if q11_36_a_corr==3 & unit==1

gen count_missing = missing(value)

*-------------------------------------------------------------------------------
*2.9.7.2. Get the imputed price in different imputation levels
*-------------------------------------------------------------------------------
* Domain Level
merge m:1 domain crop_code using `m_domain'
drop _m

* Urban/Rural Level
merge m:1 rural_2022 crop_code using `m_rural_2022'
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
	cap replace value = quant*price_rural_2022`i' if mi(value) & unit==`i'
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
collapse (sum) cropinc = value cropinc_sale = value_sale, by(psu_number hh_number)
gen food_own_monet = cropinc - cropinc_sale
tostring psu_number, format(%04.0f) replace
tostring hh_number, format(%02.0f) replace
*egen hhid = concat(psu_number hh_number), punct(-)
egen hhid = concat(psu_number hh_number)
destring psu_number hh_number, replace
sort hhid
gcollapse (sum) food_own_monet, by(hhid)
replace food_own_monet = food_own_monet/12
save `food_own_monet', replace

* -----------------------------------
* FARMING: Total Revenues:
* -----------------------------------
use "${input}\S11D1.dta", clear
tempfile inc_agric
tostring psu_number, format(%04.0f) replace
tostring hh_number, format(%02.0f) replace
*egen hhid = concat(psu_number hh_number), punct(-)
egen hhid = concat(psu_number hh_number)
destring psu_number hh_number, replace
/*q11_62 is "TOTAL INCOME OVER PAST AGRICULTURE YEAR"
1	Total crop sales							
	(Copy from Part B, Row 98)							
2	Sale of crop by-products (hay, straw, husk, etc.)							
7	Other income							
*/						
*s11d1_code = 8 is TOTAL INCOME
replace q11_62 = q11_62/12
gen inc_tot_sectionD = q11_62 if s11d1_code==8
gen inc_agric = q11_62 if inlist(s11d1_code,1,2,7)
*gen inc_crop = q11_62 if s11d1_code==1
gen rent_asset_inc = q11_62 if inlist(s11d1_code,3,4,5,6)
gcollapse (sum) inc_agric rent_asset_inc inc_tot_sectionD, by(hhid)
*compare inc_tot inc_alt /*muy similares (211 con valores más altos en el inc_tot con promedio de 147 de diferencia y el mean gral es 1361*/ 
sort hhid
save  `inc_agric', replace

* -----------------------------------------------
* FARMING: Total Expenditures:(hh level - long)
* -----------------------------------------------
*q11_63 TOTAL EXPENSES OVER PAST AGRICULTURE YEAR
use "${input}\S11D2.dta", clear 
tempfile exp_agric
tostring psu_number, format(%04.0f) replace
tostring hh_number, format(%02.0f) replace
*egen hhid = concat(psu_number hh_number), punct(-)
egen hhid = concat(psu_number hh_number)
destring psu_number hh_number, replace
replace q11_63 = (q11_63/12)*(-1)
gen exp_agric = q11_63 if inlist(s11d2_code,1,2,3,4,5,6,7,8,9,10,15)
gen rent_asset_exp = q11_63 if inlist(s11d2_code,11,12,13,14)
gen exp_tot_sectionD = q11_63 if s11d2_code==16 
gcollapse (sum) exp_agric rent_asset_exp exp_tot_sectionD, by(hhid)
sort hhid
save  `exp_agric', replace

* -----------------------------------------------
* FARMING S11: Livestock sold
* -----------------------------------------------
use "${input}\S11E1.dta", clear
tempfile livestock_sold
*q11_69_b How many did you sell over the past 12 months? How much did you sell them for? Ruppees
*LIVESTOCK CODE (s11e1_code) --> 11 total
gen livestock_sold = q11_69_b/12 if s11e1_code==11
tostring psu_number, format(%04.0f) replace
tostring hh_number, format(%02.0f) replace
*egen hhid = concat(psu_number hh_number), punct(-)
egen hhid = concat(psu_number hh_number)
destring psu_number hh_number, replace
gcollapse (sum) livestock_sold, by(hhid)
sort hhid
save  `livestock_sold', replace

* ------------------------------------------------------
* FARMING S11: Livestock and related expenses: income
* ------------------------------------------------------
use "${input}\S11E2.dta", clear
*q11_71 TOTAL INCOME OVER PAST 12 MONTHS --> 09	TOTAL INCOME	
tempfile livestock_inc
gen livestock_inc = q11_71/12 if s11e2_code == 9
tostring psu_number, format(%04.0f) replace
tostring hh_number, format(%02.0f) replace
*egen hhid = concat(psu_number hh_number), punct(-)
egen hhid = concat(psu_number hh_number)
destring psu_number hh_number, replace
gcollapse (sum) livestock_inc, by(hhid)
sort hhid
save  `livestock_inc', replace

* ------------------------------------------------------
* FARMING S11: Livestock and related expenses: expenses
* ------------------------------------------------------
use "${input}\S11E3.dta", clear
*q11_72 TOTAL EXPENDITURE OVER PAST 12 MONTHS (RUPEES) --> 7	TOTAL EXPENDITURES	
tempfile livestock_exp
gen livestock_exp = (q11_72/12)*(-1) if s11e3_code == 7
tostring psu_number, format(%04.0f) replace
tostring hh_number, format(%02.0f) replace
*egen hhid = concat(psu_number hh_number), punct(-)
egen hhid = concat(psu_number hh_number)
destring psu_number hh_number, replace
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

*Assign total agriculture income among land owners
use "${input}\S11A1.dta", clear 
tostring psu_number, format(%04.0f) replace
tostring hh_number, format(%02.0f) replace
*egen hhid = concat(psu_number hh_number), punct(-)
egen hhid = concat(psu_number hh_number)
destring psu_number hh_number, replace

foreach var of varlist q11_06 q11_07_1 q11_07_2 {
replace `var' = . if `var'==0
}

*Ropani:
gen aux1r = q11_03_a*508.72 if q11_03==1
gen aux2r = q11_03_b*31.80 if q11_03==1
gen aux3r = q11_03_c*7.95 if q11_03==1
*Bigha:
gen aux1b = q11_03_a*6772.63 if q11_03==2
gen aux2b = q11_03_b*338.63 if q11_03==2
gen aux3b = q11_03_c*6.935 if q11_03==2
egen auxr = rsum(aux1r aux2r aux3r), missing
egen auxb = rsum(aux1b aux2b aux3b), missing
gen area = auxr if q11_03==1
replace area = auxb if q11_03==2
drop aux*

keep hhid s11a1_plot_nb q11_06 q11_07_1 q11_07_2 area

egen tot1 = sum (area) if q11_06!=., by(hhid)
egen tot2 = sum (area) if q11_07_1!=., by(hhid)
egen n1 = sum (area) if q11_06!=., by(hhid q11_06)
egen n2a = sum (area) if q11_07_1!=., by(hhid q11_07_1)
egen n2b = sum (area) if q11_07_2!=., by(hhid q11_07_2)

gen pond_n1 = n1/tot1
gen pond_n2a = n2a/tot2
replace pond_n2a = pond_n2a/2 if n2b!=0 & n2b!=.
gen pond_n2b = n2b/tot2
replace pond_n2b = pond_n2b/2 if n2b!=0 & n2b!=.

rename q11_06 com1
rename q11_07_1 com2
rename q11_07_2 com3

preserve
tempfile pond1
gcollapse (mean) pond_n1, by(hhid com1)
rename com1 com
keep if com!=.
sort hhid com
save `pond1', replace
restore

preserve
tempfile pond2
gcollapse (mean) pond_n2a, by(hhid com2)
rename com2 com
keep if com!=.
sort hhid com
save `pond2', replace
restore

preserve
tempfile pond3
gcollapse (mean) pond_n2b, by(hhid com3)
rename com3 com
keep if com!=.
sort hhid com
save `pond3', replace
restore

use `pond1', clear
merge 1:1 hhid com using `pond2', nogen
merge 1:1 hhid com using `pond3', nogen

egen pond_agric = rsum(pond*), missing
tempfile pond_agric
keep hhid com pond_agric
save `pond_agric', replace

* ------------------------------------------------------
*S12: Non-agricultural enterprises / activities (hh level)
* ------------------------------------------------------
* S120 sirve solo para la primera pregunta que está en formato wide
* Después usar S12A que tiene en formato long todas las preguntas (porque cada línea es un código de empresa)
use "${input}\S120.dta", clear 
tempfile info_s12
keep if q12_01==1
tostring psu_number, format(%04.0f) replace
tostring hh_number, format(%02.0f) replace
*egen hhid = concat(psu_number hh_number), punct(-)
egen hhid = concat(psu_number hh_number)
destring psu_number hh_number, replace
sort hhid
save `info_s12', replace

*Info extra que se puede mergear con employment si hace falta:
*q12_04 code of respondent
*Which member in the household manage this enterprise/activity? id code
*Who in the household owns this enterprise? id code
*Which members in the household work in this enterprise? id code
use "${input}\S12A.dta", clear 
keep if s12_ln!=.
tempfile income_non_agric
tostring psu_number, format(%04.0f) replace
tostring hh_number, format(%02.0f) replace
*egen hhid = concat(psu_number hh_number), punct(-)
egen hhid = concat(psu_number hh_number)
destring psu_number hh_number, replace
* Total Non-Agricultural Income by Activity
* q12_26: NET REVENUES OVER PAST 12 MONTHS
* q12_07: What share of the profits is kept by your household? (after q12_06
*q12_06 If anyone outside this household is a joint owner, what is their number as per gender?
gen share = q12_07 if q12_26!=.
replace share = 100 if q12_06_a==0 & q12_06_b==0
gen inc_nonagric = (q12_26 * (share/100)) / 12

/*q12_05 Who in the household owns this enterprise?
q12_05_a owner 1
q12_05_b owner 2
*/
rename s12_ln line
rename q12_05_a owner1
rename q12_05_b owner2
rename inc_nonagric inc_nonagric1
clonevar inc_nonagric2 = inc_nonagric1
keep hhid line inc_nonagric* owner*

reshape long owner inc_nonagric, i(hhid line) j(com)
replace inc_nonagric = inc_nonagric
drop if inc_nonagric==0
replace com = owner
drop if com == 0
sort hhid com line
merge 1:1 hhid com line using `labor_noagric'

*Cuento cuántos hay por hogar para dividir
gen uno = 1
egen aux = sum(uno), by(hhid)
replace inc_nonagric = inc_nonagric/aux
drop uno aux
save `income_non_agric'

*Tengo que definir cuáles de estos ingresos son main o no:
keep if inc_nonagric!=.
*si tiene relab=3 o relab = 1 es que tiene labor info y entonces asumo este como principal ingreso y le defino esa relación laboral
gen main = 1 if (relab==1 | relab == 3)
replace main = 0 if main!=1 & relab!=.
*defino main para los de mayores ingresos para los que no quedaron con main = 1
egen aux = max(inc_nonagric), by(hhid com)
replace main = 1 if aux==inc_nonagric & main==.
replace main = 0 if main==.
*para los que no tienen relab, los asumo cuentapropistas:
replace relab = 3 if relab==.

*egen inc_nonagric_p = total(inc_nonagric) if main==1, by(hhid com)
*egen inc_nonagric_np = total(inc_nonagric) if main==0, by(hhid com)
egen inc_nonagric_emp_p = total(inc_nonagric) if main==1 & relab==1, by(hhid com)
egen inc_nonagric_emp_np = total(inc_nonagric) if main==0 & relab==1, by(hhid com)
egen inc_nonagric_se_p = total(inc_nonagric) if main==1 & relab==3, by(hhid com)
egen inc_nonagric_se_np = total(inc_nonagric) if main==0 & relab==3, by(hhid com)
gcollapse (mean) inc_nonagric_emp_p inc_nonagric_emp_np inc_nonagric_se_p inc_nonagric_se_np, by(hhid com)
save `income_non_agric', replace

* --------------------------------------
* S13: Credits and savings ( hh level)
* --------------------------------------
*tener cuidado con el id code of respondent porque en cada parte puede ser distinto (y ese dato está en S130, no en las minibases)
*S13A: savings (long)
*S13B: loans (long)
use "${input}\S130.dta", clear 
tempfile inc_renting
*q13_33 How much did your household receive in total over the past 12 months from renting out  property ?
*q13_39 How much did your household receive in total over the past 12 months from renting these assets to others?
tostring psu_number, format(%04.0f) replace
tostring hh_number, format(%02.0f) replace
*egen hhid = concat(psu_number hh_number), punct(-)
egen hhid = concat(psu_number hh_number)
destring psu_number hh_number, replace
egen inc_renting_assets = rsum( q13_33 q13_39), missing
replace inc_renting_assets = inc_renting_assets/12
sort hhid
save `inc_renting', replace

* ---------------------------------------------
*Section 14 (absentees information) (hh level)
* --------------------------------------------
use "${input}\S14A.dta", clear 
tostring psu_number, format(%04.0f) replace
tostring hh_number, format(%02.0f) replace
*egen hhid = concat(psu_number hh_number), punct(-)
egen hhid = concat(psu_number hh_number)
destring psu_number hh_number, replace
*q14_18 How much money did the household members receive from ..[PERSON].. during the past 12 months?
*q14_20 What is the value of all goods received by  the household members from ..[PERSON].. during the past 12 months?
/*q14_11 Where does ..[PERSON].. live now?
district codes: from 101 to 709
country codes: 801 to 819
*/
gen abroad = 1 if q14_11>=801 & q14_11<=819
replace abroad = 0 if (q14_11>=101 & q14_11<=709)
tempfile inc_remit_absent
replace q14_18 = q14_18/12
replace q14_20 = q14_20/12
egen inc_remit_absent_abroad_m = rsum(q14_18) if abroad==1 , missing
egen inc_remit_absent_abroad_nm = rsum(q14_20) if abroad==1 , missing
egen inc_remit_absent_nat_m = rsum(q14_18) if abroad==0, missing
egen inc_remit_absent_nat_nm = rsum(q14_20) if abroad==0, missing
collapse (sum) inc_remit*, by(hhid)
sort hhid
keep hhid inc_remit*
save `inc_remit_absent', replace

* -----------------------------------------
* Section 15: Other Remittances (hh level)
* -----------------------------------------
* Remittances and Transfer Income Received 
*q15_19 How much in total did you receive from. ..[DONOR].. over the past 12 months? CASH
*q15_19_a How much in total did you receive from. ..[DONOR].. over the past 12 months?  IN KIND
/*q15_17 Where does ..[PERSON].. live now?
district codes: from 101 to 709
country codes: 801 to 819
*/
use "${input}\S15B.dta", clear 
tostring psu_number, format(%04.0f) replace
tostring hh_number, format(%02.0f) replace
*egen hhid = concat(psu_number hh_number), punct(-)
egen hhid = concat(psu_number hh_number)
destring psu_number hh_number, replace
tempfile inc_remit_other
replace q15_19 = q15_19/12
replace q15_19_a = q15_19_a/12
gen abroad = 1 if q15_17>=801 & q15_17<=819
replace abroad = 0 if (q15_17>=101 & q15_17<=709)
egen inc_remit_other_abroad_m = rsum(q15_19) if abroad==1 , missing
egen inc_remit_other_abroad_nm = rsum(q15_19_a) if abroad==1 , missing
egen inc_remit_other_nat_m = rsum(q15_19) if abroad==0, missing
egen inc_remit_other_nat_nm = rsum(q15_19_a) if abroad==0, missing
*15.14 Who in your household is primarily responsible for receiving this assistan
rename q15_14 com
collapse (sum) inc_remit_other*, by(hhid com)
sort hhid com
keep hhid com inc_remit_other*
save `inc_remit_other', replace

* ----------------------------------------------------------------------------------
*Section 16: Transfers, Social Assistance and Other INCOME (hh level/source level)
* ----------------------------------------------------------------------------------
*Cash transfers programs:
use "${input}\S16A.dta", clear 
tempfile inc_transfer
tostring psu_number, format(%04.0f) replace
tostring hh_number, format(%02.0f) replace
*egen hhid = concat(psu_number hh_number), punct(-)
egen hhid = concat(psu_number hh_number)
destring psu_number hh_number, replace

/*
q16_01 Did any of the household members  receive payment  from ..[SOURCE].. during the past 12 months?
q16_04 is How much did your household members received from [SOURCE] in the last 12 months?
q16_02 How many household members are receiving the payments from ...[SOURCE]...?
Which household members are receiving the payments from ...[SOURCE]...?
q16_03_1 idocde1
q16_03_2 idocde2
q16_03_3 idcode3
q16_03_4 idcode4
*/
drop if q16_01!=1
keep hhid s161_code q16_04 q16_03_1 q16_03_2 q16_03_3 q16_03_4
forvalues i=1(1)4 {
replace q16_03_`i' = . if q16_03_`i'==0
}
egen members = rownonmiss(q16_03_1 q16_03_2 q16_03_3 q16_03_4)
gen inc_transfer = q16_04/ members
replace inc_transfer = inc_transfer/ 12
reshape long q16_03_, i(hhid s161_code) j(com)
drop if q16_03_==.
replace com = q16_03_
drop q16_03_ q16_04 members
/*Cash Transfer Programs					
01	Senior citizen allowance	- NCCT			
02	Single woman allowance			- NCCT	
03	Full disability allowance			- NCCT	
04	Partial disability allowance			- NCCT	
05	Endangered ethnicities' allowance		- NCCT		
06	Child grant				- CCT
07	Safe motherhood/Post-natal care allowance	- CCT		
08	Martyr’s family benefits			- NCCT	
09	Confilct victims benefits 			- NCCT	
10	Unemployment benefits				- CCT
11	Earthquake disaster relief			- NCCT	
12	Flood/landslide disaster relief		- NCCT		
13	Other disaster relief				- NCCT
14	Agricultural Subsidy (cash)			- NCCT	
15	Other cash assistance			- NCCT	
*/
gen inc_transfer_ncct = inc_transfer if inlist(s161_code,1,2,3,4,5,8,9,11,12,13,14,15)
gen inc_transfer_cct = inc_transfer if inlist(s161_code,6,7,10)
gcollapse (sum) inc_transfer*, by(hhid com)
save `inc_transfer', replace


/*In kind or public works programs: no se usa porque no se sabe montos
use "${input}\S16B.dta", clear 
tempfile sa_inkind
*q16_07 Did any of the household members participate in or receive any benefits from --> solo se puede saber si recibieron o no
keep if q16_07==1
tostring psu_number, format(%04.0f) replace
tostring hh_number, format(%02.0f) replace
*egen hhid = concat(psu_number hh_number), punct(-)
egen hhid = concat(psu_number hh_number)
destring psu_number hh_number, replace
*/
/*In-Kind Transfer programs						
01	Public Food Distribution System					
02	Nutritional Supplement program for children					
03	Nutritional Supplement program for mothers					
04	Midday meals					
05	Earthquake disaster relief					
06	Flood/landslide victims'  relief					
07	Other disaster relief					
08	Agriculture subsidy (in-kind)					
09	Other in-kind assistance					
Public Works (Cash for Work)						
10	Prime Minister's Employment Program (PMEP)					
11	Karnali Employment Program (KEP)					
12	Rural Community Infrastructure Works (RCIW)					
13	Labor Intensive Infrastructure Development Program					
14	Other public works program					
*/
*keep psu hh s162_code  q16_07 q16_08
*reshape wide q16_07 q16_08, i( psu hh ) j( s162_code )
*sort hhid
*save  `sa_inkind', replace

* --------------------------------
* S16: Other income: // hh level
* --------------------------------
use "${input}\S16C.dta", clear
tempfile inc_other
*q16_10 How much has the household received from ..[ITEM].. in the past 12 months? (interest, dividends, profit, payments, etc.)
tostring psu_number, format(%04.0f) replace
tostring hh_number, format(%02.0f) replace
*egen hhid = concat(psu_number hh_number), punct(-)
egen hhid = concat(psu_number hh_number)
destring psu_number hh_number, replace
rename q16_10 inc_other_
replace inc_other = inc_other/12
*gcollapse (sum) inc_other, by(hhid)
keep hhid s163_code  inc_other
reshape wide inc_other, i(hhid) j( s163_code )
sort hhid
save  `inc_other', replace

* ------------------------------------
*Section 17: adequacy of consumption (hh level) - not used
*Section 18: security (hh level) - not used
* -------------------------------------

*************************************************************************
* 			ADDITIONAL GMD VARIABLES 					

*Section 2: household Expenses
use "${input}\S020.DTA", clear
tempfile s02_expenditure
tostring psu_number, format(%04.0f) replace
tostring hh_number, format(%02.0f) replace
*egen hhid = concat(psu_number hh_number), punct(-)
egen hhid = concat(psu_number hh_number)
destring psu_number hh_number, replace
cap rename water water_orig
* {2.23} How much did you pay for water over the last 12 months? 
gen water_aux = q02_23
* q02_26 : {2.26} How much did your household pay for garbage disposal over the last month?
gen garbage_aux =  q02_26*12
*electricity: {2.30} How much did you spend on electricity over the past 12 months?
gen elect_aux = q02_30
* q02_35_1a: purchased -- In the last 12 months, from which of the following sources did your household obtain firewood and what value is your usage equivalent to?
gen firewood_aux = q02_35_1a
*Landline telephone: Which of the following facilities are there in your dwelling unit and how much do you pay for them? Annual Expense
gen landphone_aux = q02_31_a2
gen cable_aux = q02_31_b2
gen internet_aux = q02_31_c2
keep hhid water_aux garbage_aux elect_aux firewood_aux landphone_aux cable_aux internet_aux
sort hhid 
save `s02_expenditure', replace

*Nonfood expendituree
use "${input}\S06A.DTA", clear
tempfile s06_expenditure
tostring psu_number, format(%04.0f) replace
tostring hh_number, format(%02.0f) replace
*egen hhid = concat(psu_number hh_number), punct(-)
egen hhid = concat(psu_number hh_number)
destring psu_number hh_number, replace
*Were any of the following items purchased or received in-kind by your household over the past 12 months? RUPEES
rename q06_02a_a exp_
rename s06a_code code
keep hhid exp_ code
reshape wide exp_, i(hhid) j(code)
sort hhid 
keep hhid exp_451 exp_452 exp_453 exp_454 exp_431 exp_432 exp_522 exp_533 exp_544 exp_553 exp_562 exp_513 exp_722
save `s06_expenditure', replace

*Weights (only hh):
use "${input}\99_NLSSIV_hhdata.dta", clear 
ren pcep pcep_raw1
merge 1:1 psu_number hh_number using "${input}\poverty.dta", keepusing(pcep) keep(1 3) nogen
tempfile weights
cap drop hhid
tostring psu_number, format(%04.0f) replace
tostring hh_number, format(%02.0f) replace
*egen hhid = concat(psu_number hh_number), punct(-)
egen hhid = concat(psu_number hh_number)
destring psu_number hh_number, replace
*keep hhid dist_code domain prov base_hh_wt_adj ind_wt
save `weights', replace

*Disabilities
*S8: disability and mortality (not used) (individual level)
use "${input}\S080.dta", clear
tempfile disability
tostring psu_number, format(%04.0f) replace
tostring hh_number, format(%02.0f) replace
*egen hhid = concat(psu_number hh_number), punct(-)
egen hhid = concat(psu_number hh_number)
destring psu_number hh_number, replace
gen com = s08_idc
save  `disability', replace

*Utilities and assets
use "${input}\S06C.DTA", clear
tempfile asset
tostring psu_number, format(%04.0f) replace
tostring hh_number, format(%02.0f) replace
*egen hhid = concat(psu_number hh_number), punct(-)
egen hhid = concat(psu_number hh_number)
destring psu_number hh_number, replace
rename q06_03c own_
rename s06c_code code
keep hhid own code
reshape wide own, i(hhid) j(code)
sort hhid
save `asset', replace

*Livestock property
use "${input}\S11E1.dta", clear
tempfile livestock_asset
tostring psu_number, format(%04.0f) replace
tostring hh_number, format(%02.0f) replace
*egen hhid = concat(psu_number hh_number), punct(-)
egen hhid = concat(psu_number hh_number)
destring psu_number hh_number, replace
rename q11_65_a own_livestock_
rename s11e1_code code
keep hhid own code
reshape wide own, i(hhid) j(code)
sort hhid
save  `livestock_asset', replace

*Livestock property
use "${input}\S11F.dta", clear
tempfile farming_asset
tostring psu_number, format(%04.0f) replace
tostring hh_number, format(%02.0f) replace
*egen hhid = concat(psu_number hh_number), punct(-)
egen hhid = concat(psu_number hh_number)
destring psu_number hh_number, replace
rename q11_75 own_farming_
rename s11f_code code
keep hhid own code
reshape wide own, i(hhid) j(code)
sort hhid
save  `farming_asset', replace


*******************************************************************
* -----------------------------------------------------------------
*** MERGE DATASETS
* -----------------------------------------------------------------
*******************************************************************

	use `roster', clear
	* Individual-level datasets
	foreach p in migration education disability labor wage income_non_agric inc_transfer inc_remit_other pond_agric {
	merge 1:1 hhid com using ``p''
	keep if _merge!=2
	drop _merge
	}

	*reajusto los ponderadores para que sumen uno a nivel de hogar
	egen aux = sum(pond_agric), by(hhid)
	replace pond_agric = pond_agric/aux
	drop aux
	
	* Household-level datasets
	foreach x in weights housing tot_agric inc_renting inc_remit_absent inc_other food asset livestock_asset farming_asset nonfood_own travel_inkind agriland area_ownland area_notownland s02_expenditure s06_expenditure{
	merge m:1 hhid using ``x'', nogen force
	}

	*Los que se definen solo para el jefe de hogar porque es una a nivel de todo el hogar
		foreach var of varlist food_inkind inc_renting_assets inc_renting_housing nonfood_own travel_inkind inc_remit_absent* inc_other* implicit_rent {
		replace `var' = . 	if  q01_04!=1
		}

	sort hhid com
	drop if psu == . | hh_number==.

	*Asigno ingreso agrícola entre miembros que tienen ponderadores: si no tienen, asigno solo al jefe de hogar
	egen aux = sum(pond), by(hhid) 
	replace aux = round(aux)
	rename agri_income_tot agri_income_tot_old
	gen agri_income_tot = agri_income_tot_old*pond_agric if aux==1 // hogares que tienen ponderadores definidos
	replace agri_income_tot = agri_income_tot_old if aux==0 & q01_04==1 // hogares que tienen ponderadores definidos van al jefe de hogar
	drop aux


* -----------------------------------------------------------
* Final adjustments 
*Ajusto main job en función de relab:
*A los que tienen relab = 2, les paso el ingreso de self employed de main occupation a non-principal
gen tag = 1 if inc_nonagric_se_p!=0 & inc_nonagric_se_p!=. & relab_7days == 2
egen aux = rsum(inc_nonagric_se_p inc_nonagric_se_np), missing
replace inc_nonagric_se_np = aux if tag==1
replace inc_nonagric_se_p = . if tag==1
drop tag aux

*A los que tienen relab = 2, les paso el ingreso de employer de main occupation a non-principal
gen tag = 1 if inc_nonagric_emp_p!=0 & inc_nonagric_emp_p!=. & relab_7days == 2
egen aux = rsum(inc_nonagric_emp_p inc_nonagric_emp_np), missing
replace inc_nonagric_emp_np = aux if tag==1
replace inc_nonagric_emp_p = . if tag==1
drop tag aux

*A los que tienen relab = 1, les paso el ingreso de self employed de main occupation a non-principal
gen tag = 1 if inc_nonagric_se_p!=0 & inc_nonagric_se_p!=. & relab_7days == 1
egen aux = rsum(inc_nonagric_se_p inc_nonagric_se_np), missing
replace inc_nonagric_se_np = aux if tag==1
replace inc_nonagric_se_p = . if tag==1
drop tag aux

cap drop hogarsec
gen     hogarsec = 0		if  q01_04!=.
replace hogarsec = 1		if  q01_04==12

tostring com, format(%02.0f) g(aux_pid)
egen pid = concat(hhid aux_pid)
drop aux_pid
gen wgt = base_hh_wt_adj


* -----------------------------------------
*<_Save data file_>
compress
save "${output}/`yearfolder'_v`vm'_M.dta", replace
* -----------------------------------------

