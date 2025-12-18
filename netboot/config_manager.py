import readline
import cmd
import os
import sys
import re

class Client:
    __CONFIG_PATH = "/srv/nfsroot/root/configs/"
    POSITIONS = [
        "none", "helms", "weapons", "engineering", "science", "relay",
        "tactical", "engineering+", "operations",
        "single",
        "damageControl", "powerManagement", "databaseView"
    ]

    def __init__(self, mac, ip):
        if os.path.isdir("test/"):
            self.__CONFIG_PATH = "test/"
        self.__mac = mac
        self.__ip = ip
        self.__name = "(same as MAC)"
        self.__auto_connect = False
        self.__ship = ""
        self.__station = ""
        try:
            f = open(self.getIniFilename(), "rt")
        except IOError:
            pass
        else:
            for line in f:
                if '#' in line:
                    line = line[:line.find("#")]
                if not '=' in line:
                    continue
                key, value = map(str.strip, line.strip().split("=", 1))
                if key == "instance_name":
                    self.__name = value
                elif key == "autoconnect":
                    if value:
                        position = int(value)
                        if position <= 0:
                            self.__auto_connect = False
                        else:
                            self.__auto_connect = True
                            self.__station = self.POSITIONS[position]
                    else:
                        self.__auto_connect = False
                elif key == "autoconnectship":
                    self.__ship = value
            f.close()
    
    def getMac(self):
        return self.__mac

    def getIp(self):
        return self.__ip
    
    def getName(self):
        return self.__name

    def setName(self, name):
        self.__name = name
        self.replaceInIni("instance_name", name)
    
    def setPosition(self, position):
        idx = None
        for pos in self.POSITIONS:
            if position.lower() == pos.lower():
                idx = self.POSITIONS.index(pos)
        if idx is None:
            print("Unknown position: [%s], possible positions: %s" % (position, ', '.join(self.POSITIONS)))
            return
        self.replaceInIni("autoconnect", idx)
    
    def getIniFilename(self):
        return os.path.join(self.__CONFIG_PATH, "%s.ini" % self.__mac)
    
    def replaceInIni(self, key, value):
        lines = []
        try:
            f = open(self.getIniFilename(), "rt")
            for line in f:
               if line.split("=")[0].strip() != key:
                   lines.append(line)
            f.close()
        except IOError:
            pass
        lines.append("%s=%s\n" % (key, value))
        f = open(self.getIniFilename(), "wt")
        for line in lines:
            f.write(line)
        f.close()

    def runOnClient(self, command):
        os.system("ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null %s '%s'" % (self.getIp(), command))

    def __repr__(self):
        if self.__auto_connect:
            return "{: >12} {: >20} {: >20} {: >20}".format(self.__mac, self.__name, self.__station, self.__ship)
        return "{: >12} {: >20}".format(self.__mac, self.__name)

class ClientDatabase:
    __LEASES_FILE = "/var/lib/misc/dnsmasq.leases"

    def __init__(self):
        if os.path.isfile("test/dnsmasq.leases"):
            self.__LEASES_FILE = "test/dnsmasq.leases"
    
    def getClients(self):
        clients = []
        for line in open(self.__LEASES_FILE, "rt"):
            mac_address = line.strip().split(" ")[1]
            ip_address = line.strip().split(" ")[2]
            mac_address = mac_address.replace(":", "")
            clients.append(Client(mac_address, ip_address))
        return clients
    
    def getWithName(self, name):
        if name == "":
            return []
        clients = self.getClients()
        if name == "all":
            return clients
        expr = "^"
        for char in name:
            if char == "*":
                expr += ".*"
            elif char == "?":
                expr += "."
            else:
                expr += char
        expr += "$"
        result = []
        for client in clients:
            if re.match(expr, client.getMac()) != None:
                result.append(client)
            elif re.match(expr, client.getName()) != None:
                result.append(client)
        return result

