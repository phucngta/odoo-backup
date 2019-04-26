#!/bin/bash

source /pgenv.sh

#echo "Running with these environment options" >> /var/log/cron.log
#set | grep PG >> /var/log/cron.log

MYDATE=`date +%Y-%B-%d-%H`
MONTH=$(date +%B)
YEAR=$(date +%Y)
MYBASEDIR=/var/backup
MYBACKUPDIR=${MYBASEDIR}/${YEAR}/${MONTH}
mkdir -p ${MYBACKUPDIR}
cd ${MYBACKUPDIR}

echo "Backup running to $MYBACKUPDIR"

#
# Loop through each pg database backing it up
#

DBLIST=`psql -l | awk '{print $1}' | grep -v "+" | grep -v "Name" | grep -v "List" | grep -v "(" | grep -v "template" | grep -v "postgres" | grep -v "|" | grep -v ":"`

# TODO: refactor this, only get DB_BACKUP in DBLIST
if [ ! -z ${DB_BACKUP} ]; then
  DBLIST=`psql -l | awk '{print $1}' | grep -v "+" | grep -v "Name" | grep -v "List" | grep -v "(" | grep -v "template" | grep -v "postgres" | grep -v "|" | grep -v ":" | grep -w "${DB_BACKUP}"`
fi

# echo "Databases to backup: ${DBLIST}" >> /var/log/cron.log
for DB in ${DBLIST}
do
  echo "Backing up $DB"
  FILENAME=${MYBACKUPDIR}/${DUMPPREFIX}_${DB}.${MYDATE}.tar
  ACTION="Create $FILENAME"
  pg_dump -Ft -C -f ${FILENAME} -O ${DB} && gzip -f ${FILENAME}
  if [ $? -eq 0 ]; then
     echo "OK: " $ACTION " - " $(date)
  else
     echo "FAIL: " $ACTION " - " $(date)
  fi
  if [ -n "${DRIVE_DESTINATION}" ]; then
    ACTION="Copy $FILENAME to destination"
    /go/bin/rclone copy $FILENAME.gz $DRIVE_DESTINATION --low-level-retries 100 --tpslimit 2 --user-agent "ISV|rclone.org|rclone/v1.42" $RCLONE_OPTS
    if [ $? -eq 0 ]; then
      echo "OK: " $ACTION " - " $(date)
    else
      echo "FAIL: " $ACTION " - " $(date)
    fi
  else
    echo "DRIVE UPLOAD DISABLED"
  fi
done
