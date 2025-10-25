FROM alpine:latest

# Install dnsmasq
RUN apk add --no-cache dnsmasq && \
    mkdir -p /etc/dnsmasq.d && \
    echo "conf-dir=/etc/dnsmasq.d/,*.conf" > /etc/dnsmasq.conf

# Copy config file and entrypoint script
COPY dnsmasq.conf /etc/dnsmasq.d/pxe.conf
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose DHCP ports
EXPOSE 67/udp 69/udp

# Use entrypoint script to configure interface at runtime
ENTRYPOINT ["/entrypoint.sh"]
