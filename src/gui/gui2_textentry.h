#ifndef GUI2_TEXTENTRY_H
#define GUI2_TEXTENTRY_H

#include "gui2_element.h"

class GuiTextEntry : public GuiElement
{
public:
    typedef std::function<void(string text)> func_t;
    
protected:
    string text;
    float text_size;
    func_t func;
public:
    GuiTextEntry(GuiContainer* owner, string id, string text);

    virtual void onDraw(sf::RenderTarget& window);
    virtual bool onMouseDown(sf::Vector2f position);
    virtual bool onKey(sf::Keyboard::Key key, int unicode);
    
    string getText();
    GuiTextEntry* setText(string text);
    GuiTextEntry* setTextSize(float size);
    GuiTextEntry* callback(func_t func);
};

#endif//GUI2_TEXTENTRY_H
