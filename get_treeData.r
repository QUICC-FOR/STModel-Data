# Prepare past climate grid input 
# Date: Novenver 13th, 2014

# This script prepare grid of the past climate for the province of Quebec.
## ---------------------------------------------
# First step: The North america past climate grid is clipped with the spatial polygon of Quebec.
# Second step: The average of the climatic variables are compute on the clipped raster and the period of time expected


## Query parameters
## ---------------------------------------------

# 6 climatic variables available for USA/CAN (1930-2010):
# - 'annual_mean_temp' (WARNING: Need to be divided by 10 to get decimal)
# - 'min_temp_coldest_mont'
# - 'mean_temp_warmest_quarter'
# - 'mean_temp_coldest_quarter'
# - 'annual_pp'
# - 'pp_seasonality'


## Get grid from quicc-for database
## ---------------------------------------------

# Database connection
source('./con_quicc_db.r')

#Load librairies
require('reshape2')

# Query 
query_pastClimate_grid  <- ""

## Send the query to the database
treeData <- dbGetQuery(con, query_pastClimate_grid)
## Time: Approx. 5-15 minutes

# Reshaping and writing grid dataset
## ---------------------------------------------


## Write
write.table(treeData, file="out_files/treeData.csv", sep=',', row.names=FALSE)

