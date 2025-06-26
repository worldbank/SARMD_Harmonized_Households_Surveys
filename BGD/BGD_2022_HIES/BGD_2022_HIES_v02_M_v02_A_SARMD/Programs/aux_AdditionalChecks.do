
/*****************************************************************************************************
******************************************************************************************************
**                                                                                                  **
**                                                                                                  **
**                                                                                                  **
** RESPONSIBLE		Adriana Castillo Castillo
** MODFIED BY		
** Date				02/15/2024

**
******************************************************************************************************
*****************************************************************************************************/

*==============================================*
** Number of unique hhid and pid combinations **
*==============================================*
	cap    clonevar id_household = idh 
	cap    clonevar id_household = hhid 
	cap    clonevar id_person    = idp
	cap    clonevar id_person    = pid 

	cap    drop unique_household_person
	unique id_household id_person, by(year) gen(unique_household_person)
	sum    unique_household_person
	local  number_obs_unique =r(mean)
	di     `number_obs_unique'
	describe 
	local  number_obs_d =r(N)
	di     `number_obs_d'
	
	if `number_obs_unique'==`number_obs_d' {
		di "NOTHING TO DO"
	}
	else if `number_obs_unique'!=`number_obs_d' {
		di as error "STOP: The # of unique hhid and pid combination does not correspond to the number of observations" 
		di as error "Please check and solve this error before saving the final database."
		stop 
	}
	
*==============================================*
** Check for weights (mean) **
*==============================================*
	cap     clonevar var_weight =wgt
	cap     clonevar var_weight =weight
	sum     var_weight
	global  var_weight =r(mean)
	di      ${var_weight}
	
	preserve
	datalibweb, country(${code}) year(${year}) type(GMD) survey(${survey}) module(ALL) clear
	cap         rename weight_h var_weightGMD
	sum         var_weightGMD
	glo         var_weightGMD =r(mean)
	di          ${var_weightGMD}
	restore 
	
	if "${new_primus_master_version}"=="N" {
		if ${var_weight}==${var_weightGMD} {
		}
		else if ${var_weight}!=${var_weightGMD}  {
			di as error "STOP: Weights (mean) from this new version and weights (mean) from GMD primus version do not correspond." 
			di as error "Please check and solve this error before saving the final database."
			
			di ""
			di "Weight value for GMD Primus database: " ${var_weightGMD}
			di "-----"
			di "Weight value for this new version: " ${var_weight}
			di ""
		    stop 
		}
	}
	else if  "${new_primus_master_version}"=="Y" {
		di "NOTHING TO DO"
	}
	
	
*==============================================*
** Check for weights (sd) **
*==============================================*
	cap     clonevar var_weight =wgt
	cap     clonevar var_weight =weight
	sum     var_weight
	global  var_weight =r(sd)
	di      ${var_weight}
	
	preserve
	datalibweb, country(${code}) year(${year}) type(GMD) survey(${survey}) module(ALL) clear
	cap         rename weight_h var_weightGMD
	sum         var_weightGMD
	glo         var_weightGMD =r(sd)
	di          ${var_weightGMD}
	restore 
	
	if "${new_primus_master_version}"=="N" {
		if ${var_weight}==${var_weightGMD} {
		}
		else if ${var_weight}!=${var_weightGMD}  {
			di as error "STOP: Weights (sd) from this new version and weights (sd) from GMD primus version do not correspond." 
			di as error "Please check and solve this error before saving the final database."
			
			di ""
			di "Weight value for GMD Primus database: " ${var_weightGMD}
			di "-----"
			di "Weight value for this new version: " ${var_weight}
			di ""
		    stop 
		}
	}
	else if  "${new_primus_master_version}"=="Y" {
		di "NOTHING TO DO"
	}
	
*==============================================*
** Check for weights (min) **
*==============================================*
	cap     clonevar var_weight =wgt
	cap     clonevar var_weight =weight
	sum     var_weight
	global  var_weight =r(min)
	di      ${var_weight}
	
	preserve
	datalibweb, country(${code}) year(${year}) type(GMD) survey(${survey}) module(ALL) clear
	cap         rename weight_h var_weightGMD
	sum         var_weightGMD
	glo         var_weightGMD =r(min)
	di          ${var_weightGMD}
	restore 
	
	if "${new_primus_master_version}"=="N" {
		if ${var_weight}==${var_weightGMD} {
		}
		else if ${var_weight}!=${var_weightGMD}  {
			di as error "STOP: Weights (min) from this new version and weights (min) from GMD primus version do not correspond." 
			di as error "Please check and solve this error before saving the final database."
			
			di ""
			di "Weight value for GMD Primus database: " ${var_weightGMD}
			di "-----"
			di "Weight value for this new version: " ${var_weight}
			di ""
		    stop 
		}
	}
	else if  "${new_primus_master_version}"=="Y" {
		di "NOTHING TO DO"
	}
	
	
