#pragma once

#include "gui/gui2_element.h"
#include "timer.h"

class GuiScrollingBanner : public GuiElement
{
public:
    GuiScrollingBanner(GuiContainer* owner);

    virtual void onDraw(sp::RenderTarget& target) override;
private:
    static constexpr float scroll_speed_per_second = 150.0f;

    sp::SystemStopwatch update_clock;
    bool has_scrolling_started = false;
    float draw_offset = 0.0f;
};
