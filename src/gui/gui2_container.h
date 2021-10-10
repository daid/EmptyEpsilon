#ifndef GUI2_CONTAINER_H
#define GUI2_CONTAINER_H

#include <list>
#include "gui/joystickConfig.h"
#include "rect.h"

class GuiElement;
class HotkeyResult;
class AxisAction;
class GuiContainer
{
protected:
    std::list<GuiElement*> elements;

public:
    GuiContainer() = default;
    virtual ~GuiContainer();

protected:
    virtual void drawElements(sp::Rect parent_rect, sp::RenderTarget& window);
    virtual void drawDebugElements(sp::Rect parent_rect, sp::RenderTarget& window);
    GuiElement* getClickElement(sp::io::Pointer::Button button, glm::vec2 position, int id);
    void forwardKeypressToElements(const HotkeyResult& key);
    bool forwardJoystickAxisToElements(const AxisAction& axisAction);

    friend class GuiElement;
};

#endif//GUI2_CONTAINER_H
