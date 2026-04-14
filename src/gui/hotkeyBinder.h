#pragma once

#include "gui2_element.h"

class GuiThemeStyle;

class GuiHotkeyBinder : public GuiElement
{
private:
    sp::io::Keybinding* key;

    const GuiThemeStyle* front_style;
    const GuiThemeStyle* back_style;
public:
    GuiHotkeyBinder(GuiContainer* owner, string id, sp::io::Keybinding* key);

    virtual bool onMouseDown(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id) override;
    virtual void onDraw(sp::RenderTarget& renderer) override;
    virtual bool interceptsPointer() const override { return true; }
};
