#pragma once

#include "gui2_element.h"

class GuiScrollbar;

// GuiContainer-like GuiElement with support for clipping or scrolling arbitrary
// child elements that overflow its bounds.
class GuiScrollContainer : public GuiElement
{
public:
    // Define modes to indicate whether this element scrolls, and if so, how.
    enum class ScrollMode {
        None,   // Cut overflow off at element borders; no scrolling
        Scroll, // Scroll by fixed increments, regardless of contents or element size
        Page    // Scroll by increments equal to the element size
    };

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
    // Define whether this element scrolls, paginates, or only clips content.
    ScrollMode mode;
    // Defines the scrollbar's width, in virtual pixels.
    float scrollbar_width = 30.0f;
    // Scrollbar element, visible only if there's overflow.
    GuiScrollbar* scrollbar_v;

    // Defines the scroll offset in virtual pixels, with 0 as the top.
    float scroll_offset = 0.0f;
    // Defines the total height of content, in virtual pixels.
    float content_height = 0.0f;
    // Defines the visible height of the element, in virtual pixels.
    float visible_height = 0.0f;

    // Defines the element that has focus within this element's subtree.
    GuiElement* focused_element = nullptr;
    // Defines the element being clicked/tapped within this element's subtree.
    GuiElement* pressed_element = nullptr;
    // Defines the scroll position of the pressed element.
    float pressed_scroll = 0.0f;

    // Returns a rect for the area where content is visible.
    sp::Rect getContentRect() const;
    // Returns the effective scrollbar width, factoring in whether it appears
    // at all.
    float getEffectiveScrollbarWidth() const;
    // Passes focus to another element.
    void switchFocusTo(GuiElement* new_element);
};
