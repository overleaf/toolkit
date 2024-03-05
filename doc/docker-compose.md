# Working with Docker Compose Services

The Overleaf Toolkit runs Overleaf inside a docker container, plus the
supporting databases (MongoDB and Redis), in their own containers. All of this
is orchestrated with `docker compose`.

Note: for legacy reasons, the main Overleaf container is called `sharelatex`,
and is based on the `sharelatex/sharelatex` docker image. This is because the
technology is based on the ShareLaTeX code base, which was merged into Overleaf.
See [this blog
post](https://www.overleaf.com/blog/518-exciting-news-sharelatex-is-joining-overleaf)
for more details. At some point in the future, this will be renamed to match the
Overleaf naming scheme.


## The `bin/docker-compose` Wrapper

The `bin/docker-compose` script is a wrapper around `docker compose`. It
loads configuration from the `config/` directory, before invoking
`docker compose` with whatever arguments were passed to the script.

You can treat `bin/docker-compose` as a transparent wrapper for the
`docker compose` program installed on your machine.

For example, we can check which containers are running with the following:

```
$ bin/docker-compose ps
```


## Convenience Helpers

In addition to `bin/docker-compose`, the toolkit also provides a collection of
convenient scripts to automate common tasks:

- `bin/up`: shortcut for `bin/docker-compose up`
- `bin/start`: shortcut for `bin/docker-compose start`
- `bin/stop`: shortcut for `bin/docker-compose stop`
- `bin/shell`: starts a shell inside the main container


## Architecture

Inside the overleaf container, the Overleaf software runs as a set of micro-services, managed by `runit`. Some of the more interesting files inside the container are:

- `/etc/service/`: initialisation files for the microservices
- `/etc/overleaf/settings.js`: unified settings file for the microservices
- `/var/log/overleaf/`: logs for each microservice
- `/var/www/overleaf/`: code for the various microservices
- `/var/lib/overleaf/`: the mount-point for persistent data (corresponds to the directory indicated by `OVERLEAF_DATA_PATH` on the host)

Before Server Pro/Community Edition version 5.0, the paths used the ShareLaTeX brand.

## The MongoDB and Redis Containers

Overleaf dedends on two external databases: MongoDB and Redis. By default, the toolkit will provision a container for each of these databases, in addition to the Overleaf container, for a total of three docker containers.

If you would prefer to connect to an existing MongoDB or Redis instance, you can do so by setting the appropriate settings in  the [overleaf.rc](./overleaf-rc.md) configuration file.


## Viewing Individual Micro-Service Logs

The `bin/logs` script allows you to select individual log streams from inside the overleaf container.
For example, if you want to see just the logs for the `web` and `clsi` (compiler) micro-services, run:

```
$ bin/logs -f web clsi
```

See the output of `bin/logs --help` for more options.
