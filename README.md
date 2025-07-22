# k3s-multipass-bootstrap

A quick and easy way to setup a local k3s Cluster using k3sup & Multipass.

## Prerequisites

- [k3sup](https://github.com/alexellis/k3sup)
- [Multipass](https://multipass.run)
- SSH key pair (generate with `ssh-keygen -t ed25519 -f demo-key`)

## Usage

```sh
export PUBLIC_SSH_KEY_PATH=./demo-key.pub
export PRIVATE_SSH_KEY_PATH=./demo-key
./minimal-k3s-multipass-bootstrap.sh create
```

The generated `kubeconfig` will be saved in the current directory.

## Cleanup

```sh
./minimal-k3s-multipass-bootstrap.sh delete
```

## Troubleshooting

- Ensure `multipass` and `k3sup` are installed and in your PATH.
- If you see permission errors, check your SSH key permissions.