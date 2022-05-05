clear all
cap drop _all
cap graph drop _all
//ssc install estout, replace
//ssc install center, replace

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
//gen dxrusd = xrusd - l.xrusd
//gen fer = 1 if dxrusd == 0
gen fer = peg
replace fer = 0 if missing(fer)
gen N_fer = N*fer
gen F_fer = F*fer
//gen pd_gdp = tloans/gdp
gen pd_gdp = tloans/gdp/xrusd
//by ifs (year) : center pd_gdp
gen c_pd_gdp = pd_gdp
replace  c_pd_gdp = . if ifs == 134 & year <= 1924 

gen N_tloans = N*c_pd_gdp
gen F_tloans = F*c_pd_gdp







//lag creation
foreach x in lgdppc /*lcpi stir*/ {
forv h = 0/5 {
//gen `x'`h' = f`h'.`x' - l.`x' 			// Use for cumulative IRF
gen `x'`h' = f`h'.`x' - `x' 			// Use for cumulative IRF 
//gen `x'_lag_`h'  = `x' - l(`h').`x'
//gen `x'usual`h' = f`h'.`x' - l.f`h'.`x'		// Use for usual IRF

}
}
/*

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



*/




eststo clear
cap drop b u d Years Zero
gen Years = _n-1 if _n<=6
gen Zero =  0    if _n<=6
gen bNL=0
gen uNL=0
gen dNL=0
gen bFL=0
gen uFL=0
gen dFL=0
qui forv h = 0/5 {
xtreg lgdppc`h' N F N_tloans F_tloans  /*if year> 1869 & year<= 1912*/, fe /*cluster(iso)*/ //the effect of tloans only at the time of recessions-crises for all regressions
replace bNL = _b[N] + _b[_cons]                     if _n == `h'+1
replace uNL = _b[N] + _b[_cons] + 1.645* _se[N]  if _n == `h'+1
replace dNL = _b[N] + _b[_cons] - 1.645* _se[N]  if _n == `h'+1
replace bFL = _b[F] + _b[_cons]                     if _n == `h'+1
replace uFL = _b[F] + _b[_cons] + 1.645* _se[F]  if _n == `h'+1
replace dFL = _b[F] + _b[_cons] - 1.645* _se[F]  if _n == `h'+1
eststo 
}

esttab, se // for standard error






// -------------------------------------------------------------- //

// ALL

eststo clear
qui forv h = 0/5 {
xtreg lgdppc`h' N F N_fer F_fer /*if year> 1869 & year<= 1912*/, fe /*cluster(iso)*/ //the effect of tloans only at the time of recessions-crises for all regressions
replace bNL = _b[N] + _b[_cons]                     if _n == `h'+1
replace uNL = _b[N] + _b[_cons] + 1.645* _se[N]  if _n == `h'+1
replace dNL = _b[N] + _b[_cons] - 1.645* _se[N]  if _n == `h'+1
replace bFL = _b[F] + _b[_cons]                     if _n == `h'+1
replace uFL = _b[F] + _b[_cons] + 1.645* _se[F]  if _n == `h'+1
replace dFL = _b[F] + _b[_cons] - 1.645* _se[F]  if _n == `h'+1
eststo 
}

esttab, se // for standard error


// Without WAR

eststo clear
qui forv h = 0/5 {
xtreg lgdppc`h' N F N_fer F_fer if year< 1912 | (year> 1924 & year< 1936) | year> 1950/*if year> 1869 & year<= 1912*/, fe /*cluster(iso)*/ //the effect of tloans only at the time of recessions-crises for all regressions
replace bNL = _b[N] + _b[_cons]                     if _n == `h'+1
replace uNL = _b[N] + _b[_cons] + 1.645* _se[N]  if _n == `h'+1
replace dNL = _b[N] + _b[_cons] - 1.645* _se[N]  if _n == `h'+1
replace bFL = _b[F] + _b[_cons]                     if _n == `h'+1
replace uFL = _b[F] + _b[_cons] + 1.645* _se[F]  if _n == `h'+1
replace dFL = _b[F] + _b[_cons] - 1.645* _se[F]  if _n == `h'+1
eststo 
}

esttab, se // for standard error

//
//





/*
twoway ///
		(rarea uF dF  Years,  ///
		fcolor(gs13) lcolor(gs13) lw(none) lpattern(solid)) ///
		(line bN bNL Years, lcolor(blue) ///
		lpattern(solid) lwidth(thick)) /// 
		(line Zero Years, lcolor(black)), legend(off) ///
		title("F", color(black) size(medsmall)) ///
		ytitle("Percent", size(medsmall)) xtitle("Year", size(medsmall)) ///
		graphregion(color(white)) plotregion(color(white))
		
		gr rename g_N , replace

		
twoway ///
		(rarea uF dF  Years,  ///
		fcolor(gs13) lcolor(gs13) lw(none) lpattern(solid)) ///
		(line bF bFL Years, lcolor(blue) ///
		lpattern(solid) lwidth(thick)) /// 
		(line Zero Years, lcolor(black)), legend(off) ///
		title("F", color(black) size(medsmall)) ///
		ytitle("Percent", size(medsmall)) xtitle("Year", size(medsmall)) ///
		graphregion(color(white)) plotregion(color(white))
		
		gr rename g_F , replace


gr combine g_N g_F

*/











