"""Module for reading and parsing the output of the QUICC-FOR database, and computing transitions

    Implements the following classes:
        Plot: describes plot-specific attributes and implements sample lookups
        Sample: describes a single sampling interval from within a plot
            implements functions for determining the state of the plot at that time
        
    Additionally, the module implements the following functions for reading data from files
        read_plots
        read_climate_into_plots
        read_trees_into_plots
"""

import csv
from collections import OrderedDict

# define some globals that determine which species belong to each group
_B_SPECIES = ['183302-PIC-MAR','183295-PIC-GLA','18034-PIC-RUB','183412-LAR-LAR',
  '183319-PIN-BAN','18032-ABI-BAL']

_T_SPECIES = ['19481-BET-ALL','19408-QUE-RUB','28728-ACE-RUB','28731-ACE-SAC',
  '32931-FRA-AME','32945-FRA-NIG','19462-FAG-GRA','19511-OST-VIR','21536-TIL-AME',
  '24764-PRU-SER']


def read_plots(filename, indices = {'id':0,'longitude':1,'latitude':2}, delim=',', \
        twoStateSpecies = None):
    """Read plots from a file on disk and adds samples for each year measured
    
    Indices is a dictionary; keys are the names of the data fields, and values are the
    columns (starting with 0) in which to find the data. If these are None, then the field
    will be ignored. Expected values are as follows:
        id: plot id number
        year: year plot was measured
        latitude & longitude: coordinates of the plot
        size: size of plot, in ha
        drainage: drainage category of the plot
    """
    types = {'id':str,'longitude':float, 'latitude':float}
    vals = {}
    with open(filename, 'rU') as f:
        csvDat = csv.reader(f, delimiter = delim, dialect='excel')
        colnames = next(csvDat, None)
        plots = dict()
        for curLine in csvDat:
            curPlotID = str(curLine[indices['id']])
            for key in indices:
                try:
                    vals[key] = types[key](curLine[indices[key]])
                except (ValueError, TypeError):
                    vals[key] = None
            curPlotID = vals['id']
            curLat = vals['latitude']
            curLong = vals['longitude']
            if curPlotID in plots:
                raise RuntimeError("Duplicate plot in plot info record, number " + curPlotID)
            plots[curPlotID] = Plot(curPlotID, curLat, curLong, twoStateSpecies)
    return plots


def read_climate(filename, plots, indices={'id':0, 'year':1}, delim=','):
    types = {'id':str,'year':int}
    vals = {}
    with open(filename, 'rU') as f:
        csvDat = csv.reader(f, delimiter = delim, dialect='excel')
        colnames = next(csvDat, None)
        # get all of the other variables and add them to indices and types
        for index in range(len(colnames)):
            if index not in indices.values():
                name = colnames[index]
                indices[name] = index
                types[name] = float
        for curLine in csvDat:
            curPlotID = types['id'](curLine[indices['id']])
            for key in indices:
                try:
                    vals[key] = types[key](curLine[indices[key]])
                except (ValueError, TypeError):
                    vals[key] = None
            year = vals['year']
            del vals['year']
            del vals['id']
            try:
                curPlot = plots[curPlotID]
            except KeyError:
                print("Warning: tried to add climate for plot number " + str(curPlotID) \
                     + " when no such plot exists")
            else:
                try:
                    curSample = curPlot.samples[year]
                except KeyError:
                    print("Warning: tried to add climate for plot number " + \
                        str(curPlotID) + " for year " + str(year) + \
                        "; year does not exist for that plot")
                else:
                    curSample.add_climate(vals)
        

