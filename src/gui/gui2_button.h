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
    bool override_color;
    sf::Color color;
    bool override_text_color;
    sf::Color text_color;
    EGuiAlign text_alignment;
    func_t func;
    string icon_name;
    EGuiAlign icon_alignment;
    float icon_rotation;
public:
    GuiButton(GuiContainer* owner, string id, string text, func_t func);

    virtual void onDraw(sf::RenderTarget& window);
    virtual bool onMouseDown(sf::Vector2f position);
    virtual void onMouseUp(sf::Vector2f position);
    
    GuiButton* setColor(sf::Color button_color);
    GuiButton* setText(string text);
    GuiButton* setTextSize(float size);
    GuiButton* setTextColor(sf::Color text_color);
    GuiButton* setIcon(string icon_name, EGuiAlign icon_alignment = ACenterLeft, float rotation=0);
    string getText() const;
    string getIcon() const;
};

#endif//GUI2_BUTTON_H
