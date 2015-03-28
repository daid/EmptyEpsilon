#include "engine.h"
#include "mainMenus.h"
#include "main.h"
#include "crewUI.h"
#include "mainScreen.h"
#include "epsilonServer.h"
#include "playerInfo.h"
#include "gameGlobalInfo.h"
#include "spaceObjects/spaceship.h"
#include "mouseCalibrator.h"
#include "gui/shipSelectionScreen.h"
#include "gui/serverCreationScreen.h"

MainMenu::MainMenu()
{
}

void MainMenu::onGui()
{
    drawText(sf::FloatRect(0, 100, getWindowSize().x, 300), "Empty", AlignCenter, 180);
    drawText(sf::FloatRect(0, 250, getWindowSize().x, 300), "Epsilon", AlignCenter, 200);
    drawText(sf::FloatRect(0, 480, getWindowSize().x, 100), "Version: " + string(VERSION_NUMBER), AlignCenter, 20);

    if (drawButton(sf::FloatRect(50, 620, 300, 50), "Start server"))
    {
        new EpsilonServer();
        new ServerCreationScreen();
        destroy();
    }
    if (drawButton(sf::FloatRect(50, 680, 300, 50), "Start client"))
    {
        new ServerBrowserMenu();
        destroy();
    }
    if (drawButton(sf::FloatRect(50, 740, 300, 50), "Options"))
    {
        new OptionsMenu();
        destroy();
    }
    if (drawButton(sf::FloatRect(50, 800, 300, 50), "Quit") || InputHandler::keyboardIsPressed(sf::Keyboard::Escape))
    {
        engine->shutdown();
    }
    
    if (InputHandler::touch_screen)
    {
        if (drawButton(sf::FloatRect(getWindowSize().x - 350, 750, 300, 100), "Calibrate\nTouchscreen"))
        {
            new MouseCalibrator("default.calib");
            destroy();
        }
    }

    float y = 100;
    drawText(sf::FloatRect(0, y, getWindowSize().x - 50, 25), "Credits", AlignRight, 25); y+= 25;
    drawText(sf::FloatRect(0, y, getWindowSize().x - 50, 20), "Programming:", AlignRight, 20); y+= 20;
    drawText(sf::FloatRect(0, y, getWindowSize().x - 50, 18), "Daid (github.com/daid)", AlignRight, 18); y+= 18;
    drawText(sf::FloatRect(0, y, getWindowSize().x - 50, 18), "Nallath (github.com/nallath)", AlignRight, 18); y+= 18;
    y += 10;
    drawText(sf::FloatRect(0, y, getWindowSize().x - 50, 20), "Music:", AlignRight, 20); y+= 20;
    drawText(sf::FloatRect(0, y, getWindowSize().x - 50, 18), "Matthew Pablo (www.matthewpablo.com)", AlignRight, 18); y+= 18;
    y += 10;
    drawText(sf::FloatRect(0, y, getWindowSize().x - 50, 20), "Models:", AlignRight, 20); y+= 20;
    drawText(sf::FloatRect(0, y, getWindowSize().x - 50, 18), "Angryfly (turbosquid.com)", AlignRight, 18); y+= 18;
    y += 10;
    drawText(sf::FloatRect(0, y, getWindowSize().x - 50, 20), "Models:", AlignRight, 20); y+= 20;
    drawText(sf::FloatRect(0, y, getWindowSize().x - 50, 18), "SolCommand (http://solcommand.blogspot.com/)", AlignRight, 18); y+= 18;
    y += 10;
    drawText(sf::FloatRect(0, y, getWindowSize().x - 50, 20), "Crew sprites:", AlignRight, 20); y+= 20;
    drawText(sf::FloatRect(0, y, getWindowSize().x - 50, 18), "Tokka (http://bekeen.de/)", AlignRight, 18); y+= 18;
    y += 10;
    drawText(sf::FloatRect(0, y, getWindowSize().x - 50, 20), "Special thanks:", AlignRight, 20); y+= 20;
    drawText(sf::FloatRect(0, y, getWindowSize().x - 50, 18), "Marty Lewis (MadKat)", AlignRight, 18); y+= 18;
}

OptionsMenu::OptionsMenu()
{
}

