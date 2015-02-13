-- Stored past-climate in rasters for each year measured
-- Each raster contains the climatic average (15 past-years).

DROP MATERIALIZED VIEW IF EXISTS rdb_quicc.stm_rasters_clim;
CREATE MATERIALIZED VIEW rdb_quicc.stm_rasters_clim AS (
    SELECT rast, biovar, year_clim, year_measured
    FROM clim_rs.clim_allbiovars,
    (SELECT DISTINCT year_measured FROM rdb_quicc.stm_plots_id
    ORDER BY year_measured) as all_year_meas,
    (SELECT ST_Transform(ST_ConvexHull(coord_postgis),4269) as ext FROM rdb_quicc.stm_plots_id) as coords_box
    WHERE year_clim <= year_measured AND year_clim > year_measured-15
    AND ST_Intersects(rast,ext)
);
