#include "gui2_scrollcontainer.h"
#include "gui2_scrollbar.h"
#include "gui2_canvas.h"
#include "gui/layout/layout.h"


GuiScrollContainer::GuiScrollContainer(GuiContainer* owner, const string& id, ScrollMode mode)
: GuiElement(owner, id), mode(mode)
{
    // We need to manipulate layout size to hide/show the scrollbar.
    layout.match_content_size = false;

    // Add a vertical scrollbar only if this element scrolls or pages.
    if (mode == ScrollMode::Scroll || mode == ScrollMode::Page)
    {
        scrollbar_v = new GuiScrollbar(this, id + "_SCROLLBAR_V", 0, 100, 0,
            [this](int value)
            {
                scroll_offset = static_cast<float>(value);
            }
        );
        scrollbar_v->setClickChange(50);
        scrollbar_v
            ->setPosition(0.0f, 0.0f, sp::Alignment::TopRight)
            ->setSize(scrollbar_width, GuiSizeMax);
    }
}

GuiScrollContainer* GuiScrollContainer::setMode(ScrollMode new_mode)
{
    mode = new_mode;
    return this;
}

GuiScrollContainer* GuiScrollContainer::setScrollbarWidth(float width)
{
    scrollbar_width = width;
    return this;
}

void GuiScrollContainer::scrollToFraction(float fraction)
{
    const float max_scroll = std::max(0.0f, content_height - visible_height);
    scroll_offset = std::clamp(fraction * max_scroll, 0.0f, max_scroll);
    if (scrollbar_v) scrollbar_v->setValue(static_cast<int>(scroll_offset));
}

void GuiScrollContainer::scrollToOffset(float pixel_offset)
{
    const float max_scroll = std::max(0.0f, content_height - visible_height);
    scroll_offset = std::clamp(pixel_offset, 0.0f, max_scroll);
    if (scrollbar_v) scrollbar_v->setValue(static_cast<int>(scroll_offset));
}

void GuiScrollContainer::updateLayout(const sp::Rect& rect)
{
    this->rect = rect;
    visible_height = rect.size.y - layout.padding.top - layout.padding.bottom;

    // Show the scrollbar only if we're clipping anything.
    scrollbar_visible = (scrollbar_v != nullptr) && (content_height > visible_height + 0.5f);
    // Don't factor scrollbar width if it isn't visible.
    const float sb_width = scrollbar_visible ? scrollbar_width : 0.0f;

    // Manually factor padding into content layout around the scrollbar.
    glm::vec2 padding_offset{
        layout.padding.left,
        layout.padding.top
    };

    glm::vec2 padding_size{
        layout.padding.left + layout.padding.right,
        layout.padding.top + layout.padding.bottom
    };

    sp::Rect content_layout_rect{
        rect.position + padding_offset,
        rect.size - padding_size - glm::vec2{sb_width, 0.0f}
    };

    if (!layout_manager) layout_manager = std::make_unique<GuiLayout>();

    // Temporarily hide the scrollbar so the layout manager ignores it for
    // sizing, then restore it if enabled.
    if (scrollbar_v) scrollbar_v->setVisible(false);

    layout_manager->updateLoop(*this, content_layout_rect);

    if (scrollbar_v)
    {
        scrollbar_v->setVisible(scrollbar_visible);

        // Override the scrollbar rect.
        scrollbar_v->updateLayout({
            {rect.position.x + rect.size.x - scrollbar_width, rect.position.y},
            {scrollbar_width, rect.size.y}
        });
    }

    // Compute content_height from non-scrollbar visible children.
    float max_bottom = 0.0f;
    for (GuiElement* child : children)
    {
        if (child == scrollbar_v) continue;
        if (!child->isVisible()) continue;

        const float bottom = child->getRect().position.y + child->getRect().size.y + child->layout.margin.bottom - rect.position.y;
        if (bottom > max_bottom) max_bottom = bottom;
    }
    content_height = max_bottom + layout.padding.bottom;

    // Clamp scroll offset.
    scroll_offset = std::clamp(scroll_offset, 0.0f, std::max(0.0f, content_height - visible_height));

    // Sync scrollbar properties to new layout.
    if (scrollbar_v)
    {
        scrollbar_v->setRange(0, static_cast<int>(content_height));
        scrollbar_v->setValueSize(static_cast<int>(visible_height));
        scrollbar_v->setValue(static_cast<int>(scroll_offset));
    }
}

