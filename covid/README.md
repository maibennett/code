## COVID-19 repository

Some of the code and data I'm using to put up:
https://www.magdalenabennett.com/covid
and
https://maibennett.shinyapps.com/corona_app

Here I'll be adding updated data and some maps for the spread of COVID-19 in Chile! (Note: Data publicly provided by Ministerio de Salud, and locations obtained through Google Maps)

1) **data_covid.csv:** Data from the Ministry for tested individuals (+), with location according to the testing center.
2) **data_covid_region.csv:** Data from the Ministry for confirmed indivudals by date (from the first case, updated daily).
3) **covid_maps_public.R:** Quick R code to generate maps for GIFs.
4) **confirmed_cases_by_residence_latlon.csv:** Confirmed cases by date and county of residency (comuna), as provided by the Ministry of Health in their Epidemiology reports. Lat/Lon refer to latitude and longitude obtained from geocoding the counties using Google's geocode API (you can check out the code in my other repository folders).
