#!/bin/bash
rsync -varzP -e "ssh -i /home/auston01/.ssh/id_ed25519" auston@45.32.89.196:{/var/www/,/etc/nginx,/nginx.files} /mnt/SUPRAIDZ0.NFS/Webserver.Backups.2026
cd /mnt/SUPRAIDZ0.NFS/Webserver.Backups.2026/
chmod -R 755 /mnt/SUPRAIDZ0.NFS/Webserver.Backups.2026
exit 0
