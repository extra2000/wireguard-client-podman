FROM docker.io/library/ubuntu:22.04

RUN apt update && apt install -y wireguard iputils-ping iptables dos2unix iproute2 openresolv

COPY entrypoint.sh /bin/entrypoint.sh
RUN dos2unix /bin/entrypoint.sh

ENTRYPOINT ["/bin/entrypoint.sh"]
CMD ["/usr/bin/wg-quick", "up", "client"]
