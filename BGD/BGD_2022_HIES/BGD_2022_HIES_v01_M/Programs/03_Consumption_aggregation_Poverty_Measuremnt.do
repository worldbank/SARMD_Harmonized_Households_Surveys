
/******************************************************************************
          Governemnmt of the Peoples'Republic of Bangladesh
			             Ministry of Planning
				 Statistics and Informatics Division
				    Bangladesh Bureau of Statistics
					
				HOUSEHOLD INCOME AND EXPENDITURE SURVEY 2022
				

		**Consumption Aggregation and Poverty Measurement-CBN**
******************************************************************************/

/*------------------------------------------------------------------------------
				PREPARED BY: HIES 2022 TEAM, BBS and CONSULTANTS
------------------------------------------------------------------------------*/

/*****************************************************************************
               Consumtion Aggreation and Household Expenditure
*****************************************************************************/



****************************FOOD CONSUMPTION**********************************

/*****************************************************************************
     * Daily Consumtion from Section HH_SEC_9A1 outlier adjusted file *
*****************************************************************************/

use HH_SEC_9A1_adj.dta,clear
sort psu hhid visit day item qty value

drop if (qty==0 | qty==.) & (value==0 | value==.)
duplicates tag  psu hhid visit day item qty value,gen(dup)
tab dup

duplicates drop psu hhid visit day item qty value,force
drop dup

egen tconsumers=rowtotal(boy girl men women)
 
bysort psu hhid visit day : gen no_item1=_n

collapse (sum) fexpday= value (max) no_item1 term boy girl men women tconsumers,by(psu hhid visit day)
gen hhold=psu*1000+hhid

collapse (sum) fexp1= fexpday boy=boy girl=girl men=men women=women totconsumers=tconsumers ///
(count) ndays=day (mean) no_item1 (max) term,by(hhold)

** convert to 14 days first 
replace fexp1=fexp1*14/ndays

** convert to monthly food exp1. **
gen month_fexp1=fexp1*365/(14*12)
summ month_fexp1
sort hhold
save temp1,replace


/*****************************************************************************
     * Weekly Consumtion from Section HH_SEC_9B2 outlier adjusted file *
*****************************************************************************/
use HH_SEC_9B2_adj.dta,clear

cap drop dup
sort psu hhid week item
drop if (qty==0 | qty==.) & (value==0 | value==.)
duplicates tag  psu hhid week item qty value,gen(dup)
tab dup

duplicates drop psu hhid week item qty value,force
drop dup

collapse (sum) fexpweek=value (count) no_item2=item,by(psu hhid week)
collapse (sum) fexp2=fexpweek (count) nweeks=week (mean) no_item2,by(psu hhid)
gen hhold=psu*1000+hhid

** convert expenditure to 14 days (2 weeks) first**
replace fexp2=fexp2*2/nweeks

** convert to monthly food exp2. **
gen month_fexp2=fexp2*365/(14*12)
summ month_fexp2
sort hhold
save temp2,replace

use temp1, clear
	merge 1:1 hhold using temp2
	tab _merge
	egen fexp = rowtotal(month_fexp1 month_fexp2)
	egen num_items = rowtotal(no_item1 no_item2)
	label var fexp "Monthly food consumption"
	summarize
	drop fexp1 fexp2 _merge
	sort hhold
	*save  "$temp\fexp_hies2022_new", replace
	save  fexp_hies2022_new, replace
	
    erase temp1.dta
	erase temp2.dta
    

	
	
****************************NON-FOOD EXPENDITURE********************************

