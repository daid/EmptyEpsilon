The EmptyEpsilon repo includes a `netboot` directory containing scripts to build and configure a Preboot Execution Environment (PXE) server. A PXE server allows clients to boot an operating system and launch EmptyEpsilon over a network.

**This is an advanced configuration.** Unless you're familiar with Linux, PXE servers, DHCP, and working from the command line, don't attempt this. You can damage your operating system and lose data if you don't know what you're doing.

## What is this?

The `netboot/build_netboot_system.sh` setup script creates a network boot environment. Most computers built since the year 2000 can be configured to boot from a network server, even if they lack their own storage.

How is this useful for EmptyEpsilon? In a local network environment, you can use a PXE server to ensure that every system runs the exact same version of EmptyEpsilon, without needing to install any software onto those systems. You only have to update the server and restart the clients to run the latest version of EmptyEpsilon with minimal fuss.

It also reduces the number of hardware dependencies, since only one server must have a working storage device.
This makes it easier to find and use donor or recycled systems as EmptyEpsilon clients.

With some additional configuration, all of these clients can then autoconnect to the server and immediately launch into gameplay.

## Requirements

Setting up a PXE server and netboot requires planning and a time investment before play. The initial PXE server installation and configuration can take several hours. Once complete, however, you no longer have to copy, install, configure, and update EmptyEpsilon onto each client.

You also need to have a standalone wired network, or a second wired network interface on the server. The vast majority of unmodified devices don't support booting over WiFi. This process also runs a DHCP server to assign IP addresses to clients, which can't run on a network that already has a DHCP server.

## Installation

1. Perform a fresh OS install of Debian Linux. Use the Netinstall installer, and install only the base system with standard utilities, no graphical shell, and no server features.
1. Confirm that the freshly installed Debian system can access the internet.
1. Copy the `build_netboot_system.sh` script to the freshly installed Debian system.
1. Run `build_netboot_system.sh` as the root user. This installs several packages, downloads an additional Linux installation for the network boot environment, and compiles EmptyEpsilon in this environment from source.

   This script sets up your system to run a DHCP server over its network interface. After running this script, the DHCP server is not yet activated; however, on the following reboot it will distribute IP addresses to network clients. **If this system is an an existing network that already has an active DHCP server, this will disrupt your local network. You have been warned!**

1. Disconnect the network cable from the server.
1. Reboot.
1. After rebooting, connect the server and your clients (powered off) to a separate stand-alone wired network.
1. Power up each client and enter its BIOS.
1. Enable network booting in client's BIOS. This option depends on support in the system's BIOS, and steps to enable and configure can depend on the system.
1. If available in the client's BIOS, also enable booting upon power connection. This saves you from pressing the system's power button. While many systems support this feature, it isn't always dependable.
1. Boot the clients from the network with the new BIOS setup.

## Configuration

The `netboot` directory of this repo also includes a Python script named `config_manager.py`. After running `build_netboot_system.sh`, this script is also located in the server's home directory. Use this tool to edit and administrate `options.ini` Preferences Files for each client.

To launch it, run `python config_manager.py` from the server's home directory.

## Rename clients (setname)

By default, each client uses its hardware MAC address as its name and displays its name in the upper-left corner of the EmptyEpsilon main menu. You can configure names for each client using the `config_manager.py` tool's `setname` command. 

For example, to rename the system with a specific MAC address to `Red_shirt`, run:

`setname 00b0d0a6b323 Red_shirt`

When that client is rebooted, it will display `Red_shirt` in the upper-left corner.

### Other functions

The `config_manager.py` tool can also reboot systems, restart EE on systems, and configure autoconnect settings.

### Manual configuration

For more advanced uses, open the `options.ini` files directly in an text editor, or execute any command on the clients.

## Performing updates, changes, and using the internet

The `build_netboot_system.sh` script also installs three helper scripts in your server's home directory.

- If you run `dhcp_client.sh`, the system's network port switches to DHCP client mode and stops serving DHCP requests. This means you can reconnect it to your normal network and access the internet from this system. This doesn't persist if you reboot the server.

- If you run `dhcp_server.sh`, the system's network port switches back to DHCP server mode, undoing the `dhcp_client.sh` script. Combine these scripts to switch between serving EE and accessing the internet.

- If you run `update.sh`, the server attempts to update its local EmptyEpsilon installation. This requires internet, so you must first run `dhcp_client.sh`.

## Experimental distributed compiling (distcc)

Clients are also configured to distribute the compiling of EmptyEpsilon from source, which means every powered client can assist in building EmptyEpsilon.

For example, this reduced daid's compilation time from 20 minutes to 3 minutes. However, daid hasn't set up scripts to do this since it wasn't fully reliable.