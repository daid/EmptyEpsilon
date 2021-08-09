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
    sp::Alignment text_alignment;
    func_t func;
    string icon_name;
    sp::Alignment icon_alignment;
    float icon_rotation;
    WidgetColorSet color_set;
public:
    GuiButton(GuiContainer* owner, string id, string text, func_t func);

    virtual void onDraw(sp::RenderTarget& target);
    virtual bool onMouseDown(glm::vec2 position);
    virtual void onMouseUp(glm::vec2 position);

    GuiButton* setText(string text);
    GuiButton* setTextSize(float size);
    GuiButton* setIcon(string icon_name, sp::Alignment icon_alignment = sp::Alignment::CenterLeft, float rotation = 0);
    GuiButton* setColors(WidgetColorSet color_set);
    string getText() const;
    string getIcon() const;
    WidgetColorSet getColors() const;
};

#endif//GUI2_BUTTON_H
