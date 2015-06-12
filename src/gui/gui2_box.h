#ifndef GUI2_BOX_H
#define GUI2_BOX_H

#include "gui2_element.h"

class GuiBox : public GuiElement
{
private:
    sf::Color fill_color;
public:
    GuiBox(GuiContainer* owner, string id);

    virtual void onDraw(sf::RenderTarget& window);
    
    GuiBox* fill(sf::Color color = sf::Color::Black);
};

#endif//GUI2_BOX_H
