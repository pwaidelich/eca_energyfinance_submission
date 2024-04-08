*** CODE  for a paper entitled "Quantifying the shift of public export finance from fossil fuels to renewable energy" (submitted to Nature Communications) 

*** Corresponding author: Paul Waidelich (paul.waidelich@gess.ethz.ch)


/* Import original Excel files and change to STATA data files (.dta)

clear all 

cd "/Users/pcenskow/Library/CloudStorage/OneDrive-UniversitédeLausanne/ECA paper/datasets"

import excel "sus1 18 06.xlsx", firstr sheet("Data") // import excel data 2013-2022

save TXF_data

clear all 

cd "/Users/pcenskow/Library/CloudStorage/OneDrive-UniversitédeLausanne/ECA paper/datasets"

import excel "2023_ef_fy.xlsx", firstr sheet("Data")

save Raw_data_2023_new

*/


/* Import and append different datawaves (in total two, 2013-2022 and 2023)

clear all

cd "/Users/pcenskow/Library/CloudStorage/OneDrive-UniversitédeLausanne/ECA paper/Final dataset/other"

use "TXF_data"


drop ecaserialno


append using "Raw_data_2023_new"


destring volumein tranchevolumein tranchelocalc~e lenderinvolve~n mlainvolvemen~p ecainvolvemen~n, replace dpcomma


* Sort by unique deal IDs

sort tmddealid

* extract closing year from closing date  

gen closingyear = substr(closingdate, 1, 4)

encode closingyear, gen(closingyear_num)

* re-label target variables 
label var volumein "Total deal volume in USD million"

label var ecainvolvementonthedealin "ECA involvement in USD million"

*/


