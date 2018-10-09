rm(list = ls())
cat("\014")

##########################################################
##### Function to reverse geocode addresses from lat/lon
##########################################################

# Disclaimer: Code originally created by Kei Saito and slightly adapted to get full addresses
# Source: https://blog.exploratory.io/reverse-geocoding-part-2-using-google-maps-api-with-r-e676db36fee6

library(stringr)

dir_data = paste0(dirname(rstudioapi::getSourceEditorContext()$path),"/")

infile <- "input"
data <- read.csv(paste0(dir_data, infile, '.csv'), stringsAsFactors = FALSE)

# INSERT YOUR API KEY HERE IF YOU HAVE ONE
apiKey = ""

# Function to return address from lat/lon using Google's geocode API.
# (2,500 requests a day are allowed for free. Check the API for more information)

# long: vector of longitudes
# lat: vector of latitudes
# id: ids for the longitudes and latitudes (to merge with data afterwords)

find_address <- function(long, lat, id, apiKey = NULL) {
  # Request URL parameters
  parameters <- ""
  # Add API Key in the parameters if available.
  if (!is.null(apiKey)) {
    parameters <- str_c("&key=", apiKey)
  }
  # Construct Google Maps APIs request URL.
  apiRequests <- iconv(str_c("https://maps.googleapis.com/maps/api/geocode/json?latlng=", lat, ",", long, parameters), "", "UTF-8")
  # Prefecture names will be stored to this.
  result <- matrix(NA,ncol=6,nrow=length(lat))
  
  # Iterate longitude/latitude combinations.
  for(i in 1:length(lat)) {
    # Avoid calling API too often.
    Sys.sleep(0.1)
    # Call Google Maps API.
    conn <- httr::GET(URLencode(apiRequests[i]))
    # Parse the JSON response. 
    apiResponse <- jsonlite::fromJSON(httr::content(conn, "text"))
    # Look at the address_components of the 1st address.
    ac <- apiResponse$results$address_components[[1]]
    
    # address (store address results
    address_num <- ""
    address_street <- ""
    address_city <- ""
    address_neighborhood <- ""
    address_state <- ""
    address_zipcode <- ""
     
    if (!is.null(ac)) {
      # Iterate the types of the current address_components.
      for (j in 1:length(ac$types)) {
        if (ac$types[[j]][[1]] == "administrative_area_level_1") {
          address_state <- ac$short_name[[j]]
        }
        if (ac$types[[j]][[1]] == "locality") {
          address_city <- ac$long_name[[j]]
        }
        if (ac$types[[j]][[1]] == "street_number") {
          address_num <- ac$short_name[[j]]
        }
        if (ac$types[[j]][[1]] == "route") {
          address_street <- ac$short_name[[j]]
        }
        if (ac$types[[j]][[1]] == "neighborhood") {
          address_neighborhood <- ac$long_name[[j]]
        }
        if (ac$types[[j]][[1]] == "postal_code") {
          address_zipcode <- ac$short_name[[j]]
        }
      }
    }    
    result[i,] <- c(address_num,address_street,address_city,address_neighborhood,
                    address_state,address_zipcode)
  }
  
  # Return the result vector.
  result <- as.data.frame(id,result, stringsAsFactors=FALSE)
  names(result) <- c("Id","StreetNumber","StreetName","CityName","Neighborhood","State","Zipcode")
  #paste the full address
  result$address <- paste(result$StreetNumber,result$StreetName,result$CityName,result$Neighborhood,result$State,result$Zipcode)
  return(result)
}

#Call the function (use apiKey if you have one)
addresses <- find_address(data$lon,data$lat,apiKey = apiKey)
