import discord
import logging
import config
import game

logging.basicConfig(level=logging.INFO)


class MyClient(discord.Client):
    async def on_ready(self):
        print('Logged on as', self.user)

    async def on_message(self, message):
        if message.author == self.user: # never respond to ourself. Just to be sure.
            return

        if not self.isAuthorisedMessage(message):
            return

        if message.content.startswith("!ee"):
            args = message.content[3:].strip().split()
            await self.onCommand(message.channel, args[0].lower(), args[1:])

    def isAuthorisedMessage(self, message):
        if "%s#%s" % (message.author.name, message.author.discriminator) == config.admin_name:
            return True
        admin_found = False
        for member in message.guild.members:
            if "%s#%s" % (member.name, message.author.discriminator) == config.admin_name:
                admin_found = True
                break
        if admin_found:
            for role in message.author.roles:
                if role.name == config.role:
                    return True
        return False

    async def onCommand(self, channel, command, args):
        if command == "start":
            if game.start("scenario_00_basic.lua", ""):
                await channel.send('Started server, game paused.')
            else:
                await channel.send('Failed to start (server already running?)')
        elif command == "stop":
            if game.stop():
                await channel.send('Stopped the server')
            else:
                await channel.send('Failed to stop the server')
        elif command == "pause":
            if game.pause():
                await channel.send('Paused the game')
            else:
                await channel.send('Failed to pause the game')
        elif command == "unpause":
            if game.pause():
                await channel.send('Unpaused the game')
            else:
                await channel.send('Failed to unpause the game')
        elif command == "help":
            await channel.send('Available commands: start stop pause unpause')
        else:
            await channel.send('Unknown command: %s' % (command))


client = MyClient()
client.run(config.token)
