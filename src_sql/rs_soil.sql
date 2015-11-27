CREATE MATERIALIZED VIEW rdb_quicc.rs_soil AS (
    SELECT var,  ST_Tile(rast,10,10) AS rast FROM (

            SELECT var ,ST_Resample(ph.rast,ref.rast) as rast FROM
            (SELECT ST_Transform(ST_Union(rast),4269) AS rast, 'ph_sd1' :: varchar(10)  as var FROM map_world.ph_sd1,
                 (SELECT ST_Transform(ST_GeomFromText('POLYGON((-79.95454 43.04572,-79.95454 50.95411,-60.04625 50.95411,-60.04625 43.04572,-79.95454 43.04572))',4326),4269) as env_plots) AS env_stm
             WHERE ST_Intersects(ST_Transform(rast,4269),env_stm.env_plots)) as ph,
            (SELECT ST_Union(rast) as rast 
                FROM clim_rs.past_clim_allbiovars,
                    (SELECT ST_Transform(ST_GeomFromText('POLYGON((-79.95454 43.04572,-79.95454 50.95411,-60.04625 50.95411,-60.04625 43.04572,-79.95454 43.04572))',4326),4269) as env_plots) AS env_stm
                WHERE biovar = 'annual_mean_temp' AND year_clim = 2010 AND ST_Intersects(rast,env_stm.env_plots)) as ref

            UNION ALL

            SELECT var, ST_Resample(ph.rast,ref.rast) as rast FROM
            (SELECT ST_Transform(ST_Union(rast),4269) AS rast, 'ph_sd2' :: varchar(10)  as var FROM map_world.ph_sd2,
                 (SELECT ST_Transform(ST_GeomFromText('POLYGON((-79.95454 43.04572,-79.95454 50.95411,-60.04625 50.95411,-60.04625 43.04572,-79.95454 43.04572))',4326),4269) as env_plots) AS env_stm
             WHERE ST_Intersects(ST_Transform(rast,4269),env_stm.env_plots)) as ph,
            (SELECT ST_Union(rast) as rast 
                FROM clim_rs.past_clim_allbiovars,
                    (SELECT ST_Transform(ST_GeomFromText('POLYGON((-79.95454 43.04572,-79.95454 50.95411,-60.04625 50.95411,-60.04625 43.04572,-79.95454 43.04572))',4326),4269) as env_plots) AS env_stm
                WHERE biovar = 'annual_mean_temp' AND year_clim = 2010 AND ST_Intersects(rast,env_stm.env_plots)) as ref

            UNION ALL

            SELECT var, ST_Resample(soil.rast,ref.rast) as rast FROM
            (SELECT ST_Transform(ST_Union(rast),4269) AS rast, 'soil' :: varchar(10)  as var FROM map_world.soil,
                 (SELECT ST_Transform(ST_GeomFromText('POLYGON((-79.95454 43.04572,-79.95454 50.95411,-60.04625 50.95411,-60.04625 43.04572,-79.95454 43.04572))',4326),4269) as env_plots) AS env_stm
             WHERE ST_Intersects(ST_Transform(rast,4269),env_stm.env_plots)) as soil,
            (SELECT ST_Union(rast) as rast 
                FROM clim_rs.past_clim_allbiovars,
                    (SELECT ST_Transform(ST_GeomFromText('POLYGON((-79.95454 43.04572,-79.95454 50.95411,-60.04625 50.95411,-60.04625 43.04572,-79.95454 43.04572))',4326),4269) as env_plots) AS env_stm
                WHERE biovar = 'annual_mean_temp' AND year_clim = 2010 AND ST_Intersects(rast,env_stm.env_plots)) as ref

            ) AS rasters_tiled
);

CREATE INDEX rs_soil_spa_idx
  ON rdb_quicc.rs_soil
  USING gist
  (st_convexhull(rast));

CREATE INDEX rs_soil_var
  ON rdb_quicc.rs_soil
  USING btree
  (var);
