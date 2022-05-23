clear all
cap drop _all
cap graph drop _all
//ssc install estout, replace

/********************* READ IN THE DATA ***********************/
use http://data.macrohistory.net/JST/JSTdatasetR5.dta
merge 1:1 year iso using "Z:\Downloads\RecessionDummies.dta" // path
// 

sort ifs year								/* ifs indicates the country */
xtset  ifs year, yearly

replace N = 0 if missing(N)
replace F = 0 if missing(F)

//drop  if year >= 1912 & year <= 1923
//drop  if year >= 1937 & year <= 1950
//drop  if year > 2008

/******************** Some Data transformations ***************/
gen lgdppc = 100*ln(rgdppc)				/* convert to rgdp to lrgdp */


//lag creation
foreach x in lgdppc /*lcpi stir*/ {
forv h = 0/8 {
//gen `x'`h' = f`h'.`x' - l.`x' 			// Use for cumulative IRF
gen `x'`h' = f`h'.`x' - `x' 			// Use for cumulative IRF 
//gen `x'_lag_`h'  = `x' - l(`h').`x'
//gen `x'usual`h' = f`h'.`x' - l.f`h'.`x'		// Use for usual IRF

}
}

eststo clear
cap drop b u d Years Zero
gen Years = _n-1 if _n<=9
gen Zero =  0    if _n<=9
gen bN=0
gen uN=0
gen dN=0
gen bF=0
gen uF=0
gen dF=0
gen intcN = 0
gen slopeN = 0
qui forv h = 0/8 {
xtreg lgdppc`h' N F /*if year> 1869 & year<= 1912*/, fe /*cluster(iso)*/
replace bN = _b[N] + _b[_cons]                     if _n == `h'+1
replace uN = _b[N] + _b[_cons] + 1.645* _se[N]  if _n == `h'+1
replace dN = _b[N] + _b[_cons] - 1.645* _se[N]  if _n == `h'+1
replace bF = _b[F] + _b[_cons]                     if _n == `h'+1
replace uF = _b[F] + _b[_cons] + 1.645* _se[F]  if _n == `h'+1
replace dF = _b[F] + _b[_cons] - 1.645* _se[F]  if _n == `h'+1
eststo 
}


esttab, se // for standard error
// browse 
// tabulate F N
// esttab using table.tex, se





twoway ///
		(line bF bN Years, lcolor(blue red) ///
		lpattern(solid) lwidth(thick)) /// 
		/*(rarea uF dF  Years,  ///
		fcolor(blue%25) lcolor(blue%25) lw(none) lpattern(solid)) ///
		(rarea uN dN  Years,  ///
		fcolor(red%25) lcolor(red%25) lw(none) lpattern(solid)) */ ///
		(line Zero Years, lcolor(black)), legend(on) ///
		title("Cumulative Paths of Real GDP per Capita", color(black) size(vsmall)) ///
		ytitle("Percent", size(medsmall)) xtitle("Year", size(medsmall)) ///
		graphregion(color(white)) plotregion(color(white)) ///
		legend( order(1 "Financial" 2 "Non-Financial" 3 "90% CI Financial" 4 "90% CI Non-Financial") size(vsmall))
		
		gr rename g_NF_with_war , replace
	
//----------- without War-Years that is paper's methodology to remove some noise

eststo clear
qui forv h = 0/8 {
xtreg lgdppc`h' N F if year< 1912 | (year> 1923 & year< 1936) | year> 1950 , fe /*cluster(iso)*/
//replace intcN = _b[N]
//replace slopeN = _b[N]
replace bN = _b[N] + _b[_cons]                     if _n == `h'+1
replace uN = _b[N] + _b[_cons] + 1.645* _se[N]  if _n == `h'+1
replace dN = _b[N] + _b[_cons] - 1.645* _se[N]  if _n == `h'+1
replace bF = _b[F] + _b[_cons]                     if _n == `h'+1
replace uF = _b[F] + _b[_cons] + 1.645* _se[F]  if _n == `h'+1
replace dF = _b[F] + _b[_cons] - 1.645* _se[F]  if _n == `h'+1
eststo 
}


esttab, se // for standard error
// browse 
// tabulate F N
// esttab using table.tex, se



/*(rarea uF dF  Years,  ///
		fcolor(blue%25) lcolor(blue%25) lw(none) lpattern(solid)) ///
		(rarea uN dN  Years,  ///
		fcolor(red%25) lcolor(red%25) lw(none) lpattern(solid)) /// */

twoway ///
		(line bF bN Years, lcolor(blue red) ///
		lpattern(solid) lwidth(thick)) /// 
		(rarea Zero Zero  Years,  ///
		fcolor(blue%25) lcolor(blue%25) lw(none) lpattern(solid)) ///
		(line Zero Years, lcolor(black)), legend(on) ///
		title("Cumulative Paths of Real GDP per Capita excluding War Period", color(black) size(vsmall)) ///
		ytitle("Percent", size(medsmall)) xtitle("Year", size(medsmall)) ///
		graphregion(color(white)) plotregion(color(white)) ///
		legend( order(1 "Financial" 2 "Non-Financial" 3 "90% CI Financial" 4 "90% CI Non-Financial") size(vsmall))
		
		gr rename g_NF_without_war , replace
		
gr combine g_NF_with_war g_NF_without_war
	
/*	
twoway ///
		(rarea uF dF  Years,  ///
		fcolor(gs13) lcolor(gs13) lw(none) lpattern(solid)) ///
		(line bF Years, lcolor(blue) ///
		lpattern(solid) lwidth(thick)) /// 
		(line Zero Years, lcolor(black)), legend(off) ///
		title("F", color(black) size(medsmall)) ///
		ytitle("Percent", size(medsmall)) xtitle("Year", size(medsmall)) ///
		graphregion(color(white)) plotregion(color(white))
		
		gr rename g_F , replace


gr combine g_N g_F

*/