def read_trees(filename, plots, indices={'id':0, 'year':1, 'species':2, \
        'ba':3}, delim=','):
    """Read information about trees from a file on disk and store in a dictionary of plots
    
    plots: a dictionary of plots, with plot ID as key
    indices: a dictionary, with keys the names of data fields and values equal to the
      column in the datafile containing that field (starting at 0)
      expected fields are:
        id: plot ID
        year: the year of measurement
        species: the species code of the tree
        ba: the basal area of the tree species, in m^2 / ha
    delim: the character used as delimiter in the file
    """
    types = {'id':str,'year':int,'species':str,'ba':float}
    vals = {}
    with open(filename, 'rU') as f:
        csvDat = csv.reader(f, delimiter = delim, dialect='excel')
        colnames = next(csvDat, None)
        for curLine in csvDat:
            for key in indices:
                try:
                    vals[key] = types[key](curLine[indices[key]])
                except (ValueError, TypeError):
                    vals[key] = None
            plotID = vals['id']
            year = vals['year']
            species = vals['species']
            ba = vals['ba']
            try:
                curPlot = plots[plotID]
            except KeyError:
                print("Warning: tried to add tree for plot number " + str(plotID) + \
                    " sampled in " + str(year) + " when no such plot exists")
            else:
                curPlot.add_tree(year, species, ba)


class _QCTransitionBase(object):
    """ base class for most of the functionality of this module; not to be used
    directly. provides a basic init method as well as some utilities"""
    def __init__(self, id, idName = 'id'):
        self._stringSep = ','
        self._data = OrderedDict()
        self._data[idName] = id
    
    def get_data(self, method='list', header=False):
        """Outputs the metadata on the plot object; can also produce an appropriate header
        
        method: if 'string' will produce a comma-separated string of the data/header
            otherwise, produces a list
        header: if True, outputs a header using the format specified by 'method,'
            otherwise returns the data"""
        if header:
            dat = self._data.keys()
        else:
            dat = self._data.values()
        if method == 'string':
            val = self._listToString(dat)
        elif method == 'dict':
            val = self._data
        else:
            val = dat
        return val
            
    def _listToString(self, theList):
        """Processes a list of items into a string. If null (i.e, None) data are encountered,
        they are interpreted into 'NA'"""
        for i in range(len(theList)):
            if theList[i] is None:
                theList[i] = 'NA'
            else:
                theList[i] = str(theList[i])
        return self._stringSep.join(theList)


class Plot(_QCTransitionBase):
    """Create a plot with no samples (can be added using add_sample()
    
    Climate information must be added completely (using climate.add_climate_record() 
    BEFORE adding samples 
    if twoStateSpeces is None, then the four-state model will be used"""
    def __init__(self, id, latitude = None, longitude = None, twoStateSpecies = None):
        super(Plot, self).__init__(id, 'plot')
#         self.climate = ClimateHistory()
        self.samples = {} # keyed by year
        self._climateTimeLag = 20   # how many years back to compute the mean climate?
        self._transitions = []
        self._twoStateSpecies = twoStateSpecies
        self._transitionsAreDirty = False
        # note: the order of adding items matters; during output, they will be produced
        # in the same order
        self._data['latitude'] = latitude
        self._data['longitude'] = longitude
        
    def get_data(self, data="samples", method = "object", header=False):
        """Plot method for data output
        
        if data == 'samples', this method operates on samples
        otherwise, operates on transitions
        
        method:
            string and list modes work as in _QCTransitionBase
            object: return a list of transitions or samples
        """
        if data == 'samples':
            targetData = self.samples.values()
        else:
            if self._transitionsAreDirty:
                self._compute_transitions()
            targetData = self._transitions
        if method == "object":
            result = targetData
        else:
            result = list()
            base = super(Plot, self).get_data(method, header)
            if header:
                result.append(base + self._stringSep + targetData[0].get_data(method, header))
            else:
                for item in targetData:
                    line = base + self._stringSep + item.get_data(method, header)
                    result.append(line)
        return result

    def add_tree(self, year, species, ba):
        self._transitionsAreDirty = True
        if year is None or ba is None or species is None:
            raise ValueError("Tried to add tree with missing data")
        if year not in self.samples:
            self.samples[year] = Sample(year, self._twoStateSpecies)
        samp = self.samples[year]
        samp.add_tree(species, ba)
        
    def _compute_transitions(self):
        """Step through all sample years and determine transitions between valid states"""
        years = sorted(self.samples.keys())
        if len(years) > 1:
            for year1, year2 in zip(years[:-1], years[1:]):
                samp1 = self.samples[year1]
                samp2 = self.samples[year2]
                if samp1.state() != 'U' and samp2.state() != 'U':
                    self._transitions.append(Transition(samp1, samp2))
        self._transitionsAreDirty = False        
                    

