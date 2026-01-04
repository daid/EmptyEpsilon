#pragma once

#include "gui2_element.h"


class GuiThemeStyle;
class GuiKeyValueDisplay : public GuiElement
{
public:
    GuiKeyValueDisplay(GuiContainer* owner, const string& id, float div_distance, const string& key, const string& value);

    virtual void onDraw(sp::RenderTarget& renderer) override;

    GuiKeyValueDisplay* setKey(const string& key);
    GuiKeyValueDisplay* setValue(const string& value);
    GuiKeyValueDisplay* setTextSize(float text_size);
    GuiKeyValueDisplay* setColor(glm::u8vec4 color);
    GuiKeyValueDisplay* setBackColor(glm::u8vec4 color);
    GuiKeyValueDisplay* setKeyColor(glm::u8vec4 color);
    GuiKeyValueDisplay* setValueColor(glm::u8vec4 color);
    GuiKeyValueDisplay* useThemeColors();
    GuiKeyValueDisplay* setIcon(const string& icon_texture);

private:
    const GuiThemeStyle* back_style;
    const GuiThemeStyle* key_style;
    const GuiThemeStyle* value_style;

    float div_distance;
    string key;
    string value;
    string icon_texture;
    float text_size = 20.0f;
    glm::u8vec4 back_color{255,255,255,255};
    glm::u8vec4 key_color{255,255,255,255};
    glm::u8vec4 value_color{255,255,255,255};
};
