# HELIOS Scripts

This directory contains operational scripts for managing the HELIOS system.

## Script Overview

| Script | Description |
|--------|-------------|
| `master-compose-up.sh` | Starts all Docker Compose services using the root docker-compose.yml |
| `master-compose-down.sh` | Stops all Docker Compose services |
| `master-compose-refresh.sh` | Refreshes all services by stopping and starting them |
| `docker-container-rebuild.sh` | Rebuilds all containers by pulling latest images and restarting them |
| `clean-usenet.sh` | Cleans up Usenet download directories and restarts SABnzbd |
| `restart-docker.sh` | Restarts the Docker service and all containers |

## Usage

All scripts are designed to be run from the command line:

```bash
./scripts/master-compose-up.sh    # Start all services
./scripts/master-compose-down.sh  # Stop all services
```

## Features

- **Automatic Path Detection**: Scripts use relative paths for portability
- **Environment Loading**: Automatically loads variables from env.sh
- **.env Generation**: Creates .env file for Docker Compose when needed
- **Detailed Logging**: All operations are logged to the logs/ directory
- **Error Handling**: Comprehensive error checking and reporting

## Logs

All scripts generate logs in the `logs/` directory, named after the script (e.g., `master-compose-up.log`).

## Adding New Scripts

When creating new scripts, follow these guidelines:

1. Use the same header and error handling structure as existing scripts
2. Get script and project paths dynamically using `SCRIPT_DIR` and `HELIOS_ROOT`
3. Source the environment variables from env.sh
4. Include proper logging and error handling
5. Add script documentation to this README 