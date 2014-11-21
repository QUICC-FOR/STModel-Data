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

trans.read_climate(climFile, plots)
print("Finished reading climate data")

trans.read_trees(treeFile, plots)
print("Finished reading tree data")
    
# now print information
trans.print_plot_summary(plots)
trans.print_trans_table(plots)

# output all transition & sample info
n = 1
dataSources = ("transitions", "samples")
method = "string"
for data, outFile in zip(dataSources, (outputFileTr, outputFileSt)):
    print("Writing " + data + " to disk...")
    with open(outFile, 'w') as of:
        # find the first plot with a valid header
        hdr = ""
        i = 0
        while not hdr:
            try:
                hdr = plots.values()[i].get_data(data, method, header=True)
            except IndexError:
                i = i+1
        print(hdr, file=of)
        # print data for each plot
        for id in plots:
            pl = plots[id]
            out = pl.get_data(data, method)
            for l in out:
                print(l, file=of)
            n += len(out)
    print("Wrote " + str(n) + " lines to " + outFile)
