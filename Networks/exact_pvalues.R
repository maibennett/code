## Clear memory
rm(list=ls())
cat("\014")

############################################################
####### Exact Pvalues (Athey, Eckle & Imbens, 2018) ########
############################################################

#Set working directory
setwd("C:/Users/maibe/Dropbox/PhD Columbia/Research/TC IRB/For Magdalena/Network/Exact pvalues")

library(foreign)

d = read.dta("data_analysis_oldv2.dta")

grade_baseline = d[,c("stuid2","clus")]
names(grade_baseline) = c("id1","clus1")

#Merge the cluster for peer1
d = merge(d,grade_baseline,by="id1",all.x=TRUE)

#drop observations without clusters (they don't count)
d = d[!is.na(d$clus),]

#Generate a dummy for students that consented:
d$consent = 0
d$consent[!is.na(d$treatment)]=1

#Generate a dummy variable for those students who have a peer 1:
d$peer1=0
d$peer1[d$d1>0] = 1

#Generate an empty variable for observations that'll be in the focal group.
d$focal = NA

#Here we'll store whether stuid2 (column1) is focal or not (column2)
focal = c(NA, NA)

#random allocation of focal clusters

cluster = as.numeric(rownames(table(d$clus)))

set.seed(100)

n_focal = 38

cluster_focal = sample(cluster,n_focal)
  
#for(c in 1:length(cluster_focal)){
#  d$focal[d$clus==cluster_focal[c]] = 1
#}

#d$focal[is.na(d$focal)] = 0  

#We'll assign clusters to the focal group by school
for (k in 1:22){
  #data for school k
  d_aux = d[d$schoolid2==k,]

  print(paste("######################## School",k))

  #clusters for each school:
  cluster_k = as.numeric(rownames(table(d_aux$clus)))
  #number of clusters per school:
  n_c = length(cluster_k)
  
  #If the number of clusters is even 
  if(n_c%% 2 == 0){
    n_focal = n_c/2
    
    STOP = FALSE
    
    not_assigned = cluster_k
    
    iter = 1
    
    while(STOP == FALSE){
      
      set.seed(k)
      iter = iter + 1
      
      #randomly select one focal cluster
      seed_f = sample(not_assigned,1)
      not_assigned = not_assigned[!(not_assigned %in% seed_f)]
      d$focal[d$schoolid2==k & d$clus==seed_f] = 1
      
      #select a nonfocal cluster from the ones that have the most peer1 in other cluster
      clus1 = table(d$clus1[d$peer1==1 & d$clus==seed_f])
      clus1 = clus1[as.numeric(rownames(clus1))!=seed_f & 
                      as.numeric(rownames(clus1)) %in% not_assigned]
      
      if(length(clus1)>0){
        if(length(clus1)==1){
          a = 1
        }
        if(length(clus1)>1){
          a = sample(seq(1,length(clus1[which(clus1==max(clus1))]),1),1)
        }
        seed_nf = as.numeric(names(clus1[which(clus1==max(clus1))[a]])) 
        d$focal[d$schoolid2==k & d$clus==seed_nf] = 0
        not_assigned = not_assigned[!(not_assigned %in% seed_nf)]
      }
      
      if(length(clus1)==0){
        if(length(not_assigned)==1){
          seed_nf = not_assigned
        }
        if(length(not_assigned)>1){
          seed_nf = sample(not_assigned,1)
        }
        d$focal[d$schoolid2==k & d$clus==seed_nf] = 0
        not_assigned = not_assigned[!(not_assigned %in% seed_nf)]
      }
      
      # if(length(not_assigned)==1 & n_focal == floor(n_c/2)){
      #   d$focal[d$schoolid2==k & d$clus==not_assigned] = 0
      #   STOP = TRUE
      # }
      if(length(not_assigned)==0){
        STOP = TRUE
      }
    }
  }
  
  #If the number of clusters is odd
  if(n_c%%2 == 1){
    #randomly select how many would be focal:
    n_focal = floor(n_c/2) + sample(c(0,1),1)
    
    STOP = FALSE
    
    not_assigned = cluster_k
    
    iter = 1
    
    while(STOP == FALSE){
      set.seed(k)
      iter = iter + 1
      
      #randomly select one focal cluster
      seed_f = sample(not_assigned,1)
      not_assigned = not_assigned[!(not_assigned %in% seed_f)]
      d$focal[d$schoolid2==k & d$clus==seed_f] = 1
      
      #select a nonfocal cluster from the ones that have the most peer1 in other cluster
      clus1 = table(d$clus1[d$peer1==1 & d$clus==seed_f])
      clus1 = clus1[as.numeric(rownames(clus1))!=seed_f & 
                      as.numeric(rownames(clus1)) %in% not_assigned]
      
      if(length(clus1)>0){
        if(length(clus1)==1){
          a = 1
        }
        if(length(clus1)>1){
          a = sample(seq(1,length(clus1[which(clus1==max(clus1))]),1),1)
        }
        seed_nf = as.numeric(names(clus1[which(clus1==max(clus1))[a]])) 
        d$focal[d$schoolid2==k & d$clus==seed_nf] = 0
        not_assigned = not_assigned[!(not_assigned %in% seed_nf)]
      }
      
      if(length(clus1)==0){
        seed_nf = sample(not_assigned,1)
        d$focal[d$schoolid2==k & d$clus==seed_nf] = 0
        not_assigned = not_assigned[!(not_assigned %in% seed_nf)]
      }
      
      if(length(not_assigned)==1 & n_focal > floor(n_c/2)){
        d$focal[d$schoolid2==k & d$clus==not_assigned] = 1
        STOP = TRUE
      }
      
      if(length(not_assigned)==1 & n_focal == floor(n_c/2)){
        d$focal[d$schoolid2==k & d$clus==not_assigned] = 0
        STOP = TRUE
      }
    }
  }
}

