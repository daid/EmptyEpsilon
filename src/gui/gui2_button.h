#ifndef GUI2_BUTTON_H
#define GUI2_BUTTON_H

#include "gui2.h"

class GuiButton : public GuiElement
{
public:
    typedef std::function<void(GuiButton*)> func_t;
    
protected:
    string text;
    float text_size;
    EGuiAlign text_alignment;
    sf::Color button_color;
    func_t func;
public:
    GuiButton(GuiContainer* owner, string id, string text, func_t func);

    virtual void onDraw(sf::RenderTarget& window);
    virtual GuiElement* onMouseDown(sf::Vector2f position);
    virtual void onMouseUp(sf::Vector2f position);
    
    GuiButton* setText(string text);
    GuiButton* setColor(sf::Color color);
    string getText();
};

#endif//GUI2_BUTTON_H
