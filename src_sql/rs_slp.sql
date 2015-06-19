CREATE MATERIALIZED VIEW rdb_quicc.rs_slp AS (
    SELECT var,  ST_Tile(rast,10,10) AS rast FROM (

             SELECT 'slp' AS var, ST_Transform(ST_Slope(ST_Union(demelevation.rast::raster),1,'32BF'::text,'DEGREES'::text,111120.0::double precision,false),4269) as rast
             FROM map_world.demelevation,
                  (SELECT ST_Transform(ST_GeomFromText('POLYGON((-79.95454 43.04572,-79.95454 50.95411,-60.04625 50.95411,-60.04625 43.04572,-79.95454 43.04572))',4326),4269) as env_plots) AS env_stm
              WHERE ST_Intersects(ST_Transform(rast,4269),env_stm.env_plots)

            ) AS rasters_tiled
);

CREATE INDEX rs_slp_spa_idx
  ON rdb_quicc.rs_slp
  USING gist
  (st_convexhull(rast));

CREATE INDEX rs_slp_var
  ON rdb_quicc.rs_slp
  USING btree
  (var);
