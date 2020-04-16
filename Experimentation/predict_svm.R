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
test_case = read.table("input.csv", header = T, sep=",")
load_model = readRDS("final_model_svm.rds")

total_index = 1:nrow(dataset)
original_rows = nrow(dataset) 

dataset = rbind(dataset, test_case)
print(total_index)
print(nrow(dataset))
index_case = (original_rows+1):(original_rows+nrow(test_case))

max = apply(dataset , 2 , max)
min = apply(dataset, 2 , min)
scaled = as.data.frame(scale(dataset, center = min, scale = max - min))

caseNN = scaled[index_case,]
predict = predict(load_model, newdata= caseNN[,c(1:29)])   
print(predict)

#c_matrix = table(caseNN$tep, predict)

#print(c_matrix)

#print(tep.predict)

#result = ifelse(tep.predict > 0.5, 1, 0)
#print(result)

#return(as.data.frame(predict))



#paste("Type:", typeof(test_case), sep = " ", collapse=NULL)
#paste("Length:", length(dataset), sep = " ", collapse=NULL)
#dataset[, c(1:29)] = scale(dataset[, c(1:29)])
#test_case = as.data.frame(scale(test_case[1,c(1:29)]))

#summary(dataset)

#y_pred = predict(load_model, as.data.frame(test_case[,c(1:29)]))

#print(y_pred)

#saveRDS(final_model, "final_model_svm.rds")