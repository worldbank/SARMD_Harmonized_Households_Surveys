**==================================================================== drop clname EAname HH6 HH7
*project:       BTN_2022_BLSS
*Author:        
*Dependencies:  SAR stats team Poverty-World Bank 
*----------------------------------------------------------------------
*Creation Date:         11/28/2022 
*Modification Date:     11/28/2022 by Joe
*====================================================================

**survey information
local code="BTN"
local year=2017
local survey="BLSS"
local vm="01"
local stata "${rootdatalib}/`code'/`code'_`year'_`survey'/`code'_`year'_`survey'_v`vm'_M/Data/Stata"
local masterf "`code'_`year'_`survey'_v`vm'_M"


****ENDEND Data prep for the harmonization ****
*save "`stata'/`masterf'.dta", replace


exit
*gracias totales*


***