#ifndef GUI_LAYOUT_HORIZONTAL_H
#define GUI_LAYOUT_HORIZONTAL_H

#include "layout.h"


class GuiLayoutHorizontal : public GuiLayout
{
public:
    virtual void update(GuiContainer& container, const sp::Rect& rect) override;
};
class GuiLayoutHorizontalRight : public GuiLayout
{
public:
    virtual void update(GuiContainer& container, const sp::Rect& rect) override;
};

#endif//GUI_LAYOUT_HORIZONTAL_H
