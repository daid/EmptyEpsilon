#include "gui2_container.h"
#include "gui2_element.h"
#include "gui2_canvas.h"

GuiContainer::~GuiContainer()
{
    for(GuiElement* element : children)
    {
        element->owner = nullptr;
        delete element;
    }
}

void GuiContainer::drawElements(glm::vec2 mouse_position, sp::Rect parent_rect, sp::RenderTarget& renderer)
{
    for(auto it = children.begin(); it != children.end(); )
    {
        GuiElement* element = *it;
        if (element->destroyed)
        {
            //Find the owning cancas, as we need to remove ourselves if we are the focus or click element.
            GuiCanvas* canvas = dynamic_cast<GuiCanvas*>(element->getTopLevelContainer());
            if (canvas)
                canvas->unfocusElementTree(element);

            //Delete it from our list.
            it = children.erase(it);

            // Free up the memory used by the element.
            element->owner = nullptr;
            delete element;
        }else{
            element->hover = element->rect.contains(mouse_position);
            element->onUpdate();

            if (element->visible)
            {
                element->onDraw(renderer);
                element->drawElements(mouse_position, element->rect, renderer);
            }

            it++;
        }
    }
}

void GuiContainer::drawDebugElements(sp::Rect parent_rect, sp::RenderTarget& renderer)
{
    for(GuiElement* element : children)
    {
        if (element->visible)
        {
            renderer.fillRect(element->rect, glm::u8vec4(255, 255, 255, 5));
            //TODO_GFX: renderer.outlineRect(element->rect, glm::u8vec4(255, 0, 255, 255));

            element->drawDebugElements(element->rect, renderer);

            renderer.drawText(sp::Rect(element->rect.position.x, element->rect.position.y - 20, element->rect.size.x, 20), element->id, sp::Alignment::TopLeft, 20, main_font, glm::u8vec4(255, 0, 0, 255));
        }
    }
}

GuiElement* GuiContainer::getClickElement(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id)
{
    for(auto it = children.rbegin(); it != children.rend(); it++)
    {
        GuiElement* element = *it;

        if (element->visible && element->enabled && element->rect.contains(position))
        {
            GuiElement* clicked = element->getClickElement(button, position, id);
            if (clicked)
                return clicked;
            if (element->onMouseDown(button, position, id))
            {
                return element;
            }
        }
    }
    return nullptr;
}

void GuiContainer::updateLayout(const sp::Rect& rect)
{
    this->rect = rect;
    if (layout_manager || !children.empty())
    {
        if (!layout_manager)
            layout_manager = std::make_unique<GuiLayout>();

        glm::vec2 padding_size(layout.padding.left + layout.padding.right, layout.padding.top + layout.padding.bottom);
        layout_manager->updateLoop(*this, sp::Rect(rect.position + glm::vec2{layout.padding.left, layout.padding.top}, rect.size - padding_size));
        if (layout.match_content_size)
        {
            glm::vec2 content_size_min(std::numeric_limits<float>::max(), std::numeric_limits<float>::max());
            glm::vec2 content_size_max(std::numeric_limits<float>::min(), std::numeric_limits<float>::min());
            for(auto w : children)
            {
                if (w && w->isVisible())
                {
                    glm::vec2 p0 = w->rect.position;
                    glm::vec2 p1 = p0 + w->rect.size;
                    content_size_min.x = std::min(content_size_min.x, p0.x - w->layout.margin.left);
                    content_size_min.y = std::min(content_size_min.y, p0.y - w->layout.margin.bottom);
                    content_size_max.x = std::max(content_size_max.x, p1.x + w->layout.margin.right);
                    content_size_max.y = std::max(content_size_max.y, p1.y + w->layout.margin.top);
                }
            }
            if (content_size_max.x != std::numeric_limits<float>::min())
            {
                this->rect.size = (content_size_max - content_size_min) + padding_size;
                layout.size = this->rect.size;
            }
        }
    }
}
