#pragma once

#include "gui/gui2_element.h"

class GuiAdvancedScrollText;

class ShipsLog : public GuiElement
{
public:
    ShipsLog(GuiContainer* owner);

    virtual void onDraw(sp::RenderTarget& target) override;
    virtual bool onMouseDown(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id) override;
private:
    bool open;
    GuiAdvancedScrollText* log_text;
    const float SIDE_MARGINS = 15.0f;
};
