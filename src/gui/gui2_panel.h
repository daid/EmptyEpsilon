#pragma once

#include "gui2_element.h"

class GuiThemeStyle;

class GuiPanel : public GuiElement
{
protected:
    const GuiThemeStyle* style;
public:
    GuiPanel(GuiContainer* owner, string id);

    virtual void onDraw(sp::RenderTarget& renderer) override;
    virtual bool onMouseDown(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id) override;
    virtual bool interceptsPointer() const override { return true; }
};
