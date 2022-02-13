#ifndef GUI2_BUTTON_H
#define GUI2_BUTTON_H

#include "gui2_element.h"

class GuiThemeStyle;
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
    const GuiThemeStyle* back_style;
    const GuiThemeStyle* front_style;
public:
    GuiButton(GuiContainer* owner, string id, string text, func_t func);

    virtual void onDraw(sp::RenderTarget& target) override;
    virtual bool onMouseDown(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id) override;
    virtual void onMouseUp(glm::vec2 position, sp::io::Pointer::ID id) override;

    GuiButton* setText(string text);
    GuiButton* setTextSize(float size);
    GuiButton* setIcon(string icon_name, sp::Alignment icon_alignment = sp::Alignment::CenterLeft, float rotation = 0);
    GuiButton* setStyle(const string& style);
    string getText() const;
    string getIcon() const;
};

#endif//GUI2_BUTTON_H
