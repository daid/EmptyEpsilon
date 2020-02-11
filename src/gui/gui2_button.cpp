#include "soundManager.h"
#include "colorConfig.h"
#include "gui2_button.h"
#include "preferenceManager.h"

GuiButton::GuiButton(GuiContainer* owner, string id, string text, func_t func)
: GuiElement(owner, id), text(text), func(func)
{
    override_color = false;
    override_text_color = false;
    text_size = 30;
}

void GuiButton::onDraw(sf::RenderTarget& window)
{
    if (!override_color)
        color = selectColor(colorConfig.button.background);
    if (!override_text_color)
        text_color = selectColor(colorConfig.button.forground);

    if (!enabled)
        drawStretched(window, rect, "gui/ButtonBackground.disabled", color);
    else if (active)
        drawStretched(window, rect, "gui/ButtonBackground.active", color);
    else if (hover)
        drawStretched(window, rect, "gui/ButtonBackground.hover", color);
    else
        drawStretched(window, rect, "gui/ButtonBackground", color);

    if (icon_name != "")
    {
        sf::FloatRect text_rect = rect;
        sf::Sprite icon;
        EGuiAlign text_align = ACenterLeft;
        textureManager.setTexture(icon, icon_name);
        float scale = rect.height / icon.getTextureRect().height * 0.8;
        icon.setScale(scale, scale);
        icon.setRotation(icon_rotation);
        switch(icon_alignment)
        {
        case ACenterLeft:
        case ATopLeft:
        case ABottomLeft:
            icon.setPosition(rect.left + rect.height / 2, rect.top + rect.height / 2);
            text_rect.left = rect.left + rect.height;
            break;
        default:
            icon.setPosition(rect.left + rect.width - rect.height / 2, rect.top + rect.height / 2);
            text_rect.width = rect.width - rect.height;
            text_align = ACenterRight;
        }
        icon.setColor(text_color);
        window.draw(icon);
        drawText(window, text_rect, text, text_align, text_size, main_font, text_color);
    }else{
        drawText(window, rect, text, ACenter, text_size, main_font, text_color);
    }
}

bool GuiButton::onMouseDown(sf::Vector2f position)
{
    return true;
}

void GuiButton::onMouseUp(sf::Vector2f position)
{
    if (rect.contains(position))
    {
        soundManager->playSound("button.wav");
        if (func)
        {
            func_t f = func;
            f();
        }
    }
}

GuiButton* GuiButton::setColor(sf::Color color)
{
    this->override_color = true;
    this->color = color;
    return this;
}

GuiButton* GuiButton::setText(string text)
{
    this->text = text;
    return this;
}

GuiButton* GuiButton::setTextSize(float size)
{
    text_size = size;
    return this;
}

GuiButton* GuiButton::setTextColor(sf::Color color)
{
    this->override_text_color = true;
    this->text_color = color;
    return this;
}

GuiButton* GuiButton::setIcon(string icon_name, EGuiAlign icon_alignment, float rotation)
{
    this->icon_name = icon_name;
    this->icon_alignment = icon_alignment;
    this->icon_rotation = rotation;
    return this;
}

string GuiButton::getText() const
{
    return text;
}

string GuiButton::getIcon() const
{
    return icon_name;
}
