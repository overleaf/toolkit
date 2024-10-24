# Configuration: `overleaf.rc`

This document describes the variables that are supported in the `config/overleaf.rc` file.
This file consists of variable definitions in the form `NAME=value`. Lines beginning with `#` are treated as comments.

Note: we recommend that you re-create the docker containers after changing anything in `overleaf.rc` or `variables.env`, by running `bin/docker-compose down`, followed by `bin/up`

## Variables


### `PROJECT_NAME`

Sets the value of the `--project-name` flag supplied to `docker-compose`.
This is useful when running multiple instances of Overleaf on one host, as each instance can have a different project name.

- Default: overleaf


### `OVERLEAF_DATA_PATH`

Sets the path to the directory that will be mounted into the main `sharelatex` container, and used to store project and compile data. This can be either a full path (beginning with a `/`), or relative to the base directory of the toolkit.

- Default: data/sharelatex

### `OVERLEAF_LOG_PATH`

Sets the path to the directory that will be mounted into the main `sharelatex` container, and used for making application logs available on the Docker host. This can be either a full path (beginning with a `/`), or relative to the base directory of the toolkit.

Remove the config entry to disable the bind-mount. When not set, logs will be discarded when recreating the container.

- Default: not set

### `OVERLEAF_LISTEN_IP`

Sets the host IP address(es) that the container will bind to. For example, if this is set to `0.0.0.0`, then the web interface will be available on any host IP address.

Since https://github.com/overleaf/toolkit/pull/77 the listen mode of the application container was changed to `localhost` only, so the value of `OVERLEAF_LISTEN_IP` must be set to the public IP address for direct container access.

Setting `OVERLEAF_LISTEN_IP` to either `0.0.0.0` or the external IP of your host will typically cause errors when used in conjunction with the [TLS Proxy](tls-proxy.md).

- Default: `127.0.0.1`

### `OVERLEAF_PORT`

Sets the host port that the container will bind to. For example, if this is set to `8099` and `OVERLEAF_LISTEN_IP` is set to `127.0.0.1`, then the web interface will be available on `http://localhost:8099`.

- Default: 80

### `OVERLEAF_IMAGE_NAME`

Docker image as used by the Server Pro/CE application container. This is just the Docker image name, the Docker image tag is sourced from `config/version`.

- Default:
  - Server Pro: `quay.io/sharelatex/sharelatex-pro`
  - Community Edition: `sharelatex/sharelatex`

### `SERVER_PRO`

When set to `true`, tells the toolkit to use the Server Pro image (`quay.io/sharelatex/sharelatex-pro`), rather than the default Community Edition image (`sharelatex/sharelatex`). 

- Default: false


### `SIBLING_CONTAINERS_ENABLED`

