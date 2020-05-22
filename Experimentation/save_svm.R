#install.packages('caTools')
#install.packages('caret')
#install.packages('e1071')

library(Metrics)
library(e1071)
library(caTools)
library(caret)
library(plyr)

setwd("/home/joan/Desktop/Experimentation")
dataset = read.csv("data_tep.csv")

set.seed(666)

dataset$tep = factor(dataset$tep, levels = c("0", "1"), labels = c("0", "1"))
dataset[, c(1:29)] = scale(dataset[, c(1:29)])


support_vector_machine = function(type, kernel, dataset, nu){

    split = sample.split(dataset$tep, SplitRatio = 0.80)
    training_set = subset(dataset, split == TRUE)
    test_set = subset(dataset, split == FALSE)

    table(training_set$tep)
    table(test_set$tep)


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

        #plot(classifier, formula=f, data=training_fold)                                
   
        y_pred = predict(classifier, newdata = test_fold[,c(1:29)])     
        c_matrix = table(test_fold$tep, y_pred)
        test = paste("Type:" ,type, "Kernel:", kernel, sep = " ", collapse=NULL)
        print(test)
        print(c_matrix)        
        TP = c_matrix[2,2]
        TN = c_matrix[1,1]
        FN = c_matrix[2,1]
        FP = c_matrix[1,2]        

        accuracy = (TP + TN) / (TN + TP + FN + FP)                      
        auc = Metrics::auc(test_fold$tep, y_pred)
        precision = TP / (TP + FP)  
        sensitivity = TP / (TP + FN)
        specificity = TN / (TN + FP)
        f1 = (2 * precision * sensitivity) / (precision + sensitivity)
                
        metrics = c(accuracy = accuracy, 
                  auc = auc,
                  precision = precision,
                  sensitivity = sensitivity,
                  specificity = specificity,
                  f1 = f1)
        result = vector(mode="list", length=2)
        names(result) = c("metrics", "model")
        result[[1]] = metrics
        result[[2]] = classifier
        return(result)
    })

    return(cvKernelSVM)
}
 
sum_metrics = c(accuracy = 0, auc = 0, precision = 0, sensitivity = 0, specificity = 0, f1 = 0)  
results = support_vector_machine("nu-classification", "radial", dataset, 0.108)   
print(results[5]$Fold5$metrics)
final_model = results[5]$Fold5$model

saveRDS(final_model, "final_model_svm.rds")
