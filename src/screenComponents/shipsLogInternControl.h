#ifndef SHIPS_LOGINTERN_CONTROL_H
#define SHIPS_LOGINTERN_CONTROL_H

#include "gui/gui2_element.h"

class GuiPanel;
class GuiAdvancedScrollText;

class ShipsLogIntern : public GuiElement
{
public:
    ShipsLogIntern(GuiContainer* owner);

    virtual void onDraw(sf::RenderTarget& window) override;
    virtual bool onMouseDown(sf::Vector2f position) override;
private:
    bool open;
    GuiAdvancedScrollText* logIntern_text;
};

#endif//SHIPS_LOGINTERN_CONTROL_H
