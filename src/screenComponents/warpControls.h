#ifndef GUI_WARP_CONTROLS_H
#define GUI_WARP_CONTROLS_H

#include "gui/gui2_element.h"

class GuiKeyValueDisplay;
class GuiSlider;

class GuiWarpControls : public GuiElement
{
private:
    GuiKeyValueDisplay* label;
    GuiSlider* slider;
public:
    GuiWarpControls(GuiContainer* owner, string id);
    
    virtual void onDraw(sf::RenderTarget& window) override;
    virtual void onHotkey(const HotkeyResult& key) override;
};

#endif//GUI_WARP_CONTROLS_H
