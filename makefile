# Makefile to retrieve & reshape data from the QUICC-FOR database
# Jan 20, 2015

# set the threshold basal area value for the R state
R_STATE = 1

R_CMD = Rscript
export QC_VPN := $(shell bash -c 'read -p "Use VPN (Y/[N]): " vpn; vpn=$${vpn:-N}; echo $$vpn')
export QC_USERNAME := $(shell bash -c 'read -p "Enter your database username: " pwd; echo $$pwd')
export QC_PASSWORD := $(shell bash -c 'read -s -p "Enter your database password: " pwd; echo $$pwd')


all: treeData climData plotInfoData STMClimate_grid SDMClimate_grid plotMap SHP_area reshape
speciesCode: out_files/speciesCode.csv
treeData: out_files/treeData.csv
climData: out_files/climData.csv
plotInfoData: out_files/plotInfoData.csv
STMClimate_grid: out_files/STMClimate_grid.csv
SDMClimate_grid: out_files/SDMClimate_grid.csv
SHP_area: out_files/shp_stm_area.robj
plotMap: out_files/plots_map.png
reshape: out_files/transitions_r$(R_STATE).rdata

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

out_files/STMClimate_grid.csv: get_STMClimate_grid.r con_quicc_db.r
	$(R_CMD) get_STMClimate_grid.r
	@echo "Query success and STMClimate_grid.csv transferred into out_files folder"

out_files/SDMClimate_grid.csv: get_SDMClimate_grid.r con_quicc_db.r
	$(R_CMD) get_SDMClimate_grid.r
	@echo "Query success and SDMClimate_grid.csv transferred into out_files folder"

out_files/shp_stm_area.robj: get_studyAreaShapeFiles.r con_quicc_db.r
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

