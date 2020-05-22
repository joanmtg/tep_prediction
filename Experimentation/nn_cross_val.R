#install.packages('neuralnet')
#install.packages('ggplot2')
#install.packages('plyr')
#install.packages('Metrics')
#install.packages("MLmetrics")

library(neuralnet)
library(ggplot2)
library(plyr)
library(Metrics)
library(caret)

set.seed(351)
num_tests = 5
limit_layer_1 = 15
limit_layer_2 = 8
limit_layer_3 = 4

setwd("/home/joan/Desktop/Experimentation")
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
                    algorithm     = "sag",
                    act.fct       = "logistic",
                    rep=3 
    )
    #plot(NN)

    predict_testNN = compute(NN, testNN[,c(1:29)])    
    tep.predict  = predict_testNN$net.result*(max(data$tep)-min(data$tep))+min(data$tep)
    tep.real = testNN$tep*(max(data$tep)-min(data$tep))+min(data$tep)

    tep.predict = ifelse(tep.predict > 0.5, 1, 0)

    datarealpred =cbind.data.frame(tep.predict,tep.real)

    #print("Prediction against real:")   
    #print(datarealpred)  
    print(tep.real)
    predicted = factor(tep.predict, levels=c('0', '1'))
    real = factor(tep.real, levels=c('0', '1'))

    c_matrix = table(predicted, real)  
    c_matrix = confusionMatrix(c_matrix, mode='everything', positive='1')        
    print(h_layers)
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
    pbar$step()

    return(result)

}

if(TRUE){

averages_1_layer = list()

for (i in 1:limit_layer_1){

    total_index = 1:nrow(data)
    dinam_index = 1:nrow(data)

    index_test = NULL
    index_train = NULL

    sum_metrics = c(accuracy = 0, auc = 0, precision = 0, recall = 0,  specificity = 0, f1 = 0)

    for (l in 1:num_tests){
        index_test = sample(dinam_index, size = 0.2 * nrow(data), replace=FALSE)
        index_train = setdiff(total_index,index_test)
        results = red_neuronal(data, index_test, index_train, c(i))
        dinam_index = setdiff(dinam_index, index_test)       
        sum_metrics = sum_metrics + results    
        print(results)
    }
    
    #print(sum_metrics)
    average = sum_metrics / num_tests

    cat("Layers: (", i, ")") 
    layers= paste("",i, sep="")  
    print(average)

    average[[length(average)+1]] = layers
    averages_1_layer[[length(averages_1_layer)+1]] = list(average)

}

write_list = plyr::adply(averages_1_layer,1,unlist,.id = NULL)
write.csv(write_list, "CSV/one_layers_sag.csv")

}

if(TRUE){

averages_2_layers = list()

for (i in 1:limit_layer_1){

    for (j in 1:limit_layer_2){

        total_index = 1:nrow(data)
        dinam_index = 1:nrow(data)

        index_test = NULL
        index_train = NULL

        sum_metrics = c(accuracy = 0, auc = 0, precision = 0, sensitivity = 0,  specificity = 0, f1 = 0)

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
        layers= paste(i, j, sep="-")  
        print(average)

        average[[length(average)+1]] = layers
        averages_2_layers[[length(averages_2_layers)+1]] = list(average)
    }   
}

write_list = plyr::adply(averages_2_layers,1,unlist,.id = NULL)
write.csv(write_list, "CSV/two_layers_sag.csv")

}


if(TRUE){

averages_3_layers = list()

for (i in 1:limit_layer_1){

    for (j in 1:limit_layer_2){

        for (k in 1:limit_layer_3){        

            total_index = 1:nrow(data)
            dinam_index = 1:nrow(data)

            index_test = NULL
            index_train = NULL

            sum_metrics = c(accuracy = 0, auc = 0, precision = 0, recall = 0,  specificity = 0, f1 = 0)

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
            layers= paste(i, j, k, sep="-")  
            print(average)

            average[[length(average)+1]] = layers
            averages_3_layers[[length(averages_3_layers)+1]] = list(average)
        }
    }   
}

write_list = plyr::adply(averages_3_layers,1,unlist,.id = NULL)
write.csv(write_list, "CSV/three_layers_sag.csv")

}

