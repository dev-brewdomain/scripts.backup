#!/bin/bash

# --- Configuration ---
EMAIL="austonbrovitch@gmail.com"
HOSTNAME=$(hostname)
BACKUP_DIR="/mnt/SUPRAIDZ0.NFS/Webserver.Backups.2026"
REPORT=""

# Helper function to record and print messages
log_message() {
    echo -e "$1"
    REPORT+="$1\n"
}

log_message "=== Server Backup Report: $(date +'%Y-%m-%d %H:%M:%S') ==="
log_message "Host: $HOSTNAME\n"

# --- Run Rsync Backup ---
log_message "[1/3] Starting rsync transfer from remote server..."

# Capture both output and exit status of rsync
RSYNC_OUTPUT=$(rsync -varzP -e "ssh -i /home/auston01/.ssh/id_ed25519" auston@ssh.brewdomain.org:{/var/www/,/etc/nginx,/home/auston/nginx.files} "$BACKUP_DIR" 2>&1)
RSYNC_EXIT=$?

if [ $RSYNC_EXIT -eq 0 ]; then
    log_message "STATUS: Rsync completed successfully."
else
    log_message "ERROR: Rsync finished with errors or failed (Exit Code: $RSYNC_EXIT)."
fi

# Append details of the sync to the report log
log_message "\n--- Rsync Details ---"
log_message "$RSYNC_OUTPUT"
log_message "---------------------\n"

# --- Update Permissions ---
log_message "[2/3] Updating file permissions..."
if cd "$BACKUP_DIR"; then
    if chmod -R 755 "$BACKUP_DIR"; then
        log_message "STATUS: Permissions updated to 755 successfully."
    else
        log_message "ERROR: Failed to update permissions on some files."
    fi
else
    log_message "ERROR: Failed to navigate to backup directory $BACKUP_DIR"
fi

log_message ""
log_message "=== Backup Process Completed ==="

# --- Send Email Report ---
echo -e "$REPORT" | mail -s "Backup Report: $HOSTNAME ($(date +'%Y-%m-%d'))" "$EMAIL"

exit 0
