# -*- coding: utf-8 -*-
"""
Created on Fri Apr 10 09:22:11 2020
@author: maibe
"""
#############################################
### Scrape PDFs from Ministerio de Salud
### Get the data I need from daily reports
#############################################

import tabula #library that extracts tables from pdfs
import pandas as pd
import re
import unidecode 
import csv
import gc

## Disclaimer: Format of reports have been changing, so this code might need to get slightly adjusted to reflect some of these changes in the future.

###### Change the date and the version of the report here
date = 20200420
#version = "v3"
version = ""
##########################################################

day = str(date)[6:8]
month = str(date)[4:6]
year = str(2020)

url = "https://cdn.digital.gob.cl/public_files/Campañas/Corona-Virus/Reportes/"+day+"."+month+"."+"2020_Reporte_Covid19"+version+".pdf"

#Data from daily reports
DailyReports = tabula.read_pdf(url,pages='all')

# For tests:
all_tests = pd.read_csv('https://raw.githubusercontent.com/maibennett/code/master/covid/data/tests.csv')
tests = DailyReports[2][2:]

update_date = str(int(month)) + "/" + str(int(day)-1) + "/" +str(year)

# Only if we haven't recorded that value
if all_tests[all_tests["date"].str.match(update_date)].shape[0]==0:
    dailytest = pd.DataFrame(columns=all_tests.columns)

    dailytest = dailytest.append(
            {all_tests.columns[0]: update_date,
             all_tests.columns[1]: int(tests[tests.columns[1]].iloc[3].replace(".","")),
             all_tests.columns[2]: int(tests[tests.columns[1]].iloc[0].replace(".","")),
             all_tests.columns[3]: int(tests[tests.columns[1]].iloc[1].replace(".","")),
             all_tests.columns[4]: int(tests[tests.columns[1]].iloc[2].replace(".","")),
             all_tests.columns[5]: int(tests[tests.columns[3]].iloc[0].replace(".","")),
             all_tests.columns[6]: int(tests[tests.columns[3]].iloc[1].replace(".","")),
             all_tests.columns[7]: int(tests[tests.columns[3]].iloc[2].replace(".",""))}, ignore_index=True)

    all_tests = all_tests.append(dailytest)
    directory = "C:/Users/maibe/Dropbox/covid/data/"
    name_file = directory + "tests.csv"

    all_tests.to_csv(name_file, index = False)

# For daily data:
all_data = pd.read_csv('https://raw.githubusercontent.com/maibennett/code/master/covid/data/data_covid_region.csv')
data = DailyReports[0]

update_date = str(int(month)) + "/" + str(int(day)) + "/" +str(year)

regions = ["Arica y Parinacota","Tarapaca","Antofagasta","Atacama", "Coquimbo", 
              "Valparaiso", "Metropolitana","Ohiggins", "Maule","Nuble","Biobio",
              "Araucania","Los Rios","Los Lagos","Aysen","Magallanes"]

# Only if we haven't recorded that value
if all_data[all_data["date"].str.match(update_date)].shape[0]==0:
    dailydata = pd.DataFrame(columns=all_data.columns)
    
    k = 0
    
    for region in regions:
        
        all_data_subset = all_data[all_data['region'] == region] 
        
        dailydata = dailydata.append(
                {all_data.columns[0]: max(all_data['day'])+1,
                 all_data.columns[1]: region,
                 all_data.columns[2]: update_date,
                 all_data.columns[3]: max(all_data_subset['region_lat']),
                 all_data.columns[4]: max(all_data_subset['region_lon']),
                 all_data.columns[5]: data['Casos nuevos'].iloc[k],
                 all_data.columns[6]: data['Fallecidos'].iloc[k]}, ignore_index=True)
        k = k+1

    all_data = all_data.append(dailydata)
    directory = "C:/Users/maibe/Dropbox/covid/data/"
    name_file = directory + "data_covid_region.csv"

    all_data.to_csv(name_file, index = False)


# For UCI:
uci_all = pd.read_csv('https://raw.githubusercontent.com/maibennett/code/master/covid/data/hospitalized.csv')
uci = DailyReports[3].iloc[16]

update = pd.isna(uci_all[uci_all["Date"].str.match(update_date)]['UCI'])
# Only if we haven't recorded that value
if uci_all[uci_all["Date"].str.match(update_date)].shape[0]==0 or update.bool():
    
    dailyuci = pd.DataFrame(columns=uci_all.columns)

    dailyuci = dailyuci.append(
            {'Date': update_date,
             'UCI': int(uci[1]),
             'use2': 1}, ignore_index=True)

    if uci_all[uci_all["Date"].str.match(update_date)].shape==0:    
        uci_all = uci_all.append(dailyuci)
        
    if update.bool():
        uci_all['Hospital'].iloc[uci_all.shape[0]-1] = n
        uci_all['use2'].iloc[uci_all.shape[0]-1] = 1
        
    uci_all = uci_all.append(dailyuci)
    directory = "C:/Users/maibe/Dropbox/covid/data/"
    name_file = directory + "hospitalized_updated" + str(date) + ".csv"

    uci_all.to_csv(name_file, index = False)
