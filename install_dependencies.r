#!/usr/bin/Rscript
pckList = c("reshape2", "argparse", "RPostgreSQL", "maptools", "raster", "sp", "rgdal",
		"ggmap","ggplot2","rgeos")

install.packages(pckList, repos="http://cran.utstat.utoronto.ca/", dependencies=TRUE,
		type="source")