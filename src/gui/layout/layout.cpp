#include <gui/layout/layout.h>
#include <gui/gui2_element.h>
#include <logging.h>


GuiLayoutClassRegistry* GuiLayoutClassRegistry::first;

GUI_REGISTER_LAYOUT("default", GuiLayout);

void GuiLayout::updateLoop(GuiContainer& container, const sp::Rect& rect)
{
    int repeat_counter = 10;
    do
    {
        require_repeat = false;
        update(container, rect);
        if (--repeat_counter < 1)
        {
            LOG(Warning, "Possible infinite loop in gui layout.");
            return;
        }
    } while(require_repeat);
}

void GuiLayout::update(GuiContainer& container, const sp::Rect& rect)
{
    for(GuiElement* w : container.children)
    {
        if (w->isDestroyed() || !w->isVisible()) {
            continue;
        }
        basicLayout(rect, *w);
    }
}

void GuiLayout::basicLayout(const sp::Rect& rect, GuiElement& widget)
{
    glm::vec2 result_position;
    glm::vec2 result_size;
    switch(widget.layout.alignment)
    {
    case sp::Alignment::TopLeft:
    case sp::Alignment::BottomLeft:
    case sp::Alignment::CenterLeft:
        result_position.x = rect.position.x + widget.layout.position.x + widget.layout.margin.left;
        if (widget.layout.fill_width)
            result_size.x = rect.size.x - widget.layout.margin.left - widget.layout.margin.right - widget.layout.position.x;
        else
            result_size.x = widget.layout.size.x;
        break;
    case sp::Alignment::TopCenter:
    case sp::Alignment::Center:
    case sp::Alignment::BottomCenter:
        if (widget.layout.fill_width)
            result_size.x = rect.size.x - widget.layout.margin.left - widget.layout.margin.right;
        else
            result_size.x = widget.layout.size.x;
        result_position.x = rect.position.x + rect.size.x / 2.0f - result_size.x / 2.0f + widget.layout.position.x;
        break;
    case sp::Alignment::TopRight:
    case sp::Alignment::CenterRight:
    case sp::Alignment::BottomRight:
        result_position.x = rect.position.x + widget.layout.position.x + widget.layout.margin.left;
        if (widget.layout.fill_width)
            result_size.x = rect.size.x - widget.layout.margin.left - widget.layout.margin.right + widget.layout.position.x;
        else
            result_size.x = widget.layout.size.x;
        result_position.x = rect.position.x + rect.size.x - widget.layout.margin.right + widget.layout.position.x - result_size.x;
        break;
    }

    switch(widget.layout.alignment)
    {
    case sp::Alignment::TopLeft:
    case sp::Alignment::TopCenter:
    case sp::Alignment::TopRight:
        result_position.y = rect.position.y + widget.layout.position.y + widget.layout.margin.top;
        if (widget.layout.fill_height)
            result_size.y = rect.size.y - widget.layout.margin.top - widget.layout.margin.bottom - widget.layout.position.y;
        else
            result_size.y = widget.layout.size.y;
        break;
    case sp::Alignment::CenterLeft:
    case sp::Alignment::Center:
    case sp::Alignment::CenterRight:
        if (widget.layout.fill_height)
            result_size.y = rect.size.y - widget.layout.margin.top - widget.layout.margin.bottom;
        else
            result_size.y = widget.layout.size.y;
        result_position.y = rect.position.y + rect.size.y / 2.0f - result_size.y / 2.0f + widget.layout.position.y;
        break;
    case sp::Alignment::BottomLeft:
    case sp::Alignment::BottomCenter:
    case sp::Alignment::BottomRight:
        result_position.y = rect.position.y + widget.layout.position.y + widget.layout.margin.top;
        if (widget.layout.fill_height)
            result_size.y = rect.size.y - widget.layout.margin.top - widget.layout.margin.bottom + widget.layout.position.y;
        else
            result_size.y = widget.layout.size.y;
        result_position.y = rect.position.y + rect.size.y - widget.layout.margin.bottom + widget.layout.position.y - result_size.y;
        break;
    }
    if (widget.layout.lock_aspect_ratio)
    {
        float aspect = widget.layout.size.x / widget.layout.size.y;
        if (widget.layout.fill_height && widget.layout.fill_width)
        {
            float current_aspect = result_size.x / result_size.y;
            if (current_aspect > aspect)
            {
                switch(widget.layout.alignment)
                {
                case sp::Alignment::TopLeft:
                case sp::Alignment::CenterLeft:
                case sp::Alignment::BottomLeft:
                    break;
                case sp::Alignment::TopCenter:
                case sp::Alignment::Center:
                case sp::Alignment::BottomCenter:
                    result_position.x += (result_size.x - result_size.y * aspect) * 0.5f;
                    break;
                case sp::Alignment::TopRight:
                case sp::Alignment::CenterRight:
                case sp::Alignment::BottomRight:
                    result_position.x += result_size.x - result_size.y * aspect;
                    break;
                }
                result_size.x = result_size.y * aspect;
            }
            else
            {
                switch(widget.layout.alignment)
                {
                case sp::Alignment::TopLeft:
                case sp::Alignment::TopCenter:
                case sp::Alignment::TopRight:
                    break;
                case sp::Alignment::CenterLeft:
                case sp::Alignment::Center:
                case sp::Alignment::CenterRight:
                    result_position.y += (result_size.y - result_size.x / aspect) * 0.5f;
                    break;
                case sp::Alignment::BottomLeft:
                case sp::Alignment::BottomCenter:
                case sp::Alignment::BottomRight:
                    result_position.y += result_size.y - result_size.x / aspect;
                    break;
                }
                result_size.y = result_size.x / aspect;
            }
        }
        else if (widget.layout.fill_height)
        {
            switch(widget.layout.alignment)
            {
            case sp::Alignment::TopLeft:
            case sp::Alignment::CenterLeft:
            case sp::Alignment::BottomLeft:
                break;
            case sp::Alignment::TopCenter:
            case sp::Alignment::Center:
            case sp::Alignment::BottomCenter:
                result_position.x += (result_size.x - result_size.y * aspect) * 0.5f;
                break;
            case sp::Alignment::TopRight:
            case sp::Alignment::CenterRight:
            case sp::Alignment::BottomRight:
                result_position.x += result_size.x - result_size.y * aspect;
                break;
            }
            result_size.x = result_size.y * aspect;
        }
        else if (widget.layout.fill_width)
        {
            switch(widget.layout.alignment)
            {
            case sp::Alignment::TopLeft:
            case sp::Alignment::TopCenter:
            case sp::Alignment::TopRight:
                break;
            case sp::Alignment::CenterLeft:
            case sp::Alignment::Center:
            case sp::Alignment::CenterRight:
                result_position.y += (result_size.y - result_size.x / aspect) * 0.5f;
                break;
            case sp::Alignment::BottomLeft:
            case sp::Alignment::BottomCenter:
            case sp::Alignment::BottomRight:
                result_position.y += result_size.y - result_size.x / aspect;
                break;
            }
            result_size.y = result_size.x / aspect;
        }
    }
    auto pre_layout_size = widget.layout.size;
    widget.updateLayout({result_position, result_size});

    auto size_diff = pre_layout_size - widget.layout.size;
    if (std::abs(size_diff.x) + std::abs(size_diff.y) > 0.1f)
    {
        require_repeat = true;
    }
}
