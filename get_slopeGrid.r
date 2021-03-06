# Prepare slope grid to aggregate with future climate grids 
# Date: June 19th, 2015

# Database connection
#source('./con_quicc_db.r')
source('./con_quicc_db_local.r')

#Load librairies
require('reshape2')

# Query
query_slope_grid  <- "SELECT ST_X(geom) as lon, ST_Y(geom) as lat, x , y, var, val 
                                                FROM (SELECT var, (ST_PixelAsCentroids(rast, 1, false)).* FROM rdb_quicc.rs_slp) as slp_grid;"

## Send the query to the database
res_slope_grid <- dbGetQuery(con, query_slope_grid)
## Time: Approx. 5 minutes

#Manage NA
res_slope_grid[which(res_slope_grid$val==-9999),"val"] <- NA

# Writing grid dataset
## ---------------------------------------------

write.table(res_slope_grid, file="out_files/slope_grid.csv", sep=',', row.names=FALSE)
