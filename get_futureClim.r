#### Future climat
#### By Steve Vissault
#### December first, 2014

#install.packages("RPostgreSQL")
require("RPostgreSQL")
require("maptools")
require("raster")
require("sp")
require("rgdal")

climate_grid <- read.csv("~/Documents/Maitrise/Analyse/dom_ouranos/dom_climate_grid.csv")
org_grid <- climate_grid

# Raster annual_mean_temp_now
annual_mean_temp_now <- climate_grid[,1:3]
coordinates(annual_mean_temp_now) <- ~lon + lat
annual_mean_temp_now@proj4string = CRS("+proj=longlat +datum=WGS84")
gridded(annual_mean_temp_now) = TRUE
annual_mean_temp_now <- raster(annual_mean_temp_now)

# Raster annual_pp_now
annual_pp_now <- climate_grid[,c(1:2,4)]
coordinates(annual_pp_now) <- ~lon + lat
annual_pp_now@proj4string = CRS("+proj=longlat +datum=WGS84")
gridded(annual_pp_now) = TRUE
annual_pp_now <- raster(annual_pp_now)

# Create empty raster
rs_new <- raster()
extent(rs_new) <- extent(annual_pp_now)
res(rs_new) <-  res(annual_mean_temp_now)

## Transform grid to rasters

annual_mean_temp_2080 <- readShapePoly("~/Documents/Data/Ouranos/by_climvars/USDA_anusplin_ccBIO20kmGrid_Tavg_plusDELTA2080_MRCC_ADJ.shp")
annual_mean_temp_2080@proj4string = CRS( "+proj=longlat +ellps=GRS80 +datum=NAD83 +no_defs;")
annual_mean_temp_2050 <- readShapePoly("~/Documents/Data/Ouranos/by_climvars/USDA_anusplin_ccBIO20kmGrid_Tavg_plusDELTA2050_MRCC_ADJ.shp")
annual_mean_temp_2050@proj4string = CRS( "+proj=longlat +ellps=GRS80 +datum=NAD83 +no_defs;")
annual_pp_2050 <- readShapePoly("~/Documents/Data/Ouranos/by_climvars/USDA_anusplin_ccBIO20kmGrid_Prec_plusDELTA2050_MRCC_ADJ.shp")
annual_pp_2050@proj4string = CRS( "+proj=longlat +ellps=GRS80 +datum=NAD83 +no_defs;")
annual_pp_2080 <-  readShapePoly("~/Documents/Data/Ouranos/by_climvars/USDA_anusplin_ccBIO20kmGrid_Prec_plusDELTA2080_MRCC_ADJ.shp")
annual_pp_2080@proj4string = CRS( "+proj=longlat +ellps=GRS80 +datum=NAD83 +no_defs;")

annual_mean_temp_2050 <- spTransform(annual_mean_temp_2050, CRS("+proj=longlat +datum=WGS84"))
annual_mean_temp_2080 <- spTransform(annual_mean_temp_2080, CRS("+proj=longlat +datum=WGS84"))
annual_pp_2050 <- spTransform(annual_pp_2050, CRS("+proj=longlat +datum=WGS84"))
annual_pp_2080 <- spTransform(annual_pp_2080, CRS("+proj=longlat +datum=WGS84"))

ext_qc_crop <- extent(-79.7600089999999,-57.1054839999999, 44.990798, 62.5852190000001)
annual_mean_temp_2080_crop <- crop(annual_mean_temp_2080,ext_qc_crop)
annual_mean_temp_2050_crop <- crop(annual_mean_temp_2050,ext_qc_crop)
annual_pp_2080_crop <- crop(annual_pp_2080,ext_qc_crop)
annual_pp_2050_crop <- crop(annual_pp_2050,ext_qc_crop)

annual_mean_temp_2080_crop@data[annual_mean_temp_2080_crop@data==-9999] <- NA
annual_mean_temp_2050_crop@data[annual_mean_temp_2050_crop@data==-9999] <- NA
annual_pp_2050_crop@data[annual_pp_2050_crop@data==-9999] <- NA
annual_pp_2080_crop@data[annual_pp_2080_crop@data==-9999] <- NA

annual_mean_temp_2080_crop@data$annual_mean_temp <- rowMeans(annual_mean_temp_2080_crop@data[,7:18],na.rm=TRUE)
annual_mean_temp_2050_crop@data$annual_mean_temp <- rowMeans(annual_mean_temp_2050_crop@data[,7:18],na.rm=TRUE)
annual_pp_2050_crop@data$annual_pp <-rowSums(annual_pp_2050_crop@data[,7:18],na.rm=TRUE)
annual_pp_2080_crop@data$annual_pp <- rowSums(annual_pp_2080_crop@data[,7:18],na.rm=TRUE)

rs_annual_mean_temp_50 <- rasterize(annual_mean_temp_2050_crop,rs_new,'annual_mean_temp')
rs_annual_mean_temp_80 <- rasterize(annual_mean_temp_2080_crop,rs_new,'annual_mean_temp')
rs_annual_pp_80 <- rasterize(annual_pp_2080_crop,rs_new,'annual_pp')
rs_annual_pp_50 <- rasterize(annual_pp_2050_crop,rs_new,'annual_pp')

stack_clim <- stack(
    annual_pp_now,
    annual_mean_temp_now,
    rs_annual_pp_50,
    rs_annual_pp_80,
    rs_annual_mean_temp_50,
    rs_annual_mean_temp_80)

names(stack_clim)[3:6] <- c("annual_pp_2050","annual_pp_2080","annual_mean_temp_2050","annual_mean_temp_2080")

final_df <- as.data.frame(stack_clim,xy=TRUE)
final_df <- final_df[complete.cases(final_df),]
names(final_df)[1:2] <- c("lon","lat")

write.csv(final_df, file="./PresFutClim.csv", row.names=FALSE)

### Visu

require(ggplot2)
require(reshape2)

gg_df <- melt(final_df,id=c("lon","lat"),na.rm=TRUE)
ggplot(gg_df,aes(x=lon,y=lat)) + geom_raster(aes(fill=value)) + facet_wrap(~variable)