#!/usr/bin/Rscript
# usage: Rscript reshapeTransitions.r
# for help and options: Rscript reshapeTransitions.r --help

require(reshape2)
require(argparse)
# handle command line arguments
parser = ArgumentParser()
parser$add_argument("-i", "--infile", default="reshape/tmpStateData_r1.rdata", help="input file name")
parser$add_argument("-o", "--outfile", default="out_data/transitions.rdata", help="output file name")
trArgList = parser$parse_args()
load(trArgList$infile)


# remove plots with only one sample
freqs = table(stateData$plot_id)
select = which(freqs > 1)
dfselect = which(stateData$plot_id %in% as.numeric(names(freqs[select])))
transSamples = stateData[dfselect,]

# reshape
transSamples.wide = list()
dropNames = c('plot_id', 'year_measured', 'B', 'T', 'U', 'sumBA', 'state')
selectOut = which(colnames(transSamples) %in% dropNames)
transitionClimateVariables = colnames(transSamples)[-selectOut]
for(v in c('state', transitionClimateVariables))
	transSamples.wide[[v]] = dcast(transSamples, plot_id ~ year_measured, value.var = v)

transitionData = data.frame(plot = numeric(), year1 = numeric(), year2 = numeric(),
		state1 = character(), state2 = character())
for(env in transitionClimateVariables)
	transitionData[, env] = numeric()

# compute transitions
for(i in 2:ncol(transSamples.wide$state)) {
	subSamp = lapply(transSamples.wide, function(x) x[!is.na(x[,i]),])
	state1 = subSamp$state[,i]
	n = length(state1)
	year1 = rep(as.numeric(colnames(subSamp$state)[i]), n)
	state2 = year2 = rep(NA, n)
	j = i + 1
	remain = n
	while(nrow(subSamp$state) > 0 & j <= ncol(subSamp$state)) {
		select = which(!is.na(subSamp$state[,j]))
		n = length(select)
		if(n > 0) {
			trns = data.frame(
				plot = subSamp$state$plot_id[select],
				year1 = rep(as.numeric(colnames(subSamp$state)[i]), n),
				year2 = rep(as.numeric(colnames(subSamp$state)[j]), n),
				state1 = subSamp$state[select, i],
				state2 = subSamp$state[select, j]
			)
			for(env in transitionClimateVariables)
				trns[,env] = rowMeans(cbind(subSamp[[env]][select, i], 
						subSamp[[env]][select, j]))
			trns = trns[!is.na(trns$year2) & !is.na(trns$state2),]
			subSamp = lapply(subSamp, function(x) x[-select,])
			transitionData = rbind(transitionData, trns)
		}
		j = j + 1
	}
}

# drop U state
# done after the computation because we need to ignore transitions from/to valid to/from U
stateData = stateData[stateData$state != 'U',]
transitionData = transitionData[transitionData$state1 != 'U' & 
		transitionData$state2 != 'U',]
transitionData$state1 = factor(transitionData$state1)
transitionData$state2 = factor(transitionData$state2)


print(table(transitionData$state1, transitionData$state2))

save(stateData, transitionData, file=trArgList$outfile)
cat(paste("State and transition data written to", trArgList$outfile, "\n"))