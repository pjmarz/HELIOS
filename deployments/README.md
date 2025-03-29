# HELIOS Deployments

This directory contains all Docker Compose deployment configurations for the HELIOS system, organized by service type.

## Structure

- `console/` - Core system management and monitoring services
  - `docker-compose.yml` - Console services configuration
  - `config/` - Service-specific configuration files

- `media/` - Media management and download services
  - `docker-compose.yml` - Media services configuration
  - `config/` - Service-specific configuration files

## Usage

These deployments are designed to be orchestrated by the root `docker-compose.yml` file using Docker Compose's include feature. You generally shouldn't need to run them individually.

### Root Orchestration

```bash
# Using scripts (recommended)
./scripts/compose-up.sh      # Start all services
./scripts/compose-down.sh    # Stop all services and prune containers
./scripts/compose-refresh.sh # Refresh all services with pruning

# Direct Docker Compose commands
docker compose up -d  # Start all services
docker compose down   # Stop all services
```

### Individual Management (if needed)

```bash
# Navigate to specific deployment
cd deployments/console

# Start just the console services
docker compose up -d
```

## Docker Resource Management

### Volumes

- Volume names follow the format `helios_service_data` (e.g., `helios_portainer_data`)
- Volumes persist container data across restarts and rebuilds
- Volume management is handled through `docker-rebuild.sh` and other scripts
- Always use the correct volume names to prevent data loss

### Networks

- `helios_default` - Default network for services
- `helios_agent_network` - Dedicated network for Portainer agent communication
- Predefined networks ensure proper service discovery and isolation

## Configuration

Each deployment's `config/` directory contains configuration files that are mounted into the respective containers. These are mounted as volumes in the Docker Compose files.

## Adding New Services

When adding a new service:

1. Add it to the appropriate docker-compose.yml file
2. Create necessary configuration in the config/ directory
3. Ensure environment variables are defined in the root .env file
4. Define any required volumes with the proper naming convention
5. Test the deployment independently before integrating with the root docker-compose.yml 