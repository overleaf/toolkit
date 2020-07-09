# Quick-Start Guide

## Prerequisites

The overleaf toolkit depends on the following programs:

- bash
- docker
- docker-compose

We recommend that you install the most recent version of docker and docker-compose that 
are available on your system.


## Install


Clone this repo to your machine:

```sh
$ git clone git@github.com:overleaf/overleaf-toolkit.git
```

We assume that you will run all subsequent commands from the base directory of this
repository.


## Running the doctor script


Run `bin/doctor` to check the present state of things:

```
$ bin/doctor
====== Overleaf Doctor ======
- Host Information
    - Linux
    - Output of 'lsb_release -a':
            No LSB modules are available.
            Distributor ID:	Ubuntu
            Description:	Ubuntu 20.04 LTS
            Release:	20.04
            Codename:	focal
- Dependencies
    - bash
        - status: present
        - version info: 5.0.16(1)-release

...
```

You'll see some warnings at the bottom, indicating that some essential configuration files
are missing. This is fine, let's move on to the next step.



## Initialise Configuration


Run `bin/init`:

```sh
$ bin/init
Copying config files to 'config/'
```

Now check the contents of the `config/` directory

```sh
$ ls config
overleaf.rc     variables.env     version
```


These are the three configuration files you will interact with:

- `overleaf.rc` : top-level configuration
- `variables.env` : environment variables loaded into the docker container
- `version` : version of the docker images to use


## Starting Up


Let's start the server:

```sh
$ bin/up
```

You should see some log output from the docker containers.


## Create the first admin account

In a browser, open `http://localhost/launchpad`. You should see a form with email and password fields.
Fill these in with the credentials you want to use as the admin account, then click "Register".

Then click the link to go to the login page (`http://localhost/login`). Enter the credentials.
Once you are logged in, you will be taken to a welcome page.

Click the green button at the bottom of the page to start using Overleaf. 


## Create your first project

On the `http://localhost/project` page, you will see a button prompting you to create your first
project. Click the button and follow the instructions.

You should then be taken to the new project, where you will see a text editor and a PDF preview.


## Check the logs


Let's look at the logs inside the container:


```sh
$ bin/logs -f web
```


You can look at the logs for multiple services at once:

```sh
$ bin/logs -f filestore docstore web clsi
```


Or, you can look at error logs specifically:

```sh
$ bin/error-logs -f web
```


## Next Steps

Run the `bin/doctor` script again, and check the output. 
