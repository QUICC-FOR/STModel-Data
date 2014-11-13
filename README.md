STModel-Data
============

### Get tree data

	R CMD BATCH get_treeData.r &

**Output**: Trees csv file with one row per SPECIES in a given plot in a given year include only living trees

**Columns**: plot_id, year, species_code, basal area

**Filters:**

- Basal areal is the sum of basal area for all individuals of that species in that year

- All columns should not be null

- Only permanent plots

### Get climatic data

	R CMD BATCH get_ClimData.r &

**Output**: Climate csv file with each line is the climate for one year in one plot (e.g., plot 100 in 1965)

**Columns**: plot_id, year, all climate data 

**Filters:**

- plot_id and year appear in the tree_file
- plot_id, year, MeanTemp and AnnualPrecip not NULL

### Get plot info data

**Output**: Plot Info csv files with each line is a plot and a year

**Columns**: plot_id, drainage, lat/long

**Filters:**

- plot_id and year appear in the tree_file
- plot_id, lat and long not NULL

