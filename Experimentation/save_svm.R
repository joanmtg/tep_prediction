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

set.seed(334)

dataset$tep = factor(dataset$tep, levels = c("0", "1"), labels = c("0", "1"))
dataset[, c(1:29)] = scale(dataset[, c(1:29)])
#summary(dataset)
#svm_models = list()

support_vector_machine = function(type, kernel, dataset, nu){

    #set.seed(28)
    split = sample.split(dataset$tep, SplitRatio = 0.80)
    training_set = subset(dataset, split == TRUE)
    test_set = subset(dataset, split == FALSE)

    table(training_set$tep)
    table(test_set$tep)

    #print(training_set$tep)

    n = names(training_set)
    f = as.formula(paste("tep ~", paste(n[!n %in% "tep"], collapse = " + ")))

    folds = createFolds(dataset$tep, k = 5)

    cvKernelSVM = lapply(folds, function(x){
        training_fold = dataset[-x, ]
        test_fold = dataset[x, ]

        classifier = svm(formula = f,
                    data = training_fold,
                    type = type,
                    kernel = kernel,
                    nu = nu)
        #svm_models[[length(svm_models)+1]] = classifier  
        plot(classifier, formula=f, data=training_fold)                                
   
        y_pred = predict(classifier, newdata = test_fold[,c(1:29)])     
        c_matrix = table(test_fold$tep, y_pred)
             
        TP = c_matrix[2,2]
        TN = c_matrix[1,1]
        FN = c_matrix[2,1]
        FP = c_matrix[1,2]
        

        accuracy = (TP + TN) / (TN + TP + FN + FP)                      
        auc = Metrics::auc(test_fold$tep, y_pred)
        precision = TP / (TP + FP)  
        recall = TP / (TP + FN)
        f1 = (2 * precision * recall) / (precision + recall)
                
        metrics = c(accuracy = accuracy, 
                  auc = auc,
                  precision = precision,
                  recall = recall,
                  f1 = f1)
        result = vector(mode="list", length=2)
        names(result) = c("metrics", "model")
        result[[1]] = metrics
        result[[2]] = classifier
        return(result)
    })

    return(cvKernelSVM)
}
 
sum_metrics = c(accuracy = 0, auc = 0, precision = 0, recall = 0, f1 = 0)  
results = support_vector_machine("nu-classification", "radial", dataset, 0.073)        
final_model = results[1]$Fold1$model

# for (result in results){
#     sum_metrics = sum_metrics + result            
# }

# average = sum_metrics / 5
# average = sum_metrics / 5   
# print(average) 
#print(svm_models)
#final_model = svm_models[0]

#saveRDS(final_model, "final_model_svm.rds")
