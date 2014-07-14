#include "engine.h"
#include "mainMenus.h"
#include "main.h"
#include "epsilonServer.h"
#include "playerInfo.h"
#include "spaceship.h"
#include "shipSelectionScreen.h"

MainMenu::MainMenu()
{
}

void MainMenu::onGui()
{
    text(sf::FloatRect(0, 100, 1600, 300), "Empty", AlignCenter, 180);
    text(sf::FloatRect(0, 250, 1600, 300), "Epsilon", AlignCenter, 200);
    text(sf::FloatRect(0, 480, 1600, 100), "Version: " + string(VERSION_NUMBER), AlignCenter, 20);

    if (button(sf::FloatRect(50, 680, 300, 50), "Start server"))
    {
        new EpsilonServer();
        new ShipSelectionScreen();
        destroy();
    }
    if (button(sf::FloatRect(50, 740, 300, 50), "Start client"))
    {
        new ServerBrowserMenu();
        destroy();
    }
    if (button(sf::FloatRect(50, 800, 300, 50), "Quit"))
    {
        engine->shutdown();
    }

    float y = 100;
    text(sf::FloatRect(0, y, 1550, 25), "Credits", AlignRight, 25); y+= 25;
    text(sf::FloatRect(0, y, 1550, 20), "Programming:", AlignRight, 20); y+= 20;
    text(sf::FloatRect(0, y, 1550, 18), "Daid (github.com/daid)", AlignRight, 18); y+= 18;
    y += 10;
    text(sf::FloatRect(0, y, 1550, 20), "Music:", AlignRight, 20); y+= 20;
    text(sf::FloatRect(0, y, 1550, 18), "Matthew Pablo (www.matthewpablo.com)", AlignRight, 18); y+= 18;
    y += 10;
    text(sf::FloatRect(0, y, 1550, 20), "Models:", AlignRight, 20); y+= 20;
    text(sf::FloatRect(0, y, 1550, 18), "Angryfly (turbosquid.com)", AlignRight, 18); y+= 18;
}

ServerBrowserMenu::ServerBrowserMenu()
{
    scanner = new ServerScanner(VERSION_NUMBER);
    selectionIndex = 0;
    manual_ip = sf::IpAddress::getLocalAddress().toString();
}

ServerBrowserMenu::~ServerBrowserMenu()
{
    scanner->destroy();
}

void ServerBrowserMenu::onGui()
{
    std::vector<ServerScanner::ServerInfo> serverList = scanner->getServerList();
    for(unsigned int n=0; n<serverList.size(); n++)
    {
        if (toggleButton(sf::FloatRect(50, 50 + 35 * n, 700, 35), selectionIndex == n, serverList[n].name + " (" + serverList[n].address.toString() + ")"))
            selectionIndex = n;
    }

    if (button(sf::FloatRect(50, 800, 300, 50), "Back"))
    {
        destroy();
        new MainMenu();
    }

    if (selectionIndex < serverList.size())
    {
        if (button(sf::FloatRect(450, 800, 300, 50), "Join"))
        {
            new JoinServerScreen(serverList[selectionIndex].address);
            destroy();
        }
    }else{
        disabledButton(sf::FloatRect(450, 800, 300, 50), "Join");
    }

    manual_ip = textEntry(sf::FloatRect(1250, 740, 300, 50), manual_ip);
    if (button(sf::FloatRect(1250, 800, 300, 50), "Connect"))
    {
            new JoinServerScreen(sf::IpAddress(manual_ip));
            destroy();
    }
}

JoinServerScreen::JoinServerScreen(sf::IpAddress ip)
: ip(ip)
{
    connect_delay = 2;
}

void JoinServerScreen::onGui()
{
    text(sf::FloatRect(300, 300, 1000, 50), "Connecting...");

    if (button(sf::FloatRect(50, 800, 300, 50), "Cancel"))
    {
        destroy();
        disconnectFromServer();
        new ServerBrowserMenu();
        return;
    }

    if (connect_delay > 0)
    {
        connect_delay--;
        if (!connect_delay)
            new GameClient(ip);
    }else{
        if (!gameClient->isConnected())
        {
            destroy();
            disconnectFromServer();
            new ServerBrowserMenu();
        }else if (gameClient->getClientId() > 0)
        {
            foreach(PlayerInfo, i, playerInfoList)
                if (i->clientId == gameClient->getClientId())
                    my_player_info = i;
            if (my_player_info && gameGlobalInfo)
            {
                new ShipSelectionScreen();
                destroy();
            }
        }
    }
}
