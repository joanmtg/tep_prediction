#install.packages('neuralnet')
#install.packages('ggplot2')
#install.packages('plyr')
#install.packages('Metrics')

library(neuralnet)
library(ggplot2)
library(plyr)
library(Metrics)

set.seed(347)
num_tests = 5
limit_layer_1 = 15
limit_layer_2 = 8
limit_layer_3 = 4

setwd("/home/joan/Desktop/Tesis/tep_prediction")
data = read.table("data_tep.csv", header = T, sep=",")

#Progress bar
pbar <- create_progress_bar('text')
pbar$init(num_tests)


red_neuronal = function(data, test, train, h_layers) {

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
                    hidden        = h_layers,
                    threshold     = 0.03,  
                    algorithm     = "rprop+",
                    act.fct       = "logistic",
                    rep=3 
    )
    #plot(NN)

    predict_testNN = compute(NN, testNN[,c(1:31)])    
    tep.predict  = predict_testNN$net.result*(max(data$tep)-min(data$tep))+min(data$tep)
    tep.real = testNN$tep*(max(data$tep)-min(data$tep))+min(data$tep)

    tep.predict = ifelse(tep.predict > 0.5, 1, 0)

    datarealpred =cbind.data.frame(tep.predict,tep.real)

    #print("Prediction against real:")   
    #print(datarealpred)       

    result = c(accuracy =  accuracy(tep.real, tep.predict), 
                  auc = auc(tep.real, tep.predict),
                  precision = precision(tep.real, tep.predict),
                  recall = recall(tep.real,tep.predict),
                  f1 = f1(tep.real, tep.predict))

    pbar$step()

    return(result)

}

averages_list = list()

for (i in 1:limit_layer_1){

    total_index = 1:nrow(data)
    dinam_index = 1:nrow(data)

    index_test = NULL
    index_train = NULL

    sum_metrics = c(accuracy = 0, auc = 0, precision = 0, recall = 0, f1 = 0)

    for (l in 1:num_tests){
        index_test = sample(dinam_index, size = 0.2 * nrow(data), replace=FALSE)
        index_train = setdiff(total_index,index_test)
        results = red_neuronal(data, index_test, index_train, c(i))
        dinam_index = setdiff(dinam_index, index_test)       
        sum_metrics = sum_metrics + results    
    }
    
    #print(sum_metrics)
    average = sum_metrics / num_tests

    cat("Layers: (", i, ")")
    print(average)
    #averages_list[[length(averages_list)+1]] = list(average)

}


for (i in 1:limit_layer_1){

    for (j in 1:limit_layer_2){

        total_index = 1:nrow(data)
        dinam_index = 1:nrow(data)

        index_test = NULL
        index_train = NULL

        sum_metrics = c(accuracy = 0, auc = 0, precision = 0, recall = 0, f1 = 0)

        for (l in 1:num_tests){
            index_test = sample(dinam_index, size = 0.2 * nrow(data), replace=FALSE)
            index_train = setdiff(total_index,index_test)
            results = red_neuronal(data, index_test, index_train, c(i, j))
            dinam_index = setdiff(dinam_index, index_test)       
            sum_metrics = sum_metrics + results   
        }
        
        #print(sum_metrics)
        average = sum_metrics / num_tests

        cat("Layers: (", i, ", ", j, ")")
        print(average)
    }   
}



for (i in 1:limit_layer_1){

    for (j in 1:limit_layer_2){

        for (k in 1:limit_layer_3){        

            total_index = 1:nrow(data)
            dinam_index = 1:nrow(data)

            index_test = NULL
            index_train = NULL

            sum_metrics = c(accuracy = 0, auc = 0, precision = 0, recall = 0, f1 = 0)

            for (l in 1:num_tests){
                index_test = sample(dinam_index, size = 0.2 * nrow(data), replace=FALSE)
                index_train = setdiff(total_index,index_test)
                results = red_neuronal(data, index_test, index_train, c(i, j, k))
                dinam_index = setdiff(dinam_index, index_test)       
                sum_metrics = sum_metrics + results   
            }
            
            #print(sum_metrics)
            average = sum_metrics / num_tests

            cat("Layers: (", i, ", ", j, ", ", k, ")")
            print(average)
        }
    }   
}

