#!/bin/sh

# Replace INTERFACE placeholder with actual interface name from env var
sed -i "s/INTERFACE_PLACEHOLDER/${INTERFACE:-eth0}/g" /etc/dnsmasq.d/pxe.conf

# Start dnsmasq
exec dnsmasq --no-daemon --log-queries --log-dhcp --port=0 -d