/* Screen for additional deals and re-classification


* All sub-industries in ECA-supported deals were screened with the below code (for space reasons we only provide shipping industry here)

* All potentially energy-related deals were screened on a case-by-case basis in a separate Excel file (not possible to share since it contains deal-level information)

* Example code: dealsubindustry == Ships 

gen ships_ff = 0
replace ships_ff=1 if ///
strpos(description, "Coal") & dealsubindustry == "Ships" | ///
strpos(description, "coal") & dealsubindustry == "Ships" | ///
strpos(description, "Petroleum") & dealsubindustry == "Ships" | ///
strpos(description, "Petro") & dealsubindustry == "Ships" | ///
strpos(description, "petro") & dealsubindustry == "Ships" | ///
strpos(description, "Fossil") & dealsubindustry == "Ships" | /// 
strpos(description, "fossil") & dealsubindustry == "Ships" | /// 
strpos(description, "Fuel") & dealsubindustry == "Ships" | ///
strpos(description, "fuel") & dealsubindustry == "Ships" | ///
strpos(description, "Oil") & dealsubindustry == "Ships" | ///
strpos(description, "oil") & dealsubindustry == "Ships" | ///
strpos(description, "Gas") & dealsubindustry == "Ships" | ///
strpos(description, "gas") & dealsubindustry == "Ships" | ///
strpos(description, "LNG") & dealsubindustry == "Ships" | ///
strpos(description, "LPG") & dealsubindustry == "Ships" | ///
strpos(description, "Drill") & dealsubindustry == "Ships" | ///
strpos(description, "drill") & dealsubindustry == "Ships" | ///
strpos(description, "Energy") & dealsubindustry == "Ships" | ///
strpos(description, "energy") & dealsubindustry == "Ships" | ///
strpos(borrower, "Coal") & dealsubindustry == "Ships" | ///
strpos(borrower, "coal") & dealsubindustry == "Ships" | ///
strpos(borrower, "Petroleum") & dealsubindustry == "Ships" | ///
strpos(borrower, "Petro") & dealsubindustry == "Ships" | ///
strpos(borrower, "petro") & dealsubindustry == "Ships" | ///
strpos(borrower, "Fossil") & dealsubindustry == "Ships" | /// 
strpos(borrower, "fossil") & dealsubindustry == "Ships" | /// 
strpos(borrower, "Fuel") & dealsubindustry == "Ships" | ///
strpos(borrower, "fuel") & dealsubindustry == "Ships" | ///
strpos(borrower, "Oil") & dealsubindustry == "Ships" | ///
strpos(borrower, "oil") & dealsubindustry == "Ships" | ///
strpos(borrower, "Gas") & dealsubindustry == "Ships" | ///
strpos(borrower, "gas") & dealsubindustry == "Ships" | ///
strpos(borrower, "LNG") & dealsubindustry == "Ships" | ///
strpos(borrower, "LPG") & dealsubindustry == "Ships" | ///
strpos(borrower, "Drill") & dealsubindustry == "Ships" | ///
strpos(borrower, "drill") & dealsubindustry == "Ships" | ///
strpos(borrower, "Energy") & dealsubindustry == "Ships" | ///
strpos(borrower, "energy") & dealsubindustry == "Ships" | ///
strpos(assettype, "Coal") & dealsubindustry == "Ships" | ///
strpos(assettype, "coal") & dealsubindustry == "Ships" | ///
strpos(assettype, "Petroleum") & dealsubindustry == "Ships" | ///
strpos(assettype, "Petro") & dealsubindustry == "Ships" | ///
strpos(assettype, "petro") & dealsubindustry == "Ships" | ///
strpos(assettype, "Fossil") & dealsubindustry == "Ships" | /// 
strpos(assettype, "fossil") & dealsubindustry == "Ships" | /// 
strpos(assettype, "Fuel") & dealsubindustry == "Ships" | ///
strpos(assettype, "fuel") & dealsubindustry == "Ships" | ///
strpos(assettype, "Oil") & dealsubindustry == "Ships" | ///
strpos(assettype, "oil") & dealsubindustry == "Ships" | ///
strpos(assettype, "Gas") & dealsubindustry == "Ships" | ///
strpos(assettype, "gas") & dealsubindustry == "Ships" | ///
strpos(assettype, "LNG") & dealsubindustry == "Ships" | ///
strpos(assettype, "LPG") & dealsubindustry == "Ships" | ///
strpos(assettype, "Drill") & dealsubindustry == "Ships" | ///
strpos(assettype, "drill") & dealsubindustry == "Ships" | ///
strpos(assettype, "Energy") & dealsubindustry == "Ships" | ///
strpos(assettype, "energy") & dealsubindustry == "Ships" | ///
strpos(assettype, "FPSO") & dealsubindustry == "Ships" | ///
strpos(assettype, "fpso") & dealsubindustry == "Ships" 




/* Remove those deals that were falsely reclassified as ships_ff

* br tmddealid borrower borrowerindustry exporterindustry dealtitle volumein dealindustry dealsubindustry description if ships_ff ==1 & volumein != 0

replace ships_ff = 0 if ///
tmddealid == 4610 | /// reduce the emissions by installing exhaust gas scrubbers as well as by reblading and treating the vessels with silicone
tmddealid == 8302 | /// LNG-propelled vessels, not LNG-transport vessels
tmddealid == 10485 | /// LNG-propelled vessels, not LNG-transport vessels
tmddealid == 11257 | /// LNG-propelled vessels, not LNG-transport vessels
tmddealid == 13428 | /// modernize fleet 
tmddealid == 13883 | /// catamarans 
tmddealid == 17493 | /// LNG-propelled vessels, not LNG-transport vessels 
tmddealid == 17633 | /// LNG-propelled vessels, not LNG-transport vessels 
tmddealid == 18595 | /// electric vessel
tmddealid == 18896 | /// container ships
tmddealid == 19307 | /// LNG-propelled vessels, not LNG-transport vessels 
tmddealid == 19774 | /// container ships
tmddealid == 20230  // container ships

*/

gen upstream_dredging = 0 
replace upstream_dredging = 1 if ///
inlist(tmddealid, 1926, 6168, 12550, 12557, 12918, 18748, 21238, 12964)

gen upstream_drilling = 0
replace upstream_drilling = 1 if ///
inlist(tmddealid, 1932, 2088, 2547, 2560, 6738, 25143)  

