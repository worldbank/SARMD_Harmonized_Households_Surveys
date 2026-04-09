*==============================================================================
** NEPAL INTERNATIONAL POVERTY & INEQUALITY - NLSS IV 2022/2023 **
*==============================================================================
** SAR DATA AND STATS TEAM
** Last version: Jaime Fernandez
** Date: 3/15/24
*==============================================================================


*****
*CPI*
*****

*CPI from country team. Source: Nepal Rastra Bank
use "C:\Users\wb553773\WBG\Nethra Palaniswamy - data_shared_Jaime\cpi_monthly_long.dta", clear

keep if item=="nat"

*cpi_ref_period = 1 for field collection months (2022 - 2023)
* 0 for 2017 calendar year months
* missing all others

gen cpi_ref_period = .
replace cpi_ref_period = 1 if year1==2022 & month_num>=6
replace cpi_ref_period = 1 if year1==2023 & month_num<6

replace cpi_ref_period = 0 if year1==2017

summ CPI if cpi_ref_period==0
local av_cpi_17 = r(mean)

summ CPI if cpi_ref_period==1
local av_cpi_22_23 = r(mean)

local cpi2017 = `av_cpi_22_23' / `av_cpi_17'
di `cpi2017'

*****
*ICP*
*****

global cpiver =10
datalibweb, country(Support) year(2005) type(GMDRAW) surveyid(Support_2005_CPI_v${cpiver}_M) filename(Final_CPI_PPP_to_be_used.dta)
keep if code=="NPL" & year==2010
local icp2017 = icp2017[1]
di `icp2017'

******
*Data*
******

use "C:\Users\wb553773\WBG\Nethra Palaniswamy - data_shared_Jaime\99_NLSSIV_wgts_pcep.dta", clear
gen code = "NPL"
gen year = 2022
rename pcep welfare

global weight "ind_wt"

*Welfare in 2017 PPP
gen welfare_ppp =(1/365)*welfare/`cpi2017'/`icp2017'

***********************
*International poverty*
***********************

foreach p in 2.15 3.65 6.85 {	
	apoverty welfare_ppp [aw=$weight], line(`p') all
	return list
	local c1= el(r(b),6,1)
	di in red "Poverty - `p' - `c1'"
}

************
*Inequality*
************

ainequal welfare_ppp  [aw=$weight] 
return list
local c2 = el(r(b),1,1) 
di in red "Inequality - `c2'"
