#include "engine.h"
#include "mainMenus.h"
#include "main.h"
#include "epsilonServer.h"
#include "tutorialGame.h"
#include "playerInfo.h"
#include "gameGlobalInfo.h"
#include "spaceObjects/spaceship.h"
#include "mouseCalibrator.h"
#include "menus/shipSelectionScreen.h"
#include "menus/serverCreationScreen.h"
#include "menus/optionsMenu.h"
#include "menus/serverBrowseMenu.h"
#include "screens/gameMasterScreen.h"

MainMenu::MainMenu()
{
    constexpr float logo_size = 256;
    constexpr float title_y = 160;

    new GuiOverlay(this, "", colorConfig.background);
    (new GuiOverlay(this, "", sf::Color::White))->setTextureTiled("gui/BackgroundCrosses");

    (new GuiLabel(this, "TITLE_A", "Empty", 100))->setBold()->setAlignment(ACenterRight)->setPosition(-logo_size/2, title_y, ATopCenter)->setSize(0, 300);
    (new GuiLabel(this, "TITLE_B", "Epsilon", 100))->setAlignment(ACenterLeft)->setPosition(logo_size/2, title_y, ATopCenter)->setSize(0, 300);
    (new GuiImage(this, "LOGO", "logo_white"))->setPosition(0, title_y, ATopCenter)->setSize(logo_size, logo_size);
    (new GuiLabel(this, "VERSION", "Version: " + string(VERSION_NUMBER), 20))->setPosition(0, title_y + logo_size, ATopCenter)->setSize(0, 20);
    
    (new GuiButton(this, "START_SERVER", "Start server", [this]() {
        new EpsilonServer();
        if (game_server)
        {
            new ServerCreationScreen();
            destroy();
        }
    }))->setPosition(sf::Vector2f(50, -230), ABottomLeft)->setSize(300, 50);

    (new GuiButton(this, "START_CLIENT", "Start client", [this]() {
        new ServerBrowserMenu(ServerBrowserMenu::Local);
        destroy();
    }))->setPosition(sf::Vector2f(50, -170), ABottomLeft)->setSize(300, 50);

    (new GuiButton(this, "OPEN_OPTIONS", "Options", [this]() {
        new OptionsMenu();
        destroy();
    }))->setPosition(sf::Vector2f(50, -110), ABottomLeft)->setSize(300, 50);

    (new GuiButton(this, "QUIT", "Quit", [this]() {
        engine->shutdown();
    }))->setPosition(sf::Vector2f(50, -50), ABottomLeft)->setSize(300, 50);

    (new GuiButton(this, "START_TUTORIAL", "Tutorial", [this]() {
        destroy();
        new TutorialGame();
    }))->setPosition(sf::Vector2f(370, -50), ABottomLeft)->setSize(300, 50);

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
    (new GuiLabel(this, "CREDITS2", "Daid", 18))->setAlignment(ACenterRight)->setPosition(-50, y, ATopRight)->setSize(0, 18); y += 18;
    (new GuiLabel(this, "CREDITS3", "Nallath", 18))->setAlignment(ACenterRight)->setPosition(-50, y, ATopRight)->setSize(0, 18); y += 18;
    y += 10;
    (new GuiLabel(this, "CREDITS1", "Graphics:", 20))->setAlignment(ACenterRight)->setPosition(-50, y, ATopRight)->setSize(0, 20); y += 20;
    (new GuiLabel(this, "CREDITS3", "Interesting John", 18))->setAlignment(ACenterRight)->setPosition(-50, y, ATopRight)->setSize(0, 18); y += 18;
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
    (new GuiLabel(this, "CREDITS22", "Philippe Bruylant", 18))->setAlignment(ACenterRight)->setPosition(-50, y, ATopRight)->setSize(0, 18); y += 18;
    (new GuiLabel(this, "CREDITS23", "Ralf Leichter", 18))->setAlignment(ACenterRight)->setPosition(-50, y, ATopRight)->setSize(0, 18); y += 18;
    (new GuiLabel(this, "CREDITS24", "Lee McDonough (Flea)", 18))->setAlignment(ACenterRight)->setPosition(-50, y, ATopRight)->setSize(0, 18); y += 18;
    (new GuiLabel(this, "CREDITS25", "Mickael Houet", 18))->setAlignment(ACenterRight)->setPosition(-50, y, ATopRight)->setSize(0, 18); y += 18;

#ifdef DEBUG
    (new GuiButton(this, "START_TUTORIAL", "TO DA GM!", [this]() {
        new EpsilonServer();
        if (game_server)
        {
            gameGlobalInfo->startScenario("scenario_10_empty.lua");

            my_spaceship = nullptr;
            my_player_info->setShipId(-1);
            destroy();
            new GameMasterScreen();
        }
    }))->setPosition(sf::Vector2f(370, -150), ABottomLeft)->setSize(300, 50);
#endif
}
