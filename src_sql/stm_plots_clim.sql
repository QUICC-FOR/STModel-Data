-- MV on climate

DROP MATERIALIZED VIEW IF EXISTS rdb_quicc.stm_plots_clim CASCADE;
CREATE MATERIALIZED VIEW rdb_quicc.stm_plots_clim AS (
     SELECT plot_id, biovar, year_measured, ST_Value(rast_climato,coord_postgis,false) AS val
     FROM rdb_quicc.stm_plots_id
     LEFT JOIN rdb_quicc.stm_rasters_climato USING (year_measured)
     WHERE ST_Intersects(rast_climato,coord_postgis)
);

CREATE INDEX stm_mv_plots_clim_search
  ON rdb_quicc.stm_plots_clim
  USING btree
  (plot_id, year_measured ,biovar);