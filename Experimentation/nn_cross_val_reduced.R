#install.packages('neuralnet')
#install.packages('ggplot2')
#install.packages('plyr')
#install.packages('Metrics')

library(neuralnet)
library(ggplot2)
library(plyr)
library(Metrics)

set.seed(346)
num_tests = 5
limit_layer_1 = 5
limit_layer_2 = 20
limit_layer_3 = 20

setwd("/home/joan/Desktop/Tesis/tep_prediction/Experimentation")
data = read.table("data_tep_reduced_2.csv", header = T, sep=",")

#Progress bar
pbar <- create_progress_bar('text')
pbar$init(num_tests)


red_neuronal = function(data, test, train, h_layers, algorithm) {

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
                    algorithm     = algorithm,
                    act.fct       = "logistic",
                    rep=3 
    )
    #plot(NN)

    predict_testNN = compute(NN, testNN[,c(1:8)])    
    tep.predict  = predict_testNN$net.result*(max(data$tep)-min(data$tep))+min(data$tep)
    tep.real = testNN$tep*(max(data$tep)-min(data$tep))+min(data$tep)

    tep.predict = ifelse(tep.predict > 0.5, 1, 0)

    datarealpred =cbind.data.frame(tep.predict,tep.real)

    #print("Prediction against real:")   
    #print(datarealpred)        

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

    #print(table(tep.real, tep.predict))
    #print(f1(tep.real, tep.predict))

    pbar$step()

    return(result)

}

if(FALSE){

averages_1_layer = list()

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
        #print(results)
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
write.csv(write_list, "CSV/one_layers_rprop_plus.csv")

}

if(FALSE){

averages_2_layers = list()

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
        layers= paste(i, j, sep="-")  
        print(average)

        average[[length(average)+1]] = layers
        averages_2_layers[[length(averages_2_layers)+1]] = list(average)
    }   
}

write_list = plyr::adply(averages_2_layers,1,unlist,.id = NULL)
write.csv(write_list, "CSV/two_layers_rprop_plus.csv")

}


if(FALSE){

averages_3_layers = list()

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
            layers= paste(i, j, k, sep="-")  
            print(average)

            average[[length(average)+1]] = layers
            averages_3_layers[[length(averages_3_layers)+1]] = list(average)
        }
    }   
}

write_list = plyr::adply(averages_3_layers,1,unlist,.id = NULL)
write.csv(write_list, "CSV/three_layers_rprop_plus.csv")


}



if(TRUE){

# test_list = list(list(algorithm="sag", topology=c(1,8,1)), 
#                 list(algorithm="sag", topology=c(12,7)),
#                 list(algorithm="rprop-", topology=c(1)),
#                 list(algorithm="rprop-", topology=c(3,4,2)),
#                 list(algorithm="rprop+", topology=c(1,8,4)),
#                 list(algorithm="sag", topology=c(1)),
#                 list(algorithm="rprop+", topology=c(2,6)),
#                 list(algorithm="rprop-", topology=c(1,3)),
#                 list(algorithm="rprop+", topology=c(1)))

#list_algorithms = list("sag", "sag", "rprop-", "rprop-", "rprop+", "sag", "rprop+", "rprop-", "rprop+")
#list_topologys = list(list(1,8,1), list(12,7), list(1), list(3,4,2), list(1,8,4), list(1), list(2,6), list(1,3), list(1))

averages = list()

#for (i in 1:length(list_algorithms)){
    #print("Hier")
    #print(test['algorithm'])

    total_index = 1:nrow(data)
    dinam_index = 1:nrow(data)

    index_test = NULL
    index_train = NULL

    sum_metrics = c(accuracy = 0, auc = 0, precision = 0, recall = 0, f1 = 0)

    for (l in 1:num_tests){
        index_test = sample(dinam_index, size = 0.2 * nrow(data), replace=FALSE)
        index_train = setdiff(total_index,index_test)
        results = red_neuronal(data, index_test, index_train, c(1), "rprop+")
        dinam_index = setdiff(dinam_index, index_test)       
        sum_metrics = sum_metrics + results    
        #print(typeof(results))
    }

    #print(sum_metrics)
    average = sum_metrics / num_tests

    #cat("Layers: (", 1, ")") 
    #layers= paste(test['algorithm'], "-", test['topology'], sep="")  
    print(average)

    #average[[length(average)+1]] = layers
    averages[[length(averages)+1]] = list(average)
#}

write_list = plyr::adply(averages,1,unlist,.id = NULL)
write.csv(write_list, "CSV/nn_reduced_9.csv")

}