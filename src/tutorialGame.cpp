#include <i18n.h>
#include "tutorialGame.h"
#include "scriptInterface.h"
#include "playerInfo.h"
#include "spaceObjects/playerSpaceship.h"
#include "preferenceManager.h"
#include "main.h"

#include "screenComponents/viewport3d.h"
#include "screenComponents/radarView.h"

#include "screens/crew6/helmsScreen.h"
#include "screens/crew6/weaponsScreen.h"
#include "screens/crew6/engineeringScreen.h"
#include "screens/crew6/scienceScreen.h"
#include "screens/crew6/relayScreen.h"
#include "screens/crew4/tacticalScreen.h"
#include "screens/crew4/engineeringAdvancedScreen.h"
#include "screens/crew4/operationsScreen.h"

#include "screenComponents/indicatorOverlays.h"

#include "gui/gui2_panel.h"
#include "gui/gui2_scrolltext.h"
#include "gui/gui2_button.h"

///The TutorialGame object is normally never created.
/// And it only used to setup the special tutorial level.
/// It contains functions to assist in explaining the game, but do not work outside of the tutorial.
REGISTER_SCRIPT_CLASS_NO_CREATE(TutorialGame)
{
    REGISTER_SCRIPT_CLASS_FUNCTION(TutorialGame, setPlayerShip);
    REGISTER_SCRIPT_CLASS_FUNCTION(TutorialGame, switchViewToMainScreen);
    REGISTER_SCRIPT_CLASS_FUNCTION(TutorialGame, switchViewToTactical);
    REGISTER_SCRIPT_CLASS_FUNCTION(TutorialGame, switchViewToLongRange);
    REGISTER_SCRIPT_CLASS_FUNCTION(TutorialGame, switchViewToScreen);
    REGISTER_SCRIPT_CLASS_FUNCTION(TutorialGame, showMessage);
    REGISTER_SCRIPT_CLASS_FUNCTION(TutorialGame, setMessageToTopPosition);
    REGISTER_SCRIPT_CLASS_FUNCTION(TutorialGame, setMessageToBottomPosition);
    REGISTER_SCRIPT_CLASS_FUNCTION(TutorialGame, onNext);
    REGISTER_SCRIPT_CLASS_FUNCTION(TutorialGame, finish);
}

TutorialGame::TutorialGame(bool repeated_tutorial, string filename)
{
    new LocalOnlyGame();

    new GuiOverlay(this, "", colorConfig.background);
    (new GuiOverlay(this, "", sf::Color::White))->setTextureTiled("gui/BackgroundCrosses");

    this->viewport = nullptr;
    this->repeated_tutorial = repeated_tutorial;

    i18n::load("locale/" + PreferencesManager::get("language", "en") + ".po");
    i18n::load("locale/tutorial." + PreferencesManager::get("language", "en") + ".po");
    script = new ScriptObject();
    script->registerObject(this, "tutorial");
    script->run(filename);
}

