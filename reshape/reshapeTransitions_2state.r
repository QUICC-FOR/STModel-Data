#!/usr/bin/Rscript
# usage: Rscript reshapeTransitions.r
# for help and options: Rscript reshapeTransitions.r --help

require(reshape2)
require(argparse)
# handle command line arguments
parser = ArgumentParser()
parser$add_argument("-i", "--infile", default="reshape/tmpStateData_twoState.rdata", help="input file name")
parser$add_argument("-o", "--outfile", default="default", help="output file name")
parser$add_argument("-s", "--species", default="28731-ACE-SAC", help="desired species code")
trArgList = parser$parse_args()
load(trArgList$infile)

# subselect the desired columns
stateData = stateData[,c(plotVars, climVars, trArgList$species)]

# remove plots with only one sample
freqs = table(stateData$plot_id)
select = which(freqs > 1)
dfselect = which(stateData$plot_id %in% as.numeric(names(freqs[select])))
transSamples = stateData[dfselect,]

# reshape
transSamples.wide = list()
for(v in c(trArgList$species, climVars))
	transSamples.wide[[v]] = dcast(transSamples, plot_id ~ year_measured, value.var = v)

transitionData = data.frame(plot = numeric(), year1 = numeric(), year2 = numeric(),
		state1 = character(), state2 = character())
for(env in climVars)
	transitionData[, env] = numeric()

# compute transitions
for(i in 2:ncol(transSamples.wide[[trArgList$species]])) {
	subSamp = lapply(transSamples.wide, function(x) x[!is.na(x[,i]),])
	state1 = subSamp[[trArgList$species]][,i]
	n = length(state1)
	year1 = rep(as.numeric(colnames(subSamp[[trArgList$species]])[i]), n)
	state2 = year2 = rep(NA, n)
	j = i + 1
	remain = n
	while(nrow(subSamp[[trArgList$species]]) > 0 & j <= ncol(subSamp[[trArgList$species]])) {
		select = which(!is.na(subSamp[[trArgList$species]][,j]))
		n = length(select)
		if(n > 0) {
			trns = data.frame(
				plot = subSamp[[trArgList$species]]$plot_id[select],
				year1 = rep(as.numeric(colnames(subSamp[[trArgList$species]])[i]), n),
				year2 = rep(as.numeric(colnames(subSamp[[trArgList$species]])[j]), n),
				state1 = subSamp[[trArgList$species]][select, i],
				state2 = subSamp[[trArgList$species]][select, j]
			)
			for(env in climVars)
				trns[,env] = rowMeans(cbind(subSamp[[env]][select, i], 
						subSamp[[env]][select, j]))
			trns = trns[!is.na(trns$year2) & !is.na(trns$state2),]
			subSamp = lapply(subSamp, function(x) x[-select,])
			transitionData = rbind(transitionData, trns)
		}
		j = j + 1
	}
}

cat(paste("Presence-absence table for", trArgList$species))
print(table(transitionData$state1, transitionData$state2))

outfile = trArgList$outfile
if(outfile == "default") {
	outfile = paste("out_files/transition_twostate_", trArgList$species, ".rdata", sep="")
}
save(stateData, transitionData, file=outfile)
cat(paste("State and transition data written to", outfile, "\n"))