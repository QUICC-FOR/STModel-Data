#!/usr/bin/Rscript
# usage: Rscript reshapeStates.r
# for help and options: Rscript reshapeStates.r --help

require(reshape2)
require(argparse)
# handle command line arguments
parser = ArgumentParser()
parser$add_argument("-r", "--rstate", default=1, type="double", help="cutoff for r state")
parser$add_argument("-c", "--climate", default="out_files/climData.csv", help="climate data file location")
parser$add_argument("-t", "--tree", default="out_files/treeData.csv", help="tree data file location")
parser$add_argument("-p", "--plot", default="out_files/plotInfoData.csv", help="plot data file location")
argList = parser$parse_args()

tSpecies = c('19408-QUE-RUB','28728-ACE-RUB','28731-ACE-SAC',
  '32931-FRA-AME','32945-FRA-NIG','19462-FAG-GRA','19511-OST-VIR','21536-TIL-AME',
  '24764-PRU-SER', "183397-TSU-CAN")
bSpecies = c('183302-PIC-MAR','183295-PIC-GLA','18034-PIC-RUB','183412-LAR-LAR',
  '183319-PIN-BAN','18032-ABI-BAL', "505490-THU-OCC")

# formerly T:
# '19481-BET-ALL'

# formerly B:
# "183397-TSU-CAN"

# read the data
treeDat = read.csv(argList$tree)
plotDat = read.csv(argList$plot)
climDat = read.csv(argList$climate)
treeDat = merge(treeDat, plotDat, all.x=TRUE)
treeDat$type = rep('U', nrow(treeDat))
treeDat$type[which(treeDat$id_spe %in% tSpecies)] = 'T'
treeDat$type[which(treeDat$id_spe %in% bSpecies)] = 'B'

# get rid of all plots that NEVER have at least one T or B species
# this prevents them from being classified as R when they never contain even one
# species of interest
trTab = table(treeDat$plot_id, treeDat$type)
filterNames = as.numeric(rownames(trTab[rowSums(trTab[,1:2]) == 0,]))
treeDat.filtered = treeDat[!(treeDat$plot_id %in% filterNames),]

# reshape the data into plot-year samples by state
sampleDat = dcast(treeDat.filtered, plot_id + year_measured + lat + lon ~ type, fill = 0, 
		value.var = "basal_area", fun.aggregate = sum)
sampleDat$sumBA = sampleDat$B + sampleDat$T + sampleDat$U
sampleDat$state = rep('U', nrow(sampleDat))
sampleDat$state[sampleDat$B > 0 & sampleDat$T == 0] = 'B'
sampleDat$state[sampleDat$B == 0 & sampleDat$T > 0] = 'T'
sampleDat$state[sampleDat$B > 0 & sampleDat$T > 0] = 'M'
sampleDat$state[sampleDat$sumBA < argList$rstate] = 'R'


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
cat(paste("Mean basal area per sample:", (mean(stateData$sumBA)), "\n"))
cat(paste("Range of years sampled: ", min(stateData$year_measured), "–", 
		max(stateData$year_measured), "\n", sep=""))
print(table(stateData$state))

outFileName = paste("reshape/tmpStateData", "_r", argList$rstate, ".rdata", sep="")
save(stateData, argList, file=outFileName)
