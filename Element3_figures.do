*** CODE  for a paper entitled "A dynamic analysis of energy financing patterns by public export credit agencies" (submitted) 

*** Corresponding author: philipp.censkowsky@unil.ch


*** Final figures 

clear all 

cd "/Users/pcenskow/Library/CloudStorage/OneDrive-UniversitédeLausanne/ECA paper/Philipp Graphs"


use "/Users/pcenskow/Library/CloudStorage/OneDrive-UniversitédeLausanne/ECA paper/Final paper/datasets/current_working_file_FEB22.dta"


/* Fig 1
* Figure 1: General trends

* add dealvolume as tot_en 

bys year: egen tot_en_dv = sum(dv_bn)
bys year: egen tot_eca = sum(v_bn)



*** Guarantees (SWITCH)


preserve
	collapse (max) total_coal total_oil total_gas tech4 total_wind total_solar total_hydro total_biomass total_biogas total_waste tech11 total_nuclear tech_fine7 total_infra, by(year)
	foreach x of varlist total_coal total_oil total_gas tech4 total_wind total_solar total_hydro total_biomass total_biogas total_waste tech11 total_nuclear tech_fine7 total_infra {
	replace `x' = 0 if(`x' == .) 
	}
	gen sum1 = total_coal + total_oil
	gen sum2 = (sum1 + total_gas)
	gen sum3 = (sum2 + tech4 + tech_fine7) // other/mixed fossil power
	gen sum4 = (sum3 + total_wind)
	gen sum5 = (sum4 + total_solar)
	gen sum6 = (sum5 + total_biomass + total_biogas + total_waste + total_hydro + tech11)
	gen sum7 = (sum6 + total_nuclear)
	gen sum8 = (sum7 + total_infra)
	gen zero = 0
	twoway rarea zero total_coal year, color(gs1*0.8) ///
	|| rarea total_coal sum1 year, color(gs1*0.6)  ///
	|| rarea sum1 sum2 year, color(gs1*0.4) ///
	|| rarea sum2 sum3 year, color(gs1*0.2) ///
	|| rarea sum3 sum4 year, color(green*1.2) ///
	|| rarea sum4 sum5 year, color(green*0.7) ///
	|| rarea sum5 sum6 year, color(green*0.3) ///
	|| rarea sum6 sum7 year, color(yellow*0.4) ///
	|| rarea sum7 sum8 year, color(orange*0.6) ///
	||, legend(order(1 "Coal" 2 "Oil" 3 "Gas" 4 "Other Fossil" 5 "Wind" 6 "Solar" 7 "Other Renew." 8 "Nuclear" 9 "Grid") pos(3) r(9) size(small) symxsize(4) symysize(4) region(lp(blank))) ///
	xla(2013(1)2023, nolab notick grid) ///
	yla(0(5)27, grid angle(0) labsize(small)) xtitle("") ///
	xline(2015.5 2019.5 2021.5, lp(dash) lc(red) lwidth(medthick)) scheme(s1mono)
	 graph save "guarantees_only", replace
	 list year sum3 sum6 sum8, clean noobs
restore


*** Direct lending (SWITCH)

preserve
	collapse (max) total_coal total_oil total_gas tech4 total_wind total_solar total_hydro total_biomass total_biogas total_waste tech11 total_nuclear tech_fine7 total_infra, by(year)
	foreach x of varlist total_coal total_oil total_gas tech4 total_wind total_solar total_hydro total_biomass total_biogas total_waste tech11 total_nuclear tech_fine7 total_infra {
	replace `x' = 0 if(`x' == .) 
	}
	gen sum1 = total_coal + total_oil
	gen sum2 = (sum1 + total_gas)
	gen sum3 = (sum2 + tech4  + tech_fine7)
	gen sum4 = (sum3 + total_wind)
	gen sum5 = (sum4 + total_solar)
	gen sum6 = (sum5 + total_biomass + total_biogas + total_waste + total_hydro + tech11)
	gen sum7 = (sum6 + total_nuclear)
	gen sum8 = (sum7 + total_infra)
	gen zero = 0
	twoway rarea zero total_coal year, color(gs1*0.8) ///
	|| rarea total_coal sum1 year, color(gs1*0.6)  ///
	|| rarea sum1 sum2 year, color(gs1*0.4) ///
	|| rarea sum2 sum3 year, color(gs1*0.2) ///
	|| rarea sum3 sum4 year, color(green*1.2) ///
	|| rarea sum4 sum5 year, color(green*0.7) ///
	|| rarea sum5 sum6 year, color(green*0.3) ///
	|| rarea sum6 sum7 year, color(yellow*0.4) ///
	|| rarea sum7 sum8 year, color(orange*0.6) ///
	||, legend(off) /// 
      ytitle("") ///
		xla(2013(1)2023, nolab notick grid) ///
		yla(0(5)27, grid angle(0) labsize(small)) ///
		xtitle("") ///
		xline(2015.5 2019.5 2021.5, lp(dash) lc(red) lwidth(medthick)) scheme(s1mono)
	 	graph save "directlending_only", replace
		list year sum3 sum6 sum8, clean noobs
restore



* (NO SWITCH) Share RE over all direct lending 

bys year: egen tot_en_dl = total(v/1000) if inlist(ecaroleonthedeal, "DFI/MDB direct lender", "ECA direct lender", "Lender")
bys year: egen tot_re_dl = total(v/1000) if re == 1 & inlist(ecaroleonthedeal, "DFI/MDB direct lender", "ECA direct lender", "Lender")


bys year: egen tot_en_g = total(v/1000) if inlist(ecaroleonthedeal, "DFI/MDB (guarantor)", "ECA (guarantor)")
bys year: egen tot_re_g = total(v/1000) if re == 1 & inlist(ecaroleonthedeal, "DFI/MDB (guarantor)", "ECA (guarantor)")



* Shares RE Guarantees & Direct lending  

preserve 
collapse (max) tot_en_dl tot_re_dl tot_en_g tot_re_g, by(year)
forvalues i=2013(1)2023 {
	gen share_dl_`i' = tot_re_dl/tot_en_dl if year == `i'
	gen share_g_`i' = tot_re_g/tot_en_g if year == `i'
	list share_dl_`i' share_g_`i' year, clean noobs
}
gen share_re_dl = 0 
gen share_re_g = 0 
forv i = 2013(1)2023 {
replace share_re_dl = (share_dl_`i')*100 if year == `i'
replace share_re_g = (share_g_`i')*100 if year == `i'
}
list year share_re_dl share_re_g, clean noobs
twoway (line share_re_dl year, lc(dkgreen) lpattern(solid)) ///
(line share_re_g year, lc(dkgreen) lpattern(shortdash)) ///
, xla(2013(1)2023) ///
ylab(0(15)70, grid angle(0) labsize(small)) ///
legend(order(1 "Direct lending" 2 "Guarantees")) ///
xtitle("") xline(2015.5 2019.5 2021.5, lp(dash) lc(red) lwidth(medthick)) 
graph save "RE_share", replace
restore 


grc1leg2 guarantees_only.gph directlending_only.gph RE_share.gph, r(3) leg(guarantees_only.gph) pos(3) lr(9) 


graph export Fig1_final, as(png) replace


*/




