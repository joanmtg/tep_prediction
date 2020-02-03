#install.packages('caTools')
#install.packages('caret')

library(caTools)
library(caret)

setwd("/home/joan/Desktop/Tesis/tep_prediction")
dataset = read.csv("data_tep.csv")

dataset$tep = factor(dataset$tep, levels = c("0", "1"), labels = c("NoTEP", "SiTEP"))
dataset[, c(1:31)] = scale(dataset[, c(1:31)])
summary(dataset)

#set.seed(28)
split = sample.split(dataset$tep, SplitRatio = 0.80)
training_set = subset(dataset, split == TRUE)
test_set = subset(dataset, split == FALSE)

table(training_set$tep)
table(test_set$tep)

folds = createFolds(training_set$tep, k = 1, repeats = 5)

print(folds)


