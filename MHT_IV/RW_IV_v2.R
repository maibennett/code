#########################################
##### Romano and Wolf ###################
#########################################

# Author: Magdalena Bennett
# Date: 08-12-2016

#Clear memory
rm(list = ls())

#Clear the console
cat("\014")

#install.packages("lmtest")
#install.packages("sandwich")

library(lmtest)
library(sandwich)

#Set working directory to where the function MHT code is.
setwd("C:/Users/maibe/Dropbox/PhD Columbia/Research/Romano_and_Wolf")

#Loads the MHT function
source("MHT_rw2005.R")
source("MHT_rw2005_IV.R")
source("MHT_rw2005_IV_v2.R")

setwd("C:/Users/maibe/Dropbox/PhD Columbia/Research/Romano_and_Wolf")
######## Import data:
library("foreign")
#Load dataset in object d
d=read.dta("kcs_finaldata_all_old.dta")

setwd("C:/Users/Magdalena Bennett/Dropbox/PhD Columbia/Research/Romano_and_Wolf/results")
t_bs=read.dta("block_t_bs_total.dta")
d_hat=read.dta("blocks_total.dta")

#Results:
beta_hat = cbind(d_hat$beta_hat1,d_hat$beta_hat2,d_hat$beta_hat3,d_hat$beta_hat4,d_hat$beta_hat5)[1,]
se_hat = cbind(d_hat$se_hat1,d_hat$se_hat2,d_hat$se_hat3,d_hat$se_hat4,d_hat$se_hat5)[1,]

#Transform the negative into positive (only for the first one):
t_stat = cbind(d_hat$t_hat1,d_hat$t_hat2,d_hat$t_hat3,d_hat$t_hat4,d_hat$t_hat5)[1,]
#t_stat[c(1,5)] = -t_stat[c(1,5)]
t_stat[c(3,5)]=-t_stat[c(3,5)]

t_bs$t_bs5[is.na(t_bs$t_bs5)]=0

b_stat=t(t_bs[,1:5])
#b_stat[c(1,5),]=-b_stat[c(1,5),]
b_stat[c(3,5)]=-b_stat[c(3,5)]

library("StepwiseTest")

reject90=FWERkControl(t_stat,b_stat,1,0.1)
reject95=FWERkControl(t_stat,b_stat,1,0.05)
reject99=FWERkControl(t_stat,b_stat,1,0.01)

total=list(reject90,reject95,reject99)

save(d_hat,t_bs,total,file="results_total.RData")

setwd("C:/Users/Magdalena Bennett/Dropbox/PhD Columbia/Research/Romano_and_Wolf")
######## Import data:
library("foreign")
#Load dataset in object d
d=read.dta("kcs_finaldata_all_old.dta")

setwd("C:/Users/Magdalena Bennett/Dropbox/PhD Columbia/Research/Romano_and_Wolf/results")
t_bs=read.dta("block_t_bs_ms.dta")
d_hat=read.dta("blocks_ms.dta")

#Results:
beta_hat = cbind(d_hat$beta_hat1,d_hat$beta_hat2,d_hat$beta_hat3,d_hat$beta_hat4,d_hat$beta_hat5)[1,]
se_hat = cbind(d_hat$se_hat1,d_hat$se_hat2,d_hat$se_hat3,d_hat$se_hat4,d_hat$se_hat5)[1,]

#Transform the negative into positive (only for the first one):
t_stat = cbind(d_hat$t_hat1,d_hat$t_hat2,d_hat$t_hat3,d_hat$t_hat4)[1,]
#t_stat[c(1,5)] = -t_stat[c(1,5)]
t_stat[3]=-t_stat[3]

b_stat=t(t_bs[,1:4])
#b_stat[c(1,5),]=-b_stat[c(1,5),]
b_stat[3]=-b_stat[3]

library("StepwiseTest")

reject90=FWERkControl(t_stat,b_stat,1,0.1)
reject95=FWERkControl(t_stat,b_stat,1,0.05)
reject99=FWERkControl(t_stat,b_stat,1,0.01)

het2a=list(reject90,reject95,reject99)

save(d_hat,t_bs,het2a,file="results_het2a.RData")


setwd("C:/Users/Magdalena Bennett/Dropbox/PhD Columbia/Research/Romano_and_Wolf")
######## Import data:
library("foreign")
#Load dataset in object d
d=read.dta("kcs_finaldata_all_old.dta")

setwd("C:/Users/Magdalena Bennett/Dropbox/PhD Columbia/Research/Romano_and_Wolf/results")
t_bs=read.dta("block_t_bs_hs.dta")
d_hat=read.dta("blocks_hs.dta")

