#ifndef GUI2_IMAGE_H
#define GUI2_IMAGE_H

#include "gui2_element.h"

class GuiImage : public GuiElement
{
private:
    sf::Color color;
    string texture_name;
    float angle;
public:
    GuiImage(GuiContainer* owner, string id, string texture_name);

    virtual void onDraw(sf::RenderTarget& window);
    
    GuiImage* setColor(sf::Color color) { this->color = color; return this; }
    GuiImage* setAngle(float angle) { this->angle = angle; return this; }
};

#endif//GUI2_BOX_H
