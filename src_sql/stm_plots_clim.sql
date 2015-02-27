-- MV on climate

DROP MATERIALIZED VIEW IF EXISTS rdb_quicc.stm_plots_clim CASCADE;
CREATE MATERIALIZED VIEW rdb_quicc.stm_plots_clim AS (
     SELECT plot_id, biovar, year_measured, year_clim, ST_Value(rast,coord_postgis,false) AS val
     FROM rdb_quicc.stm_plots_id
     LEFT JOIN rdb_quicc.stm_rasters_clim USING (year_measured)
     WHERE ST_Intersects(rast,coord_postgis)
     ORDER BY plot_id, year_measured, year_clim
);

CREATE INDEX stm_mv_clim_rs_search
  ON rdb_quicc.stm_plots_clim AS
  USING btree
  (year_measured ,biovar);
