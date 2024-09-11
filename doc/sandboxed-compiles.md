# Sandboxed Compiles

In Server Pro, it is possible to have each LaTeX project be compiled in a separate docker container, achieving sandbox isolation between projects.

This feature is also known as "Sibling containers" as LaTeX compiles are running in a sibling container next to the Server Pro docker container.

When not using Sandboxed Compiles, users have full read and write access to the `sharelatex` container resources (filesystem, network, environment variables) when running LaTeX compiles.

Note: Sibling containers are not available in Community Edition, which is intended for use in environments where all users are trusted. Community Edition is not appropriate for scenarios where isolation of users is required.

## How It Works

When sandboxed compiles are enabled, the toolkit will mount the docker socket from the host into the overleaf container, so that the compiler service in the container can create new docker containers on the host. Then for each run of the compiler in each project, the LaTeX compiler service (CLSI) will do the following:

- Write out the project files to a location inside the `OVERLEAF_DATA_PATH`, 
- Use the mounted docker socket to create a new `texlive` container for the compile run
- Have the `texlive` container read the project data from the location under `OVERLEAF_DATA_PATH`
- Compile the project inside the `texlive` container


## Enabling Sibling Containers

In `config/overleaf.rc`, set `SIBLING_CONTAINERS_ENABLED=true`, and ensure that the `DOCKER_SOCKET_PATH` setting is set to the location of the docker socket on the host.

The next time you start the docker services (with `bin/up`), the requested TeX Live image (`ALL_TEX_LIVE_DOCKER_IMAGES`) will get downloaded. This process can take several minutes. Once the images have been downloaded, the Server Pro container will get started with the latest configuration changes applied (such as enabling the Sandboxed Compiles feature or adding new TeX Live images).

You can skip the download of images using `SIBLING_CONTAINERS_PULL=false` in `config/overleaf.rc`.

Note: We do not support running sandboxed compiles with Docker as installed via `snap`. Please follow the steps for installing Docker CE on https://docs.docker.com/engine/install/.
