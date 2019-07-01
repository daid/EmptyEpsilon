#include "gui2_element.h"
#include "main.h"

GuiElement::GuiElement(GuiContainer* owner, string id)
: position_alignment(ATopLeft), owner(owner), rect(0, 0, 0, 0), visible(true), enabled(true), hover(false), focus(false), active(false), id(id)
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

bool GuiElement::onMouseDown(sf::Vector2f position)
{
    return false;
}

void GuiElement::onMouseDrag(sf::Vector2f position)
{
}

void GuiElement::onMouseUp(sf::Vector2f position)
{
}

bool GuiElement::onKey(sf::Event::KeyEvent key, int unicode)
{
    return false;
}

void GuiElement::onHotkey(const HotkeyResult& key)
{
}

GuiElement* GuiElement::setSize(sf::Vector2f size)
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

sf::Vector2f GuiElement::getSize() const
{
    return size;
}

GuiElement* GuiElement::setMargins(float n)
{
    margins.left = margins.top = margins.width = margins.height = n;
    return this;
}

GuiElement* GuiElement::setMargins(float x, float y)
{
    margins.left = margins.width = x;
    margins.top = margins.height = y;
    return this;
}

GuiElement* GuiElement::setMargins(float left, float top, float right, float bottom)
{
    margins.left = left;
    margins.top = top;
    margins.width = right;
    margins.height = bottom;
    return this;
}

GuiElement* GuiElement::setPosition(float x, float y, EGuiAlign alignment)
{
    this->position.x = x;
    this->position.y = y;
    this->position_alignment = alignment;
    return this;
}

GuiElement* GuiElement::setPosition(sf::Vector2f position, EGuiAlign alignment)
{
    this->position = position;
    this->position_alignment = alignment;
    return this;
}

sf::Vector2f GuiElement::getPositionOffset() const
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

