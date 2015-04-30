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
GCM_df <- subset(GCM_df, scenario == 'rcp85')

out_folder <- "./out_files/fut_SDM/"

for (x in 1:dim(GCM_df)[1]){
    query_fut_climSDM <- paste("SELECT ST_X(geom) as lon, ST_Y(geom) as lat, var, val, clim_center, mod, run, scenario FROM (
    SELECT var,yr,clim_center, mod, run, scenario, (ST_PixelAsCentroids(ST_Union(ST_Clip(raster,1,env_plots,true),'MEAN'),1,false)).*
    FROM clim_rs.fut_clim_biovars,
    (SELECT ST_Polygon(ST_GeomFromText('LINESTRING(-79.95454 43.04572,-79.95454 50.95411,-60.04625 50.95411,-60.04625 43.04572,-79.95454 43.04572)'), 4326) as env_plots) as envelope
    WHERE (var='bio1' OR var='bio2' OR var='bio12') AND (yr>=2080 AND yr<=2095) AND clim_center='",GCM_df[x,1],"' AND mod='",GCM_df[x,2],"' AND run='",GCM_df[x,3],"' AND scenario='",GCM_df[x,4],"' AND ST_Intersects(raster,env_plots)
    GROUP BY var,yr,clim_center, mod, run, scenario
    ) as pixels;",sep="")

    cat("Querying id: ",rownames(GCM_df)[x],"\n")

    fut_climSDM <- dbGetQuery(con, query_fut_climSDM)
    
    write.table(fut_climSDM, file=paste(out_folder,"fut_climSDM_id_",rownames(GCM_df)[x],"2080-2095.csv",sep=""), sep=',', row.names=FALSE)

}



