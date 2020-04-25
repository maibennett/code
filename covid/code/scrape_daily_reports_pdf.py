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

import tabula #library that extracts tables from pdfs
import pandas as pd
import re
import unidecode 
import csv
import gc

date = 20200425 #Insert date of the report in the format yyyymmdd

# Separate day month and year for the date
day = str(date)[6:8]
month = str(date)[4:6]
year = str(2020)

# Most versions are "", but some have other versions (like v3)
#version = "v3"
version = ""

# URL changed for 2020/04/21
if date!=20200421:
    url = "https://cdn.digital.gob.cl/public_files/Campañas/Corona-Virus/Reportes/"+day+"."+month+"."+"2020_Reporte_Covid19"+version+".pdf"
else:
    url = "https://www.minsal.cl/wp-content/uploads/2020/04/"+day+month+"2020_Reporte_Covid19.pdf"

# Get data from daily reports
DailyReports = tabula.read_pdf(url,pages='all')

####### For tests (all) by institution:
all_tests = pd.read_csv('https://raw.githubusercontent.com/maibennett/code/master/covid/data/tests.csv') # Download updated data from GitHub
tests = DailyReports[2][2:] #Get table from report

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
    directory = "C:/" #Insert the path for the directory here
    name_file = directory + "tests.csv"

    all_tests.to_csv(name_file, index = False)

####### For daily data by region:
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
                 all_data.columns[6]: data['Fallecidos'].iloc[k]-sum(all_data_subset['Deaths'])}, ignore_index=True)
        k = k+1

    all_data = all_data.append(dailydata)
    directory = "C:/" #Insert the path for the directory here
    name_file = directory + "data_covid_region.csv"

    all_data.to_csv(name_file, index = False)


##### For tests by region:
all_tests_region = pd.read_csv("https://raw.githubusercontent.com/maibennett/code/master/covid/data/tests_by_newcases.csv")

if date<20200414:
    tests_region = DailyReports[2][0:DailyReports[2].shape[0]-1]
if date==20200425:
    tests_region = DailyReports[10][0:DailyReports[10].shape[0]-1]
else:
    tests_region = DailyReports[3][0:DailyReports[3].shape[0]-1]
    
# For daily data:
data_region = DailyReports[0][0:16]

update_date = str(int(month)) + "/" + str(int(day)-1) + "/" +str(year)

regions = ["Arica y Parinacota","Tarapaca","Antofagasta","Atacama", "Coquimbo", 
              "Valparaiso", "Metropolitana","Ohiggins", "Maule","Nuble","Biobio",
              "Araucania","Los Rios","Los Lagos","Aysen","Magallanes"]


data[data.columns[0]] = regions

# Remove accents
def remove_accents(a):
    return unidecode.unidecode(a)

tests_region[tests_region.columns[0]] = tests_region[tests_region.columns[0]].apply(remove_accents)

# Adapt names of regions:
region_prompts = ["Arica","Tarapaca","Antofagasta","Atacama", "Coquimbo", 
              "Valparaiso", "Metropolitana","O'Higgins", "Maule","Nuble","Bio",
              "Araucania","Los Rios","Los Lagos","Aysen","Magallanes"]

i = 0

region_names = []

for region in region_prompts:
    if sum(tests_region[tests_region.columns[0]].str.match(region)) == 1:
        region_names.append(regions[i])
    i = i+1

tests_region[tests_region.columns[0]] = region_names

# Only if we haven't recorded that value
if all_tests_region[all_tests_region["date"].str.match(update_date)].shape[0]==0:
    dailytest = pd.DataFrame(columns=all_tests_region.columns)

    k = 0
    i = 0
    
    for region in regions:
        
        if sum(tests_region[tests_region.columns[0]].str.match(region)) == 1:
            dailytest = dailytest.append(
                    {all_tests_region.columns[0]: update_date,
                     all_tests_region.columns[1]: region,
                     all_tests_region.columns[2]: tests_region['# exámenes informados'].iloc[i],
                     all_tests_region.columns[3]: data[data.columns[1]].iloc[k]}, ignore_index=True)
            i = i+1
            
        else:
            dailytest = dailytest.append(
                    {all_tests_region.columns[0]: update_date,
                     all_tests_region.columns[1]: region,
                     all_tests_region.columns[2]: 0,
                     all_tests_region.columns[3]: data[data.columns[1]].iloc[k]}, ignore_index=True)
        k = k+1

    all_tests_region = all_tests_region.append(dailytest)
    directory = "C:/" #Insert your directory here
    name_file = directory + "tests_by_newcases.csv"

    all_tests_region.to_csv(name_file, index = False)
