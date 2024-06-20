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
  if [[ ! "$IMAGE_VERSION" =~ ^([0-9]+)\.([0-9]+)\.([0-9])+(-RC[0-9]*)?(-with-texlive-full)?$ ]]; then
    echo "ERROR: invalid version '${IMAGE_VERSION}'"
    exit 1
  fi
  IMAGE_VERSION_MAJOR=${BASH_REMATCH[1]}
  IMAGE_VERSION_MINOR=${BASH_REMATCH[2]}
  IMAGE_VERSION_PATCH=${BASH_REMATCH[3]}
}

function read_mongo_version() {

  # Reads `MONGO_VERSION` from config/overleaf.rc to set the correct mongo shell
  # as $MONGOSH. If `MONGO_VERSION` is not defined it tries to extract the version
  # from `MONGO_IMAGE`, issuing a warning if it's a non-stock image.

  local mongo_version=$(read_configuration "MONGO_VERSION")
  if [ -z "${mongo_version}" ]; then
    local mongo_image=$(read_configuration "MONGO_IMAGE")
    if [[ "$mongo_image" =~ ^mongo:([0-9]+)\.(.*)$ ]]; then
      MONGO_VERSION_MAJOR=${BASH_REMATCH[1]}
    else
      echo "---------------------  ERROR  -----------------------"
      echo "  You are using a non-stock MONGO_IMAGE: $mongo_image"
      echo ""
      echo "  When using custom mongo docker images you must specify MONGO_VERSION in your config/overleaf.rc,"
      echo "  otherwise you may experience problems communicating with your mongo instance."
      echo ""
      echo "  MONGO_VERSION must be of the form <major>.<minor>."
      echo "  Example: MONGO_IMAGE=my.dockerhub.com/custom-mongo:v6"
      echo "           MONGO_VERSION=6.0"
      exit 1
    fi
  else
    if [[ ! "$mongo_version" =~ ^([0-9]+)\.(.*)$ ]]; then
      echo "---------------------  ERROR  -----------------------"
      echo "invalid MONGO_VERSION: '${mongo_version}'"
      exit 1
    fi
    MONGO_VERSION_MAJOR=${BASH_REMATCH[1]}
  fi

  if [[ "$MONGO_VERSION_MAJOR" -lt 6 ]]; then
    MONGOSH="mongo"
  else
    MONGOSH="mongosh"
  fi
}

function check_retracted_version() {
  if [[ "${OVERLEAF_SKIP_RETRACTION_CHECK:-null}" == "$IMAGE_VERSION" ]]; then
    return
  fi

  local version="$IMAGE_VERSION_MAJOR.$IMAGE_VERSION_MINOR.$IMAGE_VERSION_PATCH"
  if [[ "$version" == "5.0.1" ]]; then
    echo "-------------------------------------------------------"
    echo "---------------------  WARNING  -----------------------"
    echo "-------------------------------------------------------"
    echo "  You are currently using a retracted version, $version."
    echo ""
    echo "  We have identified a critical bug in a database migration that causes data loss in the history system."
    echo "  A new release is available with a fix and an automated recovery process."
    echo "  Please follow the steps of the recovery process in the following wiki page:"
    echo "  https://github.com/overleaf/overleaf/wiki/Doc-version-recovery"
    echo "-------------------------------------------------------"
    echo "---------------------  WARNING  -----------------------"
    echo "-------------------------------------------------------"
    exit 1
  fi
}

prompt() {
    read -p "$1 (y/n): " choice
    if [[ ! "$choice" =~ [Yy] ]]; then
        echo "Exiting."
        exit 1
    fi
}

