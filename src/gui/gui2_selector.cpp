#include "gui2_selector.h"

GuiSelector::GuiSelector(GuiContainer* owner, string id, std::vector<string> options, int selected_index, func_t func)
: GuiElement(owner, id), options(options), index(selected_index), text_size(30), func(func)
{
    if (selected_index >= (int)options.size())
        selected_index = (int)options.size() - 1;
    if (selected_index < 0)
        selected_index = 0;
}

void GuiSelector::onDraw(sf::RenderTarget& window)
{
    sf::Color color = sf::Color::White;
    if (options.size() < 1 || !enabled)
        color = sf::Color(128, 128, 128, 255);
        
    draw9Cut(window, rect, "border_background", color);
    if (options.size() > 0)
        drawText(window, rect, options[index], ACenter, text_size, color);

    drawArrow(window, sf::FloatRect(rect.left, rect.top, rect.height, rect.height), color, 0);
    drawArrow(window, sf::FloatRect(rect.left + rect.width - rect.height, rect.top, rect.height, rect.height), color, 180);
}

GuiElement* GuiSelector::onMouseDown(sf::Vector2f position)
{
    return this;
}

void GuiSelector::onMouseUp(sf::Vector2f position)
{
    if (options.size() < 1)
        return;

    if (rect.contains(position) && position.x < rect.left + rect.height)
    {
        soundManager.playSound("button.wav");
        index = (index + options.size() - 1) % options.size();
        if (func)
            func(index);
    }
    
    if (rect.contains(position) && position.x > rect.left + rect.width - rect.height)
    {
        soundManager.playSound("button.wav");
        index = (index + 1) % options.size();
        if (func)
            func(index);
    }
}