/*******************************************************************************
                 MONTHLY NON-FOOD EXPENDITURE: Section 9, Part C
*******************************************************************************/
	use HH_SEC_9C, clear
    rename (S9CQ00 S9CQ01 S9CQ02 S9CQ03) (item value1 value2 value)
	rename SERIAL serial
	rename TERM term
	drop if value1==. & value2==. & value==.
	duplicates tag PSU HHID item value,gen(dup)
	tab dup
	duplicates drop PSU HHID item value,force
	gen hhold=PSU*1000+HHID	
	gen aux=1
	collapse (sum) nfood1=value nfitem1=aux (max) term=term  , by(hhold)
	summ nfood1 nfitem1
	
	gen non_missnf=1 if nfood1!=0|nfood1==. // Flagging HH with Nonfood Consumtion//
	replace non_missnf=2 if nfood1==0|nfood1==.

	sort hhold
	save temp1, replace

	/*******************************************************************************
                 YEARLY NON-FOOD EXPENDITURE: Section 9, Part D1
*******************************************************************************/
	
	use HH_SEC_9D1_adj.dta, clear
	rename TERM term
	sort PSU HHID item
	cap drop dup
	duplicates tag PSU HHID item value,gen(dup)
	tab dup
	
	duplicates drop PSU HHID item value,force
	drop dup
	drop if item==. & quantity==. & value==. 
	gen aux=1
	cap drop hhold
	gen hhold=PSU*1000+HHID	
	
	collapse (sum) nfood2=v nfitem2=aux (max) term=term , by(hhold)
	replace nfood2=nfood2/12
	
	gen non_missnf=1 if nfood2!=0|nfood2==.
	replace non_missnf=2 if nfood2==0|nfood2==.

	sort hhold
	save temp2, replace

		/*******************************************************************************
                 YEARLY NON-FOOD EXPENDITURE: Section 9, Part D2
*******************************************************************************/

	use HH_SEC_9D2_adj, clear
	
	rename TERM term
	sort PSU HHID item
	cap drop hhold
	gen hhold=PSU*1000+HHID	
	sort hhold item
	cap drop dup
	
	count if value>0 & value~=. & v==. 
	replace v=value if value>0 & value~=. & v==.
	
	** drop expensive items  and lumpy expenditures **
	** Some expensive items like personal MOTOR CAR, Motor Cycle, Microbus,    Scooter etc. are new items included in HIES2022 questionnaire. We kept aside these items from consumption expenditures
	** other lumpy items are same as HIES 2016
	
	drop if (item>=1 & item<=3) | (item>=77 & item<=78) | ///
	 (item>=119 & item<=123) | item==129 |(item>=131 & item<=132)  ///
	 | item==136 | (item>=138 & item<=140)
	
	** seperate education expenditure **
	
	*gen code=1 if item>=79 & item<=93
	gen code=1 if item>=79 & item<=90
	replace code=2 if code==.
	label define code 1 "Education"
	label define code 2 "Others",add
	label values code code
	
	gen edu_exp=v/12 if code==1
	gen oth_exp=v/12 if code==2
	
	
	drop if item==.
	gen aux=1
	duplicates tag  hhold item value,gen(dup)
	tab dup
	
	duplicates drop hhold item value,force
	drop dup
	collapse (sum) nfood3=v  edu_exp oth_exp nfitem3=aux  (max) term=term, by(hhold)
	replace nfood3=nfood3/12
	
	gen non_missnf=1 if nfood3!=0|nfood3==.
	replace non_missnf=2 if nfood3==0|nfood3==.
	
	sort hhold
	save temp3, replace
	
	
	
/**************************************************************************
                    ADJUSTMENT OF EDUCATION EXPENDITURES
**************************************************************************/
** There are some households in section 9D2 that does not have any education expenditures 
** However, these households reported education expenditure in Section 2B2 [Education Section]
** Hence we replaced education expenditure from Section 2B2 for the HH with missing education expenditure in section 9D2
**************************************************************************/


** Education expenditure from education module (HH_SEC_2B2)

use HH_SEC_2B.dta,clear
keep if  S2BQ01==1 & S2BQ00~=.
gen hhold=PSU*1000+HHID
sort hhold
save edu_temp1,replace

use HH_SEC_2B2.dta,clear
rename S2BQ08 mid
gen hhold=PSU*1000+HHID
sort hhold
merge hhold using edu_temp1
tab _m
drop if _m==2
drop _m
egen tot_exp=rowtotal(S2BQ08A - S2BQ08P) 
collapse (sum) edu_exp_2B=tot_exp ,by(hhold)
count if edu_exp_2B==0 | edu_exp_2B==.

drop if edu_exp_2B==0 | edu_exp_2B==.

