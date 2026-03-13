# IoNix (internet of nix)

# IoNixOS

IoNixOS is a specialized NixOS distribution optimized for the Raspberry Pi Zero 2W, designed to function as a high-reliability, headless remote deployment and hardware debugging node. It leverages Nix Flakes for cross-compilation and state-managed configurations, providing an immutable environment for OpenOCD-based firmware injection and edge-AI execution.

## Key Features

* **Immutable Infrastructure**: Fully declarative system state defined via Nix Flakes.
* **Remote Hardware Bridging**: Pre-configured OpenOCD bridge for remote SWD/JTAG debugging over TCP.
* **Optimized for ARMv8**: Custom kernel parameters and module blacklisting to maximize the 512MB RAM overhead of the RPi 02W.
* **Automated Networking**: Dynamic SSID generation based on hardware CPU ID with automated uap0 virtual AP failover.

## Technical Specifications

| Component | Detail |
| --- | --- |
| **Target Architecture** | `aarch64-linux` |
| **Base System** | NixOS Unstable (Nixpkgs) |
| **Kernel Packages** | `linuxPackages_rpi02w` |
| **SWD Interface** | Linux GPIOD (Pins 19/26) |
| **Default IPv4** | `192.168.57.7/24` |

## Deployment Workflow

### 1. Build and Provisioning

As the Raspberry Pi Zero 2W lacks sufficient memory for local evaluation, the system image must be cross-compiled on a host machine:

```bash
# Generate the bootable SD image
nix build .#nixosConfigurations.ionix.config.system.build.sdImage

```

### 2. Remote Configuration Management

Post-deployment updates are handled via `nixos-rebuild`, targeting the node over the management network. This avoids local resource exhaustion during system activation:

```bash
nixos-rebuild switch --flake .#ionix \
  --target-host ionix@192.168.57.7 \
  --sudo --ask-sudo-password

```

## Hardware Interfacing

### OpenOCD Bridge

The system initializes an OpenOCD server on boot, listening on ports `3333` (GDB), `4444` (Telnet), and `6666` (TCL). The default transport is configured for SWD via the following GPIO mapping:

* **SWDIO**: GPIO 19
* **SWCLK**: GPIO 26

### Integrated Display (SSD1306)

Hardware overlays are provided for SPI-based SSD1306 OLED displays, utilizing a custom device tree fragment for pin-muxing on GPIO 24 (Reset) and GPIO 25 (DC).

## License

This project is licensed under the **GNU General Public License v3.0**. See the `LICENSE` file for full legal text.
