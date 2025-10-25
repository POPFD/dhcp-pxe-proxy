# PXE Proxy DHCP Server

This Docker Compose setup creates a lightweight Alpine Linux container running dnsmasq in **proxy DHCP mode**. It only provides PXE boot information and does NOT assign IP addresses.

## What it does

- Listens for PXE boot requests
- Provides boot filename and TFTP server information
- Does NOT interfere with your existing DHCP server
- Works alongside your regular DHCP server

## Requirements

- Existing DHCP server on your network (for IP assignment)
- TFTP server with your boot files (separate from this container)
- Docker and Docker Compose installed

## Configuration

Before starting, edit `dnsmasq.conf` and update:

1. **TFTP Server IP**: Change `192.168.1.250` to your actual TFTP server address
   ```
   dhcp-option=66,192.168.1.250
   ```

2. **Network Range**: Adjust the proxy DHCP range if needed
   ```
   dhcp-range=192.168.50.0,proxy
   ```

3. **Network Interface**: Change `enp2s0` if your host uses a different interface
   ```
   interface=enp2s0
   ```

## Usage

1. Start the container:
   ```bash
   docker-compose up -d
   ```

2. Check logs:
   ```bash
   docker-compose logs -f
   ```

3. Stop the container:
   ```bash
   docker-compose down
   ```

## How it Works

This uses dnsmasq's **proxy DHCP** mode:
- Your main DHCP server assigns IP addresses normally
- This container listens for PXE requests on port 67
- When a PXE client boots, it receives:
  - IP address from your main DHCP server
  - Boot information from this proxy DHCP server

## Troubleshooting

- Ensure no firewall is blocking UDP port 67
- The container uses `network_mode: host` for DHCP to work properly
- Check that your TFTP server is accessible from the network
- View logs to see DHCP requests: `docker-compose logs -f`

## Notes

- This is a **proxy DHCP** server - it requires an existing DHCP server
- The container is minimal (~10MB Alpine + dnsmasq)
- DNS functionality is disabled (port=0)
- Only responds to PXE clients