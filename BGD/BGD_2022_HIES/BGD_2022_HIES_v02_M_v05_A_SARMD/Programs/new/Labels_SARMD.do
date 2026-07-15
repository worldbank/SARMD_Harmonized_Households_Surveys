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

*    loc IND "hhid hhid_orig pid pid_orig weight soc ownhouse sewage_toilet water_jmp sanitation_original water_original buffalo bcycle chicken cow lamp car mcycle fridge sewmach tv washmach soc school ed_mod_age everattend landphone water_original water_jmp piped_water imp_wat_rec toilet_jmp sewage_toilet imp_san_rec sanitation_original hhid pid weight pop_wgt industrycat10 industry_orig minlaborage wage industrycat10_2  industry_orig_2 wage_2 rbirth_juris rbirth  rprevious_juris rprevious yrmove  pline_nat poor_nat welfarenat  "
	
	loc IND "hhid_orig pid pid_orig weight soc ownhouse sewage_toilet water_jmp sanitation_original water_original sanitation_source buffalo bcycle chicken cow lamp car mcycle fridge sewmach tv washmach soc school ed_mod_age everattend landphone water_original water_jmp piped_water imp_wat_rec toilet_jmp sewage_toilet imp_san_rec sanitation_original hhid pid weight pop_wgt industrycat10 industrycat4 occup_orig industry_orig minlaborage wage industrycat10_2  industry_orig_2 wage_2 rbirth_juris rbirth  rprevious_juris rprevious yrmove  pline_nat poor_nat welfarenat  "
	
	loc IND "age school bcycle buffalo cellphone chicken code computer contract countrycode cow cpi* cpiperiod ed_mod_age educat4 educat5 educat7 educy electricity empstat empstat_year empstat_2 empstat_2_year everattend fan firmsize_l firmsize_u food_share healthins hsize hhid hhid_orig pid pid_orig shared_toilet industrycat10 industrycat4 occup_orig industrycat10_2 industrycat10_year industrycat10_2_year industry_orig industry_orig_2 industry_orig_year industry_orig_2_year int_month int_year internet lamp minlaborage literacy primarycomp landphone lstatus male marital month car mcycle nfood_share njobs nlfreason occup occup_2 occup_year ocusec ocusec_year ownhouse piped_water pline_nat poor_nat pop_wgt psu quintile_cons_aggregate radio rbirth rbirth_juris fridge relationcs relationharm rprevious rprevious_juris imp_san_rec imp_wat_rec sewage_toilet sewmach soc socialsec spdef strata subnatid1 subnatid2 subnatid3 subnatid4 subnatid1_sar subnatid2_sar subnatid3_sar subnatid4_sar survey tv toilet_jmp sanitation_original unempldur_l unempldur_u union unitwage unitwage_2 urban veralt vermast wage wage_2 washmach water_jmp water_original welfare welfaredef welfarenat welfarenom welfareother welfareothertype welfaretype welfshprosperity weight weighttype whours year yrmove" 
    
