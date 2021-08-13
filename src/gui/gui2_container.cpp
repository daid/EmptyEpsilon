#include "gui2_container.h"
#include "gui2_element.h"
#include "gui2_canvas.h"
#include "input.h"

GuiContainer::~GuiContainer()
{
    for(GuiElement* element : elements)
    {
        element->owner = nullptr;
        delete element;
    }
}

void GuiContainer::drawElements(sp::Rect parent_rect, sp::RenderTarget& renderer)
{
    auto mouse_position = InputHandler::getMousePos();
    for(auto it = elements.begin(); it != elements.end(); )
    {
        GuiElement* element = *it;
        if (element->destroyed)
        {
            //Find the owning cancas, as we need to remove ourselves if we are the focus or click element.
            GuiCanvas* canvas = dynamic_cast<GuiCanvas*>(element->getTopLevelContainer());
            if (canvas)
                canvas->unfocusElementTree(element);

            //Delete it from our list.
            it = elements.erase(it);

            // Free up the memory used by the element.
            element->owner = nullptr;
            delete element;
        }else{
            element->updateRect(parent_rect);
            element->hover = element->rect.contains(mouse_position);
            element->onUpdate();

            if (element->visible)
            {
                element->onDraw(renderer);
                element->drawElements(element->rect, renderer);
            }

            it++;
        }
    }
}

void GuiContainer::drawDebugElements(sp::Rect parent_rect, sp::RenderTarget& renderer)
{
    auto mouse_position = InputHandler::getMousePos();
    for(GuiElement* element : elements)
    {
        if (element->visible)
        {
            renderer.fillRect(element->rect, glm::u8vec4(255, 255, 255, 5));
            //TODO_GFX: renderer.outlineRect(element->rect, glm::u8vec4(255, 0, 255, 255));

            element->drawDebugElements(element->rect, renderer);

            if (element->rect.contains(mouse_position))
                renderer.drawText(sp::Rect(element->rect.position.x, element->rect.position.y - 20, element->rect.size.x, 20), element->id, sp::Alignment::TopLeft, 20, main_font, glm::u8vec4(255, 0, 0, 255));
        }
    }
}

GuiElement* GuiContainer::getClickElement(glm::vec2 mouse_position)
{
    for(std::list<GuiElement*>::reverse_iterator it = elements.rbegin(); it != elements.rend(); it++)
    {
        GuiElement* element = *it;

        if (element->hover && element->visible && element->enabled)
        {
            GuiElement* clicked = element->getClickElement(mouse_position);
            if (clicked)
                return clicked;
            if (element->onMouseDown(mouse_position))
            {
                return element;
            }
        }
    }
    return nullptr;
}

void GuiContainer::forwardKeypressToElements(const HotkeyResult& key)
{
    for(GuiElement* element : elements)
    {
        if (element->isVisible())
        {
            if (element->isEnabled())
                element->onHotkey(key);
            element->forwardKeypressToElements(key);
        }
    }
}

bool GuiContainer::forwardJoystickAxisToElements(const AxisAction& axisAction)
{
    for(GuiElement* element : elements)
    {
        if (element->isVisible())
        {
            if (element->isEnabled())
                if (element->onJoystickAxis(axisAction))
                    return true;
            if (element->forwardJoystickAxisToElements(axisAction))
                return true;
        }
    }
    return false;
}
