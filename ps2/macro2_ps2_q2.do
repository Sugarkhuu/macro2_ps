// Code for Problem 2.2, Macro II by Prof. Schularick
// done by Sugarkhuu, Omer, Jerome


// install necessary packages 
ssc install estout

clear all
cls

* load data
use "fiscal_data1930s_Stata13.dta"
tsset date

// Generate 100*log of all, but irate and date
ds date irate, not
foreach ivar of var `r(varlist)' {
	gen l`ivar' = 100*ln(`ivar')
}

// plot gdp and govt
tsline lgdp_pc, ytitle("") xtitle("") title("Real GDP per capita (100*log)", size(small))
gr rename gdp, replace
twoway (tsline lg_pc) (fpfit lg_pc date), ytitle("") xtitle("") title("Real Government Spending per capita and fitted trend (100*log)", size(small)) legend(off)
gr rename govt, replace
gr combine gdp govt
gr export figures\govt.png, replace

// Estimation
local y_list lgdp_pc //g_pc
local ctrl_list lgdp_pc lg_pc lrev_pc 

foreach x in `y_list' {
	forv h = 0/23 {
	gen `x'`h' = f`h'.`x' - l.`x'
		}
}

eststo clear
gen gdp_resp=0                // gdp response stored here
gen months = _n-1 if _n < 25  // only first 24 months

foreach x in `y_list' {
	qui forv h = 0/23 {
		eststo model`x'`h': regress `x'`h' lg_pc l(1/6).d.(`ctrl_list')
		replace gdp_resp = -_b[lg_pc] if _n == `h'+1
eststo 
}
}

twoway (line gdp_resp months, lcolor(blue) ///
		lpattern(solid) lwidth(thick)), ytitle("GDP (percentage)")
gr export figures\gdp2govt.png, replace
