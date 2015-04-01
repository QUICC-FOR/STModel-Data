DROP MATERIALIZED VIEW IF EXISTS rdb_quicc.stm_plots_soil; 
CREATE MATERIALIZED VIEW rdb_quicc.stm_plots_soil AS(
    SELECT plot_id,
    ST_Value(ST_Slope(demelevation.rast::raster,1,'32BF'::text,'DEGREES'::text,111120.0::double precision,false),coord,false)::float as slp,
    ST_Value(soil.rast,coord,false) as soil,
    ST_Value(ph_sd1.rast,coord,false) as ph_2cm, 
    ST_Value(ph_sd2.rast,coord,false) as ph_10cm  
    FROM 
    map_world.demelevation,
    map_world.soil,
    map_world.ph_sd1,
    map_world.ph_sd2,
    (SELECT DISTINCT plot_id, ST_Transform(coord_postgis,4326) AS coord FROM rdb_quicc.stm_plots_id) as coord_plots
    WHERE ST_Intersects(demelevation.rast,coord) AND ST_Intersects(soil.rast,coord) AND ST_Intersects(ph_sd1.rast,coord)
    AND ST_Intersects(ph_sd2.rast,coord)
);