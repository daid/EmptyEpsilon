#ifndef GUI2_CONTAINER_H
#define GUI2_CONTAINER_H

#include <list>
#include <memory>
#include "rect.h"
#include "nonCopyable.h"
#include "io/pointer.h"
#include "graphics/alignment.h"

namespace sp {
    class RenderTarget;
}

class GuiElement;
class GuiLayout;
class GuiContainer : sp::NonCopyable
{
public:
public:
    class LayoutInfo
    {
    public:
        class Sides
        {
        public:
            float left = 0;
            float right = 0;
            float top = 0;
            float bottom = 0;
        };
        
        glm::vec2 position{0, 0};
        sp::Alignment alignment = sp::Alignment::TopLeft;
        glm::vec2 size{1, 1};
        glm::ivec2 span{1, 1};
        Sides margin;
        Sides padding;
        bool fill_width = false;
        bool fill_height = false;
        bool lock_aspect_ratio = false;
        bool match_content_size = true;
    };

    LayoutInfo layout;    
    std::list<GuiElement*> children;
public:
    GuiContainer() = default;
    virtual ~GuiContainer();

    template<typename T> void setLayout() { layout_manager = std::make_unique<T>(); }
    void updateLayout(const sp::Rect& rect);
    const sp::Rect& getRect() const { return rect; }
protected:
    virtual void drawElements(glm::vec2 mouse_position, sp::Rect parent_rect, sp::RenderTarget& window);
    virtual void drawDebugElements(sp::Rect parent_rect, sp::RenderTarget& window);
    GuiElement* getClickElement(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id);

    friend class GuiElement;

    sp::Rect rect{0,0,0,0};
private:
    std::unique_ptr<GuiLayout> layout_manager = nullptr;
};

#endif//GUI2_CONTAINER_H
