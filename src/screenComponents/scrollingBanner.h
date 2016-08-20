#ifndef SCROLLING_BANNER_H
#define SCROLLING_BANNER_H

#include "gui/gui2_element.h"

class GuiScrollingBanner : public GuiElement
{
public:
    GuiScrollingBanner(GuiContainer* owner);

    virtual void onDraw(sf::RenderTarget& window);
private:
    static constexpr float scroll_speed_per_second = 100.0f;
    sf::Clock update_clock;
    float draw_offset;
};

#endif//SCROLLING_BANNER_H
