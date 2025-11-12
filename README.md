<div align="center">
  <a href="https://github.com/pjmarz/HELIOS">
    <img src="docs/media/HELIOS.gif" width="300" alt="HELIOS">
  </a>
</div>

---

> Note: This repository is a showcase of the HELIOS architecture and user experience. It is not a turnkey deployment and is not intended to be cloned or run as-is.

## 🎯 Project Overview

HELIOS is a self-hosted media management and server administration system built with Docker and Docker Compose. The entire stack runs inside a virtual machine (VM) on Proxmox VE. The project aims to create a reliable, automated system for media collection, organization, and server management through containerized services.

## 🛠️ System Components

<table>
  <thead>
    <tr>
      <th>Category</th>
      <th colspan="2">Service</th>
      <th>Purpose</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td rowspan="8"><b>🎬 Media Management</b></td>
      <td align="center"><img src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/radarr.png" width="32" height="32" alt="Radarr"></td>
      <td><b><a href="https://github.com/Radarr/Radarr">Radarr</a></b></td>
      <td>Movie Collection & Downloads</td>
    </tr>
    <tr>
      <td align="center"><img src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/sonarr.png" width="32" height="32" alt="Sonarr"></td>
      <td><b><a href="https://github.com/Sonarr/Sonarr">Sonarr</a></b></td>
      <td>TV Series Collection & Downloads</td>
    </tr>
    <tr>
      <td align="center"><img src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/bazarr.png" width="32" height="32" alt="Bazarr"></td>
      <td><b><a href="https://github.com/morpheus65535/bazarr">Bazarr</a></b></td>
      <td>Subtitle Management</td>
    </tr>
    <tr>
      <td align="center"><img src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/overseerr.png" width="32" height="32" alt="Overseerr"></td>
      <td><b><a href="https://github.com/sct/overseerr">Overseerr</a></b></td>
      <td>Media Request & Discovery</td>
    </tr>
    <tr>
      <td align="center"><img src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/prowlarr.png" width="32" height="32" alt="Prowlarr"></td>
      <td><b><a href="https://github.com/Prowlarr/Prowlarr">Prowlarr</a></b></td>
      <td>Indexer Management</td>
    </tr>
    <tr>
      <td align="center"><img src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/sabnzbd.png" width="32" height="32" alt="SABnzbd"></td>
      <td><b><a href="https://github.com/sabnzbd/sabnzbd">SABnzbd</a></b></td>
      <td>Usenet Download Client</td>
    </tr>
    <tr>
      <td align="center"><img src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/plex.png" width="32" height="32" alt="Plex"></td>
      <td><b><a href="https://github.com/plexinc/pms-docker">Plex</a></b></td>
      <td>Media Server & Streaming</td>
    </tr>
    <tr>
      <td align="center"><img src="https://avatars.githubusercontent.com/u/19256051?v=4" width="32" height="32" alt="Plex Auto Languages"></td>
      <td><b><a href="https://github.com/RemiRigal/Plex-Auto-Languages">Plex Auto Languages</a></b></td>
      <td>Automated Language Management</td>
    </tr>
    <tr>
      <td rowspan="4"><b>📊 Server Management</b></td>
      <td align="center"><img src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/portainer.png" width="32" height="32" alt="Portainer"></td>
      <td><b><a href="https://github.com/portainer/portainer">Portainer</a></b></td>
      <td>Container Management</td>
    </tr>
    <tr>
      <td align="center"><img src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/tautulli.png" width="32" height="32" alt="Tautulli"></td>
      <td><b><a href="https://github.com/Tautulli/Tautulli">Tautulli</a></b></td>
      <td>Media Server Analytics</td>
    </tr>
    <tr>
      <td align="center"><img src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/homarr.png" width="40" height="24" alt="Homarr"></td>
      <td><b><a href="https://github.com/ajnart/homarr">Homarr</a></b></td>
      <td>Dashboard & Service Management</td>
    </tr>
    <tr>
      <td align="center"><img src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/flaresolverr.png" width="40" height="24" alt="FlareSolverr"></td>
      <td><b><a href="https://github.com/FlareSolverr/FlareSolverr">FlareSolverr</a></b></td>
      <td>Proxy & Anti-Bot Protection</td>
    </tr>
    <tr>
      <td rowspan="3"><b>🔧 Infrastructure</b></td>
      <td align="center"><img src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/proxmox.png" width="32" height="32" alt="Proxmox"></td>
      <td><b><a href="https://www.proxmox.com/en/">Proxmox VE</a></b></td>
      <td>Virtualization Platform (hosts HELIOS VM)</td>
    </tr>
    <tr>
      <td align="center"><img src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/docker.png" width="36" height="24" alt="Docker"></td>
      <td><b><a href="https://www.docker.com/">Docker</a></b></td>
      <td>Containerization Platform</td>
    </tr>
    <tr>
      <td align="center"><img src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/cloudflare.png" width="46" height="24" alt="Cloudflared"></td>
      <td><b><a href="https://github.com/cloudflare/cloudflared">Cloudflared</a></b></td>
      <td>Secure Remote Access</td>
    </tr>
  </tbody>
