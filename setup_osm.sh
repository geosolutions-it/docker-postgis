#!/usr/bin/env bash

source /env-data.sh

su - postgres -c "${POSTGRES} -D ${DATADIR} -c config_file=${CONF} ${LOCALONLY} &"

# wait for postgres to come up
until su - postgres -c "psql -l"; do
	sleep 1
done
echo "postgres ready"

echo "setting up OSM databases"
su - postgres -c "psql               \
--set=gs_role="${GS_PG_USER}"        \
--set=gs_pass="${GS_PG_PASSWORD}"        \
--set=imposm_db="${IMPOSM_DBNAME}"   \
--set=imposm_schema="${IMPOSM_DBSCHEMA_PRODUCTION}" \
--set=osm_shapefiles_db="${PG_OSM_SHAPEFILES_DB}"   \
--set=osm_shapefiles_schema="${PG_OSM_SHAPEFILES_SCHEMA}" \
--set=gwc_quota_db="${PG_GS_QUOTA_DB}"                    \
-f /docker-entrypoint-initdb.d/setup_osm.sql"

echo "restoring OSM shapefiles DB"
su - postgres -c "gunzip < /docker-entrypoint-initdb.d/osm_shapefiles.sql.gz | psql -U postgres -d ${PG_OSM_SHAPEFILES_DB}"

# Check user exists
RESULT=`su - postgres -c "psql postgres -t -c \"SELECT 1 FROM pg_roles WHERE rolname = '${GS_PG_USER}'\""`
if [ -z "$RESULT" ]; then
  echo "DB initialization error, user ${GS_PG_USER} does not exist!"
  exit 1
fi

# Check DBs exists
RESULT=`su - postgres -c "psql -l | grep -w ${PG_OSM_SHAPEFILES_DB} | wc -l"`
if [ -z "$RESULT" ]; then
  echo "DB initialization error, database ${PG_OSM_SHAPEFILES_DB} does not exist!"
  exit 1
fi

# Check DBs exists
RESULT=`su - postgres -c "psql -l | grep -w ${IMPOSM_DBNAME} | wc -l"`
if [ -z "$RESULT" ]; then
  echo "DB initialization error, database ${IMPOSM_DBNAME} does not exist!"
  exit 1
fi

# This should show up in docker logs afterwards
su - postgres -c "psql -l"

# Kill postgres
PID=`cat $PG_PID`
kill -TERM ${PID}

# Wait for background postgres main process to exit
while [ "$(ls -A ${PG_PID} 2>/dev/null)" ]; do
  sleep 1
done
