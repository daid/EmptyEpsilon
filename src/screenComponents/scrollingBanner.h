#pragma once

#include "gui/gui2_element.h"
#include "timer.h"

class GuiThemeStyle;

class GuiScrollingBanner : public GuiElement
{
public:
    GuiScrollingBanner(GuiContainer* owner);

    virtual void onDraw(sp::RenderTarget& target) override;
private:
    static constexpr float scroll_speed_per_second = 150.0f;
    static constexpr float black_area = 200.0f;

    const GuiThemeStyle* banner_style;
    sp::SystemStopwatch update_clock;
    float draw_offset = 0.0f;
};
