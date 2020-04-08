#install.packages('caTools')
#install.packages('caret')
#install.packages('rpart')

library(rpart)
library(caTools)
library(caret)

setwd("/home/joan/Desktop/Tesis/tep_prediction")
dataset = read.csv("data_tep.csv")

dataset$tep = factor(dataset$tep, levels = c("0", "1"), labels = c("0", "1"))
dataset[, c(1:29)] = scale(dataset[, c(1:29)])
summary(dataset)

decision_tree = function(method, type, dataset){
    set.seed(28)
    split = sample.split(dataset$tep, SplitRatio = 0.80)
    training_set = subset(dataset, split == TRUE)
    test_set = subset(dataset, split == FALSE)

    table(training_set$tep)
    table(test_set$tep)

    n = names(training_set)
    f = as.formula(paste("tep ~", paste(n[!n %in% "tep"], collapse = " + ")))

    folds = createFolds(dataset$tep, k = 5)
    #print(folds)

    cvDecisionTree = lapply(folds, function(x){
        training_fold = dataset[-x, ]
        test_fold = dataset[x, ]

        classifier = rpart(formula = f,
                    data = training_fold,
                    method = method)                 

        y_pred = predict(classifier, newdata = test_fold[,c(1:29)], type = type)

        c_matrix = table(test_fold$tep, y_pred)
        #print(c_matrix)        
        TP = c_matrix[2,2]
        TN = c_matrix[1,1]
        FN = c_matrix[2,1]
        FP = c_matrix[1,2]

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

    return(cvDecisionTree)
}

print("Class: ")
results = decision_tree("class", "class", dataset)
sum_metrics = c(accuracy = 0, auc = 0, precision = 0, recall = 0, f1 = 0)

for (result in results){
    sum_metrics = sum_metrics + result            
}

average = sum_metrics / 5
print(average)



