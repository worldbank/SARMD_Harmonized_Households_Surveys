/* -----------------------------------------------------------------------------

     Poverty Trend in Maldives
          
     CONTACT: 
	 
	 Silvia Redaelli
	 sredaelli@worldbank.org
	 
	 Giovanni Vecchi 
	 giovanni.vecchi@uniroma2.it
                    
     MASTER FILE
     
     This version: May 1, 2015

----------------------------------------------------------------------------- */


	*** Load data on household expenditure (A5r-Expenditures-by-CPC)
	use $path/inputdata/A5r-Expenditures-by-CPC.dta, clear

	rename hhserial hhid
	label var hhid "household identifier"
	
	* CPC code is currently a string variable
	* must become numeric and receive value labels
	
	* Airfare expenditure (whether educational, hajj, leisure or medical travels) was not numeric.
	* Replacements follow so as to be able to transform cpc7 from string to numeric variable
	
	replace cpc7="6611001" if cpc7=="66110E"
	replace cpc7="6611002" if cpc7=="66110H"
	replace cpc7="6611003" if cpc7=="66110L"
	replace cpc7="6611004" if cpc7=="66110M"
	
	destring cpc7, replace

	* define and attach cpc7 labels 
	
	# delimit;
	label def cpc7
	
	112099	"Maize (corn)"
	119099	"Other cereals"
	121001	"Potatoes"
	122002	"Dhal, red, yellow"
	122099	"Other Dried leguminous vegetables, shelled"
	123901	"Bitter gourd, faaga"
	123902	"Banana bud, boashi"
	123903	"Banbukeyo, bread fruit"
	123904	"Cabbage"
	123905	"Capsicum, riha mirus"
	123908	"Chichanda, gourd"
	123909	"Curry leaves, rambaa faiy"
	123910	"Cucumber"
	123911	"Bashi, eggplant, brinjal"
	123912	"Githeyo mirus, green chilly"
	123914	"Curry leaves, Hikandhi faiy"
	123916	"ku'lhafilaa faiy"
	123917	"Leeks"
	123919	"Lettuce"
	123921	"Baraboa, pumpkin"
	123922	"Copy faiy, leaf vegetable"
	123924	"Gourd, thoraa"
	123925	"Tomato"
	123926	"Fresh vegetables, mixed"
	123927	"Dhiguthiyara faiy"
	123928	"Muranga faiy"
	123999	"Other vegetables, fresh or chilled n.e.c."
	124001	"Ala, olhu, taro"
	124003	"Kattala, sweet potato"
	124004	"Beetroot"
	124005	"Carrot"
	124006	"Garlic"
	124007	"Ginger"
	124008	"Onion"
	124009	"Beans, tholhi"
	131001	"Banana, bothiraiy, fus, sampa"
	131002	"maalhoskeyo ripe, banana"
	131005	"Coconut young, kurumba"
	131006	"Coconut , Kaashi"
	131007	"mango , huiy, ripe"
	131008	"Pineapple, alanaasi"
	131009	"Gauva, feyru"
	131099	"Other Dates, figs, bananas, coconuts, brazil nuts, pineapples, avocados, m"
	132001	"lemon"
	132002	"Orange"
	133099	"Grapes, fresh"
	134101	"Water Melon, karaa"
	134901	"Apple"
	134902	"Bilamagu"
	134904	"Jambu"
	134905	"Kashikeyo, Srewpine"
	134906	"Kulhavah"
	134909	"Papaya, falho"
	134910	"Jumhooree meyva, passion fruit"
	134911	"Annaaru, pomagranade"
	134912	"Sabudheli"
	134913	"Stone apple, kunnaaru"
	134914	"Atha"
	134915	"Kalhuhuthu Meyva"
	134999	"Other fruit, fresh n.e.c."
	135001	"Raisins dried"
	136001	"Badhan, peanuts fresh or dried"
	136002	"Kanamadhu fresh or dried"
	151099	"Live plants; bulbs, tubers and roots; cuttings and slips; mushroom spawn"
	162001	"Cardamon, kaafurutholhi"
	162002	"Chillie packed, dried/ powdered"
	162004	"Clove, karanfoo"
	162005	"Coriander, kothanbir"
	162006	"Cumin seeds, dhiri"
	162007	"Dhaviggandhu, fennel seeds"
	162008	"Aseymirus, pepper"
	162009	"Reendhoo, turmeric"
	162010	"Curry powder, hawaadhu, mixed spices packed / tinned etc"
	212299	"Poultry, live"
	292001	"Eggs, chicken"
	292002	"Eggs, turtle"
	313001	"Fuel wood, in logs, in billets, in twigs, in faggots or in similar forms"
	411099	"Fish, live"
	412001	"Kalhubila mas, Skipjack tuna fresh or chilled"
	412002	"Mushimas fresh or chilled"
	412003	"Giulhu, hibaru, maniya,vella fresh or chilled"
	412004	"Boavadhila mas, cuttle fish fresh or chilled"
	1620001 "Lonu fuh, fine, salt"
	2111201 "Beef Frozen"
	2112201 "Chicken and chicken products frozen"
	2112202 "Sausage, chicken"
	2123001 "Dried Fish, hikki mas"
	2123002 "Smoked fish, valho mas"
	2123003 "Mas packets sa;ted or dried"
	2124001 "Canned fish"
	2124002 "Fried fish"
	2124003 "Fish paste, rihaakuru"
	2124099 "Other Fish, otherwise prepared or preserved; caviar"
	2125002 "Cuttle fish, bovadhila mas, frozen"
	2132099 "Vegetables provisionally preserved"
	2139001 "Baked beans canned"
	2139002 "Green peas canned"
	2139004 "Fruit preserved in vinegar"
	2139099 "Other preserved vegetables (including dried vegetables, canned vegetables"
	2140001 "Fruit juices and vegetable juices"
	2140002 "Toddy, coconut sap"
	2152099 "Jams, fruit jellies and fruit or nut puree and pastes"
	2153002 "Cashew nut, peanut, hazlenut roasted salted"
	2153003 "Dates, kadhuru"
	2154001 "Pineapple, canned"
	2154002 "Fruit cocktail, canned"
	2154099 "Other Fruit and nuts provisionally preserved"
	2165001 "Cooking oil"
	2165099 "Soya-bean, ground-nut, olive, sunflower-seed, safflower, cotton-seed, rape"
	2211001 "Processed liquid milk"
	2211003 "Flavoured milk packed"
	2291001 "Baby milk powder, enfalac, lactogen, SMA etc"
	2291002 "Baby food, milupa etc"
	2291003 "Coast milk powder, anchor, nido, etc"
	2291004 "Horlicks"
	2291005 "Milo in sold form"
	2292001 "Condensed milk, geri kiru"
	2292099 "Other Milk and cream, concentrated or containing added sugar or other swee"
	2293099 "Yoghurt and other fermented or acidified milk and cream"
	2294099 "Butter and other fats and oils derived from milk"
	2295099 "Cheddar, cheese"
	2297099 "Ice cream and other edible ice"
	2311001 "Aata flour, aata fuh"
	2312099 "Cereal flours other than of wheat or meslin"
	2315001 "Baby cereal foods, cerelac, nestum etc"
	2315002 "Corn flakes"
	2315003 "Bimbi, millet"
	2315099 "Other cereal grain products (including corn flakes)"
	2316001 "Baiy, handoo"
	2321003 "Glucose"
	2321004 "Honey, maamui"
	23310 	"Pet food"
	2342001 "Biscuits"
	2342002 "Apollo"
	2343001 "Bread"
	2343002 "Buns, round, long etc, hus banas"
	2343004 "Faaroshi, hikki banas"
	2343005 "Cake"
	2352001 "Sugar, normal"
	2365001 "Chocolate"
	2366001 "Chocolate crumpy"
	2367001 "Bubble gum, chewing gum"
	2367002 "Jelly"
	2371001 "Macaroni, spagetti uncooked"
	2371002 "Noodles uncooked"
	2371099 "Uncooked pasta, not stuffed or otherwise prepared"
	2372002 "Noodles cooked"
	2391199 "Coffee"
	2391399 "Green tea (not fermented), black tea (fermented) and partly fermented tea,"
	2391499 "Essence"
	2399299 "Soups and broths and preparations thereof"
	2399501 "Sauces tomato/chillie/garlic and kind"
	2399502 "Mustard sauce"
	2399504 "Lonu lumbo"
	2399901 "Haluvidhaa"
	2399902 "Chicken rings and kind"
	2399903 "Addu bondi"
	2399904 "Short eats, hedhikaa foni (sweet)"
	2399905 "Short eats, hedhikaa kulhi (saltish)"
	2399906 "Hedhikaa not specified"
	2399999 "Other food products n.e.c."
	24120 	"Ethyl alcohol and other spirits, denatured, of any strength"
	2441001 "Mineral water"
	2449001 "soft drinks, bottle or canned"
	2501001 "Cigarettes"
	2501002 "Bidi, traditional cigarette"
	2501003 "Dhun faiy, tobacco leaves"
	2502001 "Aracanut, foah, fenfoah, hanaakuri foah, roa foah, havaadhulee foah"
	2502002 "Supaaree packets, aracanut mixture, etc."
	2633001 "Wool, put up for retail sale"
	2635001 "Cotton sewing thread"
	26610 	"Woven fabrics of cotton, containing 85% or more by weight of cotton, weighing no"
	26840 	"Terry towelling and similar woven terry fabrics (other than narrow fabrics) of c"
	27120 	"Bed linen, table linen, toilet linen and kitchen linen"
	2713099 "Curtains (including drapes) and interior blinds; curtain or bed valances"
	2714002 "Sets of woven fabrics and yarn for making up into rugs"
	2716002 "Sails for boats"
	2718002 "Sleeping bags"
	27210 	"Carpets and other textile floor coverings, knotted"
	27912 	"Tulles and other net fabrics, except woven, knitted or crocheted fabrics; lace i"
	2799299 "rubber thread and cord, textile covered; text"
	28200 	"Wearing apparel"
	28210 	"Panty hose, tights, stockings, socks and other hosiery, knitted or crocheted"
	28221 	"Men's or boys' suits, coats, jackets, trousers, shorts and the like, knitted or"
	2822499 "Women's or girls' blouses, shirts, petticoats, panties, nightdresses, dressing g"
	2822501 "T-shirts, singlets and other vests, knitted or crocheted"
	28227 	"Babies' garments and clothing accessories, knitted or crocheted"
	2823101 "uniform"
	2823201 "Men's or boys' shirts, singlets, underpants, pyjamas, dressing gowns and similar"
	2823301 "Women's or girls' suits, coats, jackets, dresses, skirts, trousers, shorts and t"
	2823499 "Women's or girls' blouses, shirts, singlets, petticoats, panties, nightdresses,"
	28235 	"Babies' garments and clothing accessories, of textile fabric, not knitted or cro"
	2823701 "Brassieres, girdles, corsets"
	2823801 "Handkerchiefs, shawls, scarves, veils, ties, cravats, gloves and other made-up c"
	28330 	"Artificial fur and articles thereof (except headgear)"
	29130 	"Leather for ornamental purposes"
	2922004 "Luggage, handbags and the like, of leather, composition leather, plastic sheetin"
	2932099 "Footwear with outer soles and uppers of rubber or plastics, other than waterproo"
	2933099 "Footwear with uppers of leather, other than sports footwear, footwear incorporat"
	2934099 "Footwear with uppers of textile materials, other than sports footwear"
	29420 	"Other sports footwear of CPC 29420"
	29520 	"Wooden footwear, miscellaneous special footwear and other footwear n.e.c."
	3141099 "Plywood consisting solely of sheets of wood"
	3191201 "Tableware and kitchenware, of wood"
	3212901 "Other uncoated paper and paperboard; of a kind used for writing and printing"
	3214201 "Paper and paperboard, creped, crinkled, embossed or perforated n.e.c."
	3219301 "Garments of paper, etc."
	3219305 "sanitary pads, etc."
	3223099 "Printed books except dictionaries and encyclopaedias and serial installments th"
	3230099 "Newspapers, journals and periodicals, appearing at least four times a week"
	3240099 "Newspapers, journals and periodicals, appearing less than four times a week"
	32540 	"Printed pictures, designs and photographs"
	3260001 "Albums"
	3331001 "Petrol, motor gasolene"
	33330 	"White spirit"
	3334001 "Kerosene"
	3462099 "Insecticides, fungicides, disinfectants, etc. for household use"
	3511001 "Paints, varnishes, etc. for household use"
	35250 	"Cocaine, heroin, morphine"
	3526001 "Medicaments for humans"
	35290 	"Other pharmaceutical products or articles for medical or surgical purposes"
	3532101 "Toilet soaps"
	3532202 "Detergents and washing preparations"
	3532301 "roll on deodorant stick, etc."
	3532302 "calamine, lotion, etc."
	3532303 "body spray, etc."
	3532304 "baby eude cologne, etc."
	3532305 "gandu fuh dhalhu, face powder, etc."
	3532306 "facial cream, etc."
	3532309 "vaseline hair cream, etc."
	3532314 "perfume, etc."
	3532316 "shampoo, etc."
	3532318 "close-up, tooth paste, etc."
	3532320 "lip stick, etc."
	3532321 "after shave, etc."
	3532322 "shaving foam, etc."
	3532336 "Cutex"
	3532337 "Hair oil"
	3532338 "Facial Wash"
	3532399 "perfume and toilet preparations"
	3533101 "Preparations for perfuming or deodorizing rooms"
	3542004 "Glues for stationery products"
	3623001 "Rubber pipes and other such plumbing articles"
	3626002 "Clothing accessories of rubber"
	3627006 "Condoms and other hygienic articles"
	3633002 "Plastic foil, sheets, etc. not adhesive"
	3692002 "Stationery material of a width not exceeding 20 cm"
	3693002 "Bath tubs for children"
	3694002 "Watering cans"
	3719302 "Ashtrays"
	3722101 "Tableware, kitchenware, etc."
	3744001 "Portland cement, aluminous cement, slag cement and similar hydraulic cements, ex"
	38112 	"Seats, primarily with wooden frames"
	3811999 "Other seats"
	3813099 "Other wooden furniture, of a kind used in the kitchen"
	3814099 "Other furniture of the household type"
	3815099 "Mattress supports; mattresses, fitted with springs or stuffed or internally fitt"
	3824002 "Jewellery, except those acquired primarily as stores of value"
	3844002 "Other articles and equipment for sports or outdoor games (including sports glove"
	3856099 "Other toys (including toy musical instruments)"
	3857001 "Playing cards"
	3858001 "Video games of a kind used"
	3891101 "Tailor's chalks"
	3891102 "Pens, duplicating stylos, pencils, pen-holders, pencil-holders and similar holde"
	3892102 "Whips, riding-crops and the like"
	3893099 "linoleum floor cover, tharafaalu, etc."
	3899302 "Household brushes, mops, etc."
	3899305 "Toothbrushes"
	3899306 "Hairbrushes, etc. for personal care"
	3899402 "Lighters, pipes, cigar and cigarette holders"
	3899403 "Combs"
	3899701 "Imitation jewellery"
	3899801 "Matches"
	3899903 "Candles"
	42912 	"Table, kitchen or other household articles and parts thereof, of iron, steel, co"
	42913 	"Knives (except for machines) and scissors, and blades therefor"
	4291301 "Table knives and kitchen knives"
	4291402 "Razors and razor blades (including razor blade blanks in strips)"
	4291503 "Hair clippers, nail files, etc."
	4291601 "Spoons, forks, ladles, skimmers, cake-servers, fish-knives, butter-knives, sugar"
	4292102 "Hand tools"
	4299701 "Clasps, buckles, press-studs, etc."
	4299904 "Hangers, aluminium knitting needles"
	4299905 "Bicycle bells"
	4311001 "Outboard motors for boats"
	4322001 "Water pumps for gardens"
	4323001 "Air pumps for vehicles"
	4391201 "Household type air conditioning machines"
	44621 	"Ironing and pressing machines"
	4481101 "Refrigerators, household type, electric or non-electric"
	4481103 "Freezers, household type, electric or non-electric"
	4481201 "Dishwashing machines and clothes or linen washing or drying machines, household"
	4481401 "Household sewing machines"
	4481402 "Knitting machines"
	4481501 "Ventilators and extractor hoods"
	4481601 "Vacuum cleaners ,floor polishers, kitchen waste disposers"
	4481602 "Food mixers, coffee makers, toasters, irons and the like"
	4481603 "Hair clippers for animals"
	4481701 "Ovens, microwave ovens, cookers; water and space heaters"
	4481703 "Rice Cooker"
	4482101 "Non-electric cooking and heating apparatus"
	4482103 "Camping stoves"
	44822 	"Parts of vacuum cleaners, floor polishers, water heaters, space"
	4482201 "Stove"
	44824 	"heaters, etc."
	45130 	"Calculating machines including pocket calculators"
	4523001 "Computer"
	4526001 "Printer"
	4526003 "Computer CD"
	45270 	"Storage units"
	4621201 "Fuses, circuit breakers, switches, lamp holders, plugs and sockets, etc."
	4641099 "Primary cells and primary batteries"
	4721101 "Mobile phones"
	4722001 "Telephones, telefax machines"
	4722002 "Building surveillance equipment"
	4722003 "Fax machine"
	4731101 "Radio"
	4731301 "Cable TV"
	4731302 "Dish Antennae"
	4731304 "Television receivers, whether or not combined with radio-broadcast receivers or"
	4732101 "Compact Set"
	4732102 "CD Player"
	4732301 "Video cassette players and recorders"
	4733102 "Microphones and stands therefor; loudspeakers; headphones, earphones and combine"
	4751001 "Prepared unrecorded media for sound recording or similar recording of other phen"
	4752003 "Game software for use in PCs and for playing consoles"
	4825301 "Alcohol breath tests"
	4831201 "Corrective eye-glasses"
	4831203 "Sun-glasses"
	4832201 "Camera"
	4841001 "wrist watch, etc."
	4842002 "Household clocks"
	4911301 "Motor cars"
	4911401 "Pickup / Lorry"
	4931401 "Dhoani / Speed boat"
	4991101 "Cycle"
	49921 	"Bicycles and other cycles, not motorised"
	4992101 "Bicycle"
	4993001 "Wheel barrows and the like"
	4993002 "Rickshaws"
	5411101 "Repair and maintenance of buildings - one and two-dwelling buildings"
	54112 	"Repair and maintenance of buildings - multi-dwelling buildings"
	54611 	"Electrical wiring and fitting services"
	6319199 "Holiday centre and holiday home services"
	63199 	"Other lodging services n.e.c."
	6329001 "Lunch packet"
	6329002 "Eating in hotel"
	6329003 "Eating in restaurent"
	6421102 "Transportation by motor-bus and trolley-bus"
	6422101 "Taxi services"
	64223 	"Rental services of buses and coaches with operator"
	6511101 "Coastal and transoceanic water transport services of passengers by ferries"
	6511901 "Other coastal and transoceanic water transport services of passengers"
	66110 	"Scheduled air transport services of passengers"
	661101	"Airfare - Education travel"
	661102	"Airfare - Religious (Hajj) travel"
	661103	"Airfare - Leisure travel"
	661104	"Airfare - Medical travel"
	66120	"Non-scheduled air transport services of passengers"
	68111	"Postal services related to letters"
	68112	"Postal services related to parcels"
	69110	"Electricity transmission and distribution services"
	69120	"Gas distribution services through mains"
	69210	"Water, except steam and hot water, distribution services through mains"
	7133101 "Motor vehicle insurance services"
	7211101 "Actual rents for main residences"
	7211103 "Imputed rents for main residences"
	7211202 "Permanent hire of garages or parking spaces for purposes other than to provide p"
	7322099 "Leasing or rental services concerning video tape"
	83811 	"Portrait photography services"
	83820 	"Photography processing services"
	8411002 "Wired telecommunications services"
	8412001 "Telephone card - mobile"
	85940 	"Duplicating services"
	86921 	"Printing services and services related to printing, on a fee or contract basis"
	87149 	"Repair of pleasure boats, sports boats and private aeroplanes"
	8715102 "Repair of personal care appliances"
	87159 	"Maintenance and repair services of machinery and equipment n.e.c."
	8724099 "Furniture repair services"
	9111101 "Fees for administrative documents"
	92110 	"Pre-school education services"
	9219001 "Other primary education services"
	9221001 "General secondary education services"
	92220 	"Higher secondary education services"
	92230 	"Technical and vocational secondary education services"
	92310 	"Post-secondary technical and vocational education services"
	92900 	"Other education and training services"
	9311099 "Hospital services"
	9312102 "General medical services"
	9312202 "medical consulting"
	93123 	"Dental services"
	93191 	"Deliveries and related services, nursing services, physiotherapeutic and para-me"
	9319999 "Other human health services n.e.c."
	9332901 "Marriage guidance services"
	94211 	"Non-hazardous waste collection services"
	9591099 "Religious services"
	9615199 "Motion picture projection services"
	9652099 "Sports and recreational sports facility operation services"
	9662099 "Services of sports and games schools: services of mountain, hunting and fishing"
	9713001 "Other cleaning services for garments"
	9721001 "Hairdressing and barbers' services"
	9722099 "Cosmetic treatment, manicuring and pedicuring services"
	9723002 "Services of fitness centres"
	98000 	"Domestic services"
	99999 	"Other personal effects";
	
	la val cpc7 cpc7;
	# delimit cr

