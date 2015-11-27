# this tests the climate in the reshaped transition object against the coarse data
# to ensure that the climate in the transition object correctly reflects the 
# mean of the two points from the coarse data

require(argparse)
# handle command line arguments
parser = ArgumentParser()
parser$add_argument("-i", "--infile", default="transitions_r1.rdata", help="input file name")
parser$add_argument("-s", "--samples", default=1000, help="number of samples")
parser$add_argument("-c", "--climate", default="old/climData.csv", help="climate data file location")
argList = parser$parse_args()

load(argList$infile)
climDat = read.csv(argList$climate)
sampRows = sample(1:nrow(transitionData), argList$samples)
err = 0
for(r in sampRows) {
	p = transitionData$plot[r]
	y1 = transitionData$year1[r]
	y2 = transitionData$year2[r]
	temp = transitionData$annual_mean_temp[r]
	precip = transitionData$annual_pp[r]
	testVals = colMeans(climDat[climDat$plot_id == p & (climDat$year_measured == y1 | 
			climDat$year_measured == y2), c("annual_mean_temp", "annual_pp")])
	if(temp != testVals[1]) {
		cat(paste("plot ", p, ": ", y1, "–", y2,"  -- temp difference of ", temp - 
				testVals[1], "\n", sep=""))
		err = err + 1
	}
	if(precip != testVals[2]) {
		cat(paste("plot ", p, ": ", y1, "–", y2,"  -- precip difference of ", precip - 
				testVals[2], "\n", sep=""))
		err = err + 1
	}
}


cat(paste(err, " total errors of ", argList$samples, " samples\n", sep=""))