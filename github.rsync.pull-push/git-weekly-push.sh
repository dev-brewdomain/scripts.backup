#!/bin/bash

# Navigate to your repository folder
cd /mnt/SUPRAIDZ0.NFS/Webserver.Backups.2026 || exit

# Add all changes
git add /mnt/SUPRAIDZ0.NFS/Webserver.Backups.2026/.

# Commit only if there are uncommitted changes
if ! git diff-index --quiet HEAD --; then
    git commit -m "Weekly automated backup: $(date +'%Y-%m-%d')"
    git push origin main
else
    echo "No changes to commit."
fi
