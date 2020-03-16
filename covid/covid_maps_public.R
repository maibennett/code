#Clear memory
rm(list = ls())

#Clear the console
cat("\014")

#################################################################
### Name: Create maps for Santiago and Chile according to date
### Creator: Magdalena Bennett
### Date: March 16, 2020
#################################################################

dir_data = ## Put the folder for your data here

setwd(paste0(dir_data,"figures/")) # If you want, you can set a working directory.

library("ggplot2")
library("ggmap")
library("dplyr")

### Input start day (March) and end day #####
start = 13
end = 16
#############################################

days = seq(start,end,1)

# Load COVID data from github (https://github.com/maibennett/code/tree/master/covid)
d = read.csv(paste0(dir_data,"data/data_covid.csv"), stringsAsFactors = FALSE)

dflist = list()

for(i in 1:length(days)){
  dflist[[i]] <- d[d$day<=(i-1),] %>% group_by(hospital,date,day,region) %>%
    summarise(n=n(),lat=mean(lat),lon=mean(lon))
}

api_key = #You need to get an API Key here
register_google(key = api_key)

##### Santiago

# Download a map from Santiago from Googple Maps
StgoMap <- qmap('santiago', zoom = 11,color = 'bw', legend = 'topleft')

date = rep(NA,length(days))
total_cases = rep(NA,length(days))

for(i in 1:length(days)){
  date[i] = paste0("March ",days[i],", 2020")
  total_cases[i] = paste0("Total RM = ",sum(dflist[[i]]$n[dflist[[i]]$region=="Metropolitana"]))
}


for(k in 1:length(days)){

  # Add cases in Santiago for day k
  StgoMap + geom_point(data=dflist[[k]], aes(x=lon, y=lat, size=n), 
                       show.legend = FALSE, col=alpha('hotpink2',0.4)) + 
    scale_size_continuous(range = c(3, max(dflist[[k]]$n))) +
    annotate("rect",xmin=-70.88, xmax=-70.69,ymin=-33.27,ymax=-33.31, color="white", fill="white")+
    annotate("text", x = -70.87, y = -33.28, label = date[k], size=8, hjust=0) +
    annotate("text", x = -70.87, y = -33.3, label = total_cases[k], size=6, hjust=0)
}


##### Chile

ChileMap <- qmap('Chile', zoom = 4,color = 'bw', legend = 'topleft')

date = rep(NA,length(days))
total_cases = rep(NA,length(days))

for(i in 1:length(days)){
  date[i] = paste0("March ",days[i],", 2020")
  total_cases[i] = paste0("Total = ",sum(dflist[[i]]$n))
}


for(k in 1:length(days)){

  # Add tested cases
  ChileMap + geom_point(data=dflist[[k]], aes(x=lon, y=lat, size=n), 
                        show.legend = FALSE, col=alpha('hotpink2',0.4)) + 
    scale_size_continuous(range = c(1, max(dflist[[k]]$n)/2)) +
    annotate("rect",xmin=-99.6, xmax=-82,ymin=-10.1,ymax=-16, color="white", fill="white")+
    annotate("text", x = -99.4, y = -11.5, label = date[k], size=6, hjust=0) +
    annotate("text", x = -99.4, y = -14.5, label = total_cases[k], size=5, hjust=0)
  
}