When set to `true`, tells the toolkit to use the "Sibling Containers" technique
for compiling projects in separate sandboxes, using a separate docker container for
each project. See [the legacy documentation on Sandboxed Compiles](https://github.com/sharelatex/sharelatex/wiki/Server-Pro:-sandboxed-compiles) for more information.

Requires `SERVER_PRO=true`

- Default: false


### `DOCKER_SOCKET_PATH`

Sets the path to the docker socket on the host machine (the machine running the toolkit code). When `SIBLING_CONTAINERS_ENABLED` is `true`, the socket will be mounted into the container, to allow the compiler service to spawn new docker containers on the host.

Requires `SIBLING_CONTAINERS_ENABLED=true`

- Default: /var/run/docker.sock

### `GIT_BRIDGE_ENABLED`

Set to `true` to enable the git-bridge feature (Server Pro only).

User documentation: https://www.overleaf.com/learn/how-to/Git_integration

- Default: false

### `GIT_BRIDGE_IMAGE`

Docker image as used by the git-bridge container (Server Pro only). This is just the Docker image name, the Docker image tag is sourced from `config/version`.

- Default: `quay.io/sharelatex/git-bridge`

### `GIT_BRIDGE_DATA_PATH`

Sets the path to the directory that will be mounted into the `git-bridge` container (Server Pro only), and used to store the git-repositories. This can be either a full path (beginning with a `/`), or relative to the base directory of the toolkit.

- Default: data/git-bridge

### `GIT_BRIDGE_LOG_LEVEL`

Configure the logging level of the `git-bridge` container. Available levels: `TRACE`, `DEBUG`, `INFO`, `WARN`, `ERROR`.

- Default: INFO

### `MONGO_ENABLED`

When set to `true`, tells the toolkit to create a MongoDB container, to host the database.
When set to `false`, this container will not be created, and the system will use the MongoDB database specified by `MONGO_URL` instead.

- Default: true


### `MONGO_URL`

Specifies the MongoDB connection URL to use when `MONGO_ENABLED` is `false`

- Default: not set


### `MONGO_DATA_PATH`

Sets the path to the directory that will be mounted into the `mongo` container, and used to store the MongoDB database. This can be either a full path (beginning with a `/`), or relative to the base directory of the toolkit. This option only affects the local `mongo` container that is created when `MONGO_ENABLED` is `true`.

- Default: data/mongo

### `MONGO_IMAGE`

Docker image as used by the MongoDB container. This is just the name of the Docker image, the Docker image tag should go into `MONGO_VERSION` (see below).

- Default: `mongo`

### `MONGO_VERSION`

MongoDB version as used by the MongoDB container. The value must start with the major MongoDB version and a dot, e.g. `6.0` or `6.0-with-suffix`.

- Default: `6.0`

### `REDIS_ENABLED`

When set to `true`, tells the toolkit to create a Redis container, to host the redis database.
When set to `false`, this container will not be created, and the system will use the  Redis database specified by `REDIS_HOST` and `REDIS_PORT` instead.

- Default: true


### `REDIS_HOST`

Specifies the Redis host to use when `REDIS_ENABLED` is `false`

- Default: not set


### `REDIS_PORT`

Specifies the Redis port to use when `REDIS_ENABLED` is `false`

- Default: not set


### `REDIS_DATA_PATH`

Sets the path to the directory that will be mounted into the `redis` container, and used to store the Redis database. This can be either a full path (beginning with a `/`), or relative to the base directory of the toolkit. This option only affects the local `redis` container that is created when `REDIS_ENABLED` is `true`.

- Default: data/redis

### `REDIS_IMAGE`

Docker image as used by the Redis container.

- Default: `redis:6.2`

### `REDIS_AOF_PERSISTENCE`

Turn on AOF (Append Only File) persistence for Redis. This is the recommended configuration for Redis persistence.

For additional details, see https://github.com/overleaf/overleaf/wiki/Data-and-Backups/#redis

- Default: true

### `NGINX_ENABLED`

When set to `true`, tells the toolkit to create an NGINX container, to act as a [TLS Proxy](tls-proxy.md).

- Default: false

### `NGINX_CONFIG_PATH`

Path to the NGINX config file to use for the [TLS Proxy](tls-proxy.md).

- Default: config/nginx/nginx.conf

### `TLS_PRIVATE_KEY_PATH`

Path to the private key to use for the [TLS Proxy](tls-proxy.md).

- Default: config/nginx/certs/overleaf_key.pem

### `TLS_CERTIFICATE_PATH`

Path to the public certificate to use for the [TLS Proxy](tls-proxy.md).

- Default: config/nginx/certs/overleaf_certificate.pem

### `NGINX_TLS_LISTEN_IP`

Sets the host IP address(es) that the [TLS Proxy](tls-proxy.md) container will bind to for https. For example, if this is set to `0.0.0.0` then the https web interface will be available on any host IP address.

Typically this should be set to the external IP of your host.

- Default: `127.0.1.1`

### `TLS_PORT`

Sets the host port that the [TLS Proxy](tls-proxy.md) container will bind to for https.

- Default: 443

### `NGINX_HTTP_LISTEN_IP`

Sets the host IP address(es) that the [TLS Proxy](tls-proxy.md) container will bind to for http redirect. For example, if this is set to `127.0.1.1` then http connections to `127.0.1.1` will be redirected to the https web interface.

Typically this should be set to the external IP of your host. Do not set it to `0.0.0.0` as this will typically cause a conflict with `OVERLEAF_LISTEN_IP`.

- Default: `127.0.1.1`

### `NGINX_HTTP_PORT`

Sets the host port that the [TLS Proxy](tls-proxy.md) container will bind to for http.

- Default: `80`