*"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
*" Section 3: Variables labels 
*"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    cap lab var countrycode "country code"
	cap lab var code "country code"
    cap lab var year "4-digit year of survey based on IHSN standards"
    cap lab var weight "Household weight"
    cap lab var weighttype "Weight type (frequency, probability, analytical, importance)"
    cap lab var hhid "Household identifier "
    cap lab var pid "Personal identifier "
	cap la var hhid_orig "Household identifier in the raw data " 
	cap la var pid_orig "Personal identifier in the raw data " 
	cap la var soc "Social group" 
	cap la var typehouse "GMD ownhouse variable" 
	cap la var ownhouse "SARMD ownhouse variable" 
	cap la var sewage_toilet "Household has access to sewage toilet" 
	cap la var water_jmp "Source of drinking water-using Joint Monitoring Program categories" 
	cap la var sanitation_original "sanitation facility original" 
	cap la var water_original "Source of Drinking Water-Original from raw file" 
	cap la var buffalo "Household has buffalo" 
	cap la var bcycle "Household has bicycle" 
	cap la var chicken "Household has chicken" 
	cap la var cow "Household has cow" 
	cap la var lamp "Household has lamp" 
	cap la var car "Household has motorcar" 
	cap la var mcycle "Household has motorcycle" 
	cap la var fridge "Household has refrigerator" 
	cap la var sewmach "Household has sewing machine" 
	cap la var tv "Household has tv" 
	cap la var washmach "Household has washing machine" 
	cap la var soc "Social group" 
	cap la var school "Attending school" 
	cap la var ed_mod_age "Education module application age" 
	cap la var everattend "Ever attended school" 
	cap la var landphone "Household has landphone" 
	cap la var water_original "Source of Drinking Water-Original from raw file" 
	cap la var water_jmp "Source of drinking water-using Joint Monitoring Program categories" 
	cap la var piped_water "Household has access to piped water" 
	cap la var imp_wat_rec "Improved source of drinking water-using country-specific definitions" 
	cap la var toilet_jmp "Access to sanitation facility-using Joint Monitoring Program categories" 
	cap la var sewage_toilet "Household has access to sewage toilet" 
	cap la var imp_san_rec "Improved type of sanitation facility-using country-specific definitions" 
	cap la var sanitation_original "Access to sanitation-Original from raw file" 
	cap la var shared_toilet "Shared toilet"
	cap la var hhid "Household id" 
	cap la var pid "Individual id" 
	cap la var weight "Household sampling weight" 
	cap la var pop_wgt "Population weight" 
	cap la var industrycat10 "1 digit industry classification" 
	cap la var industry_orig "original industry codes second job" 
    cap lab var occup_orig "Original occupational classification, primary job (7-day ref period)"
	cap la var minlaborage "Labor module application age" 
	cap la var wage "Last wage payment" 
	cap la var industrycat10_2 "1 digit industry classification - second job" 
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
	cap la var age "Age of individual (continuous)" 
	cap la var cellphone "Own mobile phone (at least one)" 
	cap la var chicken "Household has chicken" 
	cap la var computer "Own Computer" 
	cap la var contract "Contract" 
	cap la var countrycode "Country code" 
	cap la var cow "Household has cow" 
	cap la var cpi "CPI" 
	cap la var cpiperiod "CPI period" 
	cap la var ed_mod_age "Education module application age" 
	cap la var educat4 "Level of education 4 categories" 
	cap la var educat5 "Level of education 5 categories" 
	cap la var educat7 "Level of education 7 categories" 
	cap la var educy "Years of education" 
	cap la var electricity "Access to electricity" 
	cap la var empstat "Type of employment" 
	cap la var empstat_year "Type of employment - last 12 months" 
	cap la var empstat_2 "Employment status - second job" 
	cap la var empstat_2_year "Employment status - second job - last 12 months" 
	cap la var everattend "Ever attended school" 
	cap la var fan "Household has fan" 
	cap la var firmsize_l "Firm size (lower bracket)" 
	cap la var firmsize_u "Firm size (upper bracket)" 
	cap la var healthins "Health insurance" 
	cap la var hsize "Household size" 
	*cap la var hhid "Household identifier " 
	cap la var hhid_orig "Household identifier in the raw data " 
	cap la var pid "Personal identifier " 
	cap la var pid_orig "Personal identifier in the raw data " 
	cap la var industrycat10 "1 digit industry classification - main job" 
    cap lab def industrycat4 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other", replace
	cap la var industrycat10_2 "1 digit industry classification - second job" 
	cap la var industrycat10_year "1 digit industry classification - main job - last 12 months" 
	cap la var industrycat10_2_year "1 digit industry classification - second job - last 12 months" 
	cap la var industry_orig "original industry codes - main job" 
	cap la var industry_orig_2 "original industry codes - second job" 
	cap la var industry_orig_year "original industry codes - main job - last 12 months" 
	cap la var industry_orig_2_year "original industry codes - second job - last 12 months" 
	cap la var int_month "Interview Month" 
	cap la var int_year "Interview Year" 
	cap la var internet "Internet connection" 
	cap la var lamp "Household has lamp" 
	cap la var minlaborage "Labor module application age" 
	cap la var literacy "Individual can read and write" 
	cap lab var primarycomp "Primary school completion"
	cap la var landphone "Household has landphone" 
	cap la var lstatus "Labor Force Status" 
	cap la var male "Sex of household member (male=1)" 
	cap la var marital "Marital status" 
	cap la var car "Household has motorcar" 
	cap la var mcycle "Household has motorcycle" 
	cap la var njobs "Number of total jobs" 
	cap la var nlfreason "Reason not in the labor force" 
	cap la var occup "1 digit occupational classification - main job" 
	cap la var occup_2 "1 digit occupational classification - second job" 
	cap la var occup_year "1 digit occupational classification - main job - last 12 months" 
	cap la var ocusec "Sector of activity" 
	cap la var ocusec_year "Sector of activity - last 12 months" 
	cap la var ownhouse "SARMD ownhouse variable" 
	cap la var piped_water "Household has access to piped water" 
	cap la var pline_int "Poverty line Povcalnet" 
	cap la var pline_nat "Poverty line naPoverty Line (National)" 
	cap la var poor_int "People below Poverty Line (International)" 
	cap la var poor_nat "People below Poverty Line (National)" 
	cap la var pop_wgt "Population weight" 
	cap la var psu "Primary sampling units" 
	cap la var radio "Household has radio" 
	cap la var rbirth "Region of Birth" 
	cap la var rbirth_juris "Region of Birth Jurisdiction" 
	cap la var fridge "Household has refrigerator" 
	cap la var relationcs "Relationship to head of household country/region specific" 
	cap la var relationharm "Relationship to head of household harmonized across all regions" 
	cap la var rprevious "Region Previous Residence" 
	cap la var rprevious_juris "Region of previous residence" 
	cap la var imp_san_rec "Improved type of sanitation facility-using country-specific definitions" 
	cap la var imp_wat_rec "Improved source of drinking water-using country-specific definitions" 
	cap la var sewage_toilet "Household has access to sewage toilet" 
	cap la var sewmach "Household has sewing machine" 
	cap la var soc "Social group" 
	cap la var socialsec "Social security" 
	cap la var spdef "Spatial deflator" 
	cap la var strata "Strata" 
	cap la var subnatid1 "Subnational ID - highest level" 
	cap la var subnatid2 "Subnational ID - second highest level" 
	cap la var subnatid3 "Subnational ID - third highest level" 
	cap la var subnatid4 "Subnational ID - fourth highest level" 	
	cap la var subnatid1_sar "Subnational ID - highest level - SAR definition" 
	cap la var subnatid2_sar "Subnational ID - second highest level - SAR definition" 
	cap la var subnatid3_sar "Subnational ID - third highest level - SAR definition" 
	cap la var subnatid4_sar "Subnational ID - fourth highest level - SAR definition" 	
	cap la var survey "Survey name" 
	cap la var tv "Household has television" 
	cap la var toilet_jmp "Access to sanitation facility-using Joint Monitoring Program categories" 
	cap la var sanitation_original "Access to sanitation-Original from raw file" 
	cap la var typehouse "GMD ownhouse variable" 
	cap la var unempldur_l "Unemployment duration (months) lower bracket" 
	cap la var unempldur_u "Unemployment duration (months) upper bracket" 
	cap la var union "Union membership" 
	cap la var unitwage "Last wages time unit - main job" 
	cap la var unitwage_2 "Last wages time unit - second job" 
	cap la var urban "uban/rural" 
	cap la var veralt "Harmonization version" 
	cap la var vermast "Master version" 
	cap la var wage "Last wage payment" 
	cap la var wage_2 "Last wage payment second job" 
	cap la var washmach "Household has washing machine" 
	cap la var water_jmp "Source of drinking water-using Joint Monitoring Program categories" 
	cap la var water_original "Source of Drinking Water-Original from raw file" 
	cap la var welfare "Welfare aggregate used for estimating international poverty (provided to PovcalNet)" 
	cap la var welfaredef "Welfare aggregate spatially deflated" 
	cap la var welfarenat "Welfare aggregate for national poverty" 
	cap la var welfarenom "Welfare aggregate in nominal terms" 
	cap la var welfareother "Welfare aggregate if different welfare type is used from welfare, welfarenom, welfaredef" 
	cap la var welfareothertype "Type of welfare measure (income, consumption or expenditure) for welfareother" 
	cap la var welfaretype "Type of welfare measure (income, consumption or expenditure) for welfare, welfarenom, welfaredef" 
	cap la var welfshprosperity "Welfare aggregate for shared prosperity (if different from poverty)" 
	cap la var whours "Hours of work in last week" 
	cap la var year "Year" 
	cap la var yrmove "Year of most recent move"
	cap la var quintile_cons_aggregate "Quintile of welfarenat"
	cap la var code "country code" 
	cap la var improved_water "Improved source of drinking water-using country-specific definitions" 
	cap la var improved_sanitation "Improved type of sanitation facility-using country-specific definitions" 
    cap lab var water_source "Sources of drinking water (14 categories)"
    cap lab var sanitation_source "Main sanitation facility "
	cap la var food_share "Food share" 
	cap la var nfood_share "Non-food share" 
	
	notes: the following variables are required for primus upload 
	cap lab var welfshprtype "Welfare type for shared prosperity indicator (income, consumption or expenditure)"
	cap lab var converfactor "Conversion factor"
	cap lab var agecat "Age of individual (categorical)"
	notes: end of the notes 


	
