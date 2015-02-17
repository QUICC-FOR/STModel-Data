-- Stored past-climate in rasters for each year measured
-- Each raster contains the climatic average (15 past-years).

DROP MATERIALIZED VIEW IF EXISTS rdb_quicc.stm_rasters_clim;
CREATE MATERIALIZED VIEW rdb_quicc.stm_rasters_clim AS (
SELECT year_measured, biovar, ST_Union(rast,'MEAN') AS rast FROM (
    SELECT rast, biovar, year_clim, year_measured
    FROM clim_rs.clim_allbiovars,
    (SELECT ST_ConvexHull(ST_Collect(ST_Transform(coord_postgis,4269))) as convex FROM rdb_quicc.stm_plots_id) as bbox,
    (SELECT DISTINCT year_measured FROM rdb_quicc.stm_plots_id ORDER BY year_measured) as all_year_meas
    WHERE ST_Intersects(rast,convex)
    AND year_clim <= year_measured AND year_clim > year_measured-15
) AS all_rast
GROUP BY year_measured, biovar
);
