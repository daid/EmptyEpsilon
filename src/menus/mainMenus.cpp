#include "engine.h"
#include "mainMenus.h"
#include "main.h"
#include "epsilonServer.h"
#include "playerInfo.h"
#include "gameGlobalInfo.h"
#include "spaceObjects/spaceship.h"
#include "mouseCalibrator.h"
#include "menus/shipSelectionScreen.h"
#include "menus/serverCreationScreen.h"

MainMenu::MainMenu()
{
    (new GuiLabel(this, "TITLE_A", "Empty", 180))->setPosition(0, 100, ATopCenter)->setSize(0, 300);
    (new GuiLabel(this, "TITLE_B", "Epsilon", 200))->setPosition(0, 250, ATopCenter)->setSize(0, 300);
    (new GuiLabel(this, "VERSION", "Version: " + string(VERSION_NUMBER), 20))->setPosition(0, 30, ACenter)->setSize(0, 100);
    
    (new GuiButton(this, "START_SERVER", "Start server", [this]() {
        new EpsilonServer();
        new ServerCreationScreen();
        destroy();
    }))->setPosition(sf::Vector2f(50, -230), ABottomLeft)->setSize(300, 50);

    (new GuiButton(this, "START_CLIENT", "Start client", [this]() {
        new ServerBrowserMenu();
        destroy();
    }))->setPosition(sf::Vector2f(50, -170), ABottomLeft)->setSize(300, 50);

    (new GuiButton(this, "OPEN_OPTIONS", "Options", [this]() {
        new OptionsMenu();
        destroy();
    }))->setPosition(sf::Vector2f(50, -110), ABottomLeft)->setSize(300, 50);

    (new GuiButton(this, "QUIT", "Quit", [this]() {
        engine->shutdown();
    }))->setPosition(sf::Vector2f(50, -50), ABottomLeft)->setSize(300, 50);

    if (InputHandler::touch_screen)
    {
        (new GuiButton(this, "TOUCH_CALIB", "Calibrate\nTouchscreen", [this]() {
            destroy();
            new MouseCalibrator("");
        }))->setPosition(sf::Vector2f(-50, -50), ABottomRight)->setSize(300, 100);
    }

    float y = 100;
    (new GuiLabel(this, "CREDITS", "Credits", 25))->setAlignment(ACenterRight)->setPosition(-50, y, ATopRight)->setSize(0, 25); y += 25;
    (new GuiLabel(this, "CREDITS1", "Programming:", 20))->setAlignment(ACenterRight)->setPosition(-50, y, ATopRight)->setSize(0, 20); y += 20;
    (new GuiLabel(this, "CREDITS2", "Daid (github.com/daid)", 18))->setAlignment(ACenterRight)->setPosition(-50, y, ATopRight)->setSize(0, 18); y += 18;
    (new GuiLabel(this, "CREDITS3", "Nallath (github.com/nallath)", 18))->setAlignment(ACenterRight)->setPosition(-50, y, ATopRight)->setSize(0, 18); y += 18;
    y += 10;
    (new GuiLabel(this, "CREDITS4", "Music:", 20))->setAlignment(ACenterRight)->setPosition(-50, y, ATopRight)->setSize(0, 20); y += 20;
    (new GuiLabel(this, "CREDITS5", "Matthew Pablo", 18))->setAlignment(ACenterRight)->setPosition(-50, y, ATopRight)->setSize(0, 18); y += 18;
    (new GuiLabel(this, "CREDITS6", "Alexandr Zhelanov", 18))->setAlignment(ACenterRight)->setPosition(-50, y, ATopRight)->setSize(0, 18); y += 18;
    (new GuiLabel(this, "CREDITS7", "Joe Baxter-Webb", 18))->setAlignment(ACenterRight)->setPosition(-50, y, ATopRight)->setSize(0, 18); y += 18;
    (new GuiLabel(this, "CREDITS8", "neocrey", 18))->setAlignment(ACenterRight)->setPosition(-50, y, ATopRight)->setSize(0, 18); y += 18;
    (new GuiLabel(this, "CREDITS9", "FoxSynergy", 18))->setAlignment(ACenterRight)->setPosition(-50, y, ATopRight)->setSize(0, 18); y += 18;
    y += 10;
    (new GuiLabel(this, "CREDITS10", "Models:", 20))->setAlignment(ACenterRight)->setPosition(-50, y, ATopRight)->setSize(0, 20); y += 20;
    (new GuiLabel(this, "CREDITS11", "Angryfly (turbosquid.com)", 18))->setAlignment(ACenterRight)->setPosition(-50, y, ATopRight)->setSize(0, 18); y += 18;
    (new GuiLabel(this, "CREDITS12", "SolCommand (http://solcommand.blogspot.com/)", 18))->setAlignment(ACenterRight)->setPosition(-50, y, ATopRight)->setSize(0, 18); y += 18;
    y += 10;
    (new GuiLabel(this, "CREDITS13", "Crew sprites:", 20))->setAlignment(ACenterRight)->setPosition(-50, y, ATopRight)->setSize(0, 20); y += 20;
    (new GuiLabel(this, "CREDITS14", "Tokka (http://bekeen.de/)", 18))->setAlignment(ACenterRight)->setPosition(-50, y, ATopRight)->setSize(0, 18); y += 18;
    y += 10;
    (new GuiLabel(this, "CREDITS15", "Special thanks:", 20))->setAlignment(ACenterRight)->setPosition(-50, y, ATopRight)->setSize(0, 20); y += 20;
    (new GuiLabel(this, "CREDITS16", "Marty Lewis (MadKat)", 18))->setAlignment(ACenterRight)->setPosition(-50, y, ATopRight)->setSize(0, 18); y += 18;
    (new GuiLabel(this, "CREDITS17", "Serge Wroclawski", 18))->setAlignment(ACenterRight)->setPosition(-50, y, ATopRight)->setSize(0, 18); y += 18;
    (new GuiLabel(this, "CREDITS18", "Dennis Shelton", 18))->setAlignment(ACenterRight)->setPosition(-50, y, ATopRight)->setSize(0, 18); y += 18;
    (new GuiLabel(this, "CREDITS19", "VolgClawtooth", 18))->setAlignment(ACenterRight)->setPosition(-50, y, ATopRight)->setSize(0, 18); y += 18;
    (new GuiLabel(this, "CREDITS20", "Daniel Loftis", 18))->setAlignment(ACenterRight)->setPosition(-50, y, ATopRight)->setSize(0, 18); y += 18;
    (new GuiLabel(this, "CREDITS21", "David Concepcion", 18))->setAlignment(ACenterRight)->setPosition(-50, y, ATopRight)->setSize(0, 18); y += 18;
}

