FROM golang:1.9.2-stretch
MAINTAINER federico.facca@martel-innovate.com

# RUN go get -u -v github.com/ncw/rclone
# RUN go clean
RUN apt-get update
RUN apt-get install -y cron postgresql-client-9.6 nano
RUN apt-get clean autoclean
RUN apt-get autoremove -y
RUN rm -rf /var/lib/{apt,dpkg,cache,log}/
RUN rm -rf /usr/local/go
RUN rm -rf /usr/local/go1.*.linux-amd64.tar.gz

USER root
WORKDIR /
RUN touch /var/log/cron.log
ADD db-backups.sh db-backups.sh
ADD file-backups.sh file-backups.sh
ADD clean.sh clean.sh
ADD clean_env.sh clean_env.sh
# ADD start.sh start.sh
# RUN chmod +x start.sh
RUN chmod +x file-backups.sh
RUN chmod +x db-backups.sh
RUN chmod +x clean.sh
RUN chmod +x clean_env.sh

COPY odoo-backup-cron /etc/cron.d/odoo-backup-cron
RUN chmod 0644 /etc/cron.d/odoo-backup-cron
RUN crontab /etc/cron.d/odoo-backup-cron
RUN sed -i '/session    required     pam_loginuid.so/c\#session    required     pam_loginuid.so' /etc/pam.d/cron

ENV ODOO_FILES 0
ENV DRIVE_DESTINATION ""
ENV RCLONE_OPTS="--config /config/rclone.conf"

COPY docker-entrypoint.sh /usr/bin/docker-entrypoint.sh
COPY restore /usr/bin/restore
RUN chmod +x /usr/bin/docker-entrypoint.sh
RUN chmod +x /usr/bin/restore

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["start"]
