# -*- coding: utf-8 -*-
"""
Created on Fri Apr 10 09:22:11 2020
@author: maibe
"""
#############################################
### Scrape PDFs from Ministerio de Salud
#############################################

import tabula #library that extracts tables from pdfs
import pandas as pd
import re
import unidecode 
import csv
import gc

gc.collect()

directory = "C:/Users/maibe/Dropbox/covid/data/"    
    
date = 20200407
#date = 20200405
#date = 20200402

url = "https://www.minsal.cl/wp-content/uploads/2020/04/Informe_EPI_GOB_08_04_2020.pdf"
#url = "https://www.minsal.cl/wp-content/uploads/2020/04/Reporte_COVID_19_06_04_2020.pdf"
#url = "https://www.minsal.cl/wp-content/uploads/2020/04/Informe_EPI_03_04_2020.pdf"

#Data for informe de epidemiologia
chile_residence = tabula.read_pdf(url, pages = 'all' ,guess=False)

regions = ["Arica y Parinacota","Tarapaca","Antofagasta","Atacama", "Coquimbo", 
              "Valparaiso", "Metropolitana","Ohiggins", "Maule","Nuble","Biobio",
              "Araucania","Los Rios","Los Lagos","Aysen","Magallanes"]

#### Search where the first table is:
start = False
count = -1

while start == False:
    count = count + 1
    search = chile_residence[count]
    search = list(map(str, list(search[search.columns[0]])))
    b1 = sum([1 if 'ANALISIS REGIONAL' in i else 0 for i in search])
    b2 = sum([1 if 'Contenido' in i else 0 for i in search])
    if b1>0 and b2==0:
        start = True
##### 
        
region_id = 0

colnames = ['region','comuna','poblacion','n','rate']

residence = pd.DataFrame(columns = colnames)

# Remove accents
def remove_accents(a):
    return unidecode.unidecode(a)

# The loop repeats itself until we find all 16 regions 
while region_id<17:
    
    # Gets info from the the page count
    table = chile_residence[count]
    table = table.fillna("")
       
    table['All'] = table[table.columns[0]] + " " + table[table.columns[1]]
    
    firstcolumn = list(map(str, list(table[table.columns[2]])))
    
    # Approximates where the table is
    lim1a = max([firstcolumn.index(i) if 'Población' in i else 0 for i in firstcolumn])
    lim1b = max([firstcolumn.index(i) if 'incidencia' in i else 0 for i in firstcolumn])
    lim1 = max(lim1a,lim1b)
    lim2 = min([firstcolumn.index(i) if 'Total' in i else table.shape[0] for i in firstcolumn])
    
    # If the table expands for two pages, we will run additional code
    twopage = min([0 if 'Total' in i else 1 for i in firstcolumn]) 
    
    table = table.iloc[lim1+1:lim2]

    firstcolumn = list(map(str, list(table[table.columns[2]])))

    # Drop the row "Por determinar" (if there is one)
    drop = max([firstcolumn.index(i) if 'Por determinar' in i else 0 for i in firstcolumn]) 

    if drop != 0:
        table = table.iloc[:drop]
    
    if twopage>0:
        firstcolumn = list(map(str, list(table[table.columns[2]])))
        drop = min([firstcolumn.index(i) if 'Tabla' in i else table.shape[0] for i in firstcolumn])
        if drop != 0:
            table = table.iloc[:drop]
            
    # Now we have to separate the data (comina, population, number of cases, and rate)
    temp = re.compile("([a-zA-Z- ]+) (\d*\.?\d+) ([0-9- ]+) (\d*\,?\d+)")  # we are going to separate strings from numbers 
    
    # We remove accents to keep it consistent (and make things easier)
    table[table.columns[2]] = table[table.columns[2]].apply(remove_accents)
    
    table['comuna'] = ""
    table['poblacion'] = "NA"
    table['n'] = "NA"
    table['rate'] = "NA"
        
    for i in range(0,table.shape[0]):
        # We add this first line for Villa O'higgins
        table[table.columns[2]].iloc[i] = table[table.columns[2]].iloc[i].replace("\'", "").strip()
        res = temp.match(table[table.columns[2]].iloc[i]).groups()
        table['comuna'].iloc[i] = res[0].strip()
        table['poblacion'].iloc[i] = res[1].strip()
        table['n'].iloc[i] = res[2].strip()
        table['rate'].iloc[i] = res[3].strip()
    
    # Drop columns we don't need       
    table = table.drop(table.columns[0:3], axis=1)
    table['region'] = regions[region_id]
    
    # If the table expands for two pages, we do the same for the second half of the table.
    if twopage>0:
        count = count + 1
        table2 = chile_residence[count]
        table2 = table2.fillna("")
       
        table2['All'] = table2[table2.columns[0]] + " " + table2[table2.columns[1]]
    
        firstcolumn = list(map(str, list(table2[table2.columns[2]])))
    
        lim1 = max([firstcolumn.index(i) if 'Población' in i else 0 for i in firstcolumn])
        lim2 = min([firstcolumn.index(i) if 'Total' in i else table2.shape[0] for i in firstcolumn])
       
        table2 = table2.iloc[lim1+1:lim2]

        firstcolumn = list(map(str, list(table2[table2.columns[2]])))

        drop = max([firstcolumn.index(i) if 'Por determinar' in i else 0 for i in firstcolumn]) 

        if drop != 0:
            table2 = table2.iloc[:drop]
    
        temp = re.compile("([a-zA-Z- ]+) (\d*\.?\d+) ([0-9- ]+) (\d*\,?\d+)")  # we are going to separate strings from numbers 
    
        table2[table2.columns[2]] = table2[table2.columns[2]].apply(remove_accents)
    
        table2['comuna'] = ""
        table2['poblacion'] = "NA"
        table2['n'] = "NA"
        table2['rate'] = "NA"
    
        for i in range(0,table2.shape[0]):
            #table2[table2.columns[2]] = table2[table2.columns[2]].iloc[i].replace("-", "")
            table2[table2.columns[2]].iloc[i] = table2[table2.columns[2]].iloc[i].replace("\'", "").strip()
            res = temp.match(table2[table2.columns[2]].iloc[i]).groups()
            table2['comuna'].iloc[i] = res[0].strip()
            table2['poblacion'].iloc[i] = res[1].strip()
            table2['n'].iloc[i] = res[2].strip()
            table2['rate'].iloc[i] = res[3].strip()
           
        table2 = table2.drop(table2.columns[0:3], axis=1)
        table2['region'] = regions[region_id]
    
        table = table.append(table2)
    
    # Append the regional table we just created to the total table        
    residence = residence.append(table) #append
        
    count = count + 1
        
    print("Region " + regions[region_id])
    region_id = region_id + 1

    # See if we need to skip the next page    
    table = chile_residence[count]
    
    # For pages that do not have a table, we skip it.            
    if table.shape[1]==1:
        count = count+1
        

# Include the date the data was collected       
residence['date'] = str(date)[4:6] + "/" + str(date)[6:8] + "/" +str(date)[0:4]

# Save the csv file.
directory = directory
name_file = directory + "residence_epi_" + str(date) + ".csv"

residence.to_csv(name_file, index = False)
    
