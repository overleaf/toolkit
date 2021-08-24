# Community Edition: Upgrading TexLive

To save bandwidth, the Overleaf image only comes with a minimal install of [TeXLive](https://www.tug.org/texlive/). To upgrade to a complete TeXLive installation, run the installation script in the Overleaf container with the following command:

```bash
$ bin/docker-compose exec sharelatex tlmgr install scheme-full
```

Alternatively you can install packages manually as you need by replacing `scheme-full` with the package name.

Note that these changes made inside the `sharelatex` container with `docker exec` are ephemeral --- they will be lost if Compose recreates the container. To make them persistent, you can use `docker commit` to save the changes to a new docker image:

```bash
$ docker commit sharelatex sharelatex/sharelatex:with-texlive-full
```

Then add a `docker-compose.override.yml` file to the `config/` folder, and specify
that the toolkit should use this new image to launch the `sharelatex` container in future:

(Note: the version number in `docker-compose.override.yml` MUST match the version number used by the toolkit scripts (such as `lib/docker-compose.base.yml`))

```yml
---
version: '2.2'
services:
    sharelatex:
        image: sharelatex/sharelatex:with-texlive-full
```

Then run `bin/stop && bin/docker-compose rm -f sharelatex && bin/up`, to recreate the container.

Note that you will need to remove this committed container and repeat these steps when you [upgrade](./upgrading.md).

Server Pro users have the option of using [Sandbox Compiles](./sandboxed-compiles.md), which will automatically pull down a full TexLive image. 

