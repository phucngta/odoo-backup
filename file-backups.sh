#!/bin/bash

source /pgenv.sh

#echo "Running with these environment options" >> /var/log/cron.log
#set | grep PG >> /var/log/cron.log

if [ $ODOO_FILES -eq 1 ]; then
  MYDATE=`date +%Y-%B-%d`
  MONTH=$(date +%B)
  YEAR=$(date +%Y)
  MYBASEDIR=/var/backup
  MYBACKUPDIR=${MYBASEDIR}/${YEAR}/${MONTH}
  mkdir -p ${MYBACKUPDIR}
  cd ${MYBACKUPDIR}
  FILENAME=${MYBACKUPDIR}/varlib.${MYDATE}.tar.gz

  echo "Backing up /var/lib/odoo"
  ACTION="Create $FILENAME in $MYBACKUPDIR"
  cp -R /var/lib/odoo /tmp/ && tar -zcf $FILENAME /tmp/odoo && rm -rf /tmp/odoo
  if [ $? -eq 0 ]; then
    echo "OK: " $ACTION " - " $(date)
  else
    echo "FAIL: " $ACTION " - " $(date)
  fi

  if [ -n "${DRIVE_DESTINATION}" ]; then
    ACTION="Copy $FILENAME to destination"
    /go/bin/rclone $RCLONE_OPTS copy $FILENAME $DRIVE_DESTINATION --retries 100 --retries-sleep 60s --user-agent "ISV|rclone.org|rclone/v1.42"
    if [ $? -eq 0 ]; then
      echo "OK: " $ACTION " - " $(date)
    else
      echo "FAIL: " $ACTION " - " $(date)
    fi
  else
    echo "DRIVE UPLOAD DISABLED"
  fi
else
  echo "ODOO FILES DISABLED"
fi