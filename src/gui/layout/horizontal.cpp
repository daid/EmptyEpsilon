#include <gui/layout/horizontal.h>
#include <gui/gui2_element.h>
#include <logging.h>


GUI_REGISTER_LAYOUT("horizontal", GuiLayoutHorizontal);
GUI_REGISTER_LAYOUT("horizontalright", GuiLayoutHorizontalRight);

void GuiLayoutHorizontal::update(GuiContainer& container, const sp::Rect& rect)
{
    float total_width = 0.0f;
    float fill_width = 0.0f;
    for(GuiElement* w : container.children)
    {
        if (w->isDestroyed() || !w->isVisible())
            continue;
        float width = w->layout.size.x + w->layout.margin.left + w->layout.margin.right;
        total_width += width;
        if (w->layout.fill_width)
            fill_width += w->layout.size.x;
    }
    float remaining_width = rect.size.x - total_width;
    float x = rect.position.x;
    for(GuiElement* w : container.children)
    {
        if (w->isDestroyed() || !w->isVisible())
            continue;
        float width = w->layout.size.x + w->layout.margin.left + w->layout.margin.right;
        if (w->layout.fill_width && fill_width > 0.0f)
            width += remaining_width * w->layout.size.x / fill_width;
        basicLayout({x, rect.position.y, width, rect.size.y}, *w);
        x = w->getRect().position.x + w->getRect().size.x + w->layout.margin.right;
    }
}

void GuiLayoutHorizontalRight::update(GuiContainer& container, const sp::Rect& rect)
{
    float total_width = 0.0f;
    float fill_width = 0.0f;
    for(GuiElement* w : container.children)
    {
        if (w->isDestroyed() || !w->isVisible())
            continue;
        float width = w->layout.size.x + w->layout.margin.left + w->layout.margin.right;
        total_width += width;
        if (w->layout.fill_width)
            fill_width += w->layout.size.x;
    }
    float remaining_width = rect.size.x - total_width;
    float x = rect.position.x + rect.size.x;
    for(GuiElement* w : container.children)
    {
        if (w->isDestroyed() || !w->isVisible())
            continue;
        float width = w->layout.size.x + w->layout.margin.left + w->layout.margin.right;
        if (w->layout.fill_width && fill_width > 0.0f)
            width += remaining_width * w->layout.size.x / fill_width;
        basicLayout({x - width, rect.position.y, width, rect.size.y}, *w);
        x = w->getRect().position.x - w->layout.margin.left;
    }
}
