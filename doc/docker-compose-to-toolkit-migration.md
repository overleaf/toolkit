# docker-compose.yml to Toolkit migration #

If you're currently using Docker Compose via a `docker-compose.yml` file, migrating to the Toolkit can make running an on-premises version of Overleaf easier to deploy, upgrade and maintain.

To migrate, you'll need to convert your existing Docker Compose setup into the format used by the Toolkit. This process involves copying existing configuration into the Toolkit.

This guide will walk you through each step of this process, ensuring a smooth migration from Docker Compose to the Toolkit.

**Note:** These instructions are for v4.x and earlier. Therefore all variables use the `SHARELATEX_` prefix instead of `OVERLEAF_`

## Clone the Toolkit repository ##

First, let's clone this Toolkit repository to the host machine:
```
$ git clone https://github.com/overleaf/toolkit.git ./overleaf-toolkit
```
Next run the `bin/init` command to initialise the Toolkit with its default configuration.

## Setting the image and version ##

In the `docker-compose.yml` file the image and version are defined in the component description:

```
version: '2.2'
services:
    sharelatex:
        restart: always
        # Server Pro users:
        # image: quay.io/sharelatex/sharelatex-pro
        image: sharelatex/sharelatex:3.5.13
```

When using the Toolkit, the image name is automatically resolved; the only requirement is to set `SERVER_PRO=true` in **config/overleaf.rc** to pick the Server Pro image or `SERVER_PRO=false` to use Community Edition.

The desired Server Pro/Community Edition version number is set in the **config/version** file. The Toolkit requires a specific version number like "**4.2.3**". In case you are using `latest`, you can use `bin/images` to find the image id of your local `latest` version, then use the release notes for [2.x](https://github.com/overleaf/overleaf/wiki/Release-Notes-2.0), [3.x](https://github.com/overleaf/overleaf/wiki/Release-Notes-3.x.x), [4.x](https://github.com/overleaf/overleaf/wiki/Release-Notes--4.x.x) or [5.x](https://github.com/overleaf/overleaf/wiki/Release-Notes-5.x.x) to map the image id to the version.

If you are sourcing the image from your own internal registry you can override the image the Toolkit uses by setting `OVERLEAF_IMAGE_NAME`. You do not need to specify the tag as the Toolkit will automatically add it based on your **config/version** file.

## Configuring external access ##

By default, Overleaf will listen on **127.0.0.1:80**, only allowing traffic from the Docker host machine.

To allow external access, you’ll need to set the `OVERLEAF_LISTEN_IP` and `OVERLEAF_PORT` in the **config/overleaf.rc** file.

## Environment variable migration ##

You’ll likely have a set of environment variables defined in the **sharelatex** service:

```
environment:
    SHARELATEX_APP_NAME: Overleaf Community Edition
    SHARELATEX_PROXY_LEARN: 'true'
    …
```

Each of these variables should be copied, with several exceptions we’ll list later, into the Toolkit’s **config/variables.env** file, ensuring the following form (note the use of `=` instead of `:`):

```
SHARELATEX_APP_NAME=Overleaf Community Edition
SHARELATEX_PROXY_LEARN=true
```

As mentioned above, there are several exceptions, as certain features are configured differently when using the Toolkit:

- Variables starting with `SANDBOXED_COMPILES_` and `DOCKER_RUNNER` are no longer needed. To enable [Sandboxed Compiles](./sandboxed-compiles.md), set `SIBLING_CONTAINERS_ENABLED=true` in your **config/overleaf.rc** file.
- Variables starting with `SHARELATEX_MONGO_`, `SHARELATEX_REDIS_` and the `REDIS_HOST` variable are no longer needed. MongoDB and Redis are now configured in the **config/overleaf.rc** file using  `MONGO_URL`, `REDIS_HOST` and `REDIS_PORT`.

For advanced configuration options, refer to the [overleaf.rc](./overleaf-rc.md) documentation.

## NGINX Proxy ##

For instructions on how to migrate `nginx`, please see [TLS Proxy for Overleaf Toolkit environment](tls-proxy.md)

## Volumes ##

### ShareLaTeX ###

The location of the data volume for the `sharelatex` container will need to be set using `OVERLEAF_DATA_PATH` in the **config/overleaf.rc** file.

In case you are bind-mounting the [application logs](https://github.com/overleaf/overleaf/wiki/Log-files), you can use `OVERLEAF_LOG_PATH` to configure the host path.

### MongoDB ###

The location of the data volume for the `mongo` container will need to be set using `MONGO_DATA_PATH` in the **config/overleaf.rc** file.

### Redis ###

The location of the data volume for the `redis` container will need to be set using `REDIS_DATA_PATH` in the **config/overleaf.rc** file.
