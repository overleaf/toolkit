# shellcheck shell=bash
# shellcheck disable=SC2034
# shellcheck source-path=..

function read_config() {
  source "$TOOLKIT_ROOT/lib/default.rc"
  # shellcheck source=/dev/null
  source "$TOOLKIT_ROOT/config/overleaf.rc"

  if [[ $SERVER_PRO != "true" || $IMAGE_VERSION_MAJOR -lt 4 ]]; then
    # Force git bridge to be disabled if not ServerPro >= 4
    GIT_BRIDGE_ENABLED=false
  fi
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
  local mongo_image=$(read_configuration "MONGO_IMAGE")
  local mongo_version=$(read_configuration "MONGO_VERSION")
  if [ -z "${mongo_version}" ]; then
    if [[ "$mongo_image" =~ ^mongo:([0-9]+)\.(.*)$ ]]; then
      # when running a chain of commands (example: bin/up -> bin/docker-compose) we're passing
      # SKIP_WARNINGS=true to prevent the warning message to be printed several times
      if [[ ${SKIP_WARNINGS:-null} != "true" ]]; then
        echo "-------------------  WARNING  ----------------------"
        echo "  Deprecation warning: the mongo image is now split between MONGO_IMAGE"
        echo "  and MONGO_VERSION configurations. Please update your config/overleaf.rc as"
        echo "  your current configuration may stop working in future versions of the toolkit."
        echo "  Example: MONGO_IMAGE=mongo"
        echo "           MONGO_VERSION=6.0"
        echo "-------------------  WARNING  ----------------------"
      fi
      MONGO_VERSION_MAJOR=${BASH_REMATCH[1]}
      MONGO_DOCKER_IMAGE="$mongo_image"
    else
      echo "---------------------  ERROR  -----------------------"
      echo "  The mongo image is now split between MONGO_IMAGE and MONGO_VERSION configurations."
      echo "  Please update your config/overleaf.rc."
      echo ""
      echo "  MONGO_VERSION must start with the actual major version of mongo, followed by a dot."
      echo "  Example: MONGO_IMAGE=my.dockerhub.com/custom-mongo"
      echo "           MONGO_VERSION=6.0-custom"
      echo "---------------------  ERROR  -----------------------"
      exit 1
    fi
  else
    if [[ ! "$mongo_version" =~ ^([0-9]+)\.(.+)$ ]]; then
      echo "---------------------  ERROR  -----------------------"
      echo "  Invalid MONGO_VERSION: $mongo_version"
      echo ""
      echo "  MONGO_VERSION must start with the actual major version of mongo, followed by a dot."
      echo "  Example: MONGO_IMAGE=my.dockerhub.com/custom-mongo"
      echo "           MONGO_VERSION=6.0-custom"
      echo "---------------------  ERROR  -----------------------"
      exit 1
    fi
    MONGO_VERSION_MAJOR=${BASH_REMATCH[1]}
    MONGO_DOCKER_IMAGE="$mongo_image:$mongo_version"
  fi

  if [[ "$MONGO_VERSION_MAJOR" -lt 6 ]]; then
    MONGOSH="mongo"
  else
    MONGOSH="mongosh"
  fi
}

function set_server_pro_image_name() {
  local version=$1
  local image_name
  if [[ -n ${OVERLEAF_IMAGE_NAME:-} ]]; then
    image_name="$OVERLEAF_IMAGE_NAME"
  elif [[ $SERVER_PRO == "true" ]]; then
    image_name="quay.io/sharelatex/sharelatex-pro"
  else
    image_name="sharelatex/sharelatex"
  fi
  export IMAGE="$image_name:$version"
}

function set_git_bridge_image_name() {
  local version=$1
  local image_name
  if [[ -n ${GIT_BRIDGE_IMAGE:-} ]]; then
    image_name="$GIT_BRIDGE_IMAGE"
  else
    image_name="quay.io/sharelatex/git-bridge"
  fi

  # since we're reusing the GIT_BRIDGE_IMAGE environment variable, we check here if the version
  # has already been added to it, for scenarios where this function is called more than once
  if [[ "$image_name" == *"$version" ]]; then
    export GIT_BRIDGE_IMAGE="$image_name"
  else
    export GIT_BRIDGE_IMAGE="$image_name:$version"
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
  | sed -r "s/^$name=([\"']?)(.+)\1\$/\2/"
}

function read_configuration() {
  local name=$1
  grep -E "^$name=" "$TOOLKIT_ROOT/config/overleaf.rc" \
  | sed -r "s/^$name=([\"']?)(.+)\1\$/\2/"
}

# Returns 0 if podman runtime is available (podman binary or docker shim)
is_podman() {
  command -v podman &>/dev/null && return 0

  if command -v docker &>/dev/null; then
    docker version 2>/dev/null | grep -qi podman && return 0
  fi

  return 1
}

# Check for quay.io login credentials.
# Sets: QUAY_LOGIN_STATUS ("true" or "false")
#       QUAY_LOGIN_USER (username if found, empty otherwise)
check_quay_login() {
  QUAY_LOGIN_STATUS=false
  QUAY_LOGIN_USER=""

  # Try podman --get-login first
  if command -v podman &>/dev/null; then
    QUAY_LOGIN_USER=$(podman login quay.io --get-login 2>/dev/null) || true
    if [[ -n "$QUAY_LOGIN_USER" ]]; then
      QUAY_LOGIN_STATUS=true
      return
    fi
  fi

  # Fall back to checking auth config files
  local auth_file
  for auth_file in \
    "$HOME/.config/containers/auth.json" \
    "$HOME/.docker/config.json" \
    "${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/containers/auth.json"; do
    if [[ -f "$auth_file" ]] && grep -q "quay.io" "$auth_file" 2>/dev/null; then
      QUAY_LOGIN_STATUS=true
      local auth_b64
      auth_b64=$(awk '/"quay.io"/{f=1} f&&/"auth"/{gsub(/.*"auth": *"/,""); gsub(/".*/,""); print; exit}' "$auth_file" 2>/dev/null) || true
      if [[ -n "$auth_b64" ]]; then
        QUAY_LOGIN_USER=$(printf '%s' "$auth_b64" | base64 -d 2>/dev/null | cut -d: -f1) || true
      fi
      return
    fi
  done
}

