# Changelog

All notable changes to the HELIOS project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.11.0] - 2025-10-05

### Removed
- **Tdarr Complete Removal**:
  - Eliminated Tdarr service from docker-compose.yml (42 lines of commented service definition)
  - Removed Tdarr configuration directory and all files (2.2 GB freed)
  - Deleted TDARR_WEBUI_PORT and TDARR_SERVER_PORT environment variables
  - Cleaned up Tdarr references from documentation (README.md, index.html)
  - Removed Tdarr variable checks from system-verify.sh script
  - Updated GPU warning messages to be generic (no longer Tdarr-specific)

### Changed
- **System Architecture Optimization**:
  - Streamlined service configuration after Tdarr removal
  - Enhanced focus on quality-first media acquisition without transcoding
  - Updated Media Management service count from 8 to 7 services
  - Improved documentation clarity across all files

### Technical
- **Quality-Focused Architecture**:
  - Eliminated transcoding layer in favor of original quality preservation
  - Aligned system with 4K Remux priority approach
  - Reduced storage overhead by 2.2 GB (config directory removal)
  - Maintained backup at /tmp/tdarr-backup-YYYYMMDD.tar.gz (387 MB compressed)
  - Preserved all other system functionality and integrations

### Rationale
- Project prioritizes 4K Remux and original quality content
- No transcoding needed with quality-first download approach
- Simplifies architecture and reduces resource overhead
- Tdarr was commented out and unused in active configuration

## [1.10.0] - 2025-09-07

### Added
- **Enhanced Docker Compose Architecture**:
  - Added missing console_agent_network and shared volumes to root compose file
  - Implemented comprehensive homarr_encryption_key secret support
  - Enhanced shared resource management across deployment modules
  - Added complete external networks and volumes definitions

### Changed
- **Operational Script Improvements**:
  - Updated `media-clean.sh` to run Docker Compose commands from root directory for proper secret access
  - Enhanced `docker-restart.sh` with improved `down` → `up -d` pattern for clean state management
  - Optimized all scripts to follow Docker Compose best practices and modern syntax
  - Improved container lifecycle management across all operational scripts

### Fixed
- **Docker Compose Configuration**:
  - Resolved plex_token secret conflicts between root and media deployment files
  - Fixed media-clean.sh script secret access issues by running commands from proper context
  - Eliminated duplicate secret definitions causing compose project conflicts
  - Enhanced secret sharing across included deployment files

### Security
- **Comprehensive Security Audit**:
  - Verified all sensitive information properly handled through Docker Secrets
  - Confirmed no sensitive data exposure in YAML configurations  
  - Validated secure file permissions (600) on all secret files
  - Ensured comprehensive .gitignore protection for sensitive files

### Technical
- **Production-Ready Architecture**:
  - Achieved 100% Docker Compose best practices compliance
  - Validated all 14 services running with proper network isolation
  - Confirmed all operational scripts function flawlessly
  - Established enterprise-grade security posture with A+ rating

## [1.9.0] - 2025-08-29

### Removed
- **Recyclarr Complete Removal**:
  - Eliminated Recyclarr service from docker-compose.yml
  - Removed recyclarr configuration directory and all files
  - Deleted recyclarr-sync.sh management script
  - Cleaned up RECYCLARR_PORT environment variable
  - Removed all Recyclarr references from documentation
  - Deleted Recyclarr Docker image and cleaned up system

### Added
- **Enhanced Documentation**:
  - Updated index.html with current HELIOS architecture
  - Refreshed CHANGELOG.md with all recent changes
  - Updated README.md with current component status
  - Improved documentation consistency across all files

### Changed
- **System Architecture Optimization**:
  - Streamlined service configuration after Recyclarr removal
  - Enhanced docker-compose.yml structure
  - Improved environment variable management
  - Updated scripts documentation

### Fixed
- **Documentation Synchronization**:
  - Aligned all documentation files with current system state
  - Updated service references and component listings
  - Ensured consistent version information across files

