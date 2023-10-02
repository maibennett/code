##############################################################
### Title: Extract CoreLogic data
### Author: Magdalena Bennett
### Date Created: 06/27/2023
### Last edit: [06/27/2023] - Create code
##############################################################

import gc

# This will just make sure we are able to free up any
# unused memory.
gc.enable()

# Create an array with the files you want to run through
# (In this case, we're only running through two files, but
# you can include as many files you want! Even just one!)

file = [""]*2
file[0] = "Q:/Bennett/Data/CoreLogic/CL_Part_1/data1.txt"
file[1] = "Q:/Bennett/Data/CoreLogic/CL_Part_1/data2.txt"

# In this case, I want to extract data for a specific state and a
# specific year. If you want to search by another variable (or just one),
# just edit accordingly.

##### EDIT FOR EACH STATE AND YEAR
state = "Texas"

# Set the target state and year
target_state = 'TX'
target_year1 = '2005'
target_year2 = '2006'
#####

# Create a file for your your output data (this will be the extract of the
# dataset that you want). I usually use the target variables for this, so
# the name changes automatically when my target changes.

output_file = "Q:/Bennett/Data/CoreLogic/States/" + state + target_year1 + "_" + target_year2 + ".txt"
check_file = "Q:/Bennett/Data/CoreLogic/States/" + state + target_year1 + "_" + target_year2 + "files_checked.txt"

n_file = 1

# For many files, I find it useful to know which files have already been
# searched. If anything happens, then I can only search on the ones that
# are missing. YMMMV.

with open(check_file, 'a') as check, open(output_file, 'w') as out:
  for f in file:
    done = str(f) + "\n"
    check.write(done)
  
    # Open the input file for reading
    with open(f, 'r') as input_file:
      # Iterate over each line in the file
      for line in input_file:
          # Split the line into columns
          columns = line.split('|')  # Assuming tab-separated columns, adjust if necessary
        
          # Extract the state and year values (see 00_extract_var_names.py,
          # if you want to see how I search for the column names)
          state = columns[58]  # column for state. Adjust if necessary
          year = columns[126]  # column for year. Adjust if necessary
        
          # Check if the line matches the target state and year (and save that in
          # your output_file!)
          if state == target_state and (year == target_year1 or year == target_year2):
              # Process the matching line
              out.write(line)
    

