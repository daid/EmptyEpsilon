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
    sf::Color border_color;
public:
    GuiProgressbar(GuiContainer* owner, string id, float min, float max, float value);

    virtual void onDraw(sf::RenderTarget& window);
    
    GuiProgressbar* setValue(float value);
    GuiProgressbar* setColor(sf::Color color);
};

#endif//GUI2_PROGRESS_BAR_H
