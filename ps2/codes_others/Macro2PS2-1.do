clear all
cap drop _all
cap graph drop _all
//ssc install estout, replace
//net install grc1leg,from( http://www.stata.com/users/vwiggins/) 

/********************* READ IN THE DATA ***********************/

use "Y:\mm\JSTdataset.dta"
drop if year == 2014 | year == 2015 // 2014-15 are NA variables, removed from data

/********************* DATA DECLARATION ***********************/

sort ifs year
xtset  ifs year, yearly

/********************* DATA MANIPULATION ***********************/

// 1.1
gen stir_change		=	d.stir
gen peg_lag			=	l.peg
gen z_instr			=	dibaseF * peg * peg_lag * openquinn * (1/100) // since KAOPEN is defined in 0-100 range instead of 0-1


// 1.2
//log dependent variable calculation
gen lgdp			=	ln(gdp				)
gen ltloans			=	ln(tloans			)
gen lcpi			=	ln(cpi				)
gen lstocks			=	ln(stocks			)

//necessary regressor calculation
gen lrgdppc			= 	ln(rgdppc			)
gen lrconpc			= 	ln(rconpc			)
gen lripc			=	ln(iy * gdp / pop	)
//gen lripc			= 	ln(rgdppc *  iy		)
gen lrhp			= 	ln(hpnom  / cpi		)
gen	lrstocks		= 	ln(stocks / cpi		)
//gen	gdpcpi			= 	ln(gdp / cpi		)
//gen gdpd			=	gdp / xrusd			 //gdp dollars
gen gdpd			=	gdp / cpi
bys year: egen wgdp =	sum(gdpd) if gdpd != 0
sort ifs year
gen wgdpg			=	d.wgdp / l.wgdp
//gen wgdpg			= 	

// 2.1
gen USrate				=	0
gen USzrate				=	0
replace USrate			=	stir_change if country == "USA"
replace USzrate			=	z_instr if country == "USA"
bys year: egen USall	=	sum(USrate)
bys year: egen USzall	=	sum(USzrate)
sort ifs year

// to observe apprx. percent change, log transformation
/*
replace	gdp			=	100 * ln(gdp			)
replace tloans		=	100	* ln(tloans			)
*/

// forward dependent variable creation
foreach x in lgdp lcpi ltloans lstocks /*lcpi stir*/ {
forv h = 1/10 {
	gen `x'`h' = f`h'.`x' - `x' 			// Use for cumulative IRF 
}
}



/*


/********************* DATA PLOTTING ***********************/

twoway (scatter stir_change z_instr /*if iso=="FRA"*/, msize(vsmall)) (lfit stir_change z_instr), name("g_instr_all_scatter", replace) title("All Periods") legend(size(vsmall)) ytitle("Change in Short Term Interest Rate") xtitle("Z Trilemma Instrument")

twoway (scatter stir_change z_instr if year <= 1938, msize(vsmall) ) (lfit stir_change z_instr), name("g_instr_before_WW2_ended_scatter", replace) title("Pre-WWII") ytitle("Change in Short Term Interest Rate") xtitle("Z Trilemma Instrument")

twoway (scatter stir_change z_instr if year > 1945, msize(vsmall) ) (lfit stir_change z_instr), name("g_instr_after_WW2_ended_scatter", replace) title("Post-WWII") ytitle("Change in Short Term Interest Rate") xtitle("Z Trilemma Instrument")

/*graph combine*/grc1leg g_instr_before_WW2_ended_scatter g_instr_after_WW2_ended_scatter, name("secondset", replace)  ycommon cols(2) title("Pre & Post WWII") legendfrom(g_instr_before_WW2_ended_scatter)

grc1leg g_instr_all_scatter secondset, col(1) /*col(1) iscale(1)*/ legendfrom(g_instr_all_scatter)

/********************* EXPERIMENTED PLOTTING ***********************/
/*
twoway line z_instr stir_change year /*if iso=="FRA"*/, cmissing(n)
*/

*/



/********************* Z instrument effects ***********************/


/*

* Set parameters
local H 10 //LP horizon

* Preparation
egen coun = group(iso)
tab iso,gen(country_)
//rename country_17 c_17

* Generate matrices to store results
matrix irf_model_GDP_z		= J(`H'+1,1,0)
matrix irf_model_stir	= J(`H'+1,1,0)


foreach x in gdp/*lcpi stir*/ {
// forward dependent variable creation
forv h = 1/10 {
	gen `x'`h' = f`h'.`x' - `x' 			// Use for cumulative IRF 
}
}

forvalues h=1/`H' {
 reg gdp`h' z_instr stir country_*, noconstant
 //outreg2 using "Myfile.xls",append tstat bdec(3) tdec(2) keep(n f) addtext(Country FE, YES)
 matrix irf_model_GDP_z[`h'+1,1]			= _b[z_instr]
 //matrix irf_model_stir[`h'+1,1]			= _b[stir]
}

* Generate variables from coefficient estimates
svmat irf_model_GDP_z, names(irf_model_GDP_z)
svmat irf_model_stir, names(irf_model_stir)

matrix list irf_model_GDP_z

*/
//



eststo clear
cap drop b u d Years Zero
gen Years = _n-1 if _n<=10
gen Zero =  0    if _n<=10
gen bN=0
gen uN=0
gen dN=0


