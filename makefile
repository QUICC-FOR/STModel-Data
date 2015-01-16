# Makefile to retrieve & reshape data from the QUICC-FOR database
# November 21, 2014

PY_EXE = /usr/bin/python
R_CMD = Rscript
# use the below if you are old-fashioned or if Rscript doesn't work for some reason
# R_CMD = R CMD BATCH


# some convenience targets:
# all: treeData climData plotInfoData pastClimate_grid plotMap transitions states
all: speciesCode treeData climData plotInfoData plotMap transitions states
speciesCode: out_files/speciesCode.csv
treeData: out_files/treeData.csv
climData: out_files/climData.csv
plotInfoData: out_files/plotInfoData.csv
pastClimate_grid: out_files/pastClimate_grid.csv
plotMap: out_files/plots_map.png
transitions: out_files/transitionsFourState.csv
states: out_files/statesFourState.csv

# remove all data files and R junk
clean: cleanR
	rm -f out_files/*.csv

# removes junk created by R CMD BATCH
cleanR:
	rm -f *.Rout .RData

out_files/speciesCode.csv: get_speciesCode.r con_quicc_db.r
	$(R_CMD) get_speciesCode.r
	@echo "Query success and speciesCode.csv transferred into out_files folder"

out_files/treeData.csv: get_treeData.r con_quicc_db.r
	$(R_CMD) get_treeData.r
	@echo "Query success and treeData.csv transferred into out_files folder"

out_files/climData.csv: get_climData.r con_quicc_db.r
	$(R_CMD) get_climData.r
	@echo "Query success and climData.csv transferred into out_files folder"

out_files/plotInfoData.csv: get_plotInfoData.r con_quicc_db.r
	$(R_CMD) get_plotInfoData.r
	@echo "Query success and plotInfo.csv transferred into out_files folder"

out_files/pastClimate_grid.csv: get_pastClimate_grid.r con_quicc_db.r
	$(R_CMD) get_pastClimate_grid.r
	@echo "Query success and pastClimate_grid.csv transferred into out_files folder"

out_files/transitionsFourState.csv: reshape/QCtransition.py \
reshape/build_four_state_dataset.py out_files/treeData.csv out_files/climData.csv \
out_files/plotInfoData.csv
	$(PY_EXE) reshape/build_four_state_dataset.py

out_files/statesFourState.csv: out_files/transitionsFourState.csv

out_files/plots_map.png: out_files/plotInfoData.csv

con_quicc_db.r: credentials.r
