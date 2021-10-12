#include "gui2_element.h"
#include "main.h"


GuiElement::GuiElement(GuiContainer* owner, const string& id)
: position_alignment(sp::Alignment::TopLeft), owner(owner), rect(0, 0, 0, 0), visible(true), enabled(true), hover(false), focus(false), active(false), id(id)
{
    owner->elements.push_back(this);
    destroyed = false;
}

GuiElement::~GuiElement()
{
    if (owner)
    {
        LOG(ERROR) << "GuiElement was destroyed while it still had an owner...";
    }
}

bool GuiElement::onMouseDown(sp::io::Pointer::Button button, glm::vec2 position, int id)
{
    return false;
}

void GuiElement::onMouseDrag(glm::vec2 position, int id)
{
}

void GuiElement::onMouseUp(glm::vec2 position, int id)
{
}

void GuiElement::onTextInput(const string& text)
{
}

void GuiElement::onTextInput(sp::TextInputEvent e)
{
}

void GuiElement::onHotkey(const HotkeyResult& key)
{
}

bool GuiElement::onJoystickAxis(const AxisAction& axisAction)
{
    return false;
}

GuiElement* GuiElement::setSize(glm::vec2 size)
{
    this->size = size;
    return this;
}

GuiElement* GuiElement::setSize(float x, float y)
{
    this->size.x = x;
    this->size.y = y;
    return this;
}

glm::vec2 GuiElement::getSize() const
{
    return size;
}

GuiElement* GuiElement::setMargins(float n)
{
    margins.left = margins.top = margins.right = margins.bottom = n;
    return this;
}

GuiElement* GuiElement::setMargins(float x, float y)
{
    margins.left = margins.right = x;
    margins.top = margins.bottom = y;
    return this;
}

GuiElement* GuiElement::setMargins(float left, float top, float right, float bottom)
{
    margins.left = left;
    margins.top = top;
    margins.right = right;
    margins.bottom = bottom;
    return this;
}

GuiElement* GuiElement::setPosition(float x, float y, sp::Alignment alignment)
{
    this->position.x = x;
    this->position.y = y;
    this->position_alignment = alignment;
    return this;
}

GuiElement* GuiElement::setPosition(glm::vec2 position, sp::Alignment alignment)
{
    this->position = position;
    this->position_alignment = alignment;
    return this;
}

glm::vec2 GuiElement::getPositionOffset() const
{
    return position;
}

GuiElement* GuiElement::setVisible(bool visible)
{
    this->visible = visible;
    return this;
}

GuiElement* GuiElement::hide()
{
    setVisible(false);
    return this;
}

GuiElement* GuiElement::show()
{
    setVisible(true);
    return this;
}

bool GuiElement::isVisible() const
{
    return visible;
}

GuiElement* GuiElement::setEnable(bool enable)
{
    this->enabled = enable;
    return this;
}

GuiElement* GuiElement::enable()
{
    setEnable(true);
    return this;
}

GuiElement* GuiElement::disable()
{
    setEnable(false);
    return this;
}

bool GuiElement::isEnabled() const
{
    return enabled;
}

GuiElement* GuiElement::setActive(bool active)
{
    this->active = active;
    return this;
}

bool GuiElement::isActive() const
{
    return active;
}

void GuiElement::moveToFront()
{
    if (owner)
    {
        owner->elements.remove(this);
        owner->elements.push_back(this);
    }
}

void GuiElement::moveToBack()
{
    if (owner)
    {
        owner->elements.remove(this);
        owner->elements.push_front(this);
    }
}

glm::vec2 GuiElement::getCenterPoint() const
{
    return rect.center();
}

GuiContainer* GuiElement::getOwner()
{
    return owner;
}

GuiContainer* GuiElement::getTopLevelContainer()
{
    GuiContainer* top_level = owner;
    while(dynamic_cast<GuiElement*>(top_level) != nullptr)
        top_level = dynamic_cast<GuiElement*>(top_level)->getOwner();
    return top_level;
}

void GuiElement::destroy()
{
    destroyed = true;
}

bool GuiElement::isDestroyed()
{
    return destroyed;
}

void GuiElement::updateRect(sp::Rect parent_rect)
{
    glm::vec2 local_size = size;
    if (local_size.x == GuiSizeMax)
        local_size.x = parent_rect.size.x - fabs(position.x);
    if (local_size.y == GuiSizeMax)
        local_size.y = parent_rect.size.y - fabs(position.y);

    if (local_size.x == GuiSizeMatchHeight)
        local_size.x = local_size.y;
    if (local_size.y == GuiSizeMatchWidth)
        local_size.y = local_size.x;

    local_size.x -= margins.right + margins.left;
    local_size.y -= margins.bottom + margins.top;

    switch(position_alignment)
    {
    case sp::Alignment::TopLeft:
    case sp::Alignment::CenterLeft:
    case sp::Alignment::BottomLeft:
        rect.position.x = parent_rect.position.x + position.x + margins.left;
        break;
    case sp::Alignment::TopCenter:
    case sp::Alignment::Center:
    case sp::Alignment::BottomCenter:
        rect.position.x = parent_rect.position.x + parent_rect.size.x * 0.5f + position.x - local_size.x * 0.5f;
        break;
    case sp::Alignment::TopRight:
    case sp::Alignment::CenterRight:
    case sp::Alignment::BottomRight:
        rect.position.x = parent_rect.position.x + parent_rect.size.x + position.x - local_size.x - margins.right;
        break;
    }

    switch(position_alignment)
    {
    case sp::Alignment::TopLeft:
    case sp::Alignment::TopRight:
    case sp::Alignment::TopCenter:
        rect.position.y = parent_rect.position.y + position.y + margins.top;
        break;
    case sp::Alignment::CenterLeft:
    case sp::Alignment::CenterRight:
    case sp::Alignment::Center:
        rect.position.y = parent_rect.position.y + parent_rect.size.y / 2.0f + position.y - local_size.y / 2.0f;
        break;
    case sp::Alignment::BottomLeft:
    case sp::Alignment::BottomRight:
    case sp::Alignment::BottomCenter:
        rect.position.y = parent_rect.position.y + parent_rect.size.y + position.y - local_size.y - margins.bottom;
        break;
    }

    rect.size.x = local_size.x;
    rect.size.y = local_size.y;
    if (rect.size.x < 0)
    {
        rect.position.x += rect.size.x;
        rect.size.x = -rect.size.x;
    }
    if (rect.size.y < 0)
    {
        rect.position.y += rect.size.y;
        rect.size.y = -rect.size.y;
    }
}

glm::u8vec4 GuiElement::selectColor(const ColorSet& color_set) const
{
    if (!enabled)
        return color_set.disabled;
    if (active)
        return color_set.active;
    if (hover)
        return color_set.hover;
    if (focus)
        return color_set.focus;
    return color_set.normal;
}
