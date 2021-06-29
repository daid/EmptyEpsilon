#ifndef SCROLLING_BANNER_H
#define SCROLLING_BANNER_H

#include "gui/gui2_element.h"

class GuiScrollingBanner : public GuiElement
{
public:
    GuiScrollingBanner(GuiContainer* owner);

    virtual void onDraw(sf::RenderTarget& window);
private:
    static constexpr float scroll_speed_per_second = 150.0f;
    static constexpr float black_area = 200.0f;

    sp::SystemStopwatch update_clock;
    float draw_offset;
};

#endif//SCROLLING_BANNER_H
