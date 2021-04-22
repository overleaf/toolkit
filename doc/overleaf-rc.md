# Configuration: `overleaf.rc`

This document describes the variables that are supported in the `config/overleaf.rc` file.
This file consists of variable definitions in the form `NAME=value`. Lines beginning with `#` are treated as comments.


## Variables


### `PROJECT_NAME`

Sets the value of the `--project-name` flag supplied to `docker-compose`.
This is useful when running multiple instances of Overleaf on one host, as each instance can have a different project name.

- Default: overleaf


### `SHARELATEX_DATA_PATH`

Sets the path to the directory that will be mounted into the main `sharelatex` container, and used to store compile data. This can be either a full path (beginning with a `/`), or relative to the base directory of the toolkit.

- Default: data/sharelatex


### `SHARELATEX_PORT`

Sets the host port that the container will bind to. For example, if this is set to `8099`, then the web interface will be available on `http://localhost:8099`.

- Default: 80


### `SERVER_PRO`

When set to `true`, tells the toolkit to use the Server Pro image (`quay.io/sharelatex/sharelatex-pro`), rather than the default Community Edition image (`sharelatex/sharelatex`). 

- Default: false


### `SIBLING_CONTAINERS_ENABLED`

When set to `true`, tells the toolkit to use the "Sibling Containers" technique
for compiling projects in separate sandboxes, using a separate docker container for
each project. See (the legacy documentation on Sandboxed Compiles)[https://github.com/sharelatex/sharelatex/wiki/Server-Pro:-sandboxed-compiles] for more information.

Requires `SERVER_PRO=true`

- Default: false


### `DOCKER_SOCKET_PATH`

Sets the path to the docker socket on the host machine (the machine running the toolkit code). When `SIBLING_CONTAINERS_ENABLED` is `true`, the socket will be mounted into the container, to allow the compiler service to spawn new docker containers on the host.

Requires `SIBLING_CONTAINERS_ENABLED=true`

- Default: /var/run/docker.sock


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

### `TLS_PORT`

Sets the host port that the [TLS Proxy](tls-proxy.md) container will bind to. For example, if this is set to `8443`, then the https web interface will be available on `https://localhost:8443`.

- Default: 443
