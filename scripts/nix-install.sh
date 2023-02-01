#!/usr/bin/env bash

# Set strict error checking
set -euo pipefail
LC_CTYPE=C

# Enable debug output if $DEBUG is set to true
[ "${DEBUG:="false"}" = "true" ] && set -x

# Required vars
HOST_OS=${HOST_OS:?'HOST_OS is not set'}

# Optional vars
NIX_VERSION="${NIX_VERSION:="2.13.2"}"
INSTALL_URL="${INSTALL_URL:="https://releases.nixos.org/nix/nix-${NIX_VERSION}/install"}"

# Create a temporary workdir
TMPDIR=$(mktemp -d)
trap 'rm -rf "${TMPDIR}"' EXIT INT QUIT TERM


# Configure Nix
add_config() {
  echo "$1" | tee -a "${TMPDIR}/nix.conf" >/dev/null
}

if [ -n "$(command -v nix)" ]; then
  echo "Aborting: Nix is already installed at $(command -v nix)"
  exit
fi

if [[ -z "$(command -v git)" ]]; then
  xcode-select --install
fi

# Set jobs to number of cores
add_config "max-jobs = auto"

# Allow binary caches for user
add_config "trusted-users = root @wheel ${USER}"

# Enable flakes
add_config "experimental-features = nix-command flakes"

# Nix installer flags
INSTALL_OPTS=(
  --no-channel-add
#  --darwin-use-unencrypted-nix-store-volume
  --nix-extra-conf-file "${TMPDIR}/nix.conf"
  --daemon
)

CURL_RETRIES=5
while ! curl -sS -o "${TMPDIR}/install" --fail -L "${INSTALL_URL}"; do
  sleep 1
  ((CURL_RETRIES--))
  if [[ $CURL_RETRIES -le 0 ]]; then
    echo "curl retries failed" >&2
    exit 1
  fi
done

sh "$TMPDIR/install" "${INSTALL_OPTS[@]}"


# Prep for nix-darwin
if [[ "${HOST_OS}"=="darwin" ]]; then
  echo -e "run\tprivate/var/run" | sudo tee -a /etc/synthetic.conf >/dev/null
  /System/Library/Filesystems/apfs.fs/Contents/Resources/apfs.util -B 2>/dev/null
fi
