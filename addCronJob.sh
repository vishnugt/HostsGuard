#!/bin/bash

# Define the cron job to add
cron_job="*/10 * * * * /path/to/Block-Youtube-DNS/blockSites.sh"

# Get the current date and time
current_time=$(date "+%Y-%m-%d %H:%M:%S")

# Check if the cron job is already present
if crontab -l 2>/dev/null | grep -F "$cron_job" > /dev/null; then
    echo "$current_time - Cron job already exists: $cron_job"
else
    echo "$cron_job" | crontab -
    echo "$current_time - Cron job added: $cron_job"
fi