* ----------------------------- * 
*   Consumption aggregate (CA)  *
* ----------------------------- *

	* Construct the 2003 CA consistently with the 2009 CA 
	* see 2009/"02_consumption_aggregate"

	* Mortgage and loan brokerage services (coicop 12.6.2)
	gen x1=valueperday if inlist(cpc7==71559,82330)
	
	* Actual and imputed rentals for housing (coicop 4.1 4.2)
	gen x2=valueperday if inlist(cpc7,7211101,7211103, 7211202)
	
	* Purchase of vehicles (coicop 7.1)
	gen x3=valueperday if inlist(cpc7,4911301,4911401,4931401, 4991101,49921,4992101,4993001)

	* Major tools and equipment (D) (coicop 05.5.1)
	gen x4=valueperday if inlist(cpc7,4322001,4292102,44231)
	
	* Major household appliances whether electric or not (D) (coicop 05.3.1)
	gen x5=valueperday if inlist(cpc7,42993,4391201,43914,44621,4481101,4481103,4481201,4481401,4481402,4481501,4481601,4481701,4481703,4482101, 4482103, 4482201,44824,44826,44831)

	* Major durables for outdoor recreation (D) (coicop 09.2.1)
	gen x6=valueperday if inlist(cpc7,2716002, 2718002, 31914,48160,49490,4993001,4993002, 4482103, 4311001) 
	
	* Musical instruments and major durables for indoor recreation (D) (coicop 09.2.2)
	gen x7=valueperday if inlist(cpc7,2922004,38310,38320,38330,38340,38350,38360,3844002,38590,42999)

	* Maintenance and repair of other major durables for recreation and culture (S) (coicop 09.2.3)
	gen x8=valueperday if inlist(cpc7,87149,87159)

	* Jewellery, clocks and watches (D) (coicop 12.3.1)
	gen x9=valueperday if inlist(cpc7,3824002,3899701,4841001,4842002,87220)

	* Haj
	gen x10=valueperday if inlist(cpc7, 6611002, 9591099)
		
	* wedding
	gen x11=valueperday if cpc7==97990

	* Furniture and furnishings, carpets and other floor coverings
	gen x12= valueperday if inlist(cpc7,4910,2714002,27210,27230, 29130,31913,31914,36950,36960,36990,37116,37222,38112,381199,813099,3814099,3815099,38160,3893099,38960,3899903,42999,46531,46539,54611,54750,8724099,87290)
		
	egen X=rowtotal(x1 x2 x3 x4 x5 x6 x7 x8 x9 x10 x11 x12), missing

	collapse (sum) valueperday X, by(hhid)   

	merge 1:1 hhid using $path/outputdata/check_2003.dta
	keep if _m == 3
	drop _m
	