/* New vars Fig2



replace period = 1 if inlist(year, 2013, 2014, 2015)
replace period = 2 if inlist(year, 2016, 2017, 2018, 2019) 
replace period = 3 if inlist(year, 2020, 2021)
replace period = 4 if inlist(year, 2022, 2023)

* value chain by year and type of fuel 

drop v_c1_coal-v_c5_coal v_c1_oil-v_c5_oil v_c1_oil-v_c5_gas

forv i = 1(1)5 {
	bys period: egen v_c`i'_coal = sum(v/1000) if v_c==`i' & coal == 1 
}


local names Upstream Midstream Downstream Power_generation Electricity_infrastructure
foreach var of varlist v_c1_coal-v_c5_coal {
    local list `list' `var'
}
forvalues i=1(1)5 {
        local name : word `i' of `names'
        local varname : word `i' of `list'
        label variable `varname' `name'
}


forv i = 1(1)5 {
	bys period: egen v_c`i'_oil = sum(v/1000) if v_c==`i' & oil == 1 
}

local names Upstream Midstream Downstream Power_generation Electricity_infrastructure
foreach var of varlist v_c1_oil-v_c5_oil {
    local list `list' `var'
}
forvalues i=1(1)5 {
        local name : word `i' of `names'
        local varname : word `i' of `list'
        label variable `varname' `name'
}

forv i = 1(1)5 {
	bys period: egen v_c`i'_gas = sum(v/1000) if v_c==`i' & gas == 1 
}

local names Upstream Midstream Downstream Power_generation Electricity_infrastructure
foreach var of varlist v_c1_oil-v_c5_gas {
    local list `list' `var'
}
forvalues i=1(1)5 {
        local name : word `i' of `names'
        local varname : word `i' of `list'
        label variable `varname' `name'
}


forv i = 1(1)5 {
	bys period: egen v_c`i'_fossil = sum(v/1000) if v_c==`i' & ff == 1 
}

local names Upstream Midstream Downstream Power_generation Electricity_infrastructure
foreach var of varlist v_c1_fossil-v_c5_fossil {
    local list `list' `var'
}
forvalues i=1(1)5 {
        local name : word `i' of `names'
        local varname : word `i' of `list'
        label variable `varname' `name'
}


label define period_labs 1 "Pre-Paris" 2 "Post-Paris" 3 "Pandemic" 4 "Post-Glasgow"

label values period period_labs

gen ff_energy_source = 0 
replace ff_energy_source = 1 if coal == 1 
replace ff_energy_source = 2 if oil == 1 
replace ff_energy_source = 3 if gas == 1 
replace ff_energy_source = 4 if o_g_mixed == 1 // mixed O&G 

label define ff_energy_source_labs 1 "Coal" 2 "Oil" 3 "Gas" 4 "O&G_mixed"

label values ff_energy_source ff_energy_source_labs

* Wind offshore, Wind onshore, Wind (unspecified), Solar PV, Solar thermal, Solar (unspecified), Biogas, Biomass or Geothermal, other RE 

gen re_energy_source = 0 
replace re_energy_source = 1 if tech_fine == 8 // offshore 
replace re_energy_source = 2 if inlist(tech_fine, 9, 10) // onshore or unspecified but typically onshore 
replace re_energy_source = 3 if tech_fine == 11 // Solar PV 
replace re_energy_source = 4 if tech_fine == 13 | tech_fine == 14 // Hydro  
replace re_energy_source = 5 if inlist(tech_fine, 12, 15, 16, 17, 18, 19) // Biogas, Biomass and Geothermal, waste-to-energy, solar PV and other (mixed RE)


label define re_energy_source_labs 1 "Offshore wind" 2 "Onshore wind" ///
 3 "Solar PV" 4 "Hydro" 5 "Other renewables or mixed"

label values re_energy_source re_energy_source_labs



*/