</table>

## ✅ Prerequisites (for reference only)

- **Docker**: Engine installed and running
- **Docker Compose v2 (with include support)**: `docker compose` CLI available
- **Proxmox VE**: Host virtualization platform (HELIOS runs inside a VM on Proxmox VE)

## 🔐 Secrets & Environment Configuration

### 🔄 Environment Variable Management

HELIOS uses **direnv** for automatic environment variable loading:

- **`.envrc`**: Automatically loads `.env` (for Docker Compose) and `env.sh` (for scripts)
- **direnv hook**: Configured in shell for seamless environment isolation
- **Automatic loading**: Environment variables load automatically when you `cd` into the project directory
- **Script compatibility**: Scripts still source `env.sh` explicitly for non-interactive execution (cron, etc.)

This ensures consistent environment variable access across interactive shells, scripts, and Docker Compose commands.

HELIOS uses a centralized architecture for managing environment files and secrets, following Docker best practices:

### Centralized Architecture

- **`/etc/HELIOS/env.sh`**: Centralized environment configuration file (actual file location)
  - **`env.sh`** in project root is a symlink pointing to `/etc/HELIOS/env.sh`
  - Excluded from git (tracked in `.gitignore`)
  - Contains environment variable exports for local development
  
- **`/etc/HELIOS/secrets/`**: Centralized secrets directory (actual directory location)
  - **`secrets/`** in project root is a symlink pointing to `/etc/HELIOS/secrets`
  - Excluded from git (tracked in `.gitignore`)
  - Contains sensitive credentials and keys managed via Docker Secrets

### Setting Up Secrets

Create the following files with secure permissions in `/etc/HELIOS/secrets/`:

```bash
mkdir -p /etc/HELIOS/secrets
printf "<YOUR_PLEX_TOKEN>\n" > /etc/HELIOS/secrets/plex_token.txt
printf "<32+ CHAR ENCRYPTION KEY>\n" > /etc/HELIOS/secrets/homarr_encryption_key.txt
printf "<YOUR_HOMARR_API_KEY>\n" > /etc/HELIOS/secrets/homarr_api_key.txt
printf "<YOUR_PORTAINER_ACCESS_TOKEN>\n" > /etc/HELIOS/secrets/portainer_api_token.txt
chmod 700 /etc/HELIOS/secrets
chmod 600 /etc/HELIOS/secrets/*
```

The symlinks in the project root (`env.sh` and `secrets/`) will automatically point to these centralized locations.

### Required Secrets

- **plex_token.txt**: used by `plexautolanguages`
- **homarr_encryption_key.txt**: recommended to secure Homarr data (if configured to use secrets)
- **homarr_api_key.txt**: Homarr API key for authenticated API requests (header `ApiKey`)
- **portainer_api_token.txt**: Portainer access token for API (`X-API-Key` over HTTPS 9443)

This centralized approach ensures consistent configuration management across the system and aligns with industry best practices for Docker-based deployments.

## 🚀 Quickstart (for reference only)

```bash
# 1) Verify environment and generate .env
./scripts/system-verify.sh

# 2) Start all services
./scripts/compose-up.sh

# 3) Stop services (optional)
./scripts/compose-down.sh
```

- Services are defined in the top-level `docker-compose.yml` which includes:
  - `deployments/console/docker-compose.yml`
  - `deployments/media/docker-compose.yml`

## 🧰 Scripts (for reference only)

Common operations (see `scripts/README.md` for full details):

```bash
./scripts/compose-up.sh      # Start all services
./scripts/compose-down.sh    # Stop all services
./scripts/compose-refresh.sh # Restart with prune
./scripts/docker-rebuild.sh  # Pull latest images and prune
./scripts/system-verify.sh   # Validate config & environment
./scripts/test-api-connectivity.sh # Verify API connectivity to all services (logs to logs/test-api-connectivity.log)
```

## 🧩 Architecture & Compose Includes

- Single project name: `helios`
- Optimized 3-network architecture:
  - `helios_proxy`: External access network (Homarr, FlareSolverr)
  - `helios_console_agent_network`: Management isolation (Portainer)
  - `helios_default`: Main application network (all media services)
- Secrets stored in `/etc/HELIOS/secrets/` (centralized location, symlinked from project root)
- Docker socket integration with proper group permissions for Homarr
- Uses Docker Compose "include" to orchestrate `console` and `media` stacks from the root

## 💾 Storage Configuration

HELIOS uses a centralized storage architecture optimized for media management and service configuration:

### Storage Architecture

The storage layout follows a hierarchical structure with clear separation between media content, configuration data, and temporary files:

