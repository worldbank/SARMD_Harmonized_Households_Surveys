/*------------------------------------------------------------------------------
  GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   	IND_2011_NSS-SCH2_v02_M_v01_A_GMD.do	   </_Program name_>
<_Application_>    	STATA 18.0									 <_Application_>
<_Author(s)_>      	Leo Tornarolli <tornarolli@gmail.com>		  </_Author(s)_>
<_Author(s)_>      	Kelly Montoya <kmontoyamunoz@worldbank.org>   </_Author(s)_>
<_Date created_>   	02-2025									   </_Date created_>
<_Date modified>   	February 2025						      </_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        	IND											    </_Country_>
<_Survey Title_>   	NSS-SCH2								       </_Survey Title_>
<_Survey Year_>    	2011										</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:				02-2025
File:				IND_2011_NSS-SCH2_v02_M_v01_A_GMD.do
First version
</_Version Control_>
------------------------------------------------------------------------------*/

version 18.0

* Previously harmonized GMD data
	use "P:\SARMD\SARDATABANK\WORKINGDATA\IND\IND_2011_NSS-SCH2\IND_2011_NSS-SCH2_v01_M_v01_A_SARMD\Data\Harmonized\IND_2011_NSS-SCH2_v01_M_v01_A_SARMD_GMD.dta", clear

	tostring hhid, replace

* New welfare vectors
	merge m:1 hhid using "P:\SARMD\SARDATABANK\WORKINGDATA\IND\IND_2011_NSS-SCH2\IND_2011_NSS-SCH2_v02_M\Data\Stata\IND_PRIMUS_2011-12.dta", keepusing(welfarenom_final welfaredef_final)
	drop _m

* Replace version
	replace vermast = "02"
	replace veralt = "01"

* Annualize vectors
	cap drop welfare welfarenom welfaredef
	cap ren *_final *
	clonevar welfare = welfaredef

	for any welfare welfaredef welfarenom welfareother: replace X = X * 12

* New income quintiles
	cap drop quintile_cons_aggregate
	_ebin welfare [aw=weight], gen(quintile_cons_aggregate) nq(5) 

* Survey IDs
	cap     clonevar code = countrycode
	replace survey = "NSS-SCH2"

* Spatial deflators
	gen spdef = welfarenom / welfaredef

	preserve
	collapse rdef=spdef [aw=weight], by(subnatid1 urban)
	tempfile rdef
	save `rdef'
	restore

	merge m:1 subnatid1 urban using `rdef', nogen

* Weight variables
	clonevar weight_h = weight
	clonevar weight_p = weight

* Final CPIs
	cap drop cpi2021
	cap drop cpi2017

	g cpi2017 = 0.713696
	g cpi2021 = 0.590538032

* Labels
	#delimit ;
	labvars
	countrycode			"WDI three letter country codes"
	year				"4 digit year of the survey"
	hhid				"Household ID"
	pid					"Individual identifier"
	welfare				"Welfare aggregate used for estimating international poverty (provided to PovcalN"
	subnatid1			"Subnational ID - highest level"
	subnatid2			"Subnational ID - second highest level"
	subnatid3			"Subnational ID - third highest level"
	subnatidsurvey		"Survey representation of geographical units"
	gaul_adm1_code		"GAUL code for admin1 level"
	gaul_adm2_code		"GAUL code for admin2 level"
	welfarenom			"Welfare aggregate in nominal terms"
	welfareother		"Welfare aggregate if different welfare type is used from welfare, welfarenom, we"
	welfareothertype	"Type of welfare measure (income, consumption or expenditure) for welfareother"
	welfaredef			"Welfare aggregate spatially deflated"
	weight				"Poverty specific weights"
	age					"Age of individual (continuous)"
	male				"Sex of household member (male=1)"
	urban				"Urban (1) or rural (0)"
	hsize				"Household size",
	alternate;
	#delimit cr

* Save New data

	save "P:\SARMD\SARDATABANK\WORKINGDATA\IND\IND_2011_NSS-SCH2\IND_2011_NSS-SCH2_v02_M_v01_A_SARMD\Data\Harmonized\IND_2011_NSS-SCH2_v02_M_v01_A_GMD.dta", replace


* Poverty and inequality
	gen welfare_ppp=(1/365)*welfare/cpi2021/icp2021

	for any 3 4.2 8.3: noi: apoverty welfare_ppp [w = weight], line(X) all
	ainequal welfare_ppp [w = weight]

	gen hhwgt = weight_p * hsize

	for any 3 4.2 8.3: noi: apoverty welfare_ppp [aw = hhwgt] if relationharm == 1, line(X) all
	ainequal welfare_ppp [aw = hhwgt] if relationharm == 1