class Transition(_QCTransitionBase):
    """Transition object; initialized using two samples
    
    keys is a list of keys to use from the samples
    if keys is None or an empty list, ALL keys from the samples will be used
    """
    def __init__(self, sample1, sample2, keys=['year', 'state', 'annual_pp', \
            'annual_mean_temp']):
        s1dat = sample1.get_data('dict')
        s2dat = sample2.get_data('dict')
        super(Transition, self).__init__(abs(s1dat['year'] - s2dat['year']), 'interval')
                
        if keys is None or len(keys) == 0:
            keys = s1dat.keys()
        for k in keys:
            try:
                self._data[k + '1'] = s1dat[k]
            except KeyError:
                self._data[k + '1'] = None
            try:
                self._data[k + '2'] = s2dat[k]
            except KeyError:
                self._data[k + '2'] = None
                
    def states(self):
        return (self._data['state1'], self._data['state2'])


class Sample(_QCTransitionBase):
    """Create a sample identified by the year sampled.
    
        Trees are added to the sample via the add_tree function
        They should not be added manually to _species; this will fubar everything
        
        if twoStateSpecies is not None, the two state model is used, and the get_state 
        function will be re-mapped to _is_present()
        """
    def __init__(self, year, twoStateSpecies = None):
        super(Sample, self).__init__(year, 'year')
        self._data['state'] = 'NoStateHere'
        self._species = {}  # keyed by species code, values are basal area
        self._totalBA = 0
        self._bBA = 0
        self._tBA = 0
        self._stateIsDirty = False
        self.hasClimate = False
        if twoStateSpecies is not None:
            self._data['species'] = twoStateSpecies
            self._get_state = self._is_present

    def add_tree(self, species, ba):
        self._stateIsDirty = True
        if species not in self._species:
            self._species[species] = 0
        self._species[species] += ba
        self._totalBA += ba
        if species in _B_SPECIES:
            self._bBA += ba
        elif species in _T_SPECIES:
            self._tBA += ba
    
    def state(self):
        if self._stateIsDirty:
            self._get_state()
        return self._data['state']
    
    def get_data(self, method = "string", header=False):
        if self._stateIsDirty:
            self._get_state()
        if method == "dict":
            return self._data
        else:
            return super(Sample, self).get_data(method, header)

    def add_climate(self, climate):
        if climate is not None:
            self._data.update(climate)
            self.hasClimate = True

    def _get_state(self):
        """State function; computes the state of the sample and sets it in the _state
            attribute of the _data dictionary under the 4-state model
        
        The definition of this function is synonymous with the definition of the states    
        """
        self._stateIsDirty = False
        if self._totalBA < 10:
            self._data['state'] = 'R'
        elif self._tBA > 0 and self._bBA == 0:
            self._data['state'] = 'T'
        elif self._bBA > 0 and self._tBA == 0:
            self._data['state'] = 'B'
        elif self._bBA > 0 and self._tBA > 0:
            self._data['state'] = 'M'
        else:
            self._data['state'] = 'U'        # state undetermined

    def _is_present(self):
        """State function; sets state to 1 if the test species (in self._twoStateSpecies) 
        is present with basal area > 0
            
        This implements the two-state model for any given species
        """
        self._stateIsDirty = False
        sp = self._twoStateSpecies
        self._data['state'] = str(int(sp in self._species and self._species[sp] > 0))


