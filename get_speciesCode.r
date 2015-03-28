# Get the species code out of the QUICC-FOR Database
# Date: November 14th, 2014

# This script extract all species code
## ---------------------------------------------

## Get species code from quicc-for database
## ---------------------------------------------

# Database connection
#source('./con_quicc_db.r')
source('./con_quicc_db_local.r')

# Query
query_speciesCode  <- "
SELECT id_spe, tsn, genus, species, en_common_name, fr_common_name FROM rdb_quicc.ref_species WHERE id_spe IN
            (SELECT DISTINCT tree.id_spe
            FROM rdb_quicc.tree
            RIGHT JOIN (SELECT DISTINCT plot_id FROM rdb_quicc.stm_plots_clim) as plt_clim_constraint USING (plot_id)
            LEFT JOIN rdb_quicc.plot USING (plot_id,year_measured)
            WHERE dbh > 127 AND plot_size IS NOT NULL AND dbh IS NOT NULL)
"

## Send the query to the database
speciesCode <- dbGetQuery(con, query_speciesCode)
## Time: Approx. 3 minutes

# Writing final trees dataset
## ---------------------------------------------

write.table(speciesCode, file="out_files/speciesCode.csv", sep=',', row.names=FALSE)

