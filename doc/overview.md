# Overleaf Toolkit Overview


## What is Overleaf?

[Overleaf](https://overleaf.com) is an online collaborative writing and publishing tool that makes the whole process of writing, editing and publishing scientific documents much quicker and easier. Overleaf provides the convenience of an easy-to-use LaTeX editor with real-time collaboration and the fully compiled output produced automatically in the background as you type.


## What is the Overleaf Toolkit?

The [Overleaf Toolkit](https://github.com/overleaf/toolkit) is a set of tools that allow anyone to run their own local version of Overleaf. The Overleaf software is distributed in [Docker](https://www.docker.com) images, while the toolkit manages the complexity of making those images run on your computer.


## What are "Community Edition" and "Server Pro"?

Community Edition is the free version of Overleaf, while Server Pro is our enterprise offering, with more features and commercial support. Community Edition is distributed as a docker image on [Docker Hub](https://hub.docker.com/r/sharelatex/sharelatex), whereas Server Pro is distributed as a docker image on a private [quay.io](https://quay.io) registry.

When you set up Overleaf using the toolkit, you will start with Community Edition, and can easily switch to Server Pro by changing just one setting.


## Docker, Docker Compose, and Overleaf

The toolkit uses [Docker](https://www.docker.com) and [Docker Compose](https://docs.docker.com/compose/) to run the Overleaf software in an isolated sandbox. While we do recommend becoming familiar with both Docker and Docker Compose, we also aim to make it as easy as possible to run Overleaf on your own computer.


## How do I get the Toolkit?

The toolkit is distributed as a git repository, here: https://github.com/overleaf/toolkit

If you want to get started right now, we recommend you take a look at the
[Quick-Start Guide](./quick-start-guide.md).


## Toolkit Structure

If you take a look at the toolkit repository, you will see a file structure like this:

```
    bin/
    config/
    data/
    doc/
    lib/
    README.md
```

The `README.md` file contains some important information about the project. The `lib/` directory contains files that are internal to the toolkit, and users should not need to worry about. 


### Data Files

By default, the toolkit will put your overleaf data in the `data/` directory. This directory is ignored by git, so you don't need to worry about it being over-written by an update to the toolkit code.


### Configuration Files

Your own configuration files will live in the `config/` directory. This directory is also ignored by git, so it won't be over-written by the toolkit.


### The `bin/` directory

The `bin/` directory contains a collection of scripts, which will be your main interface to the toolkit system. We can start the Overleaf system with `bin/start`, we can check the logs with `bin/logs`, and we can back up our configuration with `bin/backup-config`


### Documentation

You will find all the documentation you need in the `doc/` directory. This documentation can also be viewed online, here: https://github.com/overleaf/toolkit/tree/master/doc/
