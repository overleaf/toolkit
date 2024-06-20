# Changelog

## 2024-06-17
### Added
- Added support for Mongo 6.0.

## 2024-06-11
### Added
- Updated default [`version`](https://github.com/overleaf/toolkit/blob/master/lib/config-seed/version) to `5.0.5`.
  :warning: This is a security release. Please check the [release notes](https://github.com/overleaf/overleaf/wiki/Release-Notes-5.x.x#server-pro-505) for details.

  Note: Server Pro version 4.2.5 contains the equivalent security update for the 4.x.x release line.

## 2024-05-27
### Added
- Pull TeX Live images from `bin/up`

## 2024-05-24
### Added
- Updated default [`version`](https://github.com/overleaf/toolkit/blob/master/lib/config-seed/version) to `5.0.4`.
  :warning: This is a security release. Please check the [release notes](https://github.com/overleaf/overleaf/wiki/Release-Notes-5.x.x#server-pro-504) for details.

## 2024-05-08
### Added
- Add warning for using docker installing via `snap`.

## 2024-04-22
### Added
- Updated default [`version`](https://github.com/overleaf/toolkit/blob/master/lib/config-seed/version) to `5.0.3`.

  :warning: This is a security release. This release also fixes a critical bug in a database migration as included in release 5.0.1. The recovery procedure for doc versions has been updated compared to 5.0.2. Please check the [release notes](https://github.com/overleaf/overleaf/wiki/Release-Notes-5.x.x#server-pro-503) for details.

  Note: Server Pro version 4.2.4 contains the equivalent security update for the 4.x.x release line.

## 2024-04-22
### Added
- Updated default [`version`](https://github.com/overleaf/toolkit/blob/master/lib/config-seed/version) to `5.0.2`.

  :warning: This is a security release. This release also fixes a critical bug in a database migration as included in release 5.0.1. Please check the [release notes](https://github.com/overleaf/overleaf/wiki/Release-Notes-5.x.x#server-pro-502) for details.

  Note: Server Pro version 4.2.4 contains the equivalent security update for the 4.x.x release line.
### Fixed
- Retracted release 5.0.2

  :warning: We have identified a few corner cases in the recovery procedure for docs.

## 2024-04-18
### Fixed
- Retracted release 5.0.1

  :warning: We have identified a critical bug in a database migration that causes data loss. Please defer upgrading to release 5.0.1 until further notice on the mailing list. Please hold on to any backups that were taken prior to upgrading to version 5.0.1.

## 2024-04-09
### Added

- Print column headers from `bin/images`
- List Git Bridge images via `bin/images`

## 2024-04-02
### Added
- Updated default [`version`](https://github.com/overleaf/toolkit/blob/master/lib/config-seed/version) to `5.0.1`.

  :warning: This is a major release. Please check the [release notes](https://github.com/overleaf/overleaf/wiki/Release-Notes-5.x.x#server-pro-501) for details.

- Rebranded 'SHARELATEX_' variables to 'OVERLEAF_'


## 2024-02-27
### Fixed

- Relaunch `bin/upgrade` after updating Toolkit code.

  We are planning to expand the scope of the `bin/upgrade` script in a following release and these changes need to be applied _while_ running `bin/upgrade`.

  With this release there is a one-time requirement that you choose "Yes" to "Perform code update?" and "No" to "Upgrade image?". After the Toolkit code has been updated, run `bin/upgrade` again and choose to upgrade the image.

## 2024-02-16
### Added
- Updated default [`version`](https://github.com/overleaf/toolkit/blob/master/lib/config-seed/version) to `4.2.3`.

  :warning: This is a security release. Please check the [release notes](https://github.com/overleaf/overleaf/wiki/Release-Notes--4.x.x#server-pro-423) for details.

## 2024-02-14
### Added
- Updated default [`version`](https://github.com/overleaf/toolkit/blob/master/lib/config-seed/version) to `4.2.2`.

  :warning: This is a security release. Please check the [release notes](https://github.com/overleaf/overleaf/wiki/Release-Notes--4.x.x#server-pro-422) for details.

## 2024-01-12
### Added
- Updated Mongo version from 4.4 to 5.0 in config seed. Documentation on Mongo updates can be found [here](https://github.com/overleaf/overleaf/wiki/Updating-Mongo-version).

## 2023-11-10
### Added
- Updated default [`version`](https://github.com/overleaf/toolkit/blob/master/lib/config-seed/version) to `4.2.0`.

## 2023-11-02
### Added
- Updated default [`version`](https://github.com/overleaf/toolkit/blob/master/lib/config-seed/version) to `4.1.6`.
  The previous release `4.1.5` is an important bug fix release for the history system, see the full [release notes](https://github.com/overleaf/overleaf/wiki/Release-Notes--4.x.x#server-pro-415).

## 2023-10-24
### Added
- `bin/logs`: Pick up logs from history-v1 and project-history
- Updated default [`version`](https://github.com/overleaf/toolkit/blob/master/lib/config-seed/version) to `4.1.4`.

## 2023-10-06
### Added
- Updated default [`version`](https://github.com/overleaf/toolkit/blob/master/lib/config-seed/version) to `4.1.3`.

## 2023-09-18

### Added
- Prepare for addition of web-api service in upcoming Server Pro 4.2 release.

## 2023-09-06
### Added
- Updated default [`version`](https://github.com/overleaf/toolkit/blob/master/lib/config-seed/version) to `4.1.1`.

  This is a bug fix release, see the full [release notes](https://github.com/overleaf/overleaf/wiki/Release-Notes--4.x.x#server-pro-411).

## 2023-08-24
### Added
- Updated default [`version`](https://github.com/overleaf/toolkit/blob/master/lib/config-seed/version) to `4.1.0`.

  :warning: This is a security release. Please check the [release notes](https://github.com/overleaf/overleaf/wiki/Release-Notes--4.x.x#server-pro-410) for details.

## 2023-08-11
### Added
- Updated default [`version`](https://github.com/overleaf/toolkit/blob/master/lib/config-seed/version) to `4.0.6`.

  From the [release notes](https://github.com/overleaf/overleaf/wiki/Release-Notes--4.x.x#server-pro-406):

  - Bring back the [History Migration Cleanup Script](https://github.com/overleaf/overleaf/wiki/Full-Project-History-Migration#clean-up-legacy-history-data) with a fix to free up mongo storage space.

    > :warning: We advise customers to re-run the script again as per the documentation.

## 2023-07-28
### Added
- Added support for a version suffix of `-with-texlive-full` to be able to load a custom image with TeXLive full backed in.

  Server Pro customers: We strongly recommend using [Sandboxed compiles](https://github.com/overleaf/toolkit/blob/master/doc/sandboxed-compiles.md) instead of running a custom TeXLive full installation. Please reach out to us if you have any questions or need help with setting up Sandboxed compiles in Server Pro.

## 2023-07-20
### Added
- Updated default [`version`](https://github.com/overleaf/toolkit/blob/master/lib/config-seed/version) to `4.0.5`.

## 2023-07-14
### Added
- Updated default [`version`](https://github.com/overleaf/toolkit/blob/master/lib/config-seed/version) to `4.0.4`.

## 2023-06-29
### Added
- Updated default [`version`](https://github.com/overleaf/toolkit/blob/master/lib/config-seed/version) to `4.0.3`.
- 

## 2023-06-08
### Added
- Updated default [`version`](https://github.com/overleaf/toolkit/blob/master/lib/config-seed/version) to `4.0.2`.
- 
## 2023-05-30
### Added
- Updated default [`version`](https://github.com/overleaf/toolkit/blob/master/lib/config-seed/version) to `4.0.1`.

## 2023-05-16
### Added
- Use Docker Compose v2 by default. Fall back to Docker Compose v1 if v2 is
  unavailable.
### Fixed
- Propagate the `REDIS_PORT` variable to the sharelatex container

## 2023-05-15
### Added
- Support listing container logs with `bin/logs` command
- `bin/logs -n all` shows all logs for a given service

## 2023-05-11
### Added
- Change the location of the git-bridge data directory to /data/git-bridge
  inside the container

## 2023-05-01
### Added
- Start Mongo in a replica set by default

## 2023-04-14
### Fixed
- Fix openssl invocation on OS X

## 2023-04-13
### Fixed
- Ensure git bridge is disabled by default

## 2023-04-10
### Added
- Git bridge support in Server Pro 4.x

## 2023-03-21
### Added
- Updated default [`version`](https://github.com/overleaf/toolkit/blob/master/lib/config-seed/version) to `3.5.5`.

## 2023-03-20
### Added
- Updated default [`version`](https://github.com/overleaf/toolkit/blob/master/lib/config-seed/version) to `3.5.4`.

## 2023-03-16
### Added
- Updated default [`version`](https://github.com/overleaf/toolkit/blob/master/lib/config-seed/version) to `3.5.3`.

## 2023-03-07
### Added
- Updated default [`version`](https://github.com/overleaf/toolkit/blob/master/lib/config-seed/version) to `3.5.2`.

## 2023-03-06
### Added
- Updated default [`version`](https://github.com/overleaf/toolkit/blob/master/lib/config-seed/version) to `3.5.1`.

## 2023-02-28
### Added
- Add variables for S3
- Extend doctor script to flag incomplete S3 config

## 2023-02-10
### Added
- Increase SIGKILL timeout for docker container to enable graceful shutdown in version 3.5 onwards

## 2023-01-11
### Added
- Updated default [`version`](https://github.com/overleaf/toolkit/blob/master/lib/config-seed/version) to `3.4.0`.

## 2022-11-15
### Added
- Updated default [`version`](https://github.com/overleaf/toolkit/blob/master/lib/config-seed/version) to `3.3.2`.

## 2022-10-13
### Added
- Updated default [`version`](https://github.com/overleaf/toolkit/blob/master/lib/config-seed/version) to `3.3.0`.

## 2022-09-22
### Added
- Updated default [`version`](https://github.com/overleaf/toolkit/blob/master/lib/config-seed/version) to `3.2.2`.

## 2022-08-16
### Added
- Updated default [`version`](https://github.com/overleaf/toolkit/blob/master/lib/config-seed/version) to `3.2.0`.
- Updated Mongo version from 4.2 to 4.4. Documentation on Mongo updates can be found [here](https://github.com/overleaf/overleaf/wiki/Updating-Mongo-version).
- Print warning when `SHARELATEX_LISTEN_IP` is not defined.

## 2021-10-13
### Added
- HTTP to HTTPS redirection.
  - Listen mode of the `sharelatex` container now `localhost` only, so the value of `SHARELATEX_LISTEN_IP` must be set to the public IP address for direct container access. 

## 2021-08-12
### Added
- Server Pro: New variable to control LDAP and SAML, `EXTERNAL_AUTH`, which can
  be set to one of `ldap`, `saml`, `none`. This is the preferred way to activate
  LDAP and SAML.  For backward compatibility, if this is not set, we fall back
  to the legacy behaviour of inferring which module to activate from the
  relevant environment variables.
  - This should not affect current installations. Please contact support if you
    encounter any problems
  - See [LDAP](./doc/ldap.md) and [SAML](./doc/saml.md) documentation for more

## 2020-11-25
### Added
- `bin/upgrade` displays any changes to the changelog and prompts for
   confirmation before applying the remote changes to the local branch.
### Misc
- Fix code linting errors in bin/ scripts

## 2020-11-19
### Added
- Updated default [`version`](https://github.com/overleaf/toolkit/blob/master/lib/config-seed/version) to 2.5.0
- Updated Mongo version from 3.6 to 4.0. Documentation on Mongo updates can be found [here](https://github.com/overleaf/overleaf/wiki/Updating-Mongo-version).

## 2020-10-22
### Added
- Updated default [`version`](https://github.com/overleaf/toolkit/blob/master/lib/config-seed/version) to 2.4.2


## 2020-10-21
### Added
- `bin/up` now passes along any supplied flags to `docker-compose`,
  for example: `bin/up -d` will run in detached mode
- Documentation on how to update environment variables. ([documentation](./doc/configuration.md))
### Fixed
- A typo


## 2020-10-09
### Added
- Add `SHARELATEX_PORT` option to `overleaf.rc` file, which defaults
  to `80`, same as the previous hard-coded value. ([documentation](./doc/overleaf-rc.md))
