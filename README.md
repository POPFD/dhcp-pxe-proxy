# PXE Proxy DHCP Server

A lightweight containerized PXE DHCP proxy server using dnsmasq that provides
network boot information to PXE clients without interfering with existing DHCP
servers. Configured to boot netboot.xyz for easy network installation of
operating systems.

## Features

- **Proxy DHCP Mode**: Only provides PXE boot information, does NOT assign IPs
- **Multi-Architecture Support**: BIOS, EFI x64, and ARM64 clients
- **Configurable Interface**: Network interface set via environment variable
- **netboot.xyz Integration**: Pre-configured for netboot.xyz boot files
- **Minimal Footprint**: Alpine Linux base (~10MB + dnsmasq)

## Requirements

- Existing DHCP server on your network (for IP assignment)
- TFTP server with netboot.xyz boot files at 192.168.50.250
- Docker and Docker Compose installed
- Network interface with access to your LAN

## Configuration

All configuration is done via environment variables in `docker-compose.yml`:

```yaml
environment:
  - INTERFACE=enp2s0              # Network interface to listen on
  - DHCP_RANGE=192.168.50.0       # Network range for proxy DHCP
  - TFTP_SERVER=192.168.50.250    # TFTP server IP address
  - BIOS_BOOTFILE=netboot.xyz.kpxe        # Boot file for BIOS clients
  - EFI_BOOTFILE=netboot.xyz.efi          # Boot file for EFI x64 clients
  - ARM64_BOOTFILE=netboot.xyz-arm64.efi  # Boot file for ARM64 clients
```

**Common configurations:**

- **Change network interface**: Set `INTERFACE` to your interface name (check with `ip link show`)
- **Different network**: Update `DHCP_RANGE` to match your subnet (e.g., `192.168.1.0`)
- **Custom TFTP server**: Set `TFTP_SERVER` to your server's IP
- **Different boot files**: Update bootfile names if using custom PXE images

## Usage

1. Start the container:
   ```bash
   docker-compose up -d
   ```

2. Check logs to see PXE requests:
   ```bash
   docker-compose logs -f
   ```

3. Stop the container:
   ```bash
   docker-compose down
   ```

4. Rebuild after configuration changes:
   ```bash
   docker-compose up --build -d
   ```

## How it Works

This uses dnsmasq's **proxy DHCP** mode with PXE service directives:

1. Your main DHCP server assigns IP addresses normally
2. This container listens for PXE boot requests on UDP port 67
3. When a PXE client boots, it receives two DHCP responses:
   - IP address and network config from your main DHCP server
   - Boot file information from this proxy DHCP server
4. The client then downloads the boot file from the TFTP server via UDP port 69
5. netboot.xyz loads, providing a menu of operating systems to install

## Supported Architectures

The proxy automatically detects client architecture and provides the
appropriate boot file:

- **x86 BIOS**: netboot.xyz.kpxe
- **x86-64 EFI**: netboot.xyz.efi
- **ARM64 EFI**: netboot.xyz-arm64.efi

## Troubleshooting

**No PXE boot menu appears:**
- Check logs: `docker-compose logs -f` should show DHCP requests
- Verify TFTP server is accessible: `ping 192.168.50.250`
- Ensure UDP port 67 is not blocked by firewall
- Verify correct network interface is set in docker-compose.yml

**Container fails to start:**
- Check interface name matches your system: `ip link show`
- Ensure no other DHCP server conflicts
- Verify `network_mode: host` is set (required for DHCP)

**TFTP timeout errors:**
- Verify TFTP server is running on port 69
- Check netboot.xyz files exist on TFTP server
- Test TFTP manually from another machine

## Network Architecture

```
PXE Client  <--DHCP-->  Router DHCP (assigns IP)
    |
    +-------<--DHCP-->  Proxy DHCP (provides boot info)
    |
    +-------<--TFTP-->  TFTP Server (sends boot files)
```

## Files

- `Dockerfile`: Container image definition
- `docker-compose.yml`: Service configuration
- `dnsmasq.conf`: PXE proxy DHCP configuration
- `entrypoint.sh`: Runtime interface configuration script

## Notes

- This is a **proxy DHCP** server - it requires an existing DHCP server
- DNS functionality is disabled (`port=0`)
- Only responds to PXE clients (broadcast requests)
- Uses `network_mode: host` for proper DHCP operation
- Requires `NET_ADMIN` and `NET_RAW` capabilities