/* Fig 2: Value chains FF by type of energy and period



preserve
keep if ff_energy_source == 1  | period == 4
collapse (max) v_c1_coal-v_c4_coal, by(period)
forvalues i = 1(1)4 {
	replace v_c`i'_coal = (v_c`i'_coal / 3) if period==1
}
forvalues i = 1(1)4 {
	replace v_c`i'_coal = (v_c`i'_coal / 4) if period==2
}
forvalues i = 1(1)4 {
	replace v_c`i'_coal = (v_c`i'_coal / 2) if period==3
}
forvalues i = 1(1)4 {
	replace v_c`i'_coal = (v_c`i'_coal / 2) if period==4
}
graph bar v_c1_coal-v_c4_coal, ///
over(period, relabel(1 "P1" 2 "P2" 3 "P3" 4 "P4")) ///
stack ///
title(Coal, box bexpand bcolor(gs1*0.4)) ///
bar(1, col("237 248 251") lp(solid) lw(vthin)) ///
bar(2, col("179 205 227") lp(solid) lw(vthin)) ///
bar(3, col("140 150 198") lp(solid) lw(vthin)) ///
bar(4, col("136 65 157") fi(inten30) lp(solid) lw(vthin) lc("136 65 157%30")) ///
graphregion(color(white)) yla(0(2)15, angle(0)) ///
legend(order(1 "Upstream" 2 "Midstream" 3 "Downstream" 4 "Power Generation - Fossil") title("Element of the value chain", size(small)) pos(6) col(4) size(vsmall) region(lp(blank)))
graph save "Coal", replace
restore 



preserve 
keep if ff_energy_source == 2 
collapse (max) v_c1_oil-v_c4_oil, by(period)
forvalues i = 1(1)4 {
	replace v_c`i'_oil = (v_c`i'_oil / 3) if period==1
}

forvalues i = 1(1)4 {
	replace v_c`i'_oil = (v_c`i'_oil / 4) if period==2
}

forvalues i = 1(1)4 {
	replace v_c`i'_oil = (v_c`i'_oil / 2) if period==3
}

forvalues i = 1(1)4 {
	replace v_c`i'_oil = (v_c`i'_oil / 2) if period==4
}

graph bar  v_c1_oil-v_c4_oil, ///
over(period, relabel(1 "P1" 2 "P2" 3 "P3" 4 "P4")) stack leg(off) title(Oil, box bexpand bcolor(gs1*0.3)) ///
bar(1, col("237 248 251") lp(solid) lw(vthin)) ///
bar(2, col("179 205 227") lp(solid) lw(vthin)) ///
bar(3, col("140 150 198") lp(solid) lw(vthin)) ///
bar(4, col("136 65 157") fi(inten30) lp(solid) lw(vthin) lc("136 65 157%30")) ///
graphregion(color(white)) yla(0(2)15, nolab)
graph save "Oil", replace
restore 

preserve 
keep if ff_energy_source == 3
collapse (max) v_c1_gas-v_c4_gas, by(period)
forvalues i = 1(1)4 {
	replace v_c`i'_gas = (v_c`i'_gas / 3) if period==1
}

forvalues i = 1(1)4 {
	replace v_c`i'_gas = (v_c`i'_gas / 4) if period==2
}

forvalues i = 1(1)4 {
	replace v_c`i'_gas = (v_c`i'_gas / 2) if period==3
}

forvalues i = 1(1)4 {
	replace v_c`i'_gas = (v_c`i'_gas / 2) if period==4
}

graph bar v_c1_gas-v_c4_gas, ///
over(period, relabel(1 "P1" 2 "P2" 3 "P3" 4 "P4")) stack ///
title(Gas, box bexpand bcolor(gs1*0.2)) ///
leg(off) ///
bar(1, col("237 248 251") lp(solid) lw(vthin)) ///
bar(2, col("179 205 227") lp(solid) lw(vthin)) ///
bar(3, col("140 150 198") lp(solid) lw(vthin)) ///
bar(4, col("136 65 157") fi(inten30) lp(solid) lw(vthin) lc("136 65 157%30")) ///
graphregion(color(white)) yla(0(2)15, nolab)
graph save "Gas", replace
restore 


preserve
forv i = 1(1)5 {
	bys year: egen tech_fine_`i' = sum(v/1000) if re_energy_source==`i'
}
collapse (max) tech_fine_1-tech_fine_5, by(period)
forvalues i = 1(1)5 {
	replace tech_fine_`i' = ( tech_fine_`i' / 3) if period==1
}
forvalues i = 1(1)5 {
	replace tech_fine_`i' = ( tech_fine_`i' / 4) if period==2
}
forvalues i = 1(1)5 {
	replace tech_fine_`i' = ( tech_fine_`i' / 2) if period==3
}
forvalues i = 1(1)5 {
	replace tech_fine_`i' = ( tech_fine_`i' / 2) if period==4
}

graph bar tech_fine_1-tech_fine_5, ///
over(period, relabel(1 "P1" 2 "P2" 3 "P3" 4 "P4")) ///
stack ///
title(Renewables, box bexpand bcolor(green*0.2)) ///
bar(1, col(green*1.2) lp(solid) fi(inten100)) ///
bar(2, col(green*1.2) lp(solid) fi(inten80)) ///
bar(3, col(green*0.15) lp(solid) fi(inten30)) ///
bar(4, col(green*0.4) lp(sold) fi(inten40)) ///
bar(5, col(green*0.8) lp(solid) fi(inten60)) ///
graphregion(color(white)) yla(0(2)15, grid nolab) ///
legend(order(5 "Other or mixed" ///
4 "Hydro" 3 "Solar PV" 2 "Wind (onshore)" 1 "Wind (offshore)") title(Power generation - Renewables, size(small)) size(vsmall) pos(3) col(1))
graph save "Renewables", replace
restore 



grc1leg2 Coal.gph Oil.gph Gas.gph Renewables.gph, r(1) loff graphregion(color(white)) ycom 

graph export, as(png) name("Fig2") quality(100) replace 

// legend code: relabel(1 `""Pre-Paris" "{it:(2013-15)}""' 2 `""Post-Paris" "{it:(2016-19)}""' 3 `""Pandemic" "{it:(2020-21)}""' 4 `""Post-Glasgow" "{it:(2022-23)}""')

*/



