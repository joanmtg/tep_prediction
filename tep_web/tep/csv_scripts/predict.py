import numpy as np
from numpy import genfromtxt


X = genfromtxt('/home/joan/Desktop/Tesis/tep_prediction/tep_web/tep/csv_scripts/input.csv', delimiter=',')
#print(X)

from prediction import Model

# Constants
MODEL_PATH = "/home/joan/Desktop/Tesis/tep_prediction/tep_web/tep/csv_scripts/final_model_nn"
data = genfromtxt("/home/joan/Desktop/Tesis/tep_prediction/tep_web/tep/csv_scripts/data_tep.csv", delimiter=',')


#X = np.array([[0],[23],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[1],[1],[1],[0]])
#print(X)
# Example Run
model = Model().load(MODEL_PATH, data)
pred = model.predict(X)

# Example output
#print(pred)