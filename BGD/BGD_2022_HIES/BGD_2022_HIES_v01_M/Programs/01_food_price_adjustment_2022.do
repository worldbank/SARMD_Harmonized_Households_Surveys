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




/*******************************************************************************                          DAILY CONSUMPTION- Section 9A1
*******************************************************************************/

	
use "weight_final_2022.dta",clear
cap drop hhold
gen hhold=PSU*1000+HHID // creating unique id for each household
keep hhold domain16 stratum16 hh_wgt pop_wgt urbrural 
sort hhold
save "temp1",replace

// Daily Food Consumption data 
use "HH_SEC_9A1.dta", clear	
rename S9A2Q041 unit
rename TERM term
rename S9A2Q01 item
rename (S9A1Q01 S9A1Q02 S9A1Q03 S9A1Q04) (boy girl men women)
rename (PSU HHID VISIT DAY) (psu hhid visit day)
rename (S9A2Q05 S9A2Q07 S9A2Q08) (qty uprice value)
 
drop if (qty==0 | qty==.) & (value==0 | value==.)

duplicates tag term psu hhid visit day item unit qty uprice value,gen(dup)
tab dup

duplicates drop term psu hhid visit day item unit qty uprice value,force
drop dup

duplicates tag term psu hhid visit day item, gen(dup)
tab dup
drop dup


gen hhold=psu*1000+hhid
sort hhold
merge hhold using "temp1"
tab _m
keep if _m==3
drop _m
sort hhold item day
	
sum qty, de

*Rural variable	 
gen rural=urbrural==1
	

gen p_1=uprice
la var p_1 "Initial unit value"
gen p=p_1 
	
/*When quantity>0 and total value is zero, the unit value is zero. We replace these values for missing and at the end 
we use the medians to impute those prices, and compute the total value */
	
replace p=. if (qty>0 & qty~=.) & (value==. | value==0)
	
	
*Create Ln of p
	quietly gen lnp = ln(p) 
	
	
* 1) Identify and replace outliers as missings
	
	qui levelsof item, local (food) 	
	foreach f of local food {
	qui   sum p [aw = hh_wgt] if item==`f', detail	
    
* When the variance of p exists and is different from zero we detect and delete outliers
	     if r(Var) != 0 & r(Var) < . {
		
	     qui levelsof domain16, local(strat)
         foreach s of local strat {
            qui   sum p [aw = hh_wgt] if p > 0 & p <. & domain16 == `s' & item==`f'
            local antp = r(N)
			qui sum lnp [aw= hh_wgt] if domain16 == `s' & item==`f', detail
			local ameanp = r(mean)
			local asdp   = r(sd)			
      
		    replace  p =. if (abs((lnp - `ameanp') / `asdp') > 2.5 & ~mi(lnp)) & domain16 == `s' & item==`f'
		 	qui count if p > 0 & ~mi(p) & domain16 == `s' & item==`f'
		 	local postp = r(N)
			
		   }
	     }
       }
     
	gen outlier=(p==.)
	
	noi di as error "Number of outliers"
	count if p==.	
	
		
*2) Count number of observations without outliers
	bysort hhold      item: egen counthhold= count(p)
	bysort psu        item: egen countpsu=  count(p)
    bysort domain16  item: egen countstratum= count(p)
	bysort rural      item: egen countarea  = count(p)

		
*3) Calculate medians 
	
*A- Calculate median by household and item
	bysort hhold      item: egen medianhhold=   median(p)
	
	
*B- Calculate median by PSU and item
	bysort psu        item: egen medianpsu=     median(p)
	

*C-calculate median by stratum	
	 qui levelsof domain16, local(strat)
	 qui levelsof item, local(food)
 	  qui gen medianstratum = . 
	  foreach s of local strat {
	           foreach f of local food {
		qui su p [aw = hh_wgt] if domain16 == `s' & item==`f', detail
		qui replace medianstratum = r(p50) if domain16 == `s' & item==`f' & medianstratum == .
        }
	  }
		
	
*D-calculate median by urban/rural		 
	 qui levelsof rural, local(strat)
	 qui levelsof item, local(food)
 	  qui gen medianarea = . 
	  foreach s of local strat {
	           foreach f of local food {
		qui su p [aw = hh_wgt] if rural == `s' & item==`f', detail
		qui replace medianarea = r(p50) if rural == `s' & item==`f' & medianarea == .
        }
	  }

*E- Calculate median by country
      bysort   item: egen mediancountry=  median(p)
		
/*
     We impute the MEDIAN values at different levels. We start from the lowest or 
	 closest level (household) to the highest level (stratum):
	 
	 A- HOUSEHOLD: maximum number of observations = 14. We ask for more than 9 observations per household and item 
	 
	 B- PSU: We ask for more than 9 observations per PSU and item.
				  
	 C- STRATUM: We ask for more than 9 observations per stratum and item.
	 
	 D- URBAN/RURAL: We ask for more than 9 observations per area and item.
	 
	 E- NATIONAL: Replace outlier with national unit value	 */	
	
	
	noi di as error "Replacing outliers by household median price per item"	
	replace p=medianhhold if p==. & counthhold>9

	noi di as error "Replacing outliers by psu median price per item"	
	replace p=medianpsu  if p==. & countpsu>9
	
   	noi di as error "Replacing outliers by stratum median price per item"	
	replace p=medianstratum if p==. & countstratum>9
	
	noi di as error "Replacing outliers by area median price per item"	
	replace p=medianarea if p==. & countarea>9
	
	noi di as error "Replacing outliers by country median price per item"	
	replace p=mediancountry if p==. 
	
