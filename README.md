<div align="center">
  <a href="https://github.com/pjmarz/HELIOS">
    <img src="assets/media/HELIOS.gif" width="300" alt="HELIOS">
  </a>
</div>

---

## 🎯 Project Overview

HELIOS is a self-hosted media management and server administration system built with Docker and Docker Compose ontop of Proxmox VE. The project aims to create a reliable, automated system for media collection, organization, and server management through containerized services.

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
      <td align="center"><img src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/tdarr.png" width="32" height="32" alt="Tdarr"></td>
      <td><b><a href="https://github.com/HaveAGitGat/Tdarr">Tdarr</a></b></td>
      <td>Media Transcoding & Health Check</td>
    </tr>
    <tr>
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
      <td><b><a href="https://github.com/RemiRigal/Plex-Auto-Languages">Plex Auto Languages</a></b></td>
      <td>Automated Language Management</td>
    </tr>
    <tr>
      <td rowspan="5"><b>📊 Server Management</b></td>
      <td align="center"><img src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/portainer.png" width="32" height="32" alt="Portainer"></td>
      <td><b><a href="https://github.com/portainer/portainer">Portainer</a></b></td>
      <td>Container Management</td>
    </tr>
    <tr>
      <td align="center"><img src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/watchtower.png" width="36" height="40" alt="Watchtower"></td>
      <td><b><a href="https://github.com/containrrr/watchtower">Watchtower</a></b></td>
      <td>Automated Container Updates</td>
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
      <td align="center"><img src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/cloudflare.png" width="46" height="24" alt="Cloudflared"></td>
      <td><b><a href="https://github.com/cloudflare/cloudflared">Cloudflared</a></b></td>
      <td>Secure Remote Access</td>
    </tr>
    <tr>
      <td rowspan="4"><b>🔧 Infrastructure</b></td>
      <td align="center"><img src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/proxmox.png" width="32" height="32" alt="Proxmox"></td>
      <td><b><a href="https://www.proxmox.com/en/">Proxmox VE</a></b></td>
      <td>Virtualization Platform</td>
    </tr>
    <tr>
      <td align="center"><img src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/docker.png" width="36" height="24" alt="Docker"></td>
      <td><b><a href="https://www.docker.com/">Docker</a></b></td>
      <td>Containerization Platform</td>
    </tr>
    <tr>
      <td align="center"><img src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/flaresolverr.png" width="40" height="24" alt="FlareSolverr"></td>
      <td><b><a href="https://github.com/FlareSolverr/FlareSolverr">FlareSolverr</a></b></td>
      <td>Proxy & Anti-Bot Protection</td>
    </tr>
  </tbody>
</table>

## 💡 Implementation Details

The project implements:
- Containerized services using Docker and Docker Compose
- Docker Secrets for secure management of sensitive information
- Automated container updates and maintenance
- Secure remote access through Cloudflare tunnels
- Centralized logging and monitoring
- Resource-efficient container orchestration

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
- Automated container updates via Watchtower
- Centralized logging and monitoring



---

<div align="center">
  <a href="https://youtu.be/Nw_cdqQHGA8?t=1">
    <img src="assets/media/GIR.gif" alt="HELIOS" width="120" height="120">
  </a>
  
  <p align="center">
    <sub><i> I'm gonna sing the doom song now </i></sub>
  </p>
</div>