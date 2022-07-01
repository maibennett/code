# -*- coding: utf-8 -*-
"""
Purpose: Code to scrape who cites the papers from a specific author
Created on Thu Jun 30 11:23:18 2022
@author: Magdalena Bennett (@maibennett)
"""

import pandas as pd
import csv
import json
from serpapi import GoogleScholarSearch

# api key from SerpAPI
api_key = #INSERT YOUR API KEY FROM SERPAPI HERE
# Author's name (we are looking for)
author_name = "Mirya R. Holman" 

#####################################################################
# Search for user (to find their ID) (you can do this manually too)
#####################################################################

params = {
    "api_key": api_key,
    "engine": "google_scholar_profiles",
    "hl": "en",
    "mauthors": author_name
}

search = GoogleScholarSearch(params)
results = search.get_dict()

author_id = results['profiles'][0]['author_id']

#####################################################################
# Get citations ids for articles from the previous author
#####################################################################

# Get citation ids for articles (restricted to 100 articles):
params = {
    "api_key": api_key,
    "engine": "google_scholar_author",
    "author_id": author_id,
    "num": "100"  
}

search = GoogleScholarSearch(params)
results = search.get_dict()

articles = results['articles']

#####################################################################
# Get names of authors that have cited the previous papers
#####################################################################

# This is where we will store the name and author id of the people that cite
authors_that_cite = {"name":[],
                     "author_id":[]}

# Gets first 20 results, but can iterate by changing this
# (start = "20" starts on the 3rd page, etc.)
start = "0"
num = "20"

# Only start with an empty list if we are on the first iteration
if start == "0":
    full_cited_by = []

# Go through artciles and get the information of who cites them
for article in articles:
    
    params = {
        "api_key": api_key,
        "engine": "google_scholar",
        "cites": article['cited_by']['cites_id'],
        "start": start,
        "num": num
        }

    search = GoogleScholarSearch(params)
    results = search.get_dict()
    
    full_cited_by = full_cited_by  + results['organic_results']

for result in full_cited_by:
    
    if "authors" in result['publication_info']:
        authors_info = result['publication_info']['authors']
    
        for author in authors_info:
            authors_that_cite["name"].append(author["name"])
            authors_that_cite["author_id"].append(author["author_id"])
            
import csv

file_csv = "authors_that_cite.csv" # You can add a path as well

df = pd.DataFrame(authors_that_cite)

df.to_csv(file_csv, index=False)


