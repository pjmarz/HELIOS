# Console Services Configuration

This directory contains configuration files for console management services. These configurations are mounted into the respective Docker containers as volumes.

## Service Configurations

### Portainer

- Configuration directory: `portainer/`
- Used for container management UI settings

### Homarr

- Configuration directories:
  - `homarr/config/` - Main configuration files
  - `homarr/icons/` - Custom icons
  - `homarr/imgs/` - Custom images

### Tautulli

- Configuration directory: `tautulli/`
- Used for Plex monitoring and statistics

### N8N

- Configuration directory: `n8n/`
- Used for workflow automation

## Configuration Management

### Adding New Configurations

1. Create a subdirectory for the service
2. Add configuration files
3. Update the docker-compose.yml to mount these configurations

### Backup Strategy

It's recommended to regularly back up this directory, as it contains critical configuration.

```bash
# Example backup command
tar -czf console-config-backup-$(date +%Y%m%d).tar.gz -C /path/to/deployments/console/config .
```

### Sensitive Data

**Important**: Do not store sensitive credentials in these configuration files directly. Use environment variables or the .secrets file.

## Default Configuration

Most services will generate their default configuration on first startup if the configuration directory is empty. 