/* Fig3: Upper element of the graph  

gen e3f = 0 
replace e3f = 1 if inlist(ecacountry, "Belgium", "Denmark", "Finland", "France", "Germany") | ///
inlist(ecacountry, "Italy", "Netherlands", "Spain", "Sweden", "United Kingdom")

* Upper element of the graph 

preserve 
clonevar ecacountry5 = ecacountry

replace ecacountry5 = "Non-E3F" if e3f == 0 
replace ecacountry5 = "E3F" if e3f == 1 

drop tot_en_p* tot_ff_p* tot_re_p* tot_other_p*

forv i = 1(1)4 {
bys ecacountry5: egen tot_en_p`i' = sum(v/1000) if p`i' == 1 
}
forv i = 1(1)4 {
bys ecacountry5: egen tot_ff_p`i' = sum(v/1000) if ff == 1 & p`i' == 1 
}
forv i = 1(1)4 {
bys ecacountry5: egen tot_re_p`i' = sum(v/1000) if re == 1 & p`i' == 1 
}
forv i = 1(1)4 {
bys ecacountry5: egen tot_other_p`i' = sum(v/1000) if other == 3 & p`i' == 1 
}
	collapse (max) tot_en_p1  tot_en_p2 tot_en_p3 tot_en_p4 tot_ff_p1 tot_ff_p2 tot_ff_p3 tot_ff_p4 tot_re_p1 tot_re_p2 tot_re_p3 tot_re_p4 tot_other_p1 tot_other_p2	tot_other_p3 tot_other_p4, by(ecacountry5)
	foreach x of varlist tot_en_p1 tot_en_p2 tot_en_p3 tot_en_p4 tot_ff_p1 tot_ff_p2 tot_ff_p3 tot_ff_p4 tot_re_p1 tot_re_p2 tot_re_p3 tot_re_p4 tot_other_p1 tot_other_p2 tot_other_p3 tot_other_p4 {
	replace `x' = 0 if (`x' == .) 
	}
		foreach var of varlist tot_en_p1 tot_ff_p1 tot_re_p1 tot_other_p1 {
	gen av_`var' = `var'/ 3 
	}
	foreach var of varlist tot_en_p2 tot_ff_p2 tot_re_p2 tot_other_p2 {
	gen av_`var' = `var'/ 4 
	}
	foreach var of varlist tot_en_p3 tot_ff_p3 tot_re_p3 tot_other_p3 {
	gen av_`var' = `var'/ 2
	}
	foreach var of varlist tot_en_p4 tot_ff_p4 tot_re_p4 tot_other_p4 {
	gen av_`var' = `var'/ 2
	}
	graph bar (mean) av_tot_ff_p1 av_tot_re_p1 av_tot_other_p1, ///
	over(ecacountry5, rev label(labsize(medium))) ///
	stack yla(0(5)27, nolab) /// 
	bar(1, color(gs1*0.6) ls(none)) ///
	bar(2, color(green*0.6) ls(none)) ///
	bar(3, color(orange*0.6) ls(none)) ///
	title(Pre-Paris (2013-2015), size(medium) box bexpand bcolor(gs1*0.1)) ///
	legend(order(1 "Fossil" 2 "Renewables" 3 "Grid") col(3) region(lcolor(none))) 
	graph save p1, replace
	graph bar (mean) av_tot_ff_p2 av_tot_re_p2 av_tot_other_p2, ///
	over(ecacountry5, rev label(labsize(medium))) ///
	stack yla(0(5)27, nolab) ///
	bar(1, color(gs1*0.6) ls(none)) ///
	bar(2, color(green*0.6) ls(none)) ///
	bar(3, color(orange*0.6) ls(none)) ///
	title(Post-Paris (2016-2019), size(medium) box bexpand bcolor(gs1*0.1))
	graph save p2, replace
	graph bar (mean) av_tot_ff_p3 av_tot_re_p3 av_tot_other_p3, ///
	over(ecacountry5, rev label(labsize(medium))) ///
	stack yla(0(5)27, nolab) ///
	bar(1, color(gs1*0.6) ls(none)) ///
	bar(2, color(green*0.6) ls(none)) ///
	bar(3, color(orange*0.6) ls(none)) ///
	title(Pandemic (2020-2021), size(medium) box bexpand bcolor(gs1*0.1))
	graph save p3, replace
	graph bar (mean) av_tot_ff_p4 av_tot_re_p4 av_tot_other_p4, ///
	over(ecacountry5, rev label(labsize(medium))) ///
	stack yla(0(5)27, nolab) ///
	bar(1, color(gs1*0.6) ls(none)) ///
	bar(2, color(green*0.6) ls(none)) ///
	bar(3, color(orange*0.6) ls(none)) ///
	title(Post-Glasgow (2022-2023), size(medium) box bexpand bcolor(gs1*0.1))
	graph save p4, replace
restore

grc1leg2 p1.gph p2.gph p3.gph p4.gph, r(1) pos(6) saving(Fig3_upper, replace)


*/



/* Fig3: Middle element, non-E3F countries by period 

/*
gen e3f = 0 
replace e3f = 1 if inlist(ecacountry, "Belgium", "Denmark", "Finland", "France", "Germany") | ///
inlist(ecacountry, "Italy", "Netherlands", "Spain", "Sweden", "United Kingdom")
*/

* Japan
preserve 
drop tot_ff tot_re tot_other
egen tot_ff = total(v/1000) if ff == 1, by(period ecacountry)
egen tot_re = total(v/1000) if re == 1, by(period ecacountry)
egen tot_other = total(v/1000) if other == 3, by(period ecacountry)
keep if ecacountry == "Japan"
	collapse (mean) tot_ff tot_re tot_other, by(period)
	foreach x of varlist tot_ff tot_re tot_other {
	replace `x' = 0 if (`x' == .) 
	}
	list  
	gen p1 = (tot_ff / (tot_ff + tot_re + tot_other))*100 
	gen p2 = ((tot_ff + tot_re) /  (tot_ff + tot_re + tot_other))*100
	gen p3 = 100
	gen zero = 0
	twoway rarea zero p1 period, fcolor(gs1*0.6) lc(black) lw(vthin) lstyle(solid) ///
	|| rarea p1 p2 period, fcolor(green*0.6) lc(black) lw(vthin) lstyle(solid) ///
	|| rarea p2 p3 period, fcolor(orange*0.6) lc(black) lw(vthin) lstyle(solid) ///
	||, legend(order(1 "Fossil" 2 "Renewables" 3 "Grid") r(1) size(small) region(lp(blank))) /// 
     ytitle("") yla(0(25)100, angle(0) labsize(medium) nolab) ///
	 title(Japan (39%), size(medium) box bexpand bcolor(gs1*0.1)) xtitle("") ///
	 xla(1 "P1" 2 "P2" 3 "P3" 4 "P4", labsize(medium))
	 graph save japan_rel, replace
restore

* Korea
preserve 
drop tot_ff tot_re tot_other
egen tot_ff = total(v/1000) if ff == 1, by(period ecacountry)
egen tot_re = total(v/1000) if re == 1, by(period ecacountry)
egen tot_other = total(v/1000) if other == 3, by(period ecacountry)
keep if ecacountry == "Korea"
	collapse (mean) tot_ff tot_re tot_other, by(period)
	foreach x of varlist tot_ff tot_re tot_other {
	replace `x' = 0 if (`x' == .) 
	}
	list 
	gen p1 = tot_ff / (tot_ff + tot_re + tot_other) 
	gen p2 = (tot_ff + tot_re) /  (tot_ff + tot_re + tot_other)
	gen p3 = 1
	gen zero = 0
	twoway rarea zero p1 period, fcolor(gs1*0.6) lc(black) lw(vthin) lstyle(solid) ///
	|| rarea p1 p2 period, fcolor(green*0.6) lc(black) lw(vthin) lstyle(solid) ///
	|| rarea p2 p3 period, fcolor(orange*0.6) lc(black) lw(vthin) lstyle(solid) ///
	||, legend(order(1 "Fossil" 2 "Renewables" 3 "Grid")) /// 
    ytitle("") ylab(, nolabel grid) ///
	 title(Korea (27%), size(medium) box bexpand bcolor(gs1*0.1)) xtitle("") ///
	 xla(1 "P1" 2 "P2" 3 "P3" 4 "P4", labsize(medium))
	 list, clean noobs
	graph save korea_rel, replace
