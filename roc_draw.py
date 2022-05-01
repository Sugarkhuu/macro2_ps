
import pandas as pd
from sklearn import metrics
import matplotlib.pyplot as plt

df = pd.read_csv('roc_raw.csv')
df.dropna(inplace=True)

fpr, tpr, thresholds = metrics.roc_curve(df['crisisJST'], df['yhat1'])
fpr2, tpr2, thresholds = metrics.roc_curve(df['crisisJST'], df['yhat2'])

plt.figure()
lw = 2
plt.plot(fpr,tpr)
plt.plot(fpr2,tpr2)
plt.plot([0, 1], [0, 1], color="navy", lw=lw, linestyle="--")
plt.xlim([0.0, 1.0])
plt.ylim([0.0, 1.05])
plt.xlabel("False Positive Rate")
plt.ylabel("True Positive Rate")
plt.title("Receiver operating characteristic example")
plt.legend(loc="lower right")
plt.show()