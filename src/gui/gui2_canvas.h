#ifndef GUI2_CANVAS_H
#define GUI2_CANVAS_H

#include "Renderable.h"
#include "gui2_container.h"


class GuiLayout;
class GuiCanvas : public Renderable, public GuiContainer
{
private:
    GuiElement* click_element;
    GuiElement* focus_element;
    glm::vec2 mouse_position;
    bool enable_debug_rendering;
public:
    GuiCanvas(RenderLayer* renderLayer=nullptr);
    virtual ~GuiCanvas();

    virtual void render(sp::RenderTarget& window) override;
    virtual bool onPointerMove(glm::vec2 position, sp::io::Pointer::ID id) override;
    virtual void onPointerLeave(sp::io::Pointer::ID id) override;
    virtual bool onPointerDown(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id) override;
    virtual void onPointerDrag(glm::vec2 position, sp::io::Pointer::ID id) override;
    virtual void onPointerUp(glm::vec2 position, sp::io::Pointer::ID id) override;
    virtual void onTextInput(const string& text) override;
    virtual void onTextInput(sp::TextInputEvent e) override;

    void focus(GuiElement* element);
    //Called when an element is destroyed in this tree. Recursive tests if the given element or any of it's children currently has focus, and unsets that focus.
    void unfocusElementTree(GuiElement* element);

private:
    void runUpdates(GuiContainer* parent);
};

#endif//GUI2_CANVAS_H
