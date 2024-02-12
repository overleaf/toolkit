# shellcheck shell=bash
# shellcheck disable=SC2034
# shellcheck source-path=..

function read_config() {
  source "$TOOLKIT_ROOT/lib/default.rc"
  # shellcheck source=/dev/null
  source "$TOOLKIT_ROOT/config/overleaf.rc"
}

function read_image_version() {
  IMAGE_VERSION="$(head -n 1 "$TOOLKIT_ROOT/config/version")"
  if [[ ! "$IMAGE_VERSION" =~ ^([0-9]+)\.([0-9]+)\.[0-9]+(-RC[0-9]*)?(-with-texlive-full)?$ ]]; then
    echo "ERROR: invalid version '${IMAGE_VERSION}'"
    exit 1
  fi
  IMAGE_VERSION_MAJOR=${BASH_REMATCH[1]}
  IMAGE_VERSION_MINOR=${BASH_REMATCH[2]}
}

prompt() {
    read -p "$1 (y/n): " choice
    if [[ ! "$choice" =~ [Yy] ]]; then
        echo "Exiting."
        exit 1
    fi
}

rebrand_sharelatex_env_variables() {
  set +o pipefail
  sharelatex_occurrences=$(grep -o "SHARELATEX_" "$TOOLKIT_ROOT/config/variables.env" | wc -l | sed 's/ //g')
  set -o pipefail
  if [ "$sharelatex_occurrences" -gt 0 ]; then
    echo "Found $sharelatex_occurrences lines with SHARELATEX_"
    local timestamp=$(date "+%Y.%m.%d-%H.%M.%S")
    echo "Creating backup file config/__old-variables.env.$timestamp"
    cp config/variables.env config/__old-variables.env.$timestamp
    echo "Replacing 'SHARELATEX_' with 'OVERLEAF_' in config/variables.env"
    sed -i "s/SHARELATEX_/OVERLEAF_/g" "$TOOLKIT_ROOT/config/variables.env"
    echo "Updated $sharelatex_occurrences lines in $TOOLKIT_ROOT/config/variables.env"
  else
    echo "No 'SHARELATEX_' ocurrences found in config/variables.env"
  fi
}
