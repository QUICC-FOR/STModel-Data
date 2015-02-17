#!/usr/bin/Rscript
# usage: Rscript reshapeStates.r
# for help and options: Rscript reshapeStates.r --help

require(reshape2)
require(argparse)
# handle command line arguments
parser = ArgumentParser()
parser$add_argument("-c", "--climate", default="out_files/climData.csv", help="climate data file location")
parser$add_argument("-t", "--tree", default="out_files/treeData.csv", help="tree data file location")
parser$add_argument("-p", "--plot", default="out_files/plotInfoData.csv", help="plot data file location")
argList = parser$parse_args()

# read the data
treeDat = read.csv(argList$tree)
plotDat = read.csv(argList$plot)
climDat = read.csv(argList$climate)
treeDat = merge(treeDat, plotDat, all.x=TRUE)

sampleDat = dcast(treeDat, plot_id + year_measured + lat + lon ~ id_spe, fill = 0, 
		value.var = "basal_area", fun.aggregate = function(x) as.integer(sum(x) > 0))

stateData = merge(sampleDat, climDat, all = 'T', by=c("plot_id", "year_measured"))
if(sum(is.na(stateData$lat)) > 0) {
	warning(paste(sum(is.na(stateData$lat)), " plot-year climate records ", 
			"with no corresponding tree data were found and will be dropped", sep=""))
	stateData = stateData[!is.na(stateData$lat), ]
}
if(sum(is.na(stateData$mean_diurnal_range)) > 0) {
	warning(paste(sum(is.na(stateData$mean_diurnal_range)), " plot-year ", 
			"samples with no climate data were found and will be dropped", sep=""))
	stateData = stateData[!is.na(stateData$mean_diurnal_range), ]
}

cat(paste("Number of plots:", length(unique(stateData$plot_id)), "\n"))
cat(paste("Number of plot-year samples:", (nrow(stateData)), "\n"))
cat(paste("Samples/plot:", (nrow(stateData)/length(unique(stateData$plot_id))), "\n"))
cat(paste("Range of years sampled: ", min(stateData$year_measured), "–", 
		max(stateData$year_measured), "\n", sep=""))


plotVars = c('plot_id', 'year_measured', 'lat', 'lon')
climVars = colnames(climDat)
climVars = climVars[which(!(climVars %in% plotVars))]
outFileName = "reshape/tmpStateData_twoState.rdata"
save(stateData, argList, plotVars, climVars, file=outFileName)