** make it monthly expenditure **
replace edu_exp_2B=edu_exp_2B/12
sort hhold
save edu_t0,replace


** Education expenditure from yearly non-food expenditure (HH_SEC_9D2)

use HH_SEC_9D2_adj.dta,clear
cap drop hhold
gen hhold=PSU*1000+HHID
gen edu_exp_9d2=v/12 if (item>=79 & item<=90) 
collapse (sum) edu_exp_9d2=edu_exp_9d2 ,by(hhold)
sort hhold
save edu_t1,replace

use edu_t0
sort hhold
merge hhold using edu_t1
tab _m
drop if _m==2
drop _m
count if edu_exp_2B>0 & edu_exp_2B~=. & (edu_exp_9d2==. | edu_exp_9d2==0)
save edu_exp_original_hies2022,replace

** Replace the missing expenditures from  the education module **
 
replace edu_exp_9d2=edu_exp_2B if (edu_exp_9d2==. | edu_exp_9d2==0) & (edu_exp_2B>0 & edu_exp_2B~=.) 
collapse (sum) edu_exp_9d2=edu_exp_9d2,by(hhold)
sort hhold
save edu_exp_modified_hies2022.dta,replace


use edu_exp_modified_hies2022.dta,clear
sort hhold
merge hhold using temp3
tab _m
drop _m
replace edu_exp=edu_exp_9d2
cap drop non_food3
egen non_food3=rsum(edu_exp oth_exp)
sort hhold
save temp4,replace
        
use temp1,clear
sort hhold
merge 1:1 hhold using temp2
tab _m
drop _m
sort hhold
merge 1:1 hhold using temp4
tab _m
drop _m
cap drop nfexp
egen nfexp = rowtotal(nfood1  nfood2 non_food3)
cap drop nfitems
egen nfitems = rowtotal(nfitem1  nfitem2 nfitem3)
	
save nfexp_hies2022_new, replace
   	

/**************************************************************************
                      AGGREGATING TOGETHER THE VARIOUS TOTALS
**************************************************************************/
	
	use  fexp_hies2022_new, clear
	gen non_miss=1 if fexp!=0|fexp==.
	replace non_miss=2 if fexp==0|fexp==.

	sort hhold
	merge 1:1 hhold using nfexp_hies2022_new
	tab  _merge
	
	drop _merge
	
	replace non_miss=2 if non_missnf==.
	drop non_missnf
	egen hhexp = rowtotal(fexp nfexp)
	sort hhold
	save hhold_exp_hies2022_new.dta,replace 
	
	use HH_SEC_1A.dta,clear
	rename  TEAM_ID  team
	rename (ID_01_CODE ID_01_NAME) (div div_name)
	rename (ID_02_CODE ID_02_NAME) (zl zl_name)
	rename ID_09_CODE rmo
	rename (INTERVIEWER_NAME MEMBER) (interv_name member)
	gen hhold=PSU*1000+HHID
	keep TERM hhold rmo div div_name zl zl_name team interv_name member
	sort hhold
	*merge hhold using "$temp\hhold_exp_hies2022_new.dta"
	
	merge hhold using hhold_exp_hies2022_new.dta
	tab _m
	drop  if _m==2
	drop _m
	replace fexp=. if nfexp==.
    replace nfexp=. if fexp==.
    replace hhexp=. if fexp==. | nfexp==.
	
	** make missing values of nfood1 nfood2 non_food3 and edu_exp=0
	** which will make the average of these items representative to the total for comparing during computation process
	replace nfood1=0 if nfood1==.
	replace nfood2=0 if nfood2==.
	replace non_food3=0 if non_food3==.
	replace edu_exp=0 if edu_exp==.
	
	save hhold_exp_hies2022_new.dta,replace 
	
	** put stratum code and weights to expenditure file **
	
	use weight_final_2022.dta,clear
	cap drop hhold
	gen hhold=PSU*1000+HHID
	keep hhold domain16 stratum16 hh_wgt pop_wgt urbrural 
    sort hhold
	save temp1,replace

	** Calculating per capita food, nonfood and consumtion expenditure	
	use hhold_exp_hies2022_new.dta,clear
	sort hhold
	merge hhold using temp1
	tab _m
	keep if _m==3
	drop _m
	cap drop pcfexp
	gen pcfexp=fexp/member
	cap drop pcnfexp
	gen pcnfexp=nfexp/member
	cap drop pcexp
	gen pcexp=hhexp/member
	
	table urbrural [aw=pop_wgt],stat(m pcfexp) stat(m pcnfexp) stat(m pcexp) nformat (%9.0f)
	
	table urbrural [aw=hh_wgt],stat(m fexp) stat(m nfexp) stat(m hhexp) nformat (%9.0f)
	
	table urbrural [aw=hh_wgt] if non_miss==1,stat(m fexp) stat(m nfexp) stat(m hhexp) nformat (%9.0f)
     save hhold_exp_hies2022_new.dta,replace      


