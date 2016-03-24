#ifndef GUI2_PROGRESS_BAR_H
#define GUI2_PROGRESS_BAR_H

#include "gui2_element.h"

class GuiProgressbar : public GuiElement
{
private:
    float min;
    float max;
    float value;
    sf::Color color;
    
    string text;
public:
    GuiProgressbar(GuiContainer* owner, string id, float min, float max, float value);

    virtual void onDraw(sf::RenderTarget& window);
    
    GuiProgressbar* setValue(float value);
    GuiProgressbar* setText(string text);
    GuiProgressbar* setColor(sf::Color color);
};

#endif//GUI2_PROGRESS_BAR_H