void GuiScrollContainer::drawElements(glm::vec2 mouse_position, sp::Rect /* parent_rect */, sp::RenderTarget& renderer)
{
    sp::Rect content_rect = getContentRect();

    // Capture clipping and scroll translation.
    renderer.pushScissorRect(content_rect);
    renderer.pushTranslation({0.0f, -scroll_offset});

    // Track mouse position on element relative to the vertical scroll offset.
    glm::vec2 layout_mouse = mouse_position + glm::vec2{0.0f, scroll_offset};

    // Pass the relative mouse position through to each child element.
    for (auto it = children.begin(); it != children.end(); )
    {
        GuiElement* element = *it;

        if (element == scrollbar_v)
        {
            ++it;
            continue;
        }

        if (element->isDestroyed())
        {
            GuiCanvas* canvas = dynamic_cast<GuiCanvas*>(element->getTopLevelContainer());
            if (canvas) canvas->unfocusElementTree(element);

            it = children.erase(it);
            clearElementOwner(element);
            delete element;

            continue;
        }

        setElementHover(element, element->getRect().contains(layout_mouse));

        if (element->isVisible())
        {
            element->onDraw(renderer);
            callDrawElements(element, layout_mouse, element->getRect(), renderer);
        }

        ++it;
    }

    // Apply scroll translation and clipping. Order matters here.
    renderer.popTranslation();
    renderer.popScissorRect();

    // Draw the scrollbar. Never clip nor scroll the scrollbar itself.
    if (scrollbar_v
        && !scrollbar_v->isDestroyed()
        && scrollbar_v->isVisible()
    )
    {
        setElementHover(scrollbar_v, scrollbar_v->getRect().contains(mouse_position));
        scrollbar_v->onDraw(renderer);
        callDrawElements(scrollbar_v, mouse_position, scrollbar_v->getRect(), renderer);
    }
}

GuiElement* GuiScrollContainer::getClickElement(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id)
{
    // Pass the click to the scrollbar first, and don't translate its position.
    if (scrollbar_v
        && scrollbar_v->isVisible()
        && scrollbar_v->isEnabled()
        && scrollbar_v->getRect().contains(position)
    )
    {
        GuiElement* clicked = callGetClickElement(scrollbar_v, button, position, id);
        if (clicked) return clicked;
        if (scrollbar_v->onMouseDown(button, position, id)) return scrollbar_v;
    }

    // Don't pass clicks to elements outside of the content rect.
    if (!getContentRect().contains(position)) return nullptr;

    // Pass the click to each nested child, which should take priority if it can
    // use it.
    glm::vec2 layout_pos = position + glm::vec2{0.0f, scroll_offset};

    for (auto it = children.rbegin(); it != children.rend(); ++it)
    {
        GuiElement* element = *it;

        // We already handled the scrollbar.
        if (element == scrollbar_v) continue;
        // We don't care about buttons that aren't visible or enabled.
        if (!element->isVisible() || !element->isEnabled()) continue;

        // Figure out if we can click the element. If so, capture the scroll
        // offset to pass to drag events, focus it, and click it.
        GuiElement* clicked = callGetClickElement(element, button, layout_pos, id);
        if (clicked)
        {
            switchFocusTo(clicked);
            pressed_element = clicked;
            pressed_scroll = scroll_offset;
            return this;
        }

        // The click didn't fire, but we still recurse into children regardless.
        // This helps find children or child-like elements (like GuiSelector
        // popups) that can exist outside of their parent's rect.
        if (element->getRect().contains(layout_pos) && element->onMouseDown(button, layout_pos, id))
        {
            switchFocusTo(element);
            pressed_element = element;
            pressed_scroll = scroll_offset;
            return this;
        }
    }

    // Otherwise, do nothing.
    return nullptr;
}

void GuiScrollContainer::switchFocusTo(GuiElement* new_element)
{
    // Apply focus change, if any.
    if (focused_element == new_element) return;

    if (focused_element)
    {
        setElementFocus(focused_element, false);
        focused_element->onFocusLost();
    }

    focused_element = new_element;

    // If this scroll container already has canvas focus, forward focus gained
    // to the new child now (GuiCanvas won't call our onFocusGained again).
    // If this scroll container is not yet focused, canvas will call our
    // onFocusGained after getClickElement returns, which will forward it.
    if (focus)
    {
        setElementFocus(focused_element, true);
        focused_element->onFocusGained();
    }
}