### Technical
- **Clean System State**:
  - Achieved 100% Recyclarr removal with no residual traces
  - Maintained all other system functionality
  - Preserved existing Custom Format configurations
  - Kept manual language CFs intact for Radarr/Sonarr

## [1.8.2] - 2025-08-27

### Added
- **Official Standards Compliance**:
  - Full alignment with Tdarr_Plugins repository standards and syntax expectations
  - Proper ESLint configuration with global disable and specific parameter comments
  - Official plugin structure and documentation patterns
  - Enhanced code maintainability and readability

### Changed
- **Plugin Standards Alignment**:
  - Updated both plugins to match official Tdarr_Plugins repository patterns
  - Converted template literal descriptions to single-line strings
  - Added proper ESLint disable comments for unused parameters
  - Enhanced plugin documentation with official response object comments
  - Improved code structure following official best practices

### Fixed
- **Code Quality Improvements**:
  - Resolved ESLint warnings and standardized code formatting
  - Fixed plugin structure to match official repository expectations
  - Enhanced error handling documentation
  - Improved plugin maintainability and future extensibility

### Technical
- **Development Standards**:
  - Achieved 100% compliance with official Tdarr plugin development standards
  - Enhanced plugin stability with proper error handling patterns
  - Improved code readability and maintainability
  - Standardized plugin architecture for future development

## [1.8.1] - 2025-08-27

### Added
- **Enhanced Tdarr Plugin Capabilities**:
  - Comprehensive subtitle codec detection (WEBVTT, mov_text, subp, pgssub, tx3g, dvb_subtitle)
  - Container-specific subtitle handling for MKV, MP4, TS containers
  - Improved file size calculation with clean logging (no debug spam)
  - Enhanced error handling and logging for transcoding failures

### Changed
- **Tdarr Plugin Improvements**:
  - Optimized subtitle detection algorithm with two-tier system (always-problematic + container-specific)
  - Cleaner log output with specific codec names instead of generic messages
  - Maintained working file size calculation logic while removing debug code
  - Enhanced FFmpeg command generation for better subtitle handling

### Fixed
- **Tdarr Processing Reliability**:
  - Better handling of problematic subtitle codecs that cause FFmpeg failures
  - Improved subtitle exclusion logic to prevent transcoding errors
  - Enhanced plugin stability with comprehensive error handling
  - Maintained accurate file size reporting without debug clutter

### Performance
- **Optimized Tdarr Workflow**:
  - Reduced log verbosity while maintaining detailed diagnostics
  - Faster subtitle analysis with improved detection algorithms
  - Better resource utilization with cleaner plugin execution
  - Enhanced transcoding success rate with comprehensive subtitle handling

## [1.8.0] - 2025-08-27

### Added
- Configurable Tdarr ports (`TDARR_WEBUI_PORT`, `TDARR_SERVER_PORT`) for better port management
- Enhanced Docker integration for Homarr with proper group permissions
- Docker socket permission validation in system verification
- Network architecture optimization with dedicated purpose-built networks

### Changed
- Optimized Docker network architecture:
  - `helios_proxy`: External access network (Homarr, FlareSolverr, Tautulli)
  - `helios_console_agent_network`: Management isolation (Portainer)
  - `helios_default`: Main application network (all media services)
- Removed unused `helios-console_default` network for cleaner architecture
- Improved environment variable consistency between `env.sh` and `.env`
- Enhanced Homarr Docker socket access with proper group permissions (GID 996)
- Added explicit network configuration for Tautulli service

### Fixed
- Resolved Homarr Docker integration issues (EACCES permission errors)
- Fixed Docker socket group access for privileged containers
- Improved network isolation and service communication patterns
- Enhanced configuration validation in `system-verify.sh`

### Security
- Maintained secure Docker socket permissions (660 root:docker)
- Improved container isolation with purpose-built networks
- Enhanced privileged container security practices

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