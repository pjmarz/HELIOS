HELIOS Docker Environment
Welcome to the HELIOS repository! This repository contains a Docker Compose setup to manage and deploy various services for a comprehensive server environment.

Services Included:
Portainer Agent:

Image: portainer/agent:latest
Role: Provides a way to manage Docker environments.
Portainer:

Image: portainer/portainer-ce:latest
Role: A lightweight management UI for Docker environments.
Watchtower:

Image: containrrr/watchtower:latest
Role: Automatically updates running Docker containers to the latest images.
Pi-hole:

Image: pihole/pihole:latest
Role: Network-wide ad blocking.
Homarr:

Image: ghcr.io/ajnart/homarr:latest
Role: A custom service (details to be added).
Whisparr:

Image: hotio/whisparr:latest
Role: A custom service (details to be added).
Prowlarr:

Image: lscr.io/linuxserver/prowlarr:latest
Role: Indexer manager for apps like Radarr, Sonarr, etc.
NZBGet:

Image: linuxserver/nzbget:latest
Role: Efficient Usenet downloader.
Plex:

Image: linuxserver/plex:latest
Role: Media server platform.
Getting Started:
Prerequisites:

Ensure you have Docker and Docker Compose installed on your machine.
NVIDIA runtime for Docker if you're planning to use GPU with Plex.
Deployment:

Clone this repository: git clone https://github.com/pjmarz/HELIOS.git
Navigate to the directory: cd HELIOS
Start the services: docker-compose up -d
Access Services:

Portainer: https://<your-server-ip>:9443
Pi-hole: http://<your-server-ip>:8081/admin
Homarr: http://<your-server-ip>:7575
... (Add other services as needed)
Environment Variables:

Ensure you have set the necessary environment variables like TZ, ROOT, MEDIA, CHARON, PUID, and PGID.
Contributing:
Feel free to submit issues or pull requests if you have suggestions or improvements for this setup.

Yes this was written with ChatGPT.