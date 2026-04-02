#!/usr/bin/env bash
set -euo pipefail

NETWORK_NAME="${NETWORK_NAME:-labnet}"
SUBNET="${SUBNET:-172.20.0.0/16}"
GATEWAY="${GATEWAY:-172.20.0.1}"
IP_RANGE="${IP_RANGE:-172.20.1.0/24}"
RECREATE="${1:-}"

if ! command -v docker >/dev/null 2>&1; then
  printf 'docker is required but was not found in PATH\n' >&2
  exit 1
fi

if [[ "$RECREATE" != "" && "$RECREATE" != "--recreate" ]]; then
  printf 'Usage: %s [--recreate]\n' "$0" >&2
  exit 1
fi

network_exists() {
  docker network inspect "$NETWORK_NAME" >/dev/null 2>&1
}

current_network_value() {
  local template="$1"
  docker network inspect -f "$template" "$NETWORK_NAME"
}

create_network() {
  docker network create \
    --driver bridge \
    --subnet "$SUBNET" \
    --gateway "$GATEWAY" \
    --ip-range "$IP_RANGE" \
    "$NETWORK_NAME" >/dev/null

  printf 'Created network %s with subnet %s and dynamic range %s\n' \
    "$NETWORK_NAME" "$SUBNET" "$IP_RANGE"
}

if ! network_exists; then
  create_network
  exit 0
fi

CURRENT_SUBNET="$(current_network_value '{{(index .IPAM.Config 0).Subnet}}')"
CURRENT_GATEWAY="$(current_network_value '{{(index .IPAM.Config 0).Gateway}}')"
CURRENT_IP_RANGE="$(current_network_value '{{(index .IPAM.Config 0).IPRange}}')"

if [[ "$CURRENT_SUBNET" == "$SUBNET" && "$CURRENT_GATEWAY" == "$GATEWAY" && "$CURRENT_IP_RANGE" == "$IP_RANGE" ]]; then
  printf 'Network %s already matches the desired configuration\n' "$NETWORK_NAME"
  exit 0
fi

printf 'Network %s exists with different settings and cannot be updated in place\n' "$NETWORK_NAME" >&2
printf 'Current: subnet=%s gateway=%s ip_range=%s\n' "$CURRENT_SUBNET" "$CURRENT_GATEWAY" "${CURRENT_IP_RANGE:-<unset>}" >&2
printf 'Desired: subnet=%s gateway=%s ip_range=%s\n' "$SUBNET" "$GATEWAY" "$IP_RANGE" >&2

if [[ "$RECREATE" == "--recreate" ]]; then
  printf 'Recreating %s...\n' "$NETWORK_NAME"
  docker network rm "$NETWORK_NAME"
  create_network
  exit 0
fi

printf 'Stop containers attached to %s, then rerun %s --recreate\n' "$NETWORK_NAME" "$0" >&2
exit 1
