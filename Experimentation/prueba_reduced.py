import rpy2.robjects as robjects
from rpy2.robjects import r

result = r['source']('tep_predict_reduced.R')
print(result)