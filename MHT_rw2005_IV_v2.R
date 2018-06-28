#ROMANO AND WOLF (2005) Multiple Hypothesis Testing adjustments using IV (2SLS)

#If we use clusters, we need to use robust SE
MHT_rw2005_iv=function(y_mat,treat,iv,X,covariates,B=1000,robust,fe=NULL,clusterid=NULL,
                       names=names_outcomes,if_condition=NULL,two_side_test=T){
  
  #include code to install 'ivpack' if not installed.
  
  library("ivpack")
  
  #Number of multiple hypothesis that will be tested  
  s=ncol(y_mat)
  
  #Estimated betas
  
  beta_hat=rep(NA,s)
  se_hat=rep(NA,s)
  pval_hat=rep(NA,s)
  t_hat=rep(NA,s)
  reject_unadjust=rep("",s)
  
  outcomes=as.data.frame(y_mat)
  names(outcomes)=names[1:s]
  
  attach(outcomes)
  
  for (i in 1:s){
    
    #Covariates used for this regression i:
    covariates_aux=covariates[,c(X[i,X[i,]!=""])]
    
    cc<-complete.cases(y_mat[,i],covariates_aux)
    
    if(i==1){
      cc[if_condition==FALSE]<-FALSE
    }
    
    y_mat2=y_mat[cc,]
    treat2=treat[cc]
    iv2=iv[cc]
    covariates_aux2=covariates_aux[cc,]
    clusterid2=clusterid[cc]
    fe2=fe[cc]
    X_aux=names(covariates_aux2)
    
    outcomes2=outcomes[cc,]
    
    cc2 = complete.cases(outcomes2[,i],treat2,iv2,clusterid2)
    
    y_mat2=y_mat2[cc2,]
    treat2=treat2[cc2]
    iv2=iv2[cc2]
    covariates_aux2=covariates_aux2[cc2,]
    clusterid2=clusterid2[cc2]
    fe2=fe2[cc2]
    
    outcomes2=outcomes2[cc2,]
    
    #Eliminate variables that are colinear:
    cov_aux=covariates_aux2
    # 
    # if(dim(table(cov_aux[,"gpa_baseline_miss"],cov_aux[,"fracabs15_miss"]))[1]==2){
    #   if(table(cov_aux[,"gpa_baseline_miss"],cov_aux[,"fracabs15_miss"])[1,2]==0 & 
    #       table(cov_aux[,"gpa_baseline_miss"],cov_aux[,"fracabs15_miss"])[2,1]==0){
    #   
    #     aux=which(X_aux=="fracabs15_miss")
    #     X_aux = X_aux[-aux]
    #     covariates_aux2=covariates_aux2[,-aux]
    #   }
    # }
    # 
    # if (dim(table(cov_aux[,"gpa_baseline_miss"],cov_aux[,"fracabs15_miss"]))[1]==1){
    #   aux=which(X_aux=="fracabs15_miss")
    #   X_aux = X_aux[-aux]
    #   covariates_aux2=covariates_aux2[,-aux]
    # }
    # 
    # drop = NA
    # 
    # for(w in 1:dim(covariates_aux2)[2]){
    #   if (length(table(covariates_aux2[,w]))==1 | 
    #       (table(covariates_aux2[,w])[2]==1 & length(table(covariates_aux2[,w]))==2)){
    #     drop = c(drop, w)
    #   }
    # }
    # 
    # if (length(drop)>1){
    #   drop_aux=drop[-1]
    #   covariates_aux2 = covariates_aux2[,-drop_aux]
    #   X_aux=X_aux[-drop_aux]
    # }
    
    #Create dataframe with dependent variable (y), treatment (treat) and covariates for regression i
    reduce_form=as.data.frame(cbind(y_mat2[,i],treat2,covariates_aux2))
    first_stage=as.data.frame(cbind(y_mat2[,i],iv2,covariates_aux2))
    #Include names of all variables
    names(reduce_form)<-c(names[i],"treat2",X_aux)
    names(first_stage)<-c(names[i],"iv2",X_aux)
    
    rf_formula=paste(names(reduce_form)[1],"~",sep=" ")
    fs_formula=c(" | ")
    
    for(l in 2:(length(names(reduce_form))-1)){
      rf_formula=paste(rf_formula,names(reduce_form)[l],"+",sep=" ")
      fs_formula=paste(fs_formula,names(first_stage)[l],"+",sep=" ")
    }
    
    rf_formula=paste(rf_formula,names(reduce_form)[length(names(reduce_form))],sep=" ")
    fs_formula=paste(fs_formula,names(first_stage)[length(names(first_stage))],sep=" ")
    
    fe_n="fe2"
    
    if(!is.null(fe)){
      rf_formula=paste0(rf_formula," + ","as.factor(",fe_n,")")
      fs_formula=paste0(fs_formula," + ","as.factor(",fe_n,")")
    }
    
    formula_iv=paste0(rf_formula,fs_formula)
    
    d_aux=as.data.frame(cbind(outcomes2,covariates_aux2,treat2,iv2,fe2,clusterid2))
    
    #Run IV model
    ivmodel=ivreg(formula_iv,data=d_aux,na.action = na.omit)
    
    if(!is.null(clusterid)){
      ct=cluster.robust.se(ivmodel,clusterid2)
    }
    if(is.null(clusterid)){
      ct=robust.se(ivmodel)
    }
    
    beta_hat[i]=ivmodel$coefficients[2]
    se_hat[i]=ct[2,2]
    
    if(robust=="no"){
      pval_hat[i]=summary(ivmodel)$coefficients[2,4]
      se_hat[i]=summary(ivmodel)$coefficients[2,2]
    }
    if(robust=="yes"){
      pval_hat[i]=ct[2,4]
    }
    
    if(two_side_test==F){
      pval_hat[i]=pval_hat[i]/2
    }
    #If we don't need heteroskedastic robust errors
    if(robust=="no"){
      t_hat[i]=summary(ivmodel)$coefficients[2,3]
      
      if(pval_hat[i]>0.1){
        reject_unadjust[i]="No"
      }
      
      if(pval_hat[i]<=0.1){ 
        reject_unadjust[i]="90"
      }
      
      if(pval_hat[i]<=0.05){
        reject_unadjust[i]="95"
      }
      
      if(pval_hat[i]<=0.01){
        reject_unadjust[i]="99"
      }
    }
    
    #If we need heteroskedastic robust errors
    if(robust=="yes"){
      t_hat[i]=ct[2,3]
      
      if(pval_hat[i]>0.1){
        reject_unadjust[i]="No"
      }
      
      if(pval_hat[i]<=0.1){ 
        reject_unadjust[i]="90"
      }
      
      if(pval_hat[i]<=0.05){
        reject_unadjust[i]="95"
      }
      
      if(pval_hat[i]<=0.01){
        reject_unadjust[i]="99"
      }
    }
  }
  
  if(two_side_test==T){
    t_hat=abs(t_hat)
  }
  
  #### Step-down adjustment (Romano and Wolf)
  
  #Number of bootstrap samples (B) to obtain estimates (beta_bs) and t stats (t_bs)
  beta_bs=matrix(NA,B,s)
  t_bs=matrix(NA,B,s)
  
  for (i in 1:B){
    
    for (k in 1:s){
      
      #This set.seed can be commented out afterwards
      #set.seed(i+k)
      
      #Covariates used for this regression i:
      covariates_aux=covariates[,c(X[k,X[k,]!=""])]
      
      cc<-complete.cases(y_mat[,k],covariates_aux)
      
      if(k==1){
        cc[if_condition==FALSE]<-FALSE
      }
      
      y_mat2=y_mat[cc,]
      treat2=treat[cc]
      iv2=iv[cc]
      covariates_aux2=covariates_aux[cc,]
      clusterid2=clusterid[cc]
      fe2=fe[cc]
      X_aux=names(covariates_aux2)
      
      outcomes2=outcomes[cc,]
      
      cc2 = complete.cases(outcomes2[,k],treat2,iv2,clusterid2)
      
      y_mat2=y_mat2[cc2,]
      treat2=treat2[cc2]
      iv2=iv2[cc2]
      covariates_aux2=covariates_aux2[cc2,]
      clusterid2=clusterid2[cc2]
      fe2=fe2[cc2]
      
      outcomes2=outcomes2[cc2,]
      
      #Eliminate variables that are colinear:
      
      cov_aux=covariates_aux2
      
      # if(dim(table(cov_aux[,"gpa_baseline_miss"],cov_aux[,"fracabs15_miss"]))[1]==2){
      #   if(table(cov_aux[,"gpa_baseline_miss"],cov_aux[,"fracabs15_miss"])[1,2]==0 & 
      #      table(cov_aux[,"gpa_baseline_miss"],cov_aux[,"fracabs15_miss"])[2,1]==0){
      #     
      #     aux=which(X_aux=="fracabs15_miss")
      #     X_aux = X_aux[-aux]
      #     covariates_aux2=covariates_aux2[,-aux]
      #   }
      # }
      # 
      # if (dim(table(cov_aux[,"gpa_baseline_miss"],cov_aux[,"fracabs15_miss"]))[1]==1){
      #   aux=which(X_aux=="fracabs15_miss")
      #   X_aux = X_aux[-aux]
      #   covariates_aux2=covariates_aux2[,-aux]
      # }
      # 
      # drop = NA
      # 
      # for(w in 1:dim(covariates_aux2)[2]){
      #   if (length(table(covariates_aux2[,w]))==1 | 
      #       (table(covariates_aux2[,w])[2]==1 & length(table(covariates_aux2[,w]))==2)){
      #     drop = c(drop, w)
      #   }
      # }
      # 
      # if (length(drop)>1){
      #   drop_aux=drop[-1]
      #   covariates_aux2 = covariates_aux2[,-drop_aux]
      #   X_aux=X_aux[-drop_aux]
      # }
      
      n=nrow(y_mat2)
      
      #Take a sample of n (with replacement) from the original sample
      id=sample(seq(1:n),n,replace=T)
      
      #Obtain the outcome and treatment assignment
      outcomes_bs=outcomes2[id,]
      y_mat_bs=y_mat2[id,]
      treat_bs=treat2[id]
      iv_bs=iv2[id]
      fe_bs=fe2[id]
      clusterid_bs=clusterid2[id]
      
      covariates_bs=covariates_aux2[id,]
      
      drop = NA
      
      # for(w in 1:dim(covariates_bs)[2]){
      #   if (length(table(covariates_bs[,w]))==1 | 
      #       (table(covariates_bs[,w])[2]==1 & length(table(covariates_bs[,w]))==2)){
      #     drop = c(drop, w)
      #   }
      # }
      # 
      # if (length(drop)>1){
      #   drop_aux=drop[-1]
      #   covariates_bs = covariates_bs[,-drop_aux]
      #   X_aux=X_aux[-drop_aux]
      # }
      
      
      #Create dataframe with dependent variable (y), treatment (treat) and covariates for regression i
      reduce_form=as.data.frame(cbind(y_mat_bs[,k],treat_bs,covariates_bs))
      first_stage=as.data.frame(cbind(y_mat_bs[,k],iv_bs,covariates_bs))
      #Include names of all variables
      names(reduce_form)<-c(names[k],"treat_bs",X_aux)
      names(first_stage)<-c(names[k],"iv_bs",X_aux)
      
      rf_formula=paste(names(reduce_form)[1],"~",sep=" ")
      fs_formula=c(" | ")
      
      for(l in 2:(length(names(reduce_form))-1)){
        rf_formula=paste(rf_formula,names(reduce_form)[l],"+",sep=" ")
        fs_formula=paste(fs_formula,names(first_stage)[l],"+",sep=" ")
      }
      
      rf_formula=paste(rf_formula,names(reduce_form)[length(names(reduce_form))],sep=" ")
      fs_formula=paste(fs_formula,names(first_stage)[length(names(first_stage))],sep=" ")
      
      fe_bs_n="fe_bs"
      
      if(!is.null(fe)){
        rf_formula=paste0(rf_formula," + ","as.factor(",fe_bs_n,")")
        fs_formula=paste0(fs_formula," + ","as.factor(",fe_bs_n,")")
      }
      
      formula_iv=paste0(rf_formula,fs_formula)
      
      d_bs=as.data.frame(cbind(outcomes_bs,covariates_bs,treat_bs,iv_bs,fe_bs,clusterid_bs))
      
      #Run IV model
      ivmodel=ivreg(formula_iv,data=d_bs,na.action = na.omit)
      
      
      if(!is.null(clusterid)){
        ct=cluster.robust.se(ivmodel,clusterid_bs)
      }
      if(is.null(clusterid)){
        ct=robust.se(ivmodel)
      }
      
      beta_bs[i,k]=ivmodel$coefficients[2]
      
      if(robust=="no"){
        #The t-stat is constructed by substracting the previous estimate to the BS estimate,
        #and dividing it by the SE (not robust)
        #t_bs[i,k]=abs((beta_bs[i,k]-beta_hat[k])/summary(ivmodel)$coefficients[2,2])
        #divide by the SE of the original sample
        t_bs[i,k]=(beta_bs[i,k]-beta_hat[k])/se_hat[k]
      }
      
      if(robust=="yes"){
        #The t-stat is constructed by substracting the previous estimate to the BS estimate,
        #and dividing it by the SE (robust)
        #t_bs[i,k]=abs((beta_bs[i,k]-beta_hat[k])/ct[2,2])
        #divide by the SE of the original sample
        t_bs[i,k]=(beta_bs[i,k]-beta_hat[k])/se_hat[k]
      }
    }
  }
  
  if(two_side_test==T){
    t_bs=abs(t_bs)
    alpha=c(0.95,0.975,0.995)
  }
  #Generate quantiles:
  
  if(two_side_test==F){
    alpha=c(0.90,0.95,0.99)  
  }
  
  
  #Generate a vector which will tell us if under the MHT adjustment, the null will be rejected or not
  reject_adjust=rep("",s)
  
  for (a in 1:length(alpha)){
    
    t_hat_aux=t_hat
    t_bs_aux=t_bs
    done=F
    
    while(done==F){
      #We find the maximum value for t-stat from the original sample estimation
      t_max=max(t_hat_aux)
      #And find to which outcome does that t-stat belong to
      k=which(t_hat_aux==t_max)
      
      #If we have more than one test left:
      if(!is.null(dim(t_bs_aux))){
        t_bs_max=t_bs_aux[,k]
      }
      #If we only have one test left:
      if(is.null(dim(t_bs_aux))){
        t_bs_max=t_bs_aux
      }
      
      #Get the t-value for the alpha quantile, according to the bootstrap dist
      t_quantile=quantile(t_bs_max,alpha[a],na.rm=F)
      
      if(t_max>=t_quantile & !is.null(dim(t_bs_aux))){
        k_orig=which(t_hat==t_max)
        
        if(two_side_test==T){
          reject_adjust[k_orig]=alpha[a]*100-(1-alpha[a])*100
        }
        
        if(two_side_test==F){
          reject_adjust[k_orig]=alpha[a]
        }
        t_hat_aux=t_hat_aux[-k]
        t_bs_aux=t_bs_aux[,-k]
        print(k_orig)
      }
      
      if(is.null(dim(t_bs_aux))){
        t_bs_max=t_bs_aux
        t_quantile=quantile(t_bs_max,alpha[a],na.rm=F)
        t_max=max(t_hat_aux)
      }
      
      if(t_max<t_quantile | is.null(dim(t_bs_aux))){
        if(t_max>=t_quantile){
          k_orig=which(t_hat==t_max)
          
          if(two_side_test==T){
            reject_adjust[k_orig]=alpha[a]*100-(1-alpha[a])*100
          }
          
          if(two_side_test==F){
            reject_adjust[k_orig]=alpha[a]
          }
          
        }
        done=T
      }
    }
  }
  
  reject_adjust[reject_adjust==""]="No"
  
  #The function returns the estimated coefficients, and whether the unadjusted and
  #adjusted estimates are rejected
  
  outcome=list(beta_hat,se_hat,pval_hat,reject_unadjust,reject_adjust,t_bs,t_hat)
  names(outcome)=c("beta_hat","se_hat","pval_hat","reject_unadjust","reject_adjust","t_bs","t_hat")
  
  return(outcome)
  
}
