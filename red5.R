library(neuralnet)
library(ggplot2)


setwd("/home/joan/Desktop/Tesis")
data = read.table("data_tep.csv", header = T, sep=",")
#dim(data)
#print(names(data))

random = round(0.1 * nrow(data), digits = 0)
total_index = 1:nrow(data)

index_test = sample(total_index, size = random)
index_train = setdiff(total_index,index_test)

#print(index_test)
#print(index_train)

max = apply(data , 2 , max)
min = apply(data, 2 , min)
scaled = as.data.frame(scale(data, center = min, scale = max - min))

summary(data)
summary(scaled)
  
trainNN = scaled[index_train, ]
testNN = scaled[index_test, ]
dim(trainNN)
dim(testNN)
n = names(trainNN)
f = as.formula(paste("tep ~", paste(n[!n %in% "tep"], collapse = " + ")))

NN = neuralnet(f,
                  data          = trainNN,
                  hidden        = c(15,7),
                  threshold     = 0.03,
                  algorithm     = "slr",
                  rep=3 
)
plot(NN)

predict_testNN = compute(NN, testNN[,c(1:31)])    
tep.predict  = predict_testNN$net.result
tep.real = testNN$tep 

datarealpred =cbind.data.frame(tep.predict,tep.real)
    
print(datarealpred)
  
