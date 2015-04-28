# Extract shapefiles covering the area;
# Shapefiles are clipped and stored in db, see src_sql/stm_shapes.sql
# Date: February 10th, 2015

# This script only extract and write shapefiles from the db
## ---------------------------------------------

# Database connection

#source('./con_quicc_db.r')
source('./con_quicc_db_local.r')
source('./Rpostgis.r') #Extract spatial layer form the DB

# Library
require(ggplot2)
require(raster)
require(sp)

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
ext_geo <- extent(c(-79.95454,-60.04625,43.04572,50.95411))
#ext_geo <- extent(c(-96.98904, -57.30813,  35.25441,  52.90010))


#Crop and fortify
lakes <- crop(lakes,ext_geo)
great_lakes <- crop(great_lakes,ext_geo)
countries <- crop(countries,ext_geo)
df.lakes <- fortify(lakes)
df.countries <- fortify(countries)
df.great_lakes <- fortify(great_lakes)

#Save ggplot2 format as an R object
save(df.lakes,df.countries,df.great_lakes,file="./out_files/shp_stm_area.rdata")