#Results:
beta_hat = cbind(d_hat$beta_hat1,d_hat$beta_hat2,d_hat$beta_hat3,d_hat$beta_hat4,d_hat$beta_hat5)[1,]
se_hat = cbind(d_hat$se_hat1,d_hat$se_hat2,d_hat$se_hat3,d_hat$se_hat4,d_hat$se_hat5)[1,]

#Transform the negative into positive (only for the first one):
t_stat = cbind(d_hat$t_hat1,d_hat$t_hat2,d_hat$t_hat3,d_hat$t_hat4,d_hat$t_hat5)[1,]
#t_stat[c(1,5)] = -t_stat[c(1,5)]
t_stat[c(3,5)]=-t_stat[c(3,5)]

t_bs$t_bs5[is.na(t_bs$t_bs5)]=0

b_stat=t(t_bs[,1:5])
#b_stat[c(1,5),]=-b_stat[c(1,5),]
b_stat[c(3,5)]=-b_stat[c(3,5)]

library("StepwiseTest")

reject90=FWERkControl(t_stat,b_stat,1,0.1)
reject95=FWERkControl(t_stat,b_stat,1,0.05)
reject99=FWERkControl(t_stat,b_stat,1,0.01)

het2b=list(reject90,reject95,reject99)

save(d_hat,t_bs,het2b,file="results_het2b.RData")


setwd("C:/Users/Magdalena Bennett/Dropbox/PhD Columbia/Research/Romano_and_Wolf")
######## Import data:
library("foreign")
#Load dataset in object d
d=read.dta("kcs_finaldata_all_old.dta")

setwd("C:/Users/Magdalena Bennett/Dropbox/PhD Columbia/Research/Romano_and_Wolf/results")
t_bs=read.dta("block_t_bs_fp.dta")
d_hat=read.dta("blocks_fp.dta")

#Results:
beta_hat = cbind(d_hat$beta_hat1,d_hat$beta_hat2,d_hat$beta_hat3,d_hat$beta_hat4,d_hat$beta_hat5)[1,]
se_hat = cbind(d_hat$se_hat1,d_hat$se_hat2,d_hat$se_hat3,d_hat$se_hat4,d_hat$se_hat5)[1,]

#Transform the negative into positive (only for the first one):
t_stat = cbind(d_hat$t_hat1,d_hat$t_hat2,d_hat$t_hat3,d_hat$t_hat4,d_hat$t_hat5)[1,]
#t_stat[c(1,5)] = -t_stat[c(1,5)]
t_stat[c(3,5)]=-t_stat[c(3,5)]

t_bs$t_bs5[is.na(t_bs$t_bs5)]=0

b_stat=t(t_bs[,1:5])
#b_stat[c(1,5),]=-b_stat[c(1,5),]
b_stat[c(3,5)]=-b_stat[c(3,5)]

library("StepwiseTest")

reject90=FWERkControl(t_stat,b_stat,1,0.1)
reject95=FWERkControl(t_stat,b_stat,1,0.05)
reject99=FWERkControl(t_stat,b_stat,1,0.01)

het2c=list(reject90,reject95,reject99)

save(d_hat,t_bs,het2c,file="results_het2c.RData")

setwd("C:/Users/Magdalena Bennett/Dropbox/PhD Columbia/Research/Romano_and_Wolf")
######## Import data:
library("foreign")
#Load dataset in object d
d=read.dta("kcs_finaldata_all_old.dta")

setwd("C:/Users/Magdalena Bennett/Dropbox/PhD Columbia/Research/Romano_and_Wolf/results")
t_bs=read.dta("block_t_bs_mp.dta")
d_hat=read.dta("blocks_mp.dta")

#Results:
beta_hat = cbind(d_hat$beta_hat1,d_hat$beta_hat2,d_hat$beta_hat3,d_hat$beta_hat4,d_hat$beta_hat5)[1,]
se_hat = cbind(d_hat$se_hat1,d_hat$se_hat2,d_hat$se_hat3,d_hat$se_hat4,d_hat$se_hat5)[1,]

#Transform the negative into positive (only for the first one):
t_stat = cbind(d_hat$t_hat1,d_hat$t_hat2,d_hat$t_hat3,d_hat$t_hat4,d_hat$t_hat5)[1,]
#t_stat[c(1,5)] = -t_stat[c(1,5)]
t_stat[c(3,5)]=-t_stat[c(3,5)]

t_bs$t_bs5[is.na(t_bs$t_bs5)]=0

