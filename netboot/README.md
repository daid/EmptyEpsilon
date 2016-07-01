In this directory you will find the setup files to setup a network boot environment for EmptyEpsilon.

READ FIRST
==========
Do you know the following terms:

1. Linux

2. PXE

3. Commandline

4. DHCP

If not. Do not try to use this. You can seriously screw up your system if you do not know what you are doing.

What is this?
=============

It's a setup script for a network boot environment. Just about any computer build after the year 2000 has the feature to boot from the network. This means these computers do not need any actual harddisk to run.

Why is this useful for EmptyEpsilon? Well, it ensures that every computer runs the exact same version of EmptyEpsilon.
You only have to update a single machine and restart all others to get the latest version running wiht minimal fuzz.
It also reduces the amount of hardware dependencies, as only a single machine needs a working harddrive.
As harddrives are usually the first thing to break in a computer, this makes it easier to get donor computers for a setup.
We use a lot of donor laptops which no longer have harddisks and/or batteries.

With some added configuration, you can also have all these machines auto-connect to a server and reduce the overal setup times of your games. Which is more of an advanced use.

It DOES require a time investment before hand. Just installing this system takes about 3 hours. However, it saves us about 30 minutes in setup time when we want to run the game with 6 clients. As we no longer have to copy anything.

It also requires a wired network. Network booting does not work on wireless. The largest bit of our setup time is laying down all the cables.

This runs a DHCP server, as network booting does DHCP, this means it will require a stand alone network, or two network cards. The default setup is a stand-alone setup.

Installation
============
Start of by doing a fresh OS install of Linux Debian, Jessie. Use the "Netinstall" and only install the base system with standard utilities. No graphical shell, no server features.

Copy the "build_netboot_system.sh" script to the freshly installed machine. And make sure it has internet.

Run the "build_netboot_system.sh" script as root. This will take a long time as it will install extra tools, will download a whole extra Linux install for the network boot environment and compile EmptyEpsilon in this environment from source.

This "build_netboot_system.sh" script will setup your machine to have the network card serve DHCP. After running this it is not yet active, but on next reboot it will hand out IP addresses and mess up your local network. You have been warned!

So, before rebooting, disconnect the network cable, and then reboot. After rebooting, hook up a seperate stand-alone network with your clients connected.

For each client, you need to enable network booting in the BIOS. Every machine I've seen so far can do this, but it depends on the BIOS where and how this needs to be enabled.
If it is an option, and you are in the BIOS settings anyhow, check if you can boot up the machine on power connection. This saves you pressing the power button. Note: While this feature is present in a lot of computers, it does not always function. So do not depend on it.

Boot the client machines from the network with the new BIOS setup. And enjoy your easy EmptyEpsilon setup.

Configuration
=============
A tool called "config_manager.py" is provided. It is located in your home directory after the build_netboot_system.sh. This tool can be used to quickly edit and administrate different option.ini files per client. Start it with "python config_manager.py"

Per default, each client will show their name in the top left corner of the main menu. And per default each client has their MAC address as name.

The "config_manager.py" tool can set different names per client, with the "setname" command. Example "setname 00b0d0a6b323 Red_shirt" will name the machine with that mac address to "Red_shirt",
if that client is rebooted, it will show "Red_shirt" in the top left corner.

The "config_manager.py" tool can also reboot machines, restart EE on machines, set autoconnect-to-crew-position settings. And for more advanced uses, open option.ini files directly in an text editor, execute any command on remote machines.

Doing updates/changes/use internet
==================================
The "build_netboot_system.sh" script will install 3 helper scripts in your home directory.

If you run "dhcp_client.sh", the network port in the machine will switch to client mode and will stop serving DHCP request. This means you can hook it back up to your normal network, and access the internet from this machine. This will not stay this way if you reboot.

If you run "dhcp_server.sh", the network port is put back in dhcp mode, undoing the "dhcp_client.sh" script. Combined these scripts can be used to switch between serving EE, and having internet.

If you run "update.sh", it will try to update your local EmptyEpsilon installation. This requires internet, so you need "dhcp_client.sh" first.

distcc
======
