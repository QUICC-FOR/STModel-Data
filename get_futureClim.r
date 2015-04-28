#### Future climat
#### By Steve Vissault
#### December first, 2014

#install.packages("RPostgreSQL")
require("RPostgreSQL")

# Database connection
source('./con_quicc_db.r')
#source('./con_quicc_db_local.r')

#Load librairies
require('reshape2')

GCM_df <- read.csv("./list_GCMs.csv")
GCM_df <- subset(GCM_df, scenario == 'rcp60')


SELECT ST_X(geom) as lon, ST_Y(geom) as lat, x , y, var, yr, val FROM (
SELECT var,yr,(ST_PixelAsCentroids(ST_Clip(raster,1,env_plots,true),1,true)).*
FROM clim_rs.fut_clim_biovars,
(SELECT ST_Polygon(ST_GeomFromText('LINESTRING(-79.95454 43.04572,-79.95454 50.95411,-60.04625 50.95411,-60.04625 43.04572,-79.95454 43.04572)'), 4326) as env_plots FROM rdb_quicc.stm_plots_id) as envelope
WHERE (var='bio1' OR var='bio12') AND yr=2000 AND clim_center='NASA_GISS' AND mod='GISS_E2_R' AND run='r1i1p1_historical'  AND scenario='rcp85' AND ST_Intersects(raster,env_plots)) as pixels;