resolve_socket_path() {
  RESOLVED_SOCKET_PATH=""

  if [[ -f "$TOOLKIT_ROOT/config/overleaf.rc" ]]; then
    # shellcheck disable=SC1090
    source "$TOOLKIT_ROOT/config/overleaf.rc"
  fi

  if [[ -n "${DOCKER_SOCKET_PATH:-}" ]]; then
    RESOLVED_SOCKET_PATH="$DOCKER_SOCKET_PATH"
  elif [[ -n "${DOCKER_HOST:-}" ]]; then
    RESOLVED_SOCKET_PATH="${DOCKER_HOST#unix://}"
  elif [[ -S "/var/run/docker.sock" ]]; then
    RESOLVED_SOCKET_PATH="/var/run/docker.sock"
  else
    local runtime_dir="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
    if [[ -S "$runtime_dir/podman/podman.sock" ]]; then
      RESOLVED_SOCKET_PATH="$runtime_dir/podman/podman.sock"
    fi
  fi
}

test_socket_ping_host() {
  local socket_path="$1"
  SOCKET_PING_HOST_OK=false
  SOCKET_PING_HOST_OUTPUT="socket not found"

  if [[ ! -S "$socket_path" ]]; then
    return
  fi

  if ! command -v curl &>/dev/null; then
    SOCKET_PING_HOST_OUTPUT="curl not available"
    return
  fi

  SOCKET_PING_HOST_OUTPUT=$(curl -s --max-time 3 --unix-socket "$socket_path" http://localhost/_ping 2>&1) || true
  if [[ "$SOCKET_PING_HOST_OUTPUT" == "OK" ]]; then
    SOCKET_PING_HOST_OK=true
  fi
}

test_socket_ping_container() {
  local docker_cmd="${1:-docker}"
  SOCKET_PING_CONTAINER_OK=false
  SOCKET_PING_CONTAINER_OUTPUT="sharelatex not running"

  if $docker_cmd ps --format '{{.Names}}' 2>/dev/null | grep -qx sharelatex; then
    SOCKET_PING_CONTAINER_OUTPUT=$($docker_cmd exec sharelatex sh -c 'curl -s --max-time 3 --unix-socket /var/run/docker.sock http://localhost/_ping 2>&1') || true
    if [[ "$SOCKET_PING_CONTAINER_OUTPUT" == "OK" ]]; then
      SOCKET_PING_CONTAINER_OK=true
    fi
  fi
}

get_seccomp_expected_path() {
  echo "$HOME/.overleaf/seccomp/clsi-profile.json"
}

check_seccomp_config() {
  local seccomp_path
  seccomp_path=$(get_seccomp_expected_path)
  local ve="$TOOLKIT_ROOT/config/variables.env"

  SECCOMP_FILE_EXISTS=false
  SECCOMP_ENV_MATCHES=false
  SECCOMP_ENV_VALUE=""

  if [[ -f "$seccomp_path" ]]; then
    SECCOMP_FILE_EXISTS=true
  fi

  if [[ -f "$ve" ]]; then
    SECCOMP_ENV_VALUE=$(grep "^SECCOMP_PROFILE=" "$ve" 2>/dev/null | tail -1 | sed 's/^SECCOMP_PROFILE=//; s/["'\'']//g') || true
    if [[ "$SECCOMP_ENV_VALUE" == "$seccomp_path" ]]; then
      SECCOMP_ENV_MATCHES=true
    fi
  fi
}

# Check if SELinux module is loaded.
SELINUX_MODULE_NAME="podman_socket_clsi"
SELINUX_RULES=(
  "container_t container_runtime_t unix_stream_socket connectto"
  "container_t user_tmp_t sock_file write"
  "container_t user_tmp_t sock_file getattr"
)

# Check if SELinux module is loaded.
# Args: $1 = sudo command (e.g. "sudo -n" or "run_sudo")
# Sets: SELINUX_MODULE_LOADED (true/false)
check_selinux_module() {
  local sudo_cmd="${1:-sudo -n}"
  SELINUX_MODULE_LOADED=false

  if $sudo_cmd semodule -l 2>/dev/null | grep -q "^${SELINUX_MODULE_NAME}"; then
    SELINUX_MODULE_LOADED=true
  fi
}

# Verify SELinux module rules with sesearch.
# Args: $1 = sudo command (e.g. "sudo -n" or "run_sudo")
# Sets: SELINUX_RULES_OK (true/false), SELINUX_MISSING_RULES (array)
check_selinux_rules() {
  local sudo_cmd="${1:-sudo -n}"
  SELINUX_RULES_OK=true
  SELINUX_MISSING_RULES=()

  if ! command -v sesearch &>/dev/null; then
    return
  fi

  local rule
  for rule in "${SELINUX_RULES[@]}"; do
    read -r src target class perm <<< "$rule"
    if ! $sudo_cmd sesearch --allow -s "$src" -t "$target" -c "$class" -p "$perm" 2>/dev/null | grep -q "allow"; then
      SELINUX_RULES_OK=false
      SELINUX_MISSING_RULES+=("$rule")
    fi
  done
}