gen gas_midstream_ships = 0
replace gas_midstream_ships = 1 if inlist(tmddealid, 282, 2039, 2051, 2450, 2777, 3541, 3706, 3727, 6301, 7076, 20266, 20267, 21047, 23066, 26551) // gas midstream ship deals 

gen oil_midstream_ships = 0
replace oil_midstream_ships = 1 if inlist(tmddealid, 2412, 3254, 3299, 4306) // oil midstream ship deals 


total volumein if ships_ff == 1 // 10462.99 USD million in only 20+ deals


*/


/* Classify by energy source/technology

************************************************************************************
************************************************************************************
*****************************By energy source*********************************
************************************************************************************
************************************************************************************


gen coal = 0
replace coal = 1 if dealsubindustry == "Coal, Coke, Anthracite"| ///
dealsubindustry == "Coal-fired" | ///
tmddealid == 10858 | /// Euler hermes cover to Russia's biggest coal company
tmddealid == 11400 | ///  Euler hermes cover to Russia's biggest coal company
tmddealid == 3144 //  financing of Vinh Tan 4 power project in Viet Nam
replace coal = 0 if tmddealid==10298 // remove Bauxite mine


gen oil = 0
replace oil = 1 if ///
dealsubindustry == "Heavy fuel oil-fired" | ///
dealsubindustry == "Oil - Downstream (Refining)" | ///
dealsubindustry == "Oil - Midstream (Transportation)" | ///
dealsubindustry == "Oil - Trading"|dealsubindustry == "Oil - Upstream (Exploration and production)"
replace oil = 1 if tmddealid==3372 // Long-term loan facility for financing the Odfjell Drilling rig Deepsea Aberdeen classified as manufacturing & equipment
replace oil = 1 if tmddealid==3519 // USD67.5mln term loan facility to as a joint venture between Samsung Heavy Industries Nigeria (SHIN) and MCI FZE Yard Development Limited, for its construction of a FPSO integration yard in Lagos, Nigeria. FPSO = A floating production storage and offloading (FPSO) unit is a floating vessel used by the offshore oil and gas industry for the production and processing of oil 
replace oil = 1 if tmddealid == 3049 | /// refinery, new gasification plant and petrochemical facility in India - oil midstream
tmddealid == 13731 // dealindustry Manufacturing & equipment dealsubindustry	Engineering add Subsea 7 finance UKEF deal
replace oil = 1 if inlist(tmddealid, 2074, 3689, 3690) // added from 'Conventional power'
replace oil = 1 if oil_midstream_ships == 1 

gen gas = 0
replace gas = 1 if ///
dealsubindustry == "Gas - Upstream (Exploration and production)" | ///
dealsubindustry == "Gas - Midstream (Transportation)" | ///
dealsubindustry == "Gas - Downstream (Refining)" | ///
dealsubindustry == "Gas -Trading" | ///
dealsubindustry == "LNG" | ///
dealsubindustry == "Gas-fired" |  ///
dealsubindustry == "Gas-fired combined cycle" | ///
dealsubindustry == "Gas-fired simple cycle" | ///
inlist(tmddealid, 4351, 4093, 4301, 4374, 4345, 6012, 19777, 20902, 2738, 2062) | /// add gas turbines and combined cycle projects from subcategory 'Conventional power' and 'Manufacturing & equipment' + Kelar power project Chile combined cycle 
gas_midstream_ships == 1


*** other power/energy related 
gen other_power = 0 
replace other_power = 1 if ///
inlist(tmddealid, 2030, 2231, 2232, 2144, 2647, 2274, 17433)


gen o_g_mixed = 0 
replace o_g_mixed = 1 if ///
inlist(tmddealid, 1932, 2088, 2547, 2560, 6738, 1705, 2043) | /// mixed o & g ships ov power deals
upstream_drilling == 1 | /// assuming drilling can be used for oil and gas 
other_power == 1 /// more mixed/but highly likely FF power deals 




 // mixed o & g drilling ships or deals from Conventional power that could not properly be attributed

gen wind = 0
replace wind = 1 if ///
dealsubindustry=="Offshore wind" | ///
dealsubindustry=="Onshore wind" | ///
dealsubindustry=="Wind" | /// Wind  
tmddealid == 1935 | /// add Wind deal from subcategory 'Power'
tmddealid == 1938 | /// add Wind deal from subcategory 'Power'
tmddealid == 11286 | /// add Wind deal from subcategory 'Industrial equipment' to envision group (only do Wind)
tmddealid == 1940 | /// add Wind deal from subcategory 'Power'
inlist(tmddealid, 2014, 2086, 2087, 2275, 2278, 3190, 11286) // add all Wind deals from subcategory 'Renewables'

gen solar = 0 
replace solar = 1 if ///
dealsubindustry=="PV solar" | ///
dealsubindustry=="Solar" | /// Solar
dealsubindustry=="Solar thermal" | /// Solar
tmddealid==2434 | /// add solar deal in conventional power
tmddealid==2435 | /// add solar deal in conventional power
tmddealid==2436 | /// add solar deal in conventional power
tmddealid==5988 | /// add solar deal in renewables 
tmddealid==14911 | /// add solar deal in renewables
tmddealid==16162 | /// add solar deal in renewables
tmddealid == 3557 | /// add Renewable Solar thermal deal 
tmddealid == 3560 // add Renewable Solar thermal deal 

gen hydro = 0 
replace hydro = 1 if ///
dealsubindustry=="Small hydro" | ///
dealsubindustry=="Large hydro" | ///
tmddealid==1707 // add hydro deal conv power

gen biogas = 0 
replace biogas = 1 if ///
dealsubindustry == "Biogas"

gen biomass = 0 
replace biomass = 1 if ///
dealsubindustry == "Biomass"

gen geothermal = 0 
replace geothermal = 1 if ///
dealsubindustry == "Geothermal" | ///
tmddealid == 4084 // add Renewable Geothermal deal 

gen waste_to_energy = 0 
replace waste_to_energy = 1 if ///
dealsubindustry=="Waste to energy"

gen nuclear = 0 
replace nuclear = 1 if ///
dealsubindustry=="Nuclear" 


gen energy_source = 0 
replace energy_source = 1 if coal == 1   
replace energy_source = 2 if oil == 1
replace energy_source = 3 if gas == 1 
replace energy_source = 4 if o_g_mixed == 1 
replace energy_source = 5 if wind == 1 
replace energy_source = 6 if solar == 1 
replace energy_source = 7 if hydro == 1 
replace energy_source = 8 if biomass == 1 | ///
biogas == 1 | /// 
geothermal == 1 | ///
waste_to_energy == 1
replace energy_source = 9 if nuclear == 1 

label define energy_s 1 "Coal" 2 "Oil" 3 "Gas" 4 "Oil and gas - mixed" 5 "Wind" 6 "Solar" 7 "Hydro" 8 "Biogas, Biomass, Geothermal and Waste-to-energy" 9 "Nuclear"

label values energy_source energy_s

decode energy_source, generate(e_s)

************************************************************************************
************************************************************************************
*****************************TECHNOLOGY GROUP*********************************
************************************************************************************
************************************************************************************

* Generate coarse TECHNOLOGY GROUP variables, FF, RE and Other

gen ff = 0
replace ff=1 if coal == 1 | oil == 1 | gas == 1 | ///
o_g_mixed == 1 | ships_ff == 1 | /// add all fossil fuel ships 
dealsubindustry == "Conventional power" 

replace ff = 0 if inlist(tmddealid, 10298, 2434, 2435, 2436, 1707, 5180)  // remove Bauxite mine in Coal category, remove 3 solar deals, 1 hydro deal, and 1 transmission deal from conventional power (respectively in that order)


* Generate RE-related

gen re = 0 
replace re=1 if ///
wind == 1 | ///
solar == 1 | ///
hydro == 1 | ///
biomass == 1 | ///
biogas == 1 | ///
geothermal == 1 | ///
dealsubindustry== "Renewables" | ///
dealsubindustry == "Waste to energy" | ///
dealsubindustry == "Large hydro" // add all large hydro to RE 

replace re = 0 if /// 
tmddealid == 5258 // desalination plant in subindustry 'renewables'



gen other = 0
replace other=1 if dealsubindustry=="Nuclear" 
replace other=2 if dealsubindustry =="Hydrogen" 
replace other=3 if dealsubindustry =="Electricity transmission" | ///
dealsubindustry =="Battery storage" | /// 
tmddealid == 5180 // add transmission infrastructure deal Prestea Kumasi deal in ghana from 'Conventional power'
replace other=4 if other_power == 1

label define other_coarse 1 "Nuclear" 2 "Hydrogen" 3 "Transmission or storage" 4 "Other power"

label values other other_coarse


*/


