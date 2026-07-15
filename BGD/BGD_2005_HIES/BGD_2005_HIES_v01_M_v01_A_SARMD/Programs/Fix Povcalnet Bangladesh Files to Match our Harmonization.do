clear all
set more off

foreach year in 2000 2005 2010{
foreach year in 2005 2010{
*foreach year in 2010{


use "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\__REGIONAL\Individual Files\BGD_`year'_HIES_v01_M_v01_A_SARMD_IND.dta" 
ren hhid idh
sort countrycode year idh idp
keep countrycode year idh idp welfare*

if year==2010{
gen sub1=substr(idp,1,length(idp)-5)
gen sub2=substr(idp,length(sub1)+1,3)
gen sub3=substr(idp,-2,2)

forval i=1/3{
destring sub`i', replace
}
drop idh idp

egen str idh=concat(sub1 sub2), punct(-)
egen str idp=concat(sub1 sub2 sub3), punct(-)
drop sub1 sub2 sub3
}
sort countrycode year idh idp

tempfile temp`year'
save `temp`year''

use "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\__REGIONAL\Individual Files\BGD_`year'_HIES_v01_M_v02_A_SARMD_IND.dta" 

sort countrycode year idh idp
drop welfare*

merge 1:1 idh idp using `temp`year''
drop if _merge!=3

* GENERATE MISSING VARIABLES

cap gen landphone=.
cap gen cellphone=.
cap gen computer=.
cap gen internet=.
cap gen unempldur_l=.
cap gen unempldur_u=.
cap gen firmsize_l=.
cap gen firmsize_u=.
cap gen contract=.
cap gen healthins=.
cap gen socialsec=.
cap gen union=.
cap gen welfarenom=.
cap gen welfaredef=.
cap gen welfareother=.
cap gen welfareothertype=.

** KEEP VARIABLES - ALL

	keep countrycode year idh idp wgt strata psu vermast veralt urban int_month int_year region ///
	     subnatid1 subnatid2 subnatid3 ownhouse water electricity toilet landphone cellphone ///
	     computer internet hsize relationharm relationcs male age soc marital ed_mod_age everattend ///
	     atschool electricity literacy educy educat4 educat5 educat7 lb_mod_age lstatus empstat njobs ///
	     ocusec nlfreason unempldur_l unempldur_u industry occup firmsize_l firmsize_u whours wage ///
		 unitwage contract healthins socialsec union pline_nat pline_int poor_nat poor_int spdef cpi ppp ///
		 cpiperiod welfare welfarenom welfaredef welfshprosperity welfareother welfaretype welfareothertype

** ORDER VARIABLES

	order countrycode year idh idp wgt strata psu vermast veralt urban int_month int_year region ///
	      subnatid1 subnatid2 subnatid3 ownhouse water electricity toilet landphone cellphone ///
	      computer internet hsize relationharm relationcs male age soc marital ed_mod_age everattend ///
	      atschool electricity literacy educy educat4 educat5 educat7 lb_mod_age lstatus empstat njobs ///
	      ocusec nlfreason unempldur_l unempldur_u industry occup firmsize_l firmsize_u whours wage ///
		 unitwage contract healthins socialsec union pline_nat pline_int poor_nat poor_int spdef cpi ppp ///
		 cpiperiod welfare welfarenom welfaredef welfshprosperity welfareother welfaretype welfareothertype
	
	compress

** DELETE MISSING VARIABLES

	local keep ""
	qui levelsof countrycode, local(cty)
	foreach var of varlist urban - welfareother {
	qui sum `var'
	scalar sclrc = r(mean)
	if sclrc==. {
	     display as txt "Variable " as result "`var'" as txt " for ccode " as result `cty' as txt " contains all missing values -" as error " Variable Deleted"
	}
	else {
	     local keep `keep' `var'
	}
	}
	keep countrycode year idh idp wgt strata psu vermast veralt `keep' *type

	compress

	save "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\__REGIONAL\Individual Files\BGD_`year'_HIES_v01_M_v01_A_SARMD_IND.dta", replace

}
