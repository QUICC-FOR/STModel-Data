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
query_pastClimate_grid  <- "SELECT x-1 as x, y-1 as y, val, biovar FROM (
		SELECT biovar, (ST_PixelAsCentroids(rasters, 1, false)).* FROM (
		SELECT biovar, ST_Union(ST_Clip(rast_world.rast,env_qc.env),'MEAN') as rasters
		FROM 
		(SELECT rast, biovar FROM past_clim_rs.clim_biovars
			WHERE (year_measured > 1970 OR year_measured < 2000) 
			AND (biovar = 'annual_pp' OR biovar = 'annual_mean_temp')) AS rast_world,
		(SELECT ST_Envelope(geom) as env FROM map_world.can_adm1 WHERE name_1 = 'Québec') AS env_qc
		WHERE ST_Intersects(rast_world.rast,env_qc.env)
		GROUP BY biovar) AS union_query
		) AS points_query;"

## Send the query to the database

pastClimate_grid <- dbGetQuery(con, query_pastClimate_grid)
## Time: Approx. 5 minutes

# Reshaping and writing grid dataset
## ---------------------------------------------

## Reshape
pastClimate_grid$biovar <- as.factor(pastClimate_grid$biovar)
pastClimate_grid <- dcast(pastClimate_grid,x+y ~ biovar, value.var="val")

## Convert unit:
# - Get decimal for annual_mean_temp (divided by 10)
# - Convert mm to m for annual_pp (divided by 1000)

pastClimate_grid$annual_mean_temp <- pastClimate_grid[which(pastClimate_grid$annual_mean_temp!=-9999),pastClimate_grid$annual_mean_temp/10]
pastClimate_grid$pp <- pastClimate_grid[which(pastClimate_grid$annual_pp!=-9999),pastClimate_grid$pp/1000]

## Add year columns and rename all dataset columns 
names(pastClimate_grid)[3:4] <- c("env1","env2")
pastClimate_grid$year <- rep(0, nrow(pastClimate_grid))
pastClimate_grid <- pastClimate_grid[, c("x","y","year","env1","env2")]

## Write
write.table(pastClimate_grid, file="out_files/pastClimate_grid.csv", sep=',', row.names=FALSE)