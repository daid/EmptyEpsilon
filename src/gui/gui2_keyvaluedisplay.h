#ifndef GUI_KEYVALUEDISPLAY_H
#define GUI_KEYVALUEDISPLAY_H

#include "gui2_element.h"


class GuiThemeStyle;
class GuiKeyValueDisplay : public GuiElement
{
public:
    GuiKeyValueDisplay(GuiContainer* owner, const string& id, float div_distance, const string& key, const string& value);

    virtual void onDraw(sp::RenderTarget& target) override;

    GuiKeyValueDisplay* setKey(const string& key);
    GuiKeyValueDisplay* setValue(const string& value);
    GuiKeyValueDisplay* setTextSize(float text_size);
    GuiKeyValueDisplay* setColor(glm::u8vec4 color);
    GuiKeyValueDisplay* setIcon(const string& icon_texture);

private:
    const GuiThemeStyle* back_style;
    const GuiThemeStyle* key_style;
    const GuiThemeStyle* value_style;

    string key;
    string value;
    string icon_texture;
    float text_size{};
    float div_distance{};
    glm::u8vec4 color{255,255,255,255};
};

#endif//GUI_KEYVALUEDISPLAY_H