/*
qui forv h = 1/5 {
xtivreg lgdp`h' d.lrgdppc l.d.lrgdppc l2.d.lrgdppc  d.lrconpc l.d.lrconpc l2.d.lrconpc d.lripc l.d.lripc l2.d.lripc d.lcpi l.d.lcpi l2.d.lcpi d.ltrate l.d.ltrate l2.d.ltrate d.lrhp l.d.lrhp l2.d.lrhp d.lrstocks l.d.lrstocks l2.d.lrstocks d.debtgdp l.d.debtgdp l2.d.debtgdp d.wgdpg l.d.wgdpg l2.d.wgdpg (d.stir l.d.stir l2.d.stir = z_instr l.z_instr l2.z_instr)  /*dif year> 1869 & year<= 1912*/, fe /*cluster(iso)*/
/*
replace bN = _b[N] + _b[_cons]                     if _n == `h'+1
replace uN = _b[N] + _b[_cons] + 1.645* _se[N]  if _n == `h'+1
replace dN = _b[N] + _b[_cons] - 1.645* _se[N]  if _n == `h'+1
replace bF = _b[F] + _b[_cons]                     if _n == `h'+1
replace uF = _b[F] + _b[_cons] + 1.645* _se[F]  if _n == `h'+1
replace dF = _b[F] + _b[_cons] - 1.645* _se[F]  if _n == `h'+1
*/
eststo 
}
*/
/*
forv h = 1/5 {
xtivreg lgdp`h' l(0/2).d.lrgdppc l(0/2).d.lrconpc l(0/2).d.lripc l(0/2).d.lcpi l(0/2).d.ltrate (l(0/2).stir_change = l(0/2).z_instr) l(0/2).d.lrhp  l(0/2).d.lrstocks l(0/2).d.debtgdp l(0/2).d.wgdpg, fe
}
*/
eststo clear
set level 90
qui forv h = 1/10 {
xtivreg lgdp`h' l(0/2).d.lrgdppc l(0/2).d.lrconpc l(0/2).d.lripc l(0/2).d.lcpi l(0/2).d.ltrate /**/l(0/2).d.lrhp  l(0/2).d.lrstocks l(0/2).d.debtgdp l(0/2).d.wgdpg (l(0/2).stir_change = l(0/2).z_instr)  /*if year> 1869 & year<= 1912*/, fe /*vce(robust)*/ /*cluster(iso)*/
/*
replace bN = _b[N] + _b[_cons]                     if _n == `h'+1
replace uN = _b[N] + _b[_cons] + 1.645* _se[N]  if _n == `h'+1
replace dN = _b[N] + _b[_cons] - 1.645* _se[N]  if _n == `h'+1
replace bF = _b[F] + _b[_cons]                     if _n == `h'+1
replace uF = _b[F] + _b[_cons] + 1.645* _se[F]  if _n == `h'+1
replace dF = _b[F] + _b[_cons] - 1.645* _se[F]  if _n == `h'+1
*/
eststo
}

esttab , se  






/********************* US rate effects ***********************/

// US as instrument
eststo clear
set level 90
qui forv h = 1/10 {
xtivreg lgdp`h' l(0/2).d.lrgdppc l(0/2).d.lrconpc l(0/2).d.lripc l(0/2).d.lcpi l(0/2).d.ltrate /**/l(0/2).d.lrhp  l(0/2).d.lrstocks l(0/2).d.debtgdp l(0/2).d.wgdpg (l(0/2).USall = l(0/2).USzall)  /*if year> 1869 & year<= 1912*/, fe /*vce(robust)*/ /*cluster(iso)*/
/*
replace bN = _b[N] + _b[_cons]                     if _n == `h'+1
replace uN = _b[N] + _b[_cons] + 1.645* _se[N]  if _n == `h'+1
replace dN = _b[N] + _b[_cons] - 1.645* _se[N]  if _n == `h'+1
replace bF = _b[F] + _b[_cons]                     if _n == `h'+1
replace uF = _b[F] + _b[_cons] + 1.645* _se[F]  if _n == `h'+1
replace dF = _b[F] + _b[_cons] - 1.645* _se[F]  if _n == `h'+1
*/
eststo
}

esttab , se  


// US pure
eststo clear
set level 90
qui forv h = 1/10 {
xtreg lgdp`h' l(0/2).d.lrgdppc l(0/2).d.lrconpc l(0/2).d.lripc l(0/2).d.lcpi l(0/2).d.ltrate /**/l(0/2).d.lrhp  l(0/2).d.lrstocks l(0/2).d.debtgdp l(0/2).d.wgdpg l(0/2).USall  /*if year> 1869 & year<= 1912*/, fe /*vce(robust)*/ /*cluster(iso)*/
/*
replace bN = _b[N] + _b[_cons]                     if _n == `h'+1
replace uN = _b[N] + _b[_cons] + 1.645* _se[N]  if _n == `h'+1
replace dN = _b[N] + _b[_cons] - 1.645* _se[N]  if _n == `h'+1
replace bF = _b[F] + _b[_cons]                     if _n == `h'+1
replace uF = _b[F] + _b[_cons] + 1.645* _se[F]  if _n == `h'+1
replace dF = _b[F] + _b[_cons] - 1.645* _se[F]  if _n == `h'+1
*/
eststo
}

esttab , se  



//use US rate instead of z_inst on 2.1 GDP on 2.2 Stocks
/*
qui forv h = 1/5 {
xtivreg ltloans`h' d.lrgdppc l.d.lrgdppc l2.d.lrgdppc  d.lrconpc l.d.lrconpc l2.d.lrconpc d.lripc l.d.lripc l2.d.lripc d.lcpi l.d.lcpi l2.d.lcpi d.stir l.d.stir l2.d.stir d.ltrate l.d.ltrate l2.d.ltrate d.lrhp l.d.lrhp l2.d.lrhp d.lrstocks l.d.lrstocks l2.d.lrstocks d.debtgdp l.d.debtgdp l2.d.debtgdp (stir_change=z_instr) /*d.stir l.d.stir l2.d.stir if year> 1869 & year<= 1912*/, fe /*cluster(iso)*/