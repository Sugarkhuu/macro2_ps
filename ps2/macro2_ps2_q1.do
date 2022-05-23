// Code for Problem 2.1, Macro II by Prof. Schularick
// done by Sugarkhuu, Omer, Jerome


// install necessary packages 
ssc install estout
ssc install labutil // panel labels, labmask
ssc install ivreg2, replace
ssc install xtivreg2, replace
ssc install ranktest, replace


clear all
cls

* load data
use "JSTdataset.dta"
drop if year > 2013          // no sensible data in 2014-15
xtset ifs year               // set as panel
labmask ifs, values(country) // country names linked to ifs




//////////////////////////////////////////////////////////////////////////////////////////
* 1.1
gen z = dibaseF*peg*l.peg*openquinn/100
lab var z "z (trilemma instrument, pp)"
gen d_stir = d.stir

// Weak instrument test: F = 175.01 > much larger than 10. Stock-Yogo weak ID test 10% crit val 16.38
eststo model: ivreg2 rgdppc (d_stir = z), first
// or simply
regress d_stir z 

// plot d_stir to z
graph twoway (scatter d_stir z) (lfit d_stir z), ///
   	legend(off) ytitle("Change in Local short-term interest rate, pp")
graph export "figures/z2stir.png", replace

* 1.2
gen lrgdp    = 100*ln(rgdppc*pop)
gen lrgdppc  = 100*ln(rgdppc)
gen lrconpc  = 100*ln(rconpc)
gen linvpc   = 100*ln(iy) + lrgdppc // log(inv/y*y/pop) = log(inv/y) + log(y/pop)
gen lcpi     = 100*ln(cpi)
gen lrhp     = 100*ln(hpnom/cpi)
gen lrstocks = 100*ln(stocks/cpi)
gen lcred    = 100*ln(tloans)
gen lstocks  = 100*ln(stocks)
gen cred2gdp = tloans/gdp
gen gdpusd   = gdp/xrusd
bysort year : egen w_gdp = total(gdpusd) // log world gdp per year
gen lw_gdp = 100*ln(w_gdp)

// stir of US in each panel unit
bysort year : gen tmp = stir if country == "USA"  
bysort year : egen stir_usd = total(tmp)          

xtset ifs year // set as panel
gen d_stir_usd = d.stir_usd

// output and control variable lists
local y_list lrgdp lcpi lcred lstocks
local ctrl_list lrgdppc lrconpc linvpc lcpi ltrate lrhp lrstocks cred2gdp lw_gdp  // stir

//creating fwd
foreach x in `y_list' {
	forv h = 0/4 {
	gen `x'`h' = f`h'.`x' - l.`x'
		}
}

// Fixed effect, bw chosen at 2 for two lags (similar for all the specs following) that could generate residual serial correlation. 
eststo clear
foreach x in `y_list' {
	forv h = 0/4 {
	eststo model`x'`h': xtivreg2 `x'`h' l(0/2).d.(`ctrl_list') l(1/2).d_stir (d_stir = z), fe first bw(2)
		}
}

// Create table using C matrix for all models and all "h"
esttab, se keep(d_stir)
matrix C = r(coefs) // matrix list C
eststo clear

local fwds 0 1 2 3 4
local y_names "GDP" "CPI" "Credit" "Stock_prices"  

local i 0  // loop var on fwds                    
foreach ifwd in `fwds' {
     local ++i
     local j 0                     // loop var on depvar

     capture matrix drop b
     capture matrix drop se
     foreach iy in `y_names' {
        local ++j
        matrix tmp = C[1, 3*(`i'-1) + 15*(`j'-1)+1]     // point estimate for n and shock
        matrix colnames tmp = `iy'                 
        matrix b = nullmat(b), tmp
        matrix tmp[1,1] = C[1,3*(`i'-1) + 15*(`j'-1)+2]   // s.e
        matrix se = nullmat(se), tmp
     }
	 ereturn post b
	 quietly estadd matrix se
	 eststo a`i'                // each m=XX column ot the table is saved here
}

local title = "Responses to 1 pp monetary shock in period h, 100*log change from year 0 baseline"
esttab using tables\table_1_2.tex, replace  b(%5.2f) se(%5.2f) /// 
title(`title') /// 
nonumbers nodepvars noobs ///
mtitles("h=0" "h=1" "h=2" "h=3" "h=4") ///