OptionsMenu::OptionsMenu()
{
    P<WindowManager> windowManager = engine->getObject("windowManager");
    
    (new GuiButton(this, "FULLSCREEN", "Fullscreen toggle", []() {
        P<WindowManager> windowManager = engine->getObject("windowManager");
        windowManager->setFullscreen(!windowManager->isFullscreen());
    }))->setPosition(50, 100, ATopLeft)->setSize(300, 50);

    int fsaa = std::max(1, windowManager->getFSAA());
    int index = 0;
    switch(fsaa)
    {
    case 8: index = 3; break;
    case 4: index = 2; break;
    case 2: index = 1; break;
    default: index = 0; break;
    }
    (new GuiSelector(this, "FSAA", [](int index, string value) {
        P<WindowManager> windowManager = engine->getObject("windowManager");
        windowManager->setFSAA((int[]){0, 2, 4, 8}[index]);
    }))->setOptions({"FSAA: off", "FSAA: 2x", "FSAA: 4x", "FSAA: 8x"})->setSelectionIndex(index)->setPosition(50, 160, ATopLeft)->setSize(300, 50);

    (new GuiLabel(this, "MUSIC_VOL_LABEL", "Music Volume", 30))->setPosition(50, 220, ATopLeft)->setSize(300, 50);
    (new GuiSlider(this, "MUSIC_VOL", 0, 100, soundManager->getMusicVolume(), [](float volume){
        soundManager->setMusicVolume(volume);
    }))->setPosition(50, 270, ATopLeft)->setSize(300, 50);

    (new GuiButton(this, "BACK", "Back", [this]() {
        destroy();
        returnToMainMenu();
    }))->setPosition(50, -50, ABottomLeft)->setSize(300, 50);
    
    GuiListbox* music_list = new GuiListbox(this, "MUSIC_PLAY", [this](int index, string value) {
        soundManager->playMusic(value);
    });
    music_list->setPosition(-50, 50, ATopRight)->setSize(600, 800);

    std::vector<string> music_filenames = findResources("music/*.ogg");
    std::sort(music_filenames.begin(), music_filenames.end());
    for(string filename : music_filenames)
        music_list->addEntry(filename.substr(filename.rfind("/") + 1, filename.rfind(".")), filename);
}

