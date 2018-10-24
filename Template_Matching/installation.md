####################################################
########### Required Installations #################
####################################################

The following R packages installations and solver (Gurobi) are required to run the replication code for the paper "Building Representative Matched Samples with Multi-valued Treatments in Large Observational Studies: Analysis of the Impact of an Earthquake on Educational Attainment" (Bennett, Vielma, and Zubizarreta, 2018).

###################################################
# 1. Solver installation: Gurobi
# 2. R packages installation
###################################################

# 1. Gurobi installation

For an exact solution, we strongly recommend running designmatch either with CPLEX or Gurobi.  Between these two solvers, the R interface of Gurobi is considerably easier to install.  Here we provide general instructions for manually installing Gurobi and its R interface in Mac and Windows machines.

1. Create a free academic license
	Follow the instructions in: http://www.gurobi.com/documentation/7.0/quickstart_windows/creating_a_new_academic_li.html

2. Install the software
	2.1. In http://www.gurobi.com/index, go to Downloads > Gurobi Software
	2.2. Choose your operating system and press download

3. Retrieve and set up your Gurobi license
	2.1. Follow the instructions in: http://www.gurobi.com/documentation/7.0/quickstart_windows/retrieving_and_setting_up_.html
	2.2. Then follow the instructions in: http://www.gurobi.com/documentation/7.0/quickstart_windows/retrieving_a_free_academic.html

4. Test your license
	Follow the instructions in: http://www.gurobi.com/documentation/7.0/quickstart_windows/testing_your_license.html

5. Install the R interface of Gurobi	
	Follow the instructions in: http://www.gurobi.com/documentation/7.0/quickstart_windows/r_installing_the_r_package.html
	* In Windows, in R run the command install.packages("PATH\\gurobi_7.X-Y.zip", repos=NULL) where path leads to the file gurobi_7.X-Y.zip (for example PATH=C:\\gurobi702\\win64\\R; note that the path may be different in your computer), and "7.X-Y" refers to the version you are installing.
	* In MAC, in R run the command install.packages('PATH/gurobi_7.X-Y.tgz', repos=NULL) where path leads to the file gurobi_7.X-Y.tgz (for example PATH=/Library/gurobi702/mac64/R; note that the path may be different in your computer), and "7.X-Y" refers to the version you are installing.
		
6. Test the installation 
	Load the library and run the examples therein
	* A possible error that you may get is the following: "Error: package ‘slam’ required by ‘gurobi’ could not be found". If that case, install.packages('slam') and try again.
	You should be all set!


# 2. R packages installation

In order to reproduce the existing simulation code for Bennett, Vielma, & Zubizarreta (2018), the following code must be run on R (unless packages are already installed).

install.packages("designmatch") #To run matching procedure
install.packages("optmatch") #To run performance test using optmatch
install.packages("rcbalance") #To run performance test using rcbalance
install.packages("xtable") #To output tables in .tex format
