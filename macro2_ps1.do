
clear all
cls

// load data
use http://data.macrohistory.net/JST/JSTdatasetR5.dta
xtset ifs year

gen cred2gdp = tloans/gdp
gen mon2gdp = money/gdp
xtline cred2gdp mon2gdp
xtline mon2gdp

gen rcred = tloans/cpi

logit crisisJST l(1/5).rcred
test l.rcred l2.rcred l3.rcred l4.rcred l5.rcred
predict yhat1

roctab crisisJST yhat1, graph

logit crisisJST l(1/3).rcred
predict yhat2

roctab crisisJST yhat2, graph



twoway scatter yhat1 crisisJST money, connect(l i) msymbol(i 0) sort ylabel(0 1)

export delimited crisisJST yhat1 yhat2 using "roc_raw.csv", replace