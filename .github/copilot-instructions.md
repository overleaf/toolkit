# Overleaf Toolkit - AI Coding Assistant Instructions

## Architecture Overview

The Overleaf Toolkit is a Docker-based orchestration system for running Overleaf (collaborative LaTeX editor) locally. It manages multiple containers using Docker Compose:

- **Main Application**: `sharelatex` container (Community Edition) or `quay.io/sharelatex/sharelatex-pro` (Server Pro)
- **Databases**: MongoDB (data persistence) and Redis (caching)
- **Optional Services**: git-bridge (Git integration, Server Pro only), nginx (TLS proxy)

**Key Directories**:

- `bin/`: Executable scripts for all operations
- `config/`: User configuration files (ignored by git)
- `data/`: Persistent data (ignored by git)
- `lib/`: Internal toolkit files and Docker Compose configurations
- `doc/`: Comprehensive documentation

## Critical Developer Workflows

### Initialization & Setup

```bash
bin/init                    # Create config files from templates
bin/init --tls             # Add TLS proxy configuration
bin/up                     # Start all services (docker-compose up)
```

### Service Management

```bash
bin/start                  # Start services (detached)
bin/stop                   # Stop services
bin/shell                  # Get shell in main container
bin/docker-compose ps      # Check container status
```

### Debugging & Monitoring

```bash
bin/doctor                 # Comprehensive system diagnostic
bin/logs -f web clsi       # View logs from specific services
bin/logs -f                # View all service logs
```

### Version Management

```bash
bin/upgrade                # Upgrade to new Overleaf version
# Edit config/version to change version
# Run bin/docker-compose down && bin/up after config changes
```

## Configuration System

### Primary Config Files

- `config/overleaf.rc`: Service enablement, paths, ports
- `config/variables.env`: Application environment variables
- `config/version`: Docker image version tag

### Key Configuration Patterns

**Service Enablement**:

```bash
SERVER_PRO=true                    # Switch to Server Pro edition
SIBLING_CONTAINERS_ENABLED=true    # Sandboxed compiles (Server Pro only)
GIT_BRIDGE_ENABLED=true           # Git integration (Server Pro only)
NGINX_ENABLED=true               # TLS proxy
```

**Data Paths** (relative to toolkit root):

```bash
OVERLEAF_DATA_PATH=data/overleaf
MONGO_DATA_PATH=data/mongo
REDIS_DATA_PATH=data/redis
GIT_BRIDGE_DATA_PATH=data/git-bridge
```

**External Services**:

```bash
# Use existing MongoDB/Redis instead of containers
MONGO_ENABLED=false
MONGO_URL=mongodb://external-host:27017/overleaf
REDIS_HOST=external-redis-host
```

## Project-Specific Conventions

### Environment Variable Branding

- **Pre-v5.0**: `SHARELATEX_*` variables
- **v5.0+**: `OVERLEAF_*` variables
- **Migration**: Use `bin/rename-env-vars-5-0` and `bin/rename-rc-vars`

### Version-Specific Logic

- **v4.x**: ShareLaTeX branding, different container paths
- **v5.0+**: Overleaf branding, updated paths and features
- **Version Detection**: Parsed from `config/version` (format: `major.minor.patch`)

### Container Architecture

- **Main Container**: Monolithic app with microservices managed by `runit`
- **Internal Paths**: `/var/lib/overleaf/` (data), `/var/log/overleaf/` (logs)
- **Service Logs**: Available via `bin/logs <service-name>`

## Integration Points

### Storage Backends

```bash
# S3 Configuration (variables.env)
OVERLEAF_FILESTORE_BACKEND=s3
OVERLEAF_FILESTORE_S3_ACCESS_KEY_ID=...
OVERLEAF_FILESTORE_S3_SECRET_ACCESS_KEY=...
OVERLEAF_FILESTORE_USER_FILES_BUCKET_NAME=...
```

### Authentication

```bash
# LDAP (Server Pro, variables.env)
EXTERNAL_AUTH=ldap
OVERLEAF_LDAP_URL=ldap://...
OVERLEAF_LDAP_SEARCH_BASE=...
```

### Email Configuration

```bash
# SMTP (variables.env)
OVERLEAF_EMAIL_SMTP_HOST=smtp.example.com
OVERLEAF_EMAIL_SMTP_USER=...
OVERLEAF_EMAIL_SMTP_PASS=...
```

## Development Best Practices

### Configuration Changes

1. Edit files in `config/` directory
2. Run `bin/docker-compose down` to stop containers
3. Run `bin/up` to recreate with new config
4. Use `bin/doctor` to validate configuration

### Troubleshooting Protocol

1. Run `bin/doctor` for automated diagnostics
2. Check service-specific logs: `bin/logs -f <service>`
3. Verify Docker daemon: `docker ps`
4. Check configuration validity

### Security Considerations

- **Sibling Containers**: Required for user isolation in production
- **TLS Proxy**: Use for HTTPS in production environments
- **Docker Socket**: Only mount when `SIBLING_CONTAINERS_ENABLED=true`

## Common Patterns in Codebase

### Script Structure

- All `bin/` scripts detect toolkit root and source `lib/shared-functions.sh`
- Configuration loaded via `read_config()` and `read_variable()`
- Version parsing with regex: `^([0-9]+)\.([0-9]+)\.([0-9]+)`

### Docker Compose Architecture

- Modular YAML files in `lib/docker-compose.*.yml`
- Base configuration in `docker-compose.base.yml`
- Conditional includes based on `config/overleaf.rc` settings

### Error Handling

- Use `set -euo pipefail` in all scripts
- Check for existing config before initialization
- Validate version format and retracted versions

## Key Reference Files

- `lib/shared-functions.sh`: Core utility functions
- `lib/default.rc`: Default configuration values
- `bin/doctor`: Comprehensive diagnostic logic
- `doc/docker-compose.md`: Service architecture documentation
- `CHANGELOG.md`: Version-specific changes and migration notes
