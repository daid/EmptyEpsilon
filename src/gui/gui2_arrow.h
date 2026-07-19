#pragma once

#include "gui2_element.h"

class GuiThemeStyle;

class GuiArrow : public GuiElement
{
private:
    glm::u8vec4 color{255,255,255,255};
    float angle;
    const GuiThemeStyle* arrow_style;
public:
    GuiArrow(GuiContainer* owner, string id, float angle);

    virtual void onDraw(sp::RenderTarget& renderer) override;

    GuiArrow* setColor(glm::u8vec4 color) { this->color = color; return this; }
    GuiArrow* setAngle(float angle) { this->angle = angle; return this; }
};