table(d$focal)


#######################################################################################
############ Observed T_score #########################################################
#######################################################################################

library(miceadds)
library(multiwayvcov)

d_peer_focal = d[d$peer1==1 & d$focal==1,]

formula_controls = as.formula(pres ~ gpa_baseline + gpa_baseline_miss + factor(iep) + factor(ell) + fracabs + fracabs_miss 
                              + factor(black) + factor(female) + factor(eversuspended) + sample + factor(st)
                              + treat + sample1 + total_peers + fracabs1 + fracabs1_miss + factor(iep1) + iep1_miss +
                                female1 + female1_miss + factor(ell1) + ell1_miss + gpa_baseline1 + gpa_baseline1_miss +
                                factor(black1) + black1_miss + factor(eversuspended1) + eversuspended1_miss)

lm1 = lm.cluster(data = d_peer_focal,formula = formula_controls, cluster = "clus")

#lm1 = lm.cluster(data = d_peer_focal,formula = pres ~ sample + factor(st)
#                 + treat + sample1 + total_peers, cluster = "clus")


lm1_res = lm1$lm_res
res1 = lm1_res$residuals

lm2 = lm(formula = formula_controls, data = d_peer_focal)
#lm2 = lm(pres ~ sample + factor(st)
#         + treat + sample1 + total_peers, data = d_peer_focal)
res2 = residuals(lm2)

T_obs = cov(res1,d_peer_focal$t1[-na.action(lm2)])

#######################################################################################
########## Randomization of nonfocal units ############################################
#######################################################################################

#identify treated and control clusters in the observed experiment:

treat_clus = unique(d$clus[d$treat_clus==1])
control_clus = unique(d$clus[d$treat_clus==0])

#identify treated and control clusters in the focal observations
treat_clus_focal = unique(d$clus[d$treat_clus==1 & d$focal==1])
control_clus_focal = unique(d$clus[d$treat_clus==0 & d$focal==1])

length(c(treat_clus_focal,control_clus_focal))