restore

* China
preserve 
drop tot_ff tot_re tot_other
egen tot_ff = total(v/1000) if ff == 1, by(period ecacountry)
egen tot_re = total(v/1000) if re == 1, by(period ecacountry)
egen tot_other = total(v/1000) if other == 3, by(period ecacountry)
keep if ecacountry == "China"
	collapse (mean) tot_ff tot_re tot_other, by(period)
	foreach x of varlist tot_ff tot_re tot_other {
	replace `x' = 0 if (`x' == .) 
	}
	list 
	gen p1 = tot_ff / (tot_ff + tot_re + tot_other) 
	gen p2 = (tot_ff + tot_re) /  (tot_ff + tot_re + tot_other)
	gen p3 = 1
	gen zero = 0
	twoway rarea zero p1 period, fcolor(gs1*0.6) lc(black) lw(vthin) lstyle(solid) ///
	|| rarea p1 p2 period, fcolor(green*0.6) lc(black) lw(vthin) lstyle(solid) ///
	|| rarea p2 p3 period, fcolor(orange*0.6) lc(black) lw(vthin) lstyle(solid) ///
	||, legend(order(1 "Fossil" 2 "Renewables" 3 "Grid")) /// 
     ytitle("") ylab(, nolabel grid) ///
	 title(China (14%), size(medium) box bexpand bcolor(gs1*0.1)) xtitle("") ///
	 xla(1 "P1" 2 "P2" 3 "P3" 4 "P4", labsize(medium))
	graph save china_rel, replace
restore

* All other non-E3F countries 
preserve 
gen all_others_none3f = 0
replace all_others_none3f = 1 if !inlist(ecacountry, "Japan", "Korea", "China") & e3f != 1
drop tot_ff tot_re tot_other
egen tot_ff = total(v/1000) if ff == 1, by(period all_others_none3f)
egen tot_re = total(v/1000) if re == 1, by(period all_others_none3f)
egen tot_other = total(v/1000) if other == 3, by(period all_others_none3f)
keep if all_others_none3f == 1 
	collapse (mean) tot_ff tot_re tot_other, by(period)
	foreach x of varlist tot_ff tot_re tot_other {
	replace `x' = 0 if (`x' == .) 
	}
	list 
	gen p1 = tot_ff / (tot_ff + tot_re + tot_other) 
	gen p2 = (tot_ff + tot_re) /  (tot_ff + tot_re + tot_other)
	gen p3 = 1
	gen zero = 0
	twoway rarea zero p1 period, fcolor(gs1*0.6) lc(black) lw(vthin) lstyle(solid) ///
	|| rarea p1 p2 period, fcolor(green*0.6) lc(black) lw(vthin) lstyle(solid) ///
	|| rarea p2 p3 period, fcolor(orange*0.6) lc(black) lw(vthin) lstyle(solid) ///
	||, legend(order(1 "Fossil" 2 "Renewables" 3 "Grid")) /// 
    ytitle("") ylab(, nolabel grid) ///
	 title(All other non-E3F (20%), size(medium) box bexpand bcolor(gs1*0.1)) ///
	 xtitle("") xla(1 "P1" 2 "P2" 3 "P3" 4 "P4", labsize(medium))
	graph save all_others_none3f_rel, replace
restore

* Portfolio shifts E3F countries
* Italy
preserve 
drop tot_ff tot_re tot_other
egen tot_ff = total(v/1000) if ff == 1, by(period ecacountry)
egen tot_re = total(v/1000) if re == 1, by(period ecacountry)
egen tot_other = total(v/1000) if other == 3, by(period ecacountry)
keep if ecacountry == "Italy"
	collapse (mean) tot_ff tot_re tot_other, by(period)
	foreach x of varlist tot_ff tot_re tot_other {
	replace `x' = 0 if (`x' == .) 
	}
	list 
	gen p1 = tot_ff / (tot_ff + tot_re + tot_other) 
	gen p2 = (tot_ff + tot_re) /  (tot_ff + tot_re + tot_other)
	gen p3 = 1
	gen zero = 0
	twoway rarea zero p1 period, fcolor(gs1*0.6) lc(black) lw(vthin) lstyle(solid) ///
	|| rarea p1 p2 period, fcolor(green*0.6) lc(black) lw(vthin) lstyle(solid) ///
	|| rarea p2 p3 period, fcolor(orange*0.6) lc(black) lw(vthin) lstyle(solid) ///
	||, legend(order(1 "Fossil" 2 "Renewables" 3 "Grid")) /// 
    ytitle("") yla(0(0.25)1, nolab) ///
	 title(Italy (29%), size(medium) box bexpand bcolor(gs1*0.1)) xtitle("") ///
	 xla(1 "P1" 2 "P2" 3 "P3" 4 "P4",  labsize(medium))
	 graph save italy_rel, replace
restore

* Denmark
preserve 
drop tot_ff tot_re tot_other
egen tot_ff = total(v/1000) if ff == 1, by(period ecacountry)
egen tot_re = total(v/1000) if re == 1, by(period ecacountry)
egen tot_other = total(v/1000) if other == 3, by(period ecacountry)
keep if ecacountry == "Denmark"
	collapse (mean) tot_ff tot_re tot_other, by(period)
	foreach x of varlist tot_ff tot_re tot_other {
	replace `x' = 0 if (`x' == .) 
	}
	list 
	gen p1 = tot_ff / (tot_ff + tot_re + tot_other) 
	gen p2 = (tot_ff + tot_re) /  (tot_ff + tot_re + tot_other)
	gen p3 = 1
	gen zero = 0
	twoway rarea zero p1 period, fcolor(gs1*0.6) lc(black) lw(vthin) lstyle(solid) ///
	|| rarea p1 p2 period, fcolor(green*0.6) lc(black) lw(vthin) lstyle(solid) ///
	|| rarea p2 p3 period, fcolor(orange*0.6) lc(black) lw(vthin) lstyle(solid) ///
	||, legend(order(1 "Fossil" 2 "Renewables" 3 "Grid")) /// 
    ytitle("") ylab(, nolabel grid) ///
	 title(Denmark (20%), size(medium) box bexpand bcolor(gs1*0.1)) xtitle("") ///
	 xla(1 "P1" 2 "P2" 3 "P3" 4 "P4",  labsize(medium))
	graph save denmark_rel, replace
restore

