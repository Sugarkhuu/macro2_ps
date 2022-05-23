clear all
cap drop _all
cap graph drop _all
//ssc install estout, replace

/********************* READ IN THE DATA ***********************/

//use "Z:\Downloads\fiscal_data1930s_Stata13.dta"
use "Y:\mm\fiscal_data1930s_Stata13.dta"

/********************* DATA DECLARATION ***********************/

tsset date, monthly

/********************* DATA MANIPULATION ***********************/

replace	gdp_pc		=	100 * ln(gdp_pc		)
replace	ip			=	100 * ln(ip			)
replace	g_pc		=	100 * ln(g_pc		)
replace	g_mil_pc	=	100 * ln(g_mil_pc	)
replace rev_pc		=	100 * ln(rev_pc		)
replace	wpi			=	100 * ln(wpi		)			
replace	unemp		=	100 * ln(unemp		)


/********************* DATA PLOTTING ***********************/

tsline(g_pc gdp_pc ip g_mil_pc rev_pc wpi unemp), legend(size(vsmall))

estpost correlate g_pc gdp_pc ip g_mil_pc rev_pc wpi unemp
//esttab, unstack
//esttab using"table2.2.1.tex"

/********************* PUBLIC EXPENDITURE RESPONSE TO VARIABLES ***********************/

reg g_pc l(0/6).gdp_pc l(0/6).ip l(0/6).g_mil_pc l(0/6).rev_pc l(0/6).wpi l(0/6).unemp

/********************* LP spending shocks ***********************/

// forward dependent variable creation
foreach x in gdp_pc g_pc {
forv h = 1/60 {
	gen `x'`h' = f`h'.`x' - `x' 			// Use for cumulative IRF 
}
}


eststo clear
gen uN=0
gen dN=0
gen bN=0
gen gN=0
gen months = _n-1 if _n<=25
//gen intcN = 0
//gen slopeN = 0
qui forv h = 1/25 {
reg gdp_pc`h' g_pc l(1/6)gdp_pc l(1/6)g_pc l(1/6)rev_pc /*if year> 1869 & year<= 1912*/ /*cluster(iso)*/

replace bN = _b[g_pc] 					if _n == `h'
replace gN = -_b[g_pc]                  if _n == `h'

replace uN = -_b[g_pc] + 1.645* _se[g_pc]  if _n == `h'+1
replace dN = -_b[g_pc] - 1.645* _se[g_pc]  if _n == `h'+1
/*
replace bF = _b[F] + _b[_cons]                     if _n == `h'+1
replace uF = _b[F] + _b[_cons] + 1.645* _se[F]  if _n == `h'+1
replace dF = _b[F] + _b[_cons] - 1.645* _se[F]  if _n == `h'+1
*/
eststo 
}
esttab , se



twoway	(rarea uN dN  months,  ///
		fcolor(gs13) lcolor(gs13) lw(none) lpattern(solid)) ///
		(line gN months/*if iso=="FRA"*/) ///
		, legend( order(1 "90% CI" 2 "GDP response")) ///
		title("Deviation from GDP Path in 1% drop in Government Spending", size(medium)) ///
		ytitle("Percent") xtitle("Time")
