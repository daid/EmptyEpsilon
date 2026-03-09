#pragma once

#include <list>
#include <memory>
#include "rect.h"
#include "nonCopyable.h"
#include "stringImproved.h"
#include "io/pointer.h"
#include "graphics/alignment.h"
#include "gui/layout/layout.h"

namespace sp {
    class RenderTarget;
}

class GuiElement;
class GuiLayout;
class GuiTheme;

class GuiContainer : sp::NonCopyable
{
public:
    // Nested type to capture layout attributes
    class LayoutInfo
    {
    public:
        class Sides
        {
        public:
            float left = 0.0f;
            float right = 0.0f;
            float top = 0.0f;
            float bottom = 0.0f;
        };
        
        glm::vec2 position{0.0f, 0.0f};
        sp::Alignment alignment = sp::Alignment::TopLeft;
        glm::vec2 size{1.0f, 1.0f};
        glm::ivec2 span{1, 1};
        Sides margin;
        Sides padding;
        bool fill_width = false;
        bool fill_height = false;
        bool lock_aspect_ratio = false;
        bool match_content_size = true;
    };

    GuiContainer() = default;
    virtual ~GuiContainer();

    // Public data
    LayoutInfo layout;
    std::list<GuiElement*> children;

    // Public interfaces
    template<typename T> void setLayout() { layout_manager = std::make_unique<T>(); }
    virtual void updateLayout(const sp::Rect& rect);
    virtual void setAttribute(const string& key, const string& value);
    const sp::Rect& getRect() const { return rect; }

protected:
    GuiTheme* theme;

    // Protected data
    sp::Rect rect{0,0,0,0};
    std::unique_ptr<GuiLayout> layout_manager = nullptr;

    // Protected interfaces
    virtual void drawElements(glm::vec2 mouse_position, sp::Rect parent_rect, sp::RenderTarget& window);
    virtual void drawDebugElements(sp::Rect parent_rect, sp::RenderTarget& window);
    virtual GuiElement* getClickElement(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id);
    virtual GuiElement* executeScrollOnElement(glm::vec2 position, float value);

    // Static helpers for subclass access to protected members.
    static void clearElementOwner(GuiElement* element);
    static void setElementHover(GuiElement* element, bool has_hover);
    static void setElementFocus(GuiElement* element, bool has_focus);
    static void callDrawElements(GuiContainer* container, glm::vec2 mouse_pos, sp::Rect rect, sp::RenderTarget& render_target);
    static GuiElement* callGetClickElement(GuiContainer* container, sp::io::Pointer::Button button, glm::vec2 pos, sp::io::Pointer::ID id);
    static GuiElement* callExecuteScrollOnElement(GuiContainer* container, glm::vec2 pos, float value);

    friend class GuiElement;
};
