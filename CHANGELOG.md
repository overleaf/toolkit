# Changelog

## TBD
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
