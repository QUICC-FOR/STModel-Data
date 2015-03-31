DROP MATERIALIZED VIEW rdb_quicc.stm_plots_soil_slp; 
CREATE MATERIALIZED VIEW rdb_quicc.stm_plots_soil_slp AS(
    SELECT plot_id,coord, ST_Value(demelevation.rast::raster,coord,false) as elv,
    ST_Value(ST_Slope(demelevation.rast::raster,1,'32BF'::text,'DEGREES'::text,111120.0::double precision,false),coord,false)::float as slp,
    ST_Value(soil.rast,coord,false) as soil FROM 
    map_world.demelevation,
    map_world.soil,
    (SELECT DISTINCT plot_id, ST_Transform(coord_postgis,4326) AS coord FROM rdb_quicc.stm_plots_id) as coord_plots
    WHERE ST_Intersects(demelevation.rast,coord) AND ST_Intersects(soil.rast,coord)
);