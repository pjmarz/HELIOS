# System Configuration
export TZ="America/New_York"
export PUID=1000
export PGID=984

# Base Directories
export LOAS="/mnt"
export MOVIES_DIR="${LOAS}/media/movies"
export TV_DIR="${LOAS}/media/tv"
export DOWNLOADS_DIR="${LOAS}/usenet"

# Service Ports
export OVERSEERR_PORT=5055
export RADARR_PORT=7878
export SONARR_PORT=8989
export BAZARR_PORT=6767
export PROWLARR_PORT=9696
export SABNZBD_PORT=8080
export N8N_PORT=5678
export PORTAINER_SSL_PORT=9443
export PORTAINER_PORT=8000
export HOMARR_PORT=7575
export TAUTULLI_PORT=8181
export FLARESOLVERR_PORT=8191

# n8n Configuration
export N8N_HOST="n8n.welcometomarz.net"
export N8N_PROTOCOL="https"
export N8N_WEBHOOK_TUNNEL_URL="https://n8n.welcometomarz.net"

# Plex Configuration
export PLEX_URL="http://192.168.1.47:32400"

# Source sensitive credentials
source .secrets
