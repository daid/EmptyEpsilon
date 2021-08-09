#ifndef GUI_KEYVALUEDISPLAY_H
#define GUI_KEYVALUEDISPLAY_H

#include "gui2_element.h"

class GuiKeyValueDisplay : public GuiElement
{
public:
    GuiKeyValueDisplay(GuiContainer* owner, const string& id, float div_distance, const string& key, const string& value);

    virtual void onDraw(sp::RenderTarget& target) override;

    GuiKeyValueDisplay* setKey(const string& key);
    GuiKeyValueDisplay* setValue(const string& value);
    GuiKeyValueDisplay* setTextSize(float text_size);
    GuiKeyValueDisplay* setColor(sf::Color color);
    GuiKeyValueDisplay* setIcon(const string& icon_texture);

private:
    string key;
    string value;
    string icon_texture;
    float text_size{};
    float div_distance{};
    sf::Color color;
};

#endif//GUI_KEYVALUEDISPLAY_H