*"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
*" Section 4: Value labels 
*"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

	* Define value labels
	cap lab def welfarenat 1 "Yes"  0 "No", replace
	cap lab def water_jmp 1 "Piped into dwelling" 2 "Piped into compound, yard or plot" 3 "Public tap / standpipe" 4 "Tubewell, Borehole"  5 "Protected well" 6 "Unprotected well" 7 "Protected spring" 8 "Unprotected spring" 9 "Rain water" 10 "Tanker-truck or other vendor" 11 "Cart with small tank / drum" 12 "Surface water (river, stream, dam, lake, pond)" 13 "Bottled water"  14 "Other" 15 "Other improved", replace
	cap lab def washmach 1 "Yes"  0 "No", replace
	cap lab def urban 0 "Rural" 1 "Urban" , replace
	cap lab def unitwage_2 1 "Daily"  2 "Weekly"  3 "Every two weeks"  4 "Every two months" 5 "Monthly"  6 "Quarterly" 7 "Every six months" 8 "Annually" 9 "Hourly"  10 "Other", replace
	cap lab def unitwage 1  "Daily"  2 "Weekly"  3 "Every two weeks"  4 "Every two months" 5 "Monthly"  6 "Quarterly" 7 "Every six months" 8 "Annually" 9 "Hourly"  10 "Other", replace
	cap lab def union 1 "Yes"  0 "No", replace
	cap lab def typehouse 1 "Ownership/secure rights"  2 "Renting" 3 "Provided for free" 4 "Without permission", replace
	cap lab def toilet_jmp 1 "Flush to piped sewer  system" 2 "Flush to septic tank" 3 "Flush to pit latrine" 4 "Flush to somewhere else" 5 "Flush, don't know where" 6 "Ventilated improved pit latrine" 7 "Pit latrine with slab" 8 "Pit latrine without slab/open pit" 9 "Composting toilet" 10 "Bucket toilet" 11 "Hanging toilet/hanging latrine" 12 "No facility/bush/field" 13 "Other", replace
	cap lab def tv 1 "Yes"  0 "No", replace
	cap lab def socialsec 1 "Yes"  0 "No", replace
	cap lab def sewmach 1 "Yes"  0 "No", replace
	cap lab def sewage_toilet 1 "Yes"  0 "No", replace
	cap lab def imp_wat_rec 1 "Yes"  0 "No", replace
	cap lab def imp_san_rec 1 "Yes"  0 "No", replace
	cap lab def shared_toilet  1 "Yes"  0 "No", replace
	cap lab def relationharm 1 "Head" 2 "Spouse" 3 "Child" 4 "Parents" 5 "Other relative" 6 "Non-relative", replace
	cap lab def fridge 1 "Yes"  0 "No", replace
	cap lab def radio 1 "Yes"  0 "No", replace
	cap lab def piped_water 1 "Yes"  0 "No", replace
	cap lab def ownhouse 1 "Ownership/secure rights"  2 "Renting" 3 "Provided for free" 4 "Without permission", replace
	cap lab def ocusec 1 "Public sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish", replace
	cap lab def occup 1 "Managers"  2  "Professionals"  3  "Technicians and associate professionals"  4  "Clerical support workers"  5 "Service and sales workers" 6 "Skilled agricultural, forestry and fishery workers" 7  "Craft and related trades workers" 8  "Plant and machine operators, and assemblers" 9 "Elementary occupations" 10  "Armed forces occupations" 99 "Other/unspecified", replace
	cap lab def nlfreason 1 "Student"  2 "Housewife"  3 "Retired"  4 "Disabled" 5"Others", replace
	cap lab def mcycle 1 "Yes"  0 "No", replace
	cap lab def car 1 "Yes"  0 "No", replace
	cap lab def marital 1 "Married"  2 "Never married"  3 "Living together" 4 "Divorced/Separated"  5 "Widowed", replace
	cap lab def male 1  " Male"  0  "Female", replace
	cap lab def lstatus 1 "Employed"  2 "Unemployed"  3 "Not in labor force", replace
	cap lab def landphone 1 "Yes"  0 "No", replace
	cap lab def literacy 1 "Yes"  0 "No", replace
    cap lab def primarycomp 1 "Yes"  0 "No", replace
	cap lab def lamp 1 "Yes"  0 "No", replace
	cap lab def internet 1 "Yes"  0 "No", replace
	cap lab def int_month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December", replace
	cap lab def healthins 1 "Yes"  0 "No", replace
	cap lab def fan 1 "Yes"  0 "No", replace
	cap lab def everattend 1 "Yes"  0 "No", replace
	cap lab def empstat_2_year 1 "Paid Employee"  2 "Non-Paid Employee"  3 "Employer"  4 "Self-employed" 5 "Other, workers not classifiable by status", replace
	cap lab def empstat_2 1 "Paid Employee"  2 "Non-Paid Employee"  3 "Employer"  4 "Self-employed" 5 "Other, workers not classifiable by status", replace
	cap lab def empstat 1 "Paid Employee"  2 "Non-Paid Employee"  3 "Employer"  4 "Self-employed" 5 "Other, workers not classifiable by status", replace
	cap lab def electricity 1 "Yes"  0 "No", replace
	cap lab def educat7 1 "No education"  2 "Primary incomplete"  3 "Primary complete"  4 "Secondary incomplete"  5 "Secondary complete"  6 "Post secondary but not university"  7 "University", replace
	cap lab def educat5 1 "No education"  2 "Primary incomplete"  3 "Primary complete but Secondary incomplete" 4 "Secondary complete"  5 "Tertiary (completed or incomplete)", replace
	cap lab def educat4 1 "No education"  2 "Primary (complete or incomplete)"  3 "Secondary (complete or incomplete)" 4 "Tertiary (complete or incomplete)", replace
	cap lab def cow 1 "Yes"  0 "No", replace
	cap lab def contract 1 "Yes"  0 "No", replace
	cap lab def computer 1 "Yes"  0 "No", replace
	cap lab def chicken 1 "Yes"  0 "No", replace
	cap lab def cellphone 1 "Yes"  0 "No", replace
	cap lab def buffalo 1 "Yes"  0 "No", replace
	cap lab def bcycle 1 "Yes"  0 "No", replace
	cap lab def school 1 "Yes"  0 "No", replace
	cap lab def improved_water 1 "Yes"  0 "No", replace
	cap lab def improved_sanitation 1 "Yes"  0 "No", replace
    cap lab def water_source 1 "Piped water into dwelling"  2 "Piped water to yard/plot"  3 "Public tap or standpipe" 4 "Tube well or borehole"  5 "Protected dug well"  6 "Protected spring"  7 "Bottled water" 8 "Rainwater"  9 "Unprotected spring"  10 "Unprotected dug well"  11 "Cart with small tank/drum" 12 "Tanker-truck"  13 "Surface water"  14 "Other", replace
    cap lab def sanitation_source 1 "A flush toilet"  2 "A piped sewer system"  3 "A septic tank"  4 "Pit latrine" 5 "Ventilated improved pit latrine (VIP)"  6 "Pit latrine with slab"  7 "Composting toilet" 8 "Special case"  9 "A flush/pour flush to elsewhere"  10 "A pit latrine without slab" 11 "Bucket"  12 "Hanging toilet or hanging latrine"  13 "No facilities or bush or field"  14 "Other", replace
	cap lab def relationcs 1 "Head of the household" 2 "Wife / Husband" 3 "Son / Daughter" 4 "Parents of head of the household/ spouse" 5 "Other Relative" 6 "Domestic Servant/ Driver/ Watcher" 7 "Boarder" 9 "Other"

	local vars school bcycle buffalo cellphone chicken computer contract cow educat4 educat5 educat7 electricity empstat empstat_2 empstat_2_year everattend fan healthins shared_toilet int_month internet lamp literacy primarycomp landphone lstatus male marital car mcycle nlfreason occup ocusec ownhouse piped_water water_source sanitation_source quintile_cons_aggregate radio fridge relationharm imp_san_rec imp_wat_rec sewage_toilet sewmach socialsec tv toilet_jmp union  unitwage unitwage_2 urban washmach water_jmp

	foreach var of local vars {
        cap lab val `var' `var'	
	}

	

	
