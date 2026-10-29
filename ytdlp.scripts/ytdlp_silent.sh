#!/bin/bash

# ==========================================
# CONFIGURATION
# ==========================================
INPUT_FILE="/home/auston01/Documents/ytdlp.scripts/ytdlp.txt"
DOWNLOAD_DIR="/mnt/SUPRAIDZ0.NFS/YT.Archive/"
EMAIL=""

# LOG FILE CONFIGURATION
LOG_FILE="$DOWNLOAD_DIR/download_errors.log"

# VIDEO QUALITY CONFIGURATION
# Example: Best quality but capped at 1080p resolution
QUALITY="-f bestvideo[height<=1080]+bestaudio/best[height<=1080]"

# OUTPUT/PLAYLIST TEMPLATE CONFIGURATION
# Creates a subfolder matching the playlist title if the URL is a playlist
OUTPUT_TEMPLATE="-o %(playlist_title)s/%(title)s.%(ext)s"

# BANDWIDTH & RATE LIMIT CONFIGURATION
# Examples: "50K", "4.2M", "0" (for unlimited)
RATE_LIMIT="5M"

# SLEEP INTERVAL CONFIGURATION (in seconds)
# Minimum sleep time before starting the next download/video
SLEEP_INTERVAL="35"

# Cookies from browser FIREFOX
BROWSER_COOKIES="firefox"

# Impersonate Browser FIREFOX
BROWSER_IMPER="firefox"

# Create the directory if it doesn't exist
mkdir -p "$DOWNLOAD_DIR"

# Check if input file exists
if [ ! -f "$INPUT_FILE" ]; then
    ERROR_MSG="[$(date '+%Y-%m-%d %H:%M:%S')] Error: Input file '$INPUT_FILE' not found."
    echo "$ERROR_MSG" >> "$LOG_FILE"
    echo "$ERROR_MSG" | mail -s "yt-dlp: Batch Download Failed" "$EMAIL"
    exit 1
fi

# ==========================================
# EXECUTION
# ==========================================
SUCCESS_COUNT=0
FAILURE_COUNT=0
ERROR_SUMMARY=""

# Read the file line by line, ignoring empty lines and comments (#)
while IFS= read -r URL || [ -n "$URL" ]; do
    # Skip empty lines or lines starting with #
    [[ -z "$URL" || "$URL" =~ ^[[:space:]]*# ]] && continue

    # Trim whitespace
    URL=$(echo "$URL" | xargs)

     # Run yt-dlp quietly, passing all performance, destination, and quality options
    ERROR_LOG=$(ytdlp -q $QUALITY \
                        --paths "$DOWNLOAD_DIR" \
                        $OUTPUT_TEMPLATE \
                        --rate-limit "$RATE_LIMIT" \
                        --sleep-interval "$SLEEP_INTERVAL" \
			--cookies-from-browser "$BROWSER_COOKIES" \
			--impersonate "$BROWSER_IMPER" \
                        "$URL" 2>&1)
    if [ $? -eq 0 ]; then
        ((SUCCESS_COUNT++))
    else
        ((FAILURE_COUNT++))
        
        # Format the log entry with a fresh timestamp
        TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
        LOG_ENTRY="[$TIMESTAMP] URL: $URL"$'\n'"Error: $ERROR_LOG"$'\n'"------------------------"
        
        # 1. Append to the email summary variable
        ERROR_SUMMARY+=$'\n'"$LOG_ENTRY"
        
        # 2. Append directly to the local log file
        echo "$LOG_ENTRY" >> "$LOG_FILE"
    fi
done < "$INPUT_FILE"

# ==========================================
# EMAIL REPORTING
# ==========================================
EMAIL_BODY="Batch download process completed.

Summary:
- Successfully downloaded: $SUCCESS_COUNT
- Failed: $FAILURE_COUNT
- Destination: $DOWNLOAD_DIR
- Local Log File: $LOG_FILE"

if [ $FAILURE_COUNT -gt 0 ]; then
    SUBJECT="yt-dlp: Batch Completed with $FAILURE_COUNT Errors"
    EMAIL_BODY+=$'\n\nDetailed Error Log:\n'"$ERROR_SUMMARY"
    # Output alert to console standard error
    echo "Errors detected. Details written to: $LOG_FILE" >&2
else
    SUBJECT="yt-dlp: Batch Completed Successfully"
fi

# Send the email
echo "$EMAIL_BODY" | mail -s "$SUBJECT" "$EMAIL"
