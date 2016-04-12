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
    func_t func;
    sf::Keyboard::Key hotkey;
    string icon_name;
    EGuiAlign icon_alignment;
public:
    GuiButton(GuiContainer* owner, string id, string text, func_t func);

    virtual void onDraw(sf::RenderTarget& window);
    virtual bool onMouseDown(sf::Vector2f position);
    virtual void onMouseUp(sf::Vector2f position);
    virtual bool onHotkey(sf::Keyboard::Key key, int unicode);
    
    GuiButton* setText(string text);
    GuiButton* setTextSize(float size);
    GuiButton* setIcon(string icon_name, EGuiAlign icon_alignment = ACenterLeft);
    GuiButton* setHotkey(sf::Keyboard::Key key);
    string getText();
    string getIcon();
};

#endif//GUI2_BUTTON_H
