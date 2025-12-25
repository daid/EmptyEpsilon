#include <i18n.h>
#include "tutorialGame.h"
#include "playerInfo.h"
#include "preferenceManager.h"
#include "main.h"
#include "script.h"
#include "gameGlobalInfo.h"

#include "components/collision.h"

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

#include "menus/luaConsole.h"
#include "gui/gui2_panel.h"
#include "gui/gui2_scrolltext.h"
#include "gui/gui2_button.h"
#include "gui/theme.h"

P<TutorialGame> TutorialGame::instance;

TutorialGame::TutorialGame(bool repeated_tutorial, string filename)
{
    instance = this;
    new LocalOnlyGame();

    new GuiOverlay(this, "", GuiTheme::getColor("background"));
    (new GuiOverlay(this, "", glm::u8vec4{255,255,255,255}))->setTextureTiled("gui/background/crosses.png");

    this->viewport = nullptr;
    this->repeated_tutorial = repeated_tutorial;

    gameGlobalInfo->startScenario(filename);

    gameGlobalInfo->main_scenario_script->setGlobal("tutorial_setPlayerShip", &TutorialGame::setPlayerShip);
    gameGlobalInfo->main_scenario_script->setGlobal("tutorial_switchViewToMainScreen", &TutorialGame::switchViewToMainScreen);
    gameGlobalInfo->main_scenario_script->setGlobal("tutorial_switchViewToTactical", &TutorialGame::switchViewToTactical);
    gameGlobalInfo->main_scenario_script->setGlobal("tutorial_switchViewToLongRange", &TutorialGame::switchViewToLongRange);
    gameGlobalInfo->main_scenario_script->setGlobal("tutorial_switchViewToScreen", &TutorialGame::switchViewToScreen);
    gameGlobalInfo->main_scenario_script->setGlobal("tutorial_showMessage", &TutorialGame::showMessage);
    gameGlobalInfo->main_scenario_script->setGlobal("tutorial_setMessageToTopPosition", &TutorialGame::setMessageToTopPosition);
    gameGlobalInfo->main_scenario_script->setGlobal("tutorial_setMessageToBottomPosition", &TutorialGame::setMessageToBottomPosition);
    gameGlobalInfo->main_scenario_script->setGlobal("tutorial_onNext", &TutorialGame::onNext);
    gameGlobalInfo->main_scenario_script->setGlobal("tutorial_finish", &TutorialGame::finish);

    auto res = gameGlobalInfo->main_scenario_script->call<void>("tutorial_init");
    LuaConsole::checkResult(res);
}