* Germany
preserve 
drop tot_ff tot_re tot_other
egen tot_ff = total(v/1000) if ff == 1, by(period ecacountry)
egen tot_re = total(v/1000) if re == 1, by(period ecacountry)
egen tot_other = total(v/1000) if other == 3, by(period ecacountry)
keep if ecacountry == "Germany"
	collapse (mean) tot_ff tot_re tot_other, by(period)
	foreach x of varlist tot_ff tot_re tot_other {
	replace `x' = 0 if (`x' == .) 
	}
	list 
	gen p1 = tot_ff / (tot_ff + tot_re + tot_other) 
	gen p2 = (tot_ff + tot_re) /  (tot_ff + tot_re + tot_other)
	gen p3 = 1
	gen zero = 0
	twoway rarea zero p1 period, fcolor(gs1*0.6) lc(black) lw(vthin) lstyle(solid) ///
	|| rarea p1 p2 period, fcolor(green*0.6) lc(black) lw(vthin) lstyle(solid) ///
	|| rarea p2 p3 period, fcolor(orange*0.6) lc(black) lw(vthin) lstyle(solid) ///
	||, legend(order(1 "Fossil" 2 "Renewables" 3 "Grid")) /// 
     ytitle("") ylab(, nolabel grid) ///
	 title(Germany (19%), size(medium) box bexpand bcolor(gs1*0.1)) xtitle("") ///
	 xla(1 "P1" 2 "P2" 3 "P3" 4 "P4", labsize(medium))
	graph save germany_rel, replace
	list period p1 p2 p3, clean noobs
restore

* Other E3F countries 
preserve 
gen all_others_e3f = 0
replace all_others_e3f = 1 if !inlist(ecacountry, "Italy", "Denmark", "Germany") & e3f == 1
drop tot_ff tot_re tot_other
egen tot_ff = total(v/1000) if ff == 1, by(period all_others_e3f)
egen tot_re = total(v/1000) if re == 1, by(period all_others_e3f)
egen tot_other = total(v/1000) if other == 3, by(period all_others_e3f)
keep if all_others_e3f == 1 
	collapse (mean) tot_ff tot_re tot_other, by(period)
	foreach x of varlist tot_ff tot_re tot_other {
	replace `x' = 0 if (`x' == .) 
	}
	list 
	gen p1 = tot_ff / (tot_ff + tot_re + tot_other) 
	gen p2 = (tot_ff + tot_re) /  (tot_ff + tot_re + tot_other)
	gen p3 = 1
	gen zero = 0
	twoway rarea zero p1 period, fcolor(gs1*0.6) lc(black) lw(vthin) lstyle(solid) ///
	|| rarea p1 p2 period, fcolor(green*0.6) lc(black) lw(vthin) lstyle(solid) ///
	|| rarea p2 p3 period, fcolor(orange*0.6) lc(black) lw(vthin) lstyle(solid) ///
	|| rarea p2 p3 period, fcolor(orange*0.6) lc(black) lw(vthin) lstyle(solid) ///
	||, legend(order(1 "Fossil" 2 "Renewables" 3 "Grid")) /// 
     ytitle("") ylab(, nolabel grid) ///
	 title(All other E3F (32%), size(medium) box bexpand bcolor(gs1*0.1)) /// 
	  xtitle("") xla(1 "P1" 2 "P2" 3 "P3" 4 "P4", labsize(medium))
	graph save all_others_e3f_rel, replace
restore


grc1leg2 p1.gph p2.gph p3.gph p4.gph ///
japan_rel.gph korea_rel.gph china_rel.gph all_others_none3f_rel.gph ///
italy_rel.gph denmark_rel.gph germany_rel.gph all_others_e3f_rel.gph, r(3) loff 

graph export "/Users/pcenskow/Library/CloudStorage/OneDrive-UniversitédeLausanne/ECA paper/Final paper/Figures/Fig 3/Graph.pdf", as(pdf) name("Graph") replace 


*/


/* Fig3: Country share over total by group 

* Non-E3F
preserve 
gen all_others_none3f = 0
replace all_others_none3f = 1 if !inlist(ecacountry, "Japan", "Korea", "China") & e3f != 1
clonevar ecacountry_none3f = ecacountry
replace ecacountry_none3f = "Japan" if ecacountry == "Japan"
replace ecacountry_none3f = "Korea" if ecacountry == "Korea"
replace ecacountry_none3f = "China" if ecacountry == "China"
replace ecacountry_none3f = "All other non-E3F" if all_others_none3f == 1
drop tot_en_country
keep if e3f != 1 
egen tot_en_all_years = sum(v/1000)
bys ecacountry_none3f: egen tot_en_country = sum(v/1000)
collapse (max) tot_en_country tot_en_all_years, by(ecacountry_none3f)
gen share_total = tot_en_country/tot_en_all_years
gsort -tot_en_country
list, clean noobs
restore 

* E3F
preserve 
gen e3f_other = 0
replace e3f_other = 1 if inlist(ecacountry, "Spain", "France", "Netherlands", "Sweden", "Finland", "Belgium", "United Kingdom")
clonevar ecacountry_e3f = ecacountry
replace ecacountry_e3f = "All other E3F" if e3f_other == 1
drop tot_en_country
keep if e3f == 1 
egen tot_en_all_years = sum(v/1000)
bys ecacountry_e3f: egen tot_en_country = sum(v/1000)
collapse (max) tot_en_country tot_en_all_years, by(ecacountry_e3f)
gen share_total = tot_en_country/tot_en_all_years
gsort -tot_en_country
list, clean noobs
restore 


* RE share by country 
preserve 
gen all_others_none3f = 0
replace all_others_none3f = 1 if !inlist(ecacountry, "Japan", "Korea", "China") & e3f != 1
drop tot_en_country 
keep if all_others_none3f == 1 | inlist(ecacountry, "Japan", "Korea", "China", "United States")
bys ecacountry3: egen tot_en_country = sum(v/1000)
bys ecacountry3: egen tot_en_country_re = sum(v/1000) if re == 1 
collapse (max) tot_en_country tot_en_country_re, by(ecacountry3)
gen share_re = tot_en_country_re/tot_en_country
gsort -tot_en_country
list, clean noobs
restore 



*/



* Fig 4: Financing structure  

* DV_bn 

