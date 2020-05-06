#install.packages('neuralnet')
#install.packages('ggplot2')
#install.packages('plyr')
#install.packages('Metrics')

library(neuralnet)
library(ggplot2)
library(plyr)
library(Metrics)
#library(caret)

#wd = commandArgs(trailingOnly = TRUE)
#setwd(wd)

setwd("/home/joan/Desktop/Tesis/tep_prediction/Experimentation")

load_model = readRDS("final_model_nn2.rds")
plot(load_model, show.weights=TRUE, rep="best", fontsize=9, radius=0.06, arrow.length= 0.15)
#gwplot(load_model)
