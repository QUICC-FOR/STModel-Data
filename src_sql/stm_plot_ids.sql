-- SQL view with all plot_id considered in the stm model

-- Create a materialized view on each plot_id containing at least one tree of the species list with a dbh greater than 127 mm.
-- Plots outside of the Eastern part of North America are filtered out (longitude > -97.0)

-- SQL Instructions dropping and rebuilding the view based on the criteria:

DROP MATERIALIZED VIEW IF EXISTS rdb_quicc.stm_plot_ids;

CREATE MATERIALIZED VIEW rdb_quicc.stm_plot_ids AS (
SELECT DISTINCT 
	plot.plot_id
FROM
	rdb_quicc.tree
INNER JOIN rdb_quicc.plot USING (plot_id, year_measured)
INNER JOIN rdb_quicc.localisation USING (plot_id)
INNER JOIN rdb_quicc.ref_species USING(id_spe)
LEFT OUTER JOIN rdb_quicc.climatic_data USING (id_plot)
WHERE tree.dbh > 126 AND plot.is_temp = False AND (
tree.id_spe = '18032-ABI-BAL' OR
tree.id_spe = '18034-PIC-RUB' OR
tree.id_spe = '19408-QUE-RUB' OR
tree.id_spe = '19462-FAG-GRA' OR
tree.id_spe = '19466-ALN-NA' OR
tree.id_spe = '19481-BET-ALL' OR
tree.id_spe = '19489-BET-PAP' OR
tree.id_spe = '19511-OST-VIR' OR
tree.id_spe = '21536-TIL-AME' OR
tree.id_spe = '22453-POP-BAL' OR
tree.id_spe = '22463-POP-GRA' OR
tree.id_spe = '24764-PRU-SER' OR
tree.id_spe = '24799-PRU-PEN' OR
tree.id_spe = '25319-SOR-AME' OR
tree.id_spe = '28728-ACE-RUB' OR
tree.id_spe = '28731-ACE-SAC' OR
tree.id_spe = '32931-FRA-AME' OR
tree.id_spe = '32945-FRA-NIG' OR
tree.id_spe = '183295-PIC-GLA' OR
tree.id_spe = '183302-PIC-MAR' OR
tree.id_spe = '183319-PIN-BAN' OR
tree.id_spe = '183412-LAR-LAR' OR
tree.id_spe = '195773-POP-TRE' ) 
AND localisation.longitude > -97.0
AND plot.plot_size IS NOT NULL
ORDER BY plot_id ASC);