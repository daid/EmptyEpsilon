#ifndef GUI_GLOBAL_MESSAGE_H
#define GUI_GLOBAL_MESSAGE_H

#include "gui/gui2.h"

class GuiGlobalMessage : public GuiElement
{
private:
    GuiPanel* box;
    GuiLabel* label;
public:
    GuiGlobalMessage(GuiContainer* owner);

    virtual void onDraw(sf::RenderTarget& window);
};

#endif//GUI_SELF_DESTRUCT_INDICATOR_H
