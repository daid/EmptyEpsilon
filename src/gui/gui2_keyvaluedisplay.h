#ifndef GUI_KEY_VALUE_DISPLAY_H
#define GUI_KEY_VALUE_DISPLAY_H

#include "gui2_element.h"

class GuiKeyValueDisplay : public GuiElement
{
protected:
    float div_distance;
    string key;
    string value;
    float text_size;
public:
    GuiKeyValueDisplay(GuiContainer* owner, string id, float div_distance, string key, string value);

    virtual void onDraw(sf::RenderTarget& window);
    
    GuiKeyValueDisplay* setKey(string key);
    GuiKeyValueDisplay* setValue(string value);
    GuiKeyValueDisplay* setTextSize(float text_size);
};

#endif//GUI_KEY_VALUE_DISPLAY_H
