clear all
cap drop _all
cap graph drop _all
//ssc install estout, replace

/********************* READ IN THE DATA ***********************/
use http://data.macrohistory.net/JST/JSTdatasetR5.dta
merge 1:1 year iso using "Z:\Downloads\RecessionDummies.dta"

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
forv h = 0/5 {
//gen `x'`h' = f`h'.`x' - l.`x' 			// Use for cumulative IRF
gen `x'`h' = f`h'.`x' - `x' 			// Use for cumulative IRF 
//gen `x'_lag_`h'  = `x' - l(`h').`x'
//gen `x'usual`h' = f`h'.`x' - l.f`h'.`x'		// Use for usual IRF

}
}
/*
eststo clear
//cap drop b u d Years Zero
//gen Years = _n-1 if _n<=6
//gen Zero =  0    if _n<=6
//gen b=0
//gen u=0
//gen d=0
qui forv h = 0/4 {
xtreg lgdppc`h' N F /*if year<=2013*/, fe /*cluster(iso)*/
//replace b = _b[l.dstir]                     if _n == `h'+2
//replace u = _b[l.dstir] + 1.645* _se[l.dstir]  if _n == `h'+2
//replace d = _b[l.dstir] - 1.645* _se[l.dstir]  if _n == `h'+2
eststo 
}

esttab, se // for standard error
// browse 
// tabulate F N
*/
qui forv h = 0/5 {
xtreg lgdppc`h' N F /*N*H F*H H*/ /*if year<=2013 & year<=1990*/, fe /*cluster(iso)*/
//replace b = _b[l.dstir]                     if _n == `h'+2
//replace u = _b[l.dstir] + 1.645* _se[l.dstir]  if _n == `h'+2
//replace d = _b[l.dstir] - 1.645* _se[l.dstir]  if _n == `h'+2
eststo  // adding & storing results as columns 
}

esttab, se // for standard error
// browse 
// tabulate F N
// esttab using table.tex, se
