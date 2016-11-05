#ifndef SHIPS_LOG_CONTROL_H
#define SHIPS_LOG_CONTROL_H

#include "gui/gui2_element.h"

class GuiPanel;
class GuiAdvancedScrollText;

class ShipsLog : public GuiElement
{
public:
    ShipsLog(GuiContainer* owner);

    virtual void onDraw(sf::RenderTarget& window) override;
    virtual bool onMouseDown(sf::Vector2f position) override;
	virtual void onHotkey(const HotkeyResult& key) override;
private:
    bool open;
    GuiAdvancedScrollText* log_text;
};

#endif//SHIPS_LOG_CONTROL_H
