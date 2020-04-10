#Clear memory
rm(list = ls())

#Clear the console
cat("\014")

dir_data = ## Put the folder for your data here ###

setwd(paste0(dir_data,"figures/")) # If you want, you can set a working directory.

library("ggplot2")
library("ggmap")
library("dplyr")
library("animation")

### Input start day (March) and end day #####
start = 3
end = 17
#############################################

days = seq(start,end,1)

# Load COVID data from github (https://github.com/maibennett/code/tree/master/covid)
d = read.csv("https://raw.githubusercontent.com/maibennett/code/master/covid/data_covid.csv", stringsAsFactors = FALSE)

dflist = list()

for(i in 1:length(days)){
  dflist[[i]] <- d[d$day<=(i-1),] %>% group_by(hospital,region) %>%
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


stgo = list()
files = rep(NA,length(days)
            
for(k in 1:length(days)){

  # Add cases in Santiago for day k
  stgo[[k]] =  StgoMap + geom_point(data=dflist[[k]], aes(x=lon, y=lat, size=n), 
                       show.legend = FALSE, col=alpha('hotpink2',0.4)) + 
  scale_size_continuous(range = c(3, max(dflist[[k]]$n))) +
  annotate("rect",xmin=-70.88, xmax=-70.69,ymin=-33.27,ymax=-33.31, color="white", fill="white")+
  annotate("text", x = -70.87, y = -33.28, label = date[k], size=8, hjust=0) +
  annotate("text", x = -70.87, y = -33.3, label = total_cases[k], size=6, hjust=0)
  
  stgo[[k]]
  
  #Save plots
  ggsave(paste0("stgo_day",k,".png"),
         plot = stgo[[k]],
         width = 5.5,
         height = 5.5,
         units = c("in")
         )
  files[k] = paste0("stgo_day",k,".png")
}

# You have to install ImageMagick!  
im.convert(files, 
           output = "covid_stgo.gif")

##### Chile

ChileMap <- qmap('Chile', zoom = 4,color = 'bw', legend = 'topleft')

date = rep(NA,length(days))
total_cases = rep(NA,length(days))

for(i in 1:length(days)){
  date[i] = paste0("March ",days[i],", 2020")
  total_cases[i] = paste0("Total = ",sum(dflist[[i]]$n))
}

chile = list()
files = rep(NA,length(days)
    
for(k in 1:length(days)){

  # Add tested cases
  chile[[k]] = ChileMap + geom_point(data=dflist[[k]], aes(x=lon, y=lat, size=n), 
                        show.legend = FALSE, col=alpha('hotpink2',0.4)) + 
  scale_size_continuous(range = c(1, max(dflist[[k]]$n)/2)) +
  annotate("rect",xmin=-99.6, xmax=-82,ymin=-10.1,ymax=-16, color="white", fill="white")+
  annotate("text", x = -99.4, y = -11.5, label = date[k], size=6, hjust=0) +
  annotate("text", x = -99.4, y = -14.5, label = total_cases[k], size=5, hjust=0)
  
  chile[[k]]
  
  #Save plots
  ggsave(paste0("chile_day",k,".png"),
         plot = chile[[k]],
         width = 5.5,
         height = 5.5,
         units = c("in")
         )
  files[k] = paste0("chile_day",k,".png")
  
}

# You have to install ImageMagick!  
im.convert(files, 
           output = "covid_chile.gif")