*==============================================*
** Check for weights (max) **
*==============================================*
	cap     clonevar var_weight =wgt
	cap     clonevar var_weight =weight
	sum     var_weight
	global  var_weight =r(max)
	di      ${var_weight}
	
	preserve
	datalibweb, country(${code}) year(${year}) type(GMD) survey(${survey}) module(ALL) clear
	cap         rename weight_h var_weightGMD
	sum         var_weightGMD
	glo         var_weightGMD =r(max)
	di          ${var_weightGMD}
	restore	
	
	if "${new_primus_master_version}"=="N" {
		if ${var_weight}==${var_weightGMD} {
		}
		else if ${var_weight}!=${var_weightGMD}  {
			di as error "STOP: Weights (max) from this new version and weights (max) from GMD primus version do not correspond." 
			di as error "Please check and solve this error before saving the final database."
			
			di ""
			di "Weight value for GMD Primus database: " ${var_weightGMD}
			di "-----"
			di "Weight value for this new version: " ${var_weight}
			di ""
		    stop 
		}
	}
	else if  "${new_primus_master_version}"=="Y" {
		di "NOTHING TO DO"
	}
	
*==============================================*
** Check for welfare (mean) **
*==============================================*
	cap drop var_welfare
	clonevar var_welfare =welfare
	replace var_welfare= var_welfare *12
	sum     var_welfare
	global  var_welfare =r(mean)
	di      ${var_welfare}
	
	preserve
	datalibweb, country(${code}) year(${year}) type(GMD) survey(${survey}) module(ALL) clear
	keep        welfare year
	cap         rename welfare var_welfareGMD
	sum         var_welfareGMD
	glo         var_welfareGMD =r(mean)
	di          ${var_welfareGMD}
	tempfile    GMD   
	save        `GMD'
	restore 
	merge m:m year using `GMD'
	
	if "${new_primus_master_version}"=="N" {
		if ${var_welfare}==${var_welfareGMD} {
		}
		else if ${var_welfare}!=${var_welfareGMD}  {
			di as error "STOP: welfare (mean) from this new version and welfare (mean) from GMD primus version do not correspond. Please check and solve this error before saving the final database."
			di ""
			compare  var_welfare var_welfareGMD
		    stop 
		}
	}
	else if  "${new_primus_master_version}"=="Y" {
		di "NOTHING TO DO"
	}
	
*==============================================*
** Check for welfare (sd) **
*==============================================*
	cap drop var_welfare
	clonevar var_welfare =welfare
	replace var_welfare= var_welfare *12
	sum     var_welfare
	global  var_welfare =r(sd)
	di      ${var_welfare}
	
	preserve
	datalibweb, country(${code}) year(${year}) type(GMD) survey(${survey}) module(ALL) clear
	keep        welfare year
	cap         rename welfare var_welfareGMD
	sum         var_welfareGMD
	glo         var_welfareGMD =r(sd)
	di          ${var_welfareGMD}
	tempfile    GMD   
	save        `GMD'
	restore 
	merge m:m year using `GMD'
	
	if "${new_primus_master_version}"=="N" {
		if ${var_welfare}==${var_welfareGMD} {
		}
		else if ${var_welfare}!=${var_welfareGMD}  {
			di as error "STOP: welfare (sd) from this new version and welfare (sd) from GMD primus version do not correspond. Please check and solve this error before saving the final database."
			di ""
			compare  var_welfare var_welfareGMD
		    stop 
		}
	}
	else if  "${new_primus_master_version}"=="Y" {
		di "NOTHING TO DO"
	}

*==============================================*
** Check for welfare (max) **
*==============================================*
	cap drop var_welfare
	clonevar var_welfare =welfare
	replace var_welfare= var_welfare *12
	sum     var_welfare
	global  var_welfare =r(max)
	di      ${var_welfare}
	
	preserve
	datalibweb, country(${code}) year(${year}) type(GMD) survey(${survey}) module(ALL) clear
	keep        welfare year
	cap         rename welfare var_welfareGMD
	sum         var_welfareGMD
	glo         var_welfareGMD =r(max)
	di          ${var_welfareGMD}
	tempfile    GMD   
	save        `GMD'
	restore 
	merge m:m year using `GMD'
	
	if "${new_primus_master_version}"=="N" {
		if ${var_welfare}==${var_welfareGMD} {
		}
		else if ${var_welfare}!=${var_welfareGMD}  {
			di as error "STOP: welfare (max) from this new version and welfare (max) from GMD primus version do not correspond. Please check and solve this error before saving the final database."
			di ""
			compare  var_welfare var_welfareGMD
		    stop 
		}
	}
	else if  "${new_primus_master_version}"=="Y" {
		di "NOTHING TO DO"
	}
	
*==============================================*
** Check for welfare (min) **
*==============================================*
	cap drop var_welfare
	clonevar var_welfare =welfare
	replace var_welfare= var_welfare *12
	sum     var_welfare
	global  var_welfare =r(min)
	di      ${var_welfare}
	
	preserve
	datalibweb, country(${code}) year(${year}) type(GMD) survey(${survey}) module(ALL) clear
	keep        welfare year
	cap         rename welfare var_welfareGMD
	sum         var_welfareGMD
	glo         var_welfareGMD =r(min)
	di          ${var_welfareGMD}
	tempfile    GMD   
	save        `GMD'
	restore 
	merge m:m year using `GMD'
	
	if "${new_primus_master_version}"=="N" {
		if ${var_welfare}==${var_welfareGMD} {
		}
		else if ${var_welfare}!=${var_welfareGMD}  {
			di as error "STOP: welfare (min) from this new version and welfare (min) from GMD primus version do not correspond. Please check and solve this error before saving the final database."
			di ""
			compare  var_welfare var_welfareGMD
		    stop 
		}
	}
	else if  "${new_primus_master_version}"=="Y" {
		di "NOTHING TO DO"
	}
	
*<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>*
*<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>*	
	