-- MV on climate

DROP MATERIALIZED VIEW IF EXISTS rdb_quicc.stm_plots_clim;
CREATE MATERIALIZED VIEW rdb_quicc.stm_plots_clim AS (
    SELECT plot_id, biovar, year_measured, year_clim, ST_Value(rast,coord_postgis,false) AS val
    FROM
    (SELECT ST_ConvexHull(ST_Collect(ST_Transform(coord_postgis,4269))) as bbox
    FROM rdb_quicc.stm_plots_id) As env,
    (SELECT plot_id, year_measured,
        ST_Transform(coord_postgis,4269) as coord_postgis
    FROM rdb_quicc.stm_plots_id) As plot_points,
    (SELECT rast, biovar, year_clim
        FROM clim_rs.clim_allbiovars) AS clim_rasters
    WHERE year_clim <= year_measured AND year_clim > year_measured-15
    AND ST_Intersects(rast,bbox)
);