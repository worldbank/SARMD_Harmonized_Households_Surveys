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


   
/*******************************************************************************            SECTION 9D1: ANNUAL NON-FOOD EXPENDITURE
******************************************************************************/
** put weight and stratum code to nonfood consumption data file**
    use "weight_final_2022.dta",clear
	cap drop hhold
	gen hhold=PSU*1000+HHID
	keep hhold domain16 stratum16 hh_wgt pop_wgt urbrural 
    sort hhold
	save "temp1",replace


* Section 9, Part D (items 1 - 201)
	use "HH_SEC_9D1", clear
	gen hhold=PSU*1000+HHID
	sort hhold
	merge m:1 hhold using "temp1"
	tab _m
	keep if _m==3
	drop _m
	
	rename (S9D1Q01 S9D1Q04 S9D1Q05) (item quantity value)
	drop if  (quantity==. | quantity==0) & (value==. | value==0)
	
			
	duplicates tag hhold quantity item value,gen(dup)
	tab dup
	
	duplicates drop hhold quantity item value, force
	
	count if (quantity>0 & quantity~=.) & (value==. | value==0)
	
	
	gen flag=1 if (quantity>0 & quantity~=.) & (value==. | value==0)

	replace value=quantity  if (quantity>0 & quantity~=.) & (value==. | value==0) 
	replace quantity=1 if flag==1
	
	replace quantity=1 if item==141 & TERM==12 & quantity==5500
	
	
	gen q=quantity
	gen v=value
	
*Rural variable	 
	gen rural=(urbrural==1)
	
	gen p_1 = (v/q) if q~=.
	la var p_1 "Initial unit value"
	gen p=p_1 
	
	
/*When quantity>0 and total value is zero, the unit value is zero. We replace these values for missing and at the end we use the medians to impute those prices, and compute the total value */
	count if (q>0 & q~=.) & (v==. | v==0)

		
*Create Ln of p
	quietly gen lnp = ln(p) 
	
	
* 1) Identify and replace outliers as missings
	
	qui levelsof item, local (nfood) 	
	foreach n of local nfood {
	qui   sum p [aw = hh_wgt] if item==`n', detail	

      * When the variance of p exists and is different from zero we detect and delete outliers
	     if r(Var) != 0 & r(Var) < . {
		
	     qui levelsof  domain16, local(strat)
         foreach s of local strat {
            qui   sum p [aw = hh_wgt] if p > 0 & p <. &  domain16 == `s' & item==`n'
            local antp = r(N)
			qui sum lnp [aw= hh_wgt] if  domain16 == `s' & item==`n', detail
			local ameanp = r(mean)
			local asdp   = r(sd)			
      
		    replace  p =. if (abs((lnp - `ameanp') / `asdp') > 2.5 & ~mi(lnp)) &  domain16 == `s' & item==`n'
		
	
			qui count if p > 0 & ~mi(p) &  domain16 == `s' & item==`n'
		 	local postp = r(N)
			
		   }
	     }
       }
     
	gen outlier=(p==.)
	
	noi di as error "Number of outliers"
	count if p==.	
	
		
*A-calculate median by stratum
	 qui levelsof domain16, local(strat)
	 qui levelsof item, local(nfood)
 	 qui gen medianstrat = . 
	 foreach s of local strat {
	           foreach n of local nfood {
		qui su p [aw = hh_wgt] if domain16 == `s' & item==`n', detail
		qui replace medianstrat = r(p50) if domain16 == `s' & item==`n' & medianstrat == .
        }
	  }
			
	
*2) Correct outliers
	
/*	A- STRATUM: Replace outlier with stratum median unit value	 */	
	noi di as error "Replacing outliers by stratum median price per item"	
	replace p=medianstrat if p==. 
	
*Impute the total value if quantity>0 and value is zero or missing or  for outliers 
	replace v=q*p if  (q>0 & q~=.) & (p>0 & p~=.)
   
   	save "HH_SEC_9D1_adj", replace
   
   

/*******************************************************************************                  SECTION 9D2: ANNUAL NON-FOOD EXPENDITURE	
*******************************************************************************/  
    
** imputation of missing values when quantities are present or for extreme values (HH_SEC_9D2)

