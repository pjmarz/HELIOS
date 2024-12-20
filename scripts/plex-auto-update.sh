#!/bin/bash

# Define the Plex Docker container name directly
CONTAINER_NAME="plex"

# Define the logfile and Plex server details
LOG_FILE="/home/peter/Documents/dev/HELIOS/script_logs/plex-auto-update.log"
PLEX_URL="https://192.168.1.45:32400"

# Source the PLEX_TOKEN from environment
source /home/peter/Documents/dev/HELIOS/env.sh

# Clear the log file at the beginning of the script
> "$LOG_FILE"

# Function to prepend the current date and time to log messages
log() {
    local msg="$1"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo "${timestamp} - ${msg}" | tee -a "$LOG_FILE"
}

log "Starting Plex library update..."

# Define library sections with IDs and names
declare -A LIBRARY_SECTIONS
LIBRARY_SECTIONS=(
    [1]="TV Shows"
    [2]="Movies"
    [3]="Books"
)

# Function to poll Plex API until a library task completes
poll_for_completion() {
    local section_id=$1
    local task_type=$2
    local max_retries=12  # Poll for up to 12 minutes
    local retry=0
    local polling_interval=60  # Polling interval in seconds

    log "Polling for ${task_type} completion for section ID: ${section_id}..."
    while [[ $retry -lt $max_retries ]]; do
        sleep $polling_interval
        response=$(curl -s -k "${PLEX_URL}/library/sections/${section_id}" -H "X-Plex-Token: ${PLEX_TOKEN}")
        
        if [[ $? -eq 0 ]]; then
            local scanning=$(echo "$response" | grep -o 'scanning="[^"]*"' | cut -d'"' -f2)
            if [[ $scanning == "false" ]]; then
                log "${task_type} completed for section ID: ${section_id}."
                return 0
            fi
        else
            log "Error polling Plex API for section ID: ${section_id}. Response: $response"
        fi
        
        retry=$((retry + 1))
        log "Polling attempt $retry/${max_retries} for section ID: ${section_id}..."
    done

    log "${task_type} did not complete within the expected time for section ID: ${section_id}."
    return 1
}

# Function to update a single library section
update_library_section() {
    local section_id=$1
    local section_name=$2
    local response
    local retry=0
    local max_retries=3

    # Refresh library to scan new items
    log "Starting Plex library scan for section ${section_name} (ID: ${section_id})..."
    while [[ $retry -lt $max_retries ]]; do
        response=$(curl -k -s -X GET "${PLEX_URL}/library/sections/${section_id}/refresh" -H "X-Plex-Token: ${PLEX_TOKEN}")
        if [[ $? -eq 0 ]]; then
            break
        fi
        retry=$((retry + 1))
        sleep 10
    done
    if [[ $retry -eq $max_retries ]]; then
        log "Failed to scan library section ${section_name} (ID: ${section_id}) after ${max_retries} attempts."
        return 1
    fi

    poll_for_completion "$section_id" "library scan" || return 1

    # Refresh metadata for the library section
    log "Starting Plex metadata refresh for section ${section_name} (ID: ${section_id})..."
    retry=0
    while [[ $retry -lt $max_retries ]]; do
        response=$(curl -k -s -X GET "${PLEX_URL}/library/sections/${section_id}/refresh?force=1" -H "X-Plex-Token: ${PLEX_TOKEN}")
        if [[ $? -eq 0 ]]; then
            break
        fi
        retry=$((retry + 1))
        sleep 10
    done
    if [[ $retry -eq $max_retries ]]; then
        log "Failed to refresh metadata for section ${section_name} (ID: ${section_id}) after ${max_retries} attempts."
        return 1
    fi

    poll_for_completion "$section_id" "metadata refresh" || return 1

    # Analyze media in the library section
    log "Starting Plex media analysis for section ${section_name} (ID: ${section_id})..."
    retry=0
    while [[ $retry -lt $max_retries ]]; do
        response=$(curl -k -s -X PUT "${PLEX_URL}/library/sections/${section_id}/analyze" -H "X-Plex-Token: ${PLEX_TOKEN}")
        if [[ $? -eq 0 ]]; then
            break
        fi
        retry=$((retry + 1))
        sleep 10
    done
    if [[ $retry -eq $max_retries ]]; then
        log "Failed to analyze media for section ${section_name} (ID: ${section_id}) after ${max_retries} attempts."
        return 1
    fi

    poll_for_completion "$section_id" "media analysis" || return 1

    log "Library section ${section_name} (ID: ${section_id}) updated successfully."
}

# Iterate over each library section and update
for section_id in "${!LIBRARY_SECTIONS[@]}"; do
    update_library_section "$section_id" "${LIBRARY_SECTIONS[$section_id]}" || log "Update failed for section: ${LIBRARY_SECTIONS[$section_id]} (ID: $section_id)"
done

log "Plex library update tasks for all sections completed! Log file is located at $LOG_FILE"