#identify clusters we can randomize:
clusters_random = unique(d$clus[!(d$clus %in% c(treat_clus_focal,control_clus_focal))])

#number of treated and control clusters
n_c_treat = 38
n_c_control = 38

#number of clusters (nonfocal) that will randomize into treatment:
n_c_treat_focal = n_c_treat - length(treat_clus_focal)

#Number of draws from the null:
draws = 2000

T_score = c(NA,NA)

results = rep(NA, 5)

for(s in 1:draws){
  
  #generate a copy of the data
  d_aux = d
  
  #set seed for replicability
  set.seed(s)
  
  #draw clusters (nonfocal) that we will randomize into treatment
  c_treat = sample(clusters_random,n_c_treat_focal)
  
  #generate control clusters for nonfocal units:
  c_control = clusters_random[!(clusters_random %in% c_treat)]
  
  #generate a randomized treated variable which will be the same for all students, except
  #for the students in nonfocal clusters
  d_aux$treat_s = d_aux$treat
  d_aux$treat_s[d_aux$clus %in% c_treat & d_aux$consent==1] = 1
  d_aux$treat_s[d_aux$clus %in% c_control & d_aux$consent==1] = 0
  
  
  d_aux2 = as.data.frame(cbind(d_aux$stuid2,d_aux$treat_s))
  names(d_aux2) = c("stuid2","treat_s")
  
  d2 = merge(d,d_aux2,by.x="id1",by.y="stuid2",all.x = TRUE)
  
  d2$t1_s = d2$treat_s
  d2$t1_s[is.na(d2$t1_s)] = d2$t1[is.na(d2$t1_s)] 
  
  results = rbind(results,c(s,sum(d2$consent),sum(d2$consent[d2$focal==1]),
                            sum(d2$consent[d2$focal==0]),sum(d2$t1_s!=d2$t1)))
  
  d2_peer_focal = d2[d2$peer1==1 & d2$focal==1,]
  
  lm = lm(formula = formula_controls, data = d2_peer_focal)
  
  #lm = lm(pres ~ sample + factor(st)
  #        + treat + sample1 + total_peers, data = d2_peer_focal)
  
  res = residuals(lm)
  
  T_aux = cov(res,d2_peer_focal$t1_s[-na.action(lm)])
  
  T_score = rbind(T_score,c(s,T_aux))
  
  print(paste("Sim:",s))
}

results = results[-1,]
names(results) = c("Draw","N_Consent","N_Consent_focal","N_Consent_nonfocal","Diff")

T_score = T_score[-1,]

esp = "controls"
save(T_score,T_obs, results,d,file=paste0("t_score",draws,"_",esp,".Rdata"))

den_T_score = density(T_score[,2])


par(mfcol=c(1,1),oma = c(2,1,2,1) + 0.1,
    mar = c(6.5,4,2,1) + 0.2, mgp=c(2,0.5,0),xpd=TRUE)

#controls
plot(den_T_score$x,den_T_score$y, xlim=c(0,0.41),
     xlab = paste("T score (",draws,"draws)"),ylab="Density T score")
abline(v=T_obs, col="red",lty=2,xpd=FALSE)
legend("bottom",legend = c("H0 distribution","Obs T score"),col=c("black","red"),
       pch=c(1,NA),lty=c(NA,2),xpd = TRUE,ncol = 2,
       y.intersp=0.5,x.intersp=0.1)

#No controls
plot(den_T_score$x,den_T_score$y, xlim=c(0,0.43),
     xlab = paste("T score (",draws,"draws)"),ylab="Density T score")
abline(v=T_obs, col="red",lty=2,xpd=FALSE)
legend("bottom",legend = c("H0 distribution","Obs T score"),col=c("black","red"),
       pch=c(1,NA),lty=c(NA,2),xpd = TRUE,ncol = 2,
       y.intersp=0.5,x.intersp=0.1)

1-sum(abs(T_obs)>=abs(T_score[,2]))/nrow(T_score)