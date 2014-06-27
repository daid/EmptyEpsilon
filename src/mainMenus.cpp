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
}

ServerBrowserMenu::ServerBrowserMenu()
{
    scanner = new ServerScanner(VERSION_NUMBER);
    selectionIndex = 0;
}

void ServerBrowserMenu::onGui()
{
    std::vector<ServerScanner::ServerInfo> serverList = scanner->getServerList();
    for(unsigned int n=0; n<serverList.size(); n++)
    {
        if (button(sf::FloatRect(50, 50 + 30 * n, 500, 30), (selectionIndex == n ? "*" : "") + serverList[n].name + " (" + serverList[n].address.toString() + ")"))
            selectionIndex = n;
    }
    
    if (button(sf::FloatRect(50, 800, 300, 50), "Back"))
    {
        destroy();
        new MainMenu();
    }
    if (button(sf::FloatRect(450, 800, 300, 50), "Join"))
    {
        if (selectionIndex < serverList.size())
        {
            sf::IpAddress ip = serverList[selectionIndex].address;
            destroy();
            new GameClient(ip);
            new JoinServerScreen();
        }
    }
}

JoinServerScreen::JoinServerScreen()
{
}

void JoinServerScreen::onGui()
{
    text(sf::FloatRect(300, 300, 1000, 50), "Connecting...");
    
    if (button(sf::FloatRect(50, 800, 300, 50), "Cancel") || !gameClient)
    {
        destroy();
        disconnectFromServer();
        new ServerBrowserMenu();
    }

    if (gameClient->getClientId() > 0)
    {
        foreach(PlayerInfo, i, playerInfoList)
            if (i->clientId == gameClient->getClientId())
                myPlayerInfo = i;
        if (myPlayerInfo && gameGlobalInfo)
        {
            new ShipSelectionScreen();
            destroy();
        }
    }
}
