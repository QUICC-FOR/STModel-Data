# Get the trees out of the QUICC-FOR Database
# Date: November 14th, 2014

# This script extract all tree species needed by the stm model.
## ---------------------------------------------
# Details on species codes: ./out_files/stm_code_species.csv

# 18032-ABI-BAL: Balsam fir
# 18034-PIC-RUB: Red spruce
# 19408-QUE-RUB: Red oak
# 19462-FAG-GRA: American beech
# 19466-ALN-NA: Saule
# 19481-BET-ALL: Yellow birch
# 19489-BET-PAP: White
# 19511-OST-VIR: Ironwood
# 21536-TIL-AME: Basswood
# 22453-POP-BAL: Balsam poplar
# 22463-POP-GRA: Large tooth
# 24764-PRU-SER: Black cherry
# 24799-PRU-PEN: Pin cherry
# 25319-SOR-AME: American mountain-ash
# 28728-ACE-RUB: Red maple
# 28731-ACE-SAC: Sugar maple
# 32931-FRA-AME: White ash
# 32945-FRA-NIG: Black ash
# 183295-PIC-GLA: White spruce
# 183302-PIC-MAR: Black spruce
# 183319-PIN-BAN: jack pine
# 183412-LAR-LAR: Tamarack
# 195773-POP-TRE: Trembling aspen

# Filters:
	# - DBH > 127 and not null
	# - plot_size is not null
	# - plot_id should be in the materialized view (for further details see ./src_sql/stm_plot_ids.sql)

## Get treeData from quicc-for database
## ---------------------------------------------

# Database connection
source('./con_quicc_db.r')

# Query
query_treeData  <- "
SELECT plot_id, year_measured, id_spe, surf_spe_m2*10000/plot_size as basal_area FROM(
	SELECT plot_id, year_measured, id_spe, sum(surf_mm2)/1000000 as surf_spe_m2, plot_size FROM (
			SELECT tree.plot_id, tree.year_measured,tree.tree_id,tree.id_spe,
			 (((tree.dbh)/2)^2*pi()) as surf_mm2, plot.plot_size
			FROM rdb_quicc.tree
			RIGHT JOIN (SELECT DISTINCT plot_id FROM rdb_quicc.stm_plots_clim) as plt_clim_constraint USING (plot_id)
			LEFT JOIN rdb_quicc.plot USING (plot_id,year_measured)
			WHERE dbh > 127 AND plot_size IS NOT NULL AND dbh IS NOT NULL
		) AS get_individual_tree_surf
	GROUP BY plot_id, year_measured, id_spe, plot_size) AS final_tree_data
ORDER BY plot_id, year_measured, id_spe;
"

## Send the query to the database
treeData <- dbGetQuery(con, query_treeData)
## Time: Approx. 3 minutes

# Writing final trees dataset
## ---------------------------------------------

write.table(treeData, file="out_files/treeData.csv", sep=',', row.names=FALSE)

