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

            renderer.drawText(sp::Rect(element->rect.position.x, element->rect.position.y - 20, element->rect.size.x, 20), element->id, sp::Alignment::TopLeft, 20, nullptr, glm::u8vec4(255, 0, 0, 255));
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
                    content_size_min.y = std::min(content_size_min.y, p0.y - w->layout.margin.top);
                    content_size_max.x = std::max(content_size_max.x, p1.x + w->layout.margin.right);
                    content_size_max.y = std::max(content_size_max.y, p1.y + w->layout.margin.bottom);
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

void GuiContainer::setAttribute(const string& key, const string& value)
{
    if (key == "size")
    {
        auto p = value.partition(",");
        layout.size.x = p.first.strip().toFloat();
        layout.size.y = p.second.strip().toFloat();
        layout.match_content_size = false;
    }
    else if (key == "width")
    {
        layout.size.x = value.toFloat();
        layout.match_content_size = false;
    }
    else if (key == "height")
    {
        layout.size.y = value.toFloat();
        layout.match_content_size = false;
    }
    else if (key == "position")
    {
        auto p = value.partition(",");
        layout.position.x = p.first.strip().toFloat();
        layout.position.y = p.first.strip().toFloat();
    }
    else if (key == "margin")
    {
        auto values = value.split(",", 3);
        if (values.size() == 1)
        {
            layout.margin.top = layout.margin.bottom = layout.margin.left = layout.margin.right = values[0].strip().toFloat();
        }
        else if (values.size() == 2)
        {
            layout.margin.left = layout.margin.right = values[0].strip().toFloat();
            layout.margin.top = layout.margin.bottom = values[1].strip().toFloat();
        }
        else if (values.size() == 3)
        {
            layout.margin.left = layout.margin.right = values[0].strip().toFloat();
            layout.margin.top = values[1].strip().toFloat();
            layout.margin.bottom = values[2].strip().toFloat();
        }
        else if (values.size() == 4)
        {
            layout.margin.left = values[0].strip().toFloat();
            layout.margin.right = values[1].strip().toFloat();
            layout.margin.top = values[2].strip().toFloat();
            layout.margin.bottom = values[3].strip().toFloat();
        }
    }
    else if (key == "padding")
    {
        auto values = value.split(",", 3);
        if (values.size() == 1)
        {
            layout.padding.top = layout.padding.bottom = layout.padding.left = layout.padding.right = values[0].strip().toFloat();
        }
        else if (values.size() == 2)
        {
            layout.padding.left = layout.padding.right = values[0].strip().toFloat();
            layout.padding.top = layout.padding.bottom = values[1].strip().toFloat();
        }
        else if (values.size() == 3)
        {
            layout.padding.left = layout.padding.right = values[0].strip().toFloat();
            layout.padding.top = values[1].strip().toFloat();
            layout.padding.bottom = values[2].strip().toFloat();
        }
        else if (values.size() == 4)
        {
            layout.padding.left = values[0].strip().toFloat();
            layout.padding.right = values[1].strip().toFloat();
            layout.padding.top = values[2].strip().toFloat();
            layout.padding.bottom = values[3].strip().toFloat();
        }
    }
    else if (key == "span")
    {
        auto p = value.partition(",");
        layout.span.x = p.first.strip().toInt();
        layout.span.y = p.second.strip().toInt();
    }
    else if (key == "alignment")
    {
        string v = value.lower();
        if (v == "topleft" || v == "lefttop") layout.alignment = sp::Alignment::TopLeft;
        else if (v == "top" || v == "topcenter" || v == "centertop") layout.alignment = sp::Alignment::TopCenter;
        else if (v == "topright" || v == "righttop") layout.alignment = sp::Alignment::TopRight;
        else if (v == "left" || v == "leftcenter" || v == "centerleft") layout.alignment = sp::Alignment::CenterLeft;
        else if (v == "center") layout.alignment = sp::Alignment::Center;
        else if (v == "right" || v == "rightcenter" || v == "centerright") layout.alignment = sp::Alignment::CenterRight;
        else if (v == "bottomleft" || v == "leftbottom") layout.alignment = sp::Alignment::BottomLeft;
        else if (v == "bottom" || v == "bottomcenter" || v == "centerbottom") layout.alignment = sp::Alignment::BottomCenter;
        else if (v == "bottomright" || v == "rightbottom") layout.alignment = sp::Alignment::BottomRight;
        else LOG(Warning, "Unknown alignment:", value);
    }
    else if (key == "layout")
    {
        GuiLayoutClassRegistry* reg;
        for(reg = GuiLayoutClassRegistry::first; reg != nullptr; reg = reg->next)
        {
            if (value == reg->name)
                break;
        }
        if (reg)
        {
            layout_manager = reg->creation_function();
        }else{
            LOG(Error, "Failed to find layout type:", value);
        }
    }
    else if (key == "stretch")
    {
        if (value == "aspect")
            layout.fill_height = layout.fill_width = layout.lock_aspect_ratio = true;
        else
            layout.fill_height = layout.fill_width = value.toBool();
        layout.match_content_size = false;
    }
    else if (key == "fill_height")
    {
        layout.fill_height = value.toBool();
        layout.match_content_size = false;
    }
    else if (key == "fill_width")
    {
        layout.fill_width = value.toBool();
        layout.match_content_size = false;
    }
    else
    {
        LOG(Warning, "Tried to set unknown widget attribute:", key, "to", value);
    }
}
