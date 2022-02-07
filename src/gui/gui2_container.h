#ifndef GUI2_CONTAINER_H
#define GUI2_CONTAINER_H

#include <list>
#include "rect.h"
#include "nonCopyable.h"
#include "io/pointer.h"

namespace sp {
    class RenderTarget;
}

class GuiElement;
class AxisAction;
class GuiContainer : sp::NonCopyable
{
protected:
    std::list<GuiElement*> elements;

public:
    GuiContainer() = default;
    virtual ~GuiContainer();

protected:
    virtual void drawElements(glm::vec2 mouse_position, sp::Rect parent_rect, sp::RenderTarget& window);
    virtual void drawDebugElements(sp::Rect parent_rect, sp::RenderTarget& window);
    GuiElement* getClickElement(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id);

    friend class GuiElement;
};

#endif//GUI2_CONTAINER_H