```
/mnt                          # Base storage location (LOAS - Location Of All Storage)
├── media/                    # Media library root
│   ├── movies/               # Movie library (mounted to Radarr, Bazarr, Plex)
│   └── tv/                   # TV Shows library (mounted to Sonarr, Bazarr, Plex)
└── usenet/                   # Download directory
    ├── complete/             # Completed downloads (processed by *arr services)
    └── incomplete/           # Active downloads (SABnzbd working directory)

/etc/HELIOS/                  # Centralized configuration root
├── config/                   # Service configuration directories
│   ├── overseerr/           # Overseerr configuration
│   ├── radarr/              # Radarr configuration
│   ├── sonarr/              # Sonarr configuration
│   ├── bazarr/              # Bazarr configuration
│   ├── prowlarr/            # Prowlarr configuration
│   ├── sabnzbd/             # SABnzbd configuration
│   ├── plex/                # Plex Media Server configuration
│   ├── plexautolanguages/   # Plex Auto Languages configuration
│   ├── tautulli/            # Tautulli configuration
│   ├── flaresolverr/        # FlareSolverr configuration
│   └── homarr/              # Homarr configuration
│       ├── config/          # Homarr config files
│       └── imgs/            # Custom images/icons
└── secrets/                  # Docker Secrets (symlinked from project root)

/tmp/plex-transcode/          # Temporary Plex transcoding directory (RAM/SSD)
```

### Media Library Structure

- **Movies Directory** (`/mnt/media/movies`): 
  - Shared by Radarr (imports), Bazarr (subtitle management), and Plex (streaming)
  - Organized by Radarr's naming conventions
  
- **TV Shows Directory** (`/mnt/media/tv`):
  - Shared by Sonarr (imports), Bazarr (subtitle management), and Plex (streaming)
  - Organized by Sonarr's naming conventions

- **Downloads Directory** (`/mnt/usenet`):
  - `complete/`: Processed downloads ready for import by Radarr/Sonarr
  - `incomplete/`: Active downloads managed by SABnzbd
  - Shared access for automated post-processing workflows

### Configuration Storage

- **Centralized Config** (`/etc/HELIOS/config/`):
  - All service configurations stored in dedicated subdirectories
  - Maintains service isolation while enabling centralized management
  - Owned by `1000:984` (PUID:PGID) for consistent file permissions

### Docker Named Volumes

Persistent data for services that require Docker-managed storage:

- **`helios_portainer_data`**: Portainer settings, configurations, and management data
- **`helios_homarr_data`**: Homarr dashboard data and application state

### Temporary Storage

- **Plex Transcode Directory** (`/tmp/plex-transcode`):
  - Temporary storage for Plex transcoding operations
  - Typically mounted to fast storage (SSD) or RAM for optimal performance
  - Automatically cleaned by Plex after transcoding completes

### File Ownership & Permissions

All storage follows LinuxServer.io best practices:

- **Media Libraries**: Owned by `1000:984` with `755` permissions
- **Configuration Directories**: Owned by `1000:984` with `755` permissions
- **Download Directories**: Owned by `1000:984` with `755` permissions
- **UMASK**: Set to `002` for group-writable files (enables multi-user access)

This centralized approach ensures:
- Consistent file ownership across all services
- Simplified backup and maintenance operations
- Clear separation between media content and configuration data
- Efficient resource utilization within the Proxmox VM

## 💡 Implementation Details

### 📁 Configuration Directory Ownership

HELIOS follows LinuxServer.io best practices for configuration directory ownership:

- **Ownership**: `/etc/HELIOS/config` is owned by `1000:984` (matches container PUID/PGID)
- **Permissions**: All config directories use `755` permissions
- **Rationale**: Ensures container-created files have consistent ownership
- **Benefits**: Prevents permission issues, aligns with Docker ecosystem standards

The project implements:
- Containerized services using Docker and Docker Compose
- Docker Secrets for secure management of sensitive information
- Secure remote access through Cloudflare tunnels
- Centralized logging and monitoring
- Resource-efficient container orchestration
- Advanced Docker integration with Homarr dashboard (Docker socket access with proper permissions)
- Optimized network architecture with purpose-built isolation for different service roles

## 🔧 System Architecture

Key architectural features:
- Modular service configuration
- Automated service recovery
- Centralized management interface
- Secure network isolation
- Efficient resource allocation

## 🛠️ Maintenance

- Service orchestration (start/stop/refresh all containers)
- Automated container rebuilds with latest images
- Download directory cleanup and management
- Docker service maintenance and recovery
- Centralized logging and monitoring



---

<div align="center">
  <a href="https://youtu.be/Nw_cdqQHGA8?t=1">
    <img src="docs/media/GIR.gif" alt="HELIOS" width="120" height="120">
  </a>
  
  <p align="center">
    <sub><i> I'm gonna sing the doom song now </i></sub>
  </p>
</div>
