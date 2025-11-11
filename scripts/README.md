# HELIOS Scripts

This directory contains operational scripts for managing the HELIOS system.

## Naming Convention

Scripts follow a consistent prefix-based naming pattern:

- `compose-*.sh` - Docker Compose operations
- `docker-*.sh` - Docker engine management
- `media-*.sh` - Media management operations
- `system-*.sh` - System configuration and verification

## Script Overview

| Script | Description |
|--------|-------------|
| `compose-up.sh` | Starts all Docker Compose services using the root docker-compose.yml |
| `compose-down.sh` | Stops all Docker Compose services and prunes stopped containers |
| `compose-refresh.sh` | Refreshes all services by stopping and starting them with container pruning |
| `docker-rebuild.sh` | Rebuilds containers by pulling latest images and prunes unused images and containers |
| `docker-restart.sh` | Restarts the Docker service and all containers |
| `media-clean.sh` | Cleans up Usenet download directories and handles SABnzbd using direct Docker commands |
| `system-verify.sh` | Verifies environment configuration and Docker Compose setup with detailed logging |
| `test-api-connectivity.sh` | Tests API connectivity to all HELIOS services using secrets from ./secrets/

## Legacy Scripts (To Be Deprecated)

The following scripts are kept for backward compatibility and will be deprecated:

- `master-compose-up.sh` → use `compose-up.sh` instead
- `master-compose-down.sh` → use `compose-down.sh` instead
- `master-compose-refresh.sh` → use `compose-refresh.sh` instead
- `docker-container-rebuild.sh` → use `docker-rebuild.sh` instead
- `clean-usenet.sh` → use `media-clean.sh` instead
- `restart-docker.sh` → use `docker-restart.sh` instead
- `verify-config.sh` → use `system-verify.sh` instead

## Features

- **Automatic Path Detection**: Scripts use relative paths for portability
- **Environment Loading**: Automatically loads variables from env.sh with fallback paths
- **.env Generation**: Creates .env file for Docker Compose with proper secrets inclusion
- **Detailed Logging**: All operations are logged to the logs/ directory with timestamps
- **Error Handling**: Comprehensive error checking and reporting with standardized messages
- **Container Pruning**: Automatic clean-up of stopped containers and unused images
- **Consistent Formatting**: Standardized output and logging format across all scripts
- **Permissions Management**: Validates and ensures correct permissions for configuration directories
- **Symlink Validation**: Checks and repairs symbolic links for sensitive files
- **Self-Healing Configuration**: Automatically creates missing directories and repairs broken links

## Usage

All scripts are designed to be run from the command line:

```bash
./scripts/compose-up.sh    # Start all services
./scripts/compose-down.sh  # Stop all services
./scripts/system-verify.sh # Verify configuration
```

## Logs

All scripts generate logs in the `logs/` directory, named after the script (e.g., `compose-up.log`).

## Docker Resource Management

- `compose-down.sh` - Prunes stopped containers after stopping services
- `compose-refresh.sh` - Prunes stopped containers between down and up operations
- `docker-rebuild.sh` - Uses targeted pruning for both containers and images
- `media-clean.sh` - Uses direct Docker commands to reliably stop/start containers without conflicts

## Environment Management

- `.env` - Auto-generated from env.sh for Docker Compose with proper secrets
- `env.sh` - Centralized environment variables with export statements
- `/secrets/` - Directory containing Docker Secrets files for sensitive credentials

## Configuration Directory Standards

The system uses standardized permissions for service directories:
- Regular services: UID=1000, GID=984, with 755 directory permissions
- Data files: 644 permissions for database and configuration files