##############################################################
### Title: Read first 20 lines of CoreLogic Data
### Author: Magdalena Bennett
### Date Created: 06/27/2023
### Last edit: [06/27/2023] - Create code
##############################################################

import pandas as pd

# Name of the file you want to read.
filename = "Q:/Bennett/Data/CoreLogic/CL_Part1/data1.txt"

# Extract first 20 lines. This allows you to get the names of the
# columns, and also see how the first rows of the data looks like.
df = pd.read_csv(filename, sep="|", nrows=20)

# Save this into an Excel file.
df.to_excel("Q:/Bennett/Data/CoreLogic/CL_Part1/variables_ownertransfer.xlsx")
