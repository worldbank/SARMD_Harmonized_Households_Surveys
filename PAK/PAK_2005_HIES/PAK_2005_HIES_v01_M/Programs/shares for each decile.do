*** Pakistan data **

local m_povcal = 62.00
local year= 1 /* 1 - 98/99; 2 - 01/02; 3 - 04/05; 4 - 05/06; 5 - 07/08 */
local data="F:\pakistan\PSLM 07-08\cons_all\cons_all 98-99 to 07-08 (details).dta"

set more off
use "`data'", clear
keep if year==`year' 
sum pcexp [aw=popwt]
local m_nom=r(mean)
gen x=pcexp/(`m_nom'/`m_povcal')
xtile decile=x [aw=popwt], nq(10)
gen double y=.
gen double xdecile=.
forvalues i=1(1)10 {
	sum x [aw=popwt] if decile==`i'
	replace y=r(sum)/1000 in `i'
	replace xdecile=`i' in `i'
}
egen xtotal=sum(y) 
gen double xshare=y/xtotal
br xdecile xshare
gen xpoor=(x<38)
sum xpoor [aw=popwt]
dis `m_povcal'/`m_nom'
