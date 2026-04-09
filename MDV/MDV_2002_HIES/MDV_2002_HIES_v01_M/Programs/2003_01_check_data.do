/* -----------------------------------------------------------------------------

     Poverty Trend in Maldives
          
     CONTACT: 
	 
	 Silvia Redaelli
	 sredaelli@worldbank.org
	 
	 Giovanni Vecchi 
	 giovanni.vecchi@uniroma2.it
                    
     MASTER FILE
     
     This version: May 1, 2015

----------------------------------------------------------------------------- */


* Define household size consistently with the definition used for 2010 
	* see "01_check_data.do"
	
	* household size does not include members who
	* don't consume meals at home and who are not family members

	use $path/inputdata/A2r-Individual-info.dta, clear
	
	ren hhserial hhid
	
	* generate "crude" hhsize
	
	gen hhsize_del = 1 if membershipstatus!=.
	egen hhsize = total(hhsize_del), by(hhid)
	drop hhsize_del
	
	* Construct "official" hhsize
	# delim ;
	label define membershipstatus 	1 "Household Head" 
									2 "Paying Guest" 
									3 "Foreign Domestic Servant" 
									4 "Local Domestic Servant" 
									5 "Guest" 
									6 "Other Household Member";
	label value membershipstatus membershipstatus;
	# delim cr
		
	/*
	
	The official definition in 2010 included all "family members" 
	and "paying guests" that are used to take meals together
	
	The 2003 questionnaire is different: 
	the first category rather than including "family members" only lists "household heads".
	We assume that all other family members are under the "other hh member" category: 
	the vast majority of individuals hold that category (83%).
	
	*/
	
	gen byte hhs = 0
	replace  hhs = 1 if ((membershipstatus<=2 | membershipstatus==6) & (takemeal==1) & (membershipstatus!=.))
	egen hhsize_off=total(hhs), by(hhid)
	label var hhid "household identifier"
	
	keep hhid hhsize hhsize_off maleatl
	collapse (firstnm) hhsize hhsize_off maleatl, by(hhid)
	label var hhsize "household size"
	label var hhsize_off "household size as defined by official sources (family members taking meals)"
	
	
	/*
	
	Note: for 4 households we find hhsize_off = 0 while hhsize != 0
	
         +--------------------------+
         | hhid   hhsize   hhsize~f |
         |--------------------------|
         |  102        1          0 |
         |  109        5          0 |
         |  737        1          0 |
         |  741        1          0 |
         +--------------------------+
	
	All members in these hh declared *not* to take meals with the household
	
	We replace hhsize_off = hhsize for these 4 households.
	
	*/
	
	replace hhsize_off=hhsize if (hhid==102|hhid==109|hhid==737|hhid==741)
			
	save $path/outputdata/check_2003.dta, replace 
	
	
	* Define weights 
	use $path/inputdata/A1r-Household-info.dta, clear
	
	rename hhserial hhid
	rename rfoverall wght_hh 
	label var wght_hh "household weight"
	keep hhid wght_hh region
	
	merge 1:1 hhid using $path/outputdata/check_2003.dta,
	keep if _m == 3
	drop _m
	
	gen wght_ind=wght_hh*hhsize
	label var wght_ind "individual weight"
	
	
	* Recode region2 to match 2009 def
	rename maleatl reg2
	label var reg2 "1 = Male' 2 = Atolls"
	label define reg2 1 "Male'" 2 "Atolls"
	label value reg2 reg2
	
	* Generate region6 to match 2009 regions
	rename region region6
	# delimit;
	la def region6
	0 "Male (capital)"
	1 "North"
	2 "Central North"
	3 "Central"
	4 "Central South"
	5 "South";
	label val region6 region6;
	# delimit cr
	
	save $path/outputdata/check_2003.dta, replace 
	
	* A couple of checks now 
	* our estimates compared with official data in HIES Final Report 2012 (p. 12)
	
	* individual weights
	egen pop=total(wght_ind)
	sum pop
	
	* household weights
	egen hh=total(wght_hh)
	sum hh
	
	drop hh pop
	
	/* 
	
	Estimated population: 282,296. 
	This compares to 282,808 (total population according to the HIES report).
	
	Estimated total number of households: 42,215. 
	This compares 42,526 (total number of housheolds according to the HIES report)
	
	Note: differences may be due to sample size. 
	
	In our datasets, 834 households. 
	The HIES 2012 Report shows  880 households */
	
	* Check hh size
	table reg2 [aw=wght_hh], c(mean  hhsize mean hhsize_off) format(%9.1f) row
	
	/* Sample estimates and HIES 2012 report match for the hhsize (not for hhsize_off)*/
	
	exit
	
