#!/bin/bash

set -euo pipefail

if [ -n "${DEBUG:-}" ]; then
    set -x
    set +e
fi

function check_dependencies() {
    local dependencies=("multipass" "k3sup")
    for dep in "${dependencies[@]}"; do
        if ! command -v "$dep" &>/dev/null; then
            echo "Error: $dep is not installed." >&2
            exit 1
        fi
    done
}   

function create_nodes() {
    check_dependencies

    primary="primary"
    nodes=("node1" "node2")
    context="k3s-cluster"

    public_key="${PUBLIC_SSH_KEY_PATH:?PUBLIC_SSH_KEY_PATH is not set or null}"
    private_key="${PRIVATE_SSH_KEY_PATH:?PRIVATE_SSH_KEY_PATH is not set or null}"

    function createInstance() {
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

    createInstance "$primary"

    for node in "${nodes[@]}"; do
        createInstance "$node"
    done

    installK3sPrimaryNode "$primary"

    for node in "${nodes[@]}"; do
        joinK3sNode "$node"
    done
}

command="${1:-}"

case "$command" in

delete)
    multipass delete --all && multipass purge
    ;;

create)
    create_nodes
    ;;
*)
    echo """
    create - create 3 multipass instances and k3s cluster
    delete - delete multipass instances and k3s cluster
    """
    ;;
esac
