#install.packages('caTools')
#install.packages('caret')
#install.packages('e1071')

library(Metrics)
library(e1071)
library(caTools)
library(caret)
library(plyr)


setwd("/home/joan/Desktop/Tesis/tep_prediction/Experimentation")
dataset = read.csv("data_tep.csv")

dataset$tep = factor(dataset$tep, levels = c("0", "1"), labels = c("0", "1"))
dataset[, c(1:29)] = scale(dataset[, c(1:29)])
summary(dataset)

support_vector_machine = function(type, kernel, dataset, nu){

    #set.seed(28)
    split = sample.split(dataset$tep, SplitRatio = 0.80)
    training_set = subset(dataset, split == TRUE)
    test_set = subset(dataset, split == FALSE)

    table(training_set$tep)
    table(test_set$tep)

    n = names(training_set)
    f = as.formula(paste("tep ~", paste(n[!n %in% "tep"], collapse = " + ")))

    folds = createFolds(dataset$tep, k = 5)
    #print(folds)

    cvKernelSVM = lapply(folds, function(x){
        training_fold = dataset[-x, ]
        test_fold = dataset[x, ]

        classifier = svm(formula = f,
                    data = training_fold,
                    type = type,
                    kernel = kernel,
                    nu = nu)                                        
   
        y_pred = predict(classifier, newdata = test_fold[,c(1:29)])
        #prediccion = factor(y_pred, levels = c("0", "1"), labels = c("0", "1"))        
        c_matrix = table(test_fold$tep, y_pred)
        #print(c_matrix)        
        TP = c_matrix[2,2]
        TN = c_matrix[1,1]
        FN = c_matrix[2,1]
        FP = c_matrix[1,2]

        #FPR = FP/(FP + TN)
        #TPR = TP/(TP + FN)        
        #auc_manual = (1/2) - (FPR/2) + (TPR/2)
        #print(auc_manual)

        accuracy = (TP + TN) / (TN + TP + FN + FP)                      
        auc = Metrics::auc(test_fold$tep, y_pred)
        precision = TP / (TP + FP)  
        recall = TP / (TP + FN)
        f1 = (2 * precision * recall) / (precision + recall)
                
        result = c(accuracy = accuracy, 
                  auc = auc,
                  precision = precision,
                  recall = recall,
                  f1 = f1)
        return(result)
    })

    return(cvKernelSVM)
}

#types = c("C-classification", "nu-classification", "one-classification")
#kernels = c("linear", "polynomial", "radial", "sigmoid")

averages = list()

for (i in 1:400){
    nu = i/1000.0
    print(nu)
    sum_metrics = c(accuracy = 0, auc = 0, precision = 0, recall = 0, f1 = 0)  
    results = support_vector_machine("nu-classification", "radial", dataset, nu)        
    
    for (result in results){
        sum_metrics = sum_metrics + result            
    }
    
    average = sum_metrics / 5
    average = sum_metrics / 5   
    print(average) 

    test = paste("Nu:", nu, sep = " ", collapse=NULL)

    average[[length(average)+1]] = test
    averages[[length(averages)+1]] = list(average)    
}

write_list = plyr::adply(averages,1,unlist,.id = NULL)
write.csv(write_list, "CSV/svm_save_model.csv")