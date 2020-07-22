# Getting Server Pro

Overleaf Server Pro is a commercial version of Overleaf, with extra features and commercial support.
See https://www.overleaf.com/for/enterprises/features for more details about Server Pro and how to 
buy a license. Or, if you already have a license, contact support@overleaf.com if you need assistance.


## Obtaining Server Pro Image

Server Pro is distributed as a docker image on the [quay.io](https://quay.io) registry: `quay.io/sharelatex/sharelatex-pro`

You will have been supplied with a set of credentials when you signed up for a Server Pro license.

First use your Server Pro credentials to log in to quay.io:

```
docker login quay.io
Username: <sharelatex+your_key_name>
Password: <your key>
```

Then run `bin/docker-compose pull` to pull the image from the `quay.io` registry.


## Switching your installation to Server Pro 

We recommend first setting up your toolkit with the default Community Edition image before switching to Server Pro.

You can enable Server Pro by opening `config/overleaf.rc` and changing the `SERVER_PRO` setting to `true`:

```
SERVER_PRO=true
```

The next time you run `bin/up`, the toolkit will use the Server Pro image.
