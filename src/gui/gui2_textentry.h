#ifndef GUI2_TEXTENTRY_H
#define GUI2_TEXTENTRY_H

#include "gui2.h"

class GuiTextEntry : public GuiElement
{
protected:
    string text;
    float text_size;
public:
    GuiTextEntry(GuiContainer* owner, string id, string text);

    virtual void onDraw(sf::RenderTarget& window);
    
    string getText();
    GuiTextEntry* setText(string text);
};

#endif//GUI2_TEXTENTRY_H
