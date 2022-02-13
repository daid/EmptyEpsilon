#include <gui/layout/vertical.h>
#include <gui/gui2_element.h>
#include <logging.h>


GUI_REGISTER_LAYOUT("vertical", GuiLayoutVertical);
GUI_REGISTER_LAYOUT("verticalbottom", GuiLayoutVerticalBottom);

void GuiLayoutVertical::update(GuiContainer& container, const sp::Rect& rect)
{
    float total_height = 0.0f;
    float fill_height = 0.0f;
    for(GuiElement* w : container.children)
    {
        if (w->isDestroyed() || !w->isVisible())
            continue;
        float height = w->layout.size.y + w->layout.margin.top + w->layout.margin.bottom;
        total_height += height;
        if (w->layout.fill_height)
            fill_height += w->layout.size.x;
    }
    float remaining_height = rect.size.y - total_height;
    float y = rect.position.y;
    for(GuiElement* w : container.children)
    {
        if (w->isDestroyed() || !w->isVisible())
            continue;
        float height = w->layout.size.y + w->layout.margin.top + w->layout.margin.bottom;
        if (w->layout.fill_height && fill_height > 0.0f)
            height += remaining_height * w->layout.size.y / fill_height;
        basicLayout({rect.position.x, y, rect.size.x, height}, *w);
        y = w->getRect().position.y + w->getRect().size.y + w->layout.margin.bottom;
    }
}

void GuiLayoutVerticalBottom::update(GuiContainer& container, const sp::Rect& rect)
{
    float total_height = 0.0f;
    float fill_height = 0.0f;
    for(GuiElement* w : container.children)
    {
        if (w->isDestroyed() || !w->isVisible())
            continue;
        float height = w->layout.size.y + w->layout.margin.top + w->layout.margin.bottom;
        total_height += height;
        if (w->layout.fill_height)
            fill_height += w->layout.size.x;
    }
    float remaining_height = rect.size.y - total_height;
    float y = rect.position.y + rect.size.y;
    for(GuiElement* w : container.children)
    {
        if (w->isDestroyed() || !w->isVisible())
            continue;
        float height = w->layout.size.y + w->layout.margin.top + w->layout.margin.bottom;
        if (w->layout.fill_height && fill_height > 0.0f)
            height += remaining_height * w->layout.size.y / fill_height;
        basicLayout({rect.position.x, y - height, rect.size.x, height}, *w);
        y = w->getRect().position.y - w->layout.margin.top;
    }
}
