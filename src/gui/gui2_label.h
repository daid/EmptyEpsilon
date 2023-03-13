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

    virtual void onDraw(sp::RenderTarget& renderer) override;

    GuiLabel* setText(string text);
    string getText() const;
    GuiLabel* setAlignment(sp::Alignment alignment);
    GuiLabel* addBackground();
    GuiLabel* setVertical();
};

class GuiAutoSizeLabel : public GuiLabel
{
protected:
    glm::vec2 min_size;
    glm::vec2 max_size;
    float min_text_size;
    float max_text_size;
public:
    GuiAutoSizeLabel(GuiContainer* owner, string id, string text, glm::vec2 min_size, glm::vec2 max_size, float min_text_size, float max_text_size);

    virtual void onDraw(sp::RenderTarget& renderer) override;
    virtual void onUpdate() override;
};

#endif//GUI2_LABEL_H
