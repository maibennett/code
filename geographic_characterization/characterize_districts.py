################################################################################
## PURPOSE: Characterize school districts with census tract data
## AUTHOR: Magdalena Bennett
## DATE: 08/09/2019
################################################################################

## Description: This script is meant to be run in ArcGIS, to characterize school districts
##              with census tract data. This can be easily adapted to other geographic boundaries
##              such as school attending zones and zipcodes

## To run on ArcMap (Python command line): 
## execfile(r'C:\\characterize_districts.py')

import arcpy
import csv

# set working directory (change it here to the main folder where you have your data and output folders)
directory = "C:\\Users\\maibe\\Dropbox\\Website\\code"

arcpy.env.overwriteOutput = True

# Data folder
data_folder = "\\data"

# Data downloaded from: https://www.census.gov/cgi-bin/geo/shapefiles/index.php?year=2018&layergroup=School+Districts
# Florida unified school district 2018
district_file = directory +  data_folder + "\\FL_2018_unsd\\FL_2018_unsd.shp"
# Projected file (new)
district_file_p = directory +  data_folder + "\\FL_2018_unsd\\FL_2018_unsd_p.shp"

# Name in arcgis
district_file_arcgis = "FL_dist"

# Use a projection so we can estimate areas, etc.
sr = arcpy.SpatialReference('USA Contiguous Albers Equal Area Conic')
arcpy.Project_management(district_file, district_file_p, sr)

#Make feature layer (to add FIDs if they are not there already)
arcpy.MakeFeatureLayer_management(district_file_p, district_file_arcgis)

# Data downloaded from: https://www2.census.gov/geo/tiger/TIGER_DP/2015ACS/
#Florida census tract data 2015:
ct_file = directory + data_folder + "\\ACS_2015_5YR_BG_12_FLORIDA.gdb\\ACS_2015_5YR_BG_12_FLORIDA"
# Projected file (new)
ct_file_p = directory + data_folder + "\\ACS_2015_5YR_BG_12_FLORIDA.gdb\\ACS_2015_5YR_BG_12_FLORIDA"
ct_file_arcgis = "FL_ct"

arcpy.Project_management(ct_file, ct_file_p, sr)
   
arcpy.MakeFeatureLayer_management(ct_file_p, ct_file_arcgis)

#Calculate area of each census tract:
arcpy.AddField_management(ct_file_p, "area", "DOUBLE")
arcpy.CalculateField_management(ct_file_p, "area","!shape.area!", "PYTHON")

#Use union to merge both the census tract data and the district data:
dist_ct_file = directory +  data_folder + "\\FL_districts_ct.shp"
arcpy.Union_analysis([district_file_arcgis, ct_file_arcgis], dist_ct_file)

#Create a new area variable for the version of the map were district and census tracts are merged:
arcpy.AddField_management(dist_ct_file, "area_cl", "DOUBLE")
arcpy.CalculateField_management(dist_ct_file, "area_cl","!shape.area!", "PYTHON")

dist_ct_file_arcgis = "FL_dist_ct"
arcpy.MakeFeatureLayer_management(dist_ct_file, dist_ct_file_arcgis)

#Add some census tract data to the maps (e.g. income in this case):
income_table = directory + data_folder + "\\ACS_2015_5YR_BG_12_FLORIDA.gdb\\X19_INCOME.dbf"
arcpy.AddJoin_management(dist_ct_file_arcgis, "GEOID_Data", income_table, "GEOID","KEEP_ALL")

#Export files:
out = dist_ct_file_arcgis
out2 = out + ".txt"
out_file_path = directory + "\\output"
arcpy.TableToTable_conversion(out, out_file_path, out2)

# drop all layers currenty loaded
mxd = arcpy.mapping.MapDocument("CURRENT")
for df in arcpy.mapping.ListDataFrames(mxd):
    for lyr in arcpy.mapping.ListLayers(mxd, "",df):
        arcpy.mapping.RemoveLayer(df,lyr)
