# COVID-19 repository

Some of the code and data I'm using to put up:
https://www.magdalenabennett.com/covid
and
https://maibennett.shinyapps.com/corona_app

Here I'll be adding updated data and some maps for the spread of COVID-19 in Chile! (Note: Data publicly provided by Ministerio de Salud, and locations obtained through geocode R script (see other repositories) using Google Maps API)

#### Code
1) **scrape_daily_data.R:** Code originally created by Sue Marquez for NYS (https://github.com/Suemarquez/covid_nys), and adapted to scrape Chilean data.
2) **covid_maps_public.R:** Quick R code to generate maps for GIFs.
3) **geocode_residence_public.R:** R code to download data by residence (provided in the MinCiencia repository), geocode it (include lat/lon), and save it.
4) **scrape_pdfv2.py:** *Very rough* Python code to scrape confirmed cases by residence directly from the Epi Reports in pdf. *Disclaimer: I'm clearly not a Python coder, so code might be inefficient, but it works well with recent reports*.

#### Data
1) **data_covid.csv:** Data from the Ministry for tested individuals (+), with location according to the testing center (no longer being updated since 03/17). Individual data from archived reports [here](https://www.minsal.cl/nuevo-coronavirus-2019-ncov/casos-confirmados-en-chile-covid-19/).
2) **data_covid_region.csv:** Data from the Ministry for confirmed indivudals by region and date (from the first case, updated daily), recovered by scraping data from the ministry of health. Data at the region level scraped from [here](https://www.minsal.cl/nuevo-coronavirus-2019-ncov/casos-confirmados-en-chile-covid-19/).
3) **hospitalized.csv:** Data on total number of patients that have needed hospitalization by date. Data obtained from daily reports [here](https://www.gob.cl/coronavirus/cifrasoficiales/).
4) **symptoms.csv:** Data on percentage of patients (total and hospitalized) according to reported symptoms (updated according to the latest epidemiological report). Data can be downloaded from the daily epidemiological reports [here](http://epi.minsal.cl/informes-covid-19/).
5) **tests.csv:** Data on number of reported tests in Chile. Data obtained from daily reports [here](https://www.gob.cl/coronavirus/cifrasoficiales/).
6) **confirmed_cases_by_residence_latlon.csv:** Confirmed cases by date and county of residency (comuna), as provided by the Ministry of Health in their repository (check out [here](http://www.minciencia.gob.cl/covid19)). Lat/Lon refer to latitude and longitude obtained from geocoding the counties using Google's geocode API. Bulk of the data was obtained by scraping the report the Minstry provides, but some manual adaptation was made to reflect municipalities that have less than 4 cases (so they can still be included in the map).
