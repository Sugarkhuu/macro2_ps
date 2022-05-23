clear all
cap drop _all
cap graph drop _all
//ssc install estout, replace
//ssc install matrixtools, replace

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

/*
local list variables  year country iso ifs pop rgdpmad rgdppc rconpc gdp iy cpi ca imports exports narrowm money stir ltrate hpnom debtgdp revenue expenditure xrusd tloans tmort thh tbus lev ltd noncore crisisJST crisisJST_old peg peg_strict peg_type peg_base JSTtrilemmaIV JSTtrilemmaIV_R eq_tr housing_tr bond_tr bill_rate rent_ipolated housing_capgain_ipolated housing_capgain housing_rent_rtn housing_rent_yd eq_capgain eq_dp eq_capgain_interp eq_tr_interp eq_dp_interp bond_rate eq_div_rtn capital_tr risky_tr safe_tr

*/


/*

gen N_year                                          =year*N
gen N_country                                    =country*N
gen N_iso                                            =iso*N
gen N_ifs                                            =ifs*N
gen N_pop                                            =pop*N
gen N_rgdpmad                                    =rgdpmad*N
gen N_rgdppc                                      =rgdppc*N
gen N_rconpc                                      =rconpc*N
gen N_gdp                                            =gdp*N
gen N_iy                                              =iy*N
gen N_cpi                                            =cpi*N
gen N_ca                                              =ca*N
gen N_imports                                    =imports*N
gen N_exports                                    =exports*N
gen N_narrowm                                    =narrowm*N
gen N_money                                        =money*N
gen N_stir                                          =stir*N
gen N_ltrate                                      =ltrate*N
gen N_hpnom                                        =hpnom*N
gen N_debtgdp                                    =debtgdp*N
gen N_revenue                                    =revenue*N
gen N_expenditure                            =expenditure*N
gen N_xrusd                                        =xrusd*N
gen N_tloans                                      =tloans*N
gen N_tmort                                        =tmort*N
gen N_thh                                            =thh*N
gen N_tbus                                          =tbus*N
gen N_lev                                            =lev*N
gen N_ltd                                            =ltd*N
gen N_noncore                                    =noncore*N
gen N_crisisJST                                =crisisJST*N
gen N_crisisJST_old                        =crisisJST_old*N
gen N_peg                                            =peg*N
gen N_peg_strict                              =peg_strict*N
gen N_peg_type                                  =peg_type*N
gen N_peg_base                                  =peg_base*N
gen N_JSTtrilemmaIV                        =JSTtrilemmaIV*N
gen N_JSTtrilemmaIV_R                    =JSTtrilemmaIV_R*N
gen N_eq_tr                                        =eq_tr*N
gen N_housing_tr                              =housing_tr*N
gen N_bond_tr                                    =bond_tr*N
gen N_bill_rate                                =bill_rate*N
gen N_rent_ipolated                        =rent_ipolated*N
gen N_housing_capgain_ipolated  =housing_capgain_ipolated*N
gen N_housing_capgain                    =housing_capgain*N
gen N_housing_rent_rtn                  =housing_rent_rtn*N
gen N_housing_rent_yd                    =housing_rent_yd*N
gen N_eq_capgain                              =eq_capgain*N
gen N_eq_dp                                        =eq_dp*N
gen N_eq_capgain_interp                =eq_capgain_interp*N
gen N_eq_tr_interp                          =eq_tr_interp*N
gen N_eq_dp_interp                          =eq_dp_interp*N
gen N_bond_rate                                =bond_rate*N
gen N_eq_div_rtn                              =eq_div_rtn*N
gen N_capital_tr                              =capital_tr*N
gen N_risky_tr                                  =risky_tr*N
gen N_safe_tr                                 =safe_tr   *N                    











gen F_year                                          =year*F
gen F_country                                    =country*F
gen F_iso                                            =iso*F
gen F_ifs                                            =ifs*F
gen F_pop                                            =pop*F
gen F_rgdpmad                                    =rgdpmad*F
gen F_rgdppc                                      =rgdppc*F
gen F_rconpc                                      =rconpc*F
gen F_gdp                                            =gdp*F
gen F_iy                                              =iy*F
gen F_cpi                                            =cpi*F
gen F_ca                                              =ca*F
gen F_imports                                    =imports*F
gen F_exports                                    =exports*F
gen F_narrowm                                    =narrowm*F
gen F_money                                        =money*F
gen F_stir                                          =stir*F
gen F_ltrate                                      =ltrate*F
gen F_hpnom                                        =hpnom*F
gen F_debtgdp                                    =debtgdp*F
gen F_revenue                                    =revenue*F
gen F_expenditure                            =expenditure*F
gen F_xrusd                                        =xrusd*F
gen F_tloans                                      =tloans*F
gen F_tmort                                        =tmort*F
gen F_thh                                            =thh*F
gen F_tbus                                          =tbus*F
gen F_lev                                            =lev*F
gen F_ltd                                            =ltd*F
gen F_noncore                                    =noncore*F
gen F_crisisJST                                =crisisJST*F
gen F_crisisJST_old                        =crisisJST_old*F
gen F_peg                                            =peg*F
gen F_peg_strict                              =peg_strict*F
gen F_peg_type                                  =peg_type*F
gen F_peg_base                                  =peg_base*F
gen F_JSTtrilemmaIV                        =JSTtrilemmaIV*F
gen F_JSTtrilemmaIV_R                    =JSTtrilemmaIV_R*F
gen F_eq_tr                                        =eq_tr*F
gen F_housing_tr                              =housing_tr*F
gen F_bond_tr                                    =bond_tr*F
gen F_bill_rate                                =bill_rate*F
gen F_rent_ipolated                        =rent_ipolated*F
gen F_housing_capgain_ipolated  =housing_capgain_ipolated*F
gen F_housing_capgain                    =housing_capgain*F
gen F_housing_rent_rtn                  =housing_rent_rtn*F
gen F_housing_rent_yd                    =housing_rent_yd*F
gen F_eq_capgain                              =eq_capgain*F
gen F_eq_dp                                        =eq_dp*F
gen F_eq_capgain_interp                =eq_capgain_interp*F
gen F_eq_tr_interp                          =eq_tr_interp*F
gen F_eq_dp_interp                          =eq_dp_interp*F
gen F_bond_rate                                =bond_rate*F
gen F_eq_div_rtn                              =eq_div_rtn*F
gen F_capital_tr                              =capital_tr*F
gen F_risky_tr                                  =risky_tr*F
gen F_safe_tr                                 =safe_tr   *F                    



*/




