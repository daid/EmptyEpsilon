#ifndef GUI2_PANEL_H
#define GUI2_PANEL_H

#include "gui2_element.h"

class GuiPanel : public GuiElement
{
public:
    GuiPanel(GuiContainer* owner, string id);

    virtual void onDraw(sf::RenderTarget& window);
};

#endif//GUI2_BOX_H

