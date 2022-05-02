
import pandas as pd
import numpy as np
from sklearn import metrics
import matplotlib.pyplot as plt
import re

def plot_roc(*ys,**kwargs):
    plt.figure()
    for i in range(len(ys)):
        leg = re.findall(r'(?<=\_)\w+(?=\_)',ys[i])[0]
        fpr, tpr, thresholds = metrics.roc_curve(df['crisisJST'], df[ys[i]])
        auc = metrics.roc_auc_score(df['crisisJST'], df[ys[i]])
        lw = 2
        plt.plot(fpr,tpr,label=leg + " AUC: " + str(np.round(auc,2)))    
    plt.plot([0, 1], [0, 1], color="navy", lw=lw, linestyle="--")
    plt.xlim([0.0, 1.0])
    plt.ylim([0.0, 1.05])
    plt.xlabel("False Positive Rate")
    plt.ylabel("True Positive Rate")
    if 'title' in kwargs.keys():
        plt.title("Receiver operating characteristic curve, " + kwargs["title"])
    else:
        plt.title("Receiver operating characteristic curve")
    plt.legend(loc="lower right")
    # plt.show()


# 1.3
df = pd.read_csv('roc_raw_in_out.csv')
df.dropna(inplace=True)
plot_roc("yhat_baselineIn_cred","yhat_baselineOut_cred",title = "Real credit growth")
plt.savefig('compare_in_out.png')

# 1.4
# in_sample
df = pd.read_csv('roc_raw_all_in.csv')
df.dropna(inplace=True)

plot_roc("yhat_baseline_insample","yhat_narrowm_2017","yhat_eq_2017","yhat_hous_2017", \
    "yhat_bond_2017","yhat_bill_2017","yhat_ca_2017", title = "In-sample forecasts")
plt.savefig('compare_all_in.png')

# out_of_sample
df = pd.read_csv('roc_raw_all_out.csv')
df.dropna(inplace=True)

plot_roc("yhat_baseline_outsample","yhat_narrowm_1984","yhat_eq_1984","yhat_hous_1984", \
    "yhat_bond_1984","yhat_bill_1984","yhat_ca_1984", title = "Out-of-sample forecasts" )
plt.savefig('compare_all_out.png')