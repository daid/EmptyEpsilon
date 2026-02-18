#include "gui2_element.h"
#include "theme.h"
#include "main.h"


GuiElement::GuiElement(GuiContainer* owner, const string& id)
: owner(owner), visible(true), enabled(true), hover(false), focus(false), id(id)
{
    owner->children.push_back(this);
    destroyed = false;
    theme = owner->theme;
}

GuiElement::~GuiElement()
{
    if (owner)
    {
        LOG(ERROR) << "GuiElement was destroyed while it still had an owner...";
    }
}

bool GuiElement::onMouseDown(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id)
{
    return false;
}

void GuiElement::onMouseDrag(glm::vec2 position, sp::io::Pointer::ID id)
{
}

void GuiElement::onMouseUp(glm::vec2 position, sp::io::Pointer::ID id)
{
}

bool GuiElement::onMouseWheelScroll(glm::vec2 position, float value)
{
    return false;
}

void GuiElement::onTextInput(const string& text)
{
}

void GuiElement::onTextInput(sp::TextInputEvent e)
{
}

void GuiElement::setAttribute(const string& key, const string& value)
{
    if (key == "visible")
        setVisible(value.toBool());
    else if (key == "enabled")
        setEnable(value.toBool());
    else
        GuiContainer::setAttribute(key, value);
}

GuiElement* GuiElement::setSize(glm::vec2 size)
{
    layout.size = size;
    layout.match_content_size = false;

    if (size.x == GuiSizeMax) {
        layout.size.x = 1.0;
        layout.fill_width = true;
    }
    if (layout.size.y == GuiSizeMax) {
        layout.size.y = 1.0;
        layout.fill_height = true;
    }
    if (size.x == GuiSizeMatchHeight) {
        layout.size.x = layout.size.y;
        layout.lock_aspect_ratio = true;
    }
    if (size.y == GuiSizeMatchWidth) {
        layout.size.y = layout.size.x;
        layout.lock_aspect_ratio = true;
    }
    return this;
}

GuiElement* GuiElement::setSize(float x, float y)
{
    return setSize({x, y});
}

glm::vec2 GuiElement::getSize() const
{
    return layout.size;
}

GuiElement* GuiElement::setMargins(float n)
{
    layout.margin.left = layout.margin.top = layout.margin.right = layout.margin.bottom = n;
    return this;
}

GuiElement* GuiElement::setMargins(float x, float y)
{
    layout.margin.left = layout.margin.right = x;
    layout.margin.top = layout.margin.bottom = y;
    return this;
}

GuiElement* GuiElement::setMargins(float left, float top, float right, float bottom)
{
    layout.margin.left = left;
    layout.margin.top = top;
    layout.margin.right = right;
    layout.margin.bottom = bottom;
    return this;
}

GuiElement* GuiElement::setParent(GuiContainer* new_parent)
{
    if (GuiContainer* old_owner = this->getOwner())
    {
        // Works only if both the old owner and new parent are valid.
        if (new_parent && old_owner != new_parent)
        {
            // Remove from old owner's children list.
            old_owner->children.remove(this);

            // Add to new owner's children list.
            new_parent->children.push_back(this);

            // Update owner pointer.
            this->owner = new_parent;
        }
        else
            LOG(Debug, "GuiElement::setParent called, but new parent is invalid.");
    }
    else
        LOG(Debug, "GuiElement::setParent called, but old owner is invalid.");

    return this;
}

GuiElement* GuiElement::setPosition(float x, float y, sp::Alignment alignment)
{
    layout.position.x = x;
    layout.position.y = y;
    layout.alignment = alignment;
    return this;
}

GuiElement* GuiElement::setPosition(glm::vec2 position, sp::Alignment alignment)
{
    layout.position = position;
    layout.alignment = alignment;
    return this;
}

glm::vec2 GuiElement::getPositionOffset() const
{
    return layout.position;
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

void GuiElement::moveToFront()
{
    if (owner)
    {
        owner->children.remove(this);
        owner->children.push_back(this);
    }
}

void GuiElement::moveToBack()
{
    if (owner)
    {
        owner->children.remove(this);
        owner->children.push_front(this);
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

glm::u8vec4 GuiElement::selectColor(const ColorSet& color_set) const
{
    if (!enabled)
        return color_set.disabled;
    if (hover)
        return color_set.hover;
    if (focus)
        return color_set.focus;
    return color_set.normal;
}

GuiElement::State GuiElement::getState() const
{
    if (!enabled)
        return State::Disabled;
    if (hover)
        return State::Hover;
    if (focus)
        return State::Focus;
    return State::Normal;
}