b_stat=t(t_bs[,1:5])
#b_stat[c(1,5),]=-b_stat[c(1,5),]
b_stat[c(3,5)]=-b_stat[c(3,5)]

library("StepwiseTest")

reject90=FWERkControl(t_stat,b_stat,1,0.1)
reject95=FWERkControl(t_stat,b_stat,1,0.05)
reject99=FWERkControl(t_stat,b_stat,1,0.01)

het2d=list(reject90,reject95,reject99)

save(d_hat,t_bs,het2d,file="results_het2d.RData")

setwd("C:/Users/Magdalena Bennett/Dropbox/PhD Columbia/Research/Romano_and_Wolf")
######## Import data:
library("foreign")
#Load dataset in object d
d=read.dta("kcs_finaldata_all_old.dta")

setwd("C:/Users/Magdalena Bennett/Dropbox/PhD Columbia/Research/Romano_and_Wolf/results")
t_bs=read.dta("block_t_bs_bg.dta")
d_hat=read.dta("blocks_bg.dta")

#Results:
beta_hat = cbind(d_hat$beta_hat1,d_hat$beta_hat2,d_hat$beta_hat3,d_hat$beta_hat4,d_hat$beta_hat5)[1,]
se_hat = cbind(d_hat$se_hat1,d_hat$se_hat2,d_hat$se_hat3,d_hat$se_hat4,d_hat$se_hat5)[1,]

#Transform the negative into positive (only for the first one):
t_stat = cbind(d_hat$t_hat1,d_hat$t_hat2,d_hat$t_hat3,d_hat$t_hat4,d_hat$t_hat5)[1,]
#t_stat[c(1,5)] = -t_stat[c(1,5)]
t_stat[c(3,5)]=-t_stat[c(3,5)]

t_bs$t_bs5[is.na(t_bs$t_bs5)]=0

b_stat=t(t_bs[,1:5])
#b_stat[c(1,5),]=-b_stat[c(1,5),]
b_stat[c(3,5)]=-b_stat[c(3,5)]

library("StepwiseTest")

reject90=FWERkControl(t_stat,b_stat,1,0.1)
reject95=FWERkControl(t_stat,b_stat,1,0.05)
reject99=FWERkControl(t_stat,b_stat,1,0.01)

het2e=list(reject90,reject95,reject99)

save(d_hat,t_bs,het2e,file="results_het2e.RData")

setwd("C:/Users/Magdalena Bennett/Dropbox/PhD Columbia/Research/Romano_and_Wolf")
######## Import data:
library("foreign")
#Load dataset in object d
d=read.dta("kcs_finaldata_all_old.dta")

setwd("C:/Users/Magdalena Bennett/Dropbox/PhD Columbia/Research/Romano_and_Wolf/results")
t_bs=read.dta("block_t_bs_og.dta")
d_hat=read.dta("blocks_og.dta")

#Results:
beta_hat = cbind(d_hat$beta_hat1,d_hat$beta_hat2,d_hat$beta_hat3,d_hat$beta_hat4,d_hat$beta_hat5)[1,]
se_hat = cbind(d_hat$se_hat1,d_hat$se_hat2,d_hat$se_hat3,d_hat$se_hat4,d_hat$se_hat5)[1,]

#Transform the negative into positive (only for the first one):
t_stat = cbind(d_hat$t_hat1,d_hat$t_hat2,d_hat$t_hat3,d_hat$t_hat4)[1,]
#t_stat[c(1,5)] = -t_stat[c(1,5)]
t_stat[3]=-t_stat[3]

#t_bs$t_bs5[is.na(t_bs$t_bs5)]=0

b_stat=t(t_bs[,1:4])
#b_stat[c(1,5),]=-b_stat[c(1,5),]
b_stat[3]=-b_stat[3]

library("StepwiseTest")

reject90=FWERkControl(t_stat,b_stat,1,0.1)
reject95=FWERkControl(t_stat,b_stat,1,0.05)
reject99=FWERkControl(t_stat,b_stat,1,0.01)

het2f=list(reject90,reject95,reject99)

save(d_hat,t_bs,het2f,file="results_het2f.RData")



setwd("C:/Users/Magdalena Bennett/Dropbox/PhD Columbia/Research/Romano_and_Wolf")
######## Import data:
library("foreign")
#Load dataset in object d
d=read.dta("kcs_finaldata_all_old.dta")

setwd("C:/Users/Magdalena Bennett/Dropbox/PhD Columbia/Research/Romano_and_Wolf/results")
t_bs=read.dta("block_t_bs_f.dta")
d_hat=read.dta("blocks_f.dta")

