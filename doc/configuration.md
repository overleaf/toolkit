# Configuration Overview

This document describes the configuration files that are used to configure the Overleaf Toolkit.


## Configuration File Location

All user-owned configuration files are found in the `config/` directory.
This directory is excluded from the git revision control system, so it will not be changed by updating the toolkit code. The toolkit will not change any data in the `config/` directory without your permission.

Note that changes to the configuration files will not be automatically applied
to existing containers, even if the container is stopped and restarted (with
`bin/stop` and `bin/start`). To apply the changes, run `bin/up`, and
`docker compose` will automatically apply the configuration changes to a new
container. (Or, run `bin/up -d`, if you prefer to not attach to the docker logs)


## Initializing the Configuration

Run `bin/init` to initialize a new configuration, with sensible defaults.
This script will not over-write any existing configuration files.


## Backing Up Your Configuration

Use the `bin/backup-config` script to make a backup of your configuration files.
For example: 

```sh
bin/backup-config -m zip ~/overleaf-config-backup.zip
```


## The `overleaf.rc` File

The `config/overleaf.rc` file is the most important contains the most important "top level" configuration in the toolkit. It contains statements that set variables, in the format `VARIABLE_NAME=value`.


See [The full specification](./overleaf-rc.md) for more details on the supported options. 

Note: we recommend that you re-create the docker containers after changing anything in `overleaf.rc` or `variables.env`, by running `bin/docker-compose down`, followed by `bin/up`


## The `variables.env` File

The `config/variables.env` file contains environment variables that are loaded into the overleaf docker container, and used to configure the overleaf microservices. These include the name of the application, as displayed in the header of the web interface, settings for sending emails, and settings for using LDAP with Server Pro.


## The `version` File

The `config/version` file contains the version number of the docker images that will be used to create the running instance of Overleaf.


## The `docker-compose.override.yml` File

If present, the `config/docker-compose.override.yml` file will be included in the invocation to `docker compose`. This is useful for overriding configuration specific to docker compose.

See the [docker-compose documentation](https://docs.docker.com/compose/extends/#adding-and-overriding-configuration) for more details.
