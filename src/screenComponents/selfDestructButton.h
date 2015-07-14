#ifndef GUI_SELF_DESTRUCT_BUTTON_H
#define GUI_SELF_DESTRUCT_BUTTON_H

#include "gui/gui2.h"

class GuiSelfDestructButton : public GuiElement
{
private:
    GuiButton* activate_button;
    GuiButton* confirm_button;
    GuiButton* cancel_button;
public:
    GuiSelfDestructButton(GuiContainer* owner, string id);

    virtual void onDraw(sf::RenderTarget& window);
};

#endif//GUI_SELF_DESTRUCT_BUTTON_H
