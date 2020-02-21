#install.packages('caTools')
#install.packages('caret')
#install.packages('randomForest')

library(randomForest)
library(caTools)
library(caret)

setwd("/home/joan/Desktop/Tesis/tep_prediction")
dataset = read.csv("data_tep.csv")

dataset$tep = factor(dataset$tep, levels = c("0", "1"), labels = c("NoTEP", "SiTEP"))
dataset[, c(1:29)] = scale(dataset[, c(1:29)])
summary(dataset)

#decision_tree = function(method, type, dataset){
set.seed(28)
split = sample.split(dataset$tep, SplitRatio = 0.80)
training_set = subset(dataset, split == TRUE)
test_set = subset(dataset, split == FALSE)

table(training_set$tep)
table(test_set$tep)

n = names(training_set)
f = as.formula(paste("tep ~", paste(n[!n %in% "tep"], collapse = " + ")))

folds = createFolds(dataset$tep, k = 5)
print(folds)

cvDecisionTree = lapply(folds, function(x){
    training_fold = dataset[-x, ]
    test_fold = dataset[x, ]

    classifier = randomForest(formula = f,
                data = training_fold,
                ntree = 350,
                type="classification")                 

    y_pred = predict(classifier, newdata = test_fold[,c(1:29)])

    c_matrix = table(test_fold$tep, y_pred)
    print(c_matrix)
    precision = (c_matrix[1,1] + c_matrix[2,2]) / (c_matrix[1,1] + c_matrix[2,2] +c_matrix[1,2] + c_matrix[2,1])
    return(precision)
})

precisionDecisionTree = mean(as.numeric(cvDecisionTree))

print(precisionDecisionTree)
#}