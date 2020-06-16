# Overleaf Toolkit

## Getting Started

- Run `bin/init`
  - this will populate config files in `config/`
- Run `bin/up`
  - this will start the service with docker-compose


## Doctor

Run `bin/doctor` for debug output


## Docker Compose Wrappers

The `bin/docker-compose` script is a wrapper around `docker-compose`, 
and automatically loads the project configuration. `bin/up`, `bin/start`, etc,
are convenience wrappers around `bin/docker-compose`.


## Config files

- `config/overleaf.rc`
- `config/variables.env`
- `config/docker-compose.base.yml`
- `config/docker-compose.mongo.yml`
- `config/docker-compose.redis.yml`
- `config/docker-compose.sibling-containers.yml`

If `config/docker-compose.override.yml` is present, it will also be loaded.


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

### Change Image

- in `overleaf.rc`, set `IMAGE` to the desired image name


### Using an external mongo/redis

- Set `MONGO_ENABLED=false` in `overleaf.rc`
- In `variables.env`, set `SHARELATEX_MONGO_URL` to the appropriate url


### Using Sibling-Containers

- In `overleaf.rc` set `SIBLING_CONTAINERS_ENABLED=true`
- In `overleaf.rc`, ensure `DOCKER_SOCKET_PATH` is set
- In `variables.env`, un-comment the block starting with `DOCKER_RUNNER=...`,
  and set the appropriate values
