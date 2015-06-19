# Prepare soil grid to aggregate with future climate grids 
# Date: June 19th, 2015

# Database connection
source('./con_quicc_db.r')
#source('./con_quicc_db_local.r')

#Load librairies
require('reshape2')

# Query
query_soil_grid  <- "SELECT ST_X(geom) as lon, ST_Y(geom) as lat, x , y, var, val 
                                                FROM (SELECT var, (ST_PixelAsCentroids(rast, 1, false)).* FROM rdb_quicc.rs_soil) as soil_grid;"

## Send the query to the database
res_soil_grid <- dbGetQuery(con, query_soil_grid)
## Time: Approx. 5 minutes

# Writing grid dataset
## ---------------------------------------------

write.table(res_soil_grid, file="out_files/soil_grid.csv", sep=',', row.names=FALSE)