use "weight_final_2022.dta",clear
cap drop hhold
gen hhold=PSU*1000+HHID
keep hhold domain16 stratum16 hh_wgt pop_wgt urbrural 
sort hhold
save "temp1",replace

  
use "HH_SEC_9D2.dta",clear
rename (S9D2Q01 S9D2Q04 S9D2Q05) (item quantity value)
drop if  (quantity==. | quantity==0) & (value==. | value==0)
gen hhold=PSU*1000+HHID
	
		
duplicates tag hhold item value,gen(dup)
tab dup
	
duplicates drop hhold item value, force
sort hhold
merge m:1 hhold using "temp1"
tab _m
keep if _m==3
drop _m
	
** check **
count if (item>=14 & item<=22) | item==45 | (item>=57 & item<=59) | (item>=65 & item<=101) 
count if [(item>=14 & item<=22) | item==45 | (item>=57 & item<=59) | (item>=65 & item<=101)] & quantity~=. & (value==. | value==0)
local number=r(N)
	
br  TERM PSU HHID item quantity value if [(item>=14 & item<=22) | item==45 | (item>=57 & item<=59) | (item>=65 & item<=101)] /// 
& quantity~=. & (value==. | value==0)
	
	
gen q=quantity
gen v=value

	
summ q v value
table TERM,stat(sum v) stat(sum value) nformat (%12.0f)
	
    
*Rural variable	 
	gen rural=(urbrural==1)


	
	gen p_1 = (v/q) if q~=.
	la var p_1 "Initial unit value"

	gen p=p_1 
	
/*When quantity>0 and total value is zero, the unit value is zero. We replace these values for missing and at the end 
we use the medians to impute those prices, and compute the total value */
	
	replace p=. if (q>0 & q~=.) & (v==. | v==0)
 

*Create Ln of p
	quietly gen lnp = ln(p) 
	
	
* 1) Identify and replace outliers as missings
	
	qui levelsof item, local (nfood) 	
	foreach n of local nfood {
	qui   sum p [aw = hh_wgt] if item==`n', detail	

* When the variance of p exists and is different from zero we detect and delete outliers
	     if r(Var) != 0 & r(Var) < . {
		
	     qui levelsof  domain16, local(strat)
         foreach s of local strat {
            qui   sum p [aw = hh_wgt] if p > 0 & p <. &  domain16 == `s' & item==`n'
            local antp = r(N)
			qui sum lnp [aw= hh_wgt] if  domain16 == `s' & item==`n', detail
			local ameanp = r(mean)
			local asdp   = r(sd)			
      
		    replace  p =. if (abs((lnp - `ameanp') / `asdp') > 2.5 & ~mi(lnp)) &  domain16 == `s' & item==`n'
		 	qui count if p > 0 & ~mi(p) &  domain16 == `s' & item==`n'
		 	local postp = r(N)
			
		   }
	     }
       }
     
	gen outlier=(p==.)
	
	noi di as error "Number of outliers"
	count if p==.	
	
		
*A-calculate median by stratum
	 qui levelsof domain16, local(strat)
	 qui levelsof item, local(nfood)
 	 qui gen medianstrat = . 
	 foreach s of local strat {
	           foreach n of local nfood {
		qui su p [aw = hh_wgt] if domain16 == `s' & item==`n', detail
		qui replace medianstrat = r(p50) if domain16 == `s' & item==`n' & medianstrat == .
        }
	  }
* B- calculate median by national
	bysort item : egen mediancountry=median(p)
	
*3) Correct outliers
	
/*	 A- STRATUM: Replace outlier with stratum median unit value	 */	
	noi di as error "Replacing outliers by stratum median price per item"	
	replace p=medianstrat if p==. 
	replace p=mediancountry if p==. 
	
*Impute the total value if quantity>0 and value is zero or missing or  for outliers
*replace value=quantity*p if (quantity>0 & quantity~=.) & (value==. | value==0)
   
   replace v=q*p if  outlier==1 & q>0 & q~=.
   replace v=value if (q==0 | q==.) & value>0 & value~=.
   
*replace v=q*p if ((q>0 & q~=.) & (v==. | v==0)) | outlier==1
   recast str35 S9D2Q03,force
   

   save "HH_SEC_9D2_adj", replace
   
/*------------------------------------------------------------------------------
				                    END
------------------------------------------------------------------------------*/

