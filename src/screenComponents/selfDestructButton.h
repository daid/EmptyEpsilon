#ifndef SELF_DESTRUCT_BUTTON_H
#define SELF_DESTRUCT_BUTTON_H

#include "gui/gui2_element.h"

class GuiButton;

class GuiSelfDestructButton : public GuiElement
{
private:
    GuiButton* activate_button;
    GuiButton* confirm_button;
    GuiButton* cancel_button;
public:
    GuiSelfDestructButton(GuiContainer* owner, string id);

    virtual void onDraw(sf::RenderTarget& window) override;
    virtual void onHotkey(const HotkeyResult& key) override;
};

#endif//SELF_DESTRUCT_BUTTON_H
