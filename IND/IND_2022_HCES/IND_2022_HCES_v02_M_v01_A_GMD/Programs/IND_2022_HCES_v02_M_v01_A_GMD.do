/*------------------------------------------------------------------------------
  GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   	IND_2022_HCES_v02_M_v01_A_GMD.do	   	   </_Program name_>
<_Application_>    	STATA 18.0									 <_Application_>
<_Author(s)_>      	Leo Tornarolli <tornarolli@gmail.com>		  </_Author(s)_>
<_Author(s)_>      	Kelly Montoya <kmontoyamunoz@worldbank.org>   </_Author(s)_>
<_Date created_>   	02-2025									   </_Date created_>
<_Date modified>   	February 2025						      </_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        	IND											    </_Country_>
<_Survey Title_>   	HCES								       </_Survey Title_>
<_Survey Year_>    	2022										</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:				02-2025
File:				IND_2022_HCES_v02_M_v01_A_GMD.do
First version
</_Version Control_>
------------------------------------------------------------------------------*/

version 18.0

* Previously harmonized GMD data
	use "P:\SARMD\SARDATABANK\WORKINGDATA\IND\IND_2022_HCES\IND_2022_HCES_v01_M_v01_A_SARMD\Data\Harmonized\IND_2022_HCES_v01_M_v01_A_GMD_ALL.dta", clear

* New welfare vectors
	merge m:1 hhid using "P:\SARMD\SARDATABANK\WORKINGDATA\IND\IND_2022_HCES\IND_2022_HCES_v02_M\Data\Stata\IND_PRIMUS_2022-23.dta", keepusing(welfarenom_final welfaredef_final) keep(3) nogen

* Merge original criteria for hsize / FDQ == 1
	merge 1:1 hhid pid using "P:\SARMD\SARDATABANK\WORKINGDATA\IND\IND_2022_HCES\IND_2022_HCES_v02_M\Data\Stata\102_hcq.dta", keepusing(fdq_og_member)  keep(3) nogen
	
* Replace version
	replace vermast = "02"
	replace veralt = "01"

* Annualize vectors
	cap drop welfare welfarenom welfaredef
	cap ren *_final *
	clonevar welfare = welfaredef

	for any welfare welfaredef welfarenom welfareother: replace X = X * 12

* Identify heads no in Food
	count if fdq_og_member == "" & relationharm == 1 // 321
	gen aux = 1 if fdq_og_member == "" & relationharm == 1
	bysort hhid: egen fdq_miss_head = total(aux)
	drop aux

* Random selection criteria for the member to replace the head
	set seed 12345
	sort hhid pid
	gen random = uniform() if !inlist(relationharm,1,2) & fdq_og_member == "1"
	bysort hhid (random) : gen byte select = _n == 1 if random != .

* New FDQ // Should be 321 cases in each replace
	destring fdq_og_member, replace
	clonevar fdq_new = fdq_og_member
	
	replace fdq_new = 1 if fdq_new == . & relationharm == 1 // 321
	replace fdq_new = . if fdq_miss_head == 1 & select == 1 // 301
	
	* Note: In 20 households the only possible other member is the partner, then the partner will be excluded only for those 20 households
	
	bysort hhid: egen n_fdq_or = count(fdq_og_member)
	bysort hhid: egen n_fdq_new = count(fdq_new)
	replace fdq_new = . if fdq_miss_head == 1 & (n_fdq_new > n_fdq_or) & relationharm == 2 // 20

* Adjust welfare using new FDQ
	for any welfare welfaredef welfarenom welfareother hsize: replace X = . if fdq_new == .
	
* New income quintiles
	cap drop quintile_cons_aggregate
	_ebin welfare [aw=wgt], gen(quintile_cons_aggregate) nq(5) 

* Survey IDs
	cap     clonevar code = countrycode
	replace survey = "HCES"

* Weight variables
	ren wgt weight
	clonevar weight_h = weight
	clonevar weight_p = weight

* Spatial deflators
	cap drop spdef rdef
	gen spdef = welfarenom / welfaredef

	preserve
	collapse rdef=spdef [aw=weight], by(subnatid1 urban)
	tempfile rdef
	save `rdef'
	restore

	merge m:1 subnatid1 urban using `rdef', nogen

* Final CPI
	drop cpi2017
	drop cpi2021

	g cpi2017 = 1.3317103
	g cpi2021 = 1.1019059


* Labels and format
	format cpi* %12.0g
	
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

	save "P:\SARMD\SARDATABANK\WORKINGDATA\IND\IND_2022_HCES\IND_2022_HCES_v02_M_v01_A_SARMD\Data\Harmonized\IND_2022_HCES_v02_M_v01_A_GMD.dta", replace


* Poverty and inequality
	gen welfare_ppp=(1/365)*welfare/cpi2021/icp2021

	gen hhwgt = weight_p * hsize

	for any 3 4.2 8.3: noi: apoverty welfare_ppp [aw = weight], line(X) all
	ainequal welfare_ppp [aw = weight]

	for any 3 4.2 8.3: noi: apoverty welfare_ppp [aw = hhwgt] if relationharm == 1, line(X) all
	ainequal welfare_ppp [aw = hhwgt] if relationharm == 1
	
	for any 3 4.2 8.3: noi: apoverty welfare_ppp [aw = weight] if urban == 1, line(X) all
	ainequal welfare_ppp [aw = weight]  if urban == 1
