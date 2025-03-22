<div align="center">
  <h1>🌟 HELIOS 🌟</h1>

  <p align="center">
    <img src="https://img.shields.io/badge/Status-Operational-brightgreen?style=for-the-badge" alt="Status"/>
    <img src="https://img.shields.io/badge/Docker-Powered-blue?style=for-the-badge&logo=docker" alt="Docker"/>
    <img src="https://img.shields.io/badge/Type-Self_Hosted-orange?style=for-the-badge" alt="Self-Hosted"/>
  </p>
</div>

---

## 🎯 Project Overview

HELIOS is a sophisticated self-hosted solution that combines powerful server management capabilities with comprehensive media organization. Named after the Greek god of the sun, HELIOS illuminates your digital world by bringing order to chaos. Built on Proxmox VE, it leverages Docker containers for maximum flexibility and reliability.

### 💻 Console Command Center
The nerve center of your digital domain:
- 🔧 Powered by Portainer for seamless container management
- 🛡️ Secure remote access through Cloudflared tunnels
- 🔄 Automated updates via Watchtower
- 📊 Real-time monitoring with Tautulli and Homarr
- 🔮 Workflow automation using N8N

### 🎬 Media Management Center
Your personal entertainment hub:
- 🎥 Automated movie collection management with Radarr
- 📺 TV series automation through Sonarr
- 🗣️ Subtitle management with Bazarr
- 📝 Streamlined media requests through Overseerr
- 🔍 Advanced indexing with Prowlarr
- ⬇️ High-speed downloads via SABnzbd
- 🌐 Smart language handling with Plex Auto Languages

## 🛠️ Tech Stack

<div align="center">

<table>
<thead>
  <tr>
    <th>Category</th>
    <th>Technology</th>
    <th>Purpose</th>
  </tr>
</thead>
<tbody>
  <tr>
    <td rowspan="7"><b>🎬 Media Management</b></td>
    <td><img height="24" width="24" style="vertical-align: middle;" src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/radarr.png"/> <b><a href="https://github.com/Radarr/Radarr">Radarr</a></b></td>
    <td>Movie Collection & Downloads</td>
  </tr>
  <tr>
    <td><img height="24" width="24" style="vertical-align: middle;" src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/sonarr.png"/> <b><a href="https://github.com/Sonarr/Sonarr">Sonarr</a></b></td>
    <td>TV Series Collection & Downloads</td>
  </tr>
  <tr>
    <td><img height="24" width="24" style="vertical-align: middle;" src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/bazarr.png"/> <b><a href="https://github.com/morpheus65535/bazarr">Bazarr</a></b></td>
    <td>Subtitle Management</td>
  </tr>
  <tr>
    <td><img height="24" width="24" style="vertical-align: middle;" src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/overseerr.png"/> <b><a href="https://github.com/sct/overseerr">Overseerr</a></b></td>
    <td>Media Request & Discovery</td>
  </tr>
  <tr>
    <td><img height="24" width="24" style="vertical-align: middle;" src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/prowlarr.png"/> <b><a href="https://github.com/Prowlarr/Prowlarr">Prowlarr</a></b></td>
    <td>Indexer Management</td>
  </tr>
  <tr>
    <td><img height="24" width="24" style="vertical-align: middle;" src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/sabnzbd.png"/> <b><a href="https://github.com/sabnzbd/sabnzbd">SABnzbd</a></b></td>
    <td>Usenet Download Client</td>
  </tr>
  <tr>
    <td><img height="24" width="24" style="vertical-align: middle;" src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/plex.png"/> <b><a href="https://github.com/plex/plex-auto-languages">Plex Auto Languages</a></b></td>
    <td>Automated Language Management</td>
  </tr>
  <tr>
    <td rowspan="5"><b>📊 Monitoring & Management</b></td>
    <td><img height="24" width="24" style="vertical-align: middle;" src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/portainer.png"/> <b><a href="https://github.com/portainer/portainer">Portainer</a></b></td>
    <td>Container Management</td>
  </tr>
  <tr>
    <td><img height="24" width="24" style="vertical-align: middle;" src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/watchtower.png"/> <b><a href="https://github.com/containrrr/watchtower">Watchtower</a></b></td>
    <td>Automated Container Updates</td>
  </tr>
  <tr>
    <td><img height="24" width="24" style="vertical-align: middle;" src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/tautulli.png"/> <b><a href="https://github.com/Tautulli/Tautulli">Tautulli</a></b></td>
    <td>Media Server Analytics</td>
  </tr>
  <tr>
    <td><img height="24" width="24" style="vertical-align: middle;" src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/homarr.png"/> <b><a href="https://github.com/ajnart/homarr">Homarr</a></b></td>
    <td>Dashboard & Service Management</td>
  </tr>
  <tr>
    <td><img height="24" width="24" style="vertical-align: middle;" src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/cloudflare.png"/> <b><a href="https://github.com/cloudflare/cloudflared">Cloudflared</a></b></td>
    <td>Secure Remote Access Tunnel</td>
  </tr>
  <tr>
    <td rowspan="4"><b>🔧 Infrastructure</b></td>
    <td><img height="24" width="24" style="vertical-align: middle;" src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/proxmox.png"/> <b><a href="https://github.com/proxmox/proxmox-ve">Proxmox VE</a></b></td>
    <td>Virtualization Platform</td>
  </tr>
  <tr>
    <td><img height="24" width="24" style="vertical-align: middle;" src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/docker.png"/> <b><a href="https://github.com/docker/docker-ce">Docker</a></b></td>
    <td>Containerization Platform</td>
  </tr>
  <tr>
    <td><img height="24" width="24" style="vertical-align: middle;" src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/n8n.png"/> <b><a href="https://github.com/n8n-io/n8n">N8N</a></b></td>
    <td>Workflow Automation</td>
  </tr>
  <tr>
    <td><img height="24" width="24" style="vertical-align: middle;" src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/flaresolverr.png"/> <b><a href="https://github.com/FlareSolverr/FlareSolverr">FlareSolverr</a></b></td>
    <td>Proxy & Anti-Bot Protection</td>
  </tr>
</tbody>
</table>

</div>

## 💡 Key Features

- 🏗️ Modular Architecture
- 🔐 Security-First Design
- 🤖 Automated Management
- 📊 Intuitive Monitoring
- 🎯 Efficient Resource Utilization

## 🎨 Project Showcase

HELIOS demonstrates expertise in:
- 🔧 DevOps Practices
- 🐳 Container Orchestration
- 🔒 Security Implementation
- 🏗️ System Architecture
- 📊 Resource Management

---

<div align="center">
  <a href="https://github.com/pjmarz/HELIOS">
    <img src="assets/images/HELIOS.jpg" alt="HELIOS" width="320" height="320">
  </a>
  
  <p align="center">
    <sub>Built with passion and love ♥️</sub>
  </p>
</div>