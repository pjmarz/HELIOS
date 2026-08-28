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
#   NOTIFY_WEBHOOK="…"    — POST a one-line alert here when a script fails.
#                           Optional; unset means log-only (the default).
#                           Payload is {"content":"…"}, which Discord accepts
#                           directly, but any endpoint taking that shape works.
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

# --- Optional failure notification ---
# Scripts here are cron/ad-hoc driven, so a failure is usually discovered by
# noticing something is broken later. Setting NOTIFY_WEBHOOK turns a failure
# into a push instead. Deliberately fire-and-forget: a webhook that is slow,
# down, or misconfigured must never change the script's own exit code, and the
# URL is never written to the log.
notify_failure() {
    [[ -n "${NOTIFY_WEBHOOK:-}" ]] || return 0
    local msg="$1" payload
    payload=$(printf '%s' "$msg" | python3 -c \
        'import json,sys; print(json.dumps({"content": sys.stdin.read()[:1900]}))' 2>/dev/null) \
        || return 0
    curl -sS -m 10 -X POST -H 'Content-Type: application/json' \
        -d "$payload" "$NOTIFY_WEBHOOK" >/dev/null 2>&1 || true
}

# --- Error handling ---
handle_error() {
    local exit_code=$?
    local line_number=$1
    log_color "$RED" "Error on line $line_number: Exit code $exit_code"
    notify_failure "HELIOS: $(basename "$0") failed on line ${line_number} (exit ${exit_code}) on $(hostname)"
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
