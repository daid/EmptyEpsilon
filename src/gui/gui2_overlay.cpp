#include "engine.h"
#include "gui2_overlay.h"
#include "theme.h"

GuiOverlay::GuiOverlay(GuiContainer* owner, string id, glm::u8vec4 color)
: GuiElement(owner, id), color(color)
{
    texture_mode = TM_None;
    setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
}

void GuiOverlay::onDraw(sp::RenderTarget& renderer)
{
    if (color.a > 0)
    {
        switch(texture_mode)
        {
        case TM_None:
            renderer.fillRect(rect, color);
            break;
        case TM_Tiled:
            renderer.drawTiled(rect, texture);
            break;
        }
    }
}

GuiOverlay* GuiOverlay::setColor(glm::u8vec4 color)
{
    this->color = color;
    return this;
}

GuiOverlay* GuiOverlay::setAlpha(int alpha)
{
    color.a = std::max(0, std::min(255, alpha));
    return this;
}

GuiOverlay* GuiOverlay::setTextureTiled(string texture)
{
    this->texture = texture;
    this->texture_mode = TM_Tiled;
    return this;
}

GuiOverlay* GuiOverlay::setTextureTiledThemed(string theme_element, GuiElement::State state)
{
    this->texture = GuiTheme::getCurrentTheme()->getStyle(theme_element)->get(state).texture;
    this->texture_mode = TM_Tiled;
    return this;
}

GuiOverlay* GuiOverlay::setTextureNone()
{
    this->texture = nullptr;
    this->texture_mode = TM_None;
    return this;
}
