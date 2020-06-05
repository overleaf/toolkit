# Overleaf Toolkit

## Getting Started

- Run `bin/init`
  - this will populate config files in `config/`
- Run `bin/up`
  - this will start the service with docker-compose


## Doctor

Run `bin/doctor` for debug output


## Config files

- `config/docker-compose.yml`
  - base config file for docker-compose, not meant to be edited
- `config/local.yml`
  - local overrides, and environment configuration, editable
