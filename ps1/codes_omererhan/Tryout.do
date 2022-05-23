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
gen rpci = 100*ln(rgdppc*iy)
//gen rgdp = rgdppc * pop
//gen defl = gdp/rgdp
gen defl = cpi
gen inf = d.defl/l.defl *100 // inflation
//gen rstir = ((1+stir)/(1+inf)-1 ) *100 // fischer equation to get real stir may use apprx.
//gen rltir = ((1+ltrate)/(1+inf)-1) *100 // fischer equation to get real ltir
gen rstir = (stir - inf)  // fischer equation appr // stir is also in percentages)
gen rltir = (ltrate - inf)  // fischer equation appr
//gen tcred = thh + tbus
gen tcred = tloans
gen rtcred = tcred/(defl /* *gdp also might be divided to normalize*/) //instead can use cpi
gen lrtcred = 100*ln(rtcred)
//gen cpii = (cpi- l.cpi) /cpi
gen cpii = inf



replace  cpii = . if year >= 1912 & year <= 1924 //one less year to remove additional noise
replace  cpii = . if year >= 1937 & year <= 1950

//lag creation
foreach x in lgdppc rconpc rpci rstir rltir lrtcred cpii  /*lcpi stir*/ {
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
qui forv h = 0/8 {
xtreg rconpc`h' N F /*if year> 1869 & year<= 1912*/ , fe /*cluster(iso)*/
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
		/*(rarea Zero Zero  Years,  ///
		fcolor(gs13) lcolor(gs13) lw(none) lpattern(solid)) */ ///
		(line bF bN Years, lcolor(blue) ///
		lpattern(solid) lwidth(thick)) /// 
		(line Zero Years, lcolor(black)), legend(on) ///
		title("Cumulative Path of Real per capita Consumption", color(black) size(vsmall)) ///
		ytitle("Percent", size(medsmall)) xtitle("Year", size(medsmall)) ///
		graphregion(color(white)) plotregion(color(white)) ///
		legend( order(1 "Financial" 2 "Non-Financial") size(vsmall) region(lwidth(none)))  
		
		gr rename g_rconpc , replace
eststo clear
qui forv h = 0/8 {		
xtreg rpci`h' N F /*if year> 1869 & year<= 1912*/ , fe /*cluster(iso)*/
replace bN = _b[N] + _b[_cons]                     if _n == `h'+1
replace uN = _b[N] + _b[_cons] + 1.645* _se[N]  if _n == `h'+1
replace dN = _b[N] + _b[_cons] - 1.645* _se[N]  if _n == `h'+1
replace bF = _b[F] + _b[_cons]                     if _n == `h'+1
replace uF = _b[F] + _b[_cons] + 1.645* _se[F]  if _n == `h'+1
replace dF = _b[F] + _b[_cons] - 1.645* _se[F]  if _n == `h'+1
eststo 
}


esttab, se // for standard error

twoway ///
		/*(rarea Zero Zero  Years,  ///
		fcolor(gs13) lcolor(gs13) lw(none) lpattern(solid))*/ ///
		(line bF bN Years, lcolor(blue) ///
		lpattern(solid) lwidth(thick)) /// 
		(line Zero Years, lcolor(black)), legend(on) ///
		title("Cumulative Path Real percapita Investment", color(black) size(vsmall)) ///
		ytitle("Percent", size(medsmall)) xtitle("Year", size(medsmall)) ///
		graphregion(color(white)) plotregion(color(white)) ///
		legend( order(1 "Financial" 2 "Non-Financial") size(vsmall) region(lwidth(none)))
		
		gr rename g_rpci , replace
eststo clear
qui forv h = 0/8 {	
xtreg rstir`h' N F /*if year> 1869 & year<= 1912*/ , fe /*cluster(iso)*/
replace bN = _b[N] + _b[_cons]                     if _n == `h'+1
replace uN = _b[N] + _b[_cons] + 1.645* _se[N]  if _n == `h'+1
replace dN = _b[N] + _b[_cons] - 1.645* _se[N]  if _n == `h'+1
replace bF = _b[F] + _b[_cons]                     if _n == `h'+1
replace uF = _b[F] + _b[_cons] + 1.645* _se[F]  if _n == `h'+1
replace dF = _b[F] + _b[_cons] - 1.645* _se[F]  if _n == `h'+1
eststo 
}


esttab, se // for standard error
		

twoway ///
		/*(rarea Zero Zero  Years,  ///
		 fcolor(gs13) lcolor(gs13) lw(none) lpattern(solid)) */ ///
		(line bF bN Years, lcolor(blue)  ///
		lpattern(solid) lwidth(thick))  /// 
		(line Zero Years, lcolor(black)), legend(on) ///
		title("Cumulative Path of Real Short Term Interest Rate", color(black) size(vsmall)) ///
		ytitle("Percent", size(medsmall)) xtitle("Year", size(medsmall)) ///
		graphregion(color(white)) plotregion(color(white)) ///
		legend( order(1 "Financial" 2 "Non-Financial") size(vsmall) region(lwidth(none)))
		
		gr rename g_rstir , replace
eststo clear
qui forv h = 0/8 {
xtreg rltir`h' N F /*if year> 1869 & year<= 1912*/ , fe /*cluster(iso)*/
replace bN = _b[N] + _b[_cons]                     if _n == `h'+1
replace uN = _b[N] + _b[_cons] + 1.645* _se[N]  if _n == `h'+1
replace dN = _b[N] + _b[_cons] - 1.645* _se[N]  if _n == `h'+1
replace bF = _b[F] + _b[_cons]                     if _n == `h'+1
replace uF = _b[F] + _b[_cons] + 1.645* _se[F]  if _n == `h'+1
replace dF = _b[F] + _b[_cons] - 1.645* _se[F]  if _n == `h'+1
eststo 
}
esttab, se // for standard error

twoway ///
		/*(rarea Zero Zero  Years,  ///
		fcolor(gs13) lcolor(gs13) lw(none) lpattern(solid)) */ ///
		(line bF bN Years, lcolor(blue) ///
		lpattern(solid) lwidth(thick)) /// 
		(line Zero Years, lcolor(black)), legend(on) ///
		title("Cumulative Path of Real Long Term Interest Rate", color(black) size(vsmall)) ///
		ytitle("Percent", size(medsmall)) xtitle("Year", size(medsmall)) ///
		graphregion(color(white)) plotregion(color(white)) ///
		legend( order(1 "Financial" 2 "Non-Financial") size(vsmall) region(lwidth(none)))
		
		gr rename g_rltir , replace
eststo clear
qui forv h = 0/8 {
xtreg lrtcred`h' N F /*if year> 1869 & year<= 1912*/ , fe /*cluster(iso)*/
replace bN = _b[N] + _b[_cons]                     if _n == `h'+1
replace uN = _b[N] + _b[_cons] + 1.645* _se[N]  if _n == `h'+1
replace dN = _b[N] + _b[_cons] - 1.645* _se[N]  if _n == `h'+1
replace bF = _b[F] + _b[_cons]                     if _n == `h'+1
replace uF = _b[F] + _b[_cons] + 1.645* _se[F]  if _n == `h'+1
replace dF = _b[F] + _b[_cons] - 1.645* _se[F]  if _n == `h'+1
eststo 
}
esttab, se // for standard error

twoway ///
		/*(rarea Zero Zero  Years,  ///
		fcolor(gs13) lcolor(gs13) lw(none) lpattern(solid)) */ ///
		(line bF bN Years, lcolor(blue) ///
		lpattern(solid) lwidth(thick)) /// 
		(line Zero Years, lcolor(black)), legend(on) ///
		title("Cumulative Path of Real Credit", color(black) size(vsmall)) ///
		ytitle("Percent", size(medsmall)) xtitle("Year", size(medsmall)) ///
		graphregion(color(white)) plotregion(color(white)) ///
		legend( order(1 "Financial" 2 "Non-Financial") size(vsmall) region(lwidth(none)))
		
		gr rename g_rtcred , replace
eststo clear
qui forv h = 0/8 {
xtreg cpii`h' N F /*if year> 1869 & year<= 1912*/ , fe /*cluster(iso)*/
replace bN = _b[N] + _b[_cons]                     if _n == `h'+1
replace uN = _b[N] + _b[_cons] + 1.645* _se[N]  if _n == `h'+1
replace dN = _b[N] + _b[_cons] - 1.645* _se[N]  if _n == `h'+1
replace bF = _b[F] + _b[_cons]                     if _n == `h'+1
replace uF = _b[F] + _b[_cons] + 1.645* _se[F]  if _n == `h'+1
replace dF = _b[F] + _b[_cons] - 1.645* _se[F]  if _n == `h'+1
eststo 
}
esttab, se // for standard error

twoway ///
		/*(rarea Zero Zero  Years,  ///
		fcolor(gs13) lcolor(gs13) lw(none) lpattern(solid)) */ ///
		(line bF bN Years, lcolor(blue) ///
		lpattern(solid) lwidth(thick)) /// 
		(line Zero Years, lcolor(black)), legend(on) ///
		title("Cumulative Path of CPI Inflation", color(black) size(vsmall)) ///
		ytitle("Percent", size(medsmall)) xtitle("Year", size(medsmall)) ///
		graphregion(color(white)) plotregion(color(white)) ///
		legend( order(1 "Financial" 2 "Non-Financial") size(vsmall) region(lwidth(none)))
		
		gr rename g_cpii , replace
		

gr combine g_rconpc g_rpci g_rstir g_rltir g_rtcred g_cpii
	
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









// ---------------------------------------w/o WAR









/*



qui forv h = 0/8 {
xtreg rconpc`h' N F if year< 1912 | (year> 1923 & year< 1936) | year> 1950 /*if year> 1869 & year<= 1912*/ , fe /*cluster(iso)*/
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
		/*(rarea Zero Zero  Years,  ///
		fcolor(gs13) lcolor(gs13) lw(none) lpattern(solid)) */ ///
		(line bF bN Years, lcolor(blue) ///
		lpattern(solid) lwidth(thick)) /// 
		(line Zero Years, lcolor(black)), legend(on) ///
		title("Cumulative Path of Real per capita Consumption", color(black) size(vsmall)) ///
		ytitle("Percent", size(medsmall)) xtitle("Year", size(medsmall)) ///
		graphregion(color(white)) plotregion(color(white)) ///
		legend( order(1 "Financial" 2 "Non-Financial") size(vsmall) region(lwidth(none)))  
		
		gr rename g_rconpc , replace
eststo clear
qui forv h = 0/8 {		
xtreg rpci`h' N F if year< 1912 | (year> 1923 & year< 1936) | year> 1950 /*if year> 1869 & year<= 1912*/ , fe /*cluster(iso)*/
replace bN = _b[N] + _b[_cons]                     if _n == `h'+1
replace uN = _b[N] + _b[_cons] + 1.645* _se[N]  if _n == `h'+1
replace dN = _b[N] + _b[_cons] - 1.645* _se[N]  if _n == `h'+1
replace bF = _b[F] + _b[_cons]                     if _n == `h'+1
replace uF = _b[F] + _b[_cons] + 1.645* _se[F]  if _n == `h'+1
replace dF = _b[F] + _b[_cons] - 1.645* _se[F]  if _n == `h'+1
eststo 
}


esttab, se // for standard error

twoway ///
		/*(rarea Zero Zero  Years,  ///
		fcolor(gs13) lcolor(gs13) lw(none) lpattern(solid))*/ ///
		(line bF bN Years, lcolor(blue) ///
		lpattern(solid) lwidth(thick)) /// 
		(line Zero Years, lcolor(black)), legend(on) ///
		title("Cumulative Path Real percapita Investment", color(black) size(vsmall)) ///
		ytitle("Percent", size(medsmall)) xtitle("Year", size(medsmall)) ///
		graphregion(color(white)) plotregion(color(white)) ///
		legend( order(1 "Financial" 2 "Non-Financial") size(vsmall) region(lwidth(none)))
		
		gr rename g_rpci , replace
eststo clear
qui forv h = 0/8 {	
xtreg rstir`h' N F if year< 1912 | (year> 1923 & year< 1936) | year> 1950 /*if year> 1869 & year<= 1912*/ , fe /*cluster(iso)*/
replace bN = _b[N] + _b[_cons]                     if _n == `h'+1
replace uN = _b[N] + _b[_cons] + 1.645* _se[N]  if _n == `h'+1
replace dN = _b[N] + _b[_cons] - 1.645* _se[N]  if _n == `h'+1
replace bF = _b[F] + _b[_cons]                     if _n == `h'+1
replace uF = _b[F] + _b[_cons] + 1.645* _se[F]  if _n == `h'+1
replace dF = _b[F] + _b[_cons] - 1.645* _se[F]  if _n == `h'+1
eststo 
}


esttab, se // for standard error
		

twoway ///
		/*(rarea Zero Zero  Years,  ///
		 fcolor(gs13) lcolor(gs13) lw(none) lpattern(solid)) */ ///
		(line bF bN Years, lcolor(blue)  ///
		lpattern(solid) lwidth(thick))  /// 
		(line Zero Years, lcolor(black)), legend(on) ///
		title("Cumulative Path of Real Short Term Interest Rate", color(black) size(vsmall)) ///
		ytitle("Percent", size(medsmall)) xtitle("Year", size(medsmall)) ///
		graphregion(color(white)) plotregion(color(white)) ///
		legend( order(1 "Financial" 2 "Non-Financial") size(vsmall) region(lwidth(none)))
		
		gr rename g_rstir , replace
eststo clear
qui forv h = 0/8 {
xtreg rltir`h' N F if year< 1912 | (year> 1923 & year< 1936) | year> 1950 /*if year> 1869 & year<= 1912*/ , fe /*cluster(iso)*/
replace bN = _b[N] + _b[_cons]                     if _n == `h'+1
replace uN = _b[N] + _b[_cons] + 1.645* _se[N]  if _n == `h'+1
replace dN = _b[N] + _b[_cons] - 1.645* _se[N]  if _n == `h'+1
replace bF = _b[F] + _b[_cons]                     if _n == `h'+1
replace uF = _b[F] + _b[_cons] + 1.645* _se[F]  if _n == `h'+1
replace dF = _b[F] + _b[_cons] - 1.645* _se[F]  if _n == `h'+1
eststo 
}
esttab, se // for standard error

twoway ///
		/*(rarea Zero Zero  Years,  ///
		fcolor(gs13) lcolor(gs13) lw(none) lpattern(solid)) */ ///
		(line bF bN Years, lcolor(blue) ///
		lpattern(solid) lwidth(thick)) /// 
		(line Zero Years, lcolor(black)), legend(on) ///
		title("Cumulative Path of Real Long Term Interest Rate", color(black) size(vsmall)) ///
		ytitle("Percent", size(medsmall)) xtitle("Year", size(medsmall)) ///
		graphregion(color(white)) plotregion(color(white)) ///
		legend( order(1 "Financial" 2 "Non-Financial") size(vsmall) region(lwidth(none)))
		
		gr rename g_rltir , replace
eststo clear
qui forv h = 0/8 {
xtreg lrtcred`h' N F if year< 1912 | (year> 1923 & year< 1936) | year> 1950 /*if year> 1869 & year<= 1912*/ , fe /*cluster(iso)*/
replace bN = _b[N] + _b[_cons]                     if _n == `h'+1
replace uN = _b[N] + _b[_cons] + 1.645* _se[N]  if _n == `h'+1
replace dN = _b[N] + _b[_cons] - 1.645* _se[N]  if _n == `h'+1
replace bF = _b[F] + _b[_cons]                     if _n == `h'+1
replace uF = _b[F] + _b[_cons] + 1.645* _se[F]  if _n == `h'+1
replace dF = _b[F] + _b[_cons] - 1.645* _se[F]  if _n == `h'+1
eststo 
}
esttab, se // for standard error

twoway ///
		/*(rarea Zero Zero  Years,  ///
		fcolor(gs13) lcolor(gs13) lw(none) lpattern(solid)) */ ///
		(line bF bN Years, lcolor(blue) ///
		lpattern(solid) lwidth(thick)) /// 
		(line Zero Years, lcolor(black)), legend(on) ///
		title("Cumulative Path of Real Credit", color(black) size(vsmall)) ///
		ytitle("Percent", size(medsmall)) xtitle("Year", size(medsmall)) ///
		graphregion(color(white)) plotregion(color(white)) ///
		legend( order(1 "Financial" 2 "Non-Financial") size(vsmall) region(lwidth(none)))
		
		gr rename g_rtcred , replace
eststo clear
qui forv h = 0/8 {
xtreg cpii`h' N F if year< 1912 | (year> 1923 & year< 1936) | year> 1950 /*if year> 1869 & year<= 1912*/ , fe /*cluster(iso)*/
replace bN = _b[N] + _b[_cons]                     if _n == `h'+1
replace uN = _b[N] + _b[_cons] + 1.645* _se[N]  if _n == `h'+1
replace dN = _b[N] + _b[_cons] - 1.645* _se[N]  if _n == `h'+1
replace bF = _b[F] + _b[_cons]                     if _n == `h'+1
replace uF = _b[F] + _b[_cons] + 1.645* _se[F]  if _n == `h'+1
replace dF = _b[F] + _b[_cons] - 1.645* _se[F]  if _n == `h'+1
eststo 
}
esttab, se // for standard error

twoway ///
		/*(rarea Zero Zero  Years,  ///
		fcolor(gs13) lcolor(gs13) lw(none) lpattern(solid)) */ ///
		(line bF bN Years, lcolor(blue) ///
		lpattern(solid) lwidth(thick)) /// 
		(line Zero Years, lcolor(black)), legend(on) ///
		title("Cumulative Path of CPI Inflation", color(black) size(vsmall)) ///
		ytitle("Percent", size(medsmall)) xtitle("Year", size(medsmall)) ///
		graphregion(color(white)) plotregion(color(white)) ///
		legend( order(1 "Financial" 2 "Non-Financial") size(vsmall) region(lwidth(none)))
		
		gr rename g_cpii , replace
		

gr combine g_rconpc g_rpci g_rstir g_rltir g_rtcred g_cpii
	
/*	











*/











