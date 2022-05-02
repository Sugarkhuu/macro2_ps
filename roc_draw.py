
import pandas as pd
import numpy as np
from sklearn import metrics
import matplotlib.pyplot as plt

def plot_roc(y1,y2):
    fpr1, tpr1, thresholds = metrics.roc_curve(df['crisisJST'], df[y1])
    fpr2, tpr2, thresholds = metrics.roc_curve(df['crisisJST'], df[y2])
    auc1 = metrics.roc_auc_score(df['crisisJST'], df[y1])
    auc2 = metrics.roc_auc_score(df['crisisJST'], df[y2])
    plt.figure()
    lw = 2
    plt.plot(fpr1,tpr1,label=y1+ " " + str(np.round(auc1,2)))
    plt.plot(fpr2,tpr2,label=y2+ " " + str(np.round(auc2,2)))
    plt.plot([0, 1], [0, 1], color="navy", lw=lw, linestyle="--")
    plt.xlim([0.0, 1.0])
    plt.ylim([0.0, 1.05])
    plt.xlabel("False Positive Rate")
    plt.ylabel("True Positive Rate")
    plt.title("Receiver operating characteristic curve")
    plt.legend(loc="lower right")
    plt.show()

# 1.3
df = pd.read_csv('roc_raw_in_out.csv')
df.dropna(inplace=True)
plot_roc("yhat_base_insample","yhat_base_outsample")

# 1.4
df = pd.read_csv('roc_raw_all_in.csv')
df.dropna(inplace=True)
plot_roc("yhat_insample","yhat_outsample")

narrowm eq_capgain housing_capgain bond_tr bill_rate