preserve 
gen all_energy = 0 
replace all_energy = 1 if energy_source == 1
replace all_energy = 2 if energy_source == 2 
replace all_energy = 3 if energy_source == 3 // exclude mixed O&G deals
replace all_energy = 4 if energy_source == 5 // Wind
replace all_energy = 5 if energy_source == 6 // Solar
replace all_energy = 6 if inlist(energy_source, 7, 8)  // Hydro and other RE 
replace all_energy = 7 if other == 3 // Grid
replace all_energy = 8 if other == 1 & dv_bn == 0 // Nuclear
label define all_energy_labs 1 "Coal" 2 "Oil" 3 "Gas" 4 "Wind" 5 "Solar" ///
6 "Hydro and other RET" 7 "Grid" 8 "Nuclear"
label values all_energy all_energy_labs
collapse(max) dv_bn, by(tmddealid all_energy)
keep if inlist(all_energy, 1, 2, 3, 4, 5, 6, 7)
egen tag = tag(tmddealid)
keep if tag == 1 
graph hbox dv_bn, over(all_energy, relabel(1 "Coal" 2 "Oil" 3 "Gas" 4 "Wind" 5 "Solar" 6 "Other RET" 7 "Grid")) asyvars showyvars leg(off) /// 
yla(0(4)22, grid angle(0)) ytitle("") ///
box(1, color(gs1*0.8) lp(solid) lw(medium)) ///
box(2, color(gs1*0.6)  lp(solid) lw(medium)) ///
box(3, color(gs1*0.4) lp(solid) lw(medium)) ///
box(4, color(green*1.2) lp(solid) lw(medium)) ///
box(5, color(green*0.8) lp(solid) lw(medium)) ///
box(6, color(green*0.4) lp(solid) lw(medium)) ///
box(7, color(orange*0.8) lp(solid) lw(medium)) ///
marker(1, mcolor(gs1*0.8)) ///
marker(2, mcolor(gs1*0.6)) ///
marker(3, mcolor(gs1*0.4)) ///
marker(4, mcolor(green*1.2)) ///
marker(5, mcolor(green*0.8)) ///
marker(6, mcolor(green*0.4)) ///
marker(7, mcolor(orange*0.8))
codebook tmddealid
graph save dealvolumes, replace
restore 


* Zoom-in  

preserve 
gen all_energy = 0 
replace all_energy = 1 if energy_source == 1
replace all_energy = 2 if energy_source == 2 
replace all_energy = 3 if energy_source == 3 
replace all_energy = 4 if energy_source == 5 // Wind
replace all_energy = 5 if energy_source == 6 // Solar
replace all_energy = 6 if inlist(energy_source, 7, 8)  // Hydro and other RE 
replace all_energy = 7 if other == 3 // Grid
replace all_energy = 8 if other == 1 & dv_bn < 15 // Nuclear
label define all_energy_labs 1 "Coal" 2 "Oil" 3 "Gas" 4 "Wind" 5 "Solar" ///
6 "Hydro and other RET" 7 "Grid" 8 "Nuclear"
label values all_energy all_energy_labs
collapse(max) dv, by(tmddealid all_energy)
keep if inlist(all_energy, 1, 2, 3, 4, 5, 6, 7)
egen tag = tag(tmddealid)
keep if tag == 1 
graph hbox dv, over(all_energy, relabel(1 "Coal" 2 "Oil" 3 "Gas" 4 "Wind" 5 "Solar" 6 "Other RET" 7 "Grid")) asyvars showyvars leg(off) /// 
yla(0(400)2450, grid angle(0)) ytitle("") ///
box(1, color(gs1*0.8) lp(solid) lw(medium)) ///
box(2, color(gs1*0.6)  lp(solid) lw(medium)) ///
box(3, color(gs1*0.4) lp(solid) lw(medium)) ///
box(4, color(green*1.2) lp(solid) lw(medium)) ///
box(5, color(green*0.8) lp(solid) lw(medium)) ///
box(6, color(green*0.4) lp(solid) lw(medium)) ///
box(7, color(orange*0.8) lp(solid) lw(medium)) ///
marker(1, mcolor(gs1*0.8)) ///
marker(2, mcolor(gs1*0.6)) ///
marker(3, mcolor(gs1*0.4)) ///
marker(4, mcolor(green*1.2)) ///
marker(5, mcolor(green*0.8)) ///
marker(6, mcolor(green*0.4)) ///
marker(7, mcolor(orange*0.8)) nooutsides 
summarize dv if all_energy == 2, d
summarize dv if all_energy == 3, d
summarize dv if all_energy == 4, d
summarize dv if all_energy == 5, d
summarize dv if all_energy == 7, d
graph save zoom_in_dealvolumes, replace

restore 

graph export "/Users/pcenskow/Library/CloudStorage/OneDrive-UniversitédeLausanne/ECA paper/Final paper/Figures/Fig 4/dealvolumes_zoomin.png", as(png) name("Graph") replace


*D Tenor by period and energy 

preserve 
gen all_energy = 0 
replace all_energy = 1 if energy_source == 1
replace all_energy = 2 if energy_source == 2 
replace all_energy = 3 if energy_source == 3 
replace all_energy = 4 if energy_source == 5 // Wind
replace all_energy = 5 if energy_source == 6 // Solar
replace all_energy = 6 if inlist(energy_source, 7, 8)  // Hydro and other RE 
replace all_energy = 7 if other == 3 // Grid
replace all_energy = 8 if other == 1 // Nuclear
label define all_energy_labs 1 "Coal" 2 "Oil" 3 "Gas" 4 "Wind" 5 "Solar" ///
6 "Hydro and other RET" 7 "Grid" 8 "Nuclear"
label values all_energy all_energy_labs
collapse(max) tenor_num, by(uniquetrancheid all_energy)
keep if inlist(all_energy, 1, 2, 3, 4, 5, 6, 7)
egen tag = tag(uniquetrancheid)
keep if tag == 1 
graph hbox tenor_num, over(all_energy, relabel(1 "Coal" 2 "Oil" 3 "Gas" 4 "Wind" 5 "Solar" 6 "Other RET" 7 "Grid") label(nolab)) asyvars showyvars leg(off) /// 
yla(0(10)42, grid angle(0)) ytitle("") ///
box(1, color(gs1*0.8) lp(solid) lw(medium)) ///
box(2, color(gs1*0.6)  lp(solid) lw(medium)) ///
box(3, color(gs1*0.4) lp(solid) lw(medium)) ///
box(4, color(green*1.2) lp(solid) lw(medium)) ///
box(5, color(green*0.8) lp(solid) lw(medium)) ///
box(6, color(green*0.4) lp(solid) lw(medium)) ///
box(7, color(orange*0.8) lp(solid) lw(medium)) ///
marker(1, mcolor(gs1*0.8)) ///
marker(2, mcolor(gs1*0.6)) ///
marker(3, mcolor(gs1*0.4)) ///
marker(4, mcolor(green*1.2)) ///
marker(5, mcolor(green*0.8)) ///
marker(6, mcolor(green*0.4)) ///
marker(7, mcolor(orange*0.8)) 
graph save Tenor, replace

