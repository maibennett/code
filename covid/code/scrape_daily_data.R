################################################################################################ 
#### This code was originaly created by Sue Marquez (https://github.com/Suemarquez/covid_nys)
#### and I very slightly adapted it to this task
################################################################################################

# Code to scrape daily data from the ministry of health (new cases by region) 

library(tidyverse)
library(stringr)
library(pdftools)
library(rvest)

url <- read_html("https://www.minsal.cl/nuevo-coronavirus-2019-ncov/casos-confirmados-en-chile-covid-19/") #This is the website we want to scrape

regions = c("Arica y Parinacota","Tarapaca","Antofagasta","Atacama", "Coquimbo", 
            "Valparaiso", "Metropolitana","Ohiggins", "Maule","Nuble","Biobio",
            "Araucania","Los Rios","Los Lagos","Aysen","Magallanes")

covid_count_table <- html_nodes(url, "table") %>% #In this case, the data we want to get is in <table> </table>
  .[[1]] %>%
  html_table(fill=TRUE) %>% 
  rename(Region = X1, NewCases = X2,TotalCases = X3,Deaths = X5) %>% #Give them better names
  filter(Region!="",Region!="Total",Deaths!="Fallecidos") %>% #Filter rows that we don't need
  mutate(Region = regions) %>% #Rename regions so they are equivalent to other files
  mutate(TotalCases = str_replace_all(TotalCases, ".", "")) %>% #Change the thousand separator
  select(Region,NewCases,Deaths) #Just select the columns we need

#Now we need to include the date:
#Date from 1st case:
first_date = as.Date("2020-03-03")

date = html_nodes(url, "p")%>% #The date for the report is given under the table betweeb <p></p>. To know which nodes to select, you can use (Right Click - Inspect) on your browser to see the html code (if, as me, you are not as familiar with this)
  .[[1]] %>%
  html_text() %>% #this is just text
  str_match("Informe corresponde al (.*?). El") #Extracts the date that the report was updated, which is located between these two strings

date = date[,2]

date_char = str_match(date,"(.*?) de (.*?) ")
day = as.numeric(date_char[,2])

months = c("enero","febrero","marzo","abril","mayo","junio","julio",
           "agosto","septiembre","octubre","noviembre","diciembre")
month = which(months == date_char[,3]) #Months are in Spanish, so we convert them to numbers

update_date = as.Date(paste("2020",month,day,sep="-")) #Date for the update

days = update_date - first_date #Days since first case

#Load Data
d = read.csv("https://raw.githubusercontent.com/maibennett/code/master/covid/data_covid_region.csv",
             stringsAsFactors = FALSE) #Read the data we already had

#Build updated data in the format of the previous data
d_update = cbind(rep(days,nrow(covid_count_table)),covid_count_table)
names(d_update) = c("day","region","n_obs","Deaths")

d_update$n_obs = as.numeric(d_update$n_obs)
d_update$Deaths = as.numeric(d_update$Deaths)

d_update$date = paste(month,day,"2020",sep="/")

d_update$region_lat = NA
d_update$region_lon = NA

for(i in 1:16){
  d_update$region_lat[d_update$region==regions[i]] = mean(d$region_lat[d$region==regions[i]])
  d_update$region_lon[d_update$region==regions[i]] = mean(d$region_lon[d$region==regions[i]])
            
  #Change deaths to new deaths, instead of cumulated deaths, which is what the ministry reports:
  d_update$Deaths[d_update$region==regions[i]] =   d_update$Deaths[d_update$region==regions[i]] - sum(d$Deaths[d$region==regions[i]])
}

#Only update if there's new data:
if(days==max(d$day)){
  d = d
}

if(days>max(d$day)){
  d = rbind(d,d_update)
}

path_countdata <- "data_covid_region.csv"

write_csv(d, path = path_countdata)