/* Classify by value chain and fine technology



* Generate new variable for VALUE CHAIN (upstream, midstream, downstream, power generation, electricity infrastructure)

* use if qualifier to subset different value chain elements for FF or RE only

gen v_c = 0
replace v_c = 1 if ///
dealsubindustry == "Gas - Upstream (Exploration and production)" | ///
dealsubindustry == "Oil - Upstream (Exploration and production)" | ///
dealsubindustry == "Coal, Coke, Anthracite" | ///
tmddealid==3372 | /// Long-term loan facility for financing the Odfjell Drilling rig Deepsea Aberdeen classified as manufacturing & equipment
tmddealid == 13731 | /// add Subsea 7 finance UKEF deal
upstream_drilling == 1 //

replace v_c= 0 if tmddealid==10298 // remove Bauxite mine in Coal category

replace v_c = 2 if ///
dealsubindustry=="Gas - Midstream (Transportation)" | ///
dealsubindustry=="LNG" | ///
dealsubindustry=="Oil - Midstream (Transportation)" | ///
gas_midstream_ships==1 | ///
oil_midstream_ships==1 | ///
inlist(tmddealid, 3519, 4397) // First is USD67.5mln term loan facility to as a joint venture between Samsung Heavy Industries Nigeria (SHIN) and MCI FZE Yard Development Limited, for its construction of a FPSO integration yard in Lagos, Nigeria. FPSO = A floating production storage and offloading (FPSO) unit is a floating vessel used by the offshore oil and gas industry for the production and processing of oil; Second is refinancing of the expansion project at Jamnagar (refinery).

replace v_c = 1 if /// large LNG upstream deals listed under "LNG"
tmddealid == 6091 | /// add Yamal LNG 
tmddealid == 6525 | /// add Coral South Mozambique 
tmddealid == 17526 // second deal for arctic lng Yamal

replace v_c = 3 if ///
dealsubindustry=="Gas - Downstream (Refining)" | ///
dealsubindustry=="Gas -Trading" | ///
dealsubindustry=="Oil - Downstream (Refining)" | ///
dealsubindustry=="Oil - Trading" | /// 
tmddealid == 2030 | /// add the financing of a Boiler in Macedonia in the Power industry 
tmddealid == 3049 // refinery, new gasification plant and petrochemical facility in India - oil midstream


replace v_c = 4 if /// see dealsubindustries in 'Power' and 'Renewables', including potentially non-power generating deals like geothermal, solar thermal, or hydrogen. only elements that belong to upstream or Electricity infrastructure (16)
dealsubindustry=="Coal-fired" | ///
dealsubindustry=="Gas-fired"| ///
dealsubindustry=="Gas-fired combined cycle"| ///
dealsubindustry=="Gas-fired simple cycle"| ///
dealsubindustry=="Heavy fuel oil-fired"| ///
dealsubindustry=="Power"| ///
dealsubindustry=="Conventional Power" | ///
dealindustry=="Renewables"| ///
dealsubindustry=="Large hydro"| ///
dealsubindustry=="Waste to energy"| ///
dealsubindustry=="Nuclear"| ///
tmddealid == 19777 | /// add add combined cycle deal in Mexico 
tmddealid == 20902 | ///  add add combined cycle deal in Mexico II
tmddealid == 2738 | /// Kelar power project Chile combined cycle 
other_power == 1

replace v_c = 0 if tmddealid == 4397 // remove refinery deal  


replace v_c = 5 if ///
dealsubindustry=="Electricity transmission"| ///
dealsubindustry=="Battery storage"

label define value_chain 1 "Upstream" 2 "Midstream" 3 "Downstream" 4 "Power generation" 5 "Electricity infrastructure"

label values v_c value_chain

************************************************************************************
************************************************************************************
*****************************Power generation TECHNOLOGY *********************************
************************************************************************************
************************************************************************************


* Power generation coarse 

gen tech = 0 // see v_c downstream 


replace tech = 1 if dealsubindustry=="Coal-fired" // coal fired

replace tech = 2 if /// Gas-fired
dealsubindustry=="Gas-fired" | ///
dealsubindustry=="Gas-fired combined cycle"| ///
dealsubindustry=="Gas-fired simple cycle" | /// 
inlist(tmddealid, 4351, 4093, 4301, 4374, 4345, 6012, 19777, 20902, 2738) // add gas turbines and combined cycle projects from subcategory 'Conventional power' & 'Manufacturing & equipment', Kelar power project Chile combined cycle


replace tech = 3 if dealsubindustry=="Heavy fuel oil-fired" | /// oil-fired
inlist(tmddealid, 2074, 3689, 3690) // added from 'Conventional power'

replace tech = 4 if /// 
o_g_mixed == 1  | ///
dealsubindustry == "Conventional power" & ff == 1 & !inlist(tmddealid, 2074, 3689, 3690, 4351, 4093, 4301, 4374, 4345, 6012) | /// exclude above conv power deals to avoid double-counting
dealsubindustry=="Power" & ff == 1 // Other or mixed fossil

replace tech = 5 if ///
dealsubindustry=="Offshore wind" | ///
dealsubindustry=="Onshore wind" | ///
dealsubindustry=="Wind" | /// Wind  
tmddealid == 1935 | /// add Wind deal from subcategory 'Power'
tmddealid == 1938 | /// add Wind deal from subcategory 'Power'
tmddealid == 11286 | /// add Wind deal from subcategory 'Industrial equipment' to envision group (only do Wind)
tmddealid == 1940 | /// add Wind deal from subcategory 'Power'
inlist(tmddealid, 2014, 2086, 2087, 2275, 2278, 3190, 11286) // add all Wind deals from subcategory 'Renewables'


replace tech = 6 if ///
dealsubindustry=="PV solar" | ///
dealsubindustry=="Solar" | /// Solar
tmddealid==2434 | /// add solar deal in conventional power
tmddealid==2435 | /// add solar deal in conventional power
tmddealid==2436 | /// add solar deal in conventional power
tmddealid==5988 | /// add solar deal in renewables 
tmddealid==14911 | /// add solar deal in renewables
tmddealid==16162 // add solar deal in renewables


replace tech = 7 if /// 
dealsubindustry=="Small hydro" | ///
dealsubindustry=="Large hydro" | ///
tmddealid == 1707 // add hydro deal from conventional power

replace tech = 8 if ///
dealsubindustry == "Biogas"

replace tech = 9 if ///
dealsubindustry == "Biomass"

replace tech = 10 if /// 
dealsubindustry == "Geothermal"

replace tech = 11 if dealsubindustry=="Renewables" & tech == 0 & tmddealid != 5258 // Other or mixed renewables (remove desalination plant)

replace tech = 12 if dealsubindustry=="Waste to energy" //

replace tech = 13 if dealsubindustry=="Nuclear"


label define technology 1 "Coal-fired" 2 "Gas-fired" 3 "Oil-fired" 4 "Other or mixed fossil" 5 "Wind" 6 "Solar" 7 "Hydro" 8 "Biogas" 9 "Biomass" 10 "Geothermal" 11 "Other or mixed renewables" 12 "Waste to energy" 13 "Nuclear"

label values tech technology

* Power generation FINE

gen tech_fine = 0 // see v_c downstream 
replace tech_fine = 1 if dealsubindustry=="Coal-fired" // coal fired

replace tech_fine = 2 if dealsubindustry=="Gas-fired" 

replace tech_fine = 3 if dealsubindustry=="Gas-fired combined cycle"

replace tech_fine = 4 if dealsubindustry== "Gas-fired simple cycle"

replace tech_fine = 5 if dealsubindustry=="Heavy fuel oil-fired" // oil-fired

replace tech_fine = 6 if dealsubindustry=="Conventional power" & ff == 1 | ///
dealsubindustry=="Power" & ff == 1 // Mixed fossil

replace tech_fine = 7 if other_power==1 // Other power

replace tech_fine = 8 if dealsubindustry=="Offshore wind" 

replace tech_fine = 9 if dealsubindustry=="Onshore wind" | ///
tmddealid == 11286 // add onshore Wind deal from subcategory 'Renewables'


replace tech_fine = 10 if dealsubindustry== "Wind" | /// Other Wind
tmddealid == 1935 | /// add Wind deal from subcategory 'Power'
tmddealid == 1938 | /// add Wind deal from subcategory 'Power'
tmddealid == 11286 | /// add Wind deal from subcategory 'Industrial equipment' to envision group (only do Wind)
tmddealid == 1940 | /// add Wind deal from subcategory 'Power'
inlist(tmddealid, 2014, 2086, 2087, 2275, 2278, 3190) // add Wind deals from subcategory 'Renewables'


replace tech_fine = 11 if /// Solar PV deals 
dealsubindustry=="PV solar" | ///
dealsubindustry== "Solar" | ///
inlist(tmddealid, 5988, 14911, 16162) | /// add solar deals from subcategory 'Renewables'
inlist(tmddealid, 2434, 2435, 2436) // add solar deals from subcategory 'conventional power'

replace tech_fine = 12 if /// Thermo solar deals 
dealsubindustry == "Thermo solar" | ///
tmddealid==3557 | /// add thermal solar deal renewables
tmddealid==3560 // add thermal solar deal renewables

replace tech_fine = 13 if /// 
dealsubindustry=="Small hydro" 

replace tech_fine = 14 if dealsubindustry=="Large hydro" | /// large hydro 
tmddealid == 1707 // add hydro deal from conventional power

replace tech_fine = 15 if ///
dealsubindustry == "Biogas"

replace tech_fine = 16 if ///
dealsubindustry == "Biomass"

replace tech_fine = 17 if /// 
dealsubindustry == "Geothermal" | ///
tmddealid == 4084 // add Renewable Geothermal deal 


replace tech_fine = 18 if dealsubindustry=="Renewables" & tech_fine == 0 & tmddealid != 5258 // Other or mixed renewables (remove desalination plant)

replace tech_fine = 19 if dealsubindustry=="Waste to energy" //

replace tech_fine = 20 if dealsubindustry=="Nuclear"

label define technology_fine 1 "Coal-fired" 2 "Gas-fired" 3 "Gas-fired combined cycle" 4 "Gas-fired simple cycle" 5 "Heavy fuel oil-fired" 6 "Fossil - mixed" 7 "Other power" 8 "Offshore wind" 9 "Onshore wind" 10 "Other wind" 11 "Solar PV" 12 "Solar - thermal" 13 "Small hydro" 14 "Large hydro" 15 "Biogas" 16 "Biomass" 17 "Geothermal" 18 "Renewables - mixed" 19 "Waste to energy" 20 "Nuclear"

label values tech_fine technology_fine


*/


************************************************************************************
************************************************************************************
*****************************SUBSET THE DATASET*********************************
************************************************************************************
************************************************************************************


* Keep only if transaction is energy related 

keep if ff == 1 | re == 1 | other != 0 


save "/Users/pcenskow/Library/CloudStorage/OneDrive-UniversitédeLausanne/ECA paper/Final dataset/TXF_data_all_energy_only.dta", replace


export delimited using "/Users/pcenskow/Library/CloudStorage/OneDrive-UniversitédeLausanne/ECA paper/Final dataset/Stata code/240219 TXF_data_all_energy_only.csv", replace
