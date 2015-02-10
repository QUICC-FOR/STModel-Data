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

# Extract shapefiles from the database
countries <- dbReadSpatial(con, schemaname="temp_quicc", tablename="stm_countries_shapes", geomcol="geom")
lakes <- dbReadSpatial(con, schemaname="temp_quicc", tablename="stm_lakes_shapes", geomcol="geom")

# Write shapefiles
writeOGR(lakes, "./out_files/shapefiles/", "lakes_stm_area", driver="ESRI Shapefile")
writeOGR(countries, "./out_files/shapefiles/", "countries_stm_area", driver="ESRI Shapefile")

#Convert to ggplot2 format
df.lakes <- fortify(lakes)
df.countries <- fortify(countries)

#Save ggplot2 format as an R object
save(df.lakes,df.countries,file="./out_files/shp_stm_area.rObj")