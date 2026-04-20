<div align="center">
  <a href="https://github.com/pjmarz/HELIOS">
    <img src="docs/media/HELIOS.gif" width="300" alt="HELIOS">
  </a>
</div>

---

> Note: This repository is a portfolio project demonstrating the HELIOS architecture and user experience. It is not a turnkey deployment and is not intended to be cloned or run as-is.

## 🎯 What is HELIOS?

HELIOS is a self-hosted media management and server administration system running as Docker containers inside a Proxmox VE virtual machine. It automates the full media lifecycle — request, indexing, download, post-processing, and streaming — while providing centralized dashboards for container and server operations.

This repository showcases the architecture and engineering around that system: modular Docker Compose orchestration, a shared Bash operational library, non-destructive image-update tooling with health checks, NVIDIA GPU passthrough for Plex transcoding, and file-based Docker Secrets management.

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
      <td rowspan="9"><b>🎬 Media Management</b></td>
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
      <td align="center"><img src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/overseerr.png" width="32" height="32" alt="Seerr"></td>
      <td><b><a href="https://github.com/seerr-team/seerr">Seerr</a></b></td>
      <td>Media Request & Discovery</td>
    </tr>
    <tr>
      <td align="center"><img src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/prowlarr.png" width="32" height="32" alt="Prowlarr"></td>
      <td><b><a href="https://github.com/Prowlarr/Prowlarr">Prowlarr</a></b></td>
      <td>Indexer Management</td>
    </tr>
    <tr>
      <td align="center"><img src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/recyclarr.png" width="32" height="32" alt="Recyclarr"></td>
      <td><b><a href="https://github.com/recyclarr/recyclarr">Recyclarr</a></b></td>
      <td>TRaSH Guide Sync</td>
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
      <td><b><a href="https://github.com/homarr-labs/homarr">Homarr</a></b></td>
      <td>Dashboard & Service Management</td>
    </tr>
    <tr>
      <td align="center"><img src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/flaresolverr.png" width="40" height="24" alt="FlareSolverr"></td>
      <td><b><a href="https://github.com/FlareSolverr/FlareSolverr">FlareSolverr</a></b></td>
      <td>Proxy & Anti-Bot Protection</td>
    </tr>
    <tr>
      <td rowspan="2"><b>🔧 Infrastructure</b></td>
      <td align="center"><img src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/proxmox.png" width="32" height="32" alt="Proxmox"></td>
      <td><b><a href="https://www.proxmox.com/en/products/proxmox-virtual-environment/overview">Proxmox VE</a></b></td>
      <td>Virtualization Platform</td>
    </tr>
    <tr>
      <td align="center"><img src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/docker.png" width="36" height="24" alt="Docker"></td>
      <td><b><a href="https://www.docker.com/">Docker</a></b></td>
      <td>Containerization Platform</td>
    </tr>
  </tbody>
</table>

## 🔄 How It Fits Together

The media stack forms a request-to-streaming pipeline:

1. **Seerr** — users browse and request content. Requests are routed to Radarr (movies) or Sonarr (TV).
2. **Prowlarr** — centralized indexer manager. Feeds indexers and API keys into Sonarr and Radarr so each *arr doesn't maintain its own.
3. **Radarr / Sonarr** — monitor requests, search Prowlarr-fed indexers, hand releases to SABnzbd, then import and rename finished files into the media libraries.
4. **SABnzbd** — Usenet client. Downloads into `/mnt/usenet/incomplete/`, moves to `/mnt/usenet/complete/` on success for *arr post-processing.
5. **Recyclarr** — runs weekly (`@weekly` cron). Syncs TRaSH Guide custom formats and quality profiles into Sonarr/Radarr so their release scoring stays current without manual tuning.
6. **Bazarr** — watches Sonarr/Radarr for imports, pulls subtitles from configured providers, writes them alongside the media files.
7. **Plex** — serves the finished libraries at `/mnt/media/movies` and `/mnt/media/tv`. Transcodes via NVIDIA GPU when clients can't direct-play.
8. **Plex Auto Languages** — watches Plex sessions and auto-sets audio and subtitle preferences per user based on their configured language.

Operational services run alongside the pipeline:

- **Homarr** — landing dashboard with service status, quick links, and live Docker integration
- **Portainer** (+ Agent) — container, image, network, and volume management over an isolated agent network
- **Tautulli** — Plex watch history, stats, and notifications
- **FlareSolverr** — Cloudflare bypass proxy used by Prowlarr for protected indexers

## 🧩 Architecture Notes

- **Modular Compose**: the root `docker-compose.yml` uses Compose v2 `include` to pull in `deployments/console/docker-compose.yml` and `deployments/media/docker-compose.yml`. Each sub-stack uses `x-common` YAML anchors for DRY service configuration (restart policy, PUID/PGID, TZ, UMASK).
- **3-network topology**:
  - `helios_proxy` — external access (Homarr, FlareSolverr, Tautulli)
  - `helios_console_agent_network` — isolated Portainer ↔ Agent channel
  - `helios_default` — main network for all media services
