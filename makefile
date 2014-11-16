# Makefile to retrieve data from the QUICC-FOR database
# November 15th, 2014

get_pastClimate_grid:
	R CMD BATCH get_pastClimate_grid.r
	rm *.Rout .RData
	@echo "Query success and pastClimate_grid.csv transferred into out_files folder"

get_treeData:
	R CMD BATCH get_treeData.r
	rm *.Rout
	@echo "Query success and TreeData.csv transferred into out_files folder"

get_climData:
	R CMD BATCH get_climData.r
	rm *.Rout .RData
	@echo "Query success and climData.csv transferred into out_files folder"

get_plotInfoData:
	R CMD BATCH get_plotInfoData.r
	rm *.Rout .RData
	@echo "Query success and plotInfo.csv transferred into out_files folder"

all: get_treeData get_plotInfoData get_pastClimate_grid

clean: 
	find ./out_files -name "*Data.csv" -exec rm -f {} \;
	find ./out_files -name "*_grid.csv" -exec rm -f {} \;