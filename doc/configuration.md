# Configuration Overview

This document describes the configuration files that are used to configure the Overleaf Toolkit.


## Configuration File Location

All user-owned configuration files are found in the `config/` directory.
This directory is excluded from the git revision control system, so it will not be changed by updating the toolkit code. The toolkit will not change any data in the `config/` directory without your permission.


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


## The `variables.env` File




## The `version` File

The `config/version` file contains the version number of the docker images that will be used to create the running instance of Overleaf.
