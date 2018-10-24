rm(list = ls())
cat("\014")

##########################################################
######## CREATE DATA OF DIFFERENT SIZES ################## 
##########################################################

# Paper: Building Representative Matched Samples with Multi-valued Treatments in Large Observational Studies 
# Authors: M. Bennett, J.P. Vielma, & J.R. Zubizarreta
# Date: 09-19-18

## Load libraries
library("xtable")
 
##############################################
# 0. Index
##############################################

# 1. Load the data
# 2. Build copies of the data with random variation  
# 3. Select templates of different sizes

##############################################
# 1. Load the data
##############################################

# Data should be stored in the same folder as the script.

# IF USING R STUDIO:
# Get the path for the data as the current directory of the script
dir_data = paste0(dirname(rstudioapi::getSourceEditorContext()$path),"/")

# IF NOT USING R STUDIO:
# Uncomment the following line and set dir_data to the path in the computer that stores this script.
#dir_data =  

# Clean data for entire population in copy 0 (complete cases). This will be the starting data
# that will be further altered to generate additional copies.
d_pop = read.csv(paste0(dir_data,"data_copy0.csv"))

# Generate an id for the data
d_pop$id<-seq(1,nrow(d_pop),1)

########################################################
# 2. Build copies of the data with random variation 
########################################################

for(i in 1:9){

if(i>1){
  rm(d_dup)
}
  
d_dup = d_pop

covariates = c("edf_5", "edm_5", "hh_inc_7", "nbooks_6", "female_2", 
                "att_10", "gpa_rank_10", "indig_3", "simce_stu_11", 
                 "dep_3", "ses_sch_5", "simce_sch_11", "cath_sch_2", 
                  "rural_sch_2")

for(k in 1:length(covariates)){
  
  set.seed(as.numeric(paste0(i,k)))
  
  min = min(d_dup[,covariates[k]])
  max = max(d_dup[,covariates[k]])
  
  d_dup[,covariates[k]] = d_dup[,covariates[k]] + sample(c(-1,0,1),nrow(d_dup), replace = TRUE)
  
  d_dup[d_dup[,covariates[k]]>max,covariates[k]] = max
  
  d_dup[d_dup[,covariates[k]]<min,covariates[k]] = min
}

# Create new ids for copies
d_dup$id = seq((max(d_dup$id)*i+1),(max(d_dup$id)*i+nrow(d_dup)),1)

d_dup$copy = i

setwd(dir_data)

# Save data
save(d_dup,file=paste0("data_copy",i,".Rdata"))

print(paste("################## Copy:",i))

}

##############################################
# 3. Select templates of different sizes
##############################################

rm(list = ls())
cat("\014")

# Get the path for the data as the current directory of the script + data folder
dir_data = paste0(dirname(rstudioapi::getSourceEditorContext()$path),"/")

# Clean data for entire population in copy 0 (complete cases). This will be the starting data
# that will be further altered to generate additional copies.
d_pop = read.csv(paste0(dir_data,"data_copy0.csv"))

# Generate an id for the data
d_pop$id<-seq(1,nrow(d_pop),1)

##############################################
# 2. Building data for template selection
##############################################