/**************************************************************************
                      Rent and Imputed Rent Adjustment
**************************************************************************/
** There are some households that did not report either rent or imputed rent for owner occupied residence
** Hence, we predicted the rent using following regression based on households'chracteristics in Section 6A.


use HH_SEC_9D1_adj, clear

keep if item>=83 & item<=84
keep PSU HHID item value 
duplicates tag PSU HHID item,gen(dup)
tab dup
duplicates drop PSU HHID item,force
drop dup

reshape wide  value, i(PSU HHID) j(item)
rename value83 rent
rename value84 imprent
sort PSU HHID
save temp1, replace


** Regression for predicting Rent **

use HH_SEC_6A.dta,clear
keep PSU HHID S6AQ28
sort PSU HHID
merge PSU HHID using temp1
tab _m
drop _m
sort PSU HHID
save temp2,replace

use HH_SEC_1A,clear
sort PSU HHID
merge PSU HHID using temp2
tab _m
keep if _m==3
drop _m


replace imprent=rent if rent>0 & rent~=. & S6AQ28~=2 & (imprent==. | imprent==0)
replace rent=imprent if imprent>0 & imprent~=. & S6AQ28==2 & (rent==. | rent==0)

** when value of rent and imprent both present : choose only one 
**  with the help of ownership status ****

replace rent=. if (rent>0 & rent~=.) & (imprent>0 & imprent~=.) & S6AQ28~=2 
replace imprent=. if (rent>0 & rent~=.) & (imprent>0 & imprent~=.) & S6AQ28==2 

save housing_rent_hies2022_new,replace


** preparing variables for regression

use HH_SEC_6A.dta, clear

gen lnroom=log( S6AQ02)

gen dining=0
replace dining=1 if S6AQ03==1

gen kitchen=0
replace kitchen=1 if S6AQ24==2

gen brickwall=0
replace brickwall=1 if S6AQ04==5
replace brickwall=. if S6AQ04==.

gen tapwater=0
replace tapwater=1 if  S6AQ09==1 &  tapwater~=.

gen electricity=0
replace electricity=1 if  S6AQ18==1

gen telephone=0
replace telephone=1 if S6AQ26==1

gen lndwsize=log(S6AQ06)

gen rental=0
replace rental=1 if S6AQ28==1 | S6AQ28==3

keep PSU HHID  lnroom - rental
gen hhold=PSU*1000+HHID
sort hhold
save temp1, replace

use housing_rent_hies2022_new,clear
keep PSU HHID rent imprent S6AQ28
cap drop hhold
gen hhold=PSU*1000+HHID
sort hhold
save temp2,replace


use temp1,clear
merge hhold using temp2
tab _m
*drop if _m==2 
sort hhold
drop _m
save  temp3,replace


use weight_final_2022.dta,clear
cap drop hhold
gen hhold=PSU*1000+HHID
keep hhold  domain16 stratum16 hh_wgt pop_wgt urbrural 
sort hhold

merge hhold using temp3
tab _m
keep if _m==3
drop _m
save temp4,replace

use temp4,clear
sort hhold
replace rent=. if rent==0
replace imprent=. if imprent==0

gen dum1=(rent>0 & rent~=. )
gen dum2=(imprent>0 & imprent~=.)
gen lnrent=log(rent)
gen lnimprent=log(imprent)

