#pragma once

#include "gui2_element.h"

class GuiScrollbar;

class GuiScrollContainer : public GuiElement
{
public:
    enum class ScrollMode {
        None,   // Cut overflow off at element borders; no scrolling
        Scroll, // Scroll by fixed increments, regardless of contents or element size
        Page    // Scroll by increments equal to the element size
    };

    // GuiContainer-like GuiElement with support for clipping or scrolling
    // arbitrary child elements that overflow its bounds.
    GuiScrollContainer(GuiContainer* owner, const string& id, ScrollMode mode = ScrollMode::Scroll);

    // TODO: Right now this clips both horizontally and vertically, but supports
    // only vertical scrolling/paging.

    // Set scrolling mode. All modes clip at the element boundaries.
    GuiScrollContainer* setMode(ScrollMode mode);
    // Set width of scrollbar if visible.
    GuiScrollContainer* setScrollbarWidth(float width);
    // Scroll element to this fraction of the total scrollbar limit.
    // Value passed here represents where the top of the scrollbar pill goes
    // on the scrollbar.
    void scrollToFraction(float fraction);
    // Scroll element to this pixel offset from the top (clamped to valid range).
    void scrollToOffset(float pixel_offset);

    // Override layout updates to update child elements and juggle scrollbar
    // visibility.
    virtual void updateLayout(const sp::Rect& rect) override;
    // Handle mousewheel scroll, with behavior depending on the ScrollMode.
    virtual bool onMouseWheelScroll(glm::vec2 position, float value) override;
    // Pass mouse down to child elements, but only if they're visible.
    virtual bool onMouseDown(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id) override;
    // Pass mouse drag to child elements. This relies on 
    virtual void onMouseDrag(glm::vec2 position, sp::io::Pointer::ID id) override;
    // Pass mouse up to child elements.
    virtual void onMouseUp(glm::vec2 position, sp::io::Pointer::ID id) override;
    // Pass focus to child elements.
    virtual void onFocusGained() override;
    // Pass focus loss to child elements.
    virtual void onFocusLost() override;
    // Pass text input events to child elements.
    virtual void onTextInput(const string& text) override;
    // Pass text input events to child elements.
    virtual void onTextInput(sp::TextInputEvent e) override;

protected:
    // Draw elements if they're in view. Translate mouse positions by the scroll
    // amount.
    virtual void drawElements(glm::vec2 mouse_position, sp::Rect parent_rect, sp::RenderTarget& renderer) override;
    // Find the clicked element, checking children of this container if they're
    // visible.
    virtual GuiElement* getClickElement(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id) override;
    // Scroll the element's children. Pass any mousewheel events to children
    // first if they can use it.
    virtual GuiElement* executeScrollOnElement(glm::vec2 position, float value) override;

private:
    ScrollMode mode;
    float scrollbar_width = 30.0f;
    GuiScrollbar* scrollbar_v = nullptr;

    float scroll_offset = 0.0f;
    float content_height = 0.0f;
    float visible_height = 0.0f;
    bool scrollbar_visible = false;

    GuiElement* focused_element = nullptr;
    GuiElement* pressed_element = nullptr;
    float pressed_scroll = 0.0f;

    sp::Rect getContentRect() const;
    float getEffectiveScrollbarWidth() const;
    void switchFocusTo(GuiElement* new_element);
};
