#ifndef TUTORIAL_GAME_H
#define TUTORIAL_GAME_H

#include "epsilonServer.h"
#include "script/environment.h"
#include "script/callback.h"
#include "gui/gui2_canvas.h"

class PlayerSpaceship;
class GuiRadarView;
class GuiPanel;
class GuiButton;
class GuiScrollText;

class TutorialGame : public Updatable, public GuiCanvas
{
    static P<TutorialGame> instance;
    GuiElement* viewport;
    GuiRadarView* tactical_radar;
    GuiRadarView* long_range_radar;
    GuiElement* station_screen[8];

    GuiPanel* frame;
    GuiScrollText* text;
    GuiButton* next_button;

    bool repeated_tutorial;
    string filename;
public:
    sp::script::Callback _onNext;

    TutorialGame(bool repeated_tutorial = false, string filename = "tutorial.lua");

    virtual void update(float delta) override;

    static void setPlayerShip(sp::ecs::Entity ship);

    static void showMessage(string message, bool show_next);
    static void switchViewToMainScreen();
    static void switchViewToTactical();
    static void switchViewToLongRange();
    static void switchViewToScreen(int n);
    static void setMessageToTopPosition();
    static void setMessageToBottomPosition();

    static void onNext(sp::script::Callback callback) { instance->_onNext = callback; }
    static void finish();
    static void quit();
private:
    void hideAllScreens();
    void createScreens();
};

class LocalOnlyGame : public EpsilonServer
{
public:
    LocalOnlyGame() : EpsilonServer(defaultServerPort) {}
    //Overide the update function from the game server, so no actuall socket communication is done.
    virtual void update(float delta) override;
};

#endif//TUTORIAL_GAME_H
