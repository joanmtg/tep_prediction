#install.packages('caTools')
#install.packages('caret')
#install.packages('e1071')

library(Metrics)
library(e1071)
library(caTools)
library(caret)
library(plyr)

setwd("/home/joan/Desktop/Tesis/tep_prediction/Experimentation")
dataset = read.table("data_tep.csv", header = T, sep=",")
data = as.data.frame(dataset)
#test_case = read.table("input.csv", header = T, sep=",")
load_model = readRDS("final_model_svm.rds")
print(load_model)

plot(load_model, data=data)

