#ifndef GUI2_BUTTON_H
#define GUI2_BUTTON_H

#include "gui2_element.h"

class GuiButton : public GuiElement
{
public:
    typedef std::function<void()> func_t;
    
protected:
    string text;
    float text_size;
    EGuiAlign text_alignment;
    sf::Color button_color;
    func_t func;
public:
    GuiButton(GuiContainer* owner, string id, string text, func_t func);

    virtual void onDraw(sf::RenderTarget& window);
    virtual bool onMouseDown(sf::Vector2f position);
    virtual void onMouseUp(sf::Vector2f position);
    
    GuiButton* setText(string text);
    GuiButton* setColor(sf::Color color);
    GuiButton* setTextSize(float size);
    string getText();
};

#endif//GUI2_BUTTON_H
