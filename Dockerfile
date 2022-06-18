FROM ubuntu:22.04
LABEL maintainer="rikjan"

VOLUME /downloads
VOLUME /config

ARG DEBIAN_FRONTEND="noninteractive"

RUN usermod -u 99 nobody

# Update packages and install software
RUN apt-get update \
    && apt-get install -y software-properties-common \
    && add-apt-repository -y ppa:deluge-team/stable \
    && apt-get update \
    && apt-get install -y deluged deluge-web deluge-console wireguard iptables ipcalc net-tools moreutils iproute2 openresolv dos2unix \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


# Add configuration and scripts
ADD deluge/ /etc/deluge/
ADD wireguard/ /etc/wireguard/

RUN chmod +x /etc/deluge/*.sh /etc/deluge/*.init /etc/wireguard/*.sh

# Expose ports and run
EXPOSE 8112 58846 58946 58946/udp
CMD ["/bin/bash", "/etc/wireguard/start.sh"]