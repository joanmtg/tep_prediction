library(randomForest)
library(caTools)
library(caret)
library(plyr)
library(reprtree)

setwd("/home/joan/Desktop/Tesis/tep_prediction/Experimentation")
dataset = read.csv("data_tep.csv")

set.seed(400)

dataset$tep = factor(dataset$tep, levels = c("0", "1"), labels = c("0", "1"))
dataset[, c(1:29)] = scale(dataset[, c(1:29)])
#summary(dataset)

random_forest = function(ntree, dataset){
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

    cvRandomForest = lapply(folds, function(x){
        training_fold = dataset[-x, ]
        test_fold = dataset[x, ]

        classifier = randomForest(formula = f,
                    data = training_fold,
                    ntree = ntree,
                    type="classification")                 

        y_pred = predict(classifier, newdata = test_fold[,c(1:29)])

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

    return(cvRandomForest)
}

sum_metrics = c(accuracy = 0, auc = 0, precision = 0, recall = 0, f1 = 0)    
results = random_forest(100, dataset)
final_model = results[4]$Fold4$model

#plot
#jpeg(width=2560, height=1440, pointsize=23, quality=100)
#reprtree:::plot.getTree(final_model)
#dev.off()

#saveRDS(final_model, "final_model_randomForest.rds")
