#### Future climat for 2States
#### By Steve Vissault
#### December first, 2015

#install.packages("RPostgreSQL")
require("RPostgreSQL")

# Database connection
source('./con_quicc_db.r')
#source('./con_quicc_db_local.r')

#Load librairies
library('reshape2')

GCM_df <- read.csv("./list_GCMs.csv")

out_folder <- "./out_files/futureClimGrid/"

# create one folder by RCP

for (x in 1:dim(GCM_df)[1]){
    system(paste("mkdir -p ",out_folder,GCM_df[x,4],sep=""))
    query_fut_climData <- paste("SELECT ST_X(geom) as lon, ST_Y(geom) as lat, x , y, var, val, clim_center, mod, run, scenario FROM (
    SELECT var,clim_center, mod, run, scenario, (ST_PixelAsCentroids(ST_Union(ST_Clip(ST_Transform(raster,4269),1,env_plots,true),'MEAN'),1,false)).*
    FROM clim_rs.fut_clim_biovars,
    (SELECT ST_Transform(ST_GeomFromText('POLYGON((-97.0093390804598 25.0416666666667,-97.0093390804598 52.000000000000,-52.0416666666667 52.000000000000,-52.0416666666667 25.0416666666667,-97.0093390804598 25.0416666666667))',4326)::geometry,4269) as env_plots) as envelope
    WHERE (var='bio1' OR var='bio12') AND (yr>=2080 AND yr<=2095) AND clim_center='",GCM_df[x,1],"' AND mod='",GCM_df[x,2],"' AND run='",GCM_df[x,3],"' AND scenario='",GCM_df[x,4],"' AND ST_Intersects(ST_Transform(raster,4269),env_plots)
    GROUP BY var,clim_center, mod, run, scenario
    ) as pixels;",sep="")

    cat("Querying id: ",rownames(GCM_df)[x],"\n")

    fut_climData <- dbGetQuery(con, query_fut_climData)

    write.table(fut_climData, file=paste(out_folder,GCM_df[x,4],"/GCM_id_",rownames(GCM_df)[x],"_win_2080-2095.csv",sep=""), sep=';', row.names=FALSE)
}