foreach x in year country iso ifs pop rgdpmad rgdppc rconpc gdp iy cpi ca imports exports narrowm money stir ltrate hpnom debtgdp revenue expenditure xrusd tloans tmort thh tbus lev ltd noncore crisisJST crisisJST_old peg peg_strict peg_type peg_base JSTtrilemmaIV JSTtrilemmaIV_R eq_tr housing_tr bond_tr bill_rate rent_ipolated housing_capgain_ipolated housing_capgain housing_rent_rtn housing_rent_yd eq_capgain eq_dp eq_capgain_interp eq_tr_interp eq_dp_interp bond_rate eq_div_rtn capital_tr risky_tr safe_tr /*lcpi stir*/ {

gen N_`x' = N * `x'
gen F_`x' = F * `x'

}









//lag creation
foreach x in lgdppc /*lcpi stir*/ {
forv h = 0/5 {
//gen `x'`h' = f`h'.`x' - l.`x' 			// Use for cumulative IRF
gen `x'`h' = f`h'.`x' - `x' 			// Use for cumulative IRF 
//gen `x'_lag_`h'  = `x' - l(`h').`x'
//gen `x'usual`h' = f`h'.`x' - l.f`h'.`x'		// Use for usual IRF

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
gen intcN = 0
gen slopeN = 0


/*
//eq_tr and lev seems to have possible effects, also _risky_tr capital_tr housing campaign housing_tr

foreach var in pop rconpc iy cpi ca imports exports ca imports exports narrowm money stir ltrate hpnom debtgdp revenue expenditure xrusd tloans tmort thh tbus lev ltd noncore peg peg_strict JSTtrilemmaIV JSTtrilemmaIV_R eq_tr housing_tr bond_tr bill_rate housing_capgain housing_rent_rtn housing_rent_yd eq_capgain eq_dp bond_rate eq_div_rtn capital_tr risky_tr safe_tr{
eststo clear
qui forv h = 0/5 {
xtreg lgdppc`h' N F N_`var' F_`var' if year< 1912 | (year> 1923 & year< 1936) | year> 1950 /*if year> 1869 & year<= 1912*/, fe /*cluster(iso)*/

eststo
}
esttab, se
}

