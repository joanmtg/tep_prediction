library(neuralnet)
library(ggplot2)
library(plyr)
library(Metrics)

setwd("/home/joan/Desktop/Experimentation")

load_model = readRDS("final_model_nn.rds")
pdf(paper='USr', width=1400)
plot(load_model, show.weights=TRUE, rep="best", fontsize=9, radius=0.06, arrow.length= 0.16)
dev.off()