* ---------------------------------- *
* 	New 2003 Consumption Aggregate
* ---------------------------------- *	
	
	gen the_del=valueperday-X
	gen the=(the_del*(365/12))/(wght_hh)
	label var the "new consumption aggregate (Rf/household/month)"
	
	* calculate per capita per day ca
	
	/* 
	
	this step should be double checked: 
	I follow the exppppd var in 00r_expenditure_by_household that was constructed this way	
	
	exppppd=totalexpendday/numpeople
	numpeople=hhsize*wght_hh
	
	*/

	gen pce_day=the_del/(hhsize_off*wght_hh)
	label var pce_day "new consumption aggregate (Rf/person/day)"
	
	drop the_del
		
	drop if pce_day==.
	* no observations are deleted
	
	* calculate per capita monthly ca
	gen pce=pce_day*(365/12)
	label var pce "consumption aggregate (Rf/Individual/month)"	
	
	
	* Average and median monthly per capita consumption aggregate by reg2 (constructed)
	tabstat the [aw=wght_hh], s(mean  median) by(reg2) format(%9.0f)
	tabstat pce_day [aw=wght_ind], s(mean  median) by(reg2) format(%9.0f)
	tabstat pce [aw=wght_ind], s(mean  median) by(reg2) format(%9.0f)

	keep hh* pce reg* w*
	
	
	save $path/outputdata/pce_2003.dta, replace
	
	
	* food expenditure
	use $path/inputdata/A5r-Expenditures-by-CPC.dta, clear
	
	rename hhserial hhid
	label var hhid "household identifier"

	
	replace cpc7="6611001" if cpc7=="66110E"
	replace cpc7="6611002" if cpc7=="66110H"
	replace cpc7="6611003" if cpc7=="66110L"
	replace cpc7="6611004" if cpc7=="66110M"
	
	destring cpc7, replace
	label val cpc7 cpc7
	
	* keep food items only (same choices as with the 2009 CA)
	keep if cpc7<= 2449001 | (cpc7==6329001 | cpc7==6329002|cpc7==6329003)
	drop if cpc7>23000 & cpc7<110000
	drop if cpc7==313001
	
	collapse (sum) valueperday, by(hhid)
	
	merge 1:1 hhid using $path/outputdata/check_2003.dta
	keep if _m == 3
	drop _m

	gen food_pc=valueperday*(365/12)/(hhsize_off*wght_hh)
	label var food_pc "food consumption aggregate (Rf/person/month)"
	
	keep hhid food_pc
	
	save $path/outputdata/food_2003.dta, replace
	
	merge 1:1 hhid using $path/outputdata/pce_2003.dta
	assert _m == 3
	drop _m
	
	save $path/outputdata/pce_2003.dta, replace
	
	* Bring in temporal CPI from "CPI 1997-2013.xlsx"
	
	clear
	import excel using $path/inputdata/CPI_1997-2013.xlsx, sheet("Rep") cellra(A1:O22) first
	
	rename  CPIandInflationaRateRepubl year
	rename B January
	rename C February
	rename D March
	rename E April
	rename F May
	rename G June
	rename H July
	rename I August
	rename J September
	rename K October
	rename L November
	rename M December
	rename N Annual_Index
	rename O Inflation_Rate
	
	drop if _n==1|_n==2
	label var year "year"
	destring year, replace
	destring Annual_Index, replace
	
	save $path/outputdata/cpi.dta, replace
	
	
	* calculate 2003-2009 deflator
	gen  del1=Annual_Index if year==2003
	egen del2=total(del1)
	
	gen del3=Annual_Index if year==2009
	egen del4=total(del3)
	
	gen cpi2009=del4/del2
	keep cpi2009
	save $path/outputdata/cpi.dta, replace
	
	
	*deflate pce variable

	use $path/outputdata/pce_2003.dta, clear
	
	merge using $path/outputdata/cpi.dta
	rename cpi2009 cpi2009_del
	egen cpi2009=mean(cpi2009_del)
	
	drop cpi2009_del
	drop _merge
	
	* Generate the PCE in constant 2009 prices
		
	gen pce_2009=pce*cpi2009
	label var pce_2009 "per capita expenditure (2009 Rf/person/month)"
	
	sort hhid
	save $path/outputdata/pce_2003.dta, replace

	
	
	exit


	*CHECKS
	
	/*Reproducing official estimates (HIES Report 2012, pg. 12, "Key Indicators Table")
	Official Consumption Aggregate includes durables, does not include rent and does not include gifts*/
		
	use $path/inputdata/A5r-Expenditures-by-CPC.dta, clear
	
	rename hhserial hhid
	label var hhid "household identifier"
	
		
	replace cpc7="6611001" if cpc7=="66110E"
	replace cpc7="6611002" if cpc7=="66110H"
	replace cpc7="6611003" if cpc7=="66110L"
	replace cpc7="6611004" if cpc7=="66110M"
	
	destring cpc7, replace

	gen exp_cash=valueperday if inlist(aquired,1,3,.)
	gen exp_hmp=valueperday if aquired==2
	gen exp_gft=valueperday if aquired==4
	gen exp_rent=valueperday if inlist(cpc7,7211101,7211103, 7211202)
	
	
	collapse (sum) exp*, by(hhid)   
	
	merge 1:m hhid using $path/data/outputdata/check_2003.dta,
	keep if _m == 3
	drop _m
	
	gen the_official=(exp_cash+exp_hmp-exp_rent)*(365/12)/(wght_hh)	
	label var the_official "Total Household Expenditure (ruffya/household/month) does not include gift nor rent"
	
	gen pce_official=(exp_cash+exp_hmp-exp_rent)/(hhsize_off*wght_hh)	
	label var pce_official "Total individual expenditure (ruffya/invididual/day) does not include gift nor rent"
	
	
	tabstat pce_official [aw=wght_hh], s(mean  median) by(reg2) format(%9.0f)
	tabstat the_official [aw=wght_hh], s(mean  median) by(reg2) format(%9.0f)
	
	
	
	
