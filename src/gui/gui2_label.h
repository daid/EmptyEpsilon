#ifndef GUI2_LABEL_H
#define GUI2_LABEL_H

#include "gui2_element.h"


class GuiThemeStyle;
class GuiLabel : public GuiElement
{
protected:
    string text;
    float text_size;
    glm::u8vec4 text_color{255,255,255,255};
    sp::Alignment text_alignment;
    bool background;
    bool bold;
    bool vertical;
    const GuiThemeStyle* front_style;
    const GuiThemeStyle* back_style;
public:
    GuiLabel(GuiContainer* owner, string id, string text, float text_size);

    virtual void onDraw(sp::RenderTarget& target) override;

    GuiLabel* setText(string text);
    string getText() const;
    GuiLabel* setAlignment(sp::Alignment alignment);
    GuiLabel* addBackground();
    GuiLabel* setVertical();
};

#endif//GUI2_LABEL_H
