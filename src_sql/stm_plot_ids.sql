-- SQL view with all plot_id considered in the stm model

-- Create a materialized view on each plot_id containing at least one tree of the species list with a dbh greater than 127 mm.
-- Plots outside of the Eastern part of North America are filtered out (longitude > -97.0)
-- Plots should be measured at least 2 times

-- SQL Instructions dropping and rebuilding the view based on the criteria:

DROP MATERIALIZED VIEW IF EXISTS rdb_quicc.stm_plot_ids;

CREATE MATERIALIZED VIEW rdb_quicc.stm_plot_ids AS (
	SELECT DISTINCT
		plot.plot_id,
		plot.year_measured
	FROM
		rdb_quicc.tree
	INNER JOIN rdb_quicc.plot USING (plot_id, year_measured)
	INNER JOIN rdb_quicc.localisation USING (plot_id)
	WHERE plot.is_temp = False
	AND localisation.longitude > -97.0
	AND plot.plot_size IS NOT NULL
	ORDER BY plot_id
);