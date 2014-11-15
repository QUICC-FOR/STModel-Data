STModel-Data
============

## Getting started

	git clone git@github.com:TheoreticalEcosystemEcology/STModel-Data.git
	cd STModel-Data

## Dependency

	install.packages("RPostgreSQL")

## Retrieve data from QUICC-FOR database

#### Get tree data

	R CMD BATCH get_treeData.r &

#### Get climatic data

	R CMD BATCH get_climData.r &

#### Get plot info data

	R CMD BATCH get_plotInfo.r &

#### Get past climate grid input

	R CMD BATCH get_pastClimate_grid.r &

## Metadata

#### pastClimate_grid csv file:

- **x** : x coordinate of the cell (longitude). i.e. x = 0 corresponds to min(longitude)
- **y** : y coordinate of the cell (longitude). i.e. y = 0 corresponds to min(latitude)
- **year**: year of the climate measurement. In the sql query, year column equal to 0 because the climate has been aggregated temporarily.
- **env1**: average of the mean temperature (°C) between 1970-2000.
- **env2**: average of the annual precipitation (meters) between 1970-2000.

#### treeData csv file:

- **plot_id** : Unique id of the plot
- **year_measured** : year of the measurement
- **id_spe**: Species code, details are in ./out_files/stm_code_species.csv file
- **basal area**: basal area of the species in **m²/ha**