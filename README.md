# k3s-multipass-bootstrap

A quick and easy way to setup a local k3s Cluster using k3sup & Multipass.

Requires the following to be installed:

* [k3sup](https://github.com/alexellis/k3sup)
* [Multipass](https://multipass.run)

Requires two Environment Variables:
`PUBLIC_SSH_KEY_PATH` - File Path to Public SSH Key for Multipass Instances
`PRIVATE_SSH_KEY_PATH` - File Path to Private SSH Key for Multipass Instances

Example:

`PUBLIC_SSH_KEY_PATH=./demo-key.pub PRIVATE_SSH_KEY_PATH=./demo-key ./minimal-k3s-multipass-bootstrap.sh`

The `kubeconfig` will be stored in the directory from where the script is ran.

Clearing the VM Instances:

`multipass delete --all && multipass purge`
