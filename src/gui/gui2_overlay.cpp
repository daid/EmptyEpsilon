#include "engine.h"
#include "gui2_overlay.h"

GuiOverlay::GuiOverlay(GuiContainer* owner, string id, sf::Color color)
: GuiElement(owner, id), color(color), blocking(false)
{
    texture_mode = TM_None;
    setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
}

void GuiOverlay::onDraw(sf::RenderTarget& window)
{
    if (color.a > 0)
    {
        sf::RectangleShape overlay(sf::Vector2f(rect.width, rect.height));
        overlay.setPosition(rect.left, rect.top);
        overlay.setFillColor(color);
        switch(texture_mode)
        {
        case TM_None:
            break;
        case TM_Centered:
            overlay.setTexture(textureManager.getTexture(texture));
            overlay.setSize(sf::Vector2f(overlay.getTextureRect().width, overlay.getTextureRect().height)); 
            overlay.setPosition(rect.left + rect.width / 2.0 - overlay.getSize().x / 2.0, rect.top + rect.height / 2.0 - overlay.getSize().y / 2.0);
            break;
        case TM_Tiled:
            overlay.setTexture(textureManager.getTexture(texture));
            P<WindowManager> window_manager = engine->getObject("windowManager");
            sf::Vector2i texture_size = window_manager->mapCoordsToPixel(sf::Vector2f(rect.width, rect.height)) - window_manager->mapCoordsToPixel(sf::Vector2f(0, 0));
            overlay.setTextureRect(sf::IntRect(0, 0, texture_size.x, texture_size.y));
            break;
        }
        window.draw(overlay);
    }
}

GuiOverlay* GuiOverlay::setColor(sf::Color color)
{
    this->color = color;
    return this;
}

GuiOverlay* GuiOverlay::setAlpha(int alpha)
{
    color.a = std::max(0, std::min(255, alpha));
    return this;
}

GuiOverlay* GuiOverlay::setTextureCenter(string texture)
{
    this->texture = texture;
    this->texture_mode = TM_Centered;
    return this;
}

GuiOverlay* GuiOverlay::setTextureTiled(string texture)
{
    this->texture = texture;
    this->texture_mode = TM_Tiled;
    return this;
}

GuiOverlay* GuiOverlay::setTextureNone()
{
    this->texture = nullptr;
    this->texture_mode = TM_None;
    return this;
}

bool GuiOverlay::onMouseDown(sf::Vector2f position)
{
    return blocking;
}
