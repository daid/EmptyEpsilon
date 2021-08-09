#include "gui2_image.h"

GuiImage::GuiImage(GuiContainer* owner, string id, string texture_name)
: GuiElement(owner, id), color(sf::Color::White), texture_name(texture_name), angle(0)
{
}

void GuiImage::onDraw(sp::RenderTarget& renderer)
{
    renderer.drawRotatedSprite(texture_name, getCenterPoint(), std::min(rect.size.x, rect.size.y), angle, color);
}
