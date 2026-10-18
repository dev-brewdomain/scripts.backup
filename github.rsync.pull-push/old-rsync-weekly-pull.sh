#!/bin/bash
rsync -varzP -e "ssh -i /home/auston01/.ssh/id_ed25519" auston@ssh.brewdomain.org:{/var/www/,/etc/nginx,/home/auston/nginx.files} /mnt/SUPRAIDZ0.NFS/Webserver.Backups.2026
cd /mnt/SUPRAIDZ0.NFS/Webserver.Backups.2026/
chmod -R 755 /mnt/SUPRAIDZ0.NFS/Webserver.Backups.2026
exit 0
