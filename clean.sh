#!/bin/bash

source /pgenv.sh
source /clean_env.sh

#echo "Running with these environment options" >> /var/log/cron.log
#set | grep PG >> /var/log/cron.log

MONTH=$(date +%B --date='-1 month')
YEAR=$(date +%Y --date='-1 month')

MYBASEDIR=/var/backup
MYBACKUPDIR=${MYBASEDIR}/${YEAR}/${MONTH}
cd ${MYBACKUPDIR}

echo "Cleaning running to $MYBACKUPDIR"

#
# TODO:
# Loop through each pg database backing it up
# Loop through pgdump and filestore
#

  ACTION="Clean $MYBACKUPDIR in /backup"
  (ls -t|head -n ${NUMBER_KEEPED_BACKUPS_LAST_MONTH};ls)|sort|uniq -u|xargs rm
  if [ $? -eq 0 ]; then
     echo "OK: " $ACTION " - " $(date)
  else
     echo "FAIL: " $ACTION " - " $(date)
  fi

######## Clean Backup On Current Month ########
CURRENT_MONTH=$(date +%B)
CURRENT_YEAR=$(date +%Y)
CURRENT_BACKUPDIR=${MYBASEDIR}/${CURRENT_YEAR}/${CURRENT_MONTH}

cd ${CURRENT_BACKUPDIR}

echo "Cleaning running to $CURRENT_BACKUPDIR"

    ACTION="Clean $CURRENT_BACKUPDIR in /backup"
    (ls -t|head -n ${NUMBER_KEEPED_BACKUPS_CURRENT_YEAR};ls)|sort|uniq -u|xargs rm
    if [ $? -eq 0 ]; then
     echo "OK: " $ACTION " - " $(date)
    else
     echo "FAIL: " $ACTION " - " $(date)
    fi
