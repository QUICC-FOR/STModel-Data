#!/usr/bin/python

from __future__ import print_function
import QCtransition as trans

outputFileTr = 'out_files/transitionsFourState.csv'
outputFileSt = 'out_files/statesFourState.csv'
plotFile = 'out_files/plotInfoData.csv'
climFile = 'out_files/climData.csv'
treeFile = 'out_files/treeData.csv'

plots = trans.read_plots(plotFile)
nPlt = len(plots.keys())
print("Read " + str(nPlt) + " plots.")

trans.read_trees(treeFile, plots)
print("Finished reading tree data")

trans.read_climate(climFile, plots)
print("Finished reading climate data")

print("Checking for missing climate...")
# check that every sample has climate
totalSamples = 0
missingClimate = 0
for id in plots:
    plot = plots[id]
    for year in plot.samples:
        samp = plot.samples[year]
        totalSamples += 1
        if not samp.hasClimate:
            print("Missing climate for plot " + str(id) + " in year " + str(year))
            missingClimate += 1
print("Of " + str(totalSamples) + " samples, there are " + str(missingClimate) + " missing climate records")
    
# now print information
trans.print_plot_summary(plots)
trans.print_trans_table(plots)

# output all transition & sample info
print("Writing transitions to disk...")
n = 1
dataSources = ("transitions", "samples")
method = "string"
for data, outFile in zip(dataSources, (outputFileTr, outputFileSt)):
    with open(outFile, 'w') as of:
        print(plots.values()[0].get_data(data, method, header=True), file=of)
        for id in plots:
            pl = plots[id]
            out = pl.get_data(data, method)
            for l in out:
                print(l, file=of)
            n += len(out)
    print("Wrote " + str(n) + " lines to " + outFile)
# 
# # output all state info
# print("Writing states to disk")
# n = 1
# with open(outputFileSt, 'w') as of:
#     print(plots[plots.keys()[0]].output_states(header=True)[0], file=of)
#     for id in plots:
#         pl = plots[id]
#         out = pl.output_states()
#         for l in out:
#             print(l, file=of)
#         n += len(out)
# print("Wrote " + str(n) + " lines")