sf::Vector2f GuiElement::getCenterPoint() const
{
    return sf::Vector2f(rect.left + rect.width / 2.0, rect.top + rect.height / 2.0);
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

void GuiElement::updateRect(sf::FloatRect parent_rect)
{
    sf::Vector2f local_size = size;
    if (local_size.x == GuiSizeMax)
        local_size.x = parent_rect.width - fabs(position.x);
    if (local_size.y == GuiSizeMax)
        local_size.y = parent_rect.height - fabs(position.y);
    
    if (local_size.x == GuiSizeMatchHeight)
        local_size.x = local_size.y;
    if (local_size.y == GuiSizeMatchWidth)
        local_size.y = local_size.x;
    
    local_size.x -= margins.width + margins.left;
    local_size.y -= margins.height + margins.top;
    
    switch(position_alignment)
    {
    case ATopLeft:
    case ACenterLeft:
    case ABottomLeft:
        rect.left = parent_rect.left + position.x + margins.left;
        break;
    case ATopCenter:
    case ACenter:
    case ABottomCenter:
        rect.left = parent_rect.left + parent_rect.width / 2.0 + position.x - local_size.x / 2.0;
        break;
    case ATopRight:
    case ACenterRight:
    case ABottomRight:
        rect.left = parent_rect.left + parent_rect.width + position.x - local_size.x - margins.width;
        break;
    }

    switch(position_alignment)
    {
    case ATopLeft:
    case ATopRight:
    case ATopCenter:
        rect.top = parent_rect.top + position.y + margins.top;
        break;
    case ACenterLeft:
    case ACenterRight:
    case ACenter:
        rect.top = parent_rect.top + parent_rect.height / 2.0 + position.y - local_size.y / 2.0;
        break;
    case ABottomLeft:
    case ABottomRight:
    case ABottomCenter:
        rect.top = parent_rect.top + parent_rect.height + position.y - local_size.y - margins.height;
        break;
    }
    
    rect.width = local_size.x;
    rect.height = local_size.y;
    if (rect.width < 0)
    {
        rect.left += rect.width;
        rect.width = -rect.width;
    }
    if (rect.height < 0)
    {
        rect.top += rect.height;
        rect.height = -rect.height;
    }
}

static int powerOfTwo(int v)
{
    v--;
    v |= v >> 1;
    v |= v >> 2;
    v |= v >> 4;
    v |= v >> 8;
    v |= v >> 16;
    v++;
    return v;
}

void GuiElement::adjustRenderTexture(sf::RenderTexture& texture)
{
    P<WindowManager> window_manager = engine->getObject("windowManager");
    //Hack the rectangle for this element so it sits perfectly on pixel boundaries.
    sf::Vector2f half_pixel = (window_manager->mapPixelToCoords(sf::Vector2i(1, 1)) - window_manager->mapPixelToCoords(sf::Vector2i(0, 0))) / 2.0f;
    sf::Vector2f top_left = window_manager->mapPixelToCoords(window_manager->mapCoordsToPixel(sf::Vector2f(rect.left, rect.top) + half_pixel));
    sf::Vector2f bottom_right = window_manager->mapPixelToCoords(window_manager->mapCoordsToPixel(sf::Vector2f(rect.left + rect.width, rect.top + rect.height) + half_pixel));
    rect.left = top_left.x;
    rect.top = top_left.y;
    rect.width = bottom_right.x - top_left.x;
    rect.height = bottom_right.y - top_left.y;

    sf::Vector2i texture_size = window_manager->mapCoordsToPixel(sf::Vector2f(rect.width, rect.height) + half_pixel) - window_manager->mapCoordsToPixel(sf::Vector2f(0, 0));
    unsigned int sx = powerOfTwo(texture_size.x);
    unsigned int sy = powerOfTwo(texture_size.y);
    if (texture.getSize().x != sx && texture.getSize().y != sy)
    {
        texture.create(sx, sy, false);
    }
    //Set the view so it covers this elements normal rect. So we can draw exactly the same on this texture as no the normal screen.
    sf::View view(rect);
    view.setViewport(sf::FloatRect(0, 0, float(texture_size.x) / float(sx), float(texture_size.y) / float(sy)));
    texture.setView(view);
}

void GuiElement::drawRenderTexture(sf::RenderTexture& texture, sf::RenderTarget& window, sf::Color color, const sf::RenderStates& states)
{
    texture.display();
    
    sf::Sprite sprite(texture.getTexture());
    sprite.setTextureRect(sf::IntRect(0, 0, texture.getSize().x * texture.getView().getViewport().width, texture.getSize().y * texture.getView().getViewport().height));
    sprite.setColor(color);
    sprite.setPosition(rect.left, rect.top);
    sprite.setScale(rect.width / float(texture.getSize().x * texture.getView().getViewport().width), rect.height / float(texture.getSize().y * texture.getView().getViewport().height));
    window.draw(sprite, states);
}

void GuiElement::drawText(sf::RenderTarget& window, sf::FloatRect rect, string text, EGuiAlign align, float font_size, sf::Font* font, sf::Color color)
{
    sf::Text textElement(text, *font, font_size);
    float y = 0;
    float x = 0;
    
    //The "base line" of the text draw is the "Y position where the text is drawn" + font_size.
    //The height of normal text is 70% of the font_size.
    //So use those properties to align the text. Depending on the localbounds does not work.
    switch(align)
    {
    case ATopLeft:
    case ATopRight:
    case ATopCenter:
        y = rect.top - 0.3 * font_size;
        break;
    case ABottomLeft:
    case ABottomRight:
    case ABottomCenter:
        y = rect.top + rect.height - font_size;
        break;
    case ACenterLeft:
    case ACenterRight:
    case ACenter:
        y = rect.top + rect.height / 2.0 - font_size + font_size * 0.35;
        break;
    }
    
    switch(align)
    {
    case ATopLeft:
    case ABottomLeft:
    case ACenterLeft:
        x = rect.left - textElement.getLocalBounds().left;
        break;
    case ATopRight:
    case ABottomRight:
    case ACenterRight:
        x = rect.left + rect.width - textElement.getLocalBounds().width - textElement.getLocalBounds().left;
        break;
    case ATopCenter:
    case ABottomCenter:
    case ACenter:
        x = rect.left + rect.width / 2.0 - textElement.getLocalBounds().width / 2.0 - textElement.getLocalBounds().left;
        break;
    }
    textElement.setPosition(x, y);
    textElement.setColor(color);
    window.draw(textElement);
}

void GuiElement::drawVerticalText(sf::RenderTarget& window, sf::FloatRect rect, string text, EGuiAlign align, float font_size, sf::Font* font, sf::Color color)
{
    sf::Text textElement(text, *font, font_size);
    textElement.setRotation(-90);
    float x = 0;
    float y = 0;
    x = rect.left + rect.width / 2.0 - textElement.getLocalBounds().height / 2.0 - textElement.getLocalBounds().top;
    switch(align)
    {
    case ATopLeft:
    case ABottomLeft:
    case ACenterLeft:
        y = rect.top + rect.height;
        break;
    case ATopRight:
    case ABottomRight:
    case ACenterRight:
        y = rect.top + textElement.getLocalBounds().left + textElement.getLocalBounds().width;
        break;
    case ATopCenter:
    case ABottomCenter:
    case ACenter:
        y = rect.top + rect.height / 2.0 + textElement.getLocalBounds().width / 2.0 + textElement.getLocalBounds().left;
        break;
    }
    textElement.setPosition(x, y);
    textElement.setColor(color);
    window.draw(textElement);
}

void GuiElement::draw9Cut(sf::RenderTarget& window, sf::FloatRect rect, string texture, sf::Color color, float width_factor)
{
    sf::Sprite sprite;
    textureManager.setTexture(sprite, texture);
    sf::IntRect textureSize = sprite.getTextureRect();
    int cornerSizeT = textureSize.height / 3;
    float cornerSizeR = cornerSizeT;
    float scale = 1.0;
    if (cornerSizeT > rect.height / 2)
    {
        scale = float(rect.height / 2) / cornerSizeR;
        sprite.setScale(scale, scale);
        cornerSizeR *= scale;
    }else if (cornerSizeT > rect.width / 2)
    {
        scale = float(rect.width / 2) / cornerSizeR;
        sprite.setScale(scale, scale);
        cornerSizeR *= scale;
    }

    sprite.setColor(color);
    sprite.setOrigin(0, 0);

    float w = 1.0;
    if (cornerSizeR > rect.width * width_factor)
        w = rect.width * width_factor / cornerSizeR;

    //TopLeft
    sprite.setPosition(rect.left, rect.top);
    sprite.setTextureRect(sf::IntRect(0, 0, cornerSizeT * w, cornerSizeT));
    window.draw(sprite);
    //BottomLeft
    sprite.setPosition(rect.left, rect.top + rect.height - cornerSizeR);
    sprite.setTextureRect(sf::IntRect(0, textureSize.height - cornerSizeT, cornerSizeT * w, cornerSizeT));
    window.draw(sprite);

    if (rect.height > cornerSizeR * 2)
    {
        //left
        sprite.setPosition(rect.left, rect.top + cornerSizeR);
        sprite.setTextureRect(sf::IntRect(0, cornerSizeT, cornerSizeT * w, 1));
        sprite.setScale(scale, rect.height - cornerSizeR*2);
        window.draw(sprite);
        sprite.setScale(scale, scale);
    }
    if (w < 1.0)
        return;

    if (rect.width - cornerSizeR > rect.width * width_factor)
        w = (width_factor - cornerSizeR / rect.width) * (rect.width / (rect.width - cornerSizeR * 2));

    if (rect.width > cornerSizeR * 2)
    {
        //Top
        sprite.setPosition(rect.left + cornerSizeR, rect.top);
        sprite.setTextureRect(sf::IntRect(cornerSizeT, 0, textureSize.width - cornerSizeT * 2, cornerSizeT));
        sprite.setScale((rect.width - cornerSizeR*2) / float(textureSize.width - cornerSizeT * 2) * w, scale);
        window.draw(sprite);
        //Bottom
        sprite.setPosition(rect.left + cornerSizeR, rect.top + rect.height - cornerSizeR);
        sprite.setTextureRect(sf::IntRect(cornerSizeT, textureSize.height - cornerSizeT, textureSize.width - cornerSizeT * 2, cornerSizeT));
        sprite.setScale((rect.width - cornerSizeR*2) / float(textureSize.width - cornerSizeT * 2) * w, scale);
        window.draw(sprite);
        sprite.setScale(scale, scale);
    }

    if (rect.width > cornerSizeR * 2 && rect.height > cornerSizeR * 2)
    {
        //Center
        sprite.setPosition(rect.left + cornerSizeR, rect.top + cornerSizeR);
        sprite.setTextureRect(sf::IntRect(cornerSizeT, cornerSizeT, 1, 1));
        sprite.setScale((rect.width - cornerSizeR*2) * w, rect.height - cornerSizeR*2);
        window.draw(sprite);
        sprite.setScale(scale, scale);
    }
    if (w < 1.0)
        return;
    if (width_factor < 1.0)
        w = (width_factor - (rect.width - cornerSizeR) / rect.width) * (rect.width / cornerSizeR);

    //TopRight
    sprite.setPosition(rect.left + rect.width - cornerSizeR, rect.top);
    sprite.setTextureRect(sf::IntRect(textureSize.width - cornerSizeT, 0, cornerSizeT * w, cornerSizeT));
    window.draw(sprite);
    //BottomRight
    sprite.setPosition(rect.left + rect.width - cornerSizeR, rect.top + rect.height - cornerSizeR);
    sprite.setTextureRect(sf::IntRect(textureSize.width - cornerSizeT, textureSize.height - cornerSizeT, cornerSizeT * w, cornerSizeT));
    window.draw(sprite);

    if (rect.height > cornerSizeR * 2)
    {
        //Right
        sprite.setPosition(rect.left + rect.width - cornerSizeR, rect.top + cornerSizeR);
        sprite.setTextureRect(sf::IntRect(textureSize.width - cornerSizeT, cornerSizeT, cornerSizeT * w, 1));
        sprite.setScale(scale, rect.height - cornerSizeR*2);
        window.draw(sprite);
    }
}

void GuiElement::draw9CutV(sf::RenderTarget& window, sf::FloatRect rect, string texture, sf::Color color, float height_factor)
{
    sf::Sprite sprite;
    textureManager.setTexture(sprite, texture);
    sf::IntRect textureSize = sprite.getTextureRect();
    int cornerSizeT = textureSize.height / 3;
    float cornerSizeR = cornerSizeT;
    float scale = 1.0;
    if (cornerSizeT > rect.height / 2)
    {
        scale = float(rect.height / 2) / cornerSizeR;
        sprite.setScale(scale, scale);
        cornerSizeR *= scale;
    }else if (cornerSizeT > rect.width / 2)
    {
        scale = float(rect.width / 2) / cornerSizeR;
        sprite.setScale(scale, scale);
        cornerSizeR *= scale;
    }

    sprite.setColor(color);
    sprite.setOrigin(0, 0);

    float h = 1.0;
    if (cornerSizeR > rect.height * height_factor)
        h = rect.height * height_factor / cornerSizeR;

    //BottomLeft
    sprite.setPosition(rect.left, rect.top + rect.height - cornerSizeR * h);
    sprite.setTextureRect(sf::IntRect(0, textureSize.height - cornerSizeT * h, cornerSizeT, cornerSizeT * h));
    window.draw(sprite);
    //BottomRight
    sprite.setPosition(rect.left + rect.width - cornerSizeR, rect.top + rect.height - cornerSizeR * h);
    sprite.setTextureRect(sf::IntRect(textureSize.width - cornerSizeT, textureSize.height - cornerSizeT * h, cornerSizeT, cornerSizeT * h));
    window.draw(sprite);
    
    if (rect.width > cornerSizeR * 2)
    {
        //Bottom
        sprite.setPosition(rect.left + cornerSizeR, rect.top + rect.height - cornerSizeR * h);
        sprite.setTextureRect(sf::IntRect(cornerSizeT, textureSize.height - cornerSizeT * h, textureSize.width - cornerSizeT * 2, cornerSizeT * h));
        sprite.setScale((rect.width - cornerSizeR*2) / float(textureSize.width - cornerSizeT * 2), scale);
        window.draw(sprite);
        sprite.setScale(scale, scale);
    }
    
    if (h < 1.0)
        return;

    if (rect.height - cornerSizeR > rect.height * height_factor)
        h = (height_factor - cornerSizeR / rect.height) * (rect.height / (rect.height - cornerSizeR * 2));

    if (rect.height > cornerSizeR * 2)
    {
        //left
        sprite.setPosition(rect.left, rect.top + cornerSizeR + (rect.height - cornerSizeR * 2) * (1.0f - h));
        sprite.setTextureRect(sf::IntRect(0, cornerSizeT, cornerSizeT, 1));
        sprite.setScale(scale, (rect.height - cornerSizeR*2) * h);
        window.draw(sprite);
        sprite.setScale(scale, scale);
        //Right
        sprite.setPosition(rect.left + rect.width - cornerSizeR, rect.top + cornerSizeR + (rect.height - cornerSizeR * 2) * (1.0f - h));
        sprite.setTextureRect(sf::IntRect(textureSize.width - cornerSizeT, cornerSizeT, cornerSizeT, 1));
        sprite.setScale(scale, (rect.height - cornerSizeR*2) * h);
        window.draw(sprite);
    }

    if (rect.width > cornerSizeR * 2 && rect.height > cornerSizeR * 2)
    {
        //Center
        sprite.setPosition(rect.left + cornerSizeR, rect.top + cornerSizeR + (rect.height - cornerSizeR * 2) * (1.0f - h));
        sprite.setTextureRect(sf::IntRect(cornerSizeT, cornerSizeT, 1, 1));
        sprite.setScale(rect.width - cornerSizeR*2, (rect.height - cornerSizeR*2) * h);
        window.draw(sprite);
        sprite.setScale(scale, scale);
    }
    
    if (h < 1.0)
        return;
    if (height_factor < 1.0)
        h = (height_factor - (rect.height - cornerSizeR) / rect.height) * (rect.height / cornerSizeR);

    //TopLeft
    sprite.setPosition(rect.left, rect.top + cornerSizeR * (1.0 - h));
    sprite.setTextureRect(sf::IntRect(0, cornerSizeT * (1.0 - h), cornerSizeT, cornerSizeT * h));
    window.draw(sprite);
    //TopRight
    sprite.setPosition(rect.left + rect.width - cornerSizeR, rect.top + cornerSizeR * (1.0 - h));
    sprite.setTextureRect(sf::IntRect(textureSize.width - cornerSizeT, cornerSizeT * (1.0 - h), cornerSizeT, cornerSizeT * h));
    window.draw(sprite);

    if (rect.height > cornerSizeR * 2)
    {
        //Top
        sprite.setPosition(rect.left + cornerSizeR, rect.top + cornerSizeR * (1.0 - h));
        sprite.setTextureRect(sf::IntRect(cornerSizeT, cornerSizeT * (1.0 - h), 1, cornerSizeT * h));
        sprite.setScale(rect.width - cornerSizeR*2, scale);
        window.draw(sprite);
    }
}

void GuiElement::drawStretched(sf::RenderTarget& window, sf::FloatRect rect, string texture, sf::Color color)
{
    if (rect.width >= rect.height)
    {
        drawStretchedH(window, rect, texture, color);
    }else{
        drawStretchedV(window, rect, texture, color);
    }
}

void GuiElement::drawStretchedH(sf::RenderTarget& window, sf::FloatRect rect, string texture, sf::Color color)
{
    sf::Texture* texture_ptr = textureManager.getTexture(texture);
    sf::Vector2f texture_size = sf::Vector2f(texture_ptr->getSize());
    sf::VertexArray a(sf::TrianglesStrip, 8);
    
    float w = rect.height / 2.0f;
    if (w * 2 > rect.width)
        w = rect.width / 2.0f;
    a[0].position = sf::Vector2f(rect.left, rect.top);
    a[1].position = sf::Vector2f(rect.left, rect.top + rect.height);
    a[2].position = sf::Vector2f(rect.left + w, rect.top);
    a[3].position = sf::Vector2f(rect.left + w, rect.top + rect.height);
    a[4].position = sf::Vector2f(rect.left + rect.width - w, rect.top);
    a[5].position = sf::Vector2f(rect.left + rect.width - w, rect.top + rect.height);
    a[6].position = sf::Vector2f(rect.left + rect.width, rect.top);
    a[7].position = sf::Vector2f(rect.left + rect.width, rect.top + rect.height);
    
    a[0].texCoords = sf::Vector2f(0, 0);
    a[1].texCoords = sf::Vector2f(0, texture_size.y);
    a[2].texCoords = sf::Vector2f(texture_size.x / 2, 0);
    a[3].texCoords = sf::Vector2f(texture_size.x / 2, texture_size.y);
    a[4].texCoords = sf::Vector2f(texture_size.x / 2, 0);
    a[5].texCoords = sf::Vector2f(texture_size.x / 2, texture_size.y);
    a[6].texCoords = sf::Vector2f(texture_size.x, 0);
    a[7].texCoords = sf::Vector2f(texture_size.x, texture_size.y);

    for(int n=0; n<8; n++)
        a[n].color = color;
    
    window.draw(a, texture_ptr);
}

void GuiElement::drawStretchedV(sf::RenderTarget& window, sf::FloatRect rect, string texture, sf::Color color)
{
    sf::Texture* texture_ptr = textureManager.getTexture(texture);
    sf::Vector2f texture_size = sf::Vector2f(texture_ptr->getSize());
    sf::VertexArray a(sf::TrianglesStrip, 8);
    
    float h = rect.width / 2.0;
    if (h * 2 > rect.height)
        h = rect.height / 2.0f;
    a[0].position = sf::Vector2f(rect.left, rect.top);
    a[1].position = sf::Vector2f(rect.left + rect.width, rect.top);
    a[2].position = sf::Vector2f(rect.left, rect.top + h);
    a[3].position = sf::Vector2f(rect.left + rect.width, rect.top + h);
    a[4].position = sf::Vector2f(rect.left, rect.top + rect.height - h);
    a[5].position = sf::Vector2f(rect.left + rect.width, rect.top + rect.height - h);
    a[6].position = sf::Vector2f(rect.left, rect.top + rect.height);
    a[7].position = sf::Vector2f(rect.left + rect.width, rect.top + rect.height);
    
    a[0].texCoords = sf::Vector2f(0, 0);
    a[1].texCoords = sf::Vector2f(0, texture_size.y);
    a[2].texCoords = sf::Vector2f(texture_size.x / 2, 0);
    a[3].texCoords = sf::Vector2f(texture_size.x / 2, texture_size.y);
    a[4].texCoords = sf::Vector2f(texture_size.x / 2, 0);
    a[5].texCoords = sf::Vector2f(texture_size.x / 2, texture_size.y);
    a[6].texCoords = sf::Vector2f(texture_size.x, 0);
    a[7].texCoords = sf::Vector2f(texture_size.x, texture_size.y);

    for(int n=0; n<8; n++)
        a[n].color = color;
    
    window.draw(a, texture_ptr);
}

void GuiElement::drawStretchedHV(sf::RenderTarget& window, sf::FloatRect rect, float corner_size, string texture, sf::Color color)
{
    sf::Texture* texture_ptr = textureManager.getTexture(texture);
    sf::Vector2f texture_size = sf::Vector2f(texture_ptr->getSize());
    sf::VertexArray a(sf::TrianglesStrip, 8);

    for(int n=0; n<8; n++)
        a[n].color = color;
    
    corner_size = std::min(corner_size, rect.height / 2.0f);
    corner_size = std::min(corner_size, rect.width / 2.0f);
    
    a[0].position = sf::Vector2f(rect.left, rect.top);
    a[1].position = sf::Vector2f(rect.left, rect.top + corner_size);
    a[2].position = sf::Vector2f(rect.left + corner_size, rect.top);
    a[3].position = sf::Vector2f(rect.left + corner_size, rect.top + corner_size);
    a[4].position = sf::Vector2f(rect.left + rect.width - corner_size, rect.top);
    a[5].position = sf::Vector2f(rect.left + rect.width - corner_size, rect.top + corner_size);
    a[6].position = sf::Vector2f(rect.left + rect.width, rect.top);
    a[7].position = sf::Vector2f(rect.left + rect.width, rect.top + corner_size);
    
    a[0].texCoords = sf::Vector2f(0, 0);
    a[1].texCoords = sf::Vector2f(0, texture_size.y / 2.0);
    a[2].texCoords = sf::Vector2f(texture_size.x / 2, 0);
    a[3].texCoords = sf::Vector2f(texture_size.x / 2, texture_size.y / 2.0);
    a[4].texCoords = sf::Vector2f(texture_size.x / 2, 0);
    a[5].texCoords = sf::Vector2f(texture_size.x / 2, texture_size.y / 2.0);
    a[6].texCoords = sf::Vector2f(texture_size.x, 0);
    a[7].texCoords = sf::Vector2f(texture_size.x, texture_size.y / 2.0);

    window.draw(a, texture_ptr);

    a[0].position.y = rect.top + rect.height - corner_size;
    a[2].position.y = rect.top + rect.height - corner_size;
    a[4].position.y = rect.top + rect.height - corner_size;
    a[6].position.y = rect.top + rect.height - corner_size;
    
    a[0].texCoords.y = texture_size.y / 2.0;
    a[2].texCoords.y = texture_size.y / 2.0;
    a[4].texCoords.y = texture_size.y / 2.0;
    a[6].texCoords.y = texture_size.y / 2.0;
    
    window.draw(a, texture_ptr);

    a[1].position.y = rect.top + rect.height;
    a[3].position.y = rect.top + rect.height;
    a[5].position.y = rect.top + rect.height;
    a[7].position.y = rect.top + rect.height;
    
    a[1].texCoords.y = texture_size.y;
    a[3].texCoords.y = texture_size.y;
    a[5].texCoords.y = texture_size.y;
    a[7].texCoords.y = texture_size.y;
    
    window.draw(a, texture_ptr);
}

void GuiElement::drawArrow(sf::RenderTarget& window, sf::FloatRect rect, sf::Color color, float rotation)
{
    sf::Sprite arrow;
    textureManager.setTexture(arrow, "gui/SelectorArrow");
    arrow.setPosition(rect.left + rect.width / 2.0, rect.top + rect.height / 2.0);
    float f = rect.height / float(arrow.getTextureRect().height);
    arrow.setScale(f, f);
    arrow.setRotation(rotation);
    arrow.setColor(color);
    window.draw(arrow);
}

sf::Color GuiElement::selectColor(ColorSet& color_set) const
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

GuiElement::LineWrapResult GuiElement::doLineWrap(string text, float font_size, float width)
{
    LineWrapResult result;
    result.text = text;
    result.line_count = 1;
    {
        float currentOffset = 0;
        bool first_word = true;
        std::size_t wordBegining = 0;

        for (std::size_t pos(0); pos < result.text.length(); ++pos)
        {
            char currentChar = result.text[pos];
            if (currentChar == '\n')
            {
                currentOffset = 0;
                first_word = true;
                result.line_count += 1;
                continue;
            }
            else if (currentChar == ' ')
            {
                wordBegining = pos;
                first_word = false;
            }

            sf::Glyph glyph = main_font->getGlyph(currentChar, font_size, false);
            currentOffset += glyph.advance;

            if (!first_word && currentOffset > width)
            {
                pos = wordBegining;
                result.text[pos] = '\n';
                first_word = true;
                currentOffset = 0;
                result.line_count += 1;
            }
        }
    }
    return result;
}
