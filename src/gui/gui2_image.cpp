#include "gui2_image.h"
#include "theme.h"

GuiImage::GuiImage(GuiContainer* owner, string id, string texture_name)
: GuiElement(owner, id), color(glm::u8vec4{255,255,255,255}), texture_name(texture_name), angle(0)
{
}

void GuiImage::onDraw(sp::RenderTarget& renderer)
{
    renderer.drawRotatedSprite(texture_name, getCenterPoint(), std::min(rect.size.x, rect.size.y), angle, color);
}

GuiImage* GuiImage::setTextureThemed(string theme_element, GuiElement::State state)
{
    this->texture_name = GuiTheme::getCurrentTheme()->getStyle(theme_element)->get(state).texture;
    return this;
}
