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

query_fut_climSDM <- paste("SELECT ST_X(geom) as lon, ST_Y(geom) as lat, var, val, clim_center, mod, run, scenario FROM (
    SELECT var,clim_center, mod, run, scenario, (ST_PixelAsCentroids(ST_Union(ST_Clip(raster,1,env_plots,true),'MEAN'),1,false)).*
    FROM clim_rs.fut_clim_biovars,
    (SELECT ST_Polygon(ST_GeomFromText('LINESTRING(-79.95454 43.04572,-79.95454 50.95411,-60.04625 50.95411,-60.04625 43.04572,-79.95454 43.04572)'), 4326) as env_plots) as envelope
    WHERE (var='bio1' OR var='bio2' OR var='bio12') AND (yr>=2080 AND yr<=2095) AND scenario='rcp85' AND ST_Intersects(raster,env_plots)
    GROUP BY var,clim_center, mod, run, scenario
    ) as pixels;",sep="")

    
fut_climSDM <- dbGetQuery(con, query_fut_climSDM)
    
write.table(fut_climSDM, file=paste("out_files/fut_climSDM_2080-2095.csv",sep=""), sep=',', row.names=FALSE)




