FROM postgis/postgis:11-3.1
MAINTAINER asdrubal gonzalez <agpenton@gmail.com>
ARG P_ENV=""

ADD https://goo.gl/cvfonM /db/osm_shapefiles.sql.gz
RUN chmod 777 /db \
    && chmod 444 /db/osm_shapefiles.sql.gz
ADD postgresql.${P_ENV}.conf /etc/postgresql/postgresql.conf
ADD setup_osm.sql /db/setup_osm.sql
ADD setup_osm.sh /docker-entrypoint-initdb.d/00-setup_osm.sh
RUN chmod +x /docker-entrypoint-initdb.d/00-setup_osm.sh

# Optimise postgresql
RUN echo "kernel.shmmax=543252480" >> /etc/sysctl.conf
RUN echo "kernel.shmall=2097152" >> /etc/sysctl.conf

EXPOSE 5432
