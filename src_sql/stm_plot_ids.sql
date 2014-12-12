-- SQL view with all plot_id considered in the stm model

-- Create a materialized view on each plot_id containing at least one tree of the species list with a dbh greater than 127 mm.
-- Plots outside of the Eastern part of North America are filtered out (longitude > -97.0)
-- Plots should be measured at least 2 times

-- SQL Instructions dropping and rebuilding the view based on the criteria:

DROP MATERIALIZED VIEW IF EXISTS rdb_quicc.stm_plot_ids;

CREATE MATERIALIZED VIEW rdb_quicc.stm_plot_ids AS (
	SELECT DISTINCT
		plot.plot_id,
		plot.year_measured,
		localisation.coord_postgis
	FROM
		rdb_quicc.tree
	INNER JOIN rdb_quicc.plot USING (plot_id, year_measured)
	INNER JOIN rdb_quicc.localisation USING (plot_id)
	WHERE plot.is_temp = False
	AND localisation.longitude > -97.0
	AND plot.plot_size IS NOT NULL
	ORDER BY plot_id
);

DROP MATERIALIZED VIEW IF EXISTS clim_rs.clim_00_70_stm CASCADE;
CREATE MATERIALIZED VIEW clim_rs.clim_00_70_stm AS (
SELECT biovar,year_clim, rast_noram.rast
   FROM
            (SELECT rast, biovar,year_clim FROM clim_rs.clim_allbiovars
                WHERE (year_clim >= 1970 AND year_clim <= 2000)
                AND biovar IN ('annual_mean_temp', 'pp_seasonality', 'pp_warmest_quarter', 'mean_diurnal_range','tot_annual_pp', 'mean_temperature_wettest_quarter')
                ) AS rast_noram,
            (SELECT ST_Transform(ST_ConvexHull(ST_Collect(stm_plot_ids.coord_postgis)),4269) as env_plots FROM rdb_quicc.stm_plot_ids) AS env_stm
WHERE ST_Intersects(rast_noram.rast,env_stm.env_plots));

DROP MATERIALIZED VIEW IF EXISTS clim_rs.clim_00_70_stm_union;
CREATE MATERIALIZED VIEW clim_rs.clim_00_70_qc_union AS (
    SELECT biovar, year_clim, ST_FasterUnion('clim_rs', 'clim_00_70_stm', 'rast') as union_raster
    FROM
        clim_rs.clim_00_70_stm
    GROUP BY biovar,year_clim);
