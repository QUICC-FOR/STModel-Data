# Prepare SDM climate grid
# Date: February 9th, 2015
# Edited: October, 5th 2016

# This script prepare a climatology grid period (1970-2000) for the study area.
## ---------------------------------------------
# First step: The Eastern North america climate grid is clipped.
# Second step: The average of each climatic variables are computed on 1970-2000 period.


## Variable selected for the SDM (see 0-SDM_explo_vars in STModel-Calibration model)
## ---------------------------------------------

## Get grid from quicc-for database
## ---------------------------------------------

# Database connection
source('./con_quicc_db.r')
#source('./con_quicc_db_local.r')

#Load librairies
require('reshape2')

# Query
query_climato  <- "SELECT ST_X(geom) as lon, ST_Y(geom) as lat, val, biovar FROM (
    SELECT biovar, (ST_PixelAsCentroids(rasters)).* FROM (
    SELECT biovar, ST_Union(ST_Clip(ST_Resample(rast,ref_rast),env_stm.env_plots),'MEAN') as rasters
    FROM
    (SELECT rast, biovar,year_clim FROM clim_rs.past_clim_allbiovars
     WHERE year_clim >= 1970 AND year_clim <= 2000) AS rast_noram,
    (SELECT ST_Transform(ST_GeomFromText('POLYGON((-95.0 24.0,-95.0 62.5,-60.04625 62.5,-60.04625 24.0,-95.0 24.0))',4326),4269) as env_plots) AS env_stm,
    (SELECT ST_Union(rast) as ref_rast FROM clim_rs.past_clim_allbiovars WHERE biovar = 'annual_mean_temp' AND year_clim=2010) as ref
    WHERE ST_Intersects(rast_noram.rast,env_stm.env_plots)
    GROUP BY biovar) AS union_query
) AS points_query;"

## Send the query to the database
res_climato <- dbGetQuery(con, query_climato)
## Time: Approx. 5-15 minutes

# Reshaping and writing grid dataset
## ---------------------------------------------

climato = res_climato

## Reshape
climato$biovar <- as.factor(climato$biovar)
climato <- dcast(climato,lon+lat ~ biovar, value.var="val")

#Conversion unit
climato$mean_diurnal_range <- climato$mean_diurnal_range/10
climato$mean_temp_wettest_quarter <- climato$mean_temp_wettest_quarter/10
climato$mean_temp_driest_quarter <- climato$mean_temp_driest_quarter/10
climato$max_temp_warmest_period <- climato$max_temp_warmest_period/10
climato$mean_temp_coldest_quarter <- climato$mean_temp_coldest_quarter/10
climato$mean_temp_warmest_quarter <- climato$mean_temp_warmest_quarter/10
climato$min_temp_coldest_period <- climato$min_temp_coldest_period/10
climato$temp_annual_range <- climato$temp_annual_range/10
climato$temp_seasonality <- climato$temp_seasonality/100

## Write
saveRDS(climato, file="out_files/climato_1970-2000_biovars.rds")
