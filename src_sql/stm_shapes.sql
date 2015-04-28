-- Continent shapefile

DROP TABLE IF EXISTS temp_quicc.stm_countries_shapes;
CREATE TABLE temp_quicc.stm_countries_shapes AS
    SELECT region, ST_Transform(geom,4269) as geom FROM(
    SELECT ST_Intersection(can_adm0.geom,envelope.env_plots) as geom, 'can' as region
    FROM map_world.can_adm0,
    (SELECT ST_Transform(ST_Envelope(ST_Collect(stm_plots_id.coord_postgis)),4326) as env_plots
    FROM rdb_quicc.stm_plots_id) as envelope

    UNION ALL

    SELECT ST_Intersection(usa_adm0.geom,envelope.env_plots) as geom, 'usa' as region
    FROM map_world.usa_adm0,
    (SELECT ST_Transform(ST_Envelope(ST_Collect(stm_plots_id.coord_postgis)),4326) as env_plots
    FROM rdb_quicc.stm_plots_id) as envelope
) as us_can_geometry;

CREATE INDEX idx_countries_shapes_gist
  ON temp_quicc.stm_countries_shapes USING gist(geom);

SELECT populate_geometry_columns('temp_quicc.stm_countries_shapes'::regclass);

-- All Lakes shapefile

DROP TABLE IF EXISTS temp_quicc.stm_lakes_shapes;
CREATE TABLE temp_quicc.stm_lakes_shapes AS
    SELECT region, ST_Transform(ST_Multi(geom),4269) as geom FROM(
    SELECT ST_Intersection(can_water_areas_dcw.geom,envelope.env_plots) as geom,
    'can' :: varchar(4) as region
    FROM map_world.can_water_areas_dcw,
    (SELECT ST_Transform(ST_Envelope(ST_Collect(stm_plots_id.coord_postgis)),4326) as env_plots
    FROM rdb_quicc.stm_plots_id) as envelope
    WHERE area >= 0.0005

    UNION ALL
    
    SELECT ST_Transform(geom,4269) as geom, region FROM(
    SELECT ST_Intersection(usa_water_areas_dcw.geom,envelope.env_plots) as geom,
    'usa' :: varchar(4) as region,
    ST_Area(ST_Intersection(usa_water_areas_dcw.geom,envelope.env_plots))
    FROM map_world.usa_water_areas_dcw,
    (SELECT ST_Transform(ST_Envelope(ST_Collect(stm_plots_id.coord_postgis)),4326) as env_plots
    FROM rdb_quicc.stm_plots_id) as envelope) as surf
    WHERE st_area >= 0.0005
    ) as us_can_geometry
    WHERE NOT ST_IsEmpty(geom);

CREATE INDEX idx_lakes_shapes_gist
  ON temp_quicc.stm_lakes_shapes USING gist(geom);

SELECT populate_geometry_columns('temp_quicc.stm_lakes_shapes'::regclass);

-- Lakes shapefile

DROP TABLE IF EXISTS temp_quicc.stm_great_lakes_shapes;
CREATE TABLE temp_quicc.stm_great_lakes_shapes AS
    SELECT region, ST_Transform(ST_Multi(geom),4269) as geom FROM(
    SELECT ST_Intersection(can_water_areas_dcw.geom,envelope.env_plots) as geom,
    'can' :: varchar(4) as region
    FROM map_world.can_water_areas_dcw,
    (SELECT ST_Transform(ST_Envelope(ST_Collect(stm_plots_id.coord_postgis)),4326) as env_plots
    FROM rdb_quicc.stm_plots_id) as envelope
    WHERE area >= 0.1

    UNION ALL
    
    SELECT ST_Transform(geom,4269) as geom, region FROM(
    SELECT ST_Intersection(usa_water_areas_dcw.geom,envelope.env_plots) as geom,
    'usa' :: varchar(4) as region,
    ST_Area(ST_Intersection(usa_water_areas_dcw.geom,envelope.env_plots))
    FROM map_world.usa_water_areas_dcw,
    (SELECT ST_Transform(ST_Envelope(ST_Collect(stm_plots_id.coord_postgis)),4326) as env_plots
    FROM rdb_quicc.stm_plots_id) as envelope) as surf
    WHERE st_area >= 0.1
    ) as us_can_geometry
    WHERE NOT ST_IsEmpty(geom);

CREATE INDEX idx_great_lakes_shapes_gist
  ON temp_quicc.stm_great_lakes_shapes USING gist(geom);

SELECT populate_geometry_columns('temp_quicc.stm_great_lakes_shapes'::regclass);