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
# Navigate to secondary dir
cd /mnt/SUPRAIDZ0.NFS/Scripts.bk || exit
# Add all changes in Dir
git add /mnt/SUPRAIDZ0.NFS/Scripts.bk/.
# Commit changes if needed
if ! git diff-index --quiet HEAD --; then
      git commit -m "Weekly automated backup: $(date +'%Y-%m-%d')"
      git push origin main
else
      echo "No changes to commit to Scripts.backup."
fi
###
