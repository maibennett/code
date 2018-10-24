rm(list = ls())
cat("\014")

##########################################################
######## TESTING CARDMATCH  ############################## 
##########################################################

# Paper: Building Representative Matched Samples with Multi-valued Treatments in Large Observational Studies 
# Authors: M. Bennett, J.P. Vielma, & J.R. Zubizarreta
# Date: 09-19-18

## Load libraries
library(designmatch)
library(gurobi)
library(xtable)

##############################################
# 0. Index
##############################################

# 1. Load data and create dataframes
# 2. Matching for different data sizes (cardmatch)
# 3. Creating output table

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
performance3 = rep(NA,5)

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
# 2. Matching for different data sizes (cardmatch)
####################################################

set.seed(100)

#### 3 Levels of Exposure

# New data frame for matched obs
d_match3 = rep(NA, ncol(d)+6)

count = 0
t_max_alloc = 15
levels = 3

#for(l in 1:levels){
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
  
  subset_weight <- NULL
  total_pairs <- sum(t_ind)
  n_matches <- 1
  
  # Add fine balance constraints
  names_fine <- c("female_2","indig_3", "edm_5","edf_5","hh_inc_7","nbooks_6",
                  "simce_stu_11","att_10","gpa_rank_10",
                  "dep_3","cath_sch_2","rural_sch_2","ses_sch_5","simce_sch_11")
  fine_covs <- d_aux[,c(names_fine)]
  fine <- list(covs = fine_covs)
  
  # Solver options
  t_max <- 60*t_max_alloc
  solver <- "gurobi"
  approximate <- 0
  solver <- list(name = solver, t_max = t_max, approximate = approximate, 
                 round_cplex = 0, trace_cplex = 0)
  
  # Match                   
  out = cardmatch(t_ind = t_ind, fine = fine, solver = solver)

  
  t_id = out$t_id  
  c_id = out$c_id
  
  t_id_d=d_aux$id[t_id]
  c_id_d=d_aux$id[c_id]
  
  if (length(t_id)>0) {
    cycle = FALSE
    level_matched = l
    group_id = out$group_id+count
    d_aux_2 = cbind(d_aux[c(t_id, c_id), ],t_id,c_id, group_id,t_id_d,c_id_d,level_matched)
    d_match3 = rbind(d_match3, d_aux_2)
    if (count == 0) {
      d_match3 = d_match3[-1, ]
    }
    count = nrow(d_match3)/2
  }
  
  #(level, size data, size template, matched obs, time)
  performance3 = rbind(performance3,c(l,nrow(d_aux[d_aux$t_ind==0,]),nrow(d_aux[d_aux$t_ind==1,]),
                                      round(length(out$t_id)/min(table(t_ind)), 2)*nrow(d_aux[d_aux$t_ind==1,]),
                                      round(out$time/60, 2)))
  
  cat("\n", "*************************************************", "\n", sep = "")
  cat("\n", "* Matching Level of Exposure: ",l, sep = "")
  cat("\n", "* Original number of observations: ",sum(t_ind==0), sep = "")
  cat("\n", "* Matching Group and number of observations: ", sep = "")
  cat("\n", "* Number of matched pairs: ", length(t_id), sep = "")
  cat("\n", "* Proportion of possible pairs matched: ",round(length(out$t_id)/min(table(t_ind)), 2), sep="" )
  cat("\n", "* Matching time (mins): ", round(out$time/60, 2), sep = "")
  cat("\n", "*************************************************", "\n", sep = "")
}

print("######################################################")
print(paste("############# Template size:",t*1000))
print(paste("############# Data size (x):",s+1))
print("######################################################")
}
}

performance3 = performance3[-1,]

names_per = c("Level of Exposure", "N Data","N Template", "N Matched", "Time (min)")

colnames(performance3) = names_per

################################################
#Simplified table:

### 3 Levels of exposure

names_per_data = c("N Template", "N = 70118")

for(k in 1:10){
  
  performance3_aux = performance3[performance3[,3]==1000*k,-c(1,4)]
  performance3_data_aux = performance3_aux[1,-1]
  
  for(i in 2:10){
    performance3_data_aux = c(performance3_data_aux,
                                  performance3_aux[i,3])
    if(k==1){
      
      names_per_data = c(names_per_data,paste0("N = ",
                                               performance3_aux[i,1]))
    }
  }
  if(k==1){
    performance3_data = performance3_data_aux
  }
  if(k>1){
    performance3_data = rbind(performance3_data, performance3_data_aux)
  }
}

colnames(performance3_data) = names_per_data

rownames(performance3_data) = rep("",nrow(performance3_data))

per3_data_latex = xtable(performance3_data, digits=c(0,0,rep(2,10)))

print(per3_data_latex, floating = F, include.colnames = T, include.rownames = F, 
      file = paste0(dir_data,"per_cardmatch_3_simple.tex"))
