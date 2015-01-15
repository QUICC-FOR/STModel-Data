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
RIGHT JOIN (SELECT DISTINCT plot_id FROM rdb_quicc.stm_plots_clim) as plt_clim_constraint USING (plot_id)
ORDER BY plot_id;"

## Send the query to the database
res_plotInfoData <- dbGetQuery(con,query_plotInfoData)
## Time: Less than 1 minute

# Writing  dataset
## ---------------------------------------------

write.table(res_plotInfoData, file="out_files/plotInfoData.csv", sep=',', row.names=FALSE)

# Prepare and create map
## ---------------------------------------------

lon_med <- median(res_plotInfoData$lon)
lat_med  <- median(res_plotInfoData$lat)

theme_set(theme_grey(base_size=10))
quicc.map = get_map(location = c(lon=lon_med,lat=lat_med), zoom = 4)

plots_map =ggmap(quicc.map, maprange=FALSE,extent = "normal") %+% res_plotInfoData + aes(x = lon, y = lat) +
stat_density2d(aes(fill = ..level.., alpha = ..level..), bins = 25, geom = 'polygon',contour=TRUE) +
geom_density2d(color="orange4",size=.2) +
scale_fill_gradient(low = "orange", high = "orange4") +
scale_x_continuous(expand=c(0,0)) + scale_y_continuous(expand=c(0,0))+
xlab("Longitude") + ylab("Latitude") +
theme(legend.position = "none", text = element_text(size = 10))

ggsave(plots_map,file="./out_files/plots_map.png",width=4,height=4)