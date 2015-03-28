# Get the trees out of the QUICC-FOR Database
# Date: November 14th, 2014

# This script extract all tree species needed by the stm model.
## ---------------------------------------------
# Details on species codes: ./out_files/stm_code_species.csv

# Filters:
	# - DBH > 127 and not null
	# - plot_size is not null
	# - plot_id should be in the materialized view (for further details see ./src_sql/stm_plot_ids.sql)
	# - tree is not dead

## Get treeData from quicc-for database
## ---------------------------------------------

# Database connection
#source('./con_quicc_db.r')
source('./con_quicc_db_local.r')

# Query
query_treeData  <- "
SELECT plot_id, year_measured, id_spe, surf_spe_m2*10000/sum(plot_size) as basal_area FROM(
    SELECT plot_id, subplot_id, year_measured, id_spe, sum(surf_mm2)/1000000 as surf_spe_m2, plot_size FROM (
            SELECT tree.plot_id,tree.subplot_id, tree.year_measured,tree.tree_id,tree.id_spe,
             (((tree.dbh)/2)^2*pi()) as surf_mm2, plot.plot_size
            FROM rdb_quicc.tree
            RIGHT JOIN (SELECT DISTINCT plot_id FROM rdb_quicc.stm_plots_clim) as plt_clim_constraint USING (plot_id)
            LEFT JOIN rdb_quicc.plot USING (plot_id,subplot_id,year_measured)
            WHERE dbh > 127 AND plot_size IS NOT NULL AND dbh IS NOT NULL AND is_dead = FALSE AND dbh != 9999
        ) AS get_individual_tree_surf
    GROUP BY plot_id,subplot_id, year_measured, id_spe, plot_size) AS final_tree_data
GROUP BY plot_id,year_measured,id_spe,surf_spe_m2
ORDER BY plot_id, year_measured, id_spe;
"
## Send the query to the database
treeData <- dbGetQuery(con, query_treeData)
## Time: Approx. 3 minutes


# Writing final trees dataset
## ---------------------------------------------
write.table(treeData, file="out_files/treeData.csv", sep=',', row.names=FALSE)
