# Media Services Configuration

This directory contains configuration files for media management services. These configurations are mounted into the respective Docker containers as volumes.

## Service Configurations

### Radarr

- Configuration directory: `radarr/`
- Used for movie collection management

### Sonarr

- Configuration directory: `sonarr/`
- Used for TV series collection management

### Bazarr

- Configuration directory: `bazarr/`
- Used for subtitle management

### Overseerr

- Configuration directory: `overseerr/`
- Used for media requests and discovery

### Prowlarr

- Configuration directory: `prowlarr/`
- Used for indexer management

### SABnzbd

- Configuration directory: `sabnzbd/`
- Used for Usenet downloads

### Plex Auto Languages

- Configuration directory: `plexautolanguages/`
- Used for automated language management for Plex

## Configuration Management

### Adding New Configurations

1. Create a subdirectory for the service
2. Add configuration files
3. Update the docker-compose.yml to mount these configurations

### Backup Strategy

It's recommended to regularly back up this directory, as it contains critical configuration.

```bash
# Example backup command
tar -czf media-config-backup-$(date +%Y%m%d).tar.gz -C /path/to/deployments/media/config .
```

### Sensitive Data

**Important**: Do not store sensitive credentials in these configuration files directly. Use environment variables or the .secrets file.

## Default Configuration

Most services will generate their default configuration on first startup if the configuration directory is empty. 