// esttab, se // for standard error
// browse 
// tabulate F N
// esttab using table.tex, se
*/


/*
gen defl = cpi
gen inf = d.defl/l.defl //
replace N_eq_tr = N_eq_tr - inf
replace F_eq_tr = F_eq_tr - inf
*/


// if nominal equity returns increase, this indicates a recession, a bubble
eststo clear
qui forv h = 0/5 {
xtreg lgdppc`h' N F N_eq_tr F_eq_tr if year< 1912 | (year> 1923 & year< 1936) | year> 1950 /*if year> 1869 & year<= 1912*/, fe /*cluster(iso)*/
replace bN = _b[N] + _b[_cons]                     if _n == `h'+1
replace uN = _b[N] + _b[_cons] + 1.645* _se[N]  if _n == `h'+1
replace dN = _b[N] + _b[_cons] - 1.645* _se[N]  if _n == `h'+1
replace bF = _b[F] + _b[_cons]                     if _n == `h'+1
replace uF = _b[F] + _b[_cons] + 1.645* _se[F]  if _n == `h'+1
replace dF = _b[F] + _b[_cons] - 1.645* _se[F]  if _n == `h'+1
eststo 
}
esttab, se

/*
// Misleading, since in time banks realize giving credit makes more money and capital requirements ratio falls in time, thus another operation needed
eststo clear
qui forv h = 0/5 {
xtreg lgdppc`h' N F N_lev F_lev if year< 1912 | (year> 1923 & year< 1936) | year> 1950 /*if year> 1869 & year<= 1912*/, fe /*cluster(iso)*/
replace bN = _b[N] + _b[_cons]                     if _n == `h'+1
replace uN = _b[N] + _b[_cons] + 1.645* _se[N]  if _n == `h'+1
replace dN = _b[N] + _b[_cons] - 1.645* _se[N]  if _n == `h'+1
replace bF = _b[F] + _b[_cons]                     if _n == `h'+1
replace uF = _b[F] + _b[_cons] + 1.645* _se[F]  if _n == `h'+1
replace dF = _b[F] + _b[_cons] - 1.645* _se[F]  if _n == `h'+1
eststo 
}
esttab, se
*/

/*
// Data is strange, not explanatory
eststo clear
qui forv h = 0/5 {
xtreg lgdppc`h' N F N_risky_tr F_risky_tr if year< 1912 | (year> 1923 & year< 1936) | year> 1950 /*if year> 1869 & year<= 1912*/, fe /*cluster(iso)*/
replace bN = _b[N] + _b[_cons]                     if _n == `h'+1
replace uN = _b[N] + _b[_cons] + 1.645* _se[N]  if _n == `h'+1
replace dN = _b[N] + _b[_cons] - 1.645* _se[N]  if _n == `h'+1
replace bF = _b[F] + _b[_cons]                     if _n == `h'+1
replace uF = _b[F] + _b[_cons] + 1.645* _se[F]  if _n == `h'+1
replace dF = _b[F] + _b[_cons] - 1.645* _se[F]  if _n == `h'+1
eststo 
}
esttab, se
*/






