# Changelog

All notable changes to the HELIOS project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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

### Fixed
- Resolved path references in operational scripts
- Fixed environment variable inconsistencies
- Standardized logging format across scripts

## [Unreleased]

### Added
- Root docker-compose.yml for centralized service orchestration
- Shared network configuration
- Common environment variables using YAML anchors
- `.env.example` file as reference for environment configuration

### Changed
- Reorganized project structure to follow industry best practices
- Moved Docker Compose files to dedicated `deployments` directory
- Separated services into `console` and `media` subdirectories
- Updated operational scripts to use the root docker-compose.yml
- Improved environment variable organization and documentation in env.sh

### Removed
- Eliminated redundant directory structure
- Removed unnecessary path nesting
- Cleaned up deprecated configuration approaches

## [1.0.0] - 2025-01-15

### Added
- Initial release
- Console Command Center functionality
- Media Management Center
- Automated container management via Watchtower
- Docker-based deployment 