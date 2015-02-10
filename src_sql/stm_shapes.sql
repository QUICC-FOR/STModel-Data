-- Continent shapefile

DROP TABLE IF EXISTS temp_quicc.stm_countries_shapes;
CREATE TABLE temp_quicc.stm_countries_shapes AS
    SELECT region, geom FROM(
    SELECT ST_Intersection(can_adm0.geom,envelope.env_plots) as geom, 'can' as region
    FROM map_world.can_adm0,
    (SELECT ST_Envelope(ST_Collect(stm_plots_id.coord_postgis)) as env_plots
    FROM rdb_quicc.stm_plots_id) as envelope

    UNION ALL

    SELECT ST_Intersection(usa_adm0.geom,envelope.env_plots) as geom, 'usa' as region
    FROM map_world.usa_adm0,
    (SELECT ST_Envelope(ST_Collect(stm_plots_id.coord_postgis)) as env_plots
    FROM rdb_quicc.stm_plots_id) as envelope
) as us_can_geometry;

CREATE INDEX idx_countries_shapes_gist
  ON temp_quicc.stm_countries_shapes USING gist(geom);

SELECT populate_geometry_columns('temp_quicc.stm_countries_shapes'::regclass);

-- Lakes shapefile

DROP TABLE IF EXISTS temp_quicc.stm_lakes_shapes;
CREATE TABLE temp_quicc.stm_lakes_shapes AS
    SELECT region, ST_Multi(geom) as geom FROM(
    SELECT ST_Intersection(can_water_areas_dcw.geom,envelope.env_plots) as geom,
    'can' :: varchar(4) as region
    FROM map_world.can_water_areas_dcw,
    (SELECT ST_Envelope(ST_Collect(stm_plots_id.coord_postgis)) as env_plots
    FROM rdb_quicc.stm_plots_id) as envelope
    WHERE area >= 0.005

    UNION ALL

    SELECT geom, region FROM(
    SELECT ST_Intersection(usa_water_areas_dcw.geom,envelope.env_plots) as geom,
    'usa' :: varchar(4) as region,
    ST_Area(ST_Intersection(usa_water_areas_dcw.geom,envelope.env_plots))
    FROM map_world.usa_water_areas_dcw,
    (SELECT ST_Envelope(ST_Collect(stm_plots_id.coord_postgis)) as env_plots
    FROM rdb_quicc.stm_plots_id) as envelope) as surf
    WHERE st_area >= 0.005
    ) as us_can_geometry
    WHERE ST_IsEmpty(geom) = False;

CREATE INDEX idx_lakes_shapes_gist
  ON temp_quicc.stm_lakes_shapes USING gist(geom);

SELECT populate_geometry_columns('temp_quicc.stm_lakes_shapes'::regclass);
