CREATE MATERIALIZED VIEW rdb_quicc.rs_clim_7020 AS (
    SELECT var,  ST_Tile(rast,10,10) AS rast FROM (


            SELECT var, ST_Resample(clim_wt_union.rast,ref.rast) AS rast FROM(
                SELECT var, ST_Union(clim.rast,'MEAN') as rast
                FROM
                (SELECT past_clim_allbiovars.rast, biovar as var ,year_clim 
                    FROM clim_rs.past_clim_allbiovars,
                    (SELECT ST_Transform(ST_ConvexHull(ST_Collect(localisation.coord_postgis)),4269) as env_plots FROM rdb_quicc.localisation) AS env_stm
                    WHERE ST_Intersects(past_clim_allbiovars.rast,env_stm.env_plots) AND year_clim >= 1970 AND year_clim <= 2000) as clim
                GROUP BY var) AS clim_wt_union,
            (SELECT ST_Union(rast) as rast 
                FROM clim_rs.past_clim_allbiovars,
                (SELECT ST_Transform(ST_ConvexHull(ST_Collect(localisation.coord_postgis)),4269) as env_plots FROM rdb_quicc.localisation ) AS env_stm
                WHERE biovar = 'annual_mean_temp' AND year_clim = 2010 AND ST_Intersects(rast,env_stm.env_plots)) as ref

            ) AS rasters_tiled
);

CREATE INDEX rs_clim_7020_spa_idx
  ON rdb_quicc.rs_climato_7020
  USING gist
  (st_convexhull(rast));

CREATE INDEX rs_clim_7020_var
  ON rdb_quicc.rs_climato_7020
  USING btree
  (var);
