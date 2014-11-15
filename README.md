STModel-Data
============

## Getting started

	git clone git@github.com:TheoreticalEcosystemEcology/STModel-Data.git
	cd STModel-Data

## Librairies

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
