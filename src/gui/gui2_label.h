#ifndef GUI2_LABEL_H
#define GUI2_LABEL_H

#include "gui2_element.h"

class GuiLabel : public GuiElement
{
protected:
    string text;
    float text_size;
    sf::Color text_color;
    EGuiAlign text_alignment;
    bool box;
public:
    GuiLabel(GuiContainer* owner, string id, string text, float text_size);

    virtual void onDraw(sf::RenderTarget& window);
    
    GuiLabel* setText(string text);
    GuiLabel* setAlignment(EGuiAlign alignment);
    GuiLabel* setTextColor(sf::Color color);
    GuiLabel* addBox();
};


#endif//GUI2_LABEL_H