restore 

graph export "/Users/pcenskow/Library/CloudStorage/OneDrive-UniversitédeLausanne/ECA paper/Final paper/Figures/Fig 4/hbar_tenor.png", as(png) name("Graph") replace



bar(1, col("237 248 251") lp(solid) lw(vthin)) ///
bar(2, col("179 205 227") lp(solid) lw(vthin)) ///
bar(3, col("140 150 198") lp(solid) lw(vthin)) ///
bar(4, col("136 65 157") fi(inten30) lp(solid)

* E Borrower type 

preserve 
gen all_energy = 0 
replace all_energy = 1 if energy_source == 1
replace all_energy = 2 if energy_source == 2 
replace all_energy = 3 if energy_source == 3 
replace all_energy = 4 if energy_source == 5 // Wind
replace all_energy = 5 if energy_source == 6 // Solar
replace all_energy = 6 if inlist(energy_source, 7, 8)  // Hydro and other RE 
replace all_energy = 7 if other == 3 // Grid
replace all_energy = 8 if other == 1 // Nuclear
label define all_energy_labs 1 "Coal" 2 "Oil" 3 "Gas" 4 "Wind" 5 "Solar" ///
6 "Other RET" 7 "Grid" 8 "Nuclear"
label values all_energy all_energy_labs
keep if inlist(all_energy, 1, 2, 3, 4, 5, 6, 7)
egen tag = tag(uniquetrancheid)
keep if tag == 1 
gen borrowertype3 = 0 
replace borrowertype3 = 1 if borrowertype2 == 1 // SPV
replace borrowertype3 = 2 if inlist(borrowertype2, 2, 4) // Other private
replace borrowertype3 = 3 if inlist(borrowertype2, 3, 5) // Public

forv i = 1(1)3 {
	egen id_bt_`i' = count(uniquetrancheid) if borrowertype3 == `i'
}
graph hbar (sum) id_bt_1-id_bt_3, over(all_energy) percentage stack ///
bar(1, color("237 248 251") lc(black) lw(vthin) lstyle(solid)) ///
bar(2, color("179 205 227") lc(black) lw(vthin) lstyle(solid)) ///
bar(3, color("136 65 157") lc(black) lw(vthin) lstyle(solid)) ///
yla(, angle(0)) legend(order(1 "Special purpose vehicle" 2 "Other private" 3 "Public") r(1) ///
size(small) symxsize(4) symysize(4) region(lp(blank))) ///
intensity(*0.7) graphregion(color(white)) ytitle("") 
graph save bt, replace
restore 

graph export "/Users/pcenskow/Library/CloudStorage/OneDrive-UniversitédeLausanne/ECA paper/Final paper/Figures/Fig 4/bt_ final final .png", as(png) name("Graph") replace



* Tranche structure 

preserve 
gen all_energy = 0 
replace all_energy = 1 if energy_source == 1
replace all_energy = 2 if energy_source == 2 
replace all_energy = 3 if energy_source == 3 
replace all_energy = 4 if energy_source == 5 // Wind
replace all_energy = 5 if energy_source == 6 // Solar
replace all_energy = 6 if inlist(energy_source, 7, 8)  // Hydro and other RE 
replace all_energy = 7 if other == 3 // Grid
replace all_energy = 8 if other == 1 // Nuclear
label define all_energy_labs 1 "Coal" 2 "Oil" 3 "Gas" 4 "Wind" 5 "Solar" ///
6 "Other RET" 7 "Grid" 8 "Nuclear"
label values all_energy all_energy_labs
keep if inlist(all_energy, 1, 2, 3, 4, 5, 6, 7)
egen tag = tag(uniquetrancheid)
keep if tag == 1 

gen fintype = 0 
replace fintype = 1 if inlist(tranchestructure, "ECA-backed buyer credit", "ECA-backed buyer credit (DCM)")
replace fintype = 2 if inlist(tranchestructure, "ECA-backed supplier credit", "ECA-Backed Islamic Finance", "ECA-backed  general purpose LOC", "ECA-backed performance bond", "ECA-Direct Loan") 
replace fintype = 3 if inlist(tranchestructure, "DFI/MDB Direct Loan", "DFI/MDB-backed Loan")
replace fintype = 4 if !inlist(fintype, 1, 2, 3) 

label define fin_type 1 "ECA-backed loans (via guarantees)" 2 "Other ECA instruments (e.g., loans)" 3 "Other public"  4 "Other private" 5 "Other private"

label values fintype fin_type

tab fintype

forv i = 1(1)4 {
	egen id_ft_`i' = count(uniquetrancheid) if fintype == `i'
}

graph hbar (sum) id_ft_1-id_ft_4, over(all_energy, label(nolab)) percentage stack ///
bar(1, color("255 255 204") lc(black) lw(vthin) lstyle(solid)) ///
bar(2, color("161 218 180") lc(black) lw(vthin) lstyle(solid)) ///
bar(3, color(" 65 182 196") lc(black) lw(vthin) lstyle(solid)) ///
bar(4, color("44 127 184") lc(black) lw(vthin) lstyle(solid)) ///
bar(5, color("37 52 148") lc(black) lw(vthin) lstyle(solid)) ///
yla(, angle(0)) legend(order(1 "ECA-backed loans (via guarantees)" 2 "Other ECA instruments (e.g., loans)" ///
3 "Other public (e.g., MDBs)" 4 "Other private (e.g., term loans)") ///
r(3) ///
size(small) symxsize(4) symysize(4) region(lp(blank))) ///
intensity(*0.7) graphregion(color(white)) ytitle("") 
graph save tranche_type, replace
tab tranchestructure if fintype == 2
tab tranchestructure if fintype == 3
tab tranchestructure if fintype == 4
restore 

graph export "/Users/pcenskow/Library/CloudStorage/OneDrive-UniversitédeLausanne/ECA paper/Final paper/Figures/Fig 4/tranche_type.png", as(png) name("Graph") replace



// other private less only 49 tranches or 3.46% --> kick out




*/


