################################################################################################ 
#### This code was originaly created by Sue Marquez (https://github.com/Suemarquez/covid_nys)
#### and I very slightly adapted it to this task
################################################################################################

# Code to scrape daily data from the ministry of health (new cases by region) 

library(tidyverse)
library(stringr)
library(pdftools)
library(rvest)

url <- read_html("https://www.minsal.cl/nuevo-coronavirus-2019-ncov/casos-confirmados-en-chile-covid-19/")

regions = c("Arica y Parinacota","Tarapaca","Antofagasta","Atacama", "Coquimbo", 
            "Valparaiso", "Metropolitana","Ohiggins", "Maule","Nuble","Biobio",
            "Araucania","Los Rios","Los Lagos","Aysen","Magallanes")

covid_count_table <- html_nodes(url, "table") %>%
  .[[1]] %>%
  html_table(fill=TRUE) %>%
  rename(Region = X1, NewCases = X2,TotalCases = X3,Deaths = X5) %>% #Give them better names
  filter(Region!="",Region!="Total",Deaths!="Fallecidos") %>% #Filter rows that we don't need
  mutate(Region = regions) %>% #Rename regions so they are equivalent to other files
  mutate(TotalCases = str_replace_all(TotalCases, ".", "")) %>% #Change the thousand separator
  select(Region:NewCases) #Just select the two columns we need

#Now we need to include the date:

#Date from 1st case:
first_date = as.Date("2020-03-03")

date = html_nodes(url, "p")%>%
  .[[1]] %>%
  html_text() %>%
  str_match("Informe corresponde al (.*?). El")

date = date[,2]

date_char = str_match(date,"(.*?) de (.*?) ")
day = as.numeric(date_char[,2])

months = c("enero","febrero","marzo","abril","mayo","junio","julio",
           "agosto","septiembre","octubre","noviembre","diciembre")
month = which(months == date_char[,3])


update_date = as.Date(paste("2020",month,day,sep="-"))

days = update_date - first_date

#Load Data
d = read.csv("https://raw.githubusercontent.com/maibennett/code/master/covid/data_covid_region.csv",
             stringsAsFactors = FALSE)

d_update = cbind(rep(days,nrow(covid_count_table)),covid_count_table)
names(d_update) = c("day","region","n_obs")

d_update$date = paste(month,day,"2020",sep="/")

d_update$region_lat = NA
d_update$region_lon = NA

for(i in 1:16){
  d_update$region_lat[d_update$region==regions[i]] = mean(d$region_lat[d$region==regions[i]])
  d_update$region_lon[d_update$region==regions[i]] = mean(d$region_lon[d$region==regions[i]])
}

#drop regions with no new cases:
d_update = d_update[d_update$n_obs!=0,]

d = rbind(d,d_update)

path_countdata <- "C:/Users/maibe/Dropbox/covid/data/data_covid_region.csv"

write_csv(d, path = path_countdata)