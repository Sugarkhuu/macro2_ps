// Code for Problem 2, Macro II by Prof. Schularick
// done by Sugarkhuu, Omer, Jerome


// install necessary packages 
// ssc install estout
// ssc install labutil // panel labels, labmask
ssc install ivreg2, replace
ssc install xtivreg2, replace
ssc install ranktest, replace


clear all
cls

* load data
use "ps2\JSTdataset.dta"
drop if year > 2013


xtset ifs year // set as panel
labmask ifs, values(country) // country names linked to ifs

gen z = dibaseF*peg*l.peg*openquinn/100
gen d_stir = d.stir

eststo model: ivreg2 rgdppc (d_stir = z), first bw(5)
regress d_stir z
xtline d_stir z

gen rgdp = rgdppc*pop
gen lrgdppc = 100*ln(rgdppc)
gen lrconpc = 100*ln(rconpc)
gen linvpc    = 100*ln(iy) + lrgdppc
gen lcpi    = 100*ln(cpi)
gen lrhp = 100*ln(hpnom/cpi)
gen lrstocks = 100*ln(stocks/cpi)
gen cred2gdp = tloans/gdp
gen gdpusd = gdp/xrusd
bysort year : egen w_gdp = total(gdpusd)
xtset ifs year // set as panel

local y_list rgdp cpi tloans stocks

//creating fwd
foreach x in `y_list' {
	forv h = 0/5 {
	gen `x'`h' = f`h'.`x' - `x'
		}
}

local ctrl_list lrgdppc lrconpc linvpc lcpi stir ltrate lrhp lrstocks cred2gdp gdpusd
eststo model: ivreg2 rgdp l(0/2).d.(`ctrl_list') (d_stir = z), first bw(5)



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


