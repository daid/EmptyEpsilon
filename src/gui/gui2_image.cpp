#include "gui2_image.h"

GuiImage::GuiImage(GuiContainer* owner, string id, string texture_name)
: GuiElement(owner, id), color(glm::u8vec4{255,255,255,255}), texture_name(texture_name), angle(0)
{
}

void GuiImage::onDraw(sp::RenderTarget& renderer)
{
    renderer.drawRotatedSprite(texture_name, getCenterPoint(), std::min(rect.size.x, rect.size.y), angle, color);
}
