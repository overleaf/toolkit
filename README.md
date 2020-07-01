# Overleaf Toolkit

## Getting Started

See the [Quick Start Guide](./doc/quick-start-guide.md).


## Doctor

Run `bin/doctor` for debug output


## Docker Compose Wrappers

The `bin/docker-compose` script is a wrapper around `docker-compose`, 
and automatically loads the project configuration. `bin/up`, `bin/start`, etc,
are convenience wrappers around `bin/docker-compose`.


## Config files

- `config/overleaf.rc`
- `config/variables.env`

If `config/docker-compose.override.yml` is present, it will also be loaded.


## Docker Compose files

- `lib/docker-compose.base.yml`
- `lib/docker-compose.mongo.yml`
- `lib/docker-compose.redis.yml`
- `lib/docker-compose.sibling-containers.yml`


### overleaf.rc

The `config/overleaf.rc` file controls top-level configuration,
such as the docker image to use, data paths, etc. This is used
to configure the invocaton to docker-compose.


### variables.env

Environment variables loaded in the overleaf container as application
settings.


## Data directories (default)

- `data/mongo`
- `data/redis`
- `data/sharelatex`

All are persisted outside of the containers. 

These can be changed by setting `MONGO_DATA_PATH` (etc) in `overleaf.rc`


## How To 

### Update to the latest version

This project uses tags to mark releases on the `master` branch.
Run `git pull`, and check out the latest tag. (TODO: improve this).


### Switch to Server Pro

- In `overleaf.rc`, set `SERVER_PRO=true`


### Change Image

(Hypothetically, check out a git tag for the appropriate version)


### Using an external mongo/redis

- Set `MONGO_ENABLED=false` in `overleaf.rc`
- In `variables.env`, set `SHARELATEX_MONGO_URL` to the appropriate url


### Using Sibling-Containers

- In `overleaf.rc` set `SIBLING_CONTAINERS_ENABLED=true`
- In `overleaf.rc`, ensure `DOCKER_SOCKET_PATH` is set
- In `variables.env`, un-comment the block starting with `DOCKER_RUNNER=...`,
  and set the appropriate values