void TutorialGame::createScreens()
{
    viewport = new GuiViewport3D(this, "");
    viewport->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->setPosition(0, 0, ATopLeft);

    tactical_radar = new GuiRadarView(this, "TACTICAL", 5000.0f, nullptr);
    tactical_radar->setPosition(0, 0, ATopLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    tactical_radar->setRangeIndicatorStepSize(1000.0f)->shortRange()->enableCallsigns()->hide();
    long_range_radar = new GuiRadarView(this, "TACTICAL", 30000.0f, nullptr);
    long_range_radar->setPosition(0, 0, ATopLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    long_range_radar->setRangeIndicatorStepSize(5000.0f)->longRange()->enableCallsigns()->hide();
    long_range_radar->setFogOfWarStyle(GuiRadarView::NebulaFogOfWar);

    station_screen[0] = new HelmsScreen(this);
    station_screen[1] = new WeaponsScreen(this);
    station_screen[2] = new EngineeringScreen(this);
    station_screen[3] = new ScienceScreen(this);
    station_screen[4] = new RelayScreen(this, true);
    station_screen[5] = new TacticalScreen(this);
    station_screen[6] = new EngineeringAdvancedScreen(this);
    station_screen[7] = new OperationScreen(this);
    for(int n=0; n<8; n++)
        station_screen[n]->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->setPosition(0, 0, ATopLeft);

    new GuiIndicatorOverlays(this);

    frame = new GuiPanel(this, "");
    frame->setPosition(0, 0, ATopCenter)->setSize(900, 230)->hide();

    text = new GuiScrollText(frame, "", "");
    text->setTextSize(20)->setPosition(20, 20, ATopLeft)->setSize(900 - 40, 200 - 40);
    next_button = new GuiButton(frame, "", "Next", [this]() {
        _onNext.call();
    });
    next_button->setTextSize(30)->setPosition(-20, -20, ABottomRight)->setSize(300, 30);

    if (repeated_tutorial)
    {
        (new GuiButton(this, "", "Reset", [this]()
        {
            finish();
        }))->setPosition(-20, 20, ATopRight)->setSize(120, 50);
    }
    hideAllScreens();

    engine->setGameSpeed(1.0);
}

void TutorialGame::update(float delta)
{
    if (my_spaceship)
    {
        float target_camera_yaw = my_spaceship->getRotation();
        switch(my_spaceship->main_screen_setting)
        {
        case MSS_Back: target_camera_yaw += 180; break;
        case MSS_Left: target_camera_yaw -= 90; break;
        case MSS_Right: target_camera_yaw += 90; break;
        default: break;
        }
        camera_pitch = 30.0f;

        const float camera_ship_distance = 420.0f;
        const float camera_ship_height = 420.0f;
        sf::Vector2f cameraPosition2D = my_spaceship->getPosition() + sf::vector2FromAngle(target_camera_yaw) * -camera_ship_distance;
        sf::Vector3f targetCameraPosition(cameraPosition2D.x, cameraPosition2D.y, camera_ship_height);

        camera_position = camera_position * 0.9f + targetCameraPosition * 0.1f;
        camera_yaw += sf::angleDifference(camera_yaw, target_camera_yaw) * 0.1f;
    }
}

void TutorialGame::onKey(sf::Event::KeyEvent key, int unicode)
{
    switch(key.code)
    {
    case sf::Keyboard::Escape:
    case sf::Keyboard::Home:
        finish();
        break;
    default:
        break;
    }
}

void TutorialGame::setPlayerShip(P<PlayerSpaceship> ship)
{
    my_player_info->commandSetShipId(ship->getMultiplayerId());

    if (viewport == nullptr)
        createScreens();
}

void TutorialGame::showMessage(string message, bool show_next)
{
    if (viewport == nullptr)
        return;

    frame->show();
    text->setText(message);
    if (show_next)
    {
        next_button->show();
        frame->setSize(900, 230);
    }
    else
    {
        next_button->hide();
        frame->setSize(900, 200);
    }
}

void TutorialGame::switchViewToMainScreen()
{
    if (viewport == nullptr)
        return;

    hideAllScreens();
    viewport->show();
}

void TutorialGame::switchViewToTactical()
{
    if (viewport == nullptr)
        return;

    hideAllScreens();
    tactical_radar->show();
}

void TutorialGame::switchViewToLongRange()
{
    if (viewport == nullptr)
        return;

    hideAllScreens();
    long_range_radar->show();
}

void TutorialGame::switchViewToScreen(int n)
{
    if (viewport == nullptr)
        return;

    if (n < 0 || n >= 8)
        return;
    hideAllScreens();
    station_screen[n]->show();
}

void TutorialGame::setMessageToTopPosition()
{
    if (viewport == nullptr)
        return;

    frame->setPosition(0, 0, ATopCenter);
}

void TutorialGame::setMessageToBottomPosition()
{
    if (viewport == nullptr)
        return;

    frame->setPosition(0, -50, ABottomCenter);
}

void TutorialGame::finish()
{
    if (repeated_tutorial)
    {
        foreach(SpaceObject, obj, space_object_list)
            obj->destroy();
        script->destroy();
        hideAllScreens();

        script = new ScriptObject();
        script->registerObject(this, "tutorial");
        script->run("tutorial.lua");
    }else{
        script->destroy();
        destroy();

        disconnectFromServer();
        returnToMainMenu();
    }
}

void TutorialGame::hideAllScreens()
{
    if (viewport == nullptr)
        return;

    viewport->hide();
    tactical_radar->hide();
    long_range_radar->hide();

    for(int n=0; n<8; n++)
    {
        station_screen[n]->hide();
    }
}

LocalOnlyGame::LocalOnlyGame()
{
}

void LocalOnlyGame::update(float delta)
{
}