for(t in 1:10){
  set.seed(t)
  
  # Matrix that will store the different samples for the template selection
  sample<-rep(NA,ncol(d_pop)+1)
  
  # number of samples
  n_samples=500
  
  # Sample size (multiplied by t)
  n_size=1000*t
  
  for(i in 1:n_samples){
    d_aux<-d_pop
    aux <- d_aux[sample(1:nrow(d_aux), n_size, replace=FALSE),]
    aux<-cbind(aux,i)
    sample<-rbind(sample,aux)
  }
  
  sample<-sample[-1,]
  
  # Covariates for the entire population to assess representativeness 
  # (transform categorical variables into binary variables)
  
  # Father's education (5 categories)
  d_edf_5 <- model.matrix(~ as.factor(edf_5),d_pop)
  d_edf_5<-d_edf_5[,-1]
  
  # Mother's education (5 categories)
  d_edm_5 <- model.matrix(~ as.factor(edm_5),d_pop)
  d_edm_5<-d_edm_5[,-1]
  
  # Household income (7 categories)
  d_hh_inc_7 <- model.matrix(~ as.factor(hh_inc_7),d_pop)
  d_hh_inc_7<-d_hh_inc_7[,-1]
  
  # Number of books at home (6 categories)
  d_nbooks_6 <- model.matrix(~ as.factor(nbooks_6),d_pop)
  d_nbooks_6<-d_nbooks_6[,-1]
  
  # Female (2 categories)
  d_female_2 <- d_pop$female_2
  
  # Student attendance (10 deciles)
  d_att_10 <- model.matrix(~ as.factor(att_10),d_pop)
  d_att_10<-d_att_10[,-1]
  
  # Student GPA (10 deciles)
  d_gpa_rank_10 <- model.matrix(~ as.factor(gpa_rank_10),d_pop)
  d_gpa_rank_10<-d_gpa_rank_10[,-1]
  
  # Student ethnicity (3 categories)
  d_indig_3 <- model.matrix(~ as.factor(indig_3),d_pop)
  d_indig_3<-d_indig_3[,-1]
  
  # Student SIMCE (10 deciles)
  d_simce_stu_11 <- model.matrix(~ as.factor(simce_stu_11),d_pop)
  d_simce_stu_11 <- d_simce_stu_11[,-1]
  
  # School dependence (3 categories)
  d_dep_3 <- model.matrix(~ as.factor(dep_3),d_pop)
  d_dep_3 <- d_dep_3[,-1]
  
  # School SES group (5 categories)
  d_ses_sch_5 <- model.matrix(~ as.factor(ses_sch_5),d_pop)
  d_ses_sch_5 <- d_ses_sch_5[,-1]
  
  # School SIMCE (10 deciles)
  d_simce_sch_11 <- model.matrix(~ as.factor(simce_sch_11),d_pop)
  d_simce_sch_11 <- d_simce_sch_11[,-1]
  
  # Catholic school (2 categories)
  d_cath_sch_2 <- d_pop$cath_sch_2
  
  # Rural school (2 categories)
  d_rural_sch_2 <- d_pop$rural_sch_2
  
  
  # Data frame for covariates
  d_covariates<-as.data.frame(cbind(d_edf_5, d_edm_5, d_hh_inc_7, d_nbooks_6, d_female_2, 
                                    d_att_10, d_gpa_rank_10, d_indig_3, d_simce_stu_11 , 
                                    d_dep_3, d_ses_sch_5, d_simce_sch_11, d_cath_sch_2, 
                                    d_rural_sch_2))
  
  # Names for covariates
  colnames(d_covariates)<-c("Edf_secondary","Edf_technical","Edf_college","Edf_missing",
                            "Edm_secondary","Edm_technical","Edm_college","Edm_missing",
                            "hhinc_100_200","hhinc_200_400","hhinc_400_600","hhinc_600_1400",
                            "hhinc_1400_more","hhinc_missing","Nbooks_1_10","Nbooks_11_50",
                            "Nbooks_51_100","Nbooks_more_100","Nbooks_missing","Female","att_2",
                            "att_3","att_4","att_5","att_6","att_7","att_8","att_9","att_10","GPA_2",
                            "GPA_3","GPA_4","GPA_5","GPA_6","GPA_7","GPA_8","GPA_9","GPA_10",
                            "Indigenous","Indigenous_miss","SIMCE_Stu_2","SIMCE_Stu_3","SIMCE_Stu_4",
                            "SIMCE_Stu_5","SIMCE_Stu_6","SIMCE_Stu_7","SIMCE_Stu_8","SIMCE_Stu_9",
                            "SIMCE_Stu_10","SIMCE_Stu_11","Part_subs","Municipal","ses_sch_mid_low",
                            "ses_sch_mid","ses_sch_mid_high","ses_sch_high","SIMCE_sch_2","SIMCE_sch_3",
                            "SIMCE_sch_4","SIMCE_sch_5","SIMCE_sch_6","SIMCE_sch_7","SIMCE_sch_8",
                            "SIMCE_sch_9","SIMCE_sch_10","Catholic_sch","Rural_sch")
  
  # Mean for covariates of the whole population 
  d_mean<-apply(d_covariates,MARGIN=2,FUN=mean,na.rm=1)
  
  # Variance-Covariance matrix for the population
  S<-var(d_covariates,na.rm=TRUE)
  
  
  # Covariates for the samples to assess representativeness 
  # (transform categorical variables into binary variables)
  
  s_edf_5 <- model.matrix(~ as.factor(edf_5),sample)
  s_edf_5<-s_edf_5[,-1]
  
  s_edm_5 <- model.matrix(~ as.factor(edm_5),sample)
  s_edm_5<-s_edm_5[,-1]
  
  s_hh_inc_7 <- model.matrix(~ as.factor(hh_inc_7),sample)
  s_hh_inc_7<-s_hh_inc_7[,-1]
  
  s_nbooks_6 <- model.matrix(~ as.factor(nbooks_6),sample)
  s_nbooks_6<-s_nbooks_6[,-1]
  
  s_female_2 <- sample$female_2
  
  s_att_10 <- model.matrix(~ as.factor(att_10),sample)
  s_att_10<-s_att_10[,-1]
  
  s_gpa_rank_10 <- model.matrix(~ as.factor(gpa_rank_10),sample)
  s_gpa_rank_10<-s_gpa_rank_10[,-1]
  
  s_indig_3 <- model.matrix(~ as.factor(indig_3),sample)
  s_indig_3<-s_indig_3[,-1]
  
  s_simce_stu_11 <- model.matrix(~ as.factor(simce_stu_11),sample)
  s_simce_stu_11 <- s_simce_stu_11[,-1]
  
  s_dep_3 <- model.matrix(~ as.factor(dep_3),sample)
  s_dep_3 <- s_dep_3[,-1]
  
  s_ses_sch_5 <- model.matrix(~ as.factor(ses_sch_5),sample)
  s_ses_sch_5 <- s_ses_sch_5[,-1]
  
  s_simce_sch_11 <- model.matrix(~ as.factor(simce_sch_11),sample)
  s_simce_sch_11 <- s_simce_sch_11[,-1]
  
  s_cath_sch_2 <- sample$cath_sch_2
  s_rural_sch_2 <- sample$rural_sch_2
  
  s_covariates<-as.data.frame(cbind(s_edf_5, s_edm_5, s_hh_inc_7, s_nbooks_6, s_female_2, s_att_10, 
                                    s_gpa_rank_10, s_indig_3, s_simce_stu_11 , s_dep_3, s_ses_sch_5, 
                                    s_simce_sch_11, s_cath_sch_2, s_rural_sch_2,sample$i))
  
  colnames(s_covariates)<-c("Edf_secondary","Edf_technical","Edf_college","Edf_missing","Edm_secondary",
                            "Edm_technical","Edm_college","Edm_missing","hhinc_100_200","hhinc_200_400",
                            "hhinc_400_600","hhinc_600_1400","hhinc_1400_more","hhinc_missing",
                            "Nbooks_1_10","Nbooks_11_50","Nbooks_51_100","Nbooks_more_100","Nbooks_missing",
                            "Female","att_2","att_3","att_4","att_5","att_6","att_7","att_8","att_9",
                            "att_10","GPA_2","GPA_3","GPA_4","GPA_5","GPA_6","GPA_7","GPA_8","GPA_9",
                            "GPA_10","Indigenous","Indigenous_miss","SIMCE_Stu_2","SIMCE_Stu_3",
                            "SIMCE_Stu_4","SIMCE_Stu_5","SIMCE_Stu_6","SIMCE_Stu_7","SIMCE_Stu_8",
                            "SIMCE_Stu_9","SIMCE_Stu_10","SIMCE_Stu_11","Part_subs","Municipal",
                            "ses_sch_mid_low","ses_sch_mid","ses_sch_mid_high","ses_sch_high","SIMCE_sch_2",
                            "SIMCE_sch_3","SIMCE_sch_4","SIMCE_sch_5","SIMCE_sch_6","SIMCE_sch_7",
                            "SIMCE_sch_8","SIMCE_sch_9","SIMCE_sch_10","Catholic_sch",
                            "Rural_sch","group")
  
  # Obtain the mean for covariates for each sample
  s_mean<-matrix(NA,nrow=n_samples,ncol=ncol(s_covariates))
  
  for (j in 1:n_samples){
    s_mean[j,]<-apply(s_covariates[s_covariates$group==j,],MARGIN=2,FUN=mean,na.rm=1)
  }
  
  ##############################################
  # 3. Selection of the template
  ##############################################
  
  # Calculate Mahalanobis distance for each sample and the population means.
  
  # We create an empty vector to store the sum of the mahalanobis distance for the covariates
  dist <- rep(NA,n_samples)
  min <- 100000
  min_index <- 0
  
  for (i in 1:n_samples){
    # Incorporate adjustment for redundancy of highly correlated variables
    dist[i]<-mahalanobis(s_mean[i,1:(ncol(s_mean)-1)],d_mean,S)
    
    # We update the minimum of diff (and its index) in every loop
    if(min(dist[!is.na(dist)])<min){
      min<-min(dist[!is.na(dist)])
      min_index<-i
    }
  }
  
  # The most representative of the samples obtained is:
  min_index
  
  # Compare the sample with the complete population:
  template_id<-sample$id[sample$i==min_index]
  template<-d_pop[template_id,]
  
  comparison<-cbind(round(d_mean,2),round(s_mean[min_index,1:(ncol(s_mean)-1)],2))
  
  rownames(comparison)<-c("Edf_secondary","Edf_technical","Edf_college","Edf_missing","Edm_secondary",
                          "Edm_technical","Edm_college","Edm_missing","hhinc_100_200","hhinc_200_400",
                          "hhinc_400_600","hhinc_600_1400","hhinc_1400_more","hhinc_missing",
                          "Nbooks_1_10","Nbooks_11_50","Nbooks_51_100","Nbooks_more_100","Nbooks_missing",
                          "Female","att_2","att_3","att_4","att_5","att_6","att_7","att_8","att_9",
                          "att_10","GPA_2","GPA_3","GPA_4","GPA_5","GPA_6","GPA_7","GPA_8","GPA_9",
                          "GPA_10","Indigenous","Indigenous_miss","SIMCE_Stu_2","SIMCE_Stu_3",
                          "SIMCE_Stu_4","SIMCE_Stu_5","SIMCE_Stu_6","SIMCE_Stu_7","SIMCE_Stu_8",
                          "SIMCE_Stu_9","SIMCE_Stu_10","SIMCE_Stu_11","Part_subs","Municipal",
                          "ses_sch_mid_low","ses_sch_mid","ses_sch_mid_high","ses_sch_high","SIMCE_sch_2",
                          "SIMCE_sch_3","SIMCE_sch_4","SIMCE_sch_5","SIMCE_sch_6","SIMCE_sch_7",
                          "SIMCE_sch_8","SIMCE_sch_9","SIMCE_sch_10","Catholic_sch",
                          "Rural_sch")
  
  print(comparison)
  
  print(paste("################## Template size:",1000*t))
}