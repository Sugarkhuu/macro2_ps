// Code for Problem 2.2, Macro II by Prof. Schularick
// done by Sugarkhuu, Omer, Jerome


// install necessary packages 
ssc install estout

clear all
cls

use "fiscal_data1930s_Stata13.dta"

// Generate 100*log of all, but irate and date
ds date irate, not
foreach ivar of var `r(varlist)' {
	gen l`ivar' = 100*ln(`ivar')
}

tsset date

local y_list gdp_pc //g_pc
local ctrl_list gdp_pc g_pc rev_pc // stir

foreach x in `y_list' {
	forv h = 0/23 {
	gen `x'`h' = f`h'.`x' - l.`x'
		}
}

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

foreach x in `y_list' {
qui forv h = 0/23 {
eststo model`x'`h': regress `x'`h' g_pc l(1/6).d.(`ctrl_list')
replace bN = -_b[g_pc]                     if _n == `h'+1
replace uN = _b[g_pc] + _b[_cons] + 1.645* _se[g_pc]  if _n == `h'+1
replace dN = _b[g_pc] + _b[_cons] - 1.645* _se[g_pc]  if _n == `h'+1
replace bF = -_b[g_pc]                      if _n == `h'+1
replace uF = _b[g_pc] + _b[_cons] + 1.645* _se[g_pc]  if _n == `h'+1
replace dF = _b[g_pc] + _b[_cons] - 1.645* _se[g_pc]  if _n == `h'+1

// replace bN = _b[g_pc] + _b[_cons]                     if _n == `h'+1
// replace uN = _b[g_pc] + _b[_cons] + 1.645* _se[g_pc]  if _n == `h'+1
// replace dN = _b[g_pc] + _b[_cons] - 1.645* _se[g_pc]  if _n == `h'+1
// replace bF = _b[g_pc] + _b[_cons]                     if _n == `h'+1
// replace uF = _b[g_pc] + _b[_cons] + 1.645* _se[g_pc]  if _n == `h'+1
// replace dF = _b[g_pc] + _b[_cons] - 1.645* _se[g_pc]  if _n == `h'+1

eststo 
}

esttab, se

twoway (line bF bN date, lcolor(blue) ///
		lpattern(solid) lwidth(thick))
}
