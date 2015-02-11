# Prepare SDM climate grid
# Date: February 9th, 2015

# This script prepare grid of the SDM climate for the study area.
## ---------------------------------------------
# First step: The North america SDM climate grid is clipped with a convexHull of the location plots.
# Second step: The average of the climatic variables are compute on the clipped raster and the range of time expected


## Variable selected for the SDM (see 0-SDM_explo_vars in STModel-Calibration model)
## ---------------------------------------------

# 6 climatic variables selected to build the SDM
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
#source('./con_quicc_db_local.r')

#Load librairies
require('reshape2')

# Query
query_SDMClimate_grid  <- "SELECT ST_X(geom) as lon, ST_Y(geom) as lat, val, biovar FROM (
    SELECT biovar, (ST_PixelAsCentroids(ST_Transform(rasters,4326))).* FROM (
    SELECT biovar, ST_Union(ST_Clip(ST_Resample(rast,ref_rast),env_stm.env_plots),'MEAN') as rasters
    FROM
    (SELECT rast, biovar,year_clim FROM clim_rs.clim_allbiovars
     WHERE (year_clim >= 1970 AND year_clim <= 2000)
    AND biovar IN (

    -- SDM selected variables
    -------------------------------

    'annual_mean_temp',
    'tot_annual_pp',
    'mean_diurnal_range',
    'pp_warmest_quarter',
    'pp_wettest_period',
    'mean_temp_wettest_quarter',
    'mean_temp_driest_quarter'

    )) AS rast_noram,
    (SELECT ST_Transform(ST_ConvexHull(ST_Collect(stm_plots_id.coord_postgis)),4269) as env_plots FROM rdb_quicc.stm_plots_id) AS env_stm,
    (SELECT rast as ref_rast FROM clim_rs.clim_allbiovars WHERE biovar = 'annual_mean_temp' LIMIT 1) as ref
    WHERE ST_Intersects(rast_noram.rast,env_stm.env_plots)
    GROUP BY biovar) AS union_query
) AS points_query;"

## Send the query to the database
res_SDMClimate_grid <- dbGetQuery(con, query_SDMClimate_grid)
## Time: Approx. 5-15 minutes

# Reshaping and writing grid dataset
## ---------------------------------------------

SDMClimate_grid = res_SDMClimate_grid

## Reshape
SDMClimate_grid$biovar <- as.factor(SDMClimate_grid$biovar)
SDMClimate_grid <- dcast(SDMClimate_grid,lon+lat ~ biovar, value.var="val")

#Delete NA
SDMClimate_grid <- SDMClimate_grid[!is.na(SDMClimate_grid[,c(3:ncol(SDMClimate_grid))]),]

#Conversion unit
SDMClimate_grid$mean_diurnal_range <- SDMClimate_grid$mean_diurnal_range/10
SDMClimate_grid$mean_temp_wettest_quarter <- SDMClimate_grid$mean_temp_wettest_quarter/10
SDMClimate_grid$mean_temp_driest_quarter <- SDMClimate_grid$mean_temp_driest_quarter/10

## Write
write.table(SDMClimate_grid, file="out_files/SDMClimate_grid.csv", sep=',', row.names=FALSE)





