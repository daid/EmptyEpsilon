#ifndef SHIELDS_ENABLE_BUTTON_H
#define SHIELDS_ENABLE_BUTTON_H

#include "gui/gui2_element.h"

class GuiToggleButton;
class GuiProgressbar;

class GuiShieldsEnableButton : public GuiElement
{
private:
    GuiToggleButton* button;
    GuiProgressbar* bar;
public:
    GuiShieldsEnableButton(GuiContainer* owner, string id);
    
    virtual void onDraw(sf::RenderTarget& window) override;
    virtual void onHotkey(const HotkeyResult& key) override;
};

#endif//SHIELDS_ENABLE_BUTTON_H
