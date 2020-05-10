#install.packages('neuralnet')
#install.packages('ggplot2')
#install.packages('plyr')
#install.packages('Metrics')

library(neuralnet)
library(ggplot2)
library(plyr)
library(Metrics)

setwd("/home/joan/Desktop/Tesis/tep_prediction/Experimentation")

load_model = readRDS("final_model_nn2.rds")
#png(filename='plot_NN.png', width=1000)
pdf(paper='USr', width=1400)
plot(load_model, show.weights=TRUE, rep="best", fontsize=9, radius=0.06, arrow.length= 0.16)
#dev.off()
