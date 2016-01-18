#ifndef TUTORIAL_GAME_H
#define TUTORIAL_GAME_H

#include "epsilonServer.h"
#include "gui/gui2.h"

class PlayerSpaceship;
class GuiRadarView;

class TutorialGame : public EpsilonServer, public GuiCanvas
{
    GuiElement* viewport;
    GuiRadarView* tactical_radar;
    GuiRadarView* long_range_radar;
    GuiElement* station_screen[5];
    
    ScriptObject* script;
    GuiBox* frame;
    GuiScrollText* text;
    GuiButton* next_button;
public:
    ScriptCallback onNext;
    
    TutorialGame();
    
    //Overide the update function from the game server, so no actuall socket communication is done.
    virtual void update(float delta);
    
    void setPlayerShip(P<PlayerSpaceship> ship);
    
    void showMessage(string message, bool show_next);
    void switchViewToMainScreen();
    void switchViewToTactical();
    void switchViewToLongRange();
    void switchViewToScreen(int n);
    void setMessageToTopPosition();
    void setMessageToBottomPosition();
private:
    void hideAllScreens();
    void createScreens();
};

#endif//TUTORIAL_GAME_H
