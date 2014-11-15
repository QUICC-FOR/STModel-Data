# Get all tree data from the QUICC-FOR Database
# Date: November 14th, 2014

# This script extract all tree
## ---------------------------------------------
# First step: The North america past climate grid is clipped with the spatial polygon of Quebec.
# Second step: The average of the climatic variables are compute on the clipped raster and the period of time expected


## Get treeData from quicc-for database
## ---------------------------------------------

# Database connection
source('./con_quicc_db.r')

# Query 
query_pastClimate_grid  <- "
SELECT plot_id, year_measured, id_spe, surf_spe_m2*10000/plot_size as basal_area FROM(
	SELECT plot_id, year_measured, id_spe, sum(surf_mm2)/1000000 as surf_spe_m2, plot_size FROM (
			SELECT tree.plot_id, tree.year_measured,tree.tree_id,tree.id_spe,
			 (((tree.dbh)/2)^2*pi()) as surf_mm2, plot.plot_size
			FROM rdb_quicc.tree
			RIGHT OUTER JOIN rdb_quicc.stm_plot_ids USING (plot_id)
			LEFT OUTER JOIN rdb_quicc.plot USING (plot_id,year_measured)
			WHERE dbh > 127 AND plot_size IS NOT NULL AND dbh IS NOT NULL 
			AND id_spe IN ('18032-ABI-BAL','18034-PIC-RUB','19408-QUE-RUB',
			'19462-FAG-GRA','19466-ALN-NA','19481-BET-ALL','19489-BET-PAP',
			'19511-OST-VIR','21536-TIL-AME','22453-POP-BAL','22463-POP-GRA',
			'24764-PRU-SER','24799-PRU-PEN','25319-SOR-AME','28728-ACE-RUB',
			'28731-ACE-SAC','32931-FRA-AME','32945-FRA-NIG','183295-PIC-GLA',
			'183302-PIC-MAR','183319-PIN-BAN','183412-LAR-LAR','195773-POP-TRE')
		) AS get_individual_tree_surf
	GROUP BY plot_id, year_measured, id_spe, plot_size 

	UNION ALL

	-- Other species
	SELECT plot_id, year_measured, 'other species' As id_spe, sum(surf_mm2)/1000000 as surf_spe_m2, plot_size FROM (
			SELECT tree.plot_id, tree.year_measured,tree.tree_id,tree.id_spe,
			 (((tree.dbh)/2)^2*pi()) as surf_mm2, plot.plot_size
			FROM rdb_quicc.tree
			RIGHT OUTER JOIN rdb_quicc.stm_plot_ids USING (plot_id)
			LEFT OUTER JOIN rdb_quicc.plot USING (plot_id,year_measured)
			WHERE dbh > 127 AND plot_size IS NOT NULL AND dbh IS NOT NULL 
			AND id_spe NOT IN ('18032-ABI-BAL','18034-PIC-RUB','19408-QUE-RUB',
			'19462-FAG-GRA','19466-ALN-NA','19481-BET-ALL','19489-BET-PAP',
			'19511-OST-VIR','21536-TIL-AME','22453-POP-BAL','22463-POP-GRA',
			'24764-PRU-SER','24799-PRU-PEN','25319-SOR-AME','28728-ACE-RUB',
			'28731-ACE-SAC','32931-FRA-AME','32945-FRA-NIG','183295-PIC-GLA',
			'183302-PIC-MAR','183319-PIN-BAN','183412-LAR-LAR','195773-POP-TRE')
		) AS get_other_tree_species_surf
	GROUP BY plot_id, year_measured, plot_size
) AS final_tree_data;
"

## Send the query to the database
treeData <- dbGetQuery(con, query_pastClimate_grid)
## Time: Approx. 5-15 minutes

# Writing final tree dataset
## ---------------------------------------------

write.table(treeData, file="out_files/treeData.csv", sep=',', row.names=FALSE)

