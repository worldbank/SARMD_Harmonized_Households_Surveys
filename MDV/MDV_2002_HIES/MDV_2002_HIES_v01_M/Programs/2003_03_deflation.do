	/* -----------------------------------------------------------------------------

     Poverty Trend in Maldives
          
     CONTACT: 
	 
	 Silvia Redaelli
	 sredaelli@worldbank.org

	 Giovanni Vecchi 
	 giovanni.vecchi@uniroma2.it
                    
     This version: May 1, 2015

----------------------------------------------------------------------------- */

	* food-deflation (based on 2009 food SPI)
	
	use $path/outputdata/wf2009.dta, clear
	sort hhid			

* -------------------------- *	
* generate implicit food SPI
* -------------------------- *
	
	* load 2009 data
	use $path/outputdata/nutrients.dta, clear
			
	merge  1:1 hhid using $path/outputdata/ca.dta, keepusing(ca_pc atollIsland)
	assert _m == 3
	drop _m
	
	/*
	
	Note: 2003 survey had 6 regions, 2009 had 8 regions.
	
	Region6 makes regions in 2009 survey comparable to those in 2009 surveys
	FAAFU, Meemu and Dahlu are part of Region 4 (Central) in 2009
	But Faafu should be recoded as Region 3 (2003) and Meemu and Dahlu as Region 4 (2003)
	(See HIES FINAL REPORT 2012 and 2002-03 Final Report
	We identified Faafu through the atollIsland var
	atollIsland= 3201|3205|3604 correspond to Faafu
	
	3201 "Feeali"
	3205 "Dharaboodhoo"
	3604 "Nilandhoo"
	
	See mdv2009_prp_ppp		 
	
	*/

	ren atollIsland atoll
	
	* generate a 6-region variable consistent with regions in 2003
	gen byte region6 = .
	replace region6=0 if region==8  /*Male*/
	replace region6=1 if region==1 
	replace region6=2 if region==2 
	replace region6=3 if region==3 & (atoll!="3201" & atoll!="3205" & atoll!="3604")
	replace region6=4 if (region==4 |region==5) | (atoll=="3201" | atoll=="3205" | atoll=="3604")
	replace region6=5 if (region==6| region==7)
	
	# delimit;
	la def region6
	0 "Male (capital)"
	1 "North"
	2 "Central North"
	3 "Central"
	4 "Central South"
	5 "South", modify;
	label val region6 region6;
	# delimit cr
	
	* Estimate calorie unit cost
	gen ukcal = monthlyCost/(kcalpc*hhsize_off*(365/12))
	
	* choice of the reference group
	* Six regions
	gen ukcal_ref6 = . 	
	forvalue r=0/5 {
		qui sum ukcal [aw=wght_hh] if pcedec>1 & pcedec<=5 & region6==`r', d
		replace ukcal_ref6=r(p50) if region6==`r'
	}
	label var ukcal_ref6 "cost of one calorie by 6 regions (ref. group = deciles 2-5)"

	gen zf6 = energy_req*ukcal_ref6*(365/12) 
	label var zf6 "regional food poverty lines (Rf/person/month)"

	tabstat ukcal_ref6, s(median) by(region6) format(%9.5f)
	tabstat zf6, s(median) by(region6) format(%9.1f)
	
	* generate implicit food SPI

	preserve
		collapse zf6, by(region6)
		format zf6 %9.1f
		l
		qui su zf6
		local meanzf = r(mean)
	restore
	
	gen spi6 = . 	
	forvalue r=0/5 {
		replace spi6 = 100*(zf6/`meanzf') if region6==`r'
	}	
	label var spi6 "implicit food spatial price index (maldives = 100)"
	

	tabstat spi6, s(median) by(region6) format(%9.1f)
	
	* generate national food poverty line
	gen zfood = `meanzf'
	label var zfood "national food poverty line (Rf/person/month)" 	
	
	collapse zf6 spi6 (firstnm) zfood, by(region6)
	
	l, noo sep(0)
	
	l region6 zf6 spi6, noo sep(0)
	
	save $path/outputdata/spi6.dta, replace

exit
