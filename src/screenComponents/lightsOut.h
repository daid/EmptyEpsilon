#ifndef LIGHTS_OUT_H
#define LIGHTS_OUT_H

#include "miniGame.h"

class LightsOut : public MiniGame {
  public:
    LightsOut(GuiHackingDialog* owner, string id, int difficulty);
    virtual void reset();
    virtual void disable();
  private:
    void onFieldClick(int x, int y);
    int lights_on;

    class LightsOutToggleButton : public GuiToggleButton {
      public:
        LightsOutToggleButton(GuiContainer* owner, string id, string text, func_t func);
        bool toggle();
    };

    LightsOutToggleButton*** field_item;
};


#endif//LIGHTS_OUT_H