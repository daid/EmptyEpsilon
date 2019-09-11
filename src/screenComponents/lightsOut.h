/**
 * An implementation of the Lights Out game, where the goal is to turn all the
 * lights on. Flipping a single light flips all directly adjacent lights
 */

#ifndef LIGHTS_OUT_H
#define LIGHTS_OUT_H

#include "miniGame.h"
#include "gui/gui2_togglebutton.h"
#include <vector>
#include <memory>

class LightsOut : public MiniGame {
  public:
    LightsOut(GuiPanel* owner, GuiHackingDialog* parent, int difficulty);
    virtual void reset();
    virtual void disable();
    virtual float getProgress();
    virtual sf::Vector2f getBoardSize();
  private:
    int lights_on;

    class LightsOutToggleButton : public GuiToggleButton {
      public:
        LightsOutToggleButton(GuiContainer* owner, string id, string text, func_t func);
        bool toggle();
    };

    void onFieldClick(int x, int y);
    void toggle(int x, int y);
    LightsOutToggleButton* getField(int x, int y);

};


#endif//LIGHTS_OUT_H
