/*****************************************************************************************************
******************************************************************************************************
**                                                                                                  **
**                                   SOUTH ASIA MICRO DATABASE                                      **
**                                                                                                  **
** COUNTRY			PAKISTAN
** COUNTRY ISO CODE	PAK
** YEAR				2010
** SURVEY NAME		PAKISTAN INTEGRATED HOUSEHOLD SURVEY (PIHS)
** SURVEY AGENCY	PAKISTAN FEDERAL BUREAU OF STATISTICS
** RESPONSIBLE		Adriana Castillo Castillo
** Modified by		Adriana Castillo Castillo
** Date:			12/20/2021
**                                                                                                  **
******************************************************************************************************
*****************************************************************************************************/

/*****************************************************************************************************
*                                                                                                    *
                                   INITIAL COMMANDS
*                                                                                                    *
*****************************************************************************************************/

** INITIAL COMMANDS
	cap log close 
	clear
	set more off
	set mem 800m
		
** DIRECTORY
	global rootdatalib "P:\SARMD\SARDATABANK\SAR_DATABANK"
	local v "6"
	local input      "$rootdatalib\PAK\PAK_2010_HIES\PAK_2010_HIES_v01_M"
	local output     "$rootdatalib\PAK\PAK_2010_HIES\PAK_2010_HIES_v01_M_v0`v'_A_SARMD"
	
	
** Input databases 
	datalibweb, country(PAK) year(2010) type(GMD) mod(all) clear
	drop educat* welfare* welfshprosperity cpi* icp* ppp* psu veralt subnatid*
	/*
	if _rc {
		use "${dta}\poverty_1819_v2.dta", clear 
	}
	*/
	
	preserve
	use "`output'\Data\Harmonized\PAK_2010_PSLM_v01_M_v0`v'_A_SARMD_IND.dta", clear 
	rename idh hhid
	rename idp pid 
	keep countrycode code year hhid pid psu educat* welfare* welfshprosperity cpi* ppp*       ///
	pline_nat pop_wgt veralt water_source water_original watertype_quest sanitation_source    ///
	sanitation_original toilet_acc pipedwater_acc improved* subnatid* gaul_adm*_code
	tempfile input_base
	save `input_base'
	restore 
	merge 1:1 countrycode year hhid pid using `input_base'
	
	order countrycode code year hhid pid survey vermast veralt
		
		
/*****************************************************************************************************
*                                                                                                    *
                                   NATIONAL POVERTY
*                                                                                                    *
*****************************************************************************************************/
   	
** HEADCOUNT RATIO (NATIONAL)
*<_poor_nat_>
	gen poor_nat=welfarenat<pline_nat if welfarenat!=. & pline_nat!=.
	la var poor_nat "People below Poverty Line (National)"
	la define poor_nat 0 "Not-Poor" 1 "Poor"
	la values poor_nat poor_nat
*</_poor_nat_>



/*****************************************************************************************************
*                                                                                                    *
                                   INTERNATIONAL POVERTY
*                                                                                                    *
*****************************************************************************************************/
	local year=2011
	
** USE SARMD CPI AND PPP
	
** POVERTY LINE (POVCALNET) 1.9
*<_pline_int_>
	gen pline_int_19=1.90*cpi2011_06*ppp_2011*365/12
	label variable pline_int "Poverty Line 1.9 (Povcalnet)"
*</_pline_int_>
		
*<_poor_int_>
	gen poor_int_19=welfare<pline_int_19 & welfare!=.
	la var poor_int_19 "People below Poverty Line (Povcalnet)"
	la define poor_int_19 0 "Not Poor" 1 "Poor"
	la values poor_int_19 poor_int_19
	tab poor_int_19 [aw= weight]  if !mi(poor_int_19)
*</_poor_int_>


** POVERTY LINE (POVCALNET) 3.2
*<_pline_int_>
	gen pline_int_32=3.20*cpi2011_06*ppp_2011*365/12
	label variable pline_int_32 "Poverty Line 1.9 (Povcalnet)"
*</_pline_int_>
		
*<_poor_int_>
	gen poor_int_32=welfare<pline_int_32 & welfare!=.
	la var poor_int_32 "People below Poverty Line (Povcalnet)"
	la define poor_int_32 0 "Not Poor" 1 "Poor"
	la values poor_int_32 poor_int_32
	tab poor_int_32 [aw= weight]  if !mi(poor_int_32)
*</_poor_int_>


** POVERTY LINE (POVCALNET) 5.5
*<_pline_int_>
	gen pline_int_55=5.50*cpi2011_06*ppp_2011*365/12
	label variable pline_int_55 "Poverty Line 1.9 (Povcalnet)"
*</_pline_int_>
		
*<_poor_int_>
	gen poor_int_55=welfare<pline_int_55 & welfare!=.
	la var poor_int_55 "People below Poverty Line (Povcalnet)"
	la define poor_int_55 0 "Not Poor" 1 "Poor"
	la values poor_int_55 poor_int_55
	tab poor_int_55 [aw= weight]  if !mi(poor_int_55)
*</_poor_int_>

	saveold "`output'\Data\Harmonized\PAK_2010_HIES_v01_M_v0`v'_A_SARMD_GMD.dta", replace 