class ConfigCmd(cmd.Cmd):
    def __init__(self, client_database):
        cmd.Cmd.__init__(self)
        self.__client_database = client_database
    
    def _getClient(self, args):
        clients = self.__client_database.getWithName(args)
        if len(clients) == 1:
            return clients[0]
        print("Failed to find client with name '%s'." % (args))
        return None

    def _getClients(self, args):
        clients = self.__client_database.getWithName(args)
        if len(clients) > 0:
            return clients
        print("Failed to find clients with name '%s'." % (args))
        return []
    
    def do_list(self, args):
        'List all clients known to the server by their MAC address and name (if configured), and if connected to the server by their crew position and ship.'
        print()
        print("{: >12} {: >20} {: >20} {: >20}".format("MAC address", "Name", "Position", "Ship"))
        print("{: >12} {: >20} {: >20} {: >20}".format("============", "====================", "====================", "===================="))
        for client in self.__client_database.getClients():
            print(client)
        print()
    
    def do_edit(self, args):
        'Open the specified client\'s EmptyEpsilon Preferences File in the nano editor, or create a new file if none exists.\nExample: edit 00abcdef1234'
        client = self._getClient(args)
        if not client:
            return
        os.system("nano \"%s\"" % (client.getIniFilename()))
    
    def complete_edit(self, text, line, begidx, endidx):
        result = []
        for client in self.__client_database.getClients():
            if client.getMac().startswith(text):
                result.append(client.getMac())
            if client.getName().startswith(text):
                result.append(client.getName())
        return result

    def do_setname(self, args):
        'Set the specified client\'s name.\nExample: setname 00abcdef1234 Red_shirt'
        args = args.split(" ", 1)
        client = self._getClient(args[0])
        if not client:
            return
        client.setName(args[1])
    
    def complete_setname(self, text, line, begidx, endidx):
        return self.complete_edit(text, line, begidx, endidx)

    def do_setposition(self, args):
        'Set the specified client\'s autoconnect position.\nExample: setposition 00abcdef1234 helms'
        print("%s" % (', '.join(self.POSITIONS)))
        args = args.split(" ", 1)
        client = self._getClient(args[0])
        if not client:
            return
        client.setPosition(args[1])
    
    def complete_setname(self, text, line, begidx, endidx):
        return self.complete_edit(text, line, begidx, endidx)

    def do_exec(self, args):
        'Execute any command on the specified clients over SSH.\nExamples: exec 00abcdef1234 ip addr\n         exec all ip addr\n          exec 00ab* ip addr'
        args = args.split(" ", 1)
        for client in self._getClients(args[0]):
            client.runOnClient(args[1])

    def complete_exec(self, text, line, begidx, endidx):
        return self.complete_edit(text, line, begidx, endidx)

    def do_set(self, args):
        'Set or replace the value of any EmptyEpsilon Preferences File option on the specified clients.\nExamples: set 00abcdef1234 music_enabled 0\n        set all music_enabled 0\n          set 00ab* music_enabled 0'
        args = args.split(" ", 2)
        for client in self._getClients(args[0]):
            client.replaceInIni(args[1], args[2])

    def complete_set(self, text, line, begidx, endidx):
        return self.complete_edit(text, line, begidx, endidx)

    def do_reboot(self, args):
        'Reboot the specified clients.\nExamples: reboot 00abcdef1234\n          reboot all\n          reboot 00ab*'
        for client in self._getClients(args):
            client.runOnClient("reboot")

    def complete_reboot(self, text, line, begidx, endidx):
        return self.complete_edit(text, line, begidx, endidx)

    def do_restart(self, args):
        'Restart EmptyEpsilon on the specified client.\nExamples: restart 00abcdef1234\n          restart all\n          restart 00ab*'
        for client in self._getClients(args):
            client.runOnClient("systemctl restart emptyepsilon.service")

    def complete_restart(self, text, line, begidx, endidx):
        return self.complete_edit(text, line, begidx, endidx)
    
    def do_exit(self, args):
        'Exit this configuration tool.'
        return True

if len(sys.argv) > 1:
    ConfigCmd(ClientDatabase()).onecmd(" ".join(sys.argv[1:]))
else:
    ConfigCmd(ClientDatabase()).cmdloop()