*"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
*" Section 5: Clean up
*"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    sort hhid pid
	if year<2016 {
		keep ${keepextra} age school bcycle buffalo cellphone chicken code computer contract countrycode cow cpi* ppp* ed_mod_age educat4 educat5 educat7 educy electricity empstat empstat_year empstat_2 empstat_2_year everattend fan firmsize_l firmsize_u food_share healthins hsize hhid hhid_orig pid pid_orig shared_toilet industrycat10 industrycat4 occup_orig industrycat10_2 industrycat10_year industrycat10_2_year industry_orig industry_orig_2 industry_orig_year industry_orig_2_year int_month int_year internet lamp minlaborage literacy primarycomp landphone lstatus male marital month car mcycle nfood_share njobs nlfreason occup occup_2 occup_year ocusec ocusec_year ownhouse piped_water sanitation_source pline_nat poor_nat pop_wgt psu quintile_cons_aggregate radio rbirth rbirth_juris fridge relationcs relationharm rprevious rprevious_juris imp_san_rec imp_wat_rec sewage_toilet sewmach soc socialsec spdef strata subnatid1 subnatid2 subnatid3 subnatid4 subnatid1_sar subnatid2_sar subnatid3_sar subnatid4_sar survey tv toilet_jmp sanitation_original water_source unempldur_l unempldur_u union unitwage unitwage_2 urban veralt vermast wage wage_2 washmach water_jmp water_original welfare welfaredef welfarenat welfarenom welfareother welfareothertype welfaretype welfshprosperity weight weighttype whours year yrmove hhid pid //welfshprtype converfactor agecat 
	}
	else if year>=2016 {
		keep ${keepextra} age school bcycle buffalo cellphone chicken code computer contract countrycode cow cpi* ppp* ed_mod_age educat4 educat5 educat7 educy electricity empstat empstat_year empstat_2 empstat_2_year everattend fan firmsize_l firmsize_u food_share healthins hsize hhid hhid_orig pid pid_orig shared_toilet industrycat10 industrycat4 occup_orig industrycat10_2 industrycat10_year industrycat10_2_year industry_orig industry_orig_2 industry_orig_year industry_orig_2_year int_month int_year internet lamp minlaborage literacy primarycomp landphone lstatus male marital month car mcycle nfood_share njobs nlfreason occup occup_2 occup_year ocusec ocusec_year ownhouse piped_water sanitation_source pline_nat poor_nat pop_wgt psu quintile_cons_aggregate radio rbirth rbirth_juris fridge relationcs relationharm rprevious rprevious_juris imp_san_rec imp_wat_rec sewage_toilet sewmach soc socialsec spdef strata subnatid1 subnatid2 subnatid3 subnatid4 subnatid1_sar subnatid2_sar subnatid3_sar subnatid4_sar survey tv toilet_jmp sanitation_original water_source unempldur_l unempldur_u union unitwage unitwage_2 urban veralt vermast wage wage_2 washmach water_jmp water_original welfare welfaredef welfarenat welfarenom welfareother welfareothertype welfaretype welfshprosperity weight weighttype whours year yrmove hhid pid
	}
	
    noi di "`${module}'"
    order countrycode year hhid pid weight welfaretype  `IND'
	glo keepextra ""
*<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>*