tab domain16, gen(st)

* Distribution of rent by stratum  [weighted]**
* use only rent *

reg lnrent st1-st15  lnroom -  lndwsize [aw=hh_wgt]
* Comparison among predicted values, actual rents and imputed rents *
predict hat
gen pr_rent=exp(hat)
sum rent pr_rent lnrent hat [aw=hh_wgt] if dum1==1
sum imprent pr_rent [aw=hh_wgt]  if dum2==1
gen diff1=rent-pr_rent
gen diff2=imprent-pr_rent
sum diff1 diff2 [aw=hh_wgt]

kdensity lnrent [aw=hh_wgt], gen(x1 lnrent_h)
label var lnrent_h "density: log(rent)"
kdensity hat if lnrent~=. [aw=hh_wgt] , gen(x2 lnrent_h2)
label var lnrent_h2 "density: predicted log(rent)"
twoway (line lnrent_h x1) (line lnrent_h2  x2)


kdensity lnimprent [aw=hh_wgt] , gen(x3 lnimprent_h)
label var lnimprent_h "density: log(imprent)"
kdensity hat if lnimprent~=. [aw=hh_wgt], gen(x4 lnimprent_h2)
label var lnimprent_h2 "density: predicted log(imprent)"
twoway (line lnimprent_h x3) (line lnimprent_h2 x4)

** Adjustment of consumption expenditures for households who did not report
** rents or imputed rents

save temp4,replace


*** After creating consumption aggregate file, the program should be run again ***

use hhold_exp_hies2022_new.dta, clear

sort hhold
merge hhold using temp4

tab _m
keep if _m==3
drop _m
rename hhexp consexp
cap drop consexp2
gen consexp2=consexp
replace consexp2=consexp+pr_rent/12 if (rent==. |rent==0) & (imprent==. | imprent==0) 
cap drop nfexp2
gen nfexp2=nfexp
replace nfexp2=nfexp+pr_rent/12 if (rent==. |rent==0) & (imprent==. | imprent==0) 
cap drop p_cons
gen p_cons=consexp/member
cap drop p_cons2
gen p_cons2=consexp2/member
cap drop p_nfexp2
gen p_nfexp2=nfexp2/member
cap drop p_fexp2
gen p_fexp2=fexp/member

label var p_cons "per capita initial consumption expenditure"
label var p_cons2 "per capita cons exp including predicted rents"
label var p_nfexp2 "per capita nfexp including predicted rents"
label var p_fexp2 "per capita fexp "

** Monthly expenses for rents
cap drop hsvalhh
gen hsvalhh=rent/12
replace hsvalhh=imprent/12 if hsvalhh==.
replace hsvalhh=pr_rent/12 if hsvalhh==.
*cap drop rent
replace rent=rent/12
*cap drop imprent
replace imprent=imprent/12
*cap drop pr_rent
replace pr_rent=pr_rent/12

label var rent "Monthly Rent"
label var imprent "Monthly imputed rent"
label var pr_rent "Monthly Predicted rent for households who did not report rents nor imputed rents"
label var hsvalhh "Monthly rents (rent, imprent or pr_rent) for household"
label var nfexp "Monthly initial Non-food expenditure"
label var nfexp2 "Monthly Non-food expenditure including predicted rents"
label var consexp "Monthly initial consumption expenditure"
label var consexp2 "Monthly consumption expenditure including predicted rents for hholds who didn't report rents nor imprent"

* Keeping only the HHs with Complete Consumtion Data
keep if non_miss==1
count
*HH 14270
save expenditure_hies2022_new.dta, replace 


/*******************************************************************************
                 CALCULATING UNIT PRICES OF FOOD ITEMS OF FOOD BASKET
*******************************************************************************/

use expenditure_hies2022_new, clear

xtile d_con=p_cons2 [aw=pop_wgt], nq(10)
keep hhold domain16 stratum16 d_con hh_wgt pop_wgt 
sort hhold

save temp0,replace


use HH_SEC_9A1_hies2022_qty_gm_new.dta, clear

