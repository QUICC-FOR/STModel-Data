-- MV on climate

DROP MATERIALIZED VIEW IF EXISTS rdb_quicc.stm_plots_clim;
CREATE MATERIALIZED VIEW rdb_quicc.stm_plots_clim AS (
    SELECT plot_id, biovar, year_measured, year_clim, ST_Value(rast,coord_postgis,false) AS val
    FROM
    (SELECT plot_id, ST_Transform(coord_postgis,4269) as coord_postgis, year_measured
    FROM rdb_quicc.stm_plots_id) As plot_points,
    (SELECT rast, biovar, year_clim
    	FROM clim_rs.clim_allbiovars) AS clim_rasters
    WHERE year_clim <= year_measured AND year_clim > year_measured-15
    AND ST_Intersects(rast,coord_postgis)
);