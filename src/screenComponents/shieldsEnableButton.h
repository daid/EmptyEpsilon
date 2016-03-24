#ifndef GUI_SHIELDS_ENABLE_H
#define GUI_SHIELDS_ENABLE_H

#include "gui/gui2.h"

class GuiShieldsEnableButton : public GuiElement
{
private:
    GuiToggleButton* button;
    GuiProgressbar* bar;
public:
    GuiShieldsEnableButton(GuiContainer* owner, string id);
    
    virtual void onDraw(sf::RenderTarget& window);
};

#endif//GUI_SHIELDS_ENABLE_H
