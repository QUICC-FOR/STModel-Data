-- SQL view with all plot_id considered in the stm model

-- Create a materialized view on each plot_id containing at least one tree of the species list with a dbh greater than 127 mm.
-- Plots outside of the Eastern part of North America are filtered out (longitude > -97.0)
-- Plots should be measured at least 2 times

-- SQL Instructions dropping and rebuilding the view based on the criteria:
	-- 1. Plots not temporary
	-- 2. Plots location superior than -97.0 of longitude
	-- 3. Plots size known

	-- The second queries get the climate of all plots for 6 different climatic variables (interception with climatic rasters, 2010-1960)

DROP MATERIALIZED VIEW IF EXISTS rdb_quicc.stm_plots_id;
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

DROP MATERIALIZED VIEW IF EXISTS rdb_quicc.stm_plots_clim;
CREATE MATERIALIZED VIEW rdb_quicc.stm_plots_clim AS (
SELECT plot_id, biovar, year_measured, year_clim, ST_Value(rast,coord_postgis,false) AS val
FROM
(SELECT plot_id, ST_Transform(coord_postgis,4269) as coord_postgis, year_measured
FROM rdb_quicc.stm_plots_id) As plot_points,
(SELECT rast, biovar, year_clim
	FROM clim_rs.clim_allbiovars
	WHERE biovar IN (
	'temp_seasonality',
	'mean_temp_wettest_quarter',
	'mean_temp_driest_quarter',
	'max_temp_warmest_period',
	'gdd_above_base_temp_period2',
	'pp_driest_quarter',
	'pp_wettest_period',
	'mean_temp_period_3',
	'tot_annual_pp',
	'jd_number_grow_season',
	'jd_number_start_grow_season',
	'tot_pp_period4',
	'gdd_above_base_temp_period4',
	'tot_pp_period2',
	'isothermality',
	'mean_temp_warmest_quarter',
	'mean_temp_coldest_quarter',
	'pp_warmest_quarter',
	'annual_minimum_temp',
	'temp_range_period_3',
	'tot_pp_period3',
	'mean_diurnal_range',
	'pp_coldest_quarter',
	'pp_seasonality',
	'tot_pp_period1',
	'min_temp_coldest_period',
	'gdd_above_base_temp_period3',
	'annual_maximum_temp',
	'temp_annual_range',
	'jd_number_end_grow_season',
	'pp_wettest_quarter',
	'gdd_above_base_temp_period1',
	'pp_driest_period',
	'annual_mean_temp'
		)) AS clim_rasters
WHERE year_clim <= year_measured AND year_clim > year_measured-15
AND ST_Intersects(rast,coord_postgis)
);