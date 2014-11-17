-- SQL view with all plot_id considered in the stm model

-- Create a materialized view on each plot_id containing at least one tree of the species list with a dbh greater than 127 mm.
-- Plots outside of the Eastern part of North America are filtered out (longitude > -97.0)
-- Plots should be measured at least 2 times

-- SQL Instructions dropping and rebuilding the view based on the criteria:

DROP MATERIALIZED VIEW IF EXISTS rdb_quicc.stm_plot_ids;

CREATE MATERIALIZED VIEW rdb_quicc.stm_plot_ids AS (
SELECT DISTINCT 
	plot.plot_id,
	count(year_measured) as n_meas
FROM
	rdb_quicc.tree
INNER JOIN rdb_quicc.plot USING (plot_id, year_measured)
INNER JOIN rdb_quicc.localisation USING (plot_id)
INNER JOIN rdb_quicc.ref_species USING(id_spe)
INNER JOIN rdb_quicc.climatic_data USING (plot_id)
WHERE tree.dbh > 126 AND plot.is_temp = False 
AND id_spe IN ('18032-ABI-BAL','18034-PIC-RUB','19408-QUE-RUB',
			'19462-FAG-GRA','19466-ALN-NA','19481-BET-ALL','19489-BET-PAP',
			'19511-OST-VIR','21536-TIL-AME','22453-POP-BAL','22463-POP-GRA',
			'24764-PRU-SER','24799-PRU-PEN','25319-SOR-AME','28728-ACE-RUB',
			'28731-ACE-SAC','32931-FRA-AME','32945-FRA-NIG','183295-PIC-GLA',
			'183302-PIC-MAR','183319-PIN-BAN','183412-LAR-LAR','195773-POP-TRE') 
AND localisation.longitude > -97.0
AND plot.plot_size IS NOT NULL
AND climatic_data.plot_id IS NOT NULL
GROUP BY plot.plot_id
HAVING count(year_measured) > 1
ORDER BY plot_id ASC);