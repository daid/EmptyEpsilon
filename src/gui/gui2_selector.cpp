#include "gui2_arrowbutton.h"
#include "gui2_selector.h"

GuiSelector::GuiSelector(GuiContainer* owner, string id, std::vector<string> options, int selected_index, func_t func)
: GuiElement(owner, id), options(options), index(selected_index), text_size(30), func(func)
{
    if (selected_index >= (int)options.size())
        selected_index = (int)options.size() - 1;
    if (selected_index < 0)
        selected_index = 0;
    
    (new GuiArrowButton(this, id + "_ARROW_LEFT", 0, [this](GuiButton*) {
        if (this->options.size() < 1)
            return;
        soundManager.playSound("button.wav");
        index = (index + this->options.size() - 1) % this->options.size();
        if (this->func)
            this->func(index);
    }))->setPosition(0, 0, ATopLeft)->setSize(GuiSizeMatchHeight, GuiSizeMax);
    (new GuiArrowButton(this, id + "_ARROW_RIGHT", 180, [this](GuiButton*) {
        if (this->options.size() < 1)
            return;
        soundManager.playSound("button.wav");
        index = (index + 1) % this->options.size();
        if (this->func)
            this->func(index);
    }))->setPosition(0, 0, ATopRight)->setSize(GuiSizeMatchHeight, GuiSizeMax);
}

void GuiSelector::onDraw(sf::RenderTarget& window)
{
    sf::Color color = sf::Color::White;
    if (options.size() < 1 || !enabled)
        color = sf::Color(128, 128, 128, 255);
    
    draw9Cut(window, rect, "border_background", color);
    if (options.size() > 0)
        drawText(window, rect, options[index], ACenter, text_size, color);
}