ServerBrowserMenu::ServerBrowserMenu()
{
    scanner = new ServerScanner(VERSION_NUMBER);

    (new GuiButton(this, "BACK", "Back", [this]() {
        destroy();
        returnToMainMenu();
    }))->setPosition(50, -50, ABottomLeft)->setSize(300, 50);

    connect_button = new GuiButton(this, "CONNECT", "Connect", [this]() {
        new JoinServerScreen(sf::IpAddress(manual_ip->getText()));
        destroy();
    });
    connect_button->setPosition(-50, -50, ABottomRight)->setSize(300, 50);
    
    manual_ip = new GuiTextEntry(this, "IP", "");
    manual_ip->setPosition(-50, -120, ABottomRight)->setSize(300, 50);
    
    server_list = new GuiListbox(this, "SERVERS", [this](int index, string value) {
        manual_ip->setText(value);
    });
    scanner->addCallbacks([this](sf::IpAddress address, string name) {
        //New server found
        server_list->addEntry(name + " (" + address.toString() + ")", address.toString());

        if (manual_ip->getText() == "")
            manual_ip->setText(address.toString());

    }, [this](sf::IpAddress address) {
        //Server removed from list
        server_list->removeEntry(server_list->indexByValue(address.toString()));
    });
    server_list->setPosition(0, 50, ATopCenter)->setSize(700, 600);
}

ServerBrowserMenu::~ServerBrowserMenu()
{
    scanner->destroy();
}

JoinServerScreen::JoinServerScreen(sf::IpAddress ip)
: ip(ip)
{
    (new GuiLabel(this, "STATUS", "Connecting...", 30))->setPosition(0, 300, ATopCenter)->setSize(0, 50);
    (new GuiButton(this, "BTN_CANCEL", "Cancel", [this]() {
        destroy();
        disconnectFromServer();
        new ServerBrowserMenu();
    }))->setPosition(50, -50, ABottomLeft)->setSize(300, 50);
    
    new GameClient(ip);
}

void JoinServerScreen::update(float delta)
{
    if (game_client->isConnecting())
    {
        //If we are still trying to connect, do nothing.
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
    
    status_label = new GuiLabel(this, "STATUS", "Searching for server...", 50);
    status_label->setPosition(0, 300, ATopCenter)->setSize(0, 50);

    string position_name = "Main screen";
    if (crew_position < max_crew_positions)
        position_name = getCrewPositionName(crew_position);

    (new GuiLabel(this, "POSITION", position_name, 50))->setPosition(0, 400, ATopCenter)->setSize(0, 30);
}

AutoConnectScreen::~AutoConnectScreen()
{
    if (scanner)
        scanner->destroy();
}

void AutoConnectScreen::update(float delta)
{
    if (scanner)
    {
        std::vector<ServerScanner::ServerInfo> serverList = scanner->getServerList();

        if (serverList.size() > 0)
        {
            status_label->setText("Found server " + serverList[0].name);
            connect_to_address = serverList[0].address;
            new GameClient(serverList[0].address);
            scanner->destroy();
        }else{
            status_label->setText("Searching for server...");
        }
    }else{
        if (game_client->isConnecting())
        {
            status_label->setText("Connecting: " + connect_to_address.toString());
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
                    status_label->setText("Waiting for ship...");
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
                    status_label->setText("Connected, waiting for game data...");
                }
            }
        }
    }
}
