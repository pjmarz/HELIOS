# Changelog

All notable changes to the HELIOS project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.7.0] - 2025-08-07

### Added
- Docs landing page updated with a Getting Started section and direct links to the README and Changelog

### Changed
- Upgraded dashboard to Homarr 1.0 (`ghcr.io/homarr-labs/homarr`) and adjusted persistent data paths
- Consolidated orchestration using a top-level Docker Compose that includes `deployments/console` and `deployments/media`
- Updated README with clearer setup, script usage, and secrets documentation

### Security
- Clarified Docker Secrets usage (`/secrets/plex_token.txt`, `/secrets/homarr_encryption_key.txt`) and recommended file permissions (600)

## [1.6.0] - 2024-04-26

### Changed
- Removed workflow automation services from HELIOS
- Updated environment variables in env.sh
- Updated system-verify.sh to remove workflow automation checks
- Streamlined service configuration

## [1.5.0] - 2024-04-14

### Changed
- Implemented Docker Secrets for secure management of sensitive information
- Added dedicated `/secrets/` directory with proper file permissions (600)
- Created secret files for Plex token and Homarr password
- Enhanced documentation with Docker Secrets usage information

### Removed
- Eliminated the use of .secrets file in favor of Docker Secrets
- Removed sensitive information from environment variables files

### Security
- Improved security by isolating sensitive credentials in Docker Secrets
- Implemented proper file permissions for secret files
- Reduced attack surface by removing sensitive data from environment files

## [1.4.0] - 2024-03-30

### Added
- Implemented Docker Secrets for secure management of sensitive information
- Added dedicated `/secrets/` directory with proper file permissions (600)
- Created secret files for Plex token and Homarr password
- Enhanced documentation with Docker Secrets usage information

### Changed
- Refactored docker-compose.yml to use Docker Secrets for sensitive data
- Updated services configurations to use secrets instead of environment variables
- Modified system-verify.sh to check and validate Docker Secrets configuration
- Updated README files to reflect the new security approach

### Removed
- Eliminated the use of .secrets file in favor of Docker Secrets
- Removed sensitive information from environment variables files

### Security
- Improved security by isolating sensitive credentials in Docker Secrets
- Implemented proper file permissions for secret files
- Reduced attack surface by removing sensitive data from environment files

## [1.3.0] - 2024-03-29

### Added
- Added config directory validation in `system-verify.sh` with auto-creation
- Implemented fallback paths for secrets file with multi-location detection
- Added symbolic link validation and auto-repair for `.secrets` file
- Enhanced .env generation with consistent secrets handling

### Changed
- Standardized permissions across service configuration directories (UID=1000, GID=984)
- Improved environment variable handling with more resilient sourcing
- Modified configuration paths to use `/etc/HELIOS/config` for all services
- Enhanced error detection and self-healing for common configuration issues

### Fixed
- Fixed inconsistent ownership across configuration directories
- Resolved potential permission issues with configuration files
- Standardized directory structure to follow best practices
- Improved security for sensitive configuration files

## [1.2.0] - 2024-03-29

### Added
- Added Tdarr for automated media transcoding and health checks with NVIDIA GPU support
- Added container pruning to `compose-down.sh`, `compose-refresh.sh`, and `docker-rebuild.sh` scripts
- Implemented proper logging in `system-verify.sh` for consistency with other scripts
- Enhanced media directory cleaning with improved error handling

### Changed
- Modified `media-clean.sh` to use direct Docker commands for more reliable container management
- Standardized error message format across all operational scripts
- Improved script logging with consistent timestamps and exit code reporting
- Refined Docker resource management strategy with targeted pruning

### Fixed
- Fixed container conflict issues in `media-clean.sh` by using container stop/start instead of remove/recreate
- Resolved inconsistent error handling across scripts
- Standardized script output format and logging conventions
- Removed unused Docker volumes from previous project naming

## [1.1.0] - 2024-03-28

### Added
- Improved documentation in README.md and deployment subdirectories
- Added README.md files to script and config directories
- Enhanced project structure visualization in main README

### Changed
- Reorganized project structure to improve maintainability
- Updated scripts to align with new directory structure
- Standardized environment variable management between env.sh and .env
- Refined Docker Compose configurations for better service orchestration
- Improved error handling in operational scripts
- Standardized Docker project naming to lowercase for compatibility with Docker's automatic name conversion

### Fixed
- Resolved path references in operational scripts
- Fixed environment variable inconsistencies
- Standardized logging format across scripts

## [1.0.0] - 2025-01-15

### Added
- Initial release
- Console Command Center functionality
- Media Management Center
- Automated container management via Watchtower
- Docker-based deployment 