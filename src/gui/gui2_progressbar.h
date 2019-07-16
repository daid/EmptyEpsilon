#ifndef GUI2_PROGRESSBAR_H
#define GUI2_PROGRESSBAR_H

#include "gui2_element.h"

class GuiProgressbar : public GuiElement
{
private:
    float min_value;
    float max_value;
    float value;
    sf::Color color;
    bool drawBackground;

    string text;
public:
    GuiProgressbar(GuiContainer* owner, string id, float min_value, float max_value, float value);

    virtual void onDraw(sf::RenderTarget& window);

    GuiProgressbar* setValue(float value);
    GuiProgressbar* setRange(float min_value, float max_value);
    GuiProgressbar* setText(string text);
    GuiProgressbar* setColor(sf::Color color);
    GuiProgressbar* setDrawBackground(bool drawBackground);
};

#endif//GUI2_PROGRESSBAR_H
