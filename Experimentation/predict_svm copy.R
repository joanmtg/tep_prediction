#install.packages('caTools')
#install.packages('caret')
#install.packages('e1071')

#library(Metrics)
#library(e1071)
library(caTools)
library(caret)
#library(plyr)

setwd("/home/joan/Desktop/Tesis/tep_prediction/Experimentation")
dataset = read.csv("data_tep.csv")
case_test = read.table("input.csv")
load_model = readRDS("final_model_svm.rds")



paste("Type:", typeof(case_test), sep = " ", collapse=NULL)
#paste("Length:", length(dataset), sep = " ", collapse=NULL)
#dataset[, c(1:29)] = scale(dataset[, c(1:29)])

#summary(dataset)

y_pred = predict(load_model, case_test[,c(1:29)])

print(y_pred)

#saveRDS(final_model, "final_model_svm.rds")