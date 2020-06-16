# Overleaf Toolkit

## Getting Started

- Run `bin/init`
  - this will populate config files in `config/`
- Run `bin/up`
  - this will start the service with docker-compose


## Doctor

Run `bin/doctor` for debug output


## Config files

- `config/overleaf.rc`
- `config/variables.env`
- `config/docker-compose.base.yml`
- `config/docker-compose.mongo.yml`
- `config/docker-compose.redis.yml`
- `config/docker-compose.sibling-containers.yml`


### Overleaf.rc

The `config/overleaf.rc` file controls top-level configuration,
such as the docker image to use, data paths, etc. This is used
to configure the invocaton to docker-compose.


### Variables.env

Environment variables loaded in the overleaf container as application
settings.


## Data directories (default)

- `data/mongo`
- `data/redis`
- `data/sharelatex`

All are persisted outside of the containers. 

These can be changed by setting `MONGO_DATA_PATH` (etc) in `overleaf.rc`
