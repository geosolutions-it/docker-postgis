CREATE ROLE :gs_role WITH LOGIN PASSWORD :'gs_pass';

-- OSM DB
CREATE DATABASE :imposm_db;
\c osm
CREATE EXTENSION postgis;

-- OSM Shapefiles DB
CREATE DATABASE :osm_shapefiles_db;
\c :osm_shapefiles_db
CREATE EXTENSION postgis;

-- GS Quota DB
CREATE DATABASE :gwc_quota_db WITH OWNER :gs_role;

GRANT CONNECT ON DATABASE :imposm_db TO :gs_role;
GRANT CONNECT ON DATABASE :osm_shapefiles_db TO :gs_role;
GRANT CONNECT ON DATABASE :gwc_quota_db TO :gs_role;

-- Allow SELECT by default to 'geoserver'
\c :imposm_db
ALTER DEFAULT PRIVILEGES GRANT SELECT ON TABLES TO :gs_role;

-- Allow SELECT by default to 'geoserver'
\c :osm_shapefiles_db
ALTER DEFAULT PRIVILEGES GRANT SELECT ON TABLES TO :gs_role;
