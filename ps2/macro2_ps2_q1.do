// Code for Problem 2, Macro II by Prof. Schularick
// done by Sugarkhuu, Omer, Jerome


// install necessary packages 
// ssc install estout
// ssc install labutil // panel labels, labmask
// ssc install ivreg2, replace
// ssc install xtivreg2, replace
// ssc install ranktest, replace


clear all
cls

* load data
use "JSTdataset.dta"
drop if year > 2013
xtset ifs year // set as panel
labmask ifs, values(country) // country names linked to ifs


* 1.1
gen z = dibaseF*peg*l.peg*openquinn/100
lab var z "z (trilemma instrument, pp)"
gen d_stir = d.stir
// F = 175.01 > much larger than 10. Stock-Yogo weak ID test 10% crit val 16.38
eststo model: ivreg2 rgdppc (d_stir = z), first bw(5)
regress d_stir z


// graph twoway (scatter d_stir z) (lfit d_stir z), ///
// 	legend(off) ytitle("Change in Local short-term interest rate, pp")
// graph export "figures/z2stir.png", replace

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
xtset ifs year // set as panel

local y_list lrgdp lcpi lcred lstocks
local ctrl_list lrgdppc lrconpc linvpc lcpi ltrate lrhp lrstocks cred2gdp lw_gdp // stir


eststo clear
//creating fwd
foreach x in `y_list' {
	forv h = 0/4 {
	gen `x'`h' = f`h'.`x' - l.`x'
	//eststo model`x'`h': xtivreg2 `x'`h' l(0/2).d.(`ctrl_list') l(1/2).d.stir (d_stir = z), fe first bw(5) 
		}
}
/*
esttab, se keep(d_stir)

matrix C = r(coefs) // matrix list C
eststo clear

// shock and lag result table 
local fwds 0 1 2 3 4
local y_names 'GDP' "CPI" "Credit" "Stock prices"  

local i 0  // loop var on lags                    
foreach ifwd in `fwds' {
     local ++i
     local j 0                     // loop var on shock

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

local title = "Responses to 1 pp monetary shock in period h, 100*log change from year 0 baseline"
esttab using tables\table_1_2.tex, replace  b(%5.2f) se(%5.2f) /// 
title(`title') /// 
nonumbers nodepvars noobs ///
mtitles("h=0" "h=1" "h=2" "h=3" "h=4") ///
*/
* 2
bysort year : gen tmp = stir if country == "USA"  
bysort year : egen stir_usd = total(tmp)          // log world gdp per year
drop tmp
bysort year : gen tmp = z if country == "USA"     // log world gdp per year
bysort year : egen z_usd = total(tmp) 
replace z_usd = . if z_usd == 0 

xtset ifs year // set as panel
gen d_stir_usd = d.stir_usd

local y_list lrgdp lstocks

eststo clear
foreach x in `y_list' {
	forv h = 0/4 {
	eststo model`x'`h': xtreg `x'`h' l(0/2).d.(`ctrl_list') l(1/2).d.stir_usd d_stir_usd if country != "USA", fe
		}
}

esttab, se keep(d_stir_usd)

matrix C = r(coefs) // matrix list C
eststo clear

// shock and lag result table 
local fwds 0 1 2 3 4
local y_names "GDP" "Stock prices"  

local i 0  // loop var on lags                    
foreach ifwd in `fwds' {
     local ++i
     local j 0                     // loop var on shock

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

exit

* 3 
RR shock impact
browse annualized_RRextended_shock 


effects of monetary policy on GDP, CPI, credit, and
stock prices. As control variables, use up to two lags of the first differences of: log real GDP per
capita; log real consumption per capita; log real investment per capita; log consumer price index;
short-term interest rate (usually a 3-month government bill); long-term interest rate (usually a 5-
year government bond); log real house prices; log real stock prices; the credit to GDP ratio; and
world GDP growth.




eststo clear
cap drop b u d Years Zero
gen Years = _n-1 if _n<=6
gen Zero =  0    if _n<=6
gen bN=0
gen uN=0
gen dN=0
gen bF=0
gen uF=0
gen dF=0

qui forv h = 0/5 {
xtreg rgdppc`h' stir ltrate, fe
replace bN = _b[stir] + _b[_cons]                     if _n == `h'+1
replace uN = _b[stir] + _b[_cons] + 1.645* _se[stir]  if _n == `h'+1
replace dN = _b[stir] + _b[_cons] - 1.645* _se[stir]  if _n == `h'+1
replace bF = _b[ltrate] + _b[_cons]                     if _n == `h'+1
replace uF = _b[ltrate] + _b[_cons] + 1.645* _se[ltrate]  if _n == `h'+1
replace dF = _b[ltrate] + _b[_cons] - 1.645* _se[ltrate]  if _n == `h'+1
eststo 
}

esttab, se

twoway (line bF bN Years, lcolor(blue) ///
		lpattern(solid) lwidth(thick))


