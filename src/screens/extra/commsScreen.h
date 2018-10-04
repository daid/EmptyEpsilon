#ifndef COMMS_SCREEN_H
#define COMMS_SCREEN_H

#include "gui/gui2_overlay.h"

class GuiKeyValueDisplay;
class GuiAutoLayout;
class GuiButton;
class GuiToggleButton;
class GuiSlider;
class GuiLabel;

class CommsScreen : public GuiOverlay
{
private:

public:
	CommsScreen(GuiContainer* owner);

    virtual void onDraw(sf::RenderTarget& window);
};

#endif//COMMS_SCREEN_H
