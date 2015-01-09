-- SQL view with all plot_id considered in the stm model

-- Create a materialized view on each plot_id containing at least one tree of the species list with a dbh greater than 127 mm.
-- Plots outside of the Eastern part of North America are filtered out (longitude > -97.0)
-- Plots should be measured at least 2 times

-- SQL Instructions dropping and rebuilding the view based on the criteria:
	-- 1. Plots not temporary
	-- 2. Plots location superior than -97.0 of longitude
	-- 3. Plots size known

	-- The second queries get the climate of all plots for 6 different climatic variables (interception with climatic rasters, 2010-1960)

DROP MATERIALIZED VIEW IF EXISTS rdb_quicc.stm_plots_id CASCADE;
CREATE MATERIALIZED VIEW rdb_quicc.stm_plots_id AS (
	SELECT DISTINCT
		plot.plot_id,
		plot.year_measured,
		localisation.coord_postgis
	FROM
		rdb_quicc.tree
	INNER JOIN rdb_quicc.plot USING (plot_id, year_measured)
	INNER JOIN rdb_quicc.localisation USING (plot_id)
	WHERE plot.is_temp = False
	AND localisation.longitude >= -97.0
	AND plot.plot_size IS NOT NULL
	ORDER BY plot_id
);

DROP MATERIALIZED VIEW IF EXISTS rdb_quicc.stm_plots_clim CASCADE;
CREATE MATERIALIZED VIEW rdb_quicc.stm_plots_clim AS (
SELECT plot_id, biovar, year_clim, ST_Value(rast,coord_postgis,false) AS val
FROM
(SELECT DISTINCT plot_id, ST_Transform(coord_postgis,4269) as coord_postgis
FROM rdb_quicc.stm_plots_id) As plot_points,
(SELECT rast, biovar, year_clim
	FROM clim_rs.clim_allbiovars
	WHERE biovar IN ('annual_mean_temp',
		'pp_seasonality',
		'pp_warmest_quarter',
		'mean_diurnal_range',
		'tot_annual_pp',
		'mean_temperature_wettest_quarter')) AS clim_rasters
WHERE year_clim >=1960
AND ST_Intersects(rast,coord_postgis)
);
