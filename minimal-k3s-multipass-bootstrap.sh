#!/bin/bash

set -eo pipefail

if "${DEBUG}"; then
    set -x
    set +e
fi

primary="primary"
nodes=("node1" "node2")
context="k3s-cluster"

public_key="${PUBLIC_SSH_KEY_PATH:?PUBLIC_SSH_KEY_PATH is not set or null}"
private_key="${PRIVATE_SSH_KEY_PATH:?PRIVATE_SSH_KEY_PATH is not set or null}"

createInstance() {
    multipass launch -n "$1" --cloud-init - <<EOF
users:
- name: ${USER}
  groups: sudo
  sudo: ALL=(ALL) NOPASSWD:ALL
  ssh_authorized_keys: 
  - $(cat "${public_key}")
EOF
}

getNodeIP() {
    multipass list | grep "$1" | awk '{print $3}'
}

installK3sPrimaryNode() {
    PRIMARY_IP=$(getNodeIP "$1")
    k3sup install --ip "$PRIMARY_IP" --context "$context" --user "$USER" --ssh-key "${private_key}"
}

joinK3sNode() {
    NODE_IP=$(getNodeIP "$1")
    k3sup join --server-ip "$PRIMARY_IP" --ip "$NODE_IP" --user "$USER" --ssh-key "${private_key}"
}

createInstance $primary

for node in "${nodes[@]}"; do
    createInstance "$node"
done

installK3sPrimaryNode $primary

for node in "${nodes[@]}"; do
    joinK3sNode "$node"
done
