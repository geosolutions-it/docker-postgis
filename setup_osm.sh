#!/usr/bin/env bash

source /env-data.sh

su - postgres -c "${POSTGRES} -D ${DATADIR} -c config_file=${CONF} ${LOCALONLY} &"

# wait for postgres to come up
until su - postgres -c "psql -l"; do
	sleep 1
done
echo "postgres ready"

echo "Setting up OSM databases"
su - postgres -c "psql               \
--set=gs_role="${GS_PG_USER}"        \
--set=gs_pass="${GS_PG_PASSWORD}"        \
--set=imposm_db="${IMPOSM_DBNAME}"   \
--set=imposm_schema="${IMPOSM_DBSCHEMA_PRODUCTION}" \
--set=osm_shapefiles_db="${PG_OSM_SHAPEFILES_DB}"   \
--set=osm_shapefiles_schema="${PG_OSM_SHAPEFILES_SCHEMA}" \
--set=gwc_quota_db="${PG_GS_QUOTA_DB}"                    \
-f /docker-entrypoint-initdb.d/setup_osm.sql"

su - postgres -c "gunzip < /docker-entrypoint-initdb.d/osm_shapefiles.sql.gz | psql -U postgres -d ${PG_OSM_SHAPEFILES_DB}"

##TODO: Test Setup

# This should show up in docker logs afterwards
su - postgres -c "psql -l"

# Kill postgres
PID=`cat $PG_PID`
kill -TERM ${PID}

# Wait for background postgres main process to exit
while [ "$(ls -A ${PG_PID} 2>/dev/null)" ]; do
  sleep 1
done
