# Deluge with WebUI and WireGuard

Docker container which runs the latest headless Deluge client with WebUI while connecting to WireGuard with iptables killswitch to prevent IP leakage when the tunnel goes down.

## Docker Features

- Base: Ubuntu 22.04
- Latest deluge
- Size: 403MB
- Selectively enable or disable WireGuard support
- Iptables killswitch to prevent IP leaking when VPN connection fails
- Specify name servers to add to container
- Configure UID, GID, and UMASK for config files and downloads by Deluge

# Run container from Docker registry

The container is available from the Docker registry and this is the simplest way to get it.
To run the container use this command:

```
$ docker run --privileged  -d \
              -v /your/deluge/path/:/config/deluge \
              -v /your/wireguard/wg0.conf:/config/wireguard/wg0.conf \
              -v /your/downloads/path/:/downloads \
              -e "VPN_ENABLED=yes" \
              -e "LAN_NETWORK=192.168.1.0/24" \
              -e "NAME_SERVERS=8.8.8.8,8.8.4.4" \
              -p 8112:8112 \
              rikjan/deluge-wireguard
```

# Variables, Volumes, and Ports

## Environment Variables

| Variable            | Required | Function                                                                            | Example                                 |
| ------------------- | -------- | ----------------------------------------------------------------------------------- | ----------------------------------------|
| `VPN_ENABLED`       | Yes      | Enable VPN? (yes/no) Default:yes                                                    | `VPN_ENABLED=yes`                       |
| `VPN_CONFIG`        | No       | Path to WireGuard config file. Default first file: /config/wireguard/*.conf         | `VPN_CONFIG=/config/wireguard/wg0.conf` |
| `LAN_NETWORK`       | Yes      | Local Network with CIDR notation                                                    | `LAN_NETWORK=192.168.1.0/24`            |
| `NAME_SERVERS`      | No       | Comma delimited name servers                                                        | `NAME_SERVERS=8.8.8.8,8.8.4.4`          |
| `PUID`              | No       | UID applied to config files and downloads                                           | `PUID=100`                              |
| `PGID`              | No       | GID applied to config files and downloads                                           | `PGID=100`                              |
| `UMASK`             | No       | GID applied to config files and downloads                                           | `UMASK=002`                             |

## Volumes

| Volume        | Required | Function                                   | Example                                               |
| ------------- | -------- | -------------------------------------------| ------------------------------------------------------|
| `deluge`      | Yes      | Deluge config files                        | `/your/deluge/path/:/config/deluge`                   |
| `client.ovpn` | No       | WireGuard config file if `VPN_ENABLED=yes` | `/your/wireguard/wg0.conf:/config/wireguard/wg0.conf` |
| `downloads`   | No       | Default download path for torrents         | `/your/downloads/path/:/downloads`                    |

## Ports

| Port    | Proto | Required | Function              | Example           |
| ------- | ----- | -------- | --------------------- | ----------------- |
| `8112`  | TCP   | Yes      | Deluge WebUI          | `8112:8112`       |

# Access the WebUI

Access http://IPADDRESS:PORT from a browser on the same network.

## Default Credentials

| Credential       | Default Value |
| ---------------- | ------------- |
| `WebUI Username` | admin         |
| `WebUI Password` | deluge        |

# How to use OpenVPN

The container will fail to boot if `VPN_ENABLED` is set to yes or empty and a *.conf is not present in the /config/wireguard directory. Drop a .conf file from your VPN provider into /config/wireguard and start the container again.

**Note:** The script will use the first WireGuard file (.conf) it finds in the /config/wireguard directory. Adding multiple WireGuard files will not start multiple VPN connections.

## PUID/PGID

User ID (PUID) and Group ID (PGID) can be found by issuing the following command for the user you want to run the container as:

```
id <username>
```

# Issues

If you are having issues with this container please submit an issue on GitHub.
Please provide logs, docker version and other information that can simplify reproducing the issue.
Using the latest stable verison of Docker is always recommended. Support for older version is on a best-effort basis.

# Building the container yourself

To build this container, clone the repository and cd into it.

## Build it:

```
$ cd /repo/location/
$ docker build -t deluge-wireguard .
```

## Run it:

```
$ docker run --privileged  -d \
              -v /your/deluge/path/:/config/deluge \
              -v /your/wireguard/wg0.conf:/config/wireguard/wg0.conf \
              -v /your/downloads/path/:/downloads \
              -e "VPN_ENABLED=yes" \
              -e "LAN_NETWORK=192.168.1.0/24" \
              -e "NAME_SERVERS=8.8.8.8,8.8.4.4" \
              -p 8112:8112 \
              deluge-wireguard
```

This will start a container as described in the "Run container from Docker registry" section.