//////////////////////////////////////////////////////////////////////////////////////////
* 2
// Dependent variable list
local y_list lrgdp lstocks

eststo clear
foreach x in `y_list' {
	forv h = 0/4 {
	eststo model`x'`h': xtreg `x'`h' l(0/2).d.(`ctrl_list') l(1/2).d.stir_usd d_stir_usd if country != "USA"
		}
}

esttab, se keep(d_stir_usd)
matrix C = r(coefs) // matrix list C
eststo clear

local fwds 0 1 2 3 4
local y_names "GDP" "Stock_prices"  

local i 0  // loop var on fwds                   
foreach ifwd in `fwds' {
     local ++i
     local j 0                     // loop var on depvar

     capture matrix drop b
     capture matrix drop se
	 capture matrix drop f_stat
     foreach iy in `y_names' {
        local ++j
        matrix tmp = C[1, 3*(`i'-1) + 15*(`j'-1)+1]     // point estimate for n and shock
        matrix colnames tmp = `iy'                 
        matrix b = nullmat(b), tmp
        matrix tmp[1,1] = C[1,3*(`i'-1) + 15*(`j'-1)+2]   // s.e
        matrix se = nullmat(se), tmp
     }
	 ereturn post b
	 quietly estadd matrix se
	 eststo a`i'                // each m=XX column ot the table is saved here
 }

local title = "Responses to 1 pp US monetary shock in period h, 100*log change from year 0 baseline"
esttab using tables\table_2.tex, replace  b(%5.2f) se(%5.2f) /// 
title(`title') /// 
nonumbers nodepvars noobs ///
mtitles("h=0" "h=1" "h=2" "h=3" "h=4") ///




//////////////////////////////////////////////////////////////////////////////////////////
* 3 


// without controls as the sample is short

local y_list lrgdp lcpi
local samples all pre85 post85

foreach isample in `samples' {
eststo clear
foreach x in `y_list' {
	forv h = 0/4 {
		if "`isample'" == "all" {
			eststo model`x'`h': ivreg2 `x'`h' l(0/2).`x' (d_stir = l(1/4).annualized_RRextended_shock  ) if country == "USA", first bw(2)
		} 
		else if "`isample'" == "pre85" {
			eststo model`x'`h': ivreg2 `x'`h' l(0/2).`x' (d_stir = l(1/4).annualized_RRextended_shock  ) if country == "USA" & year<1985, first bw(2)
		}
		else {
			eststo model`x'`h': ivreg2 `x'`h' l(0/2).`x' (d_stir = l(1/4).annualized_RRextended_shock  ) if country == "USA" & year>=1985, first bw(2)
		}
	}
}

esttab, se keep(d_stir)
matrix C = r(coefs) // matrix list C
eststo clear

local fwds 0 1 2 3 4
local y_names "GDP" "CPI"  

local i 0  // loop var on fwds                   
foreach ifwd in `fwds' {
     local ++i
     local j 0                     // loop var on depvar

     capture matrix drop b
     capture matrix drop se
	 capture matrix drop f_stat
     foreach iy in `y_names' {
        local ++j
        matrix tmp = C[1, 3*(`i'-1) + 15*(`j'-1)+1]     // point estimate for n and shock
        matrix colnames tmp = `iy'                 
        matrix b = nullmat(b), tmp
        matrix tmp[1,1] = C[1,3*(`i'-1) + 15*(`j'-1)+2]   // s.e
        matrix se = nullmat(se), tmp
     }
	 ereturn post b
	 quietly estadd matrix se
	 eststo a`i'                // each m=XX column ot the table is saved here
 }

if "`isample'" == "all" {
		local title = "Responses to 1 pp monetary shock in period h, 100*log change from year 0 baseline, USA"
	} 
	else if "`isample'" == "pre85" {
		local title = "Responses to 1 pp monetary shock in period h, 100*log change from year 0 baseline, USA, pre-1985"
	}
	else {
		local title = "Responses to 1 pp monetary shock in period h, 100*log change from year 0 baseline, USA, post-1985"
}
	
esttab using tables\table_3_`isample'.tex, replace  b(%5.2f) se(%5.2f) title(`title') nonumbers nodepvars noobs ///
mtitles("h=0" "h=1" "h=2" "h=3" "h=4")

}