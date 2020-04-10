#install.packages('neuralnet')
#install.packages('ggplot2')
#install.packages('plyr')
#install.packages('Metrics')

library(neuralnet)
library(ggplot2)
library(plyr)
library(Metrics)
#545, 225
#set.seed(10)

setwd("/home/joan/Desktop/Tesis/tep_prediction/Experimentation")
data = read.table("data_tep_reduced_2.csv", header = T, sep=",")
dim(data)
#print(names(data))
#random = round(0.1 * nrow(data), digits = 0)
total_index = 1:nrow(data)

index_test = sample(total_index, size = 0.2 * nrow(data), replace=FALSE)
index_train = setdiff(total_index,index_test)

#print(index_test)
print("Train Set")
print(index_train) 

max = apply(data , 2 , max)
min = apply(data, 2 , min)
scaled = as.data.frame(scale(data, center = min, scale = max - min))

#summary(data)
#summary(scaled)

trainNN = scaled[index_train, ]
testNN = scaled[index_test, ]
dim(trainNN)
dim(testNN)
n = names(trainNN)
f = as.formula(paste("tep ~", paste(n[!n %in% "tep"], collapse = " + ")))

# NN = neuralnet(f,
#                 data          = trainNN,
#                 hidden        = c(1,8,1),
#                 threshold     = 0.03,  
#                 algorithm     = "sag",
#                 act.fct       = "logistic",
#                 rep=3 
# )
# plot(NN)
load_model = readRDS("final_model_nn_reduced_2.rds")
#print(load_model)

predict_testNN = compute(load_model, testNN[,c(1:8)])   

tep.predict  = predict_testNN$net.result*(max(data$tep)-min(data$tep))+min(data$tep)
tep.real = testNN$tep*(max(data$tep)-min(data$tep))+min(data$tep)

tep.predict = ifelse(tep.predict > 0.5, 1, 0)

datarealpred =cbind.data.frame(tep.predict,tep.real)

print("Prediction against real:")   
print(datarealpred)           

accuracy =  accuracy(tep.real, tep.predict)
auc = auc(tep.real, tep.predict)
precision = precision(tep.real, tep.predict)
recall = recall(tep.real,tep.predict)
f1 = (2 * precision * recall) / (precision + recall)


result = c(accuracy = accuracy, 
                auc = auc,
                precision = precision,
                recall = recall,
                f1 = f1)

return(result)

# saveRDS(NN, "final_model_nn.rds")