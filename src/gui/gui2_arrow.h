#ifndef GUI2_ARROW_H
#define GUI2_ARROW_H

#include "gui2_element.h"

class GuiArrow : public GuiElement
{
private:
    sf::Color color;
    float angle;
public:
    GuiArrow(GuiContainer* owner, string id, float angle);

    virtual void onDraw(sf::RenderTarget& window);

    GuiArrow* setColor(sf::Color color) { this->color = color; return this; }
    GuiArrow* setAngle(float angle) { this->angle = angle; return this; }
};

#endif//GUI2_ARROW_H
