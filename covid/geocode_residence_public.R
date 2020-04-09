rm(list = ls())
cat("\014")

##########################################################
##### Function to geocode lat/lon from addresses
##########################################################

# Disclaimer: Code originally created by Kei Saito and adapted geocode
# Source: https://blog.exploratory.io/reverse-geocoding-part-2-using-google-maps-api-with-r-e676db36fee6

library(stringr)

#Sets dir_data to the path where this script is stored (you have to have rstudioapi installed as a package).
dir_data = "C:/Users/maibe/Dropbox/covid/data/"

#Change the name of the file
infile <- "https://raw.githubusercontent.com/MinCiencia/Datos-COVID19/master/output/producto1/Covid-19.csv"

#Import data
data <- read.csv(infile, stringsAsFactors = FALSE)

#Generate address that we're going to look up:
data$address = paste0(data$Comuna,", Region de ",data$Region,", Chile")

#Generate the complete address for the data(separated each space by a + sign) --> 
#In this case, full addresses were separated in different variables
data$address2 = str_replace_all(data$address," ","+")

#Generate a dummy variable to identify if the address is empty or not (will not run geocode on this)
data$empty_address = as.numeric(data$address=="")

# get the address list, and append "USA" to the end to increase accuracy 
# (change or remove this if your address already include a country etc.)
addresses = data$address2
head(addresses)

# INSERT YOUR API KEY HERE:
apiKey = "YOUR API KEY"

data$id = seq(1,nrow(data),1)

# address: formatted US address according to USPS standards
# id: ids for the observations (to merge with data afterwords)

#Store the number of requests to keep track of costs
requests = 0

find_latlon <- function(address, id, empty_address, apiKey = NULL) {
  # Request URL parameters
  parameters <- ""
  # Add API Key in the parameters if available.
  if (!is.null(apiKey)) {
    parameters <- str_c("&key=", apiKey)
  }
  # Construct Google Maps APIs request URL.
  apiRequests <- iconv(str_c("https://maps.googleapis.com/maps/api/geocode/json?address=",address, parameters), "", "UTF-8")
  # Prefecture names will be stored to this.
  result <- matrix(NA,ncol=4,nrow=length(address))
  colnames(result) <- c("id","FormattedAddress","lat","lon")
  
  # Iterate longitude/latitude combinations.
  for(i in 1:length(address)) {
    # Avoid calling API too often.
    Sys.sleep(0.1)
    # Call Google Maps API.
    if(empty_address[i]==0){
      
      conn <- httr::GET(URLencode(apiRequests[i]))
      
      requests = requests + 1
      
      # Parse the JSON response. 
      apiResponse <- jsonlite::fromJSON(httr::content(conn, "text"))
      # Look at the address_components of the 1st address.
      ac <- apiResponse$results$geometry$location
    }
    
    if(empty_address[i]==1){
      ac = NULL
    }
    
    # address (store address results
    lat <- NA
    lon <- NA
    ad <- NA
    
    if (!is.null(ac) & empty_address[i]==0) {
      ad = apiResponse$results$formatted_address[1]
      lat = ac$lat[1]
      lon = ac$lng[1]
    } 
    
    id1 = id[i]
    
    result[i,] <- c(id1,ad,lat,lon)
    print(i)
  }
  
  # Return the result vector.
  result <- as.data.frame(result, stringsAsFactors=FALSE)
  names(result) <- c("id","FormattedAddress","lat","lon")
  
  return(list(result = result, request = requests))
}

#Generate an id variable for easier handling
data$id = seq(1,nrow(data))

#Call the function
latlon <- find_latlon(address = addresses, id = data$id, 
                      empty_address = data$empty_address,apiKey = apiKey)

#Merge the original data with the latitudes and longitudes

df = merge(data,latlon$result, by="id",all.x = TRUE,all.y=TRUE)

df$lat = as.numeric(df$lat)
df$lon = as.numeric(df$lon)

#Re-arrange the data now:
library(dplyr)

df = df %>% gather("date","n",X2020.03.30,X2020.04.01,X2020.04.03,X2020.04.06,X2020.04.08)

#Change the dates to actual dates:
df$date[df$date=="X2020.03.30"] = "03/30/2020"
df$date[df$date=="X2020.04.01"] = "04/01/2020"
df$date[df$date=="X2020.04.03"] = "04/03/2020"
df$date[df$date=="X2020.04.06"] = "04/06/2020"
df$date[df$date=="X2020.04.08"] = "04/08/2020"

df$n[df$n=="-" | df$n=="-"] = NA 

df$n = as.numeric(df$n)
df$aprox = 0

df = df %>% rename(comuna=Comuna,region=Region)

# Rename regions so they match with the other data:
df$region[df$region=="Del Libertador General Bernardo OHiggins"] = "Ohiggins"
df$region[df$region=="La Araucania"] = "Araucania"
df$region[df$region=="Aisen"] = "Aysen"
df$region[df$region=="Magallanes y la Antartica"] = "Magallanes" 

write.csv(df, file = paste0(dir_data,"confirmed_cases_by_residence_latlon.csv"))
