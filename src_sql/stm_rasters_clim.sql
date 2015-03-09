-- Stored past-climate in rasters for each year measured
-- Each raster contains the climatic average (15 past-years).

DROP MATERIALIZED VIEW IF EXISTS rdb_quicc.stm_rasters_climato CASCADE;
CREATE MATERIALIZED VIEW rdb_quicc.stm_rasters_climato AS (
SELECT biovar, year_measured, ST_Tile(ST_Union(rast,'MEAN'),10,10) AS rast_climato FROM (
 SELECT biovar, year_clim, year_measured, rast
    FROM clim_rs.past_clim_allbiovars,
    (SELECT ST_ConvexHull(ST_Collect(coord_postgis)) as convex, year_measured FROM rdb_quicc.stm_plots_id GROUP BY year_measured) as bbox
    WHERE ST_Intersects(rast,convex)
    AND year_clim <= year_measured AND year_clim > year_measured-15) AS all_rast_last_15yrs
GROUP BY biovar, year_measured
);

CREATE INDEX stm_mv_clim_rs_st_convexhull_idx
  ON rdb_quicc.stm_rasters_climato
  USING gist
  (st_convexhull(rast_climato));

CREATE INDEX stm_mv_clim_rs_search
  ON rdb_quicc.stm_rasters_climato
  USING btree
  (biovar, year_measured);