rm(list = ls())
cat("\014")

##########################################################
######## TESTING CARDMATCH VS OPTMATCH ################### 
##########################################################

# Paper: Building Representative Matched Samples with Multi-valued Treatments in Large Observational Studies
# Authors: M. Bennett, J.P. Vielma, & J.R. Zubizarreta
# Date: 09-19-18

## Load libraries
library(designmatch)
library(gurobi)
library(xtable)
library(optmatch)

##############################################
# 0. Index
##############################################

# 1. Load data and create dataframes
# 2. Matching for different data sizes (optmatch)

##############################################
# 1. Load data and create dataframes
##############################################

# Data should be stored in the same folder as the script.

# IF USING R STUDIO:
# Get the path for the data as the current directory of the script
dir_data = paste0(dirname(rstudioapi::getSourceEditorContext()$path),"/")

# IF NOT USING R STUDIO:
# Uncomment the following line and set dir_data to the path in the computer that stores this script.
#dir_data = 

template_fold = seq(1,10,1)
data_fold = seq(1,9,1)

# Store performance results
performance3_optmatch = rep(NA,5)

for(t in 1:length(template_fold)){
  for(s in 0:length(data_fold)){
    
# data created from 04_create_data_diff_sizes.R
# loads data from copy0 (d_pop) and template of size t*1000
load(paste0(dir_data,"data_template",t,".Rdata"))

# Copy 0 of the data
d_pop$copy = 0 

#Append s copies of the data:
if(s>0){
  for(j in 1:s){
    load(paste0(dir_data,"data_copy",j,".Rdata"))
    d_pop = rbind(d_pop,d_dup)
  }
}

# Set treatment variable to 0 for the template dataframe
template$treatment<-0

template$copy = -1
# Append the population data (data) with the template dataframe 
d = rbind(d_pop,template)

#Generate id for each obs of the template (so every observation has a unique id)
d[d$treatment==0,]$id=seq(nrow(d_pop)+1,nrow(d_pop)+nrow(template),1)


####################################################
# 2. Matching for different data sizes (optmatch)
####################################################

set.seed(100)

#### 3 Levels of Exposure

# New data frame for matched obs
d_match3 = rep(NA, ncol(d)+6)

count = 0
t_max_alloc = 15
levels = 3

for(l in 2:2){
  
  # Keep only template observations and level l of exposure for 3 levels.
  d_aux <- d[d$treatment==0 | d$treatment==l,]
  
  # Create a variable for "treatment" where template obs will have t_ind=1 and populations in level l
  # will have t_ind=0 (template obs < pop obs)  
  d_aux$t_ind <- 0
  d_aux$t_ind[d_aux$treatment==0] <- 1
  
  table(d_aux$t_ind)
  
  # We sort the data so we have template observations first.
  d_aux = d_aux[order(-d_aux$t_ind), ]
  
  t_ind=d_aux$t_ind
  
  table(t_ind)
  
  names_fine <- c("female_2","indig_3", "edm_5","edf_5","hh_inc_7","nbooks_6",
                  "simce_stu_11","att_10","gpa_rank_10",
                  "dep_3","cath_sch_2","rural_sch_2","ses_sch_5","simce_sch_11")
  
  d_aux2 = d_aux[,c(names_fine,"t_ind")]
  
  start.time <- Sys.time()
  
  ppty = glm(t_ind ~ ., family=binomial(),data=d_aux2)
  
  mhd <- match_on(t_ind ~ ., data = d_aux2) + caliper(match_on(ppty), 2)
  ( pm2 <- pairmatch(mhd, data = d_aux2) )
  end.time <- Sys.time()
  time.taken <- end.time - start.time
  time.taken
  
  summary(pm2)
  
  #(level, size data, size template, matched obs, time)
  performance3 = rbind(performance3,c(l,nrow(d_aux[d_aux$t_ind==0,]),nrow(d_aux[d_aux$t_ind==1,]),
                                      round(time.taken, 2)))
}

print("######################################################")
print(paste("############# Template size:",t*1000))
print(paste("############# Data size (x):",s+1))
print(paste("############# Time (min):",round(time.taken,2)))
print("######################################################")
}
}