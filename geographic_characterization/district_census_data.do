/**********************************************************************************************
* Title: Characterization of School Districts using Census Tract Data
* Created by: M. Bennett
* Created on: 08/12/19
* Purpose: This dofile creates weighted average characteristics for school districts in FL using
* 			census tract data.
* Last Modified on: 08/12/19
* Last Modified by: MB
* Edits:
	[08/12/19]: Created dofile
**********************************************************************************************/

clear all
set more off

if "`c(username)'"=="maibe"{
	global main_dir "C:\Users\maibe\Dropbox\Website\code\"
}

else{
	global main_dir /*Insert your path here*/
}


import delimited "${main_dir}\output\FL_dist_ct.txt", clear

* Drop unmatched districts and census tracts:
drop if fid_fl_201<0 | fid_acs_20<0

* Keep only variables we are going to use (for example purposes, we'll only keep household total income)
keep geoid statefp name countyfp tractce namelsad area area_cl x19_income_b19001e1

* Generate the area district by adding the intersection of areas between census tracts and each district
bysort geoid: egen area_dist = sum(area_cl)

* Weights for census tracts
gen w_ct = area_cl/area_dist

* Generate w*income
gen w_inc=w_ct*x19_income_b19001e1

* Generate weighted average for each district:
bysort geoid: egen inc_dist=sum(w_inc)

* Keep only one obs by district:
duplicates drop geoid, force

* Plot the distribution of household income by district in FL
twoway(kdensity inc_dist)

