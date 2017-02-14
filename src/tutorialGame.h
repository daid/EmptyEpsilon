#ifndef TUTORIAL_GAME_H
#define TUTORIAL_GAME_H

#include "epsilonServer.h"
#include "gui/gui2_canvas.h"

class PlayerSpaceship;
class GuiRadarView;
class GuiPanel;
class GuiButton;
class GuiScrollText;

class TutorialGame : public Updatable, public GuiCanvas
{
    GuiElement* viewport;
    GuiRadarView* tactical_radar;
    GuiRadarView* long_range_radar;
    GuiElement* station_screen[8];

    P<ScriptObject> script;
    GuiPanel* frame;
    GuiScrollText* text;
    GuiButton* next_button;

    bool repeated_tutorial;
public:
    ScriptSimpleCallback _onNext;

    TutorialGame(bool repeated_tutorial = false, string filename = "tutorial.lua");

    virtual void update(float delta) override;
    virtual void onKey(sf::Event::KeyEvent key, int unicode) override;

    void setPlayerShip(P<PlayerSpaceship> ship);

    void showMessage(string message, bool show_next);
    void switchViewToMainScreen();
    void switchViewToTactical();
    void switchViewToLongRange();
    void switchViewToScreen(int n);
    void setMessageToTopPosition();
    void setMessageToBottomPosition();

    void onNext(ScriptSimpleCallback callback) { _onNext = callback; }
    void finish();
private:
    void hideAllScreens();
    void createScreens();
};

class LocalOnlyGame : public EpsilonServer
{
public:
    LocalOnlyGame();

    //Overide the update function from the game server, so no actuall socket communication is done.
    virtual void update(float delta) override;
};

#endif//TUTORIAL_GAME_H
