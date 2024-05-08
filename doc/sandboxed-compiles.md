# Sandboxed Compiles

In Server Pro, it is possible to have each LaTeX project be compiled in a separate docker container, achieving sandbox isolation between projects. 

## How It Works

When sandboxed compiles are enabled, the toolkit will mount the docker socket from the host into the overleaf container, so that the compiler service in the container can create new docker containers on the host. Then for each run of the compiler in each project, the LaTeX compiler service (CLSI) will do the following:

- Write out the project files to a location inside the `OVERLEAF_DATA_PATH`, 
- Use the mounted docker socket to create a new `texlive` container for the compile run
- Have the `texlive` container read the project data from the location under `OVERLEAF_DATA_PATH`
- Compile the project inside the `texlive` container


## Enabling Sibling Containers

In `config/overleaf.rc`, set `SIBLING_CONTAINERS_ENABLED=true`, and ensure that the `DOCKER_SOCKET_PATH` setting is set to the location of the docker socket on the host.

The next time you start the docker services (with `bin/up`), the overleaf container will verify that it can communicate with docker on the host machine, and will pull the `texlive` image it requires to create the sandboxed compile containers. This process can take several minutes, and compiles will be un-available during this time.

Note: We do not support running sandboxed compiles with Docker as installed via `snap`. Please follow the steps for installing Docker CE on https://docs.docker.com/engine/install/.
