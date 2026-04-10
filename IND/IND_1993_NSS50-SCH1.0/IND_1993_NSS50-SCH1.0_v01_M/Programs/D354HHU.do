capture drop_all
capture label drop_all
set more off
set mem 300m
infix using "C:\Documents and Settings\wb316709\Desktop\Prg\D354HHU.dct"

sort hh_id
save "C:\Documents and Settings\wb316709\Desktop\NSS50_Sch1\D354HHU_town.dta", replace

clear