void TutorialGame::createScreens()
{
    viewport = new GuiViewport3D(this, "");
    viewport->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->setPosition(0, 0, sp::Alignment::TopLeft);

    tactical_radar = new GuiRadarView(this, "TACTICAL", nullptr);
    tactical_radar->setPosition(0, 0, sp::Alignment::TopLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    tactical_radar->setRangeIndicatorStepSize(1000.0f)->shortRange()->enableCallsigns()->hide();
    long_range_radar = new GuiRadarView(this, "TACTICAL", nullptr);
    long_range_radar->setPosition(0, 0, sp::Alignment::TopLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
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
        station_screen[n]->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->setPosition(0, 0, sp::Alignment::TopLeft);

    new GuiIndicatorOverlays(this);

    frame = new GuiPanel(this, "");
    frame->setPosition(0, 0, sp::Alignment::TopCenter)->setSize(900, 230)->hide();

    text = new GuiScrollText(frame, "", "");
    text->setTextSize(20)->setPosition(20, 20, sp::Alignment::TopLeft)->setSize(900 - 40, 200 - 40);
    next_button = new GuiButton(frame, "", tr("Next"), [this]() {
        LuaConsole::checkResult(_onNext.call<void>());
    });
    next_button->setTextSize(30)->setPosition(-20, -20, sp::Alignment::BottomRight)->setSize(300, 30);

    if (repeated_tutorial)
    {
        (new GuiButton(this, "", tr("Reset"), [this]()
        {
            finish();
        }))->setPosition(-20, 20, sp::Alignment::TopRight)->setSize(120, 50);
    }
    hideAllScreens();

    engine->setGameSpeed(1.0);
}

void TutorialGame::update(float delta)
{
    if (keys.escape.getDown())
        finish();
    if (my_spaceship)
    {
        auto pc = my_spaceship.getComponent<PlayerControl>();
        auto physics = my_spaceship.getComponent<sp::Transform>();
        float target_camera_yaw = physics ? physics->getRotation() : 0.0f;
        switch(pc ? pc->main_screen_setting : MainScreenSetting::Front)
        {
        case MainScreenSetting::Back: target_camera_yaw += 180; break;
        case MainScreenSetting::Left: target_camera_yaw -= 90; break;
        case MainScreenSetting::Right: target_camera_yaw += 90; break;
        default: break;
        }
        camera_pitch = 30.0f;

        const float camera_ship_distance = 420.0f;
        const float camera_ship_height = 420.0f;
        glm::vec2 cameraPosition2D = (physics ? physics->getPosition() : glm::vec2{0, 0}) + vec2FromAngle(target_camera_yaw) * -camera_ship_distance;
        glm::vec3 targetCameraPosition(cameraPosition2D.x, cameraPosition2D.y, camera_ship_height);

        camera_position = camera_position * 0.9f + targetCameraPosition * 0.1f;
        camera_yaw += angleDifference(camera_yaw, target_camera_yaw) * 0.1f;
    }
}

void TutorialGame::setPlayerShip(sp::ecs::Entity ship)
{
    my_player_info->commandSetShip(ship);

    if (instance->viewport == nullptr)
        instance->createScreens();
}

void TutorialGame::showMessage(string message, bool show_next)
{
    if (instance->viewport == nullptr)
        return;

    instance->frame->show();
    instance->text->setText(message);
    if (show_next)
    {
        instance->next_button->show();
        instance->frame->setSize(900, 230);
    }
    else
    {
        instance->next_button->hide();
        instance->frame->setSize(900, 200);
    }
}

void TutorialGame::switchViewToMainScreen()
{
    if (instance->viewport == nullptr)
        return;

    instance->hideAllScreens();
    instance->viewport->show();
}

void TutorialGame::switchViewToTactical()
{
    if (instance->viewport == nullptr)
        return;

    instance->hideAllScreens();
    instance->tactical_radar->show();
}

void TutorialGame::switchViewToLongRange()
{
    if (instance->viewport == nullptr)
        return;

    instance->hideAllScreens();
    instance->long_range_radar->show();
}

void TutorialGame::switchViewToScreen(int n)
{
    if (instance->viewport == nullptr)
        return;

    if (n < 0 || n >= 8)
        return;
    instance->hideAllScreens();
    instance->station_screen[n]->show();
}

void TutorialGame::setMessageToTopPosition()
{
    if (instance->viewport == nullptr)
        return;

    instance->frame->setPosition(0, 0, sp::Alignment::TopCenter);
}

void TutorialGame::setMessageToBottomPosition()
{
    if (instance->viewport == nullptr)
        return;

    instance->frame->setPosition(0, -50, sp::Alignment::BottomCenter);
}

void TutorialGame::finish()
{
    if (instance->repeated_tutorial)
    {
        sp::ecs::Entity::destroyAllEntities();
        instance->hideAllScreens();

        gameGlobalInfo->startScenario("tutorial.lua");

        gameGlobalInfo->main_scenario_script->setGlobal("tutorial_setPlayerShip", &TutorialGame::setPlayerShip);
        gameGlobalInfo->main_scenario_script->setGlobal("tutorial_switchViewToMainScreen", &TutorialGame::switchViewToMainScreen);
        gameGlobalInfo->main_scenario_script->setGlobal("tutorial_switchViewToTactical", &TutorialGame::switchViewToTactical);
        gameGlobalInfo->main_scenario_script->setGlobal("tutorial_switchViewToLongRange", &TutorialGame::switchViewToLongRange);
        gameGlobalInfo->main_scenario_script->setGlobal("tutorial_switchViewToScreen", &TutorialGame::switchViewToScreen);
        gameGlobalInfo->main_scenario_script->setGlobal("tutorial_showMessage", &TutorialGame::showMessage);
        gameGlobalInfo->main_scenario_script->setGlobal("tutorial_setMessageToTopPosition", &TutorialGame::setMessageToTopPosition);
        gameGlobalInfo->main_scenario_script->setGlobal("tutorial_setMessageToBottomPosition", &TutorialGame::setMessageToBottomPosition);
        gameGlobalInfo->main_scenario_script->setGlobal("tutorial_onNext", &TutorialGame::onNext);
        gameGlobalInfo->main_scenario_script->setGlobal("tutorial_finish", &TutorialGame::finish);

        auto res = gameGlobalInfo->main_scenario_script->call<void>("tutorial_init");
        LuaConsole::checkResult(res);
    }else{
        disconnectFromServer();
        returnToMainMenu(instance->getRenderLayer());
        instance->destroy();
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

void LocalOnlyGame::update(float delta)
{
}
