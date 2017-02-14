#ifndef GUI_KEYVALUEDISPLAY_H
#define GUI_KEYVALUEDISPLAY_H

#include "gui2_element.h"

class GuiKeyValueDisplay : public GuiElement
{
protected:
    float div_distance;
    string key;
    string value;
    float text_size;
    sf::Color color;
    string icon_texture;
public:
    GuiKeyValueDisplay(GuiContainer* owner, string id, float div_distance, string key, string value);

    virtual void onDraw(sf::RenderTarget& window);
    
    GuiKeyValueDisplay* setKey(string key);
    GuiKeyValueDisplay* setValue(string value);
    GuiKeyValueDisplay* setTextSize(float text_size);
    GuiKeyValueDisplay* setColor(sf::Color color);
    GuiKeyValueDisplay* setIcon(string icon_texture);
};

#endif//GUI_KEYVALUEDISPLAY_H
