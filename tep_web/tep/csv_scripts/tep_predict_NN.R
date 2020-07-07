#install.packages('neuralnet')
#install.packages('ggplot2')
#install.packages('plyr')
#install.packages('Metrics')

library(neuralnet)
library(ggplot2)
library(plyr)
library(Metrics)
#library(caret)

#wd = commandArgs(trailingOnly = TRUE)
#setwd(wd)

setwd("/home/joan/Desktop/Tesis/tep_prediction/tep_web/tep/csv_scripts")
data = read.table("data_tep.csv", header = T, sep=",")
test_case = read.table("input.csv", header = T, sep=",")

total_index = 1:nrow(data)
original_rows = nrow(data) 

data = rbind(data, test_case)
print(total_index)
print(nrow(data))
index_case = (original_rows+1):(original_rows+nrow(test_case))

index_test = sample(total_index, size = 0.2 * nrow(data), replace=FALSE)
index_train = setdiff(total_index,index_test)

max = apply(data , 2 , max)
min = apply(data, 2 , min)
scaled = as.data.frame(scale(data, center = min, scale = max - min))

trainNN = scaled[index_train, ]
testNN = scaled[index_test, ]
caseNN = scaled[index_case,]

load_model = readRDS("final_model_nn.rds")
predict_testNN = compute(load_model, caseNN[,c(1:29)])   

tep.predict  = predict_testNN$net.result

print(tep.predict)

result = ifelse(tep.predict > 0.5, 1, 0)
print(result)

return(as.data.frame(result))
