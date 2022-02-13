#ifndef GUI2_PROGRESSBAR_H
#define GUI2_PROGRESSBAR_H

#include "gui2_element.h"


class GuiThemeStyle;
class GuiProgressbar : public GuiElement
{
private:
    float min_value;
    float max_value;
    float value;
    glm::u8vec4 color;
    bool drawBackground;
    const GuiThemeStyle* back_style;
    const GuiThemeStyle* front_style;

    string text;
public:
    GuiProgressbar(GuiContainer* owner, string id, float min_value, float max_value, float start_value);

    virtual void onDraw(sp::RenderTarget& target) override;

    GuiProgressbar* setValue(float value);
    GuiProgressbar* setRange(float min_value, float max_value);
    GuiProgressbar* setText(string text);
    GuiProgressbar* setColor(glm::u8vec4 color);
    GuiProgressbar* setDrawBackground(bool drawBackground);
};

#endif//GUI2_PROGRESSBAR_H
