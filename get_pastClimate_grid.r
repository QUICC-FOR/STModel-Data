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
query_pastClimate_grid  <- "SELECT x-1 as x, y-1 as y, val, biovar FROM (
	SELECT biovar, (ST_PixelAsCentroids(rasters, 1, false)).* FROM (
	SELECT biovar, ST_Union(ST_Clip(rast,env_stm.env_plots),'MEAN') as rasters
	FROM
	(SELECT rast, biovar,year_clim FROM clim_rs.clim_allbiovars
     WHERE (year_clim >= 1970 AND year_clim <= 2000)
	AND biovar IN ('annual_mean_temp','tot_annual_pp')) AS rast_noram,
    (SELECT ST_Transform(ST_ConvexHull(ST_Collect(stm_plots_id.coord_postgis)),4269) as env_plots FROM rdb_quicc.stm_plots_id) AS env_stm
	WHERE ST_Intersects(rast_noram.rast,env_stm.env_plots)
	GROUP BY biovar) AS union_query
) AS points_query;"

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

pastClimate_grid$annual_pp <- conv_func(pastClimate_grid$tot_annual_pp,1000)

## Add year columns and rename all dataset columns
names(pastClimate_grid)[3:ncol(pastClimate_grid)] <- paste("env",seq(1,ncol(pastClimate_grid)-2,1),sep="")
pastClimate_grid$year <- rep(0, nrow(pastClimate_grid))
pastClimate_grid <- pastClimate_grid[, c(1,2,ncol(pastClimate_grid),4:ncol(pastClimate_grid)-1)]

## Write
write.table(pastClimate_grid, file="out_files/pastClimate_grid.csv", sep=',', row.names=FALSE)

