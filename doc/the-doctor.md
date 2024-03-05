# The Doctor

The Overleaf Toolkit comes with a handy `doctor` script, to help with debugging. Just run `bin/doctor` and the script will print out information about your host environment, your configuration, and the dependencies the toolkit needs. This output can also help the Overleaf support team to help you figure out what has gone wrong, in the case of a Server Pro installation.


## Getting Help

Users of the free Community Edition should [open an issue on github](https://github.com/overleaf/toolkit/issues). 

Users of Server Pro should contact `support@overleaf.com` for assistance.

In both cases, it is a good idea to include the output of the `bin/doctor` script in your message.


## Consulting with the Doctor

Run the doctor script:

```sh
$ bin/doctor
```

You will see some output like this:

```
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
        - version info: 5.0.17(1)-release
    - docker
        - status: present
        - version info: Docker version 23.0.6, build 369ce74a3c
    - docker compose
        - status: present
        - version info: Docker Compose version v2.17.3
    - realpath
        - status: present
        - version info: realpath (GNU coreutils) 8.30
    - perl
        - status: present
        - version info: 5.030000
    - awk
        - status: present
        - version info: GNU Awk 5.0.1, API: 2.0 (GNU MPFR 4.0.2, GNU MP 6.2.0)
- Docker Daemon
    - status: up
====== Configuration ======
- config/version
    - status: present
    - version: 2.3.1
- config/overleaf.rc
    - status: present
    - values
        - OVERLEAF_DATA_PATH: data/sharelatex
        - SERVER_PRO: false
        - MONGO_ENABLED: true
        - REDIS_ENABLED: true
- config/variables.env
    - status: present
====== Warnings ======
- None, all good
====== End ======
```


### Host Information

The `Host Information` section contains information about the machine on which the toolkit is running. This includes information about the type of Linux system being used. 


### Dependencies

The `Dependencies` section shows a list of tools which are required for the toolkit to work.
If the tool is present on the system, it will be listed as `status: present`, along with the version of the tool. For example:

```
- docker
    - status: present
    - version info: Docker version 19.03.6, build 369ce74a3c
```

However, if the tool is missing, it will be listed as `status: MISSING!`, and a warning will be added to the bottom of the `doctor` output. For example:

```
- docker
    - status: MISSING!
```

If any of the dependencies are missing, the toolkit will almost certainly not work.


### Configuration

The `Configuration` section contains information about the files in the `config/` directory. In the case of `config/overleaf.rc`, the doctor also prints out some of the more important values from the file. If any of the files are not present, they will be listed as `status: MISSING!`, and a warning will be added to the bottom of the `doctor` output. For example:

```
====== Configuration ======
- config/version
    - status: present
    - version: 2.3.1
- config/overleaf.rc
    - status: present
    - values
        - OVERLEAF_DATA_PATH: /tmp/sharelatex 
        - SERVER_PRO: false
        - MONGO_ENABLED: false
        - REDIS_ENABLED: true
- config/variables.env
    - status: MISSING!
```

The above example shows a few problems:

- The `OVERLEAF_DATA_PATH` variable is set to `/tmp/sharelatex`, which is probably not a safe place to put important data
- The `MONGO_ENABLED` variable is set to `false`, so the toolkit will not provision it's own MongoDB database. In this case, we had better be sure to set `MONGO_URL` to point to a MongoDB database managed outside of the toolkit
- the `config/variables.env` file is missing


### Warnings


The `Warnings` section shows a summary of problems discovered by the doctor script. Or, if there are no problems, this section will say so. For example:

```
====== Warnings ======
- configuration file variables.env not found
- rc file, OVERLEAF_DATA_PATH not set
====== End =======
```

