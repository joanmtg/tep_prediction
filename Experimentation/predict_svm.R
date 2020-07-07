#install.packages('caTools')
#install.packages('caret')
#install.packages('e1071')

library(Metrics)
library(e1071)
library(caTools)
library(caret)
library(plyr)

setwd("/home/joan/Desktop/Experimentation")
dataset = read.table("data_tep.csv", header = T, sep=",")
test_case = read.table("input.csv", header = T, sep=",")
load_model = readRDS("final_model_svm.rds")
print(load_model)

total_index = 1:nrow(dataset)
original_rows = nrow(dataset) 

dataset = rbind(dataset, test_case)
#print(total_index)
#print(nrow(dataset))
index_case = (original_rows+1):(original_rows+nrow(test_case))

max = apply(dataset , 2 , max)
min = apply(dataset, 2 , min)
scaled = as.data.frame(scale(dataset, center = min, scale = max - min))



caseNN = scaled[index_case,]
print(caseNN[,c(1:29)])
predict = predict(load_model, newdata=caseNN[,c(1:29)])   
print("here")
print(predict)

