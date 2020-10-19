# Persistent Data Overview

The Overleaf toolkit needs to store persistent data, such as the files required to compile LaTeX projects, and the contents of the MongoDB database. This is achieved by mounting a few directories from the host machine into the docker containers, and writing the data to those directories.


## Data Directories

The Overleaf container requires a directory in which to store data relating to LaTeX compiles. This directory is set with the `SHARELATEX_DATA_PATH` variable in `config/overleaf.rc`. 

The MongoDB container, if it is enabled, requires a directory in which to store it's database files, and the same is true of the Redis container. These directories can also be configured in `config/overleaf.rc`.


## File Permissions

Because docker runs as `root`, the data directories will end up being owned by the `root` user, even if the toolkit is being used by a non-root user. This is not a problem, but is worth being aware of, if you intend to alter the persistent data from outside of the containers.


## Backups

The recommended backup procedure is as follows:

- Shut down the docker services with `bin/stop`
- For each of the data directories, make a copy of that directory
  to another safe location
  - (We recommend using `rsync` for this)
- Start the services again with `bin/start`
