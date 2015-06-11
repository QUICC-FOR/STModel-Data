# Extract shapefiles covering the area;
# Shapefiles are clipped and stored in db, see src_sql/stm_shapes.sql
# Date: February 10th, 2015

# This script only extract and write shapefiles from the db
## ---------------------------------------------

# Database connection

source('./con_quicc_db.r')
#source('./con_quicc_db_local.r')
source('./Rpostgis.r') #Extract spatial layer form the DB

# Library
library(ggplot2)
library(raster)
library(sp)
library(rgeos)

# Extract shapefiles from the database
countries <- dbReadSpatial(con, schemaname="temp_quicc", tablename="stm_countries_shapes", geomcol="geom")
lakes <- dbReadSpatial(con, schemaname="temp_quicc", tablename="stm_lakes_shapes", geomcol="geom")
great_lakes <- dbReadSpatial(con, schemaname="temp_quicc", tablename="stm_great_lakes_shapes", geomcol="geom")

system('mkdir -p ./out_files/shapefiles/')

# Write shapefiles
writeOGR(lakes, "./out_files/shapefiles/", "lakes_stm_area", driver="ESRI Shapefile")
writeOGR(countries, "./out_files/shapefiles/", "countries_stm_area", driver="ESRI Shapefile")
writeOGR(great_lakes, "./out_files/shapefiles/", "great_lakes_stm_area", driver="ESRI Shapefile")


#Convert to ggplot2 format
ext_geo <- extent(c(-79.87535,-60.12543,43.12493,50.8749 ))
#ext_geo <- extent(c(-96.98904, -57.30813,  35.25441,  52.90010))


#Crop, simplify and fortify
lakes <- crop(lakes,ext_geo)
great_lakes <- crop(great_lakes,ext_geo)
countries <- gSimplify(crop(countries,ext_geo),0.005)
df.lakes <- fortify(lakes)
df.countries <- fortify(countries)
df.great_lakes <- fortify(great_lakes)

#Save ggplot2 format as an R object
save(lakes,great_lakes,countries,df.lakes,df.countries,df.great_lakes,file="./out_files/shp_stm_area.rdata")
