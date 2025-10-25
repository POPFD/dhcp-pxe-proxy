#!/bin/sh

# Replace placeholders with actual values from environment variables
sed -i "s/INTERFACE_PLACEHOLDER/${INTERFACE:-eth0}/g" /etc/dnsmasq.d/pxe.conf
sed -i "s/DHCP_RANGE_PLACEHOLDER/${DHCP_RANGE:-192.168.50.0}/g" /etc/dnsmasq.d/pxe.conf
sed -i "s/TFTP_SERVER_PLACEHOLDER/${TFTP_SERVER:-192.168.50.250}/g" /etc/dnsmasq.d/pxe.conf
sed -i "s/BIOS_BOOTFILE_PLACEHOLDER/${BIOS_BOOTFILE:-netboot.xyz.kpxe}/g" /etc/dnsmasq.d/pxe.conf
sed -i "s/EFI_BOOTFILE_PLACEHOLDER/${EFI_BOOTFILE:-netboot.xyz.efi}/g" /etc/dnsmasq.d/pxe.conf
sed -i "s/ARM64_BOOTFILE_PLACEHOLDER/${ARM64_BOOTFILE:-netboot.xyz-arm64.efi}/g" /etc/dnsmasq.d/pxe.conf

# Start dnsmasq
exec dnsmasq --no-daemon --log-queries --log-dhcp --port=0 -d
