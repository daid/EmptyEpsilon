#include "gui2_canvas.h"
#include "gui2_element.h"
#include "theme.h"


GuiCanvas::GuiCanvas(RenderLayer* renderLayer)
: Renderable(renderLayer), click_element(nullptr), focus_element(nullptr)
{
    enable_debug_rendering = false;
    theme = GuiTheme::getTheme("default");
}

//due to a suspected compiler bug this deconstructor needs to be explicitly defined
GuiCanvas::~GuiCanvas()
{
}

void GuiCanvas::render(sp::RenderTarget& renderer)
{
    auto window_size = renderer.getVirtualSize();
    sp::Rect window_rect(0, 0, window_size.x, window_size.y);

    runUpdates(this);
    updateLayout(window_rect);
    drawElements(mouse_position, window_rect, renderer);

    if (enable_debug_rendering)
    {
        drawDebugElements(window_rect, renderer);
    }
}

bool GuiCanvas::onPointerMove(glm::vec2 position, sp::io::Pointer::ID id)
{
    mouse_position = position;
    return false;
}

void GuiCanvas::onPointerLeave(sp::io::Pointer::ID id)
{
    mouse_position = {-100, -100};
}

bool GuiCanvas::onPointerDown(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id)
{
    mouse_position = position;
    click_element = getClickElement(button, position, id);
    focus(click_element);
    return click_element != nullptr;
}

void GuiCanvas::onPointerDrag(glm::vec2 position, sp::io::Pointer::ID id)
{
    mouse_position = position;
    if (click_element)
        click_element->onMouseDrag(position, id);
}

void GuiCanvas::onPointerUp(glm::vec2 position, sp::io::Pointer::ID id)
{
    mouse_position = position;
    if (click_element)
    {
        click_element->onMouseUp(position, id);
        click_element = nullptr;
    }
}

void GuiCanvas::onTextInput(const string& text)
{
    if (focus_element)
        focus_element->onTextInput(text);
}

void GuiCanvas::onTextInput(sp::TextInputEvent e)
{
    if (focus_element)
        focus_element->onTextInput(e);
}

void GuiCanvas::focus(GuiElement* element)
{
    if (element == focus_element)
        return;

    if (focus_element)
    {
        focus_element->focus = false;
        focus_element->onFocusLost();
    }
    focus_element = element;
    if (focus_element)
    {
        focus_element->focus = true;
        focus_element->onFocusGained();
    }
}

void GuiCanvas::unfocusElementTree(GuiElement* element)
{
    if (focus_element == element)
        focus_element = nullptr;
    if (click_element == element)
        click_element = nullptr;
    for(GuiElement* child : element->children)
        unfocusElementTree(child);
}

void GuiCanvas::runUpdates(GuiContainer* parent)
{
    for(auto it = parent->children.begin(); it != parent->children.end(); )
    {
        GuiElement* element = *it;
        if (element->destroyed)
        {
            //Find the owning cancas, as we need to remove ourselves if we are the focus or click element.
            unfocusElementTree(element);

            //Delete it from our list.
            it = parent->children.erase(it);

            // Free up the memory used by the element.
            element->owner = nullptr;
            delete element;
        }else{
            element->hover = element->rect.contains(mouse_position);
            element->hover_coordinates = mouse_position;

            element->onUpdate();
            if (element->isVisible())
                runUpdates(element);

            it++;
        }
    }
}
