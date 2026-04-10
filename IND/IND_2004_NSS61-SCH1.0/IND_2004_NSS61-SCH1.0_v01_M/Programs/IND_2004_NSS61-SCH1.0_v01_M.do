/*------------------------------------------------------------------------------
					GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   		BGD_2005_HIES_v01_M.do				   </_Program name_>
<_Application_>    		STATA 17.0							     <_Application_>
<_Author(s)_>      		acastillocastill@worldbank.org	          </_Author(s)_>
<_Author(s)_>      		tornarolli@gmail.com	          		  </_Author(s)_>
<_Date created_>   		05-25-2021	                           </_Date created_>
<_Date modified>   		08-09 2023	                          </_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        		BGD											</_Country_>
<_Survey Title_>   		HIES								   </_Survey Title_>
<_Survey Year_>    		2005									</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:					08-15-2023
File:					BGD_2005_HIES_v01_M.do
- First version
</_Version Control_>
------------------------------------------------------------------------------*/

*<_Program setup_>
clear all
set more off

global cpiver       	"10"
local code         	"IND"
local year         	"2004"
*</_Program setup_>

	
*<_Datalibweb request_>
exit 

*<_Save data file_>
compress
save "${output}/`yearfolder'_M.dta", replace
*</_Save data file_>