*Impute the total value if quantity>0 and value is zero or missing 
    replace value=qty*p if (qty>0 & qty~=.) & (value==. | value==0)| outlier==1
	
   
   save "HH_SEC_9A1_adj", replace
   

   
   
   
   
/*******************************************************************************                             WEEKLY CONSUMPTION							
******************************************************************************/

use "weight_final_2022.dta",clear
cap drop hhold
gen hhold=PSU*1000+HHID
keep hhold domain16 stratum16 hh_wgt pop_wgt urbrural 
sort hhold
save "temp1",replace

	
use "HH_SEC_9B2", clear
rename (TERM PSU HHID) (term psu hhid)
rename (SERIAL S9B2Q02 S9B2Q031 S9B2Q03U S9B2Q04 WEEK) (item qty unit uprice value week)
cap drop hhold
gen hhold=psu*1000+hhid
drop if  (qty==. | qty==0) & (value==. | value==0)
duplicates tag hhold week item unit qty uprice value,gen(dup)
tab dup
	
duplicates drop hhold week item unit qty uprice value, force
drop dup
	
sort hhold
merge hhold using "temp1"
tab _m
drop if _m==2
drop _m

sum qty, de

*Rural variable	 
	gen rural=(urbrural==1)
	

gen p_1=uprice
la var p_1 "Initial unit value"
gen p=p_1 
	
/*When qty>0 and total value is zero, the unit value is zero. We replace these values for missing and at the end 
we use the medians to impute those prices, and compute the total value */
	
replace p=. if (qty>0 & qty~=.) & (value==. | value==0)
	
	
*Create Ln of p
	quietly gen lnp = ln(p) 
	
	
* 1) Identify and delete outliers
	qui levelsof item, local (food) 	
	foreach f of local food {
	qui   sum p [aw = hh_wgt] if item==`f', detail	

* When the variance of p exists and is different from zero we detect and delete outliers
	     if r(Var) != 0 & r(Var) < . {
		
	     qui levelsof domain16, local(strat)
         foreach s of local strat {
            qui   sum p [aw = hh_wgt] if p > 0 & p <. & domain16 == `s' & item==`f'
            local antp = r(N)
			qui sum lnp [aw= hh_wgt] if domain16 == `s' & item==`f', detail
			local ameanp = r(mean)
			local asdp   = r(sd)			
      
		    replace  p =. if (abs((lnp - `ameanp') / `asdp') > 2.5 & ~mi(lnp)) & domain16 == `s' & item==`f'
		 	qui count if p > 0 & ~mi(p) & domain16 == `s' & item==`f'
		 	local postp = r(N)
			
		   }
	     }
       }
     
	 
	gen outlier=(p==.)
	
	noi di as error "Number of outliers"
	count if p==.	
	
		
*2) Count number of observations without outliers
	bysort hhold      item: egen counthhold= count(p)
	bysort psu        item: egen countpsu=  count(p)
    bysort domain16    item: egen countstratum= count(p)
	bysort rural      item: egen countarea  = count(p)

		
*3) Calculate medians 
	
*A- Calculate median by household and item
	bysort hhold      item: egen medianhhold=   median(p)
	
	
*B- Calculate median by PSU and item
	bysort psu        item: egen medianpsu=     median(p)
	

	
*C-calculate median by stratum	
	 qui levelsof domain16, local(strat)
	 qui levelsof item, local(food)
 	  qui gen medianstratum = . 
	  foreach s of local strat {
	           foreach f of local food {
		qui su p [aw = hh_wgt] if domain16 == `s' & item==`f', detail
		qui replace medianstratum = r(p50) if domain16 == `s' & item==`f' & medianstratum == .
        }
	  }
	 
*D-calculate median by urban/rural		 
	 qui levelsof rural, local(strat)
	 qui levelsof item, local(food)
 	  qui gen medianarea = . 
	  foreach s of local strat {
	           foreach f of local food {
		qui su p [aw = hh_wgt] if rural == `s' & item==`f', detail
		qui replace medianarea = r(p50) if rural == `s' & item==`f' & medianarea == .
        }
	  }
    
*E- Calculate median by country
    bysort   item: egen mediancountry=  median(p)
	  
   
*Number of outliers per household and item
	bysort hhold    item: egen countoutl= count(p) if p==.
    tab countoutl	  
   
   
*4) Correct outliers
	
/*
     We impute the MEDIAN values at different levels. We start from the lowest or 
	 closest level (household) to the highest level (stratum):
	 
	 A- HOUSEHOLD: maximum number of observations = 14. We ask for more than 9 observations per household and item 
	 
	 B- PSU: We ask for more than 9 observations per PSU and item.				
	 
	 C- STRATUM: We ask for more than 9 observations per stratum and item.
	 
	 D- URBAN/RURAL: We ask for more than 9 observations per area and item.
	 
	 E- NATIONAL: Replace outlier with national unit value	 */	
	 	
	
	
	noi di as error "Replacing outliers by household median price per item"	
	replace p=medianhhold if p==. &  counthhold>1 & countoutl!=2

	noi di as error "Replacing outliers by psu media price per item"	
	replace p=medianpsu  if p==. & countpsu>9
	
   	noi di as error "Replacing outliers by stratum median price per item"	
	replace p=medianstratum if p==. & countstratum>9
	
	noi di as error "Replacing outliers by area median price per item"	
	replace p=medianarea if p==. & countarea>9
	
	noi di as error "Replacing outliers by country median price per item"	
	replace p=mediancountry if p==. 
	
	
*Impute the total value if quantity>0 and value is zero or missing 
   replace value=qty*p if (qty>0 & qty~=.) & (value==. | value==0) | outlier==1
   

   save "HH_SEC_9B2_adj", replace

   
/*------------------------------------------------------------------------------
				                    END
------------------------------------------------------------------------------*/
