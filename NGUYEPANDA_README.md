# nguyenpanda Overleaf Deployment Guide

This document captures the complete, step-by-step replication guide for the Overleaf Toolkit deployment tailored for the nguyenpanda environment.

## 1. Prerequisites & Initialization

Clone the Overleaf Toolkit and initialize the default configurations:

```bash
git clone https://github.com/overleaf/toolkit.git overleaf-toolkit
cd overleaf-toolkit
./bin/init
```

## 2. Custom Image Build (TeXLive Full)

To ensure persistence of the full LaTeX library across container restarts without re-downloading packages, a custom `Dockerfile` is used.

**Create `Dockerfile` in the toolkit root:**

```dockerfile
FROM sharelatex/sharelatex:6.2.2

# Upgrade and install full TeXLive scheme
RUN tlmgr update --self && \
    tlmgr install scheme-full && \
    tlmgr path add
```

**Patch Version Validation Script:**

Modify `lib/shared-functions.sh` to allow the `-full` suffix. Edit the regex check around line 18:

```bash
# In lib/shared-functions.sh in read_image_version()
if [[ ! "$IMAGE_VERSION" =~ ^([0-9]+)\.([0-9]+)\.([0-9])+(-RC[0-9]*)?(-with-texlive-full|-full)?$ ]]; then
```

**Update `config/version`:**

Edit `config/version` to use the newly built custom tag:

```text
6.2.2-full
```

**Build the custom image:**

```bash
docker build -t sharelatex/sharelatex:6.2.2-full .
```

## 3. Environment Variables & Core Configuration

### `config/overleaf.rc`

Modify the core configuration to bind to `127.0.0.1:9999` (for Cloudflare Tunneling) and disable sibling containers for the Community Edition.

```zsh
#### Overleaf RC ####

PROJECT_NAME=overleaf

OVERLEAF_DATA_PATH=data/overleaf
SERVER_PRO=false
OVERLEAF_LISTEN_IP=127.0.0.1
OVERLEAF_PORT=9999

# Sibling Containers
SIBLING_CONTAINERS_ENABLED=false
DOCKER_SOCKET_PATH=/var/run/docker.sock

# Mongo configuration
MONGO_ENABLED=true
MONGO_DATA_PATH=data/mongo
MONGO_IMAGE=mongo
MONGO_VERSION=8.0

# Redis configuration
REDIS_ENABLED=true
REDIS_DATA_PATH=data/redis
REDIS_IMAGE=redis:7.4
REDIS_AOF_PERSISTENCE=true

# Git-bridge configuration (Server Pro only)
GIT_BRIDGE_ENABLED=false
GIT_BRIDGE_DATA_PATH=data/git-bridge
NGINX_ENABLED=false
NGINX_CONFIG_PATH=config/nginx/nginx.conf
NGINX_HTTP_PORT=80
NGINX_HTTP_LISTEN_IP=127.0.1.1
NGINX_TLS_LISTEN_IP=127.0.1.1
TLS_PRIVATE_KEY_PATH=config/nginx/certs/overleaf_key.pem
TLS_CERTIFICATE_PATH=config/nginx/certs/overleaf_certificate.pem
TLS_PORT=443
```

*Note: `SIBLING_CONTAINERS_ENABLED` is explicitly set to `false` to disable sandboxing warnings for Community Edition.*

### `config/variables.env`

Apply the custom branding, proxy settings, and strictly formatted JSON footers. The header image URL includes a query parameter `?v=2` to bypass aggressive browser caching of redirects.

```zsh
OVERLEAF_APP_NAME="Overleaf | nguyenpanda"

ENABLED_LINKED_FILE_TYPES=project_file,project_output_file

# Enables Thumbnail generation using an external converter (pdftocairo by default)
ENABLE_CONVERSIONS=true

# Disables email confirmation requirement
EMAIL_CONFIRMATION_DISABLED=true
OVERLEAF_ALLOW_PUBLIC_REGISTRATION=false

# Secret generated at bin/init time
# If you clone directly this branch, must run `openssl rand -base64 32` and pass to <your-id-here> below
OVERLEAF_INVITE_TOKEN_SECRET=<your-id-here>

## Nginx
# NGINX_WORKER_PROCESSES=4
# NGINX_WORKER_CONNECTIONS=768

## Set for TLS via nginx-proxy
OVERLEAF_BEHIND_PROXY=true
OVERLEAF_SECURE_COOKIE=true

OVERLEAF_SITE_URL=https://overleaf.nguyenpanda.com
OVERLEAF_NAV_TITLE="Overleaf: nguyenpanda"
OVERLEAF_HEADER_IMAGE_URL="/header.png"
OVERLEAF_ADMIN_EMAIL="nguyenpanda@nguyenpanda.com"

OVERLEAF_LEFT_FOOTER='[{"text": "Hosted locally by nguyenpanda.com", "url": "https://nguyenpanda.com"}]'
OVERLEAF_RIGHT_FOOTER='[{"text": "System Administrator: nguyenpanda", "url": "mailto:nguyenpanda@nguyenpanda.com"}]'

################
## Server Pro ##
################

EXTERNAL_AUTH=none
```

## 4. UI & Brand Customization (Docker Compose Mods)

To serve the custom header image (`header.png`), an explicit read-only volume mount was added to `lib/docker-compose.base.yml`.

**In `lib/docker-compose.base.yml` under `sharelatex.volumes`:**

```yaml
services:
    sharelatex:
        volumes:
            - "${OVERLEAF_DATA_PATH}:${OVERLEAF_IN_CONTAINER_DATA_PATH}"
            - "${OVERLEAF_DATA_PATH}/header.png:/overleaf/services/web/public/header.png:ro"
```

Place your custom logo file at `data/overleaf/header.png`. Note that placing it directly inside `data/overleaf/` is required because `${OVERLEAF_DATA_PATH}` resolves to `data/overleaf`.

## 5. Operation Commands

To properly apply changes and start the server without data loss:

```bash
# Stop and remove containers (preserves data in mounted volumes)
./bin/docker-compose down

# Start containers in detached mode
./bin/up -d
```
