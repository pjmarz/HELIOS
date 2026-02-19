#!/bin/bash
# ===========================================================================
# HELIOS SHARED LIBRARY
# ===========================================================================
# Common boilerplate for all HELIOS scripts. Source from any script with:
#   source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_common.sh"
#
# Optional variables to set BEFORE sourcing:
#   HELIOS_NO_ERREXIT=1   — use set +e (for scripts that expect failures)
#   HELIOS_START_MSG="…"  — custom start banner text
# ===========================================================================

# --- Shell options ---
if [[ "${HELIOS_NO_ERREXIT:-}" == "1" ]]; then
    set +e
    set -o pipefail
else
    set -euo pipefail
fi

# --- Path detection ---
# HELIOS_ROOT: derived from this library's own location (scripts/_common.sh)
HELIOS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# SCRIPT_DIR: derived from the calling script ($0)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# --- Environment sourcing ---
_HELIOS_ENV_FILE="${HELIOS_ROOT}/env.sh"
if [ -f "$_HELIOS_ENV_FILE" ]; then
    source "$_HELIOS_ENV_FILE"
else
    echo "Environment file $_HELIOS_ENV_FILE not found. Exiting."
    exit 1
fi

# --- Logging setup ---
LOG_DIR="${HELIOS_ROOT}/logs"
LOG_FILE="${LOG_DIR}/$(basename "$0" .sh).log"
mkdir -p "$LOG_DIR"
: > "$LOG_FILE"

# --- Color constants ---
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# --- Logging functions ---
log() {
    local msg="$*"
    local timestamp
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo "${timestamp} - ${msg}" | tee -a "$LOG_FILE"
}

log_color() {
    local color="$1"
    local msg="$2"
    local timestamp
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo -e "${color}${timestamp} - ${msg}${NC}"
    echo "${timestamp} - ${msg}" >> "$LOG_FILE"
}

# --- Error handling ---
handle_error() {
    local exit_code=$?
    local line_number=$1
    log_color "$RED" "Error on line $line_number: Exit code $exit_code"
    exit $exit_code
}

if [[ "${HELIOS_NO_ERREXIT:-}" != "1" ]]; then
    trap 'handle_error $LINENO' ERR
fi

# --- Cleanup + EXIT trap ---
cleanup() {
    local exit_code=$?
    log "=== Script Complete (Exit Code: $exit_code) ==="
}

trap cleanup EXIT

# --- Start banner ---
log "=== ${HELIOS_START_MSG:-Script Start} ==="
