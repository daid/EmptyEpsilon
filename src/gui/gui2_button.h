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
    string icon_name;
    EGuiAlign icon_alignment;
    float icon_rotation;
    WidgetColorSet color_set;
public:
    GuiButton(GuiContainer* owner, string id, string text, func_t func);

    virtual void onDraw(sf::RenderTarget& window);
    virtual bool onMouseDown(sf::Vector2f position);
    virtual void onMouseUp(sf::Vector2f position);
    
    GuiButton* setText(string text);
    GuiButton* setTextSize(float size);
    GuiButton* setIcon(string icon_name, EGuiAlign icon_alignment = ACenterLeft, float rotation = 0);
    GuiButton* setColors(WidgetColorSet color_set);
    string getText() const;
    string getIcon() const;
    WidgetColorSet getColors() const;
};

#endif//GUI2_BUTTON_H
