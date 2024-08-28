#include <i18n.h>
#include "engine.h"
#include "mainMenus.h"
#include "main.h"
#include "preferenceManager.h"
#include "epsilonServer.h"
#include "playerInfo.h"
#include "gameGlobalInfo.h"
#include "menus/serverCreationScreen.h"
#include "menus/optionsMenu.h"
#include "menus/tutorialMenu.h"
#include "menus/serverBrowseMenu.h"
#include "screens/gm/gameMasterScreen.h"
#include "screenComponents/rotatingModelView.h"
#include "config.h"

#include "gui/gui2_image.h"
#include "gui/gui2_label.h"
#include "gui/gui2_button.h"
#include "gui/gui2_textentry.h"


MainMenu::MainMenu()
{
    constexpr float logo_size = 256;
    constexpr float logo_size_y = 256;
    constexpr float logo_size_x = 1024;
    constexpr float title_y = 160;

    new GuiOverlay(this, "", colorConfig.background);
    (new GuiOverlay(this, "", glm::u8vec4{255,255,255,255}))->setTextureTiled("gui/background/crosses.png");

    (new GuiImage(this, "LOGO", "logo_full.png"))->setPosition(0, title_y, sp::Alignment::TopCenter)->setSize(logo_size_x, logo_size_y);
    (new GuiLabel(this, "VERSION", tr("Credits", "Version: {version}").format({{"version", string(VERSION_NUMBER)}}), 20))->setPosition(0, title_y + logo_size, sp::Alignment::TopCenter)->setSize(0, 20);

    (new GuiLabel(this, "", tr("mainMenu", "Your name:"), 30))->setAlignment(sp::Alignment::CenterLeft)->setPosition({50, -400}, sp::Alignment::BottomLeft)->setSize(300, 50);
    (new GuiTextEntry(this, "USERNAME", PreferencesManager::get("username")))->callback([](string text) {
        PreferencesManager::set("username", text);
    })->setPosition({50, -350}, sp::Alignment::BottomLeft)->setSize(300, 50);

    (new GuiButton(this, "START_SERVER", tr("mainMenu", "Start server"), [this]() {
        new ServerSetupScreen();
        destroy();
    }))->setPosition({50, -230}, sp::Alignment::BottomLeft)->setSize(300, 50);

    (new GuiButton(this, "START_CLIENT", tr("mainMenu", "Start client"), [this]() {
        new ServerBrowserMenu();
        destroy();
    }))->setPosition({50, -170}, sp::Alignment::BottomLeft)->setSize(300, 50);

    (new GuiButton(this, "OPEN_OPTIONS", tr("mainMenu", "Options"), [this]() {
        new OptionsMenu();
        destroy();
    }))->setPosition({50, -110}, sp::Alignment::BottomLeft)->setSize(300, 50);

    (new GuiButton(this, "QUIT", tr("mainMenu", "Quit"), []() {
        engine->shutdown();
    }))->setPosition({50, -50}, sp::Alignment::BottomLeft)->setSize(300, 50);

    (new GuiButton(this, "START_TUTORIAL", tr("mainMenu", "Tutorials"), [this]() {
        new TutorialMenu();
        destroy();
    }))->setPosition({370, -50}, sp::Alignment::BottomLeft)->setSize(300, 50);

    float y = 100;
    (new GuiLabel(this, "CREDITS", tr("Credits", "Credits"), 25))->setAlignment(sp::Alignment::CenterRight)->setPosition(-50, y, sp::Alignment::TopRight)->setSize(0, 25); y += 25;
    (new GuiLabel(this, "CREDITS1", tr("Credits", "Programming:"), 20))->setAlignment(sp::Alignment::CenterRight)->setPosition(-50, y, sp::Alignment::TopRight)->setSize(0, 20); y += 20;
    (new GuiLabel(this, "CREDITS2", "Daid", 18))->setAlignment(sp::Alignment::CenterRight)->setPosition(-50, y, sp::Alignment::TopRight)->setSize(0, 18); y += 18;
    (new GuiLabel(this, "CREDITS2", "gcask", 18))->setAlignment(sp::Alignment::CenterRight)->setPosition(-50, y, sp::Alignment::TopRight)->setSize(0, 18); y += 18;
    (new GuiLabel(this, "CREDITS2", "Nallath", 18))->setAlignment(sp::Alignment::CenterRight)->setPosition(-50, y, sp::Alignment::TopRight)->setSize(0, 18); y += 18;
    (new GuiLabel(this, "CREDITS2", "Xansta", 18))->setAlignment(sp::Alignment::CenterRight)->setPosition(-50, y, sp::Alignment::TopRight)->setSize(0, 18); y += 18;
    (new GuiLabel(this, "CREDITS2", "StarryWisdom", 18))->setAlignment(sp::Alignment::CenterRight)->setPosition(-50, y, sp::Alignment::TopRight)->setSize(0, 18); y += 18;
    y += 10;
    (new GuiLabel(this, "CREDITS1", tr("Credits", "Graphics:"), 20))->setAlignment(sp::Alignment::CenterRight)->setPosition(-50, y, sp::Alignment::TopRight)->setSize(0, 20); y += 20;
    (new GuiLabel(this, "CREDITS3", "Interesting John", 18))->setAlignment(sp::Alignment::CenterRight)->setPosition(-50, y, sp::Alignment::TopRight)->setSize(0, 18); y += 18;
    y += 10;
    (new GuiLabel(this, "CREDITS1", tr("Credits", "Localization:"), 20))->setAlignment(sp::Alignment::CenterRight)->setPosition(-50, y, sp::Alignment::TopRight)->setSize(0, 20); y += 20;
    (new GuiLabel(this, "CREDITS3", "Muerte (FR)", 18))->setAlignment(sp::Alignment::CenterRight)->setPosition(-50, y, sp::Alignment::TopRight)->setSize(0, 18); y += 18;
    (new GuiLabel(this, "CREDITS3", "aBlueShadow (DE)", 18))->setAlignment(sp::Alignment::CenterRight)->setPosition(-50, y, sp::Alignment::TopRight)->setSize(0, 18); y += 18;
    y += 10;
    (new GuiLabel(this, "CREDITS4", tr("Credits", "Music:"), 20))->setAlignment(sp::Alignment::CenterRight)->setPosition(-50, y, sp::Alignment::TopRight)->setSize(0, 20); y += 20;
    (new GuiLabel(this, "CREDITS5", "Matthew Pablo", 18))->setAlignment(sp::Alignment::CenterRight)->setPosition(-50, y, sp::Alignment::TopRight)->setSize(0, 18); y += 18;
    (new GuiLabel(this, "CREDITS6", "Alexandr Zhelanov", 18))->setAlignment(sp::Alignment::CenterRight)->setPosition(-50, y, sp::Alignment::TopRight)->setSize(0, 18); y += 18;
    (new GuiLabel(this, "CREDITS7", "Joe Baxter-Webb", 18))->setAlignment(sp::Alignment::CenterRight)->setPosition(-50, y, sp::Alignment::TopRight)->setSize(0, 18); y += 18;
    (new GuiLabel(this, "CREDITS8", "neocrey", 18))->setAlignment(sp::Alignment::CenterRight)->setPosition(-50, y, sp::Alignment::TopRight)->setSize(0, 18); y += 18;
    (new GuiLabel(this, "CREDITS9", "FoxSynergy", 18))->setAlignment(sp::Alignment::CenterRight)->setPosition(-50, y, sp::Alignment::TopRight)->setSize(0, 18); y += 18;
    y += 10;
    (new GuiLabel(this, "CREDITS10", tr("Credits", "Models:"), 20))->setAlignment(sp::Alignment::CenterRight)->setPosition(-50, y, sp::Alignment::TopRight)->setSize(0, 20); y += 20;
    (new GuiLabel(this, "CREDITS11", "Angryfly (turbosquid.com)", 18))->setAlignment(sp::Alignment::CenterRight)->setPosition(-50, y, sp::Alignment::TopRight)->setSize(0, 18); y += 18;
    (new GuiLabel(this, "CREDITS12", "SolCommand (http://solcommand.blogspot.com/)", 18))->setAlignment(sp::Alignment::CenterRight)->setPosition(-50, y, sp::Alignment::TopRight)->setSize(0, 18); y += 18;
    y += 10;
    (new GuiLabel(this, "CREDITS13", tr("Credits", "Crew sprites:"), 20))->setAlignment(sp::Alignment::CenterRight)->setPosition(-50, y, sp::Alignment::TopRight)->setSize(0, 20); y += 20;
    (new GuiLabel(this, "CREDITS14", "Tokka (http://bekeen.de/)", 18))->setAlignment(sp::Alignment::CenterRight)->setPosition(-50, y, sp::Alignment::TopRight)->setSize(0, 18); y += 18;
    y += 10;
    (new GuiLabel(this, "CREDITS15", tr("Credits", "Special thanks:"), 20))->setAlignment(sp::Alignment::CenterRight)->setPosition(-50, y, sp::Alignment::TopRight)->setSize(0, 20); y += 20;
    (new GuiLabel(this, "CREDITS16", "Marty Lewis (MadKat)", 18))->setAlignment(sp::Alignment::CenterRight)->setPosition(-50, y, sp::Alignment::TopRight)->setSize(0, 18); y += 18;
    (new GuiLabel(this, "CREDITS17", "Serge Wroclawski", 18))->setAlignment(sp::Alignment::CenterRight)->setPosition(-50, y, sp::Alignment::TopRight)->setSize(0, 18); y += 18;
    (new GuiLabel(this, "CREDITS18", "Dennis Shelton", 18))->setAlignment(sp::Alignment::CenterRight)->setPosition(-50, y, sp::Alignment::TopRight)->setSize(0, 18); y += 18;
    (new GuiLabel(this, "CREDITS19", "VolgClawtooth", 18))->setAlignment(sp::Alignment::CenterRight)->setPosition(-50, y, sp::Alignment::TopRight)->setSize(0, 18); y += 18;
    (new GuiLabel(this, "CREDITS20", "Daniel Loftis", 18))->setAlignment(sp::Alignment::CenterRight)->setPosition(-50, y, sp::Alignment::TopRight)->setSize(0, 18); y += 18;
    (new GuiLabel(this, "CREDITS21", "David Concepcion", 18))->setAlignment(sp::Alignment::CenterRight)->setPosition(-50, y, sp::Alignment::TopRight)->setSize(0, 18); y += 18;
    (new GuiLabel(this, "CREDITS22", "Philippe Bruylant", 18))->setAlignment(sp::Alignment::CenterRight)->setPosition(-50, y, sp::Alignment::TopRight)->setSize(0, 18); y += 18;
    (new GuiLabel(this, "CREDITS23", "Ralf Leichter", 18))->setAlignment(sp::Alignment::CenterRight)->setPosition(-50, y, sp::Alignment::TopRight)->setSize(0, 18); y += 18;
    (new GuiLabel(this, "CREDITS24", "Lee McDonough (Flea)", 18))->setAlignment(sp::Alignment::CenterRight)->setPosition(-50, y, sp::Alignment::TopRight)->setSize(0, 18); y += 18;
    (new GuiLabel(this, "CREDITS25", "Mickael Houet", 18))->setAlignment(sp::Alignment::CenterRight)->setPosition(-50, y, sp::Alignment::TopRight)->setSize(0, 18); y += 18;

    if (PreferencesManager::get("instance_name") != "")
    {
        (new GuiLabel(this, "", PreferencesManager::get("instance_name"), 25))->setAlignment(sp::Alignment::CenterLeft)->setPosition(20, 20, sp::Alignment::TopLeft)->setSize(0, 18);
    }

#ifdef DEBUG
    (new GuiButton(this, "", "TO DA GM!", [this]() {
        new EpsilonServer(defaultServerPort);
        if (game_server)
        {
            gameGlobalInfo->startScenario("scenario_10_empty.lua");

            my_player_info->commandSetShip({});
            destroy();
            new GameMasterScreen(nullptr);
        }
    }))->setPosition({370, -150}, sp::Alignment::BottomLeft)->setSize(300, 50);
#endif
}