cap drop hhold
gen hhold=psu*1000+hhid
duplicates tag hhold visit day item qty value,gen(dup)
tab dup
duplicates drop hhold visit day item qty value,force
sort hhold item 

** Coding the items of FOOD BASKET
cap drop itemcode
gen     itemcode = 01 if item== 5
replace itemcode = 02 if item== 12
replace itemcode = 03 if item== 170
replace itemcode = 04 if item== 29
replace itemcode = 05 if item== 165
replace itemcode = 06 if item== 75
replace itemcode = 07 if item== 92
replace itemcode = 08 if item== 105
replace itemcode = 09 if item== 177 | item==179
replace itemcode = 10 if item==48 | item==49
replace itemcode = 11 if (item>=141 & item<=155) | (item>=161 & item<=162)
drop if itemcode==.
	
** generate unit price per kg **

gen up=(value/qtygm)*1000
collapse (mean) up, by(hhold itemcode)
sort hhold
merge hhold using temp0
tab _merge
keep if _merge==3
drop _merge

** keep only reference group households i.e. 2-6 decile HHs **
keep if d_con>=2 & d_con<=6
keep hhold itemcode domain16 up  hh_wgt
drop if itemcode==.
collapse (median) up [aw=hh_wgt], by(itemcode domain16)

save temp2, replace
reshape wide up, i(domain16) j(itemcode)
for var up1-up11: rename X X_22

label var up1_22 "Rice (coarse)  "
label var up2_22 "Wheat "
label var up3_22 "Pulse(lentil)"
label var up4_22 "Beef        "
label var up5_22 "Potato       "
label var up6_22 "Milk (liquid)      "
label var up7_22 "Mustard oil        "
label var up8_22 "Banana        "
label var up9_22 "Sugar          "
label var up10_22 "Fishes        "
label var up11_22 "Other vegetables "

sort domain16

save price_hies2022_CBN_new.dta, replace


/******************************************************************************
           Constructing CBN poverty lines for HIES2022 using 16 domains
*******************************************************************************/
** COMPUTING THE FOOD POVERTY LINE
* ----------------------------------------------------------------------

use price_HIES2022_CBN_new.dta,clear

rename (up1_22 up2_22 up3_22 up4_22 up5_22 up6_22 up7_22 up8_22 up9_22 up10_22 up11_22) ///
(uprice upwheat uppulse upmeat uppotato upmilk upoil upbanana upsugar upfish upveg)
sort domain16
#delimit 
gen zf=(365/12)*(0.397*uprice
	+0.040*upwheat
	+0.040*uppulse
	+0.012*upmeat
	+0.027*uppotato
	+0.058*upmilk
	+0.020*upoil
	+0.020*upbanana
	+0.020*upsugar
	+0.048*upfish
	+0.150*upveg);
#delimit cr
*(2122/2154.205)
keep domain16 zf
drop if domain16==.
sort domain16
save fline_HIES2022_CBN_new.dta, replace


use fline_HIES2022_CBN_new.dta,clear
keep domain16 zf
sort domain16
save temp1,replace

** Merge food poverty lines by domain16 **
use expenditure_hies2022_new.dta,clear

keep hhold domain16 stratum16 p_cons2 p_fexp2 p_nfexp2 hh_wgt member pop_wgt
sort domain16
merge domain16 using temp1
tab _m
drop _m
keep hhold domain16 stratum16 zf  p_cons2 p_fexp2 p_nfexp2 hh_wgt member pop_wgt   

rename p_cons2 pcexp
rename p_fexp2 pcfexp
rename p_nfexp2 pcnfexp
sort domain16
save hhexp_HIES2022_CBN_new, replace

*******************************************************************************
*       PROGRAM DEFINED: NON-FOOD AllOWANCE USING NON-PARAMETRIC METHODS
*******************************************************************************
clear
set more off
use hhexp_HIES2022_CBN_new, clear

forvalues k=10(-1)1 {
   gen pcnfl`k'=pcnfexp if [ pcexp>=(100-`k')*zf/100] & [ pcexp<=(100+`k')*zf/100]
   gen pcnfu`k'=pcnfexp if [pcfexp>=(100-`k')*zf/100] & [pcfexp<=(100+`k')*zf/100]
 }

