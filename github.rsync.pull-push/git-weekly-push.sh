#!/bin/bash

# --- Configuration ---
EMAIL="austonbrovitch@gmail.com"
HOSTNAME=$(hostname)
REPORT=""

# Helper function to record and print messages
log_message() {
    echo -e "$1"
    REPORT+="$1\n"
}

log_message "=== Automated Backup Report: $(date +'%Y-%m-%d %H:%M:%S') ==="
log_message "Host: $HOSTNAME\n"

# --- Repo 1: Webserver.Backups.2026 ---
log_message "[1/2] Processing Webserver.Backups.2026..."
if cd /mnt/SUPRAIDZ0.NFS/Webserver.Backups.2026; then
    git add .
    if ! git diff-index --quiet HEAD --; then
        if git commit -m "Weekly automated backup: $(date +'%Y-%m-%d')" && git push origin main; then
            log_message "STATUS: Changes committed and pushed successfully."
        else
            log_message "ERROR: Git commit or push failed!"
        fi
    else
        log_message "STATUS: No changes to commit."
    fi
else
    log_message "ERROR: Failed to navigate to /mnt/SUPRAIDZ0.NFS/Webserver.Backups.2026"
fi

log_message ""

# --- Repo 2: Scripts.bk ---
log_message "[2/2] Processing Scripts.bk..."
if cd /mnt/SUPRAIDZ0.NFS/Scripts.bk; then
    git add .
    if ! git diff-index --quiet HEAD --; then
        if git commit -m "Weekly automated backup: $(date +'%Y-%m-%d')" && git push origin main; then
            log_message "STATUS: Changes committed and pushed successfully."
        else
            log_message "ERROR: Git commit or push failed!"
        fi
    else
        log_message "STATUS: No changes to commit."
    fi
else
    log_message "ERROR: Failed to navigate to /mnt/SUPRAIDZ0.NFS/Scripts.bk"
fi

log_message ""
log_message "=== Backup Completed ==="

# --- Send Email Report ---
echo -e "$REPORT" | mail -s "Backup Report: $HOSTNAME ($(date +'%Y-%m-%d'))" "$EMAIL"
