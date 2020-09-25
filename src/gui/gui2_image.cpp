#include "gui2_image.h"

GuiImage::GuiImage(GuiContainer* owner, string id, string texture_name)
: GuiElement(owner, id), color(sf::Color::White), texture_name(texture_name), angle(0)
{
}

void GuiImage::onDraw(sf::RenderTarget& window)
{
    sf::Sprite image;
    textureManager.setTexture(image, texture_name);
    float f = std::min(
        rect.height / float(image.getTextureRect().height),
        rect.width / float(image.getTextureRect().width)
    );
    if (!scale_up) {
        f = std::min(f, 1.0f);
    }
    image.setPosition(rect.left + f * image.getTextureRect().width / 2.0, rect.top + f * image.getTextureRect().height / 2.0);
    image.setScale(f, f);
    image.setRotation(angle);
    image.setColor(color);
    window.draw(image);
}