collapse (median) pcnfl* pcnfu*  [aw=pop_wgt], by(domain16)

sort domain16
merge domain16 using fline_HIES2022_CBN_new.dta

tab  _merge
drop _merge
egen znfl=rowmean(pcnfl10-pcnfl1)
egen znfu=rowmean(pcnfu10-pcnfu1)
gen  zl_cbn=zf+znfl
gen  zu_cbn=zf+znfu
count if zl_cbn==.

/*******************************************************************************
** There are two domains which have missing lower poverty lines
** but both of the domains have upper poverty lines  **
** This happens due to missing lower nonfood allowance in these domains
** These two Missing LOWER POVERTY LINES have been replaced by the average ratio of lower to upper poverty lines (zl_cbn/zu_cbn) taking only urban domains with both lower and upper lines.
*******************************************************************************/

gen ratio_line=zl_cbn/zu_cbn

* Creating average of the ratio for Urban Domains that have both lower and upper poverty lines 
egen ratio_line1=mean(ratio_line) if (domain16==2|domain16==4|domain16==8| domain16==10| domain16==14|domain16==16)

* Replicating the the average ratio for all domains
egen ratio_line2=mean(ratio_line1)

* Replacing LOWER POVERTY LINES in domain16==6 and domain16==12 by (Upper_Poverty_Line* Average ratio)
replace zl_cbn=zu_cbn*ratio_line2 if (domain16==6|domain16==12)

drop ratio_line ratio_line1 ratio_line2

sort domain16
save povlines_HIES2022_CBN_new, replace


** compute CBN poverty rate **
use expenditure_hies2022_new.dta,clear

keep PSU HHID hhold div div_name domain16 stratum16 p_cons2 p_fexp2 p_nfexp2 hh_wgt pop_wgt urbrural

sort domain16
merge m:1 domain16 using povlines_HIES2022_CBN_new
tab _m
drop _merge


label define div 10 "Barishal" 20 "Chattogram" 30 "Dhaka" 40 "Khulna" 45"Mymensingh" 50 "Rajshahi" 55 "Rangpur" 60 "Sylhet"
label values div div


label define domain16 1 " Barishal Rural" 2 " Barishal Urban" 3 "Chattogram Rural" 4 " Chattogram Urban" 5 "Dhaka Rural" 6"Dhaka Urban" 7 "Khulna Rural" 8 "Khulna Urban" 9 "Mymensingh Rural" 10 "Mymensingh Urban" 11 "Rajshahi Rural" 12 "Rajshahi Urban" 13 "Rangpur Urban" 14 "Rangpur Urban" 15 "Sylhet Rural" 16 "Sylhet Urban", modify
label values domain16 domain16

label define urbrural 1 "Rural" 2 "Urban" 
label values urbrural urbrural


gen pooru_cbn=p_cons2<=zu_cbn & p_cons2~=.
gen poorl_cbn=p_cons2<=zl_cbn & p_cons2~=.


/**************************************************************************                     Survey Settings and Poverty Measurement
**************************************************************************/

svyset PSU [pw=pop_wgt], strata(domain16)|| HHID, strata(domain16)
svy: prop pooru_cbn poorl_cbn
svy: prop pooru_cbn, over (urbrural)
svy: prop pooru_cbn if urbrural==1, over (domain16)
svy: prop pooru_cbn if urbrural==2, over (domain16)

svy: prop poorl_cbn, over (urbrural)
svy: prop poorl_cbn if urbrural==1, over (domain16)
svy: prop poorl_cbn if urbrural==2, over (domain16)


svy: prop pooru_cbn, over (div) 
svy: prop poorl_cbn, over (div)


table urbrural [aw=pop_wgt] if p_cons2~=.,stat(m poorl_cbn) stat(m pooru_cbn) nformat (%9.3f)
table div [aw=pop_wgt] if p_cons2~=.,stat(m poorl_cbn) stat(m pooru_cbn) nformat (%9.4f)


/*------------------------------------------------------------------------------
				                    END
------------------------------------------------------------------------------*/













