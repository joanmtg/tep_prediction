#install.packages('neuralnet')
#install.packages('ggplot2')
#install.packages('plyr')
#install.packages('Metrics')

library(neuralnet)
library(ggplot2)
library(plyr)
library(Metrics)

set.seed(347)
cv.error = NULL
k = 5

setwd("/home/joan/Desktop/Tesis/tep_prediction")
data = read.table("data_tep.csv", header = T, sep=",")

pbar <- create_progress_bar('text')
pbar$init(k)

red_neuronal = function(data, test, train) {

    max = apply(data , 2 , max)
    min = apply(data, 2 , min)
    scaled = as.data.frame(scale(data, center = min, scale = max - min))

    summary(data)
    summary(scaled)
    
    trainNN = scaled[train, ]
    testNN = scaled[test, ]
    dim(trainNN)
    dim(testNN)
    n = names(trainNN)
    f = as.formula(paste("tep ~", paste(n[!n %in% "tep"], collapse = " + ")))

    NN = neuralnet(f,
                    data          = trainNN,
                    hidden        = c(15,7),
                    threshold     = 0.03,  
                    algorithm     = "rprop+",
                    act.fct       = "logistic",
                    rep=3 
    )
    plot(NN)

    predict_testNN = compute(NN, testNN[,c(1:31)])    
    tep.predict  = predict_testNN$net.result*(max(data$tep)-min(data$tep))+min(data$tep)
    tep.real = testNN$tep*(max(data$tep)-min(data$tep))+min(data$tep)

    tep.predict = ifelse(tep.predict > 0.5, 1, 0)

    datarealpred =cbind.data.frame(tep.predict,tep.real)

    print("Prediction against real:")   
    print(datarealpred)        
   
    r_rmse = round(sqrt(mean((datarealpred$tep.predict-datarealpred$tep.real)^2, na.rm = FALSE)),digits = 3)
    r_r = round(cor(datarealpred$tep.predict,datarealpred$tep.real),digits = 3)
    r_r2 = round(r_r^2,digits = 3)

    print("Scores and metrics:")
    print(paste(r_rmse,r_r,r_r2))

    print(paste("Accuracy : ", accuracy(tep.real, tep.predict)))
    print(paste("AUC      : ", auc(tep.real, tep.predict)))
    print(paste("Precision: ", precision(tep.real, tep.predict)))
    print(paste("Recall   : ", recall(tep.real,tep.predict)))
    print(paste("F1       : ", f1(tep.real, tep.predict)))
    print(paste("RMSE     : ", rmse(tep.real, tep.predict)))

    pbar$step()

}


total_index = 1:nrow(data)
dinam_index = 1:nrow(data)

index_test = NULL
index_train = NULL

l_tests = vector(mode="list", length=k)

for (i in 1:k){
    index_test = sample(dinam_index, size = 0.2 * nrow(data), replace=FALSE)
    index_train = setdiff(total_index,index_test)
    red_neuronal(data, index_test, index_train)
    dinam_index = setdiff(dinam_index, index_test)
    l_tests[[i]] = index_test  
}

print("Intersection between test sets:")
Reduce(intersect, l_tests)
