replace block=0 if block==.

gen str2 stratum_str= string(  stratum,"%02.0f") 
gen str2 dzongkha_str= string(  dzongkha,"%02.0f") 
gen str2 town_str= string(  town,"%02.0f") 
gen str2 block_str= string(  block,"%02.0f") 
gen str2 houseno_str= string(  houseno,"%02.0f") 

gen str10 houseid_str = stratum_str+dzongkha_str+town_str+block_str+houseno_str

destring houseid_str , generate(houseid)

format houseid %10.0f

gen str2 idno_str= string(  idno,"%02.0f") 


gen str12 indid_str = houseid_str + idno_str

destring indid_str , generate(indid)

format pid %12.of