- **File-based Docker Secrets** stored at `/etc/HELIOS/secrets/` (symlinked into the repo). Keeps credentials out of env files and out of git.
- **Centralized environment**: `env.sh` is a symlink to `/etc/HELIOS/env.sh`, auto-loaded by direnv on `cd`. The `.env` consumed by Docker Compose is regenerated by `system-verify.sh`.
- **NVIDIA GPU passthrough** for Plex, paired with an inline 16 GB `plex_transcode` tmpfs volume — faster transcoding and auto-cleanup on container stop.
- **Docker socket integration** for Homarr with proper group permissions so the dashboard can surface live container state without running privileged.

## 🧰 What's in the Repo

The engineering surface lives in `scripts/` and the Compose files:

- **`scripts/_common.sh`** — shared Bash library sourced by every script. Provides `set -euo pipefail`, path and root detection, env sourcing, color logging, ERR/EXIT traps, and opt-out flags: `HELIOS_NO_ERREXIT=1` for scripts that need to continue past failures (e.g. `test-api-connectivity.sh`), and `HELIOS_START_MSG` for custom banners.
- **`scripts/docker-rebuild.sh`** — non-destructive image update. Never runs `compose down`; only `pull` + `up --remove-orphans`, so containers with unchanged images are left running. Features: `--dry-run`, `--skip-prune`, `--skip-health-check`, `--project-dir`; structured exit codes (`0` healthy / `1` partial / `2` complete failure); NVIDIA CDI spec regeneration after driver updates; Plex version drift detection against the PlexPass/public channel; `jq`-based post-update health check with severity assessment; up to 3 retry attempts for transient D-state failures.
- **`scripts/system-verify.sh`** — validates Docker/Compose availability, env vars, secrets file presence and `600` permissions, and external networks/volumes. Auto-generates `.env` from `env.sh` for Compose consumption.
- **`scripts/test-api-connectivity.sh`** — end-to-end API probes across all services using per-service tokens (Plex token, Homarr API key via `ApiKey` header, Portainer token via `X-API-Key` over HTTPS 9443).
- **`scripts/compose-up.sh` / `compose-down.sh` / `compose-refresh.sh`** — lifecycle scripts. `compose-refresh` delegates to the other two as subprocesses so each phase produces its own log file.
- **`scripts/media-clean.sh`** — purges Usenet `complete/` and `incomplete/` directories, cycling SABnzbd around the cleanup.

All scripts log dual-output to console and `logs/<script>.log`.

## 💾 Storage & Data Layout

```
/mnt                          # Base storage location (LOAS - Location Of All Storage)
├── media/                    # Media library root
│   ├── movies/               # Movie library (mounted to Radarr, Bazarr, Plex)
│   └── tv/                   # TV library (mounted to Sonarr, Bazarr, Plex)
└── usenet/                   # Download directory
    ├── complete/             # Completed downloads (processed by *arr services)
    └── incomplete/           # Active downloads (SABnzbd working directory)

/etc/HELIOS/                  # Centralized configuration root
├── config/                   # Service configuration directories
│   ├── seerr/                # Seerr configuration
│   ├── radarr/               # Radarr configuration
│   ├── sonarr/               # Sonarr configuration
│   ├── bazarr/               # Bazarr configuration
│   ├── prowlarr/             # Prowlarr configuration
│   ├── recyclarr/            # Recyclarr configuration
│   ├── sabnzbd/              # SABnzbd configuration
│   ├── plex/                 # Plex Media Server configuration
│   ├── plexautolanguages/    # Plex Auto Languages configuration
│   ├── tautulli/             # Tautulli configuration
│   ├── flaresolverr/         # FlareSolverr configuration
│   └── homarr/               # Homarr configuration
└── secrets/                  # Docker Secrets (symlinked from project root)
```

### Docker Named Volumes

- **`helios_portainer_data`** — Portainer settings and management data
- **`helios_homarr_data`** — Homarr dashboard data and application state
- **`plex_transcode`** — inline 16 GB tmpfs volume for Plex transcoding (RAM-backed, auto-cleanup on container stop)
- **`plex_downloads`** — disk-backed volume for Plex download staging (`/downloads` inside the container)

### File Ownership & Permissions

Follows LinuxServer.io conventions: PUID=1000, PGID=984, UMASK=002. Media libraries, config directories, and download directories are all owned `1000:984` with `755`; UMASK=002 makes new files group-writable for multi-user access.

## 📝 Changelog

Full version history in [CHANGELOG.md](CHANGELOG.md).

---

<div align="center">
  <img src="docs/media/sun.apng" alt="HELIOS" width="200" height="200">
</div>
