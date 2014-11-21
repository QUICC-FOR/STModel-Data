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
library("ggmap")

# Query 
query_plotInfoData  <- "
SELECT 
	plot_id, 
	ST_X(coord_postgis) AS lon, 
	ST_Y(coord_postgis) AS lat, 
	srid as srid_projection
FROM rdb_quicc.localisation
RIGHT JOIN (SELECT DISTINCT plot_id FROM rdb_quicc.stm_plot_ids) as plt_constraint USING (plot_id)
ORDER BY plot_id;"

## Send the query to the database
res_plotInfoData <- dbGetQuery(con,query_plotInfoData)
## Time: Less than 1 minute

# Writing  dataset
## ---------------------------------------------

write.table(res_plotInfoData, file="out_files/plotInfoData.csv", sep=',', row.names=FALSE)

# Prepare and create map
## ---------------------------------------------

lon_range <- range(res_plotInfoData$lon)
lat_range  <- range(res_plotInfoData$lat)

plots_map = qmap(zoom = 4, maptype = 'terrain',extent ="normal",
     location = c(lon_range[1],lat_range[1],lon_range[2],lat_range[2])) +
geom_point(aes(x = lon, y = lat),data = res_plotInfoData,colour="springgreen4",size=0.4,alpha=0.3)+
scale_x_continuous(expand=c(0,0)) + scale_y_continuous(expand=c(0,0))+ 
xlab("Longitude") + ylab("Latitude") + theme(axis.title=element_text(size=6),axis.text = element_text(size=6))
ggsave(plots_map,file="./out_files/plots_map.png",width=4,height=4)