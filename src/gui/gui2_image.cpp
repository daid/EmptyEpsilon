#include "gui2_image.h"

GuiImage::GuiImage(GuiContainer* owner, string id, string texture_name)
: GuiElement(owner, id), color(sf::Color::White), texture_name(texture_name), angle(0)
{
}

void GuiImage::onDraw(sf::RenderTarget& window)
{
    sf::Sprite image;
    textureManager.setTexture(image, texture_name);
    image.setPosition(rect.left + rect.width / 2.0, rect.top + rect.height / 2.0);
    float f = rect.height / float(image.getTextureRect().height);
    image.setScale(f, f);
    image.setRotation(angle);
    image.setColor(color);
    window.draw(image);
}
