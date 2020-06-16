#install.packages('caTools')
#install.packages('caret')
#install.packages('e1071')

library(Metrics)
library(randomForest)
library(caTools)
library(caret)
library(plyr)

setwd("/home/joan/Desktop/Tesis/tep_prediction/tep_web/tep/csv_scripts")
dataset = read.table("data_tep.csv", header = T, sep=",")
test_case = read.table("input.csv", header = T, sep=",")
load_model = readRDS("final_model_randomForest.rds")
#print(load_model)

total_index = 1:nrow(dataset)
original_rows = nrow(dataset)

dataset = rbind(dataset, test_case)
index_case = (original_rows+1):(original_rows+nrow(test_case))

max = apply(dataset , 2 , max)
min = apply(dataset, 2 , min)
scaled = as.data.frame(scale(dataset, center = min, scale = max - min))

caseNN = scaled[index_case,]
predict = predict(load_model, newdata=caseNN[,c(1:29)])
print(predict)
return(as.data.frame(predict))

