rm(list = ls())
cat("\014")

##########################################################
##### Function to geocode lat/lon from addresses
##########################################################

# Disclaimer: Code originally created by Kei Saito and adapted geocode
# Source: https://blog.exploratory.io/reverse-geocoding-part-2-using-google-maps-api-with-r-e676db36fee6

library(stringr)

#Sets dir_data to the path where this script is stored (you have to have rstudioapi installed as a package).
dir_data = paste0(dirname(rstudioapi::getSourceEditorContext()$path),"/")

#Change the name of the file
infile <- "input"

#Import data
data <- read.csv(paste0(dir_data,"data/", infile, '.csv'), stringsAsFactors = FALSE)

#If we are not using all the data (e.g. running different Ap Keys, slice the data with this vector)
#If not, comment out

#slice = 1:1000
#interval = "1_1000"
#data = data[slice,]

#Generate the complete address for the data(separated each space by a + sign) --> 
#In this case, full addresses were separated in different variables
data$Address = paste0(str_replace(data$STD_ADDR," ","+"),",+",data$STD_CITY,",+",data$STD_ST,"+",data$STD_ZIP5)

#Generate the complete address for the data (as one would type it)
data$Address2 = paste0(data$STD_ADDR,", ",data$STD_CITY,", ",data$STD_ST," ",data$STD_ZIP5)

#Generate a dummy variable to identify if the address is empty or not (will not run geocode on this)
data$empty_address = as.numeric(data$STD_ADDR=="")

# get the address list, and append "USA" to the end to increase accuracy 
# (change or remove this if your address already include a country etc.)
addresses = data$Address
addresses = paste0(addresses, ",+USA")
head(addresses)

# INSERT YOUR API KEY HERE:
apiKey = ""

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
  result <- matrix(NA,ncol=5,nrow=length(address))
  colnames(result) <- c("participant_code","mbr_dob","FormattedAddress","lat","lon")
  
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
    
    id1 = id[i,]
    
    result[i,] <- c(id1,ad,lat,lon)
    print(i)
  }
  
  # Return the result vector.
  result <- as.data.frame(result, stringsAsFactors=FALSE)
  names(result) <- c("id","FormattedAddress","lat","lon")
  
  return(list(result = result, request = requests))
}

#Call the function
latlon <- find_latlon(address = addresses, id = data$id, 
                      empty_address = data$empty_address,apiKey = apiKey)

save(latlon, data, file = paste0(dir_data,"data/latlon.Rdata"))
