library(neuralnet)
library(ggplot2)
library(plyr)
library(Metrics)
library(caret)

set.seed(111)

DEP_LIBS = c("neuralnet")

setwd("/home/joan/Desktop/Experimentation")
data = read.table("data_tep.csv", header = T, sep=",")
dim(data)
total_index = 1:nrow(data)

index_test = sample(total_index, size = 0.2 * nrow(data), replace=FALSE)
index_train = setdiff(total_index,index_test)

print("Train Set")
print(index_train) 

max = apply(data , 2 , max)
min = apply(data, 2 , min)
scaled = as.data.frame(scale(data, center = min, scale = max - min))

trainNN = scaled[index_train, ]
testNN = scaled[index_test, ]
dim(trainNN)
dim(testNN)
n = names(trainNN)
f = as.formula(paste("tep ~", paste(n[!n %in% "tep"], collapse = " + ")))

NN = neuralnet(f,
                data          = trainNN,
                hidden        = c(1,12,13),
                threshold     = 0.03,  
                algorithm     = "sag",
                act.fct       = "logistic",
                rep=3 
)
#plot(NN)

predict_testNN = compute(NN, testNN[,c(1:29)])    
tep.predict  = predict_testNN$net.result*(max(data$tep)-min(data$tep))+min(data$tep)
tep.real = testNN$tep*(max(data$tep)-min(data$tep))+min(data$tep)

tep.predict = ifelse(tep.predict > 0.5, 1, 0)

predicted = factor(tep.predict, levels=c('0', '1'))
real = factor(tep.real, levels=c('0', '1'))

c_matrix = table(predicted, real)  
c_matrix = confusionMatrix(c_matrix, mode='everything', positive='1')      
print(c_matrix)

accuracy =  c_matrix$overall[['Accuracy']]
auc = Metrics::auc(tep.real, tep.predict)
precision = c_matrix$byClass['Precision']
sensitivity = c_matrix$byClass['Sensitivity']
specificity = c_matrix$byClass['Specificity']
f1 = c_matrix$byClass['F1']

result = c(accuracy = accuracy, 
                  auc = auc,
                  precision = precision,
                  sensitivity = sensitivity,
                  specificity = specificity,
                  f1 = f1)   

print(result)

file_conn <- file('final_model_nn.dep')
writeLines(DEP_LIBS, file_conn)
close(file_conn)

#saveRDS(NN, "final_model_nn.rds")


