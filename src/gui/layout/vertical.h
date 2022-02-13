#ifndef GUI_LAYOUT_VERTICAL_H
#define GUI_LAYOUT_VERTICAL_H

#include "layout.h"


class GuiLayoutVertical : public GuiLayout
{
public:
    virtual void update(GuiContainer& container, const sp::Rect& rect) override;
};
class GuiLayoutVerticalBottom : public GuiLayout
{
public:
    virtual void update(GuiContainer& container, const sp::Rect& rect) override;
};

#endif//GUI_LAYOUT_VERTICAL_H