#Results:
beta_hat = cbind(d_hat$beta_hat1,d_hat$beta_hat2,d_hat$beta_hat3,d_hat$beta_hat4,d_hat$beta_hat5,d_hat$beta_hat6)[1,]
se_hat = cbind(d_hat$se_hat1,d_hat$se_hat2,d_hat$se_hat3,d_hat$se_hat4,d_hat$se_hat5,d_hat$se_hat6)[1,]

#Transform the negative into positive (only for the first one):
t_stat = cbind(d_hat$t_hat1,d_hat$t_hat2,d_hat$t_hat3,d_hat$t_hat4,d_hat$t_hat5,d_hat$t_hat6)[1,]
#t_stat[c(1,5)] = -t_stat[c(1,5)]
t_stat=-t_stat

#t_bs$t_bs5[is.na(t_bs$t_bs5)]=0

b_stat=t(t_bs[,1:6])
#b_stat[c(1,5),]=-b_stat[c(1,5),]
b_stat=-b_stat

library("StepwiseTest")

reject90=FWERkControl(t_stat,b_stat,1,0.1)
reject95=FWERkControl(t_stat,b_stat,1,0.05)
reject99=FWERkControl(t_stat,b_stat,1,0.01)

het1a=list(reject90,reject95,reject99)

save(d_hat,t_bs,het1a,file="results_het1a.RData")

setwd("C:/Users/Magdalena Bennett/Dropbox/PhD Columbia/Research/Romano_and_Wolf")
######## Import data:
library("foreign")
#Load dataset in object d
d=read.dta("kcs_finaldata_all_old.dta")

setwd("C:/Users/Magdalena Bennett/Dropbox/PhD Columbia/Research/Romano_and_Wolf/results")
t_bs=read.dta("block_t_bs_pres.dta")
d_hat=read.dta("blocks_pres.dta")

#Results:
beta_hat = cbind(d_hat$beta_hat1,d_hat$beta_hat2,d_hat$beta_hat3,d_hat$beta_hat4,d_hat$beta_hat5,d_hat$beta_hat6)[1,]
se_hat = cbind(d_hat$se_hat1,d_hat$se_hat2,d_hat$se_hat3,d_hat$se_hat4,d_hat$se_hat5,d_hat$se_hat6)[1,]

#Transform the negative into positive (only for the first one):
t_stat = cbind(d_hat$t_hat1,d_hat$t_hat2,d_hat$t_hat3,d_hat$t_hat4,d_hat$t_hat5,d_hat$t_hat6)[1,]
#t_stat[c(1,5)] = -t_stat[c(1,5)]
#t_stat=-t_stat

#t_bs$t_bs5[is.na(t_bs$t_bs5)]=0

b_stat=t(t_bs[,1:6])
#b_stat[c(1,5),]=-b_stat[c(1,5),]
#b_stat=-b_stat

library("StepwiseTest")

reject90=FWERkControl(t_stat,b_stat,1,0.1)
reject95=FWERkControl(t_stat,b_stat,1,0.05)
reject99=FWERkControl(t_stat,b_stat,1,0.01)

het1b=list(reject90,reject95,reject99)

save(d_hat,t_bs,het1b,file="results_het1b.RData")

setwd("C:/Users/Magdalena Bennett/Dropbox/PhD Columbia/Research/Romano_and_Wolf")
######## Import data:
library("foreign")
#Load dataset in object d
d=read.dta("kcs_finaldata_all_old.dta")

setwd("C:/Users/Magdalena Bennett/Dropbox/PhD Columbia/Research/Romano_and_Wolf/results")
t_bs=read.dta("block_t_bs_stdmath.dta")
d_hat=read.dta("blocks_stdmath.dta")

#Results:
beta_hat = cbind(d_hat$beta_hat1,d_hat$beta_hat2,d_hat$beta_hat3,d_hat$beta_hat4,d_hat$beta_hat5,d_hat$beta_hat6)[1,]
se_hat = cbind(d_hat$se_hat1,d_hat$se_hat2,d_hat$se_hat3,d_hat$se_hat4,d_hat$se_hat5,d_hat$se_hat6)[1,]

#Transform the negative into positive (only for the first one):
t_stat = cbind(d_hat$t_hat1,d_hat$t_hat2,d_hat$t_hat3,d_hat$t_hat4,d_hat$t_hat5,d_hat$t_hat6)[1,]
#t_stat[c(1,5)] = -t_stat[c(1,5)]
#t_stat=-t_stat

#t_bs$t_bs5[is.na(t_bs$t_bs5)]=0