void GuiScrollContainer::onFocusGained()
{
    if (focused_element)
    {
        setElementFocus(focused_element, true);
        focused_element->onFocusGained();
    }
}

void GuiScrollContainer::onFocusLost()
{
    if (focused_element)
    {
        setElementFocus(focused_element, false);
        focused_element->onFocusLost();
        focused_element = nullptr;
    }
}

void GuiScrollContainer::onTextInput(const string& text)
{
    if (focused_element) focused_element->onTextInput(text);
}

void GuiScrollContainer::onTextInput(sp::TextInputEvent e)
{
    if (focused_element) focused_element->onTextInput(e);
}

bool GuiScrollContainer::onMouseDown(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id)
{
    if (pressed_element)
    {
        pressed_element->onMouseDown(button, position + glm::vec2{0.0f, pressed_scroll}, id);
        pressed_element = nullptr;
        return true;
    }

    return false;
}

void GuiScrollContainer::onMouseDrag(glm::vec2 position, sp::io::Pointer::ID id)
{
    if (pressed_element) pressed_element->onMouseDrag(position + glm::vec2{0.0f, pressed_scroll}, id);
}    

void GuiScrollContainer::onMouseUp(glm::vec2 position, sp::io::Pointer::ID id)
{
    if (pressed_element)
    {
        pressed_element->onMouseUp(position + glm::vec2{0.0f, pressed_scroll}, id);
        pressed_element = nullptr;
    }
}

GuiElement* GuiScrollContainer::executeScrollOnElement(glm::vec2 position, float value)
{
    // Pass the scroll to the scrollbar first, and don't translate its position.
    if (scrollbar_v
        && scrollbar_v->isVisible()
        && scrollbar_v->isEnabled()
        && scrollbar_v->getRect().contains(position))
    {
        GuiElement* scrolled = callExecuteScrollOnElement(scrollbar_v, position, value);
        if (scrolled) return scrolled;
        // Handle mousewheel scroll, if any.
        if (scrollbar_v->onMouseWheelScroll(position, value)) return scrollbar_v;
    }

    // Return nothing if the scroll isn't within the container.
    if (!getContentRect().contains(position)) return nullptr;

    // Execute the scroll on each nested child. If a child can use the mousewheel
    // scroll event, give it to them.
    glm::vec2 layout_pos = position + glm::vec2{0.0f, scroll_offset};

    for (auto it = children.rbegin(); it != children.rend(); ++it)
    {
        GuiElement* element = *it;
        if (element == scrollbar_v) continue;

        if (element
            && element->isVisible()
            && element->isEnabled()
            && element->getRect().contains(layout_pos)
        )
        {
            GuiElement* scrolled = callExecuteScrollOnElement(element, layout_pos, value);
            if (scrolled) return scrolled;
            if (element->onMouseWheelScroll(layout_pos, value)) return element;
        }
    }

    // No child used the mousewheel scroll event, so use it to scroll the
    // container.
    if (onMouseWheelScroll(position, value)) return this;

    // Otherwise, nothing happens.
    return nullptr;
}

bool GuiScrollContainer::onMouseWheelScroll(glm::vec2 /* position */, float value)
{
    // Don't scroll if used only to clip.
    if (mode == ScrollMode::None) return false;

    // Scroll by a default interval of 50, or by the container height if set to
    // paged mode.
    const float step = (mode == ScrollMode::Page) ? visible_height : 50.0f;
    const float max_scroll = std::max(0.0f, content_height - visible_height);
    scroll_offset = std::clamp(scroll_offset - value * step, 0.0f, max_scroll);

    // Update the scrollbar if it exists.
    if (scrollbar_v) scrollbar_v->setValue(static_cast<int>(scroll_offset));

    return true;
}

sp::Rect GuiScrollContainer::getContentRect() const
{
    // Return the rect, inset by padding and minus room for the scrollbar if it's visible.
    return sp::Rect{
        rect.position + glm::vec2{layout.padding.left, layout.padding.top},
        {
            rect.size.x - layout.padding.left - layout.padding.right - getEffectiveScrollbarWidth(),
            rect.size.y - layout.padding.top - layout.padding.bottom
        }
    };
}

float GuiScrollContainer::getEffectiveScrollbarWidth() const
{
    // Save room for the scrollbar only if it's visible.
    return (scrollbar_v && scrollbar_visible) ? scrollbar_width : 0.0f;
}
