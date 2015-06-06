#ifndef GUI2_BOX_H
#define GUI2_BOX_H

#include "gui2.h"

class GuiBox : public GuiElement
{
public:
    GuiBox(GuiContainer* owner, string id);

    virtual void onDraw(sf::RenderTarget& window);
};

#endif//GUI2_BOX_H
