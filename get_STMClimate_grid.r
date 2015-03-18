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

# Query
query_STMClimate_grid  <- "SELECT x-1 as x, y-1 as y, val, biovar FROM (
	SELECT biovar, (ST_PixelAsCentroids(rasters, 1, false)).* FROM (
	SELECT biovar, ST_Union(ST_Clip(rast,env_stm.env_plots),'MEAN') as rasters
	FROM
	(SELECT rast, biovar,year_clim FROM clim_rs.past_clim_allbiovars
     WHERE (year_clim >= 1970 AND year_clim <= 2000)
	AND biovar IN ('annual_mean_temp','tot_annual_pp')) AS rast_noram,
    (SELECT ST_Transform(ST_ConvexHull(ST_Collect(stm_plots_id.coord_postgis)),4269) as env_plots FROM rdb_quicc.stm_plots_id) AS env_stm
	WHERE ST_Intersects(rast_noram.rast,env_stm.env_plots)
	GROUP BY biovar) AS union_query
) AS points_query;"

## Send the query to the database
res_STMClimate_grid <- dbGetQuery(con, query_STMClimate_grid)
## Time: Approx. 5-15 minutes

# Reshaping and writing grid dataset
## ---------------------------------------------

STMClimate_grid = res_STMClimate_grid

## Reshape
STMClimate_grid$biovar <- as.factor(STMClimate_grid$biovar)
STMClimate_grid[STMClimate_grid$val==-9999,"val"] <- NA
STMClimate_grid <- dcast(STMClimate_grid,x+y ~ biovar, value.var="val")
STMClimate_grid[is.na(STMClimate_grid$tot_annual_pp),"annual_mean_temp"] <- NA
STMClimate_grid[is.na(STMClimate_grid$annual_mean_temp),"tot_annual_pp"] <- NA

## Convert unit:
# - Get decimal for annual_mean_temp (divided by 10)
# - Convert mm to m for annual_pp (divided by 1000)
STMClimate_grid$tot_annual_pp <- STMClimate_grid$tot_annual_pp/1000
STMClimate_grid$annual_mean_temp <- STMClimate_grid$annual_mean_temp/10

STMClimate_grid[is.na(STMClimate_grid$annual_mean_temp),c(3,4)] <- -9999

## Add year columns and rename all dataset columns
names(STMClimate_grid)[3:ncol(STMClimate_grid)] <- paste("env",seq(1,ncol(STMClimate_grid)-2,1),sep="")
STMClimate_grid$year <- rep(0, nrow(STMClimate_grid))
STMClimate_grid <- STMClimate_grid[, c(1,2,ncol(STMClimate_grid),4:ncol(STMClimate_grid)-1)]

## Write
write.table(STMClimate_grid, file="out_files/STMClimate_grid.csv", sep=',', row.names=FALSE)