rebrand_sharelatex_env_variables() {
  local filename=$1
  local silent=${2:-no}
  sharelatex_occurrences=$(set +o pipefail && grep -o "SHARELATEX_" "$TOOLKIT_ROOT/config/$filename" | wc -l | sed 's/ //g')
  if [ "$sharelatex_occurrences" -gt 0 ]; then
    echo "Rebranding from ShareLaTeX to Overleaf"
    echo "  Found $sharelatex_occurrences lines with SHARELATEX_ in config/$filename"
    local timestamp=$(date "+%Y.%m.%d-%H.%M.%S")
    local backup_filename="__old-$filename.$timestamp"
    echo "  Will create backup of config/$filename at config/$backup_filename"
    prompt "  Proceed with the renaming in config/$filename?"
    echo "  Creating backup file config/$backup_filename"
    cp "$TOOLKIT_ROOT/config/$filename" "$TOOLKIT_ROOT/config/$backup_filename"
    echo "  Replacing 'SHARELATEX_' with 'OVERLEAF_' in config/$filename"
    sed -i "s/SHARELATEX_/OVERLEAF_/g" "$TOOLKIT_ROOT/config/$filename"
    echo "  Updated $sharelatex_occurrences lines in config/$filename"
  else
    if [[ "$silent" != "silent_if_no_match" ]]; then
      echo "Rebranding from ShareLaTeX to Overleaf"
      echo "  No 'SHARELATEX_' occurrences found in config/$filename"
    fi
  fi
}

function check_sharelatex_env_vars() {
  local rc_occurrences=$(set +o pipefail && grep -o SHARELATEX_ "$TOOLKIT_ROOT/config/overleaf.rc" | wc -l | sed 's/ //g')

  if [ "$rc_occurrences" -gt 0 ]; then
    echo "Rebranding from ShareLaTeX to Overleaf"
    echo "  The Toolkit has adopted to Overleaf brand for its variables."
    echo "  Your config/overleaf.rc still has $rc_occurrences variables using the previous ShareLaTeX brand."
    echo "  Moving forward the 'SHARELATEX_' prefixed variables must be renamed to 'OVERLEAF_'."
    echo "  You can migrate your config/overleaf.rc to use the Overleaf brand by running:"
    echo ""
    echo "    toolkit$ bin/rename-rc-vars"
    echo ""
    exit 1
  fi

  local expected_prefix="OVERLEAF_"
  local invalid_prefix="SHARELATEX_"
  if [[ "$IMAGE_VERSION_MAJOR" -lt 5 ]]; then
    expected_prefix="SHARELATEX_"
    invalid_prefix="OVERLEAF_"
  fi

  local env_occurrences=$(set +o pipefail && grep -o "$invalid_prefix" "$TOOLKIT_ROOT/config/variables.env" | wc -l | sed 's/ //g')

  if [ "$env_occurrences" -gt 0 ]; then
    echo "Rebranding from ShareLaTeX to Overleaf"
    echo "  Starting with Overleaf CE and Server Pro version 5.0.0 the environment variables will use the Overleaf brand."
    echo "  Previous versions used the ShareLaTeX brand for environment variables."
    echo "  Your config/variables.env has $env_occurrences entries matching '$invalid_prefix', expected prefix '$expected_prefix'."
    echo "  Please align your config/version with the naming scheme of variables in config/variables.env."
    if [[ ! "$IMAGE_VERSION_MAJOR" -lt 5 ]]; then
      echo "  You can migrate your config/variables.env to use the Overleaf brand by running:"
      echo ""
      echo "    toolkit$ bin/rename-env-vars-5-0"
      echo ""
    fi
    exit 1
  fi

  if [[ ! "$IMAGE_VERSION_MAJOR" -lt 5 ]]; then
    if grep -q -e 'TEXMFVAR=/var/lib/sharelatex/tmp/texmf-var' "$TOOLKIT_ROOT/config/variables.env"; then
      echo "Rebranding from ShareLaTeX to Overleaf"
      echo "  The 'TEXMFVAR' override is not needed since Server Pro/Overleaf CE version 3.2 (August 2022) and it conflicts with the rebranded paths."
      echo "  Please remove the following entry from your config/variables.env:"
      echo ""
      echo "    TEXMFVAR=/var/lib/sharelatex/tmp/texmf-var"
      echo ""
      exit 1
    fi
  fi
}

function read_variable() {
  local name=$1
  grep -E "^$name=" "$TOOLKIT_ROOT/config/variables.env" \
  | sed -r "s/^$name=([\"']*)(.+)\1*\$/\2/"
}

function read_configuration() {
  local name=$1
  grep -E "^$name=" "$TOOLKIT_ROOT/config/overleaf.rc" \
  | sed -r "s/^$name=([\"']*)(.+)\1*\$/\2/"
}
