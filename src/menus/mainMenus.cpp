#include <i18n.h>
#include "engine.h"
#include "mainMenus.h"
#include "main.h"
#include "preferenceManager.h"
#include "epsilonServer.h"
#include "playerInfo.h"
#include "gameGlobalInfo.h"
#include "spaceObjects/spaceship.h"
#include "mouseCalibrator.h"
#include "menus/serverCreationScreen.h"
#include "menus/optionsMenu.h"
#include "menus/tutorialMenu.h"
#include "menus/serverBrowseMenu.h"
#include "screens/gm/gameMasterScreen.h"
#include "screenComponents/rotatingModelView.h"

#include "gui/gui2_image.h"
#include "gui/gui2_label.h"
#include "gui/gui2_button.h"
#include "gui/gui2_textentry.h"

class DebugAllModelView : public GuiCanvas
{
public:
    DebugAllModelView()
    {
        new GuiOverlay(this, "", colorConfig.background);
        (new GuiOverlay(this, "", sf::Color::White))->setTextureTiled("gui/BackgroundCrosses");

        std::vector<string> names = ModelData::getModelDataNames();
        names.erase(std::remove_if(names.begin(), names.end(), [](const string& name) { return name.startswith("transport_"); }), names.end());
        names.erase(std::remove_if(names.begin(), names.end(), [](const string& name) { return name.startswith("artifact"); }), names.end());
        names.erase(std::remove_if(names.begin(), names.end(), [](const string& name) { return name.startswith("SensorBuoyMK"); }), names.end());
        names.erase(std::remove_if(names.begin(), names.end(), [](const string& name) { return name.startswith("space_station_"); }), names.end());
        names.erase(std::remove_if(names.begin(), names.end(), [](const string& name) { return name == "ammo_box"; }), names.end());
        names.erase(std::remove_if(names.begin(), names.end(), [](const string& name) { return name == "shield_generator"; }), names.end());
        names.erase(std::remove_if(names.begin(), names.end(), [](const string& name) { return name.endswith("Blue"); }), names.end());
        names.erase(std::remove_if(names.begin(), names.end(), [](const string& name) { return name.endswith("Green"); }), names.end());
        names.erase(std::remove_if(names.begin(), names.end(), [](const string& name) { return name.endswith("Grey"); }), names.end());
        names.erase(std::remove_if(names.begin(), names.end(), [](const string& name) { return name.endswith("Red"); }), names.end());
        names.erase(std::remove_if(names.begin(), names.end(), [](const string& name) { return name.endswith("White"); }), names.end());
        int col_count = sqrtf(names.size()) + 1;
        int row_count = ceil(names.size() / col_count) + 1;
        int x = 0;
        int y = 0;
        float w = 1600 / col_count;
        float h = 900 / row_count;
        for(string name : names)
        {
            (new GuiRotatingModelView(this, "", ModelData::getModel(name)))->setPosition(x * w, y * h, ATopLeft)->setSize(w, h);
            x++;
            if (x == col_count)
            {
                x = 0;
                y++;
            }
        }
    }
};

MainMenu::MainMenu()
{
    constexpr float logo_size = 256;
    constexpr float logo_size_y = 256;
    constexpr float logo_size_x = 1024;
    constexpr float title_y = 160;

    new GuiOverlay(this, "", colorConfig.background);
    (new GuiOverlay(this, "", sf::Color::White))->setTextureTiled("gui/BackgroundCrosses");

    (new GuiImage(this, "LOGO", "logo_full"))->setPosition(0, title_y, ATopCenter)->setSize(logo_size_x, logo_size_y);
    (new GuiLabel(this, "VERSION", tr("Version: {version}").format({{"version", string(VERSION_NUMBER)}}), 20))->setPosition(0, title_y + logo_size, ATopCenter)->setSize(0, 20);

    (new GuiLabel(this, "", tr("Your name:"), 30))->setAlignment(ACenterLeft)->setPosition(sf::Vector2f(50, -400), ABottomLeft)->setSize(300, 50);
    (new GuiTextEntry(this, "USERNAME", PreferencesManager::get("username")))->callback([](string text) {
        PreferencesManager::set("username", text);
    })->setPosition(sf::Vector2f(50, -350), ABottomLeft)->setSize(300, 50);

    (new GuiButton(this, "START_SERVER", tr("Start server"), [this]() {
        new EpsilonServer();
        if (game_server)
        {
            new ServerCreationScreen();
            destroy();
        }
    }))->setPosition(sf::Vector2f(50, -230), ABottomLeft)->setSize(300, 50);

    (new GuiButton(this, "START_CLIENT", tr("Start client"), [this]() {
        new ServerBrowserMenu(ServerBrowserMenu::Local);
        destroy();
    }))->setPosition(sf::Vector2f(50, -170), ABottomLeft)->setSize(300, 50);

    (new GuiButton(this, "OPEN_OPTIONS", tr("Options"), [this]() {
        new OptionsMenu();
        destroy();
    }))->setPosition(sf::Vector2f(50, -110), ABottomLeft)->setSize(300, 50);

    (new GuiButton(this, "QUIT", tr("Quit"), [this]() {
        engine->shutdown();
    }))->setPosition(sf::Vector2f(50, -50), ABottomLeft)->setSize(300, 50);

    (new GuiButton(this, "START_TUTORIAL", tr("Tutorials"), [this]() {
        new TutorialMenu();
        destroy();
    }))->setPosition(sf::Vector2f(370, -50), ABottomLeft)->setSize(300, 50);

    if (InputHandler::touch_screen)
    {
        GuiButton* touch_calib = new GuiButton(this, "TOUCH_CALIB", "", [this]() {
            destroy();
            new MouseCalibrator("");
        });
        touch_calib->setPosition(sf::Vector2f(-50, -50), ABottomRight)->setSize(200, 100);
        (new GuiLabel(touch_calib, "TOUCH_CALIB_LABEL", tr("Calibrate\nTouchscreen"), 30)
        )->setPosition(0, -15, ACenter);
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

    if (PreferencesManager::get("instance_name") != "")
    {
        (new GuiLabel(this, "", PreferencesManager::get("instance_name"), 25))->setAlignment(ACenterLeft)->setPosition(20, 20, ATopLeft)->setSize(0, 18);
    }

#ifdef DEBUG
    (new GuiButton(this, "", "TO DA GM!", [this]() {
        new EpsilonServer();
        if (game_server)
        {
            gameGlobalInfo->startScenario("scenario_10_empty.lua");

            my_player_info->commandSetShipId(-1);
            destroy();
            new GameMasterScreen();
        }
    }))->setPosition(sf::Vector2f(370, -150), ABottomLeft)->setSize(300, 50);
    
    (new GuiButton(this, "", "MODELS!", [this]() {
        destroy();
        new DebugAllModelView();
    }))->setPosition(sf::Vector2f(370, -200), ABottomLeft)->setSize(300, 50);
#endif
}