void OptionsMenu::onGui()
{
    P<WindowManager> windowManager = engine->getObject("windowManager");
    if (drawButton(sf::FloatRect(50, 100, 300, 50), string("Fullscreen: ") + (windowManager->isFullscreen() ? "Yes" : "No")))
    {
        windowManager->setFullscreen(!windowManager->isFullscreen());
    }
    int fsaa = windowManager->getFSAA();
    if (fsaa < 1)
        fsaa = 1;
    int offset = drawSelector(sf::FloatRect(50, 160, 300, 50), "FSAA: " + string(fsaa) + "x");
    if (offset < 0 && fsaa > 1)
        windowManager->setFSAA(fsaa / 2);
    if (offset > 0 && fsaa < 8)
        windowManager->setFSAA(fsaa * 2);

    drawText(sf::FloatRect(50, 220, 300, 50), "Music Volume", AlignCenter);
    soundManager.setMusicVolume(drawHorizontalSlider(sf::FloatRect(50, 270, 300, 50), soundManager.getMusicVolume(), 0, 100, 50.0));

    if (drawButton(sf::FloatRect(50, 800, 300, 50), "Back") || InputHandler::keyboardIsPressed(sf::Keyboard::Escape))
    {
        destroy();
        returnToMainMenu();
    }
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
        if (drawToggleButton(sf::FloatRect(50, 50 + 35 * n, 700, 35), selectionIndex == n, serverList[n].name + " (" + serverList[n].address.toString() + ")"))
        {
            selectionIndex = n;
            manual_ip = serverList[selectionIndex].address.toString();
        }
    }
    if (manual_ip == sf::IpAddress::getLocalAddress().toString() && serverList.size() > 0)
        manual_ip = serverList[0].address.toString();

    if (drawButton(sf::FloatRect(50, 800, 300, 50), "Back") || InputHandler::keyboardIsPressed(sf::Keyboard::Escape))
    {
        destroy();
        returnToMainMenu();
    }

    if (selectionIndex < serverList.size())
    {
        if (drawButton(sf::FloatRect(450, 800, 300, 50), "Join"))
        {
            new JoinServerScreen(serverList[selectionIndex].address);
            destroy();
        }
    }else{
        drawDisabledButton(sf::FloatRect(450, 800, 300, 50), "Join");
    }

    manual_ip = drawTextEntry(sf::FloatRect(getWindowSize().x - 350, 740, 300, 50), manual_ip);
    if (drawButton(sf::FloatRect(getWindowSize().x - 350, 800, 300, 50), "Connect"))
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
    drawText(sf::FloatRect(0, 300, getWindowSize().x, 50), "Connecting...", AlignCenter);

    if (drawButton(sf::FloatRect(50, 800, 300, 50), "Cancel"))
    {
        destroy();
        disconnectFromServer();
        new ServerBrowserMenu();
        return;
    }

    //We connect with a slight delay, as the connect call when joining a server will block and thus not update the screen.
    if (connect_delay > 0)
    {
        connect_delay--;
        if (!connect_delay)
            new GameClient(ip);
    }else{
        if (!game_client->isConnected())
        {
            destroy();
            disconnectFromServer();
            new ServerBrowserMenu();
        }else if (game_client->getClientId() > 0)
        {
            foreach(PlayerInfo, i, player_info_list)
                if (i->client_id == game_client->getClientId())
                    my_player_info = i;
            if (my_player_info && gameGlobalInfo)
            {
                new ShipSelectionScreen();
                destroy();
            }
        }
    }
}

AutoConnectScreen::AutoConnectScreen(ECrewPosition crew_position, bool control_main_screen)
: crew_position(crew_position), control_main_screen(control_main_screen)
{
    scanner = new ServerScanner(VERSION_NUMBER);
}

AutoConnectScreen::~AutoConnectScreen()
{
    if (scanner)
        scanner->destroy();
}

void AutoConnectScreen::onGui()
{
    if (scanner)
    {
        std::vector<ServerScanner::ServerInfo> serverList = scanner->getServerList();
        drawText(sf::FloatRect(0, 300, getWindowSize().x, 50), "Searching for server...", AlignCenter, 50);

        if (serverList.size() > 0)
        {
            drawText(sf::FloatRect(0, 350, getWindowSize().x, 30), "Found server " + serverList[0].name, AlignCenter, 30);
            connect_to_address = serverList[0].address;
            connect_delay = 2;
            scanner->destroy();
        }
        string position_name = "Main screen";
        if (crew_position < max_crew_positions)
            position_name = getCrewPositionName(crew_position);
        drawText(sf::FloatRect(0, 400, getWindowSize().x, 30), position_name, AlignCenter, 50);
    }else{
        if (connect_delay > 0)
        {
            drawText(sf::FloatRect(0, 300, getWindowSize().x, 50), "Connecting...", AlignCenter, 50);
            connect_delay--;
            if (!connect_delay)
                new GameClient(connect_to_address);
        }else{
            if (!game_client->isConnected())
            {
                disconnectFromServer();
                scanner = new ServerScanner(VERSION_NUMBER);
            }else if (game_client->getClientId() > 0)
            {
                foreach(PlayerInfo, i, player_info_list)
                    if (i->client_id == game_client->getClientId())
                        my_player_info = i;
                if (my_player_info && gameGlobalInfo)
                {
                    drawText(sf::FloatRect(0, 300, getWindowSize().x, 50), "Waiting for ship...", AlignCenter, 50);
                    if (!my_spaceship)
                    {
                        for(int n=0; n<GameGlobalInfo::max_player_ships; n++)
                        {
                            P<PlayerSpaceship> ship = gameGlobalInfo->getPlayerShip(n);
                            if (ship && ship->ship_template)
                            {
                                int cnt = 0;
                                foreach(PlayerInfo, i, player_info_list)
                                    if (i->ship_id == ship->getMultiplayerId() && i->crew_position[n])
                                        cnt++;
                                if (cnt == 0)
                                {
                                    if (crew_position != max_crew_positions)
                                    {
                                        my_player_info->setCrewPosition(crew_position, true);
                                        my_player_info->setMainScreenControl(control_main_screen);
                                    }
                                    my_player_info->setShipId(ship->getMultiplayerId());
                                    my_spaceship = ship;
                                }
                            }
                        }
                    }else{
                        if (my_spaceship->getMultiplayerId() == my_player_info->ship_id && (crew_position == max_crew_positions || my_player_info->crew_position[crew_position]))
                        {
                            destroy();
                            my_player_info->spawnUI();
                        }
                    }
                }else{
                    drawText(sf::FloatRect(0, 300, getWindowSize().x, 50), "Waiting for game state...", AlignCenter, 50);
                }
            }
        }
    }
}
