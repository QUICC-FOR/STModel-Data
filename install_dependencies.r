#!/usr/bin/Rscript
pckList = c("reshape2", "argparse", "RPostgreSQL", "maptools", "raster", "sp", "rgdal", 
		"ggmap")

install.packages(pckList, repos="http://cran.utstat.utoronto.ca/", dependencies=TRUE, 
		type="source")