#ifndef GUI2_TEXTENTRY_H
#define GUI2_TEXTENTRY_H

#include "gui2_element.h"

class GuiTextEntry : public GuiElement
{
protected:
    string text;
    float text_size;
public:
    GuiTextEntry(GuiContainer* owner, string id, string text);

    virtual void onDraw(sf::RenderTarget& window);
    virtual bool onMouseDown(sf::Vector2f position);
    virtual bool onKey(sf::Keyboard::Key key, int unicode);
    
    string getText();
    GuiTextEntry* setText(string text);
};

#endif//GUI2_TEXTENTRY_H
