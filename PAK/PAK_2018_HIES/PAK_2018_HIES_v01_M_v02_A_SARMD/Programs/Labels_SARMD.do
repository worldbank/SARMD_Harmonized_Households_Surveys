*"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
*" Program: GMD 2.0 variable and value labels - 17Dec2019.do
*" This program defines variable and value labels for all variables in GMD 2.0.
*" Optional code in Section 2 also checks if any of the required variables are 
*" not present in your your GMD file.
*" Date: December 17, 2019
*"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

*"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
*" Section 1: List of all variables in GMD 2.0
*"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    loc IND "idh idh_org idp idp_org wgt soc typehouse ownhouse sewage_toilet water_jmp toilet_orig water_orig buffalo bicycle chicken cow lamp motorcar motorcycle refrigerator sewingmachine television washingmachine soc atschool ed_mod_age everattend lphone water_orig water_jmp piped_water sar_improved_water toilet_jmp sewage_toilet sar_improved_toilet toilet_orig idh idp wgt pop_wgt industry industry_orig lb_mod_age wage industry_2  industry_orig_2 wage_2 rbirth_juris rbirth  rprevious_juris rprevious yrmove  pline_nat poor_nat welfarenat poor_int pline_int"	
    
*"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
*" Section 3: Variables labels 
*"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    cap lab var countrycode "country code"
    cap lab var year "4-digit year of survey based on IHSN standards"
    cap lab var weight "Household weight"
    cap lab var weighttype "Weight type (frequency, probability, analytical, importance)"
    cap lab var hhid "Household identifier "
    cap lab var pid "Personal identifier "
    cap la var idh "Household identifier " 
    cap la var idh_org "Household identifier in the raw data " 
    cap la var idp "Personal identifier " 
    cap la var idp_org "Personal identifier in the raw data " 
    cap la var wgt "Variables used to construct Household identifier " 
    cap la var soc "Social group" 
    cap la var typehouse "GMD ownhouse variable" 
    cap la var ownhouse "SARMD ownhouse variable" 
    cap la var sewage_toilet "Household has access to sewage toilet" 
    cap la var water_jmp "Source of drinking water-using Joint Monitoring Program categories" 
    cap la var toilet_orig "sanitation facility original" 
    cap la var water_orig "Source of Drinking Water-Original from raw file" 
    cap la var buffalo "Household has buffalo" 
    cap la var bicycle "Household has bicycle" 
    cap la var chicken "Household has chicken" 
    cap la var cow "Household has cow" 
    cap la var lamp "Household has lamp" 
    cap la var motorcar "Household has motorcar" 
    cap la var motorcycle "Household has motorcycle" 
    cap la var refrigerator "Household has refrigerator" 
    cap la var sewingmachine "Household has sewing machine" 
    cap la var television "Household has television" 
    cap la var washingmachine "Household has washing machine" 
    cap la var soc "Social group" 
    cap la var atschool "Attending school" 
    cap la var ed_mod_age "Education module application age" 
    cap la var everattend "Ever attended school" 
    cap la var lphone "Household has landphone" 
    cap la var water_orig "Source of Drinking Water-Original from raw file" 
    cap la var water_jmp "Source of drinking water-using Joint Monitoring Program categories" 
    cap la var piped_water "Household has access to piped water" 
    cap la var sar_improved_water "Improved source of drinking water-using country-specific definitions" 
    cap la var toilet_jmp "Access to sanitation facility-using Joint Monitoring Program categories" 
    cap la var sewage_toilet "Household has access to sewage toilet" 
    cap la var sar_improved_toilet "Improved type of sanitation facility-using country-specific definitions" 
    cap la var toilet_orig "Access to sanitation-Original from raw file" 
    cap la var idh "Household id" 
    cap la var idp "Individual id" 
    cap la var wgt "Household sampling weight" 
    cap la var pop_wgt "Population weight" 
    cap la var industry "1 digit industry classification" 
    cap la var industry_orig "original industry codes second job" 
    cap la var lb_mod_age "Labor module application age" 
    cap la var wage "Last wage payment" 
    cap la var industry_2 "1 digit industry classification - second job" 
    cap la var industry_orig_2 "original industry codes second job" 
    cap la var wage_2 "Last wage payment second job" 
    cap la var rbirth_juris "Region of Birth Jurisdiction" 
    cap la var rbirth "Region of Birth" 
    cap la var rprevious_juris "Region of previous residence" 
    cap la var rprevious "Region Previous Residence" 
    cap la var yrmove "Year of most recent move" 
    cap la var pline_nat "Poverty line naPoverty Line (National)" 
    cap la var poor_nat "People below Poverty Line (National)" 
    cap la var welfarenat "Welfare aggregate for national poverty" 
    cap la var poor_int "People below Poverty Line (International)" 
    cap la var pline_int "Poverty line Povcalnet" 

	
*"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
*" Section 4: Value labels 
*"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

	* Define value labels
 
	foreach var in "`${module}'" {
        cap lab val `var' `var'	
	}

*"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
*" Section 5: Clean up
*"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    sort hhid pid
    gen END_SARMD=.
    la var END_SARMD "addidional non-harmonized raw variables for reference only"
    noi di "`${module}'"
    order countrycode year hhid pid weight weighttype `${module}' END_SARMD
    