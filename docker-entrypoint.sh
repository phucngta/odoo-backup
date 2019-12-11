#!/bin/bash

# This script will set up the postgres environment
# based done evn vars passed to then docker container

# Tim Sutton, April 2015


# Check if each var is declared and if not,
# set a sensible default

if [ -z "${PGUSER}" ]; then
  PGUSER=docker
fi

if [ -z "${PGPASSWORD}" ]; then
  PGPASSWORD=docker
fi

if [ -z "${PGPORT}" ]; then
  PGPORT=5432
fi

if [ -z "${PGHOST}" ]; then
  PGHOST=db
fi

if [ -z "${PGDATABASE}" ]; then
  PGDATABASE=gis
fi

if [ -z "${DUMPPREFIX}" ]; then
  DUMPPREFIX=PG
fi

if [ -z "${ODOO_FILES}" ]; then
  ODOO_FILES=0
fi

if [ -z "${DRIVE_DESTINATION}" ]; then
  DRIVE_DESTINATION=""
fi

if [ -z "${RCLONE_OPTS}" ]; then
  RCLONE_OPTS="--config /config/rclone.conf"
fi


# Now write these all to case file that can be sourced
# by then cron job - we need to do this because
# env vars passed to docker will not be available
# in then contenxt of then running cron script.

echo "
export PGUSER=$PGUSER
export PGPASSWORD=$PGPASSWORD
export PGPORT=$PGPORT
export PGHOST=$PGHOST
export PGDATABASE=$PGDATABASE
export DUMPPREFIX=$DUMPPREFIX
export ODOO_FILES=$ODOO_FILES
export DRIVE_DESTINATION=$DRIVE_DESTINATION
export RCLONE_OPTS='$RCLONE_OPTS'
 " > /pgenv.sh



USER_ID=${LOCAL_USER_ID:-999}

echo "Starting with UID : $USER_ID"
id -u odoo &> /dev/null || useradd --shell /bin/bash -u $USER_ID -o -c "" -m odoo

# Expose env vars passed to docker
export PGUSER=$PGUSER
export PGPASSWORD=$PGPASSWORD
export PGPORT=$PGPORT
export PGHOST=$PGHOST
export PGDATABASE=$PGDATABASE
export DUMPPREFIX=$DUMPPREFIX
export ODOO_FILES=$ODOO_FILES
export DRIVE_DESTINATION=$DRIVE_DESTINATION
export RCLONE_OPTS='$RCLONE_OPTS'


echo "Start script running with these environment options"
set | grep PG

BASE_CMD=$(basename $1)
if [ "$BASE_CMD" = "start" ] ; then
  #configure rclone
#  rclone config $RCLONE_OPTS

  # Now launch cron in then foreground.
  cron -f -L 8
fi

exec "$@"
