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
use "ps2\JSTdataset.dta"
drop if year > 2013
xtset ifs year // set as panel
labmask ifs, values(country) // country names linked to ifs



* 1.1
gen z = dibaseF*peg*l.peg*openquinn/100
gen d_stir = d.stir
// F = 175.01 > much larger than 10. Stock-Yogo weak ID test 10% crit val 16.38
eststo model: ivreg2 rgdppc (d_stir = z), first bw(5)
regress d_stir z

graph twoway (scatter d_stir z) (lfitci d_stir z)


* 1.2
gen rgdp     = rgdppc*pop
gen lrgdppc  = 100*ln(rgdppc)
gen lrconpc  = 100*ln(rconpc)
gen linvpc   = 100*ln(iy) + lrgdppc
gen lcpi     = 100*ln(cpi)
gen lcred    = 100*ln(tloans)
gen lrhp     = 100*ln(hpnom/cpi)
gen lstocks  = 100*ln(stocks)
gen lrstocks = 100*ln(stocks/cpi)
gen cred2gdp = tloans/gdp
gen gdpusd   = gdp/xrusd
bysort year : egen w_gdp = total(gdpusd) // world gdp per year
xtset ifs year // set as panel

local y_list rgdp lcpi tloans stocks
local ctrl_list lrgdppc lrconpc linvpc lcpi ltrate lrhp lrstocks cred2gdp gdpusd // stir

//creating fwd
foreach x in `y_list' {
	forv h = 1/5 {
	gen `x'`h' = ln(f`h'.`x') - ln(`x')
	eststo model`x'`h': xtivreg2 `x'`h' l(0/2).d.(`ctrl_list') (d_stir = z), fe first bw(5) 
		}
}

esttab, se

* 2

d_stir_usd = 
global output = 
international stock prices = 

foreach x in `y_list' {
	forv h = 1/5 {
	gen `x'`h' = ln(f`h'.`x') - ln(`x')
	eststo model`x'`h': xtivreg2 `x'`h' l(0/2).d.(`ctrl_list') (d_stir_usd = z), fe first bw(5) 
		}
}


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


