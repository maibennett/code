# Read Big Data

This code is intended to read large datasets, extract specific chunks, and not load them in memory. I illustrate this with CoreLogic data, but you can easily adapt it to your needs.

- 00_extract_var_names.py: Two lines of script, to extract the first 20 lines of your data. It allows you to see the variables names and get a sneak peek at the data.
- 01_read_data.py: Script to show how to extract specific chunks from your large dataset. It allows for multiple files.
