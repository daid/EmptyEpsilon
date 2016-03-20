#include "gui2_arrowbutton.h"
#include "gui2_selector.h"
#include "soundManager.h"

GuiSelector::GuiSelector(GuiContainer* owner, string id, func_t func)
: GuiEntryList(owner, id, func), text_size(30)
{
    left = new GuiArrowButton(this, id + "_ARROW_LEFT", 0, [this]() {
        soundManager->playSound("button.wav");
        if (getSelectionIndex() <= 0)
            setSelectionIndex(entries.size() - 1);
        else
            setSelectionIndex(getSelectionIndex() - 1);
        callback();
    });
    left->setPosition(0, 0, ATopLeft)->setSize(GuiSizeMatchHeight, GuiSizeMax);
    right = new GuiArrowButton(this, id + "_ARROW_RIGHT", 180, [this]() {
        soundManager->playSound("button.wav");
        if (getSelectionIndex() >= (int)entries.size() - 1)
            setSelectionIndex(0);
        else
            setSelectionIndex(getSelectionIndex() + 1);
        callback();
    });
    right->setPosition(0, 0, ATopRight)->setSize(GuiSizeMatchHeight, GuiSizeMax);
}

void GuiSelector::onDraw(sf::RenderTarget& window)
{
    left->setEnable(enabled);
    right->setEnable(enabled);
    
    sf::Color color = sf::Color::White;
    if (entries.size() < 1 || !enabled)
        color = sf::Color(128, 128, 128, 255);
    
    drawStretched(window, rect, "gui/SelectorBackground", color);
    if (selection_index >= 0 && selection_index < (int)entries.size())
        drawText(window, rect, entries[selection_index].name, ACenter, text_size, main_font, color);
}

GuiSelector* GuiSelector::setTextSize(float size)
{
    text_size = size;
    return this;
}
