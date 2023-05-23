# Dependencies

This project requires a modern unix system as a base (such as Ubuntu Linux).
It also requires `bash` and `docker`. 

The `bin/doctor` script can be used to check for missing dependencies.

Note: MacOS does not ship with a `realpath` program. In this case we fall
back to a custom shell function to imitate some of what `realpath` does, but
it is relatively limited. We recommend users on MacOS install the gnu coreutils
with `brew install coreutils`, to get a working version of `realpath`.


## Host Environment

The Overleaf Toolkit is tested on Ubuntu Linux, but we expect that most modern Linux systems will be able to run the toolkit without problems. Although it is possible to run the toolkit on other platforms, they are not officially supported.
