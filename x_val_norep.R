#install.packages('neuralnet')
#install.packages('ggplot2')
#install.packages('plyr')

library(neuralnet)
library(ggplot2)
library(plyr)

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

    datarealpred =cbind.data.frame(tep.predict,tep.real)
        
    print(datarealpred)

    pbar$step()

}

#for (i in 1:k){

    #random = round(0.2 * nrow(data), digits = 0)
    total_index = 1:nrow(data)
    dinam_index = 1:nrow(data)

    index_test_1 = sample(dinam_index, size = 0.2 * nrow(data), replace=FALSE)
    index_train_1 = setdiff(total_index,index_test_1)
    red_neuronal(data, index_test_1, index_train_1)
    dinam_index = setdiff(dinam_index, index_test_1)

    index_test_2 = sample(dinam_index, size = 0.2 * nrow(data), replace=FALSE)
    index_train_2 = setdiff(total_index,index_test_2)
    red_neuronal(data, index_test_2, index_train_2)
    dinam_index = setdiff(dinam_index, index_test_2)
    
    index_test_3 = sample(dinam_index, size = 0.2 * nrow(data), replace=FALSE)
    index_train_3 = setdiff(total_index,index_test_3)
    red_neuronal(data, index_test_3, index_train_3)
    dinam_index = setdiff(dinam_index, index_test_3)

    index_test_4 = sample(dinam_index, size = 0.2 * nrow(data), replace=FALSE)
    index_train_4 = setdiff(total_index,index_test_4)
    red_neuronal(data, index_test_4, index_train_4)
    dinam_index = setdiff(dinam_index, index_test_4)

    index_test_5 = sample(dinam_index, size = 0.2 * nrow(data), replace=FALSE)
    index_train_5 = setdiff(total_index,index_test_5)
    red_neuronal(data, index_test_5, index_train_5)

    #Reduce(intersect, list(index_test_1, total_index))
    Reduce(intersect, list(index_test_1, index_test_2, index_test_3, index_test_4, index_test_5))

    #print(index_test)
    #print(index_train) 

    
    #pbar$step()

#}