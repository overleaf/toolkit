# Podman

Server Pro can run on rootless Podman instead of Docker. The `bin/podman-setup` script checks the host is configured correctly, and fixes what it can.

> [!WARNING]
> Podman support is experimental and comes with limited support. It is only tested on RHEL 9+ with rootless Podman, [Sandboxed Compiles](./sandboxed-compiles.md) and SELinux enforcing.


## Requirements

- RHEL 9 or later, with SELinux enforcing
- A non-root user with `sudo` access
- A clean installation. Migrating an existing Docker installation is not covered
- `SERVER_PRO=true` and `SIBLING_CONTAINERS_ENABLED=true` in `config/overleaf.rc`

Rootless Podman can't bind to ports below 1024 by default, so set `OVERLEAF_PORT` to a higher port, for example `8080`.


## Running the Setup Script

Check the host:

```sh
$ bin/podman-setup
```

Fix the issues found:

```sh
$ bin/podman-setup --apply
```

The script exits with `0` if all checks pass, `1` if there are warnings, and `2` if there are failures. It will not run as `root`.

> [!NOTE]
> If you run `bin/podman-setup` before starting Overleaf for the first time, it reports the warning `container → socket skipped (sharelatex not running)` and exits with code `1`. This is expected, as the `sharelatex` container isn't running yet. It also skips the data directory checks (for example `mongo data dir not found`), as `bin/up` creates these directories.
>
> Run `bin/podman-setup` again once Overleaf is up.

Logging in to `quay.io` is not done by the script. Run `podman login quay.io`.


## What the Script Changes

With `--apply`, the script may change the following.

System-wide (using `sudo`):

- Installs `podman`, `podman-docker`, `git`, `curl`, `checkpolicy` and `policycoreutils` with `dnf`
- Enables lingering for your user with `loginctl`
- Creates `/etc/containers/nodocker`
- Loads the `podman_socket_clsi` SELinux policy module, when `SELINUX_MODE=managed`

For your user:

- Enables the `podman.socket` user service
- Installs Docker Compose v2 from GitHub to `~/.local/bin/docker-compose`, and links it in `~/.docker/cli-plugins/`
- Adds a Compose provider to `~/.config/containers/containers.conf`
- Adds `mongo` and `redis` aliases in `~/.config/containers/registries.conf.d/overleaf-toolkit.conf`

In the toolkit:

- Sets `DOCKER_SOCKET_PATH` and `DOCKER_HOST` in `config/overleaf.rc`
- Sets `SECCOMP_PROFILE` in `config/variables.env`, and extracts the profile to `config/seccomp/`
- Builds the SELinux policy module in `config/selinux/`
- Changes the ownership of the data directories with `podman unshare chown`


## SELinux

`SELINUX_MODE` in `config/overleaf.rc` sets the SELinux options for the `sharelatex` container:

- `managed`: use the `sharelatex_t` type from the policy module that ships with the toolkit. `bin/podman-setup --apply` installs the module
- `custom`: use the type set in `SELINUX_LABEL`, from your own policy module
- `disable` (default): disable SELinux confinement for the container
- `none`: set no SELinux options

See [overleaf.rc](./overleaf-rc.md#selinux_mode) for details.


## Seccomp Profile

With Podman, `SECCOMP_PROFILE` in `config/variables.env` must point to the seccomp profile on the host. `bin/podman-setup --apply`, `bin/up` and `bin/upgrade` extract it from the Server Pro image to `config/seccomp/<version>/clsi-profile.json` and set `SECCOMP_PROFILE` for you.
