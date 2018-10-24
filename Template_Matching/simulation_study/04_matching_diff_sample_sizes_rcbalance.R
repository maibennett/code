rm(list = ls())
cat("\014")

##########################################################
######## TESTING CARDMATCH VS RCBALANCE ################## 
##########################################################

# Paper: Building Representative Matched Samples with Multi-valued Treatments in Large Observational Studies
# Authors: M. Bennett, J.P. Vielma, & J.R. Zubizarreta
# Date: 09-19-18

## Load libraries
library(xtable)
library(optmatch)
library(rcbalance)

##############################################
# 0. Index
##############################################

# 1. Load data and create dataframes
# 2. Matching for different data sizes (rcbalance)

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
performance3_rcb = rep(NA,5)

sink(paste0(dir_data,"rcbalance_output.txt"))

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
  
  maha_vars <- c("edm_5","edf_5","simce_stu_11","ses_sch_5","hh_inc_7","female_2",
                 "dep_3","att_10","gpa_rank_10","simce_sch_11",
                 "cath_sch_2","rural_sch_2","indig_3", "nbooks_6")
  
  l1 <- c("edm_5","edf_5","simce_stu_11","ses_sch_5","hh_inc_7","female_2")
  l2 <- c(l1,"dep_3","att_10","gpa_rank_10","simce_sch_11",
          "cath_sch_2","rural_sch_2","indig_3", "nbooks_6")
  
  start.time <- Sys.time()
  my.dist.struct <- build.dist.struct(z = d_aux$t_ind, 
                                      X = subset(d_aux[maha_vars]),
                                      calip.option = "propensity",
                                      caliper=0.2)

  out = rcbalance(my.dist.struct, fb.list = 
                    list(l1, l2),
            treated.info = d_aux[which(d_aux$t_ind ==1),],
            control.info = d_aux[which(d_aux$t_ind == 0),])
  end.time <- Sys.time()
  time.taken <- end.time - start.time
  time.taken
  
  performance3_rcb = rbind(performance3_rcb,c(l,nrow(d_aux[d_aux$t_ind==0,]),nrow(d_aux[d_aux$t_ind==1,]),
                                      length(out$matches),
                                      round(time.taken, 2)))
  

}

print("######################################################")
print(paste("############# Template size:",t*1000))
print(paste("############# Data size (x):",s+1))
print(paste("############# Time:",time.taken))
}
}

sink()