# wireguard-client-podman

| License | Versioning |
| ------- | ---------- |
| [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT) | [![semantic-release: angular](https://img.shields.io/badge/semantic--release-angular-e10079?logo=semantic-release)](https://github.com/semantic-release/semantic-release) |

Wireguard VPN client deployment using Podman.


## Building image

```
podman build -t extra2000/wireguard-client .
```


## Load SELinux policy

```
sudo semodule -i selinux/wireguard_client_podman.cil /usr/share/udica/templates/base_container.cil
```


## Configurations

Put your `conf` file into `configs/` and rename it as `client.conf`. Then, allow to be mounted into container:
```
chcon -v -t container_file_t ./configs/client.conf
```


## Running with Static IPv4

Create a pod with static IPv4 address:
```
sudo podman pod create --ip 10.88.1.2 --name wireguard-client-pod
```

Spawn an wireguard container into the pod to configure the pod as a VPN gateway:
```
sudo podman run -it --rm \
    --pod wireguard-client-pod \
    --cap-add CAP_NET_ADMIN \
    --cap-add CAP_NET_RAW \
    -v ./configs/client.conf:/etc/wireguard/client.conf:ro \
    --security-opt label=type:wireguard_client_podman.process \
    --name wireguard-client-pod-srv01 \
    extra2000/wireguard-client
```

The container will exit but the VPN connection from the pod is still exists. To route IPv4 address from the Wireguard pod, execute the following command on host:
```
sudo ip route add 192.168.123.0/24 via 10.88.1.2
```

Change `192.168.123.0/24` according to your IP range that you want to access.


## Using Rootless Podman `run` to provide VPN access to existing Podman pod

To provide VPN access to existing pod (assuming the pod name is `mypod`), execute the following command:
```
podman run -it --rm \
    --pod mypod \
    --cap-add CAP_NET_ADMIN \
    --cap-add CAP_NET_RAW \
    -v ./configs/client.conf:/etc/wireguard/client.conf:ro \
    --security-opt label=type:wireguard_client.process \
    extra2000/wireguard-client
```