def print_plot_summary(plots):
    nClim = 0
    nSmpl = 0
    minYr = 2014
    maxYr = 0
    baMean = 0
    states = {'T':0, 'B':0, 'M':0, 'R':0, 'U':0}
    for id in plots:
        curPlot = plots[id]
        for yr in curPlot.samples:
            if yr < minYr:
                minYr = yr
            if yr > maxYr:
                maxYr = yr
            cs = curPlot.samples[yr]
            baMean += cs._totalBA
            nSmpl += 1
            states[cs.state()] += 1
    nPlt = len(plots.keys())
    print("Summary of the input dataset:")
    print("Total plots in dataset: " + str(nPlt))

    print("Read " + str(nSmpl) + " samples for a mean of " + str(float(nSmpl)/nPlt) + " per plot.")
    print("Average basal area: " + str(float(baMean)/nSmpl))
    print("Earliest sample: " + str(minYr))
    print("Latest sample: " + str(maxYr))
    print("Number of samples in each state:")
    for st in states:
        print(st + ": " + str(states[st]))


# def print_trans_table_twostate(plots):
#     print("Transition frequency table:")
#     # tabulate transitions
#     malformed = []
#     trans = {'0': {'0':0, '1':0}, '1': {'0':0, '1':0}}
#     for id in plots:
#         cPlot = plots[id]
#         for cTrns in cPlot._transitions:
#             if cTrns._data['state1'] not in trans or cTrns._data['state2'] not in trans[cTrns._data['state1']]:
#                 malformed.append((cTrns._data['state1'], cTrns._data['state2']))
#             else:
#                 trans[cTrns._data['state1']][cTrns._data['state2']] += 1
#     print("     TO:")
#     print("F     0      1")
#     print("R  0 " + '{0:6}'.format(trans['0']['0']) + ' ' + '{0:6}'.format(trans['1']['0']))
#     print("O  1 " + '{0:6}'.format(trans['0']['1']) + ' ' + '{0:6}'.format(trans['1']['1']))
#     if len(malformed) > 0:
#         print("Found " + str(len(malformed)) + " malformed transitions")
# 
def print_trans_table(plots):
    print("Transition frequency table:")
    # tabulate transitions
    malformed = []
    trans = {'T': {'T':0, 'B':0, 'M':0, 'R':0}, 'B': {'T':0, 'B':0, 'M':0, 'R':0}, 'M': \
            {'T':0, 'B':0, 'M':0, 'R':0}, 'R': {'T':0, 'B':0, 'M':0, 'R':0}}
    for id in plots:
        cPlot = plots[id]
        for cTrns in cPlot.get_data("transitions"):
            st = cTrns.states()
            if st[0] not in trans or st[1] not in trans[st[0]]:
                malformed.append(cTrns['states'])
            else:
                trans[st[0]][st[1]] += 1
    print("     TO:")
    print("F     T     B     M     R")
    print("R  T " + '{0:5}'.format(trans['T']['T']) + ' ' + '{0:5}'.format(trans['T']['B']) + ' ' + '{0:5}'.format(trans['T']['M']) + ' ' + '{0:5}'.format(trans['T']['R']))
    print("O  B " + '{0:5}'.format(trans['B']['T']) + ' ' + '{0:5}'.format(trans['B']['B']) + ' ' + '{0:5}'.format(trans['B']['M']) + ' ' + '{0:5}'.format(trans['B']['R']))
    print("M  M " + '{0:5}'.format(trans['M']['T']) + ' ' + '{0:5}'.format(trans['M']['B']) + ' ' + '{0:5}'.format(trans['M']['M']) + ' ' + '{0:5}'.format(trans['M']['R']))
    print("   R " + '{0:5}'.format(trans['R']['T']) + ' ' + '{0:5}'.format(trans['R']['B']) + ' ' + '{0:5}'.format(trans['R']['M']) + ' ' + '{0:5}'.format(trans['R']['R']))
    if len(malformed) > 0:
        print("Found " + str(len(malformed)) + " malformed transitions")

