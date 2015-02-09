# Prepare past climate grid; input for the STM model
# Date: November 13th, 2014

# This script prepare grid of the past climate for the study area.
## ---------------------------------------------
# First step: The North america past climate grid is clipped with a convexHull of the location plots.
# Second step: The average of the climatic variables are compute on the clipped raster and the period of time expected

# Only two climatic variables 'annual_mean_temp' and 'tot_annual_pp'

## Get grid from quicc-for database
## ---------------------------------------------

# Database connection
source('./con_quicc_db.r')
#source('./con_quicc_db_local.r')

#Load librairies
require('reshape2')
