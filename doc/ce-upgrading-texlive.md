# Community Edition: Upgrading TexLive

To save bandwidth, the Overleaf image only comes with a minimal install of [TeX Live](https://www.tug.org/texlive/). You can install more packages or upgrade to a complete TeX Live installation using the [tlmgr](https://www.tug.org/texlive/tlmgr.html) command in the Overleaf container.

Server Pro users have the option of using [Sandboxed Compiles](./sandboxed-compiles.md), which will automatically pull down a full TexLive image. The following instructions only apply to Community Edition installations.

## Getting inside the Overleaf container

To start a shell inside the Overleaf container, run

```
$ bin/shell
```

You will get a prompt that looks like:
```
root@309b192d4030:/#
```

In the following instructions, we will assume that you are in the container.

## Determining your current TeX Live version

TeX Live is released every year around the month of April. Steps for using `tlmgr` are different depending on whether you are using the current release or an older one. You can check which version of TeX Live you are running with `tlmgr --version`. For example, this installation runs TeX Live 2021:

```
# tlmgr --version
tlmgr revision 59291 (2021-05-21 05:14:40 +0200)
tlmgr using installation: /usr/local/texlive/2021
TeX Live (https://tug.org/texlive) version 2021
```

The current release of TeX Live can be found on [the TeX Live homepage](https://www.tug.org/texlive/).

If you are running an older TeX Live version, you have two options. We usually release a new version of the Overleaf docker image shortly after a TeX Live release. You can wait for it and [upgrade your image using the `bin/upgrade` script](https://github.com/overleaf/toolkit/blob/master/doc/upgrading.md).

If you prefer to keep the older TeX Live release, you will first need to tell `tlmgr` to use a historic repository. You will find instructions for doing so [here](https://www.tug.org/texlive/acquire.html#past).

## Installing packages

To install a complete TeX Live installation, run this command inside the Overleaf container:
```
# tlmgr install scheme-full
```

You can also install individual packages manually:

```
# tlmgr install tikzlings tikzmarmots tikzducks
```

Many more commands are available. Find out more with:

```
# tlmgr help
```

When you're done, type `exit` or press Control-D to exit the shell.

## Saving your changes

The changes you've just made have changed the `sharelatex` container, but are ephemeral --- they will be lost if Compose recreates the container. To make them persistent, use `docker commit` to save the changes to a new docker image:

```
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

Then run `bin/stop && bin/compose rm -f sharelatex && bin/up`, to recreate the container.

Note that you will need to remove this committed container and repeat these steps when you [upgrade](./upgrading.md).