b_stat=t(t_bs[,1:6])
#b_stat[c(1,5),]=-b_stat[c(1,5),]
#b_stat=-b_stat

library("StepwiseTest")

reject90=FWERkControl(t_stat,b_stat,1,0.1)
reject95=FWERkControl(t_stat,b_stat,1,0.05)
reject99=FWERkControl(t_stat,b_stat,1,0.01)

het1c=list(reject90,reject95,reject99)

save(d_hat,t_bs,het1c,file="results_het1c.RData")

setwd("C:/Users/Magdalena Bennett/Dropbox/PhD Columbia/Research/Romano_and_Wolf")
######## Import data:
library("foreign")
#Load dataset in object d
d=read.dta("kcs_finaldata_all_old.dta")

setwd("C:/Users/Magdalena Bennett/Dropbox/PhD Columbia/Research/Romano_and_Wolf/results")
t_bs=read.dta("block_t_bs_stdela.dta")
d_hat=read.dta("blocks_stdela.dta")

#Results:
beta_hat = cbind(d_hat$beta_hat1,d_hat$beta_hat2,d_hat$beta_hat3,d_hat$beta_hat4,d_hat$beta_hat5,d_hat$beta_hat6)[1,]
se_hat = cbind(d_hat$se_hat1,d_hat$se_hat2,d_hat$se_hat3,d_hat$se_hat4,d_hat$se_hat5,d_hat$se_hat6)[1,]

#Transform the negative into positive (only for the first one):
t_stat = cbind(d_hat$t_hat1,d_hat$t_hat2,d_hat$t_hat3,d_hat$t_hat4,d_hat$t_hat5,d_hat$t_hat6)[1,]
#t_stat[c(1,5)] = -t_stat[c(1,5)]
#t_stat=-t_stat

#t_bs$t_bs5[is.na(t_bs$t_bs5)]=0

b_stat=t(t_bs[,1:6])
#b_stat[c(1,5),]=-b_stat[c(1,5),]
#b_stat=-b_stat

library("StepwiseTest")

reject90=FWERkControl(t_stat,b_stat,1,0.1)
reject95=FWERkControl(t_stat,b_stat,1,0.05)
reject99=FWERkControl(t_stat,b_stat,1,0.01)

het1d=list(reject90,reject95,reject99)

save(d_hat,t_bs,het1d,file="results_het1d.RData")

setwd("C:/Users/Magdalena Bennett/Dropbox/PhD Columbia/Research/Romano_and_Wolf")
######## Import data:
library("foreign")
#Load dataset in object d
d=read.dta("kcs_finaldata_all_old.dta")

setwd("C:/Users/Magdalena Bennett/Dropbox/PhD Columbia/Research/Romano_and_Wolf/results")
t_bs=read.dta("block_t_bs_gpamiss.dta")
d_hat=read.dta("blocks_gpamiss.dta")

#Results:
beta_hat = cbind(d_hat$beta_hat1,d_hat$beta_hat2,d_hat$beta_hat3,d_hat$beta_hat4,d_hat$beta_hat5,d_hat$beta_hat6)[1,]
se_hat = cbind(d_hat$se_hat1,d_hat$se_hat2,d_hat$se_hat3,d_hat$se_hat4,d_hat$se_hat5,d_hat$se_hat6)[1,]

#Transform the negative into positive (only for the first one):
t_stat = cbind(d_hat$t_hat2,d_hat$t_hat3,d_hat$t_hat4,d_hat$t_hat5,d_hat$t_hat6)[1,]
#t_stat[c(1,5)] = -t_stat[c(1,5)]
t_stat=-t_stat

t_bs$t_bs1[is.na(t_bs$t_bs1)]=0
t_bs$t_bs2[is.na(t_bs$t_bs2)]=0
t_bs$t_bs3[is.na(t_bs$t_bs3)]=0
t_bs$t_bs4[is.na(t_bs$t_bs4)]=0
t_bs$t_bs5[is.na(t_bs$t_bs5)]=0
t_bs$t_bs6[is.na(t_bs$t_bs6)]=0

b_stat=t(t_bs[,2:6])
#b_stat[c(1,5),]=-b_stat[c(1,5),]
b_stat=-b_stat

library("StepwiseTest")

reject90=FWERkControl(t_stat,b_stat,1,0.1)
reject95=FWERkControl(t_stat,b_stat,1,0.05)
reject99=FWERkControl(t_stat,b_stat,1,0.01)

het1e=list(reject90,reject95,reject99)

save(d_hat,t_bs,het1e,file="results_het1e.RData")