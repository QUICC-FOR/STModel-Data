# Prepare past climate grid input
# Date: November 13th, 2014

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
source('./con_quicc_db_local.r')

#Load librairies
require('reshape2')

# Query
query_pastClimate_grid  <- "SELECT ST_X(geom) as longitude, ST_Y(geom) as latitude, val, biovar FROM (
        SELECT biovar, (ST_PixelAsCentroids(clipped_raster)).* FROM (
		SELECT biovar, ST_Union(ST_Clip(union_raster,env_stm.env_plots),'MEAN') as clipped_raster
		FROM clim_rs.clim_00_70_stm,
		(SELECT ST_Transform(ST_ConvexHull(ST_Collect(stm_plot_ids.coord_postgis)),4269) as env_plots FROM rdb_quicc.stm_plot_ids) as env_stm
		GROUP BY biovar
	) as pixels
) as coords;"

## Send the query to the database
res_pastClimate_grid <- dbGetQuery(con, query_pastClimate_grid)
## Time: Approx. 5-15 minutes

# Reshaping and writing grid dataset
## ---------------------------------------------

pastClimate_grid = res_pastClimate_grid

## Reshape
pastClimate_grid$biovar <- as.factor(pastClimate_grid$biovar)
pastClimate_grid <- dcast(pastClimate_grid,x+y ~ biovar, value.var="val")

## Convert unit:
# - Get decimal for annual_mean_temp (divided by 10)
# - Convert mm to m for annual_pp (divided by 1000)

conv_func <-function(x,conv){

	res = as.numeric(length(x))

	for(i in 1:length(x)){
		if(x[i] != -9999){res[i]=x[i]/conv} else {res[i]=x[i]}
	}

	return(res)
}

pastClimate_grid$annual_pp <- conv_func(pastClimate_grid$annual_pp,1000)
pastClimate_grid$annual_mean_temp <- conv_func(pastClimate_grid$annual_mean_temp,10)

## Add year columns and rename all dataset columns
names(pastClimate_grid)[3:4] <- c("env1","env2")
pastClimate_grid$year <- rep(0, nrow(pastClimate_grid))
pastClimate_grid <- pastClimate_grid[, c("x","y","year","env1","env2")]

## Write
write.table(pastClimate_grid, file="out_files/pastClimate_grid.csv", sep=',', row.names=FALSE)

