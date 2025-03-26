<div align="center">
  <a href="https://github.com/pjmarz/HELIOS">
    <img src="assets/images/HELIOS.gif" width="300" alt="HELIOS">
  </a>

  <p align="center">
    <img src="https://img.shields.io/badge/Status-Operational-brightgreen?style=for-the-badge" alt="Status"/>
    <img src="https://img.shields.io/badge/Docker-Powered-blue?style=for-the-badge&logo=docker" alt="Docker"/>
    <img src="https://img.shields.io/badge/Type-Self_Hosted-orange?style=for-the-badge" alt="Self-Hosted"/>
  </p>
</div>

---

## 🎯 Project Overview

HELIOS is a self-hosted media management and server administration system built on Proxmox VE using Docker containers. The project aims to create a reliable, automated system for media collection, organization, and server management through containerized services.

## 🛠️ System Components

<div align="center">
<table>
<thead>
  <tr>
    <th>Category</th>
    <th>Service</th>
    <th>Purpose</th>
  </tr>
</thead>
<tbody>
  <tr>
    <td rowspan="7"><b>🎬 Media Management</b></td>
    <td><img height="32" width="32" style="vertical-align: middle; margin-right: 4px;" src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/radarr.png"/> <b><a href="https://github.com/Radarr/Radarr">Radarr</a></b></td>
    <td>Movie Collection & Downloads</td>
  </tr>
  <tr>
    <td><img height="32" width="32" style="vertical-align: middle; margin-right: 4px;" src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/sonarr.png"/> <b><a href="https://github.com/Sonarr/Sonarr">Sonarr</a></b></td>
    <td>TV Series Collection & Downloads</td>
  </tr>
  <tr>
    <td><img height="32" width="32" style="vertical-align: middle; margin-right: 4px;" src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/bazarr.png"/> <b><a href="https://github.com/morpheus65535/bazarr">Bazarr</a></b></td>
    <td>Subtitle Management</td>
  </tr>
  <tr>
    <td><img height="32" width="32" style="vertical-align: middle; margin-right: 4px;" src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/overseerr.png"/> <b><a href="https://github.com/sct/overseerr">Overseerr</a></b></td>
    <td>Media Request & Discovery</td>
  </tr>
  <tr>
    <td><img height="32" width="32" style="vertical-align: middle; margin-right: 4px;" src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/prowlarr.png"/> <b><a href="https://github.com/Prowlarr/Prowlarr">Prowlarr</a></b></td>
    <td>Indexer Management</td>
  </tr>
  <tr>
    <td><img height="32" width="32" style="vertical-align: middle; margin-right: 4px;" src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/sabnzbd.png"/> <b><a href="https://github.com/sabnzbd/sabnzbd">SABnzbd</a></b></td>
    <td>Usenet Download Client</td>
  </tr>
  <tr>
    <td><img height="32" width="32" style="vertical-align: middle; margin-right: 4px;" src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/plex.png"/> <b><a href="https://github.com/RemiRigal/Plex-Auto-Languages">Plex Auto Languages</a></b></td>
    <td>Automated Language Management</td>
  </tr>
  <tr>
    <td rowspan="5"><b>📊 Server Management</b></td>
    <td><img height="32" width="32" style="vertical-align: middle; margin-right: 4px;" src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/portainer.png"/> <b><a href="https://github.com/portainer/portainer">Portainer</a></b></td>
    <td>Container Management</td>
  </tr>
  <tr>
    <td><img height="45" width="42" style="vertical-align: middle; margin-right: 4px;" src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/watchtower.png"/> <b><a href="https://github.com/containrrr/watchtower">Watchtower</a></b></td>
    <td>Automated Container Updates</td>
  </tr>
  <tr>
    <td><img height="32" width="32" style="vertical-align: middle; margin-right: 4px;" src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/tautulli.png"/> <b><a href="https://github.com/Tautulli/Tautulli">Tautulli</a></b></td>
    <td>Media Server Analytics</td>
  </tr>
  <tr>
    <td><img height="24" width="34" style="vertical-align: middle; margin-right: 4px;" src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/homarr.png"/> <b><a href="https://github.com/ajnart/homarr">Homarr</a></b></td>
    <td>Dashboard & Service Management</td>
  </tr>
  <tr>
    <td><img height="24" width="40" style="vertical-align: middle; margin-right: 4px;" src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/cloudflare.png"/> <b><a href="https://github.com/cloudflare/cloudflared">Cloudflared</a></b></td>
    <td>Secure Remote Access</td>
  </tr>
  <tr>
    <td rowspan="4"><b>🔧 Infrastructure</b></td>
    <td><img height="28" width="28" style="vertical-align: middle; margin-right: 4px;" src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/proxmox.png"/> <b><a href="https://www.proxmox.com/en/">Proxmox VE</a></b></td>
    <td>Virtualization Platform</td>
  </tr>
  <tr>
    <td><img height="20" width="28" style="vertical-align: middle; margin-right: 4px;" src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/docker.png"/> <b><a href="https://www.docker.com/">Docker</a></b></td>
    <td>Containerization Platform</td>
  </tr>
  <tr>
    <td><img height="20" width="40" style="vertical-align: middle; margin-right: 4px;" src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/n8n.png"/> <b><a href="https://n8n.io/">N8N</a></b></td>
    <td>Workflow Automation</td>
  </tr>
  <tr>
    <td><img height="20" width="32" style="vertical-align: middle; margin-right: 4px;" src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/flaresolverr.png"/> <b><a href="https://github.com/FlareSolverr/FlareSolverr">FlareSolverr</a></b></td>
    <td>Proxy & Anti-Bot Protection</td>
  </tr>
</tbody>
</table>
</div>

## 💡 Implementation Details

The project implements:
- Containerized services using Docker and Docker Compose
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
    <img src="assets/images/GIR.gif" alt="HELIOS" width="120" height="120">
  </a>
  
  <p align="center">
    <sub><i> I'm gonna sing the doom song now </i></sub>
  </p>
</div>