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
sudo semodule -i selinux/wireguard_client.cil /usr/share/udica/templates/base_container.cil
```


## Configurations

Put your `conf` file into `configs/` and rename it as `client-01.conf`. Then, allow to be mounted into container:
```
chcon -v -t container_file_t ./configs/client-01.conf
```


## Using Rootless Podman `run` to provide VPN access to existing Podman pod

To provide VPN access to existing pod (assuming the pod name is `mypod`), execute the following command:
```
podman run -it --rm --pod=mypod -v ./configs/client-01.conf:/etc/wireguard/client.conf:ro --cap-add CAP_NET_ADMIN --cap-add CAP_NET_RAW --security-opt label=type:wireguard_client.process extra2000/wireguard-client
```


## Routing VPN access to Linux host (Require Rootful Podman)

Verify that IP forwarding is enabled in the container:
```
sudo podman exec -it wireguard-client-01-pod-srv01 sysctl -a | grep forward
```

If not enabled, try destroy and re-create pod.

Get the wireguard client container IP address:
```
sudo podman container inspect wireguard-client-01-pod-srv01 | grep IPAddress
```

Assuming the IP address of the container is `10.88.0.2`, execute the following command on host:
```
sudo ip route add 192.168.123.0/24 via 10.88.0.2
```


## Routing VPN access to Windows host (WSL2, Rootful Podman)

Find out WSL2 IP address:
```
wsl hostname -I
```

Assuming the WSL2 IP address is `172.28.96.149`, execute the following powershell command as `Administrator`:
```
route add 192.168.123.0 mask 255.255.255.0 172.24.63.186
```


## Known Issues

To fix error "iptables v1.8.4 (legacy): can't initialize iptables table 'nat': Table does not exist (do you need to insmod?)", try to load `ip_tables` kernel module using the following command:
```
sudo modprobe ip_tables
```

This usually occurs on AlmaLinux 8.5.
