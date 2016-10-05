# Makefile to retrieve & reshape data from the QUICC-FOR database
# Jan 20, 2015

### TODO: Improve this terrible makefile

# set the threshold basal area value for the R state
R_STATE = 5

R_CMD = Rscript

all: treeData past_climData plotInfoData STMClimate_grid SDMClimate_grid plotMap SHP_area reshape
speciesCode: out_files/speciesCode.csv
treeData: out_files/treeData.csv
past_climData: out_files/climData.csv
plotInfoData: out_files/plotInfoData.csv
climato_1970-2000: out_files/climato_1970-2000_biovars.rds
SDMClimate_grid: out_files/SDMClimate_grid.csv
soil_grid: out_files/soil_grid.csv
slope_grid: out_files/slope_grid.csv
SHP_area: out_files/shp_stm_area.rdata
plotMap: out_files/plots_map.png
reshape: out_files/transitions_r$(R_STATE).rdata
twostate: out_files/transitions_twostate_18032-ABI-BAL.rdata out_files/transition_twostate_28731-ACE-SAC.rdata

# remove all data files and R junk
clean: cleanR
	rm -f out_files/*

# removes junk created by R CMD BATCH
cleanR:
	rm -f *.Rout .RData


out_files/soil_grid.csv:  get_soilGrid.r con_quicc_db.r
	$(R_CMD) get_soilGrid.r
	@echo "Query success and soil grid transferred into out_files folder"

out_files/slope_grid.csv:  get_slopeGrid.r con_quicc_db.r
	$(R_CMD) get_slopeGrid.r
	@echo "Query success and slope grid transferred into out_files folder"

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

out_files/climato_1970-2000_biovars.rds: get_climato_1970-2000.r con_quicc_db.r
	$(R_CMD) get_climato_1970-2000.r
	@echo "Query success and climato_1970-2000_biovars.rds transferred into out_files folder"

out_files/SDMClimate_grid.csv: get_SDMClimate_grid.r con_quicc_db.r
	$(R_CMD) get_SDMClimate_grid.r
	@echo "Query success and SDMClimate_grid.csv transferred into out_files folder"

out_files/shp_stm_area.rdata: get_studyAreaShapeFiles.r con_quicc_db.r
	mkdir -p out_files/shapefiles/
	$(R_CMD) get_studyAreaShapeFiles.r
	@echo "Shapefiles successfully writed in the out_files folder"

reshape/tmpStateData_r$(R_STATE).rdata: reshape/reshapeStates.r out_files/treeData.csv \
out_files/climData.csv out_files/plotInfoData.csv
	$(R_CMD) reshape/reshapeStates.r -r $(R_STATE) -t out_files/treeData.csv \
	-c out_files/climData.csv -p out_files/plotInfoData.csv

out_files/transitions_r$(R_STATE).rdata: reshape/tmpStateData_r$(R_STATE).rdata \
reshape/reshapeTransitions.r
	$(R_CMD) reshape/reshapeTransitions.r -i reshape/tmpStateData_r$(R_STATE).rdata \
	-o out_files/transitions_r$(R_STATE).rdata

out_files/plots_map.png: out_files/plotInfoData.csv

# two state model
out_files/transitions_twostate_18032-ABI-BAL.rdata: reshape/reshapeTransitions_2state.r \
reshape/tmpStateData_twoState.rdata
	$(R_CMD) reshape/reshapeTransitions_2state.r -s "18032-ABI-BAL"

out_files/transition_twostate_28731-ACE-SAC.rdata: reshape/reshapeTransitions_2state.r \
reshape/tmpStateData_twoState.rdata
	$(R_CMD) reshape/reshapeTransitions_2state.r -s "28731-ACE-SAC"

reshape/tmpStateData_twoState.rdata: reshape/reshapeStates_2state.r out_files/treeData.csv \
out_files/climData.csv out_files/plotInfoData.csv
	$(R_CMD) reshape/reshapeStates_2state.r
