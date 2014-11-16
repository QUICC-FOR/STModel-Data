# Prepare plots informations data
# Date: November 15th, 2014

# This script get information on the plots from the QUICC-FOR Database 
# and create a map of the plots distribution across North America.
## ---------------------------------------------


## Get plots informations from quicc-for database
## ---------------------------------------------

# Database connection
source('./con_quicc_db.r')

# Load librairies

# Query 
query_plotInfoData  <- "
SELECT 
	plot_id, 
	ST_X(coord_postgis) AS lon, 
	ST_Y(coord_postgis) AS lat, 
	srid as srid_projection
FROM rdb_quicc.localisation
RIGHT OUTER JOIN rdb_quicc.stm_plot_ids USING (plot_id)
ORDER BY plot_id;"

## Send the query to the database
res_plotInfoData <- dbGetQuery(con,query_plotInfoData)
## Time: Less than 1 minute

# Writing  dataset
## ---------------------------------------------

write.table(res_plotInfoData, file="out_files/plotInfoData.csv", sep=',', row.names=FALSE)

# Prepare map
## ---------------------------------------------

theme_set(theme_grey(base_size = 18))

long_range <- range(res_plotInfoData$lon)
lat_range  <- range(res_plotInfoData$lat)

qmap(maptype = 'terrain',extent ="normal",
     location = c(range(res_plotInfoData$lon)[1],range(res_plotInfoData$lat)[1],range(res_plotInfoData$lon)[2],range(res_plotInfoData$lat)[2])) +
 geom_point(aes(x = lon, y = lat),data = res_plotInfoData,colour="firebrick1",size=1.2,alpha=0.5)+
  scale_x_continuous(expand=c(0,0)) + scale_y_continuous(expand=c(0,0))+ 
  xlab("Longitude") + ylab("Latitude")
