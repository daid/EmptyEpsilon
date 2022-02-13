#ifndef GUI2_AUTOLAYOUT_H
#define GUI2_AUTOLAYOUT_H

#include "gui2_element.h"

class GuiAutoLayout : public GuiElement
{
public:
    enum ELayoutMode
    {
        /* Various layout options, set the position of children */
        LayoutVerticalTopToBottom,
        LayoutVerticalBottomToTop,

        LayoutHorizontalRows,   /* Evenly spaced horizontal rows. Using up all space. Sets the position and size of children */
        LayoutVerticalColumns   /* Evenly spaced vertical columns. Using up all space. Sets the position and size of children */
    };
private:
    ELayoutMode mode;
public:
    GuiAutoLayout(GuiContainer* owner, string id, ELayoutMode mode);

    virtual void onDraw(sp::RenderTarget& target) override;
protected:
    virtual void drawElements(glm::vec2 mouse_position, sp::Rect parent_rect, sp::RenderTarget& target) override;
};

#endif//GUI2_AUTOLAYOUT_H
